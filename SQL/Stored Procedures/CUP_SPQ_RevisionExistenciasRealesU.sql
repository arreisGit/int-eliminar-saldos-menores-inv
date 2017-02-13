SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS (SELECT * 
		   FROM SYSOBJECTS 
		   WHERE ID = OBJECT_ID('dbo.CUP_SPQ_RevisionExistenciasRealesU') AND 
				 TYPE = 'P')
BEGIN
  DROP PROCEDURE dbo.CUP_SPQ_RevisionExistenciasRealesU
END	

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-07

  Description: Obtiene un comparativo de las exitencias
  en AuxiliarU, AcumU y SaldoU. Incluido el saldo a 16 
  decimales y el real ( a 4 decimles ).
 
  Example: EXEC CUP_SPQ_RevisionExistenciasRealesU 
              @Empresa = NULL,
              @Sucursal = NULL,
              @Almacen = NULL,
              @Articulo = NULL,
              @Subcuenta = NULL

  ** Nota: Cuando se quiera filtrar especificamente por un
  articulo sin subcuenta, se debe usar @Subcuenta = '' y no 
  NULL, ya que si es NULL entonces no se utilizara este
  Filtro.

============================================= */


CREATE PROCEDURE dbo.CUP_SPQ_RevisionExistenciasRealesU
  @Empresa CHAR(5) = NULL,
  @Sucursal INT = NULL,
  @Almacen CHAR(10) = NULL,
  @Articulo CHAR(20) = NULL,
  @Subcuenta VARCHAR(20) = NULL
