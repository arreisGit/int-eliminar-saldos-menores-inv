SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS
(
	SELECT
		*
	FROM
		SYSOBJECTS
	WHERE ID = OBJECT_ID('dbo.CUP_SPP_20320')
				AND TYPE = 'P'
)
BEGIN
	DROP PROCEDURE
		dbo.CUP_SPP_20320;
END;

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-09

  Description: Extiende la validacion
  sobre el error 20320 ( "Falta indicar los números de Serie/Lote" ).
  En otras palabras permite decidir situaciones adicionales
  dond debe o NO debe marcar este error, segun la operacion
  en sistema.
============================================= */

CREATE PROCEDURE dbo.CUP_SPP_20320
  @Empresa CHAR(10),
  @Usuario CHAR(10),
  @Accion  CHAR(20),
  @Estatus CHAR(15),
  @Modulo  CHAR(5),
  @ID      INT,
  @Mov     CHAR(20),
  @MovTipo CHAR(20),
  @Articulo CHAR(20),
  @Subcuenta VARCHAR(20),
  @Renglon FLOAT,
  @RenglonSub INT,
  @RenglonID INT,
  @RenglonTipo CHAR(1),
  @Ok INT  OUTPUT,
  @OkRef VARCHAR(255) OUTPUT
AS BEGIN
  DECLARE 
    @Concepto VARCHAR(50),
    @CantidadDetalle FLOAT

  IF @Ok = 20320
  BEGIN
      
    IF @Modulo = 'VTAS'
    BEGIN
      
      -- Omar chavez: 2014/09/29: Para dejar pasar pedido que no verifique la serielote
      -- ( Extraido del spInvVerificar )
      IF @Mov = 'Pedido'
      BEGIN
        SELECT
          @Ok = NULL,
          @OkRef = NULl
      END

    END
     
    IF @Modulo = 'INV'
    BEGIN

      SELECT 
        @Concepto = i.Concepto,
        @CantidadDetalle = d.Cantidad
      FROM 
        Inv i 
      JOIN InvD d On d.ID = i.ID
      WHERE 
        i.ID = @ID 
      AND d.RenglonID = @RenglonID
      AND d.Articulo = @Articulo
      AND ISNULL(d.SubCuenta,'') = ISNULL(@Subcuenta,'')
          
      -- Evita marcar el error en la eliminacion
      -- de saldos menores
      IF @Movtipo = 'INV.A'
      AND @Usuario = 'PRODAUT'
      AND @Accion IN ('VERIFICAR','GENERAR','AFECTAR')
      AND @Estatus = 'SINAFECTAR'
      AND @Concepto = 'Ajuste por saldos menores'
      AND ABS(ISNULL(@CantidadDetalle,0)) <= .0001
      AND NOT EXISTS
      (
        SELECT 
          sl.SerieLote 
        FROM 
          Inv i 
        JOIN InvD d ON d.ID = i.ID
        JOIN SerieLote sl ON sl.Empresa = i.Empresa
                        AND sl.Sucursal = i.Sucursal
                        AND sl.Almacen = i.Almacen
                        ANd sl.Articulo = d.Articulo
                        AND ISNULL(sl.SubCuenta,'') = ISNULL(d.SubCuenta,'')
        WHERE 
          i.ID = @ID 
      AND d.RenglonID = @RenglonID
      AND d.Articulo = @Articulo
      AND ISNULL(d.SubCuenta,'') = ISNULL(@Subcuenta,'')
      AND ISNULL(sl.Existencia,0) <> 0
      )
      BEGIN
        SELECT @OK = NULL, @OkRef = NULL
      END
    END

    
  END
END;