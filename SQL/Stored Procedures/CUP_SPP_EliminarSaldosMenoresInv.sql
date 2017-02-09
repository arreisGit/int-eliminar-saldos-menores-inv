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
  Creation Date: 2017-02-07

  Description: Procedimiento almacenado encargado de controlar
  la logica de la eliminacion de saldos menores de Inventario.
 
  Example: EXEC CUP_SPP_EliminarSaldosMenoresInv 
            @Empresa = 'CML',
            @Sucursal = NULL,
            @Almacen = NULL,
            @Articulo = NULL,
            @Subcuenta = NULL

  ** Nota: Cuando se quiera filtrar especificamente por un
  articulo sin subcuenta, se debe usar @Subcuenta = '' y no 
  NULL, ya que si es NULL entonces no se utilizara este
  Filtro.

============================================= */


CREATE PROCEDURE dbo.CUP_SPP_EliminarSaldosMenoresInv
  @Empresa CHAR(5),
  @Sucursal INT = NULL,
  @Almacen CHAR(10) = NULL,
  @Articulo CHAR(20) = NULL,
  @Subcuenta VARCHAR(20) = NULL
AS BEGIN 

  DECLARE
    @LockResult INT,
    @LockName NVARCHAR(255) = 'CUP_Herramienta_Eliminacion_Saldos_Menores_Inv',
    @TipoCambio FLOAT,
    @MonedaCosteo VARCHAR(10),
    @Ok INT,
    @OkRef VARCHAR(255),
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

    -- 1 ) OBtenemos las Existencias sin considerar SerieLote,
    --  ( de saldoU)
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

    -- 2) Todos los articulos con saldoU en 0 deberian tener su serie lote en 0 tambien
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


    -- 2 ) OBtenemos las Existencia SerieLote,
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

    -- 3 ) IDentificamos los saldos menors SU, ya que de entrada 
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
      Tipo             VARCHAR(50) NULL,
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
      Tipo
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
      Tipo = calc.Tipo
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
                  Tipo =  CASE 
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
                              THEN  'SEGURO' 
                            ELSE
                              'UKNOWN'
                          END       
               ) calc
    WHERE 
      art.Tipo IN ('Serie','Lote','Normal')
    AND ISNULL(su.SaldoU_Existencia,0) <> 0
    AND ABS(ISNULL(su.SaldoU_Existencia,0)) < 1

    -- Crea y afecta los Ajustes encargados de eliminar, 
    -- aquellos saldos menores considerados como seguros.
    IF OBJECT_ID('tempdb..#tmp_CUP_AdjustesSaldosMenores') IS NOT NULL 
      DROP TABLE #tmp_CUP_AdjustesSaldosMenores;

    CREATE TABLE #tmp_CUP_AdjustesSaldosMenores
    (
      ID INT NOT NULL PRIMARY KEY,
      Almacen CHAR(10) NOT NULL UNIQUE,
      Tipo VARCHAR(50) NOT NULL,
      OK INT NULL,
      OkRef VARCHAR(255) NULL
    )

    CREATE NONCLUSTERED INDEX IX_#tmp_CUP_AdjustesSaldosMenores
        ON #tmp_CUP_AdjustesSaldosMenores ( Almacen )
    INCLUDE ( ID, Tipo );

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
      Usuario
    )
    OUTPUT
      INSERTED.ID,
      INSERTED.Almacen,
      'SEGURO'
    INTO
      #tmp_CUP_AdjustesSaldosMenores
    (
      ID,
      Almacen,
      Tipo
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
        Usuario = 'PRODAUT'
    FROM 
      #tmp_CUP_SaldosMenoresSU su
    WHERE 
      su.Tipo = 'SEGURO'

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
      ajm.ID, 
      Renglon = CAST(2048 * ROW_NUMBER() OVER (ORDER BY ajm.ID, su.Articulo,su.Subcuenta) AS FLOAT),  --(de 2048 en 2048)
      RenglonSub= ROW_NUMBER() OVER (PARTITION BY ajm.ID, su.Articulo, su.Subcuenta ORDER BY su.Subcuenta) - 1, 
      RenglonID = ROW_NUMBER() OVER (ORDER BY ajm.ID, su.Articulo, su.Subcuenta),                        
      RenglonTipo = dbo.fnRenglonTipo(a.Tipo),                                                
      Cantidad =  su.ExistenciaSU * -1 , 
      Almacen = ajm.Almacen, 
      Articulo = su.Articulo, 
      SubCuenta = NULLIF(su.Subcuenta,''),
      Costo = CASE -- Costo. ** Basarse en lo que hace el  spVerCosto ** 
                WHEN a.MonedaCosto = @MonedaCosteo THEN  
                    ROUND(ISNULL(ac.CostoPromedio,ISNULL(ace.CostoPromedio,0)),4)
                ELSE 
                  CASE 
                    WHEN  a.MonedaCosto = 'Pesos' THEN 
                        ROUND(ISNULL(ac.CostoPromedio,ISNULL(ace.CostoPromedio,0))  / @TipoCambio,4)
                    ELSE 
                        ROUND(ISNULL(ac.CostoPromedio,ISNULL(ace.CostoPromedio,0)) / mcosto.TipoCambio,4) *  ROUND(@TipoCambio,4)
                  END 
              END,  
      Unidad = a.Unidad,
      Factor = 1,
      CantidadInventario = ISNULL(su.ExistenciaSU,0) * -1, 
      Sucursal = su.Sucursal  
    FROM 
      #tmp_CUP_AdjustesSaldosMenores ajm
    JOIN #tmp_CUP_SaldosMenoresSU su ON su.Almacen = ajm.Almacen
    JOIN art a ON a.Articulo = su.Articulo   
    left OUTER JOIN ArtCosto ac ON ac.Articulo = su.Articulo
                                AND ac.Sucursal = su.Sucursal
                                AND ac.Empresa = su.Empresa
    LEFT OUTER JOIN ArtCostoEmpresa ace ON ace.Articulo = su.Articulo
                                        AND ace.Empresa = su.Empresa
    JOIN mon mcosto ON a.MonedaCosto = mcosto.Moneda                    
    WHERE 
      su.Tipo  = 'SEGURO'

    -- Actualiza el Renglon Maximo del cabecero.
    UPDATE i 
    SET RenglonID = (SELECT MAX(d.RenglonID)
                      FROM InvD d 
                      WHERE d.ID = i.ID)
    FROM
      #tmp_CUP_AdjustesSaldosMenores ajm
    JOIN inv i ON i.ID = ajm.ID
              AND i.Almacen = ajm.Almacen

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
      'INV',
      ajm.ID,
      d.RenglonID,
      d.Articulo,
      Subcuenta = ISNULL(d.Subcuenta,''),
      sl.SerieLote,
      sl.Existencia,
      sl.Propiedades,
      i.Sucursal
    FROM
      #tmp_CUP_AdjustesSaldosMenores ajm
    JOIN Inv i ON i.Id = ajm.ID
    JOIN InvD d ON d.ID = i.ID   
    JOIN #tmp_CUP_ArtExistenciasSL sl ON i.Empresa = sl.Empresa
                                      AND i.Sucursal = sl.Sucursal
                                      AND i.Almacen = sl.Almacen
                                      AND d.Articulo = sl.Articulo
                                      AND ISNULL(d.SubCuenta,'') = ISNULL(sl.Subcuenta,'')
    WHERE
      d.RenglonTipo IN ('S','L')

    -- Afecta los Ajustes Menores
    DECLARE cr_AjustesMenores CURSOR LOCAL FAST_FORWARD FOR 
    SELECT 
      ID 
    FROM 
      #tmp_CUP_AdjustesSaldosMenores

    OPEN cr_AjustesMenores

    FETCH NEXT FROM cr_AjustesMenores INTO @r_AjusteID

    WHILE @@FETCH_STATUS = 0
    BEGIN
      SELECT 
        @OK = NULL,
        @OKRef = NULL

      -- Afecta el ajuste recien creado y guardamos el resultado.
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

      -- Registra el Resultado.
      UPDATE #tmp_CUP_AdjustesSaldosMenores
      SET Ok = @Ok, OkRef = @OkRef
      WHERE id = @r_AjusteID

      FETCH NEXT FROM cr_AjustesMenores INTO @r_AjusteID
    END

    CLOSE cr_AjustesMenores

    DEALLOCATE cr_AjustesMenores

    -- Libera el bloqueo del procedimiento
    EXECUTE sp_releaseapplock @Resource = @LockName
  END

END