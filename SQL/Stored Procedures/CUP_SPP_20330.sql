SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS
(
	SELECT
		*
	FROM
		SYSOBJECTS
	WHERE ID = OBJECT_ID('dbo.CUP_SPP_20330')
				AND TYPE = 'P'
)
BEGIN
	DROP PROCEDURE
		dbo.CUP_SPP_20330;
END;

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-09

  Description: Extiende la validacion
  sobre el error 20330 ( "No corresponde la cantidad con los números de Serie/Lote" ).
  En otras palabras permite decidir situaciones adicionales
  dond debe o NO debe marcar este error, segun la operacion
  en sistema.
============================================= */

CREATE PROCEDURE dbo.CUP_SPP_20330
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
    @CUP_Origen INT,
    @EscenarioEliminarSaldosInv INT,
    @CantidadDetalle FLOAT,
    @CantidadSL FLOAT

  IF @Ok = 20330
  BEGIN
    
    IF @Modulo = 'INV'
    BEGIN

      SELECT 
        @CUP_Origen = i.CUP_Origen,
        @EscenarioEliminarSaldosInv = ag.Escenario
      FROM 
        Inv i
      LEFT JOIN CUP_EliminarSaldosMenoresInv_AjustesGenerados ag ON 13 = i.CUP_Origen
                                                               AND ag.Modulo = 'INV'
                                                               AND ag.ModulOID = i.ID 
      WHERE 
        i.ID = @ID

      SELECT 
        @CantidadDetalle = d.Cantidad
      FROM 
        InvD d
      WHERE 
        d.id = @ID
      AND d.RenglonID = @RenglonID
      AND d.Articulo = @Articulo
      AND ISNULL(d.SubCuenta,'') = ISNULL(@Subcuenta,'')

      SELECT 
        @CantidadSL = SUM(slm.Cantidad)
      FROM 
        SerieloteMov slm
      WHERE 
        slm.Modulo = @Modulo
      AND slm.ID = @ID 
      AND slm.RenglonID = @RenglonID 
      AND slm.Articulo = @Articulo
      AND ISNULL(slm.SubCuenta,'') = ISNULL(@Subcuenta,'')

      -- Evita marcar el error en la eliminacion
      -- de saldos menores
      IF @Movtipo = 'INV.A'
      AND @CUP_Origen = 13
      AND @EscenarioEliminarSaldosInv IN (
                                            1, -- Escenario Eliminar SaldosU Menores Seguro.
                                            2  -- Escenario Eliminar Saldos Serie Lote Menores Seguro.
                                          )
      BEGIN
        SELECT @OK = NULL, @OkRef = NULL
      END
    END

  END
END;