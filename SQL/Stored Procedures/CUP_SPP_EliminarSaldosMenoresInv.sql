SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS (SELECT * 
		   FROM SYSOBJECTS 
		   WHERE ID = OBJECT_ID('dbo.CUP_SPP_EliminarSaldosMenoresInv') AND 
				 TYPE = 'P')
BEGIN
  DROP PROCEDURE dbo.CUP_SPP_EliminarSaldosMenoresInv
END	

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-09

  Description: Procedimiento almacenado encargado de controlar
  la logica de la eliminacion de saldos menores de Inventario.
 
  Example: EXEC CUP_SPP_EliminarSaldosMenoresInv
            @Usuario = 'PRODAUT',
            @Empresa = 'CML',
            @Sucursal = NULL,
            @Almacen = NULL,
            @Articulo = NULL,
            @Subcuenta = NULL,
            @EnSilencio = 0

  ** Nota: Cuando se quiera filtrar especificamente por un
  articulo sin subcuenta, se debe usar @Subcuenta = '' y no 
  NULL, ya que si es NULL entonces no se utilizara este
  Filtro.

============================================= */


CREATE PROCEDURE dbo.CUP_SPP_EliminarSaldosMenoresInv
  @Usuario CHAR(10),
  @Empresa CHAR(5),
  @Sucursal INT = NULL,
  @Almacen CHAR(10) = NULL,
  @Articulo CHAR(20) = NULL,
  @Subcuenta VARCHAR(20) = NULL,
  @EnSilencio BIT = 1
