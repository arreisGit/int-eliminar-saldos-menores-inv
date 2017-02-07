USE Cuprum;
GO

SET ANSI_NULLS, QUOTED_IDENTIFIER OFF;
GO

ALTER PROCEDURE dbo.spInvInitRenglon
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
	@ID                        INT, -- Este campo no pasa cuando Matando = 1
	@Renglon                   FLOAT, -- Este campo no pasa cuando Matando = 1		
	@RenglonSub                INT, -- Este campo no pasa cuando Matando = 1	
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
	@OkRef                     VARCHAR(255) OUTPUT,
	@Seccion                   INT          = NULL
----WITH ENCRYPTION
AS BEGIN

	DECLARE
		@CantidadNegativa   BIT,
		@Decimales          INT,
		@EsPrestamoGarantia BIT,
		@EsFacturaPendiente BIT;

	SELECT
		@Decimales = @CfgDecimalesCantidades,
		@CantidadNegativa = 0;
	-- Arreglar Subcuenta en los Registros que no lleva "Subcuenta"

	IF @ArtTipo = 'ESTRUCTURA'
	BEGIN
		SELECT
			@Ok = 20680
	END;

	IF @MovTipo = 'INV.CP'
			AND @AlVerificar = 0
	BEGIN
		SELECT
			@MovTipo = 'INV.A'
	END;

	SELECT
		@Cantidad = /*ROUND(*/ @CantidadOriginal, /*, 10)*/
		@EsEntrada = 0,
		@EsSalida = 0,
		@AfectarUnidades = 0,
		@EsPrestamoGarantia = 0,
		@EsFacturaPendiente = 0;

	IF @Cantidad < 0
	BEGIN
		SELECT
			@CantidadNegativa = 1
	END;

	-- Limpiar valores que no corresponden
	IF @Modulo NOT IN('VTAS', 'INV', 'PROD')
	BEGIN
		SELECT
			@CantidadReservada = 0.0,
			@CantidadOrdenada = 0.0
	END;

	IF @MovTipo = 'INV.TMA'
	BEGIN
		IF @Seccion IS NULL
		BEGIN
			SELECT
				@EsSalida = 1;
		END
		ELSE
		BEGIN
			SELECT
				@EsEntrada = 1;
		END;
	END;

	-- Entradas
	IF @MovTipo IN('VTAS.D', 'VTAS.DR', 'VTAS.DFC', 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.IG', 'COMS.CC', 'INV.E', 'INV.EP', 'INV.EI', 'INV.TIS', 'PROD.E')
	OR (    @MovTipo = 'INV.A'
			AND @Cantidad > 0.0)
	OR (    @MovTipo IN('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX')
      AND @Cantidad < 0.0)
	BEGIN
		SELECT
			@EsEntrada = 1;
	END
	ELSE
	BEGIN
		-- Salidas
		IF @MovTipo IN('VTAS.R', 'VTAS.SG', 'COMS.D', 'COMS.DG', 'COMS.DC', 'INV.S', 'INV.SI', 'INV.CP')
		OR (    @MovTipo = 'INV.A'
				AND @Cantidad < 0.0)
		OR (    @MovTipo IN
				('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG'
				/*, 'VTAS.FX'*/)
				AND @Cantidad > 0.0)
		BEGIN
			SELECT
				@EsSalida = 1;
		END
		ELSE
		BEGIN
			IF @MovTipo = 'INV.CM'
			BEGIN
				IF UPPER(@DetalleTipo) NOT IN('SALIDA', 'DEVOLUCION', 'MERMA', 'DESPERDICIO')
				BEGIN
					SELECT
						@Ok = 25390
				END;
				IF UPPER(@DetalleTipo) = 'SALIDA'
				BEGIN
					SELECT
						@EsSalida = 1;
				END
				ELSE
				BEGIN
					SELECT
						@EsEntrada = 1;
				END;
			END;
		END;
	END;

	IF @MovTipo IN('VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX')
	AND (     @EstatusNuevo = 'PENDIENTE'
				OR (    @Estatus = 'PENDIENTE'
						AND @Accion = 'CANCELAR'))
	BEGIN
		SELECT
			@EsSalida = 0,
			@EsFacturaPendiente = 1
	END;

	IF @Accion = 'CANCELAR'
	BEGIN
		IF @EsEntrada = 1
		BEGIN
			SELECT
				@EsEntrada = 0,
				@EsSalida = 1;
		END
		ELSE
		BEGIN
			IF @EsSalida = 1
			BEGIN
				SELECT
					@EsEntrada = 1,
					@EsSalida = 0
			END;
		END;
	END;

	IF @MovTipo IN('INV.P', 'INV.R')
	AND @AlmacenTipo <> @AlmacenDestinoTipo
	AND @AlmacenDestinoTipo IS NOT NULL
	AND (  @AlmacenTipo IN('NORMAL', 'PROCESO', 'GARANTIAS')
	     OR @AlmacenDestinoTipo IN('NORMAL', 'PROCESO', 'GARANTIAS'))
	BEGIN
		SELECT
			@EsPrestamoGarantia = 1;
		IF @AlmacenDestinoTipo = 'GARANTIAS'
		BEGIN
			SELECT
				@EsSalida = 1
		END;
	END;

	IF @Accion = 'CANCELAR'
			AND @Base = 'TODO'
	BEGIN
		IF @Estatus = 'PENDIENTE'
		BEGIN
			SELECT
				@Cantidad = @CantidadPendiente + @CantidadReservada
		END;
	END;
	ELSE
	BEGIN
		-- Si se esta explotando en renglon conservar la cantidad
		IF @ExplotandoSubCuenta = 0
				AND @MovTipo <> 'INV.IF'
		BEGIN
			IF @Base = 'PENDIENTE'
			BEGIN
				SELECT
					@Cantidad = @CantidadPendiente;
				IF @Accion NOT IN('RESERVAR', 'DESRESERVAR', 'RESERVARPARCIAL', 'ASIGNAR', 'DESASIGNAR')
				BEGIN
					SELECT
						@Cantidad = @Cantidad + @CantidadReservada
				END;
			END;
			ELSE
			BEGIN
				IF @Base = 'SELECCION'
				BEGIN
					SELECT
						@Cantidad = @CantidadA;
				END
				ELSE
				BEGIN
					IF @Base = 'RESERVADO'
					BEGIN
						SELECT
							@Cantidad = @CantidadReservada;
					END
					ELSE
					BEGIN
						IF @Base = 'ORDENADO'
						BEGIN
							SELECT
								@Cantidad = @CantidadOrdenada
						END;
					END;
				END;
			END;
		END;
	END;

	--IF @CfgDecimalesCantidades<=10 SELECT @Cantidad = ROUND(@Cantidad, 10)

	-- Kike Sierra: Modificacion para la advertencia de cantidad negativa en mermas: Codigo Original:
	--IF @MovTipo = 'INV.CM' AND UPPER(@DetalleTipo) <> 'SALIDA' AND @Cantidad >= 0.0 
	IF @MovTipo = 'INV.CM'
			AND UPPER(@DetalleTipo) NOT IN('SALIDA', 'MERMA')
	AND @Cantidad >= 0.0
	BEGIN
		SELECT
			@Ok = 25360;
		RETURN;
	END;

	IF(@MovTipo IN('INV.A', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX')
	AND @Cantidad < 0.0)
	OR (@MovTipo = 'INV.CM'
			AND UPPER(@DetalleTipo) <> 'SALIDA')
	BEGIN
		SELECT
			@Cantidad = @Cantidad * -1
	END;

  /*IF @ArtTipo = 'DOBLE UNIDAD' AND UPPER(@SubCuenta) = 'PIEZAS'
  SELECT @AfectarPiezas = 1
  ELSE*/

	SELECT
		@AfectarPiezas = 0;

	IF(    @EsEntrada = 1
			OR @EsSalida = 1
			OR @MovTipo IN('COMS.B', 'COMS.CA', 'COMS.GX', 'INV.TC'))
	AND @AfectarPiezas = 0
	AND @ArtTipo NOT IN('JUEGO', 'SERVICIO')
	AND @AfectarConsignacion = 0
	AND @MovTipo NOT IN('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'COMS.OG', 'COMS.IG', 'COMS.DG')
	BEGIN
		SELECT
			@AfectarCostos = 1;
	END
	ELSE
	BEGIN
		SELECT
			@AfectarCostos = 0;
	END;

	IF(    @EsEntrada = 1
			OR @EsSalida = 1
			OR @EsTransferencia = 1
			OR @Accion IN('RESERVARPARCIAL', 'RESERVAR', 'DESRESERVAR')
	OR (    @Accion = 'CANCELAR'
			AND @CantidadReservada > 0))
	AND @ArtTipo NOT IN('JUEGO', 'SERVICIO')
	BEGIN
		SELECT
			@AfectarUnidades = 1
	END;

	IF @AfectarUnidades = 0
	AND @Accion IN('RESERVAR', 'DESRESERVAR')
	BEGIN
		SELECT
			@Cantidad = 0.0
	END;

	IF @EsPrestamoGarantia = 0
	AND (  @AlmacenTipo = 'GARANTIAS'
			OR @AlmacenDestinoTipo = 'GARANTIAS')
	BEGIN
		SELECT
			@AfectarCostos = 0
	END;

	IF @AplicaMovTipo = 'VTAS.R'
			AND @MovTipo IN('VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX')
	AND @EsFacturaPendiente = 0
	BEGIN
		SELECT
			@AfectarUnidades = 0,
			@AfectarCostos = 0
	END;

	IF @AplicaMovTipo = 'VTAS.R'
			AND @MovTipo = 'VTAS.R'
	BEGIN
		SELECT
			@AfectarUnidades = 0
	END;

	IF @MovTipo = 'VTAS.FM'
			AND @Estatus = 'PROCESAR'
			AND @Accion <> 'CANCELAR'
	BEGIN
		SELECT
			@AfectarCostos = 1
	END;

	IF @AfectarPiezas = 1
			OR @ArtTipo IN('JUEGO', 'SERVICIO')
	BEGIN
		SELECT
			@AfectarCostos = 0
	END;

	IF @MovTipo IN('INV.CM', 'PROD.E')
	AND UPPER(@DetalleTipo) IN('MERMA', 'DESPERDICIO')
	BEGIN
		SELECT
			@AfectarCostos = 0
	END;

	-- Calcular el Factor
	IF @Estatus IN('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')
	AND @Matando = 0
	AND (@CfgMultiUnidades = 1
				OR @ArtTipo = 'PARTIDA')
	AND @Ok IS NULL
	BEGIN
		EXEC xpUnidadFactorMov
			@Empresa,
			@CfgMultiUnidades,
			@CfgMultiUnidadesNivel,
			@CfgCompraFactorDinamico,
			@CfgInvFactorDinamico,
			@CfgProdFactorDinamico,
			@CfgVentaFactorDinamico,
			@Accion,
			@Base,
			@Modulo,
			@ID,
			@Renglon,
			@RenglonSub,
			@Estatus,
			@EstatusNuevo,
			@MovTipo,
			@EsTransferencia,
			@AfectarConsignacion,
			@AlmacenTipo,
			@AlmacenDestinoTipo,
			@Articulo,
			@SubCuenta,
			@MovUnidad,
			@ArtUnidad,
			@ArtTipo,
			@RenglonTipo,
			@AplicaMovTipo,
			@Cantidad,
			@CantidadInventario,
			@Factor OUTPUT,
			@Decimales OUTPUT,
			@Ok OUTPUT,
			@OkRef OUTPUT;

		PRINT('DECIMALES : '+ISNULL(CAST(@Decimales AS VARCHAR), 'NULL')+' '+'@Cantidad: '+ISNULL(CAST(@Cantidad AS VARCHAR), 'NULL')+' '+'@CantidadRedondeada '+ISNULL(CAST(ROUND(@Cantidad, @Decimales) AS VARCHAR), 'NULL')+' ');
		IF @AlVerificar = 1
				AND @Decimales <= 10
				AND @Modulo <> 'PROD'
		BEGIN
			IF ROUND(@Cantidad, 10) <> ROUND(@Cantidad, @Decimales)
			BEGIN
				SELECT
					@Ok = 20550;
			END
		END;

	END;

	IF @CantidadNegativa = 1
	AND @Cantidad > 0.0
	AND @ArtTipo = 'SERVICIO'
	AND @MovTipo NOT IN('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM')
	BEGIN
		SELECT
			@CantidadCalcularImporte = -@Cantidad;
	END
	ELSE
	BEGIN
		SELECT
			@CantidadCalcularImporte = @Cantidad;
	END;

	IF @CantidadNegativa = 1
	AND @MovTipo NOT IN('VTAS.EST', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'INV.A', 'INV.EST')
	AND @ArtTipo <> 'SERVICIO'
	AND @FacturarVtasMostrador = 0
	AND @Accion <> 'CANCELAR'
	BEGIN
		SELECT
			@Ok = 20010
	END;

	IF @CantidadNegativa = 1
			AND @CfgBloquearNotasNegativas = 1
			AND @MovTipo IN('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM')
	AND @Ok IS NULL
	BEGIN
		SELECT
			@Ok = 65070
	END;

  /*
  EXEC spMovTipoInstruccionBit @Modulo, @Mov, 'AfectarCostos',   @AfectarCostos   OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
  EXEC spMovTipoInstruccionBit @Modulo, @Mov, 'AfectarUnidades', @AfectarUnidades OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
  */

	IF @MovTipo = 'COMS.GX'
	BEGIN
		IF
		(
			SELECT
				ISNULL(EsEstadistica, 0)
			FROM
				CompraD
			WHERE
        ID = @ID
			AND Renglon = @Renglon
			AND RenglonSub = @RenglonSub
		) = 1
		BEGIN
			SELECT
				@AfectarUnidades = 0,
				@AfectarCostos = 0
		END
	END;

	EXEC xpInvInitRenglon
		@Empresa,
		@CfgDecimalesCantidades,
		@CfgMultiUnidades,
		@CfgMultiUnidadesNivel,
		@CfgCompraFactorDinamico,
		@CfgInvFactorDinamico,
		@CfgProdFactorDinamico,
		@CfgVentaFactorDinamico,
		@CfgBloquearNotasNegativas,
		@AlVerificar,
		@Matando,
		@Accion,
		@Base,
		@Modulo,
		@ID,
		@Renglon,
		@RenglonSub,
		@Estatus,
		@EstatusNuevo,
		@MovTipo,
		@FacturarVtasMostrador,
		@EsTransferencia,
		@AfectarConsignacion,
		@ExplotandoSubCuenta,
		@AlmacenTipo,
		@AlmacenDestinoTipo,
		@Articulo,
		@MovUnidad,
		@ArtUnidad,
		@ArtTipo,
		@RenglonTipo,
		@AplicaMovTipo,
		@CantidadOriginal,
		@CantidadInventario,
		@CantidadPendiente,
		@CantidadA,
		@DetalleTipo,
		@Cantidad OUTPUT,
		@CantidadCalcularImporte OUTPUT,
		@CantidadReservada OUTPUT,
		@CantidadOrdenada OUTPUT,
		@EsEntrada OUTPUT,
		@EsSalida OUTPUT,
		@SubCuenta OUTPUT,
		@AfectarPiezas OUTPUT,
		@AfectarCostos OUTPUT,
		@AfectarUnidades OUTPUT,
		@Factor OUTPUT,
		@Ok OUTPUT,
		@OkRef OUTPUT;
	RETURN;
END;