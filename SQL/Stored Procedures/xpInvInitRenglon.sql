USE [Cuprum];
GO

/****** Object:  StoredProcedure [dbo].[xpInvInitRenglon]    Script Date: 07/02/2017 02:13:18 p.m. ******/

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER OFF;
GO

ALTER PROCEDURE [dbo].[xpInvInitRenglon]
	@Empresa                   CHAR(5),
	@CfgDecimalesCantidades    INT,
	@CfgMultiUnidades          BIT,
	@CfgMultiUnidadesNivel     CHAR(20),
	@CfgCompraFactorDinamico   BIT,
	@CfgInvFactorDinamico      BIT,
	@CfgProdFactorDinamico     BIT,
	@CfgVentaFactorDinamico    BIT,
	@CfgBloquearNotasNegativas BIT,
	@AlVerificar               BIT,
	@Matando                   BIT,
	@Accion                    CHAR(20),
	@Base                      CHAR(20),
	@Modulo                    CHAR(5),
	@ID                        INT,
	@Renglon                   FLOAT,
	@RenglonSub                INT,
	@Estatus                   CHAR(15),
	@EstatusNuevo              CHAR(15),
	@MovTipo                   CHAR(20),
	@FacturarVtasMostrador     BIT,
	@EsTransferencia           BIT,
	@AfectarConsignacion       BIT,
	@ExplotandoSubCuenta       BIT,
	@AlmacenTipo               CHAR(15),
	@AlmacenDestinoTipo        CHAR(15),
	@Articulo                  CHAR(20),
	@MovUnidad                 VARCHAR(50),
	@ArtUnidad                 VARCHAR(50),
	@ArtTipo                   VARCHAR(20),
	@RenglonTipo               CHAR(1),
	@AplicaMovTipo             VARCHAR(20),
	@CantidadOriginal          FLOAT,
	@CantidadInventario        FLOAT,
	@CantidadPendiente         FLOAT,
	@CantidadA                 FLOAT,
	@DetalleTipo               VARCHAR(20),
	@Cantidad                  FLOAT OUTPUT,
	@CantidadCalcularImporte   FLOAT OUTPUT,
	@CantidadReservada         FLOAT OUTPUT,
	@CantidadOrdenada          FLOAT OUTPUT,
	@EsEntrada                 BIT OUTPUT,
	@EsSalida                  BIT OUTPUT,
	@SubCuenta                 VARCHAR(50) OUTPUT,
	@AfectarPiezas             BIT OUTPUT,
	@AfectarCostos             BIT OUTPUT,
	@AfectarUnidades           BIT OUTPUT,
	@Factor                    FLOAT OUTPUT,
	@Ok                        INT OUTPUT,
	@OkRef                     VARCHAR(255) OUTPUT
AS BEGIN

	DECLARE
		@CantidadNegativa BIT;

	/* MK: Corrige el error del sistema al no dejar afectar movimiento con clave de afectacion INV.CM donde el campo DetalleTipo <> 'SALIDA' y la Cantidad < 0.0. */
	IF @Cantidad < 0
	BEGIN
		SELECT
			@CantidadNegativa = 1
	END;

	IF(@CantidadNegativa = 1
	OR (    
          @EsEntrada = 1
			AND @EsSalida = 0)
      )
	AND @MovTipo = 'INV.CM'
	AND UPPER(@DetalleTipo) <> 'SALIDA'
	AND @ArtTipo <> 'SERVICIO'
	AND @FacturarVtasMostrador = 0
	AND @Accion <> 'CANCELAR'
	BEGIN
		IF @Ok = 20010
		BEGIN
			SELECT
				@Ok = NULL,
				@OkRef = NULL
		END
	END;
	RETURN;
END;