/********************* CONFIGURAR SQL SERVER **********************************/

SET DATEFIRST 7
SET ANSI_NULLS ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER ON
GO


/**********************  SI EXISTE EL PROCEDIMIENTO SE TIRA ****************************/
IF EXISTS (SELECT * 
		   FROM SYSOBJECTS 
		   WHERE ID = OBJECT_ID('dbo.CUP_SPI_SaldosMenoresSL') AND 
				 TYPE = 'P') BEGIN
				 
	 DROP PROCEDURE dbo.CUP_SPI_SaldosMenoresSL
		  
END
	
GO

/*
:Example
 EXEC CUP_SPI_SaldosMenoresSL 
          @Usuario = 'ESIERRA', -- No puede ir null,
          @Empresa =  'CML', --  Si se manda NULL Regresa TODAS las empresas. 
          @Sucursal  = NULL, -- Si esta NULL regresa TODAS las sucursales.
          @Almacen  = NULL, -- Si esta NULL regresa TODOS los almacenes
          @ToleranciaKGS = 1, --  Regresa solo donde la existencia este bajo la tolerancia.
          @EnSilencio  = 0
*/

CREATE PROCEDURE CUP_SPI_SaldosMenoresSL
  @Usuario CHAR(10),
  @Empresa CHAR(5) = 'CML',
  @Sucursal INT = NULL,
  @Almacen CHAR(10) = NULL,
  @ToleranciaKGS DECIMAL(18,4) = 1,
  @EnSilencio BIT = 0
AS BEGIN TRY

  BEGIN TRANSACTION SaldosMenoresSL

  DELETE CUP_EliminarSaldosMenoresSL WHERE Usuario = @Usuario

  INSERT INTO CUP_EliminarSaldosMenoresSL
  (
    Usuario,
    Empresa,
    Sucursal,
    Almacen,
    Articulo,
    Subcuenta,
    SerieLote,
    Propiedades,
    Existencia,
    ExistenciaReal,
    ExistenciaRemanente
  )
  SELECT
    @Usuario,
    sl.Empresa,
    sl.Sucursal,
    sl.Almacen,
    sl.Articulo,
    sl.SubCuenta,
    sl.SerieLote,
    sl.Propiedades,
    calc.Existencia,
    calc.ExistenciaReal,
    ExistenciaRemanente = calc.Existencia  - calc.ExistenciaReal
  FROM
    SerieLote sl
  JOIN art a  ON sl.Articulo = a.Articulo
  -- CALC 
  CROSS APPLY( SELECT 
                  Existencia =      CONVERT( DECIMAL(30,16), ISNULL(sl.Existencia,0)),
                  ExistenciaReal =  ROUND(CONVERT( DECIMAL(18,5), ISNULL(sl.Existencia,0)),4,1)
             ) calc
  WHERE
    sl.Empresa = ISNULL(@Empresa,sl.Empresa)
  AND sl.Sucursal = ISNULL(@Sucursal,sl.Sucursal)
  AND sl.Almacen = ISNULL(@Almacen,sl.Almacen)
  AND ISNULL(sl.Existencia,0) <> 0 
  AND ISNULL(calc.Existencia,0) < ISNULL(@ToleranciaKGS,0)

  IF ISNULL(@EnSilencio,0) = 0
  BEGIN
    SELECT 
      esm.ID,
      esm.Empresa,
      esm.Sucursal,
      esm.Almacen,
      a.Categoria,
      a.Grupo,
      esm.Articulo,
      esm.SubCuenta,
      esm.SerieLote,
      esm.Propiedades,
      esm.Existencia,
      esm.ExistenciaReal,
      esm.ExistenciaRemanente
    FROM 
      CUP_EliminarSaldosMenoresSL esm
    JOIN Art a ON esm.Articulo = a.Articulo
    WHERE 
      esm.Usuario = @Usuario
    ORDER BY 
      esm.Existencia
  END
  
  IF XACT_STATE() = 1 
    COMMIT TRANSACTION SaldosMenoresSL

  
	RETURN
END TRY 
BEGIN CATCH

  IF (XACT_STATE()) IN (-1,1)
  BEGIN
    ROLLBACK TRANSACTION SaldosMenoresSL;
    PRINT 'The transaction is in an uncommittable state.' +
          ' Rolling back transaction.'
            
  END;
  
  SELECT Error =  ERROR_MESSAGE()   

END CATCH;