AS BEGIN 

  DECLARE
    @LockResult INT,
    @LockName NVARCHAR(255) = 'CUP_Herramienta_Eliminacion_Saldos_Menores_Inv',
    @TipoCambio FLOAT,
    @MonedaCosteo VARCHAR(10),
    @Ok INT,
    @OkRef VARCHAR(255),
    @ProcesoID INT = 13, -- Este es el ID que identifica el tipo de proceso definido en CUP_Procesos
    @ID INT,
    @r_AjusteID INT

  SET NOCOUNT ON;

  -- Este procedimiento solo ejecutarse 1 a la vez
  EXECUTE @LockResult = sp_getapplock 
                           @Resource    = @LockName, 
                           @LockMode    = 'Exclusive',
                           @LockTimeout = 0

  -- @LockResult <> 0 significa que esta bloqueado
  IF @LockResult <> 0 
  BEGIN
    THROW 99947,
          'Solo puede existir 1 ejecución activa a la vez de La herramienta de eliminación saldos menores inv.',
          1
  END
  ELSE 
  BEGIN

    SELECT 
      @MonedaCosteo = MonedaCosteo,
      @TipoCambio = Mon.TipoCambio
    FROM 
      EmpresaCFG e
    JOIN Mon ON e.MonedaCosteo = Mon.Moneda
    WHERE 
      e.Empresa = @Empresa

    -- Obtener las Existencias sin considerar SerieLote ( saldoU )
    IF OBJECT_ID('tempdb..#tmp_CUP_ArtExistencias') IS NOT NULL 
      DROP TABLE #tmp_CUP_ArtExistencias;

    CREATE TABLE #tmp_CUP_ArtExistencias
    (
      Empresa               CHAR(5) NOT NULL,
      Sucursal              INT NOT NULL,
      Almacen               CHAR(10) NOT NULL,
      Articulo              CHAR(20) NOT NULL,
      SubCuenta             VARCHAR(20) NOT NULL,
      AuxU_Existencia       FLOAT NOT NULL,
      AuxU_ExistenciaReal   DECIMAL(18,5) NOT NULL,
      AcumU_Existencia      FLOAT NOT NULL,
      AcumU_ExistenciaReal  DECIMAL(18,5) NOT NULL,
      SaldoU_Existencia     FLOAT NOT NULL,
      SaldoU_ExistenciaReal DECIMAL(18,5) NOT NULL,
      PRIMARY KEY ( 
                    Empresa,
                    Sucursal,
                    Almacen,
                    Articulo,
                    Subcuenta
                  )
    )

    INSERT INTO #tmp_CUP_ArtExistencias
    (
      Empresa,
      Sucursal,
      Almacen,
      Articulo,
      Subcuenta,
      AuxU_Existencia,
      AuxU_ExistenciaReal,
      AcumU_Existencia,
      AcumU_ExistenciaReal,
      SaldoU_Existencia,
      SaldoU_ExistenciaReal
    )
    EXEC CUP_SPQ_RevisionExistenciasRealesU
      @Empresa,
      @Sucursal,
      @Almacen,
      @Articulo,
      @Subcuenta

    -- Todos los articulos con saldoU en 0 deberian tener suserie lote en 0 tambien
    UPDATE sl
    SET 
      sl.Existencia = 0,
      sl.ExistenciaAlterna = 0 
    FROM 
       #tmp_CUP_ArtExistencias su
    JOIN SerieLote sl ON sl.Empresa = su.Empresa
                     AND sl.Sucursal = su.Sucursal
                     AND sl.Almacen = su.Almacen
                     AND sl.Articulo = su.Articulo
                     AND sl.SubCuenta = su.SubCuenta
    WHERE 
      ISNULL(su.SaldoU_Existencia,0) = 0 
    AND ISNULL(sl.Existencia,0) <> 0

    -- OBtener las existencia SerieLote,
    IF OBJECT_ID('tempdb..#tmp_CUP_ArtExistenciasSL') IS NOT NULL 
      DROP TABLE #tmp_CUP_ArtExistenciasSL;

    CREATE TABLE #tmp_CUP_ArtExistenciasSL
    (
      Empresa        CHAR(5) NOT NULL,
      Sucursal       INT NOT NULL,
      Almacen        CHAR(10) NOT NULL,
      Articulo       CHAR(20) NOT NULL,
      SubCuenta      VARCHAR(20) NOT NULL,
      SerieLote      VARCHAR(50) NOT NULL,
      Propiedades    VARCHAR(20) NULL,
      Existencia     FLOAT  NOT NULL,
      ExistenciaReal DECIMAL(18,5) NOT NULL
      PRIMARY KEY ( 
                    Empresa,
                    Sucursal,
                    Almacen,
                    Articulo,
                    Subcuenta,
                    SerieLote
                  )
    )

    INSERT INTO #tmp_CUP_ArtExistenciasSL
    (
      Empresa,
      Sucursal,
      Almacen,
      Articulo,
      Subcuenta,
      SerieLote,
      Propiedades,
      Existencia,
      ExistenciaReal
    )
    EXEC CUP_SPQ_RevisionExistenciasRealesUSL 
      @Empresa,
      @Sucursal,
      @Almacen,
      @Articulo,
      @Subcuenta

    -- Identifica los saldos menors SU, ya que de entrada 
    -- este tipo es mas facil de limpiar 
    IF OBJECT_ID('tempdb..#tmp_CUP_SaldosMenoresSU') IS NOT NULL 
      DROP TABLE #tmp_CUP_SaldosMenoresSU;

    CREATE TABLE #tmp_CUP_SaldosMenoresSU
    (
      Empresa          CHAR(5) NOT NULL,
      Sucursal          INT NOT NULL,
      Almacen         CHAR(10) NOT NULL,
      Articulo         CHAR(20) NOT NULL,
      SubCuenta        VARCHAR(20) NOT NULL,
      ExistenciaSU     FLOAT NOT NULL,
      ExistenciaRealSU DECIMAL(18,5) NOT NULL,
      ExistenciaSL     FLOAT NOT NULL,
      ExistenciaRealSL DECIMAL(18,5) NOT NULL,
      Escenario        INT,
      PRIMARY KEY ( 
                    Empresa,
                    Sucursal,
                    Almacen,
                    Articulo,
                    Subcuenta
                  )
    )

    INSERT INTO #tmp_CUP_SaldosMenoresSU
    (
      Empresa,
      Sucursal,
      Almacen,
      Articulo,
      Subcuenta,
      ExistenciaSU,
      ExistenciaRealSU,
      ExistenciaSL,
      ExistenciaRealSL,
      EScenario
    )
    SELECT 
      su.Empresa,
      su.Sucursal,
      su.Almacen,
      su.Articulo,
      su.SubCuenta,
      su.SaldoU_Existencia,
      su.SaldoU_ExistenciaReal,
      ExistenciaSL = ISNULL(serielote.Existencia,0),
      ExistenciaRealSL = ISNULL(serieLote.ExistenciaReal,0),
      calc.Escenario
    FROM 
      #tmp_CUP_ArtExistencias su
    JOIN art ON su.Articulo = art.Articulo
    OUTER APPLY (
                  SELECT
                    Existencia = SUM(ISNULL(sl.Existencia,0)),
                    ExistenciaReal = SUM(ISNULL(sl.ExistenciaReal,0))
                  FROM
                    #tmp_CUP_ArtExistenciasSL sl  
                  WHERE 
                    sl.Empresa = su.Empresa
                  AND sl.Sucursal = su.Sucursal
                  AND sl.Almacen = su.Almacen
                  AND sl.Articulo = su.Articulo
                  AND sl.SubCuenta = su.SubCuenta
                  ) serieLote
    -- calculados
    OUTER APPLY(
                SELECT 
                  Escenario =  CASE 
                            WHEN
                                -- Donde SaldoU y ExsistenciaSl ( o art tip normal) 
                                --  sean iguales y menores  a 1.
                                ( 
                                    ABS(ISNULL(su.SaldoU_Existencia,0)) < 1
                                AND (
                                      ISNULL(serieLote.Existencia,0) = ISNULL(su.SaldoU_Existencia,0)
                                    OR dbo.fnRenglonTipo(art.Tipo) NOT IN ('S','L')
                                    )
                                ) 
                                -- Los saldos chiquititos ( menor a 4 decimales ) se pueden sacar sin problema. 
                            OR (
                                  ABS(ISNULL(su.SaldoU_Existencia,0)) < .0001
                                AND ABS(ISNULL(serielote.Existencia,0)) < .0001
                                )
                              THEN  1 -- Seguro
                            ELSE
                              0 -- Desconocido
                          END       
               ) calc
    WHERE 
      art.Tipo IN ('Serie','Lote','Normal')
    AND ISNULL(su.SaldoU_Existencia,0) <> 0
    AND ABS(ISNULL(su.SaldoU_Existencia,0)) < 1

    -- Revisa que exista un escenario definido que la herramienta
    -- este preparada para trabajar.
    IF EXISTS
    (
      SELECT Escenario 
      FROM #tmp_CUP_SaldosMenoresSU
      WHERE Escenario <> 0
    )
    BEGIN
      DECLARE @AjustesGenerados TABLE
      (
        ID INT NOT NULL,
        Escenario INT NOT NULL
      )
      -- Guardamos un registro del proceso de eliminacion de saldos menores.
      INSERT INTO CUP_EliminarSaldosMenoresInv ( Usuario )
      VALUES ( @Usuario )

      SET @ID = SCOPE_IDENTITY()

      -- Prepara los Ajustes que trabajaran los escenarios seguros de eliminar.
      -- Es decir, aquellos donde no deberiamos esperar problemas o procesos
      -- muy especiales.
      EXEC CUP_SPI_EliminarSaldosMenoresInv_Seguros @ID

      INSERT INTO Inv
      (
        Empresa,
        Sucursal,
        Mov,
        Estatus,
        FechaEmision,
        FechaRegistro,
        Concepto,
        Moneda,
        TipoCambio,
        Almacen,
        Usuario,
        CUP_Origen,
        CUP_OrigenID
      )
      OUTPUT 
        INSERTED.ID,
        1
      INTO @AjustesGenerados
      (
        ID,
        Escenario
      )
      SELECT DISTINCT 
          su.Empresa,
          su.Sucursal,
          Mov = 'Ajuste',
          Estatus = 'SINAFECTAR',
          FechaEmision = CAST(GETDATE() AS DATE),
          FechaRegistro = GETDATE(),
          Concepto = 'Ajuste por saldos Menores',
          Moneda = 'Pesos',
          TipoCambio = 1,
          su.Almacen,
          Usuario = 'PRODAUT',
          CUP_Origen = @ProcesoID,
          CUP_OrigenID  = @ID
      FROM 
        #tmp_CUP_SaldosMenoresSU su
      WHERE 
        su.Escenario = 1

      -- Guarda el registro del ajuste generado junto con su tipo.
      INSERT INTO
        CUP_EliminarSaldosMenoresInv_AjustesGenerados
      (
        ID,
        Modulo,
        ModuloID,
        Escenario
      )
      SELECT 
        @ID,
        Modulo = 'INV',
        ModuloID = ag.ID,
        ag.Escenario
      FROM 
        @AjustesGenerados ag

      -- Inserta el detalle de los movimientos.
      INSERT INTO InvD 
      ( 
        ID,
        Renglon,
        RenglonSub,
        RenglonID,
        RenglonTipo,
        Cantidad,
        Almacen,
        Articulo,
        SubCuenta,
        Costo,
        Unidad,
        Factor,
        CantidadInventario,
        Sucursal 
      )  
      SELECT 
        i.ID, 
        Renglon = CAST(   2048 
                        * ROW_NUMBER() OVER (
                                              ORDER BY
                                                i.ID,
                                                su.Articulo,
                                                su.Subcuenta
                                             ) 
                       AS FLOAT),  --(de 2048 en 2048)
        RenglonSub= ROW_NUMBER() OVER (
                                        PARTITION BY
                                          i.ID,
                                          su.Articulo,
                                          su.Subcuenta 
                                        ORDER BY
                                          su.Subcuenta
                                        ) - 1, 
        RenglonID = ROW_NUMBER() OVER (
                                        ORDER BY
                                          i.ID,
                                          su.Articulo,
                                          su.Subcuenta
                                       ),                        
        RenglonTipo = dbo.fnRenglonTipo(a.Tipo),                                                
        Cantidad =  su.ExistenciaSU * -1 , 
        Almacen = i.Almacen, 
        Articulo = su.Articulo, 
        SubCuenta = NULLIF(su.Subcuenta,''),
        Costo = CASE -- Costo. ** Basarse en lo que hace el  spVerCosto ** 
                  WHEN a.MonedaCosto = @MonedaCosteo THEN  
                      ROUND(ISNULL(ac.CostoPromedio, 0),4)
                  ELSE 
                    CASE 
                      WHEN  a.MonedaCosto = 'Pesos' THEN 
                          ROUND(ISNULL(ac.CostoPromedio, ace.CostoPromedio )  / @TipoCambio,4)
                      ELSE 
                          ROUND(ISNULL(ac.CostoPromedio, ace.CostoPromedio ) / mcosto.TipoCambio,4) *  ROUND(@TipoCambio,4)
                    END 
                END,  
        Unidad = a.Unidad,
        Factor = 1,
        CantidadInventario = ISNULL(su.ExistenciaSU,0) * -1, 
        Sucursal = su.Sucursal  
      FROM 
        CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
      JOIN Inv i ON 'INV' = ajm.Modulo
                AND i.Id = ajm.ModuloID
      JOIN #tmp_CUP_SaldosMenoresSU su ON su.Almacen = i.Almacen  
      JOIN art a ON a.Articulo = su.Articulo   
      left OUTER JOIN ArtCosto ac ON ac.Articulo = su.Articulo
                                  AND ac.Sucursal = su.Sucursal
                                  AND ac.Empresa = su.Empresa
      LEFT OUTER JOIN ArtCostoEmpresa ace ON ace.Articulo = su.Articulo
                                          AND ace.Empresa = su.Empresa
      JOIN mon mcosto ON a.MonedaCosto = mcosto.Moneda                    
      WHERE 
          ajm.ID = @ID
      AND ajm.Modulo = 'INV'
      AND su.Escenario = 1

      -- Actualiza el Renglon Maximo del cabecero.
      UPDATE i 
      SET RenglonID = (SELECT MAX(d.RenglonID)
                        FROM InvD d 
                        WHERE d.ID = i.ID)
      FROM
        CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
      JOIN inv i ON i.ID = ajm.ModuloID
      WHERE 
        ajm.Id = @ID 
      AND ajm.Modulo = 'INV'

      --SeriesLote
      INSERT INTO SerieLoteMov 
      (
        Empresa,
        Modulo,
        ID,
        RenglonID,
        Articulo,
        SubCuenta,
        SerieLote,
        Cantidad,
        Propiedades,
        Sucursal
      )  
      SELECT 
        i.Empresa, 
        ajm.Modulo,
        ajm.ModuloID,
        d.RenglonID,
        d.Articulo,
        Subcuenta = ISNULL(d.Subcuenta,''),
        sl.SerieLote,
        sl.Existencia,
        sl.Propiedades,
        i.Sucursal
      FROM
        CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
      JOIN Inv i ON  i.Id = ajm.ModuloID
      JOIN InvD d ON d.ID = i.ID   
      JOIN #tmp_CUP_ArtExistenciasSL sl ON i.Empresa = sl.Empresa
                                        AND i.Sucursal = sl.Sucursal
                                        AND i.Almacen = sl.Almacen
                                        AND d.Articulo = sl.Articulo
                                        AND ISNULL(d.SubCuenta,'') = ISNULL(sl.Subcuenta,'')
      WHERE
        ajm.ID = @ID
      AND ajm.Modulo = 'INV'
      AND d.RenglonTipo IN ('S','L')

      -- Afecta los Ajustes Menores.
      DECLARE cr_AjustesMenores CURSOR LOCAL FAST_FORWARD FOR 
      SELECT 
        i.ID 
      FROM 
        CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
      JOIN Inv i ON i.ID = ajm.ModuloID
      WHERE 
        ajm.Id = @ID 
      AND ajm.Modulo = 'INV'

      OPEN cr_AjustesMenores

      FETCH NEXT FROM cr_AjustesMenores INTO @r_AjusteID

      WHILE @@FETCH_STATUS = 0
      BEGIN

        SELECT 
          @OK = NULL,
          @OKRef = NULL

        EXEC spAfectar
          @Modulo = 'INV', 
          @ID = @r_AjusteID ,
          @Accion = 'AFECTAR',
          @Base = 'TODO',
          @GenerarMov =NULL, 
          @Usuario = 'PRODAUT',
          @SincroFinal = 0, 
          @EnSilencio = 1,
          @OK = @OK OUTPUT,
          @OkRef = @OkRef OUTPUT

        ---- Apartado para eliminar renglones con el problema del costeo.
        --WHILE @Ok = 20101
        --  EXEC CUP_SPP_EliminaSMInv_RemueveArtProblemaCosto
        --    @ID = @r_AjusteID,
        --    @Ok = @OK INT OUTPUT,
        --    @OkREf = @OkRef INT OUTPUT
        --

        FETCH NEXT FROM cr_AjustesMenores INTO @r_AjusteID
      END

      CLOSE cr_AjustesMenores

      DEALLOCATE cr_AjustesMenores


      IF ISNULL(@EnSilencio,0) = 0
      BEGIN

        SELECT
          ajm.ID,
          ajm.Modulo,
          ajm.ModuloId,
          ajm.Escenario,
          i.Almacen,
          i.Estatus,
          ab.Accion,
          ab.Base,
          ab.GenerarMov,
          ab.Usuario,
          ab.FechaRegistro,
          ab.Ok,
          ab.OkRef,
          MensajeDesc =  m.Descripcion
        FROM
          CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
        JOIN inv i ON i.ID = ajm.ModuloID
        LEFT JOIN AfectarBitacora ab ON ab.Modulo = ajm.Modulo
                                    AND ab.ModuloID = ajm.ModuloID
        LEFT JOIN MensajeLista m ON m.Mensaje = ab.OK
        WHERE 
          ajm.Id = @ID
        AND ajm.Modulo = 'INV'
        ORDER BY
          ajm.Id,
          ajm.Modulo,
          ajm.ModuloID,
          ab.ID ASC

        SELECT * from #tmp_CUP_SaldosMenoresSU

        /*
        -- Detalle Ajustes
        SELECT
          ajm.Id,
          ajm.Modulo,
          ajm.ModuloId,
          i.Mov,
          i.Movid,
          i.Almacen,
          d.Articulo,
          d.SubCuenta,
          d.Cantidad,
          d.Factor,
          d.CantidadInventario,
          d.Costo
        FROM
          CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
        JOIN inv i ON i.ID = ajm.ModuloID
        JOIN InvD d ON d.ID = ajm.ID
        WHERE 
          ajm.Id = @ID
        AND ajm.Modulo = 'INV'
        */
      END
    END
    
    -- Libera el bloqueo del procedimiento
    EXECUTE sp_releaseapplock @Resource = @LockName
  END

END