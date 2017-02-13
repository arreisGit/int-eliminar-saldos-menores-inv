SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS (SELECT * 
		   FROM SYSOBJECTS 
		   WHERE ID = OBJECT_ID('dbo.CUP_SPQ_RevisionExistenciasRealesSL') AND 
				 TYPE = 'P')
BEGIN
  DROP PROCEDURE dbo.CUP_SPQ_RevisionExistenciasRealesSL
END	

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-07

  Description: Obtiene las existencias SerieLote 
  registradas en Intelisis, incluida la "real" 
  que es aquella truncada a 4 decimales.
 
  Example: EXEC CUP_SPQ_RevisionExistenciasRealesSL 
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


CREATE PROCEDURE dbo.CUP_SPQ_RevisionExistenciasRealesSL
  @Empresa CHAR(5) = NULL,
  @Sucursal INT = NULL,
  @Almacen CHAR(10) = NULL,
  @Articulo CHAR(20) = NULL,
  @Subcuenta VARCHAR(20) = NULL
AS BEGIN 
 
  SET NOCOUNT ON;

  SELECT 
    sl.Empresa,
    sl.Sucursal,
    sl.Almacen,
    sl.Articulo,
    sl.SubCuenta,
    sl.SerieLote,
    sl.Propiedades,
    Existencia = ISNULL(sl.Existencia,0),
    ExistenciaReal = ISNULL(calc.ExistenciaReal,0)
  FROM 
    SerieLote sl
  -- CALC 
  CROSS APPLY
  (
    SELECT 
      ExistenciaReal = ROUND (
                              CONVERT ( 
                                DECIMAL(18,5),
                                ISNULL(sl.Existencia,0)
                              ),
                              4,
                              1
                            )
  ) calc
  WHERE 
    sl.Existencia <> 0
  AND sl.Empresa = ISNULL( @Empresa, sl.Empresa )
  AND sl.Sucursal = ISNULL( @Sucursal, sl.Sucursal )
  AND sl.Almacen = ISNULL( @Almacen, sl.Almacen )
  AND sl.Articulo = ISNULL( @Articulo, sl.Articulo )
  AND ISNULL(sl.SubCuenta,'')  = ISNULL( @SubCuenta, sl.SubCuenta )
END