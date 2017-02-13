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
  @EnSilencio BIT = 1,
  @EvitarError20101 BIT = 1,
  @CorrerSinAfectar BIT = 0 
AS BEGIN 

  DECLARE
    @LockResult INT,
    @LockName NVARCHAR(255) = 'CUP_SPP_EliminarSaldosMenoresInv',
    @TipoCambio FLOAT,
    @MonedaCosteo VARCHAR(10),
    @ProcesoID INT = 13, -- Este es el ID que identifica el tipo de proceso definido en CUP_Procesos
    @ID INT,
    @CantidadSegura FLOAT = .5 -- Las Cantidades Seguras seran aquellas menores a esta.

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
    EXEC CUP_SPQ_RevisionExistenciasRealesSL 
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
      Costo            FLOAT NULL,
      ExistenciaSU     FLOAT NOT NULL,
      ExistenciaRealSU DECIMAL(18,5) NOT NULL,
      ExistenciaSL     FLOAT NOT NULL,
      ExistenciaRealSL DECIMAL(18,5) NOT NULL,
      ExistenciaSLMayor FLOAT NOT NULL,
      ExistenciaSLMenor FLOAT NOT NULL,
      RemanenteSU      FLOAT NOT NULL,
      Escenario        INT,
      PRIMARY KEY ( 
                    Empresa,
                    Sucursal,
                    Almacen,
                    Articulo,
                    Subcuenta
                  )
    );

    CREATE NONCLUSTERED INDEX [IX_#tmp_CUP_SaldosMenoresSU_Escenario_Almacen]
    ON [dbo].[#tmp_CUP_SaldosMenoresSU](
                                          Escenario,
                                          Empresa,
                                          Sucursal,
                                          Almacen
                                       )
    INCLUDE ( 
               Articulo,
               SubCuenta,
               Costo,
               ExistenciaSU,
               ExistenciaSL,
               ExistenciaSLMayor,
               ExistenciaSLMenor,
               RemanenteSU
            );

    INSERT INTO #tmp_CUP_SaldosMenoresSU
    (
      Empresa,
      Sucursal,
      Almacen,
      Articulo,
      Subcuenta,
      Costo,
      ExistenciaSU,
      ExistenciaRealSU,
      ExistenciaSL,
      ExistenciaRealSL,
      ExistenciaSLMayor,
      ExistenciaSLMenor,
      RemanenteSU,
      Escenario
    )
    SELECT 
      su.Empresa,
      su.Sucursal,
      su.Almacen,
      su.Articulo,
      su.SubCuenta,
      calc.Costo,
      su.SaldoU_Existencia,
      su.SaldoU_ExistenciaReal,
      ExistenciaSL = ISNULL(serielote.Existencia,0),
      ExistenciaRealSL = ISNULL(serieLote.ExistenciaReal,0),
      ExistenciaSLMayor = ISNULL(serieLote.ExistenciaMayor,0),
      ExistenciaSLMenor = ISNULL(serieLote.ExistenciaMenor,0),
      RemanenteSU = ISNULL(calc.RemanenteSU,0),
      escenario.ID
    FROM 
      #tmp_CUP_ArtExistencias su
    JOIN art ON su.Articulo = art.Articulo
    LEFT OUTER JOIN ArtCosto ac ON ac.Articulo = su.Articulo
                               AND ac.Sucursal = su.Sucursal
                               AND ac.Empresa = su.Empresa
    LEFT OUTER JOIN ArtCostoEmpresa ace ON ace.Articulo = su.Articulo
                                       AND ace.Empresa = su.Empresa
    JOIN mon mcosto ON art.MonedaCosto = mcosto.Moneda    
    OUTER APPLY (
                  SELECT
                    Existencia = SUM(ISNULL(sl.Existencia,0)),
                    ExistenciaReal = SUM(ISNULL(sl.ExistenciaReal,0)),
                    ExistenciaMenor = SUM
                                      (
                                        CASE
                                          WHEN ABS(ISNULL(sl.Existencia,0)) > @CantidadSegura THEN 
                                            ISNULL(sl.Existencia,0)
                                          ELSE 
                                            0
                                        END
                                      ),
                    ExistenciaMayor = SUM
                                      (
                                        CASE
                                          WHEN ABS(ISNULL(sl.Existencia,0)) <= @CantidadSegura THEN 
                                            ISNULL(sl.Existencia,0)
                                          ELSE 
                                            0
                                        END
                                      )     
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
                  RemanenteSU = ISNULL(su.SaldoU_Existencia,0) - ISNULL(serielote.ExistenciaMayor,0),
                  Costo = CASE -- Costo. ** Basarse en lo que hace el  spVerCosto ** 
                            WHEN art.MonedaCosto = @MonedaCosteo THEN  
                                ROUND(ISNULL(ac.CostoPromedio, 0),4)
                            ELSE 
                              CASE 
                                WHEN  art.MonedaCosto = 'Pesos' THEN 
                                  ROUND
                                  (
                                      ISNULL(ac.CostoPromedio, ace.CostoPromedio )
                                    / @TipoCambio
                                  ,4)
                                ELSE 
                                  ROUND
                                  (
                                      ISNULL(ac.CostoPromedio, ace.CostoPromedio ) 
                                    / mcosto.TipoCambio
                                  ,4) 
                                * ROUND(@TipoCambio,4)
                              END 
                          END
               ) calc
    -- Saldos Menores
    OUTER APPLY( 
                 SELECT 
                  ConSaldoUMenor =  CASE 
                                      WHEN ABS(ISNULL(su.SaldoU_Existencia,0)) < CASE art.Unidad
                                                                                   WHEN 'KGS' THEN 
                                                                                     1
                                                                                   ELSE 
                                                                                     .5
                                                                                 END
                                        THEN 1 
                                      ELSE 
                                        0
                                    END,
                  ConSaldoSLMenor  = CASE
                                       WHEN ISNULL(serieLote.ExistenciaMenor,0) <> 0 
                                         AND ISNULL(calc.RemanenteSu,0) > 0
                                         AND ISNULL(calc.RemanenteSu,0) >= ISNULL(serieLote.ExistenciaMenor,0)
                                        THEN 1
                                       ELSE 
                                         0
                                     END
               ) saldos_menores
    -- Escenario
    OUTER APPLY(
                  SELECT 
                    ID =  CASE 
                            WHEN( 
                                    ISNULL(saldos_menores.ConSaldoUMenor,0) = 1
                                AND (
                                      ISNULL(su.SaldoU_ExistenciaReal,0) =  ISNULL(serieLote.ExistenciaReal,0)
                                    OR dbo.fnRenglonTipo(art.Tipo) NOT IN ('S','L')
                                    )
                                ) 
                                -- Los saldos chiquititos se pueden sacar sin problema. 
                            OR (
                                  ABS(ISNULL(su.SaldoU_Existencia,0)) < @CantidadSegura
                                AND ABS(ISNULL(serielote.Existencia,0)) < @CantidadSegura
                                )
                              THEN  1 -- Seguro
                            WHEN ISNULL(saldos_menores.ConSaldoSLMenor,0) = 1
                              THEN 2 -- Saldos menores serielote
                            ELSE
                              0 -- Desconocido
                          END   
               ) escenario
    WHERE 
      art.Tipo IN ('Serie','Lote','Normal')
    AND ISNULL(su.SaldoU_Existencia,0) <> 0
    AND (
          ISNULL(saldos_menores.ConSaldoUMenor,0) = 1 
        OR ISNULL(saldos_menores.ConSaldoSLMenor,0) = 1
        )
    -- Si @EvitarError20101 = 1, evita incluir articulos
    -- con costo negativo.
    AND ISNULL(calc.Costo,0) > CASE ISNULL(@EvitarError20101,1)
                                 WHEN 1 THEN
                                   0
                                 ELSE 
                                   ISNULL(calc.Costo,0) -1
                               END;

    -- Revisa que exista un escenario definido que la herramienta
    -- este preparada para trabajar.
    IF EXISTS
    (
      SELECT Escenario 
      FROM #tmp_CUP_SaldosMenoresSU
      WHERE Escenario <> 0
    )
    BEGIN

      -- Guardamos un registro del proceso de eliminacion de saldos menores.
      INSERT INTO CUP_EliminarSaldosMenoresInv ( Usuario )
      VALUES ( @Usuario );

      SET @ID = SCOPE_IDENTITY()

      -- Prepara los Ajustes seguros de eliminar. Es decir, aquellos donde no 
      -- deberiamos esperar problemas o procesos especiales.
      EXEC CUP_SPI_EliminarSaldosMenoresInv_Seguros @ProcesoID, @ID

      -- Afecta los Ajustes Menores generados por este proceso.
      IF ISNULL(@CorrerSinAfectar,0) = 0
        EXEC CUP_SPP_EliminarSaldosMenoresInv_AfectarAjustes @ID

      -- Reporta el resultado del proceso.
      IF ISNULL(@EnSilencio,0) = 0        
        EXEC CUP_SPQ_EliminarSaldosMenoresInv_ResultadoDelProceso @ID

    END

    -- Temp
    SELECT 
      su.*,
      a.Unidad,
      a.Grupo,
      a.Familia,
      a.Categoria
    from
      #tmp_CUP_SaldosMenoresSU su
    JOIN art a ON a.Articulo = su.Articulo
    --
    
    -- Libera el bloqueo del procedimiento
    EXECUTE sp_releaseapplock @Resource = @LockName
  END

END