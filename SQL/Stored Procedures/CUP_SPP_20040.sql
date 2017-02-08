SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS
(
	SELECT
		*
	FROM
		SYSOBJECTS
	WHERE ID = OBJECT_ID('dbo.CUP_SPP_20040')
				AND TYPE = 'P'
)
BEGIN
	DROP PROCEDURE
		dbo.CUP_SPP_20040;
END;

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-07

  Description: Extiende la validacion
  sobre el error 20040 ( "No existe disponible esa opcion" ).
  En otras palabras permite decidir situaciones adicionales
  dond debe o NO debe marcar este error, segun la operacion
  en sistema.
============================================= */

CREATE PROCEDURE dbo.CUP_SPP_20040
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
    @Concepto VARCHAR(50)

  IF @Ok = 20040
  BEGIN
    
    IF @Modulo = 'INV'
    BEGIN

      SELECT 
        @Concepto = i.Concepto
      FROM 
        Inv i 
      WHERE 
        i.ID = @ID
      
      -- Evita marcar el error en la eliminacion
      -- de saldos menores
      IF @Movtipo = 'INV.A'
      AND @Usuario = 'PRODAUT'
      AND @Accion IN ('VERIFICAR','GENERAR','AFECTAR')
      AND @Estatus = 'SINAFECTAR'
      AND @Concepto = 'Ajuste por saldos menores'
      BEGIN
        SELECT @OK = NULL, @OkRef = NULL
      END
    END

    
  END
END;