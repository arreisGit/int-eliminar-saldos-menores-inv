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
  sobre el error 20320 ( "Falta indicar los n�meros de Serie/Lote" ).
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
    @CUP_Origen INT,
    @EscenarioEliminarSaldosInv INT,
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
        @CUP_Origen = i.CUP_Origen,
        @CantidadDetalle = d.Cantidad,
        @EscenarioEliminarSaldosInv = ag.Escenario
      FROM 
        Inv i 
      JOIN InvD d On d.ID = i.ID
      LEFT JOIN CUP_EliminarSaldosMenoresInv_AjustesGenerados ag ON 13 = i.CUP_Origen
                                                                AND ag.Modulo = 'INV'
                                                                AND ag.ModuloID = i.ID 
      WHERE 
        i.ID = @ID 
      AND d.RenglonID = @RenglonID
      AND d.Articulo = @Articulo
      AND ISNULL(d.SubCuenta,'') = ISNULL(@Subcuenta,'')
          

      -- Evita marcar el error en la eliminacion
      -- de saldos menores
      IF @Movtipo = 'INV.A'
      AND @CUP_Origen = 13
      AND @EscenarioEliminarSaldosInv IN (
                                            1, -- Escenario Eliminar SaldosU Menores Seguro.
                                            2  -- Escenario Eliminar Saldos Serie Lote Menores Seguro.
                                          )
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