SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS
(
	SELECT
		*
	FROM
		SYSOBJECTS
	WHERE ID = OBJECT_ID('dbo.CUP_SPP_OpcionValidar')
				AND TYPE = 'P'
)
BEGIN
	DROP PROCEDURE
		dbo.CUP_SPP_OpcionValidar;
END;

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-07

  Description: Procedimiento encargado de extender las Validaciones del 
  spOpcionValidar con la finalidad de poder tener mas alternativas a la hora de decidir
  cuando SI y cuando NO se debe aplicar estos criterio. Ej, en la eliminacion de saldos
  menores no es necesario aplicar la validacion.

============================================= */

CREATE PROCEDURE dbo.CUP_SPP_OpcionValidar
  @Modulo CHAR(5),
  @Id     INT,
  @Accion  CHAR(20),
  @Base CHAR(20),
  @GenerarMov CHAR(20),
  @Mov CHAR(20),
  @MovTipo CHAR(20),
  @Articulo CHAR(20),
  @Subcuenta VARCHAR(20),
  @CfgOpcionBloquearDescontinuado BIT,
  @CfgOpcionPermitirDescontinuado BIT,
  @Ok INT OUTPUT,
  @OkRef VARCHAR(255) OUTPUT 
AS BEGIN
  DECLARE 
    @CUP_Origen INT

  IF @Ok = 20046
  BEGIN
    
    IF @Modulo = 'INV'
    BEGIN

      SELECT 
        @CUP_Origen = i.CUP_Origen
      FROM 
        Inv i 
      WHERE 
        i.ID = @ID
      
      -- Evita marcar el error en la eliminacion
      -- de saldos menores
      IF @Movtipo = 'INV.A'
      AND @CUP_Origen = 13
      BEGIN
        SELECT @OK = NULL, @OkRef = NULL
      END
    END

    
  END
END;