AS BEGIN 
 
  SET NOCOUNT ON;

  -- 1 ) Existencia Nivel Auxiliaru
  IF OBJECT_ID('tempdb..#tmp_CUP_AuxiliarU') IS NOT NULL 
    DROP TABLE #tmp_CUP_AuxiliarU;

  CREATE TABLE #tmp_CUP_AuxiliarU
  (
    Empresa             CHAR(5) NOT NULL,
    Sucursal            INT NOT NULL,
    Almacen             CHAR(10) NOT NULL,
    Articulo            CHAR(20) NOT NULL,
    SubCuenta           VARCHAR(20) NOT NULL,
    Existencia          FLOAT NOT NULL,
    PRIMARY KEY (
                  Empresa,
                  Sucursal,
                  Almacen,
                  ARticulo,
                  Subcuenta
                )
  )

  INSERT INTO #tmp_CUP_AuxiliarU
  (
    Empresa,
    Sucursal,
    Almacen,
    ARticulo,
    Subcuenta,
    Existencia
  )
  SELECT 
    auxU.Empresa,
    auxU.Sucursal,
    Almacen = auxU.Grupo,
    Articulo = auxU.Cuenta,
    SubCuenta = ISNULL(auxU.SubCuenta,''),
    Existencia = SUM(ISNULL(auxU.CargoU,0) - ISNULL(auxU.AbonoU,0))
  FROM 
    AuxiliarU auxU 
  WHERE 
    auxU.Rama = 'INV'
  AND auxU.Empresa = ISNULL( @Empresa, auxU.Empresa )
  AND auxU.Sucursal = ISNULL( @Sucursal, auxU.Sucursal )
  AND auxU.Grupo = ISNULL( @Almacen, auxU.Grupo )
  AND auxU.Cuenta = ISNULL( @Articulo, auxU.Cuenta )
  AND auxU.SubCuenta = ISNULL( @SubCuenta, auxU.SubCuenta )
  GROUP BY 
    auxU.Empresa,
    auxU.Sucursal,
    auxU.Grupo,
    auxU.Cuenta,
    ISNULL(auxU.SubCuenta,'')

  -- 2 Existencia Nivel Acumu
  IF OBJECT_ID('tempdb..#tmp_CUP_AcumU') IS NOT NULL 
    DROP TABLE #tmp_CUP_AcumU;

  CREATE TABLE #tmp_CUP_AcumU
  (
    Empresa             CHAR(5) NOT NULL,
    Sucursal            INT NOT NULL,
    Almacen             CHAR(10) NOT NULL,
    Articulo            CHAR(20) NOT NULL,
    SubCuenta           VARCHAR(20) NOT NULL,
    Existencia          FLOAT NOT NULL,
    PRIMARY KEY (
                  Empresa,
                  Sucursal,
                  Almacen,
                  ARticulo,
                  Subcuenta
                )
  )

  INSERT INTO #tmp_CUP_AcumU
  (
    Empresa,
    Sucursal,
    Almacen,
    ARticulo,
    Subcuenta,
    Existencia
  )
  SELECT 
    AcumU.Empresa,
    AcumU.Sucursal,
    Almacen = AcumU.Grupo,
    Articulo = AcumU.Cuenta,
    Subcuenta = ISNULL(AcumU.SubCuenta,''),
    Existencia = SUM(ISNULL(AcumU.CargosU,0) - ISNULL(AcumU.AbonosU,0))
  FROM 
    AcumU  
  WHERE 
    AcumU.Rama = 'INV'
  AND AcumU.Periodo BETWEEN 1 AND 12
  AND AcumU.Empresa = ISNULL( @Empresa, AcumU.Empresa )
  AND AcumU.Sucursal = ISNULL( @Sucursal, AcumU.Sucursal )
  AND AcumU.Grupo = ISNULL( @Almacen, AcumU.Grupo )
  AND AcumU.Cuenta = ISNULL( @Articulo, AcumU.Cuenta )
  AND AcumU.SubCuenta = ISNULL( @SubCuenta, AcumU.SubCuenta )
  GROUP BY 
    AcumU.Empresa,
    AcumU.Sucursal,
    AcumU.Grupo,
    AcumU.Cuenta,
    ISNULL(AcumU.SubCuenta,'')

  --3  Existencia Nivel SaldoU
  IF OBJECT_ID('tempdb..#tmp_CUP_SaldoU') IS NOT NULL 
    DROP TABLE #tmp_CUP_SaldoU;

  CREATE TABLE #tmp_CUP_SaldoU
  (
    Empresa             CHAR(5) NOT NULL,
    Sucursal            INT NOT NULL,
    Almacen             CHAR(10) NOT NULL,
    Articulo            CHAR(20) NOT NULL,
    SubCuenta           VARCHAR(20) NOT NULL,
    Existencia          FLOAT NOT NULL,
    CantidadReservada   FLOAT NOT NULL,
    PRIMARY KEY (
                  Empresa,
                  Sucursal,
                  Almacen,
                  ARticulo,
                  Subcuenta
                )
  )

  INSERT INTO #tmp_CUP_SaldoU
  (
    Empresa,
    Sucursal,
    Almacen,
    ARticulo,
    Subcuenta,
    Existencia,
    CantidadReservada
  )
  SELECT 
    SaldoU.Empresa,
    SaldoU.Sucursal,
    Almacen = SaldoU.Grupo,
    Articulo = SaldoU.Cuenta,
    Subcuenta = ISNULL(SaldoU.SubCuenta,''),
    Existencia = SUM(
                      CASE ISNULL(SaldoU.Rama,'') 
                        WHEN 'INV' 
                          THEN ISNULL(SaldoU.SaldoU,0)
                        ELSE 
                          0
                       END
                    ),
    CantidadReservada = SUM
                       (
                        CASE ISNULL(SaldoU.Rama,'') 
                          WHEN 'RESV' 
                            THEN ISNULL(SaldoU.SaldoU,0)
                          ELSE 
                            0
                          END
                       )
  FROM 
    SaldoU  
  WHERE 
    SaldoU.Rama IN ('INV','RESV')
  AND SaldoU.Empresa = ISNULL( @Empresa, SaldoU.Empresa )
  AND SaldoU.Sucursal = ISNULL( @Sucursal, SaldoU.Sucursal )
  AND SaldoU.Grupo = ISNULL( @Almacen, SaldoU.Grupo )
  AND SaldoU.Cuenta = ISNULL( @Articulo, SaldoU.Cuenta )
  AND SaldoU.SubCuenta = ISNULL( @SubCuenta, SaldoU.SubCuenta )
  GROUP BY 
    SaldoU.Empresa,
    SaldoU.Sucursal,
    SaldoU.Grupo,
    SaldoU.Cuenta,
    ISNULL(SaldoU.SubCuenta,'')

  -- 4) Enfrentamos las Existencias de AuxiliarU, AcumU, y SaldoU
  SELECT 
    auxU.Empresa,
    auxU.Sucursal,
    auxU.Almacen,
    auxU.Articulo,
    auxU.SubCuenta,
    Auxu_Existencia = auxU.Existencia,
    calc.AuxU_ExistenciaReal,
    AcumU_Existencia = acumU.Existencia,
    calc.AcumU_ExistenciaReal,
    SaldoU_Existencia = saldoU.Existencia,
    calc.SaldoU_ExistenciaReal,
    CantidadReservada = ISNULL(saldoU.CantidadReservada,0),
    CantidadReservadaReal = ISNULL(calc.CantidadReservadaReal,0)
  FROM 
    #tmp_CUP_AuxiliarU auxU 
  JOIN #tmp_CUP_AcumU acumU ON acumU.Empresa = auxU.Empresa
                              AND acumU.Sucursal = auxU.Sucursal
                              AND acumU.Almacen = auxu.Almacen
                              AND acumU.Articulo = auxU.Articulo
                              AND acumU.SubCuenta = auxU.SubCuenta
  JOIN #tmp_CUP_SaldoU saldoU ON saldoU.Empresa = auxU.Empresa
                              AND saldoU.Sucursal = auxU.Sucursal
                              AND saldoU.Almacen = auxu.Almacen
                              AND saldoU.Articulo = auxU.Articulo
                              AND saldoU.SubCuenta = auxU.SubCuenta
  -- CALC 
  CROSS APPLY
  (
    SELECT 
      AuxU_ExistenciaReal = ROUND (
                              CONVERT ( 
                                DECIMAL(18,5),
                                ISNULL(auxU.Existencia,0)
                              ),
                              4,
                              1
                            ),
      AcumU_ExistenciaReal = ROUND (
                              CONVERT ( 
                                DECIMAL(18,5),
                                ISNULL(AcumU.Existencia,0)
                              ),
                              4,
                              1
                            ),
      SaldoU_ExistenciaReal = ROUND (
                                CONVERT ( 
                                  DECIMAL(18,5),
                                  ISNULL(SaldoU.Existencia,0)
                                ),
                                4,
                                1
                              ),
      CantidadReservadaReal = ROUND
                              (
                                CONVERT ( 
                                  DECIMAL(18,5),
                                  ISNULL(SaldoU.Existencia,0)
                                ),
                                4,
                                1
                              )
  ) calc
  WHERE 
    ISNULL(auxU.Existencia,0) <> 0
  OR ISNULL(acumU.Existencia,0) <> 0
  OR ISNULL(saldoU.Existencia,0) <> 0
END