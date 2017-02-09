USE [Cuprum]
GO

/****** Object:  StoredProcedure [dbo].[spInvVerificar]    Script Date: 07/02/2017 05:01:08 p.m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER  PROCEDURE [dbo].[spInvVerificar]
  @ID INT,
  @Accion CHAR(20),
  @Base CHAR(20),
  @Empresa CHAR(5),
  @Usuario CHAR(10),
  @Autorizacion CHAR(10) OUTPUT,
  @Mensaje INT,
  @Modulo CHAR(5),
  @Mov CHAR(20),
  @MovID VARCHAR(20),
  @MovTipo CHAR(20),
  @MovMoneda CHAR(10),
  @MovTipoCambio FLOAT,
  @FechaEmision DATETIME,
  @Ejercicio INT,
  @Periodo INT,
  @Almacen CHAR(10),
  @AlmacenTipo CHAR(15),
  @AlmacenDestino CHAR(10),
  @AlmacenDestinoTipo CHAR(15),
  @VoltearAlmacen BIT,
  @AlmacenEspecifico CHAR(10),
  @Condicion VARCHAR(50),
  @Vencimiento DATETIME,
  @ClienteProv CHAR(10),
  @EnviarA INT,
  @DescuentoGlobal FLOAT,
  @SobrePrecio FLOAT,
  @ConCredito BIT,
  @ConLimiteCredito BIT,
  @LimiteCredito MONEY,
  @ConLimitePedidos BIT,
  @LimitePedidos MONEY,
  @MonedaCredito CHAR(10),
  @TipoCambioCredito FLOAT,
  @DiasCredito INT,
  @CondicionesValidas VARCHAR(255),
  @PedidosParciales BIT,
  @VtasConsignacion BIT,
  @AlmacenVtasConsignacion CHAR(10),
  @AnticiposFacturados MONEY,
  @Estatus CHAR(15),
  @EstatusNuevo CHAR(15),
  @AfectarMatando BIT,
  @AfectarMatandoOpcional BIT,
  @AfectarConsignacion BIT,
  @AfectarAlmacenRenglon BIT,
  @OrigenTipo VARCHAR(10),
  @Origen VARCHAR(20),
  @OrigenID VARCHAR(20),
  @OrigenMovTipo VARCHAR(20),
  @FacturarVtasMostrador BIT,
  @EsTransferencia BIT,
  @ServicioGarantia BIT,
  @ServicioArticulo CHAR(20),
  @ServicioSerie CHAR(20),
  @FechaRequerida DATETIME,
  @AutoCorrida CHAR(8),
  @CfgCosteoNivelSubCuenta BIT,
  @CfgDecimalesCantidades INT,
  @CfgSeriesLotesMayoreo BIT,
  @CfgSeriesLotesAutoOrden CHAR(20),
  @CfgValidarPrecios CHAR(20),
  @CfgPrecioMinimoSucursal BIT,
  @CfgValidarMargenMinimo CHAR(20),
  @CfgVentaSurtirDemas BIT,
  @CfgCompraRecibirDemas BIT,
  @CfgCompraRecibirDemasTolerancia FLOAT,
  @CfgTransferirDemas BIT,
  @CfgVentaChecarCredito CHAR(20),
  @CfgVentaPedidosDisminuyenCredito BIT,
  @CfgVentaBloquearMorosos CHAR(20),
  @CfgVentaLiquidaIntegral BIT,
  @CfgFacturaCobroIntegrado BIT,
  @CfgInvPrestamosGarantias BIT,
  @CfgInvEntradasSinCosto BIT,
  @CfgServiciosRequiereTareas BIT,
  @CfgServiciosValidarID BIT,
  @CfgImpInc BIT,
  @CfgLimiteRenFacturas INT,
  @CfgNotasBorrador BIT,
  @CfgAnticiposFacturados BIT,
  @CfgMultiUnidades BIT,
  @CfgMultiUnidadesNivel CHAR(20),
  @CfgCompraFactorDinamico BIT,
  @CfgInvFactorDinamico BIT,
  @CfgProdFactorDinamico BIT,
  @CfgVentaFactorDinamico BIT,
  @CfgToleranciaCosto MONEY,
  @CfgToleranciaCostoInferior MONEY,
  @CfgToleranciaTipoCosto CHAR(20),
  @CfgFormaPagoRequerida BIT,
  @CfgBloquearNotasNegativas BIT,
  @CfgBloquearFacturacionDirecta BIT,
  @CfgBloquearInvSalidaDirecta BIT,
  @SeguimientoMatriz BIT,
  @CobroIntegrado BIT,
  @CobroIntegradoCxc BIT,
  @CobroIntegradoParcial BIT,
  @CobrarPedido BIT,
  @CfgCompraValidarArtProv BIT,
  @CfgValidarCC BIT,
  @CfgVentaRestringida BIT,
  @CfgLimiteCreditoNivelGrupo BIT,
  @CfgLimiteCreditoNivelUEN BIT,
  @CfgRestringirArtBloqueados BIT,
  @CfgValidarFechaRequerida BIT,
  @FacturacionRapidaAgrupada BIT,
  @Utilizar BIT,
  @UtilizarID INT,
  @UtilizarMovTipo CHAR(20),
  @Generar BIT,
  @GenerarMov CHAR(20),
  @GenerarAfectado BIT,
  @Conexion BIT,
  @SincroFinal BIT,
  @Sucursal INT,
  @SucursalDestino INT,
  @AccionEspecial VARCHAR(20),
  @AnexoID INT,
  @Autorizar BIT OUTPUT,
  @AfectarConsecutivo BIT OUTPUT,
  @Ok INT OUTPUT,
  @OkRef VARCHAR(255) OUTPUT,
  @CfgPrecioMoneda BIT = 0
----WITH ENCRYPTION
AS
BEGIN
  DECLARE
    @EnLinea BIT,
    @Renglon FLOAT,
    @RenglonSub INT,
    @RenglonID INT,
    @RenglonTipo CHAR(1),
    @Conteo INT,
    @AutoGenerado BIT,
    @AfectarAlmacen CHAR(10),
    @AfectarAlmacenTipo CHAR(20),
    @Articulo CHAR(20),
    @ArticuloDestino CHAR(20),
    @SubCuentaDestino VARCHAR(20),
    @ArtTipo CHAR(20),
    @ArtSerieLoteInfo BIT,
    @ArtTipoOpcion CHAR(20),
    @ArtTipoCompra VARCHAR(20),
    @ArtSeProduce BIT,
    @ArtSeCompra BIT,
    @ArtEsFormula BIT,
    @ArtUnidad VARCHAR(50),
    @ArtMargenMinimoBorrar BIT,
    @ArtMargenMinimo MONEY,
    @ArtMonedaVenta CHAR(10),
    @ArtFactorVenta FLOAT,
    @ArtTipoCambioVenta FLOAT,
    @ArtPrecioMinimo MONEY,
    @ArtMonedaCosto CHAR(10),
    @ArtFactorCosto FLOAT,
    @ArtTipoCambioCosto FLOAT,
    @ArtCaducidadMinima INT,
    @ArtNivelToleranciaCosto VARCHAR(10),
    @ArtToleranciaCosto MONEY,
    @ArtToleranciaCostoInferior MONEY,
    @FechaCaducidad DATETIME,
    @Subcuenta VARCHAR(50),
    @SustitutoArticulo VARCHAR(20),
    @SustitutoSubcuenta VARCHAR(50),
    @Cantidad FLOAT,
    @CantidadObsequio FLOAT,
    @CantidadSugerida FLOAT,
    @CantidadCalcularImporte FLOAT,
    @MovUnidad VARCHAR(50),
    @Factor FLOAT,
    @CantidadOriginal FLOAT,
    @CantidadInventario FLOAT,
    @CantidadPendiente FLOAT,
    @CantidadReservada FLOAT,
    @CantidadOrdenada FLOAT,
    @CantidadA FLOAT,
    @CantidadSeries INT,
    @IDAplica INT,
    @AplicaMov CHAR(20),
    @AplicaMovID VARCHAR(20),
    @AplicaOrdenado FLOAT,
    @AplicaPendiente FLOAT,
    @AplicaReservada FLOAT,
    @AplicaClienteProv CHAR(10),
    @AplicaCondicion VARCHAR(50),
    @AplicaMovTipo CHAR(20),
    @AplicaControlAnticipos CHAR(20),
    @AplicaAutorizacion CHAR(10),
    @AlmacenRenglon CHAR(10),
    @ArticuloMatar CHAR(20),
    @SubCuentaMatar VARCHAR(50),
    @Costo FLOAT,
    @ArtCosto FLOAT,
    @Saldo MONEY,
    @VentasPendientes MONEY,
    @RemisionesAplicadas MONEY,
    @PedidosPendientes MONEY,
    @Disponible FLOAT,
    @EsEntrada BIT,
    @EsSalida BIT,
    @AfectarPiezas BIT,
    @AfectarCostos BIT,
    @AfectarUnidades BIT,
    @AfectarAlgo BIT,
    @Precio FLOAT,
    @PrecioUnitarioNeto MONEY,
    @PrecioTipoCambio FLOAT,
    @DescuentoTipo CHAR(1),
    @DescuentoLinea FLOAT,
    @Impuesto1 FLOAT,
    @Impuesto2 FLOAT,
    @Impuesto3 MONEY,
    @Impuesto5 MONEY,
    @Importe MONEY,
    @ImporteNeto MONEY,
    @Impuestos MONEY,
    @ImpuestosNetos MONEY,
    @ImporteTotal MONEY,
    @ValesCobrados MONEY,
    @TarjetasCobradas MONEY,
    @Importe1 MONEY,
    @Importe2 MONEY,
    @Importe3 MONEY,
    @Importe4 MONEY,
    @Importe5 MONEY,
    @FormaCobro1 VARCHAR(50),
    @FormaCobro2 VARCHAR(50),
    @FormaCobro3 VARCHAR(50),
    @FormaCobro4 VARCHAR(50),
    @FormaCobro5 VARCHAR(50),
    @FormaCobroVales VARCHAR(50),
    @FormaCobroTarjetas VARCHAR(50),
    @CobroDesglosado MONEY,
    @CobroCambio MONEY,
    @CobroRedondeo MONEY,
    @CobroDelEfectivo MONEY,
    @Efectivo MONEY,
    @DescuentoLineaImporte MONEY,
    @DescuentoGlobalImporte MONEY,
    @SobrePrecioImporte MONEY,
    @SumaCantidadOriginal FLOAT,
    @SumaCantidadPendiente FLOAT,
    @ImporteTotalSinAutorizar MONEY,
    @SumaImporteNeto MONEY,
    @SumaImpuestosNetos MONEY,
    @UtilizarEstatus CHAR(15),
    @ServicioArticuloTipo CHAR(20),
    @DiasVencimiento INT,
    @MaxDiasMoratorios INT,
    @DiasTolerancia INT,
    @ChecarCredito BIT,
    @SerieLote CHAR(50),
    @EstatusCuenta CHAR(15),
    @Descripcion VARCHAR(100),
    @TareaOmision VARCHAR(50),
    @TareaOmisionEstado VARCHAR(30),
    @DetalleTipo VARCHAR(20),
    @NoValidarDisponible BIT,
    @ValidarDisponible BIT,
    @ValidarCobroIntegrado BIT,
    @CANTSaldo MONEY,
    @Minimo MONEY,
    @Maximo MONEY,
    @AlmacenTemp CHAR(10),
    @AlmacenOriginal CHAR(10),
    @AlmacenDestinoOriginal CHAR(10),
    @CfgControlAlmacenes BIT,
    @CfgLimitarCompraLocal BIT,
    @ProdSerieLote VARCHAR(50),
    @ProdRuta VARCHAR(20),
    @ProdOrden INT,
    @ProdOrdenID INT,
    @ProdOrdenDestino INT,
    @ProdOrdenFinal INT,
    @ProdOrdenSiguiente INT,
    @ProdCentro CHAR(10),
    @ProdCentroDestino CHAR(10),
    @ProdCentroSiguiente CHAR(10),
    @ProdEstacion CHAR(10),
    @ProdEstacionDestino CHAR(10),
    @DifCredito MONEY,
    @ImporteAutorizar MONEY,
    @AlmacenSucursal INT,
    @AlmacenDestinoSucursal INT,
    @CfgVentaCobroRedondeoDecimales INT,
    @CfgVentaLimiteRenFacturasVMOS BIT,
    @CfgAutoAutorizacionFacturas BIT,
    @SumaImporteNetoSinAutorizar MONEY,
    @SumaImpuestosNetosSinAutorizar MONEY,
    @CantidadMinimaVenta FLOAT,
    @CantidadMaximaVenta FLOAT,
    @CfgVentaDevSinAntecedente BIT,
    @CfgVentaDevSeriesSinAntecedente BIT,
    @CfgCompraCaducidad BIT,
    @ContUso VARCHAR(20),
    @Flotante FLOAT,
    @Identificador VARCHAR(20),
    @EmpresaGrupo VARCHAR(50),
    @ArtActividades BIT,
    @RedondeoMonetarios INT,
    @ValidarFechaRequerida BIT,
    @FechaRequeridaD DATETIME,
    @ExcendeteDemas FLOAT,
    @SeriesLotesAutoOrden CHAR(20),
    @UltimoCosto FLOAT,
    @CostoPromedio FLOAT,
    @CostoEstandar FLOAT,
    @CostoReposicion FLOAT,
    @VentaUEN INT,
    @CategoriaActivoFijo VARCHAR(50),
    @Paquete INT,
    @PPTO BIT,
    @PPTOVentas BIT,
    @FEA BIT,
    @EsEstadistica BIT,
    @Tarima VARCHAR(20),
    @Seccion INT,
    @Tarjeta VARCHAR(20),
    @PuntosTarjeta MONEY,
    @CfgCompraPresupuestosCategoria BIT,
    @CfgCompraValidarPresupuesto VARCHAR(20),
    @CfgValidarOrdenCompraTolerancia BIT,
    @CfgCompraValidarPresupuestoMov VARCHAR(15),
    @Retencion1 FLOAT,
    @Retencion2 FLOAT,
    @Retencion3 FLOAT,
    @Retencion1Neto FLOAT,
    @Retencion2Neto FLOAT,
    @Retencion3Neto FLOAT,
    @RetencionesNeto FLOAT,
    @SumaRetencionesNeto FLOAT,
    @CfgProdSerieLoteDesdeOrden BIT,
    @LotesFijos BIT,
    @AjusteMov CHAR(20),
    @BloquearFacturaOtraSucursal BIT,
    @SucursalAcceso INT,
    @SucursalAlmacen INT,
    @SucursalAlmacenRenglon INT,
    @Subclave VARCHAR(20),
    @CfgValidarPreciosAux CHAR(20),
    @CfgOpcionBloquearDescontinuado BIT,
    @CfgOpcionPermitirDescontinuado BIT,
    @AnticipoFacturado BIT,
    @CfgVentaRefSerieLotePedidos BIT,
    @SubCuentaExplotarInformacion BIT,
    @TipoCondicion VARCHAR(20),
/*Para la Refecturacion PST EBG 08/04/2014*/
    @Refacturado BIT

  SELECT
    @CfgValidarPreciosAux = @CfgValidarPrecios

  SELECT TOP 1
    @Subclave = SubClave,
    @CfgOpcionPermitirDescontinuado = ISNULL(OpcionPermitirDescontinuado, 0)
  FROM
    MovTipo
  WHERE
    Modulo = @Modulo
    AND Clave = @MovTipo
    AND Mov = @Mov 



  SELECT
    @RedondeoMonetarios = dbo.fnRedondeoMonetarios()

  SELECT
    @ChecarCredito = 0,
    @NoValidarDisponible = 0,
    @CfgControlAlmacenes = 0,
    @SerieLote = NULL,
    @ProdSerieLote = NULL,
    @ProdOrden = NULL,
    @ProdOrdenDestino = NULL,
    @ProdCentro = NULL,
    @ProdCentroDestino = NULL,
    @ProdRuta = NULL,
    @Descripcion = NULL,
    @IDAplica = NULL,
    @AplicaAutorizacion = NULL,
    @AlmacenOriginal = @Almacen,
    @AlmacenDestinoOriginal = @AlmacenDestino,
    @Autorizar = 0,
    @ValidarFechaRequerida = 0,
    @VentaUEN = NULL,
    @PPTO = 0
  CREATE TABLE #SerieLoteTransito
  (
    ID INT NOT NULL
           IDENTITY(1, 1),
    Modulo VARCHAR(10) COLLATE Database_Default
                       NULL,
    ModuloID INT NULL,
    Articulo VARCHAR(10) COLLATE Database_Default
                         NULL,
    SubCuenta VARCHAR(50) COLLATE Database_Default
                          NULL,
    SerieLote VARCHAR(50) COLLATE Database_Default
                          NULL,
    Cantidad FLOAT NULL
  )
  IF @CfgLimiteCreditoNivelGrupo = 1
    SELECT
      @EmpresaGrupo = NULLIF(RTRIM(Grupo), '')
    FROM
      Empresa
    WHERE
      Empresa = @Empresa
  IF @CfgLimiteCreditoNivelUEN = 1
    AND @Modulo = 'VTAS'
    BEGIN
      SELECT
        @VentaUEN = UEN
      FROM
        Venta
      WHERE
        ID = @ID
      SELECT
        @LimiteCredito = CreditoLimite
      FROM
        CteUEN
      WHERE
        Cliente = @ClienteProv
        AND UEN = @VentaUEN
    END

        /* PST EBG 08/04/2014
        Para omitir la validacion de Costos en Refacturacion
        Se pregunta si es refacturacion*/
  SELECT
    @Refacturado = 0
  IF @Modulo = 'VTAS'
    SELECT
      @Refacturado = Refacturado
    FROM
      Venta
    WHERE
      ID = @ID
        /*******************************/
  SELECT
    @PPTO = PPTO,
    @PPTOVentas = PPTOVentas,
    @FEA = FEA,
    @CfgOpcionBloquearDescontinuado = ISNULL(OpcionBloquearDescontinuado, 0),
    @SubCuentaExplotarInformacion = ISNULL(SubCuentaExplotarInformacion, 0)
  FROM
    EmpresaGral
  WHERE
    Empresa = @Empresa
  SELECT
    @CfgVentaCobroRedondeoDecimales = VentaCobroRedondeoDecimales,
    @CfgVentaLimiteRenFacturasVMOS = ISNULL(VentaLimiteRenFacturasVMOS, 0),
    @FormaCobroVales = CxcFormaCobroVales,
    @FormaCobroTarjetas = CxcFormaCobroTarjetas,
    @CfgCompraValidarPresupuesto = UPPER(ISNULL(CompraValidarPresupuesto, 'NO')),
    @CfgValidarOrdenCompraTolerancia = ISNULL(ValidarOrdenCompraTolerancia, 0),
    @CfgCompraValidarPresupuestoMov = UPPER(ISNULL(CompraValidarPresupuestoMov, '(ENTRADA COMPRA)')),
    @CfgVentaRefSerieLotePedidos = VentaRefSerieLotePedidos
  FROM
    EmpresaCfg
  WHERE
    Empresa = @Empresa
  SELECT
    @CfgAutoAutorizacionFacturas = AutoAutorizacionFacturas,
    @CfgVentaDevSinAntecedente = VentaDevSinAntecedente,
    @CfgVentaDevSeriesSinAntecedente = VentaDevSeriesSinAntecedente,
    @CfgCompraCaducidad = ISNULL(CompraCaducidad, 0),
    @CfgCompraPresupuestosCategoria = ISNULL(CompraPresupuestosCategoria, 0),
    @CfgProdSerieLoteDesdeOrden = ISNULL(ProdSerieLoteDesdeOrden, 0),
    @BloquearFacturaOtraSucursal = ISNULL(BloquearFacturaOtraSucursal, 0)
  FROM
    EmpresaCfg2
  WHERE
    Empresa = @Empresa
  SELECT
    @CfgControlAlmacenes = ISNULL(ControlAlmacenes, 0),
    @CfgLimitarCompraLocal = ISNULL(LimitarCompraLocal, 0)
  FROM
    UsuarioCfg2
  WHERE
    Usuario = @Usuario
  SELECT
    @AjusteMov = InvAjuste
  FROM
    EmpresaCfgMov
  WHERE
    Empresa = @Empresa
  SELECT
    @SucursalAcceso = Sucursal
  FROM
    Acceso
  WHERE
    SPID = @@SPID
    AND Usuario = @Usuario
  SELECT
    @SucursalAlmacen = Sucursal
  FROM
    Alm
  WHERE
    Almacen = @Almacen
  IF EXISTS ( SELECT
                *
              FROM
                Inv
              WHERE
                Empresa = @Empresa
                AND Estatus = 'CONFIRMAR'
                AND OrigenTipo = 'VMOS'
                AND Sucursal = @Sucursal
                AND Mov = @AjusteMov
                AND Almacen = @Almacen )
    AND @Modulo = 'VTAS'
    AND @OrigenTipo = 'VMOS'
    AND @Estatus = 'BORRADOR'
    AND @EstatusNuevo = 'CONCLUIDO'
    SELECT
      @Ok = 10170
/* Aqui estaba la validacion del error 60070 */
  IF NULLIF(RTRIM(@Almacen), '') IS NULL
    AND @Modulo IN ( 'VTAS', 'COMS', 'INV' )
    AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
    SELECT
      @Ok = 20390
  IF NULLIF(RTRIM(@AlmacenDestino), '') IS NULL
    AND @MovTipo = 'INV.DTI'
    AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
    SELECT
      @Ok = 20390
  IF @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
    AND @CobroIntegrado = 0
    AND (
          ( @MovTipo IN ( 'VTAS.C', 'VTAS.CS' ) )
          OR (
               @MovTipo IN ( 'VTAS.P', 'VTAS.S' )
               AND @EstatusNuevo = 'PENDIENTE'
             )
          OR (
               @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', /*'VTAS.FX', */ 'VTAS.FB', 'VTAS.R' )
               AND @Utilizar = 0
             )
        )
    SELECT
      @ChecarCredito = 1
  IF @MovTipo IN ( 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM' )
    AND @CfgNotasBorrador = 1
    AND (
          @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
          OR @Accion = 'CANCELAR'
        )
    SELECT
      @NoValidarDisponible = 1
  IF @Accion IN ( 'RESERVAR', 'DESRESERVAR', 'RESERVARPARCIAL', 'ASIGNAR', 'DESASIGNAR' )
    AND @MovTipo NOT IN ( 'VTAS.P', 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.S', 'INV.SOL', 'INV.SM',
                          'INV.OT', 'INV.OI' )
    SELECT
      @Ok = 60040
  IF @Accion = 'CANCELAR'
    AND @MovTipo = 'VTAS.FM'
    AND @Estatus = 'CONCLUIDO'
    SELECT
      @Ok = 60050,
      @OkRef = RTRIM(@Mov) + ' ' + RTRIM(@MovID)
  IF @Modulo = 'COMS'
    AND @MovTipo IN ( 'COMS.O', 'COMS.OP', 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.CC', 'COMS.OG', 'COMS.OD',
                      'COMS.OI', 'COMS.IG' )
    AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
    AND @Ok IS NULL
    BEGIN
      SELECT
        @EstatusCuenta = Estatus
      FROM
        Prov
      WHERE
        Proveedor = @ClienteProv
      IF @EstatusCuenta = 'BLOQUEADO'
        BEGIN
          SELECT
            @Ok = 65032,
            @OkRef = @ClienteProv
          EXEC xpOk_65032 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
        END
    END
  IF @Modulo IN ( 'VTAS', 'COMS' )
    AND @MovTipo <> 'COMS.R'
    AND NULLIF(RTRIM(@ClienteProv), '') IS NULL
    AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
    BEGIN
      IF @Modulo = 'VTAS'
        SELECT
          @Ok = 40010
      ELSE
        IF @Modulo = 'COMS'
          SELECT
            @Ok = 40020
    END
  IF @CfgValidarFechaRequerida = 1
    BEGIN
      IF (
           @Modulo = 'VTAS'
           AND @MovTipo IN ( 'VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.VP', 'VTAS.S', 'VTAS.PR', 'VTAS.EST', 'VTAS.F',
                             'VTAS.FAR', 'VTAS.FC', 'VTAS.DFC', 'VTAS.FB', 'VTAS.R', 'VTAS.SG', 'VTAS.EG', 'VTAS.VC',
                             'VTAS.VCR', 'VTAS.SD' )
         )
        OR (
             @Modulo = 'COMS'
             AND @MovTipo NOT IN ( 'COMS.D', 'COMS.DG', 'COMS.B', 'COMS.DC' )
           )
        SELECT
          @ValidarFechaRequerida = 1
    END
  IF @ValidarFechaRequerida = 1
    IF @FechaRequerida IS NULL
      SELECT
        @Ok = 25120
    ELSE

--Kike Sierra: 17/06/2013: Se Modifico la validacion para no considerar los movs de Oferta Servicio
---Condicion Original:   IF (@FechaRequerida < @FechaEmision)
      IF (
           @FechaRequerida < @FechaEmision
           AND NOT (
                     @Modulo = 'VTAS'
                     AND @MovTipo IN ( 'VTAS.P', 'VTAS.C', 'VTAS.F', 'VTAS.VP' )
                   )
         )
        SELECT
          @Ok = 25121 


  IF @Modulo = 'VTAS'
    AND @MovTipo NOT IN ( 'VTAS.PR', 'VTAS.EST', 'VTAS.SD', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B', 'VTAS.DR',
                          'VTAS.DC', 'VTAS.DCR', 'VTAS.VP' )
    AND @Accion NOT IN ( 'CANCELAR', 'DESRESERVAR', 'GENERAR' )
    AND (
          @Autorizacion IS NULL
          OR @Mensaje NOT IN ( 65010, 65020, 65040, 20310, 65030, 65035 )
        )
    AND @Ok IS NULL
    BEGIN
      SELECT
        @EstatusCuenta = Estatus
      FROM
        Cte
      WHERE
        Cliente = @ClienteProv
      IF @EstatusCuenta <> 'BLOQUEADO'
        SELECT
          @EstatusCuenta = Estatus,
          @Descripcion = Descripcion
        FROM
          Bloqueo
        WHERE
          Bloqueo = @EstatusCuenta
      IF @EstatusCuenta = 'BLOQUEADO'
        SELECT
          @Ok = 65030,
          @OkRef = @Descripcion

      IF ISNULL(@EnviarA, 0) > 0
        AND @Ok IS NULL
        BEGIN
          SELECT
            @EstatusCuenta = Estatus
          FROM
            CteEnviarA
          WHERE
            Cliente = @ClienteProv
            AND ID = @EnviarA
          IF @EstatusCuenta <> 'BLOQUEADO'
            SELECT
              @EstatusCuenta = Estatus,
              @Descripcion = Descripcion
            FROM
              Bloqueo
            WHERE
              Bloqueo = @EstatusCuenta
          IF @EstatusCuenta = 'BLOQUEADO'
            SELECT
              @Ok = 65035,
              @OkRef = @Descripcion
        END
      IF @Ok IS NOT NULL
        SELECT
          @Autorizar = 1
    END



  IF @AnticiposFacturados <> 0.0
    AND @Ok IS NULL
    AND @Estatus = 'SINAFECTAR'
    BEGIN
      IF @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FB' )
        AND @CfgAnticiposFacturados = 1
        BEGIN
          IF @AnticiposFacturados < 0.0
            SELECT
              @Ok = 30100
          ELSE
            IF @Accion <> 'CANCELAR'
              BEGIN
                SELECT
                  @CANTSaldo = 0.0
/*SELECT @CANTSaldo = ROUND(ISNULL(SUM(Saldo), 0.0), 2) FROM Saldo WHERE Rama = 'CANT' AND Empresa = @Empresa AND Moneda = @MovMoneda AND Cuenta = @ClienteProv*/

-- Kike Sierra : 10/06/2014:Se modifico la siguiente validacion ya que Anteriormente redondeaba a 2 decimales de forma constante.
-- lo cual provocaba errores en el desarrollo de Pedidos-Factura Anticipo.

                SELECT
                  @CANTSaldo = ROUND(ISNULL(SUM(AnticipoSaldo
                                                * ( CASE WHEN Cxc.ClienteMoneda <> @MovMoneda
                                                         THEN Cxc.ClienteTipoCambio / @MovTipoCambio
                                                         ELSE 1.0
                                                    END )), 0.0), @CfgDecimalesCantidades)
                FROM
                  Cxc
                WHERE
                  Empresa = @Empresa
                  AND AnticipoAplicaModulo = @Modulo
                  AND AnticipoAplicaID = @ID    
                                            
                                   
									  -- Kike Sierra : 10/06/2014:Se modifico la siguiente validacion ya que Anteriormente redondeaba a 2 decimales de forma constante.
									  -- lo cual provocaba errores en el desarrollo de Pedidos-Factura Anticipo.
                IF ROUND(@AnticiposFacturados, @CfgDecimalesCantidades) > @CANTSaldo
                  BEGIN
                    SELECT
                      @Ok = 30400    
                  END 
              END
        END
      ELSE
        SELECT
          @Ok = 70070




      IF @Ok IS NOT NULL
        SELECT
          @OkRef = 'Anticipos Facturados'
    END
  IF @MovTipo = 'INV.TC'
    SELECT
      @Ok = 60120
  IF @Accion <> 'CANCELAR'
    AND @Ok IS NULL
    BEGIN
      IF @MovTipo IN ( 'VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.S', 'VTAS.F', 'VTAS.FAR', 'VTAS.FB', 'COMS.C', 'COMS.O',
                       'COMS.OP', 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'INV.P' )
        EXEC spVerificarVencimiento @Condicion, @Vencimiento, @FechaEmision, @Ok OUTPUT
      IF @Modulo = 'VTAS'
        AND @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
        AND ( @Base IN ( 'SELECCION', 'RESERVADO' ) )
        AND @PedidosParciales = 0
        IF (
             @Utilizar = 1
             AND @UtilizarMovTipo = 'VTAS.P'
           )
          OR (
               @Generar = 1
               AND @MovTipo = 'VTAS.P'
             )
          SELECT
            @Ok = 20300
      IF @MovTipo IN ( 'VTAS.VC', 'VTAS.DC' )
        IF @VtasConsignacion = 0
          OR @AlmacenVtasConsignacion = NULL
          SELECT
            @Ok = 20270
    END
  IF @MovTipo IN ( 'INV.OI', 'INV.TI', 'INV.SI', 'INV.EI' )
    AND @Accion <> 'GENERAR'
    BEGIN
      IF @AlmacenDestino = @Almacen
        OR @AlmacenDestino IS NULL
        SELECT
          @Ok = 20120 /*ELSE
IF EXISTS(SELECT * FROM Alm a, Alm d WHERE a.Sucursal = d.Sucursal AND a.Almacen = @Almacen AND d.Almacen = @AlmacenDestino) SELECT @Ok = 20800*/
    END
  IF @Estatus = 'PENDIENTE'
    AND @Accion = 'CANCELAR'
    AND @Base IN ( 'SELECCION', 'PENDIENTE' )
    AND @MovTipo NOT IN ( 'VTAS.P', 'VTAS.S', 'COMS.R', 'COMS.O', 'COMS.OP', 'COMS.OG', 'COMS.OD', 'COMS.OI', 'INV.SOL',
                          'INV.OT', 'INV.OI', 'INV.TI', 'INV.SM', 'PROD.O', 'VTAS.VCR' )
    SELECT
      @Ok = 60240
  IF @MovTipo IN ( 'VTAS.S', 'VTAS.SG', 'VTAS.EG' )
    AND @Ok IS NULL
    BEGIN
      SELECT
        @ServicioArticuloTipo = NULL
      SELECT
        @ServicioArticuloTipo = UPPER(Tipo)
      FROM
        Art
      WHERE
        Articulo = @ServicioArticulo
      IF @ServicioArticuloTipo IS NULL
        SELECT
          @Ok = 20450
      ELSE
        IF @ServicioArticuloTipo IN ( 'SERIE', 'LOTE', 'VIN', 'PARTIDA' )
          AND @ServicioSerie IS NULL
          SELECT
            @Ok = 20460
    END
  IF @MovTipo = 'INV.TMA'
    AND @Accion <> 'CANCELAR'
    AND @Ok IS NULL
    EXEC spInvVerificarTarima @ID, @Accion, @Empresa, @Sucursal, @Usuario, @Ok OUTPUT, @OkRef OUTPUT
  IF @MovTipo IN ( 'VTAS.N', 'VTAS.NO', 'VTAS.NR' )
    AND @Accion = 'CANCELAR'
    IF EXISTS ( SELECT
                  *
                FROM
                  Venta
                WHERE
                  ID = (
                         SELECT
                          ID
                         FROM
                          VentaOrigen
                         WHERE
                          OrigenID = @ID
                       )
                  AND Estatus = 'BORRADOR' )
      SELECT
        @Ok = 30370
  IF @Accion NOT IN ( 'GENERAR', 'CANCELAR' )
    AND @Ok IS NULL
    EXEC spValidarMovImporteMaximo @Usuario, @Modulo, @Mov, @ID, @Ok OUTPUT, @OkRef OUTPUT
  IF @FEA = 1
    IF (
         SELECT
          NULLIF(RTRIM(ConsecutivoFEA), '')
         FROM
          MovTipo
         WHERE
          Modulo = @Modulo
          AND Mov = @Mov
       ) IS NOT NULL
      EXEC spPreValidarFEA @ID, 1, @Ok OUTPUT, @OkRef OUTPUT
  IF @BloquearFacturaOtraSucursal = 1
    AND @SucursalAcceso <> @SucursalAlmacen
    AND @Ok IS NULL
    AND @MovTipo IN ( 'VTAS.P', 'VTAS.F', 'VTAS.D', 'VTAS.VCR', 'VTAS.DCR', 'VTAS.DF', 'VTAS.B', 'VTAS.N', 'VTAS.FM',
                      'VTAS.NO', 'VTAS.NR', 'VTAS.FR' )
    AND @Accion IN ( 'AFECTAR', 'RESERVAR', 'DESRESERVAR', 'RESERVARPARCIAL', 'ASIGNAR', 'DESASIGNAR' )
    SELECT
      @Ok = 20785,
      @OkRef = RTRIM(LTRIM(@Almacen)) + ' - ' + (
                                                  SELECT
                                                    ISNULL(Nombre, '')
                                                  FROM
                                                    Sucursal
                                                  WHERE
                                                    Sucursal = @SucursalAlmacen
                                                )
/*IF @Ok IS NULL
EXEC vic_spInvVerificar @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo,
@Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo,
@FechaEmision,
@Ok OUTPUT, @OkRef OUTPUT*/
  IF @Ok IS NULL
    EXEC xpInvVerificar @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo, @MovMoneda,
      @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @Ok OUTPUT, @OkRef OUTPUT
  IF @Ok IS NULL
    EXEC spInvPedidoProrrateadoVerificar @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
      @MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @Ok OUTPUT, @OkRef OUTPUT
  IF @Ok IS NULL
    AND (
          SELECT
            EsGuatemala
          FROM
            Empresa
          WHERE
            Empresa = @Empresa
        ) = 1
    EXEC xpInvVerificarGuatemala @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo, @MovMoneda,
      @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @Ok OUTPUT, @OkRef OUTPUT
  CREATE TABLE #ValidarDisponible
  (
    Articulo VARCHAR(20) COLLATE DATABASE_DEFAULT
                         NULL,
    Subcuenta VARCHAR(20) COLLATE DATABASE_DEFAULT
                          NULL,
    Almacen VARCHAR(10) COLLATE DATABASE_DEFAULT
                        NULL,
    Cantidad FLOAT NULL,
    Disponible FLOAT NULL
  )
  IF @Ok IS NOT NULL
    RETURN
  IF @Modulo = 'VTAS'
    DECLARE crVerificarDetalle CURSOR
    FOR
    SELECT
      NULL,
      0,
      d.Renglon,
      d.RenglonSub,
      d.RenglonID,
      d.RenglonTipo,
      ( ISNULL(d.Cantidad, 0.0) - ISNULL(d.CantidadCancelada, 0.0) ),
      d.CantidadObsequio,
      d.CantidadInventario,
      ISNULL(d.CantidadReservada, 0.0),
      ISNULL(d.CantidadOrdenada, 0.0),
      ISNULL(d.CantidadPendiente, 0.0),
      ISNULL(d.CantidadA, 0.0),
      NULLIF(RTRIM(d.Unidad), ''),
      ISNULL(d.Factor, 0.0),
      NULLIF(RTRIM(d.Articulo), ''),
      NULLIF(RTRIM(d.SubCuenta), ''),
      CONVERT(VARCHAR(20), NULL),
      CONVERT(VARCHAR(20), NULL),
      NULLIF(RTRIM(d.SustitutoArticulo), ''),
      NULLIF(RTRIM(d.SustitutoSubCuenta), ''),
      ISNULL(d.Costo, 0.0),
      ISNULL(d.Precio, 0.0),
      NULLIF(RTRIM(d.DescuentoTipo), ''),
      ISNULL(d.DescuentoLinea, 0.0),
      ISNULL(d.Impuesto1, 0.0),
      ISNULL(d.Impuesto2, 0.0),
      ISNULL(d.Impuesto3, 0.0),
      NULLIF(RTRIM(d.Aplica), ''),
      d.AplicaID,
      NULLIF(RTRIM(d.Almacen), ''),
      RTRIM(UPPER(a.Tipo)),
      a.SerieLoteInfo,
      ISNULL(NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), 'NO'),
      RTRIM(UPPER(a.TipoCompra)),
      a.SeProduce,
      a.SeCompra,
      a.EsFormula,
      NULLIF(RTRIM(a.Unidad), ''),
      ISNULL(a.PrecioMinimo, 0.0),
      NULLIF(RTRIM(a.MonedaPrecio), ''),
      ISNULL(a.MargenMinimo, 0.0),
      NULLIF(RTRIM(a.MonedaCosto), ''),
      CONVERT(CHAR, NULL),
      CONVERT(CHAR, NULL),
      CONVERT(INT, NULL),
      CONVERT(INT, NULL),
      CONVERT(CHAR, NULL),
      CONVERT(CHAR, NULL),
      CONVERT(CHAR, NULL),
      NULLIF(a.CantidadMinimaVenta, 0),
      NULLIF(a.CantidadMaximaVenta, 0),
      CONVERT(INT, NULL),
      CONVERT(DATETIME, NULL),
      a.Actividades,
      d.FechaRequerida,
      d.Paquete,
      0,
      d.PrecioTipoCambio,
      NULLIF(RTRIM(d.Tarima), ''),
      ISNULL(NULLIF(RTRIM(a.NivelToleranciaCosto), ''), '(EMPRESA)'),
      ISNULL(a.ToleranciaCosto, 0),
      ISNULL(a.ToleranciaCostoInferior, 0),
      d.Retencion1,
      d.Retencion2,
      d.Retencion3,
      CONVERT(MONEY, NULL),
      AnticipoFacturado
    FROM
      VentaD d
      JOIN Art a ON a.Articulo = d.Articulo
    WHERE
      d.ID = @ID
  ELSE
    IF @Modulo = 'COMS'
      DECLARE crVerificarDetalle CURSOR
      FOR
      SELECT
        NULL,
        0,
        d.Renglon,
        d.RenglonSub,
        d.RenglonID,
        d.RenglonTipo,
        ( ISNULL(d.Cantidad, 0.0) - ISNULL(d.CantidadCancelada, 0.0) ),
        CONVERT(FLOAT, NULL),
        d.CantidadInventario,
        d.Cantidad,
        d.Cantidad,
        ISNULL(d.CantidadPendiente, 0.0),
        ISNULL(d.CantidadA, 0.0),
        NULLIF(RTRIM(d.Unidad), ''),
        d.Factor,
        NULLIF(RTRIM(d.Articulo), ''),
        NULLIF(RTRIM(d.SubCuenta), ''),
        CONVERT(VARCHAR(20), NULL),
        CONVERT(VARCHAR(20), NULL),
        CONVERT(CHAR(20), NULL),
        CONVERT(CHAR(20), NULL),
        ISNULL(d.Costo, 0.0),
        ISNULL(d.Costo, 0.0),
        NULLIF(RTRIM(d.DescuentoTipo), ''),
        ISNULL(d.DescuentoLinea, 0.0),
        ISNULL(d.Impuesto1, 0.0),
        ISNULL(d.Impuesto2, 0.0),
        ISNULL(d.Impuesto3, 0.0),
        NULLIF(RTRIM(d.Aplica), ''),
        d.AplicaID,
        NULLIF(RTRIM(d.Almacen), ''),
        NULLIF(RTRIM(UPPER(a.Tipo)), ''),
        a.SerieLoteInfo,
        ISNULL(NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), 'NO'),
        RTRIM(UPPER(a.TipoCompra)),
        a.SeProduce,
        a.SeCompra,
        a.EsFormula,
        NULLIF(RTRIM(a.Unidad), ''),
        ISNULL(a.PrecioMinimo, 0.0),
        NULLIF(RTRIM(a.MonedaPrecio), ''),
        ISNULL(a.MargenMinimo, 0.0),
        NULLIF(RTRIM(a.MonedaCosto), ''),
        CONVERT(CHAR, NULL),
        CONVERT(CHAR, NULL),
        CONVERT(INT, NULL),
        CONVERT(INT, NULL),
        CONVERT(CHAR, NULL),
        CONVERT(CHAR, NULL),
        CONVERT(CHAR, NULL),
        CONVERT(FLOAT, NULL),
        CONVERT(FLOAT, NULL),
        CASE WHEN a.TieneCaducidad = 1 THEN NULLIF(a.CaducidadMinima, 0)
             ELSE CONVERT(INT, NULL)
        END,
        d.FechaCaducidad,
        a.Actividades,
        d.FechaRequerida,
        d.Paquete,
        d.EsEstadistica,
        CONVERT(FLOAT, NULL),
        NULLIF(RTRIM(d.Tarima), ''),
        ISNULL(NULLIF(RTRIM(a.NivelToleranciaCosto), ''), '(EMPRESA)'),
        ISNULL(a.ToleranciaCosto, 0),
        ISNULL(a.ToleranciaCostoInferior, 0),
        d.Retencion1,
        d.Retencion2,
        d.Retencion3,
        d.Impuesto5,
        0
      FROM
        CompraD d
        LEFT OUTER JOIN Art a ON a.Articulo = d.Articulo
      WHERE
        d.ID = @ID
    ELSE
      IF @Modulo = 'INV'
        DECLARE crVerificarDetalle CURSOR
        FOR
        SELECT
          d.Seccion,
          0,
          d.Renglon,
          d.RenglonSub,
          d.RenglonID,
          d.RenglonTipo,
          ( ISNULL(d.Cantidad, 0.0) - ISNULL(d.CantidadCancelada, 0.0) ),
          CONVERT(FLOAT, NULL),
          d.CantidadInventario,
          ISNULL(d.CantidadReservada, 0.0),
          ISNULL(d.CantidadOrdenada, 0.0),
          ISNULL(d.CantidadPendiente, 0.0),
          ISNULL(d.CantidadA, 0.0),
          NULLIF(RTRIM(d.Unidad), ''),
          d.Factor,
          NULLIF(RTRIM(d.Articulo), ''),
          NULLIF(RTRIM(d.SubCuenta), ''),
          NULLIF(RTRIM(d.ArticuloDestino), ''),
          NULLIF(RTRIM(d.SubCuentaDestino), ''),
          CONVERT(CHAR(20), NULL),
          CONVERT(CHAR(20), NULL),
          ISNULL(d.Costo, 0.0),
          CONVERT(MONEY, NULL),
          '$',
          CONVERT(MONEY, NULL),
          CONVERT(FLOAT, NULL),
          CONVERT(FLOAT, NULL),
          CONVERT(MONEY, NULL),
          NULLIF(RTRIM(d.Aplica), ''),
          d.AplicaID,
          NULLIF(RTRIM(d.Almacen), ''),
          NULLIF(RTRIM(UPPER(a.Tipo)), ''),
          a.SerieLoteInfo,
          ISNULL(NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), 'NO'),
          RTRIM(UPPER(a.TipoCompra)),
          a.SeProduce,
          a.SeCompra,
          a.EsFormula,
          NULLIF(RTRIM(a.Unidad), ''),
          ISNULL(a.PrecioMinimo, 0.0),
          NULLIF(RTRIM(a.MonedaPrecio), ''),
          ISNULL(a.MargenMinimo, 0.0),
          NULLIF(RTRIM(a.MonedaCosto), ''),
          NULLIF(RTRIM(d.ProdSerieLote), ''),
          CONVERT(CHAR, NULL),
          CONVERT(INT, NULL),
          CONVERT(INT, NULL),
          CONVERT(CHAR, NULL),
          CONVERT(CHAR, NULL),
          d.Tipo,
          CONVERT(FLOAT, NULL),
          CONVERT(FLOAT, NULL),
          CONVERT(INT, NULL),
          CONVERT(DATETIME, NULL),
          a.Actividades,
          CONVERT(DATETIME, NULL),
          d.Paquete,
          0,
          CONVERT(FLOAT, NULL),
          NULLIF(RTRIM(d.Tarima), ''),
          ISNULL(NULLIF(RTRIM(a.NivelToleranciaCosto), ''), '(EMPRESA)'),
          ISNULL(a.ToleranciaCosto, 0),
          ISNULL(a.ToleranciaCostoInferior, 0),
          CONVERT(FLOAT, NULL),
          CONVERT(FLOAT, NULL),
          CONVERT(FLOAT, NULL),
          CONVERT(MONEY, NULL),
          0
        FROM
          InvD d
          JOIN Art a ON a.Articulo = d.Articulo
        WHERE
          d.ID = @ID
      ELSE
        IF @Modulo = 'PROD'
          DECLARE crVerificarDetalle CURSOR
          FOR
          SELECT
            NULL,
            d.AutoGenerado,
            d.Renglon,
            d.RenglonSub,
            d.RenglonID,
            d.RenglonTipo,
            ( ISNULL(d.Cantidad, 0.0) - ISNULL(d.CantidadCancelada, 0.0) ),
            CONVERT(FLOAT, NULL),
            d.CantidadInventario,
            ISNULL(d.CantidadReservada, 0.0),
            ISNULL(d.CantidadOrdenada, 0.0),
            ISNULL(d.CantidadPendiente, 0.0),
            ISNULL(d.CantidadA, 0.0),
            NULLIF(RTRIM(d.Unidad), ''),
            d.Factor,
            NULLIF(RTRIM(d.Articulo), ''),
            NULLIF(RTRIM(d.SubCuenta), ''),
            CONVERT(VARCHAR(20), NULL),
            CONVERT(VARCHAR(20), NULL),
            CONVERT(CHAR(20), NULL),
            CONVERT(CHAR(20), NULL),
            ISNULL(d.Costo, 0.0),
            CONVERT(MONEY, NULL),
            '$',
            CONVERT(MONEY, NULL),
            CONVERT(FLOAT, NULL),
            CONVERT(FLOAT, NULL),
            CONVERT(MONEY, NULL),
            NULLIF(RTRIM(d.Aplica), ''),
            d.AplicaID,
            NULLIF(RTRIM(d.Almacen), ''),
            NULLIF(RTRIM(UPPER(a.Tipo)), ''),
            a.SerieLoteInfo,
            ISNULL(NULLIF(RTRIM(UPPER(a.TipoOpcion)), ''), 'NO'),
            RTRIM(UPPER(a.TipoCompra)),
            a.SeProduce,
            a.SeCompra,
            a.EsFormula,
            NULLIF(RTRIM(a.Unidad), ''),
            ISNULL(a.PrecioMinimo, 0.0),
            NULLIF(RTRIM(a.MonedaPrecio), ''),
            ISNULL(a.MargenMinimo, 0.0),
            NULLIF(RTRIM(a.MonedaCosto), ''),
            NULLIF(RTRIM(d.ProdSerieLote), ''),
            NULLIF(RTRIM(d.Ruta), ''),
            d.Orden,
            d.OrdenDestino,
            NULLIF(RTRIM(d.Centro), ''),
            NULLIF(RTRIM(d.CentroDestino), ''),
            d.Tipo,
            CONVERT(FLOAT, NULL),
            CONVERT(FLOAT, NULL),
            CONVERT(INT, NULL),
            CONVERT(DATETIME, NULL),
            a.Actividades,
            CONVERT(DATETIME, NULL),
            d.Paquete,
            0,
            CONVERT(FLOAT, NULL),
            NULLIF(RTRIM(d.Tarima), ''),
            ISNULL(NULLIF(RTRIM(a.NivelToleranciaCosto), ''), '(EMPRESA)'),
            ISNULL(a.ToleranciaCosto, 0),
            ISNULL(a.ToleranciaCostoInferior, 0),
            CONVERT(FLOAT, NULL),
            CONVERT(FLOAT, NULL),
            CONVERT(FLOAT, NULL),
            CONVERT(MONEY, NULL),
            0
          FROM
            ProdD d
            JOIN Art a ON a.Articulo = d.Articulo
          WHERE
            d.ID = @ID
  SELECT
    @AfectarAlgo = 0,
    @SumaCantidadOriginal = 0,
    @SumaCantidadPendiente = 0,
    @SumaImporteNeto = 0.0,
    @SumaImpuestosNetos = 0.0,
    @SumaImporteNetoSinAutorizar = 0.0,
    @SumaImpuestosNetosSinAutorizar = 0.0,
    @SumaRetencionesNeto = 0.0
  IF @Ok IS NULL
    BEGIN
      OPEN crVerificarDetalle
      FETCH NEXT FROM crVerificarDetalle INTO @Seccion, @AutoGenerado, @Renglon, @RenglonSub, @RenglonID, @RenglonTipo,
        @CantidadOriginal, @CantidadObsequio, @CantidadInventario, @CantidadReservada, @CantidadOrdenada,
        @CantidadPendiente, @CantidadA, @MovUnidad, @Factor, @Articulo, @Subcuenta, @ArticuloDestino, @SubCuentaDestino,
        @SustitutoArticulo, @SustitutoSubcuenta, @Costo, @Precio, @DescuentoTipo, @DescuentoLinea, @Impuesto1,
        @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID, @AlmacenRenglon, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion,
        @ArtTipoCompra, @ArtSeProduce, @ArtSeCompra, @ArtEsFormula, @ArtUnidad, @ArtPrecioMinimo, @ArtMonedaVenta,
        @ArtMargenMinimo, @ArtMonedaCosto, @ProdSerieLote, @ProdRuta, @ProdOrden, @ProdOrdenDestino, @ProdCentro,
        @ProdCentroDestino, @DetalleTipo, @CantidadMinimaVenta, @CantidadMaximaVenta, @ArtCaducidadMinima,
        @FechaCaducidad, @ArtActividades, @FechaRequeridaD, @Paquete, @EsEstadistica, @PrecioTipoCambio, @Tarima,
        @ArtNivelToleranciaCosto, @ArtToleranciaCosto, @ArtToleranciaCostoInferior, @Retencion1, @Retencion2,
        @Retencion3, @Impuesto5, @AnticipoFacturado
      IF @@ERROR <> 0
        SELECT
          @Ok = 1
      WHILE @@FETCH_STATUS <> -1
        AND @Ok IS NULL
        BEGIN
          SELECT
            @SeriesLotesAutoOrden = ISNULL(NULLIF(NULLIF(RTRIM(UPPER(SeriesLotesAutoOrden)), ''), '(EMPRESA)'),
                                           @CfgSeriesLotesAutoOrden)
          FROM
            Art
          WHERE
            Articulo = @Articulo
          SELECT
            @SucursalAlmacenRenglon = Sucursal
          FROM
            Alm
          WHERE
            Almacen = @AlmacenRenglon
          IF @PPTO = 1
            AND @Accion <> 'CANCELAR'
            AND (
                  @Modulo = 'COMS'
                  OR (
                       @Modulo = 'VTAS'
                       AND @PPTOVentas = 1
                     )
                )
            IF (
                 SELECT
                  NULLIF(RTRIM(CuentaPresupuesto), '')
                 FROM
                  Art
                 WHERE
                  Articulo = @Articulo
               ) IS NULL
              BEGIN
                SELECT
                  @Ok = 40035,
                  @OkRef = @Articulo
                EXEC xpOk_40035 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
              END
          IF @ArtTipo NOT IN ( 'SERIE', 'LOTE' )
            AND @Modulo = 'COMS'
            AND @MovTipo IN ( 'COMS.F' )
            AND @Subclave IN ( 'COMS.SLC' )
            SELECT
              @Ok = 75540,
              @OkRef = @Articulo + ' ' + CASE WHEN NULLIF(@Subcuenta, '') IS NULL THEN ''
                                              ELSE '(' + @Subcuenta + ')'
                                         END
          IF @Ok IS NULL
            AND @SubCuentaExplotarInformacion = 1
            EXEC spMovOpcionVerificar @Modulo, @ID, @Renglon, @RenglonSub, @Subcuenta, @Ok OUTPUT, @OkRef OUTPUT
          SELECT
            @LotesFijos = LotesFijos
          FROM
            Art
          WHERE
            Articulo = @Articulo
          IF @ArtTipo = 'LOTE'
            AND @Modulo = 'COMS'
            AND @MovTipo = ( 'COMS.F' )
            AND @LotesFijos = 1
            AND @Ok IS NULL
            BEGIN
              IF (
                   SELECT
                    COUNT(Impuesto1)
                   FROM
                    (
                      SELECT
                        lf.Impuesto1
                      FROM
                        LoteFijo lf
                        JOIN SerieLoteMov slm ON slm.SerieLote = lf.Lote
                        JOIN CompraD d ON d.ID = slm.ID
                      WHERE
                        slm.Empresa = @Empresa
                        AND slm.Modulo = @Modulo
                        AND slm.ID = @ID
                        AND slm.Articulo = @Articulo
                        AND ISNULL(slm.Cantidad, 0) > 0
                      GROUP BY
                        lf.Impuesto1
                    ) a
                 ) > 1
                SELECT
                  @Ok = 1,
                  @OkRef = 20031
              IF (
                   SELECT
                    COUNT(Impuesto2)
                   FROM
                    (
                      SELECT
                        lf.Impuesto2
                      FROM
                        LoteFijo lf
                        JOIN SerieLoteMov slm ON slm.SerieLote = lf.Lote
                        JOIN CompraD d ON d.ID = slm.ID
                      WHERE
                        slm.Empresa = @Empresa
                        AND slm.Modulo = @Modulo
                        AND slm.ID = @ID
                        AND slm.Articulo = @Articulo
                        AND ISNULL(slm.Cantidad, 0) > 0
                      GROUP BY
                        lf.Impuesto2
                    ) a
                 ) > 1
                SELECT
                  @Ok = 20031,
                  @OkRef = 'Articulo: ' + @Articulo
            END
          SELECT
            @Importe = 0.0,
            @ImporteNeto = 0.0,
            @Impuestos = 0.0,
            @ImpuestosNetos = 0.0,
            @DescuentoLineaImporte = 0.0,
            @DescuentoGlobalImporte = 0.0,
            @SobrePrecioImporte = 0.0,
            @IDAplica = NULL,
            @AplicaAutorizacion = NULL,
            @AplicaCondicion = NULL,
            @AplicaMovTipo = NULL,
            @AplicaControlAnticipos = NULL
          IF @ValidarFechaRequerida = 1
            IF @FechaRequeridaD IS NULL
              SELECT
                @Ok = 25120
            ELSE


--Kike Sierra: 17/06/2013: Se Modifico la validacion para no considerar los movs de Oferta Servicio
--Condicion Original:      IF @FechaRequeridaD < @FechaEmision 
              IF (
                   @FechaRequeridaD < @FechaEmision
                   AND NOT (
                             @Modulo = 'VTAS'
                             AND @MovTipo IN ( 'VTAS.P', 'VTAS.C', 'VTAS.F', 'VTAS.VP' )
                           )
                 )
                SELECT
                  @Ok = 25121   

          IF @CfgCompraValidarArtProv = 1
            AND @Modulo = 'COMS'
            AND @MovTipo NOT IN ( 'COMS.R' )
            IF NOT EXISTS ( SELECT
                              *
                            FROM
                              ArtProv
                            WHERE
                              Articulo = @Articulo
                              AND ISNULL(NULLIF(RTRIM(SubCuenta), ''), '') = ISNULL(NULLIF(RTRIM(@Subcuenta), ''), '')
                              AND Proveedor = @ClienteProv )
              SELECT
                @Ok = 26040,
                @OkRef = RTRIM(@Articulo) + ' ' + RTRIM(@Subcuenta)
          IF @MovTipo = 'INV.EP'
            BEGIN
              EXEC spMovGastoIndirectoSugerir @Empresa, @Modulo, @ID
              IF @ArtSeProduce = 0
                OR @ArtTipo NOT IN ( 'SERIE', 'VIN', 'LOTE', 'PARTIDA' )
                SELECT
                  @Ok = 20076,
                  @OkRef = @Articulo
            END
          IF @ArtTipoOpcion IN ( 'NO', NULL )
            AND @Subcuenta IS NOT NULL
            SELECT
              @Ok = 20740,
              @OkRef = @Articulo
          EXEC xpOk_20740 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
          IF @AplicaMov IS NOT NULL
            AND @AplicaMovID IS NOT NULL
            BEGIN
              IF @Modulo = 'VTAS'
                SELECT
                  @IDAplica = ID,
                  @AplicaAutorizacion = NULLIF(RTRIM(Autorizacion), ''),
                  @AplicaCondicion = Condicion
                FROM
                  Venta
                WHERE
                  Empresa = @Empresa
                  AND Mov = @AplicaMov
                  AND MovID = @AplicaMovID
                  AND Estatus NOT IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO' )
              ELSE
                IF @Modulo = 'COMS'
                  SELECT
                    @IDAplica = ID,
                    @AplicaAutorizacion = NULLIF(RTRIM(Autorizacion), '')
                  FROM
                    Compra
                  WHERE
                    Empresa = @Empresa
                    AND Mov = @AplicaMov
                    AND MovID = @AplicaMovID
                    AND Estatus NOT IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO' )
                ELSE
                  IF @Modulo = 'INV'
                    SELECT
                      @IDAplica = ID,
                      @AplicaAutorizacion = NULLIF(RTRIM(Autorizacion), '')
                    FROM
                      Inv
                    WHERE
                      Empresa = @Empresa
                      AND Mov = @AplicaMov
                      AND MovID = @AplicaMovID
                      AND Estatus NOT IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO' )
                  ELSE
                    IF @Modulo = 'PROD'
                      SELECT
                        @IDAplica = ID,
                        @AplicaAutorizacion = NULLIF(RTRIM(Autorizacion), '')
                      FROM
                        Prod
                      WHERE
                        Empresa = @Empresa
                        AND Mov = @AplicaMov
                        AND MovID = @AplicaMovID
                        AND Estatus NOT IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO' )
              EXEC spAplicaOk @Empresa, @Usuario, @Modulo, @IDAplica, @Ok OUTPUT, @OkRef OUTPUT
              IF @AplicaAutorizacion IS NOT NULL
                AND @Autorizacion IS NULL
                AND @CfgAutoAutorizacionFacturas = 1
                SELECT
                  @Autorizacion = @AplicaAutorizacion
            END
          ELSE
            BEGIN
              IF @MovTipo = 'INV.DTI'
                AND @Accion <> 'GENERAR'
                SELECT
                  @Ok = 25410
            END
          IF @AplicaMov <> NULL
            BEGIN
              SELECT
                @AplicaMovTipo = NULL
              SELECT
                @AplicaMovTipo = MIN(Clave)
              FROM
                MovTipo
              WHERE
                Modulo = @Modulo
                AND Mov = @AplicaMov
              IF @Modulo = 'VTAS'
                AND @AplicaMovTipo IS NULL
                SELECT
                  @AplicaMovTipo = MIN(Clave)
                FROM
                  MovTipo
                WHERE
                  Modulo = 'CXC'
                  AND Mov = @AplicaMov
              ELSE
                IF @Modulo = 'COMS'
                  AND @AplicaMovTipo IS NULL
                  SELECT
                    @AplicaMovTipo = MIN(Clave)
                  FROM
                    MovTipo
                  WHERE
                    Modulo = 'CXP'
                    AND Mov = @AplicaMov
              IF @AplicaMovTipo IN ( 'VTAS.P', 'VTAS.S', 'VTAS.SD' )
                SELECT
                  @AplicaControlAnticipos = ISNULL(NULLIF(RTRIM(UPPER(ControlAnticipos)), ''), 'NO')
                FROM
                  Condicion
                WHERE
                  Condicion = @AplicaCondicion
            END
          IF @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', /*'VTAS.FX',*/ 'VTAS.FB' )
            AND @CfgBloquearFacturacionDirecta = 1
            AND @AplicaMovTipo IS NULL
            AND @Accion NOT IN ( 'GENERAR', 'CANCELAR' )
            SELECT
              @Ok = 25415
          IF @Ok = 25415
            AND @Articulo = (
                              SELECT
                                NULLIF(CxcAnticipoArticuloServicio, '')
                              FROM
                                EmpresaCfg2
                              WHERE
                                Empresa = @Empresa
                            )
            SELECT
              @Ok = NULL
          IF @MovTipo IN ( 'INV.S', 'INV.SI', 'INV.T', 'INV.P' )
            AND @CfgBloquearInvSalidaDirecta = 1
            AND @AplicaMovTipo IS NULL
            AND @Accion NOT IN ( 'GENERAR', 'CANCELAR' )
            AND @Conexion = 0
            SELECT
              @Ok = 25410
          IF @Accion <> 'GENERAR'
            BEGIN
              IF @Modulo = 'VTAS'
                AND @Accion <> 'CANCELAR'
                AND @MovTipo NOT IN ( 'VTAS.PR', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B', 'VTAS.CO', 'VTAS.VP' )
                BEGIN
                  IF @CantidadMinimaVenta IS NOT NULL
                    AND @CantidadOriginal < @CantidadMinimaVenta
                    SELECT
                      @Ok = 20011,
                      @OkRef = @Articulo
                  ELSE
                    IF @CantidadMaximaVenta IS NOT NULL
                      AND @CantidadOriginal > @CantidadMaximaVenta
                      SELECT
                        @Ok = 20013,
                        @OkRef = @Articulo
                END
              IF @CobrarPedido = 1
                BEGIN
                  IF @MovTipo IN ( 'VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.P', 'VTAS.SD', 'VTAS.B' )
                    BEGIN
                      IF @AplicaMovTipo IS NOT NULL
                        AND @AplicaControlAnticipos = 'COBRAR PEDIDO'
                        SELECT
                          @Ok = 20880
                    END
                  ELSE
                    IF @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FB', 'VTAS.VP', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC',
                                     'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM' )
                      BEGIN
                        IF @AplicaMovTipo NOT IN ( 'VTAS.P', 'VTAS.S', 'VTAS.SD' )
                          OR @AplicaControlAnticipos <> 'COBRAR PEDIDO'
                          SELECT
                            @Ok = 20880
                      END
                    ELSE
                      SELECT
                        @Ok = 20880
                END
              ELSE
                IF @AplicaControlAnticipos = 'COBRAR PEDIDO'
                  SELECT
                    @Ok = 20880
              IF @Ok = 20880
                EXEC xpOk_20880 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
            END
          IF @Modulo = 'PROD'
            AND @MovTipo <> 'PROD.O'
            AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
            AND @ProdSerieLote IS NOT NULL
            BEGIN
              SELECT
                @AplicaMovTipo = 'PROD.O',
                @AplicaMov = Mov,
                @AplicaMovID = MovID,
                @ProdRuta = Ruta
              FROM
                ProdSerieLotePendiente
              WHERE
                Empresa = @Empresa
                AND ProdSerieLote = @ProdSerieLote
                AND Articulo = @Articulo
                AND SubCuenta = @Subcuenta
              UPDATE
                ProdD
              SET
                Aplica = @AplicaMov,
                AplicaID = @AplicaMovID,
                Ruta = @ProdRuta
              WHERE CURRENT OF crVerificarDetalle
            END
          IF @AutoGenerado = 1
            AND @Accion = 'AFECTAR'
            SELECT
              @Ok = 60270
          IF @Utilizar = 1
            AND @Base <> 'TODO'
            SELECT
              @UtilizarEstatus = 'PENDIENTE'
          ELSE
            SELECT
              @UtilizarEstatus = @Estatus
          IF @ArtEsFormula = 1
            SELECT
              @Ok = 20750
          IF @Modulo = 'COMS'
            AND @CfgLimitarCompraLocal = 1
            AND (
                  @ArtSeCompra = 0
                  OR @ArtTipoCompra <> 'LOCAL'
                )
            SELECT
              @Ok = 20760
          IF @ArtTipoOpcion = 'SI'
            AND @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
            AND @Accion <> 'CANCELAR'
            AND @Ok IS NULL
            EXEC spOpcionValidar @Articulo, @Subcuenta, @Accion, @CfgOpcionBloquearDescontinuado,
              @CfgOpcionPermitirDescontinuado, @Ok OUTPUT, @OkRef OUTPUT 
          SELECT
            @Almacen = @AlmacenOriginal,
            @AlmacenDestino = @AlmacenDestinoOriginal
          IF @AfectarAlmacenRenglon = 1
            SELECT
              @Almacen = NULLIF(RTRIM(@AlmacenRenglon), '')
          IF @AlmacenEspecifico IS NOT NULL
            SELECT
              @Almacen = @AlmacenEspecifico
          IF @VoltearAlmacen = 1
            SELECT
              @AlmacenTemp = @Almacen,
              @Almacen = @AlmacenDestino,
              @AlmacenDestino = @AlmacenTemp
          IF @EsTransferencia = 0
            AND @MovTipo NOT IN ( 'INV.OT', 'INV.TI' )
            SELECT
              @AlmacenDestino = NULL
          IF @MovTipo = 'INV.EI'
            SELECT
              @AlmacenDestino = @AlmacenOriginal /** JH 28.07.2006 **/
          IF @Almacen IS NOT NULL
            BEGIN
              SELECT
                @AlmacenTipo = UPPER(Tipo),
                @AlmacenSucursal = Sucursal
              FROM
                Alm
              WHERE
                Almacen = @Almacen
              IF @AlmacenTipo = 'ESTRUCTURA'
                SELECT
                  @Ok = 20680,
                  @OkRef = @Almacen
              IF @CfgControlAlmacenes = 1
                AND @Accion <> 'CANCELAR'
                AND @MovTipo NOT IN ( 'INV.TI', 'INV.DTI' )
                IF NOT EXISTS ( SELECT
                                  *
                                FROM
                                  UsuarioAlm
                                WHERE
                                  Usuario = @Usuario
                                  AND Almacen = @Almacen )
                  SELECT
                    @Ok = 20660,
                    @OkRef = @Almacen
              IF @AlmacenSucursal <> ISNULL(@SucursalDestino, @Sucursal)
                AND @Accion <> 'SINCRO'
                AND @MovTipo NOT IN ( 'INV.TI', 'INV.DTI', 'INV.TIF', 'INV.TIS', 'VTAS.PR', 'COMS.PR', 'VTAS.EST',
                                      'COMS.EST' )
                AND @SeguimientoMatriz = 0
                BEGIN
                  EXEC spSucursalEnLinea @AlmacenSucursal, @EnLinea OUTPUT
                  IF @EnLinea = 0
                    SELECT
                      @Ok = 20780,
                      @OkRef = @Almacen
                END
            END
          IF @Tarima IS NOT NULL
            AND @Accion <> 'CANCELAR'
            IF EXISTS ( SELECT
                          *
                        FROM
                          ArtExistenciaTarima
                        WHERE
                          Empresa = @Empresa
                          AND Tarima = @Tarima
                          AND Almacen <> @Almacen
                          AND ROUND(ISNULL(Existencia, 0.0), 2) <> 0.0 )
              SELECT
                @Ok = 13090,
                @OkRef = @Tarima
          IF @AlmacenDestino IS NOT NULL
            AND @MovTipo <> 'INV.EI' /** JH 06.09.2006 **/
            BEGIN
              SELECT
                @AlmacenDestinoTipo = UPPER(Tipo),
                @AlmacenDestinoSucursal = Sucursal
              FROM
                Alm
              WHERE
                Almacen = @AlmacenDestino
              IF @AlmacenDestinoTipo = 'ESTRUCTURA'
                SELECT
                  @Ok = 20680,
                  @OkRef = @AlmacenDestino
              IF @CfgControlAlmacenes = 1
                AND @Accion <> 'CANCELAR'
                AND @MovTipo NOT IN ( 'INV.TI', 'INV.DTI' )
                IF NOT EXISTS ( SELECT
                                  *
                                FROM
                                  UsuarioAlm
                                WHERE
                                  Usuario = @Usuario
                                  AND Almacen = @AlmacenDestino )
                  SELECT
                    @Ok = 20660,
                    @OkRef = @AlmacenDestino
              IF @AlmacenDestinoSucursal <> ISNULL(@SucursalDestino, @Sucursal)
                AND @Accion NOT IN ( 'SINCRO', 'CANCELAR', 'GENERAR' )
                BEGIN
                  SELECT
                    @Ok = 20790,
                    @OkRef = @AlmacenDestino
                END
            END
          IF @BloquearFacturaOtraSucursal = 1
            AND @SucursalAcceso <> @SucursalAlmacenRenglon
            AND @Ok IS NULL
            AND @MovTipo IN ( 'VTAS.P', 'VTAS.F', 'VTAS.D', 'VTAS.VCR', 'VTAS.DCR', 'VTAS.DF', 'VTAS.B', 'VTAS.N',
                              'VTAS.FM', 'VTAS.NO', 'VTAS.NR', 'VTAS.FR' )
            AND @Accion IN ( 'AFECTAR', 'RESERVARPARCIAL', 'RESERVAR' )
            SELECT
              @Ok = 20785,
              @OkRef = RTRIM(LTRIM(@AlmacenRenglon)) + ' - ' + (
                                                                 SELECT
                                                                  ISNULL(Nombre, '')
                                                                 FROM
                                                                  Sucursal
                                                                 WHERE
                                                                  Sucursal = @SucursalAlmacenRenglon
                                                               )
          IF @Accion IN ( 'AFECTAR', 'VERIFICAR' )
            AND @MovTipo = 'INV.EI'
            AND @Almacen <> @AlmacenDestinoOriginal
            SELECT
              @Ok = 20120
          IF @Accion IN ( 'AFECTAR', 'VERIFICAR' )
            AND @MovTipo = 'INV.EI'
            AND @AplicaMovTipo <> 'INV.TI'
            SELECT
              @Ok = 25410
          IF @Accion IN ( 'AFECTAR', 'VERIFICAR' )
            AND @MovTipo IN ( 'PROD.A', 'PROD.R', 'PROD.E' )
            AND @AplicaMovTipo <> 'PROD.O'
            AND UPPER(@DetalleTipo) NOT IN ( 'MERMA', 'DESPERDICIO' )
            SELECT
              @Ok = 25280
          IF @Accion = 'AFECTAR'
            AND @MovTipo = 'VTAS.VP'
            AND @AplicaMovTipo NOT IN ( NULL, 'VTAS.P', 'VTAS.S' )
            SELECT
              @Ok = 20197
          IF @Accion = 'AFECTAR'
            AND @MovTipo IN ( 'INV.TIF', 'INV.TIS' )
            AND @AplicaMovTipo <> 'INV.TI'
            SELECT
              @Ok = 20180
          IF @EsTransferencia = 1
            AND @Accion <> 'GENERAR'
            AND @Ok IS NULL
            BEGIN
              IF @AlmacenDestino = @Almacen
                OR @AlmacenDestino IS NULL
                SELECT
                  @Ok = 20120
              ELSE
                IF @AlmacenTipo <> @AlmacenDestinoTipo
                  AND NOT (
                            @AlmacenTipo IN ( 'NORMAL', 'PROCESO' )
                            AND @AlmacenDestinoTipo IN ( 'NORMAL', 'PROCESO' )
                          )
                  IF (
                       @AlmacenTipo IN ( 'NORMAL', 'PROCESO', 'GARANTIAS' )
                       OR @AlmacenDestinoTipo IN ( 'NORMAL', 'PROCESO', 'GARANTIAS' )
                     )
                    BEGIN
                      IF @CfgInvPrestamosGarantias = 0
                        OR @MovTipo NOT IN ( 'INV.P', 'INV.R' )
                        SELECT
                          @Ok = 40130
                    END
                  ELSE
                    SELECT
                      @Ok = 40130
            END
          IF @Modulo = 'VTAS'
            AND @ServicioGarantia = 1
            AND (
                  @AlmacenTipo <> 'GARANTIAS'
                  OR @MovTipo NOT IN ( 'VTAS.S', 'VTAS.SG', 'VTAS.EG' )
                )
            AND @Ok IS NULL
            SELECT
              @Ok = 20440
          IF @ArtActividades = 1
            AND @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.FB' )
            AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
            AND @CantidadOriginal > 0.0
            IF EXISTS ( SELECT
                          *
                        FROM
                          VentaDAgente
                        WHERE
                          ID = @ID
                          AND Renglon = @Renglon
                          AND RenglonSub = @RenglonSub
                          AND UPPER(Estado) NOT IN ( 'COMPLETADA', 'CANCELADA', 'CONCLUIDA' ) )
              SELECT
                @Ok = 20496
          EXEC spInvInitRenglon @Empresa, @CfgDecimalesCantidades, @CfgMultiUnidades, @CfgMultiUnidadesNivel,
            @CfgCompraFactorDinamico, @CfgInvFactorDinamico, @CfgProdFactorDinamico, @CfgVentaFactorDinamico,
            @CfgBloquearNotasNegativas, 1, 0, @Accion, @Base, @Modulo, @ID, @Renglon, @RenglonSub, @UtilizarEstatus,
            @EstatusNuevo, @MovTipo, @FacturarVtasMostrador, @EsTransferencia, @AfectarConsignacion, 0, @AlmacenTipo,
            @AlmacenDestinoTipo, @Articulo, @MovUnidad, @ArtUnidad, @ArtTipo, @RenglonTipo, @AplicaMovTipo,
            @CantidadOriginal, @CantidadInventario, @CantidadPendiente, @CantidadA, @DetalleTipo, @Cantidad OUTPUT,
            @CantidadCalcularImporte OUTPUT, @CantidadReservada OUTPUT, @CantidadOrdenada OUTPUT, @EsEntrada OUTPUT,
            @EsSalida OUTPUT, @Subcuenta OUTPUT, @AfectarPiezas OUTPUT, @AfectarCostos OUTPUT, @AfectarUnidades OUTPUT,
            @Factor OUTPUT, @Ok OUTPUT, @OkRef OUTPUT, @Seccion = @Seccion
          IF @AplicaMovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.FB' )
            SELECT
              @Ok = 20180
          ELSE
            IF @Almacen IS NULL
              AND @Accion <> 'GENERAR'
              SELECT
                @Ok = 20390
            ELSE
              IF @Articulo IS NULL
                AND (
                      @CfgCompraPresupuestosCategoria = 0
                      OR @MovTipo <> 'COMS.PR'
                    )
                SELECT
                  @Ok = 20400
              ELSE
                IF @Cantidad = 0.0
                  AND @Base = 'TODO'
                  AND @AutoCorrida IS NULL
                  AND @MovTipo NOT IN ( 'INV.IF', 'COMS.OP' )
                  SELECT
                    @Ok = 20015
                ELSE
                  IF @Cantidad = 0.0
                    AND @Base = 'TODO'
                    AND @AutoCorrida IS NULL
                    AND @MovTipo = 'COMS.OP'
                    SELECT
                      @Ok = 20021
                  ELSE
                    IF @Cantidad < 0.0
                      AND @ArtTipo <> 'SERVICIO'
                      AND @FacturarVtasMostrador = 0
                      AND @Accion <> 'CANCELAR'
                      AND @MovTipo NOT IN ( 'VTAS.EST', 'INV.EST' )
                      SELECT
                        @Ok = 20010
                    ELSE
                      IF @Accion = 'CANCELAR'
                        AND @Base = 'SELECCION'
                        AND ROUND(@Cantidad, 4) > ROUND(@CantidadPendiente + @CantidadReservada, 4)
                        SELECT
                          @Ok = 20010
          IF @CfgMultiUnidades = 1
            AND @MovUnidad IS NULL
            AND @Accion <> 'CANCELAR'
            SELECT
              @Ok = 20150
          ELSE
            IF @AplicaMov IS NOT NULL
              AND @FacturarVtasMostrador = 1
              SELECT
                @Ok = 20102
            ELSE
              IF @Accion IN ( 'RESERVAR', 'ASIGNAR' )
                AND @Cantidad > @CantidadPendiente
                SELECT
                  @Ok = 20160
              ELSE
                IF @Accion = 'DESRESERVAR'
                  AND @Cantidad > @CantidadReservada
                  SELECT
                    @Ok = 20165
                ELSE
                  IF @Accion = 'DESASIGNAR'
                    AND @Cantidad > @CantidadOrdenada
                    SELECT
                      @Ok = 20167
          IF @FacturarVtasMostrador = 1
            AND (
                  @AplicaMov IS NOT NULL
                  OR @AplicaMovID IS NOT NULL
                )
            SELECT
              @Ok = 20180
          IF @ArtTipo = 'PARTIDA'
            AND @ArtTipoOpcion = 'MATRIZ'
            IF NOT EXISTS ( SELECT
                              *
                            FROM
                              ArtRenglon
                            WHERE
                              Renglon = @Subcuenta )
              SELECT
                @Ok = 20045
/** JH 06.09.2006 **/
          IF (
               (
                 @Modulo = 'PROD'
                 OR ( @MovTipo IN ( 'INV.SM', 'INV.CM' ) )
               )
               AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
               AND @OrigenTipo <> 'INV/EP'
             )
            BEGIN
              IF @MovTipo IN ( 'PROD.O', 'PROD.A', 'PROD.R' )
                AND @ProdRuta IS NULL
                SELECT
                  @Ok = 25300 
              IF @MovTipo = 'PROD.E'
                BEGIN
                  IF @ProdCentro IS NULL /*OR @ProdOrden IS NULL */ SELECT
                                                                      @Ok = 25040
                  ELSE
                    BEGIN
                      EXEC spProdUltimoCentro @Empresa, @Articulo, @Subcuenta, @ProdSerieLote, @ProdRuta,
                        @ProdOrdenFinal OUTPUT
                      IF @ProdOrden IS NULL
                        SELECT
                          @ProdOrden = @ProdOrdenFinal  
                      IF @ProdOrden <> @ProdOrdenFinal
                        SELECT
                          @Ok = 25350,
                          @OkRef = @ProdCentro
                    END
                END
              IF @MovTipo IN ( 'PROD.A', 'PROD.R' )
                BEGIN
                  IF @ProdCentro IS NULL
                    OR @ProdOrden IS NULL
                    SELECT
                      @Ok = 25040
                  ELSE
                    IF ( @ProdCentroDestino IS NULL )
                      OR ( @ProdCentro = @ProdCentroDestino )
                      SELECT
                        @Ok = 25330
                    ELSE
                      BEGIN
                        EXEC spProdAvanceAlCentro @Empresa, @MovTipo, @Articulo, @Subcuenta, @ProdSerieLote, @ProdRuta,
                          @ProdOrden, @ProdOrdenSiguiente OUTPUT, @ProdCentro, @ProdCentroSiguiente OUTPUT,
                          @ProdEstacion, @ProdEstacionDestino OUTPUT, @Verificar = 1
                        IF @ProdCentroDestino <> @ProdCentroSiguiente
                          SELECT
                            @Ok = 25340,
                            @OkRef = @ProdCentroDestino
                      END
                  IF @Ok IS NULL
                    IF NOT EXISTS ( SELECT
                                      *
                                    FROM
                                      ProdSerieLotePendiente
                                    WHERE
                                      Empresa = @Empresa
                                      AND ProdSerieLote = @ProdSerieLote
                                      AND Articulo = @Articulo
                                      AND SubCuenta = @Subcuenta
                                      AND Orden = @ProdOrden
                                      AND Centro = @ProdCentro )
                      SELECT
                        @Ok = 25350,
                        @OkRef = @ProdCentro
                END
              IF @ProdSerieLote IS NULL
                IF @MovTipo IN ( 'INV.SM', 'INV.CM' )
                  AND @Subclave <> 'INV.SAUX'
                  OR @MovTipo NOT IN ( 'INV.SM', 'INV.CM' )
                  SELECT
                    @Ok = 25230 
                ELSE
                  IF EXISTS ( SELECT
                                *
                              FROM
                                SerieLoteMov
                              WHERE
                                Empresa = @Empresa
                                AND Modulo = @Modulo
                                AND ID = @ID
                                AND RenglonID = @RenglonID
                                AND Articulo = @Articulo
                                AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                                AND SerieLote = @ProdSerieLote )
                    SELECT
                      @Ok = 25240
              IF @MovTipo = 'INV.CM'
                AND @Subclave <> 'INV.SAUX'
                AND NOT EXISTS ( SELECT
                                  *
                                 FROM
                                  ProdSerieLotePendiente
                                 WHERE
                                  Empresa = @Empresa
                                  AND ProdSerieLote = @ProdSerieLote )
                SELECT
                  @Ok = 25250,
                  @OkRef = @ProdSerieLote
              IF @Ok IS NULL
                BEGIN
                  IF @MovTipo = 'PROD.O'
                    BEGIN
                      IF EXISTS ( SELECT
                                    *
                                  FROM
                                    ProdSerieLotePendiente
                                  WHERE
                                    Empresa = @Empresa
                                    AND ProdSerieLote = @ProdSerieLote
                                    AND CantidadPendiente > 0.0
                                    AND ID <> @ID )
                        SELECT
                          @Ok = 25245
                    END
                  ELSE
                    BEGIN
                      IF NOT EXISTS ( SELECT
                                        *
                                      FROM
                                        ProdSerieLote
                                      WHERE
                                        Empresa = @Empresa
                                        AND ProdSerieLote = @ProdSerieLote
                                        AND CantidadOrdenada > 0.0 )
                        IF @MovTipo IN ( 'INV.SM', 'INV.CM' )
                          AND @Subclave <> 'INV.SAUX'
                          OR @MovTipo NOT IN ( 'INV.SM', 'INV.CM' )
                          SELECT
                            @Ok = 25250
                    END
                END
              IF @Ok IS NULL
                AND @CfgProdSerieLoteDesdeOrden = 1
                AND @MovTipo IN ( 'PROD.A', 'PROD.R', 'PROD.E' )
                AND @Accion <> 'CANCELAR'
                BEGIN
                  SELECT
                    @ProdOrdenID = NULL
                  SELECT
                    @ProdOrdenID = MIN(ID)
                  FROM
                    ProdSerieLotePendiente
                  WHERE
                    Empresa = @Empresa
                    AND ProdSerieLote = @ProdSerieLote
                    AND Articulo = @Articulo
                    AND SubCuenta = @Subcuenta
                  SELECT
                    @OkRef = NULL
                  SELECT
                    @OkRef = MIN(SerieLote)
                  FROM
                    SerieLoteMov
                  WHERE
                    Empresa = @Empresa
                    AND Modulo = @Modulo
                    AND ID = @ID
                    AND RenglonID = @RenglonID
                    AND Articulo = @Articulo
                    AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                    AND SerieLote NOT IN ( SELECT
                                            SerieLote
                                           FROM
                                            SerieLoteMov
                                           WHERE
                                            Empresa = @Empresa
                                            AND Modulo = @Modulo
                                            AND ID = @ProdOrdenID
                                            AND Articulo = @Articulo
                                            AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '') )
                  IF @OkRef IS NOT NULL
                    SELECT
                      @Ok = 20093
                END
/*IF @Ok IS NULL
BEGIN
SELECT @ProdOrdenID = NULL
SELECT @ProdOrdenID = MIN(ID) FROM ProdSerieLotePendiente WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote
IF @ProdOrdenID IS NULL
BEGIN
IF @MovTipo <> 'PROD.O' SELECT @Ok = 25250
END ELSE
BEGIN
IF @MovTipo = 'PROD.O'
SELECT @Ok = 25240
ELSE
BEGIN
IF @Modulo = 'PROD' UPDATE ProdD SET OPID = @ProdOrdenID WHERE CURRENT OF crVerificarDetalle ELSE
IF @Modulo = 'INV'  UPDATE InvD  SET OPID = @ProdOrdenID WHERE CURRENT OF crVerificarDetalle
END
END
END
IF @MovTipo IN ('INV.SM', 'INV.CM') AND @Ok IS NULL
BEGIN
IF NOT EXISTS(SELECT * FROM ProdSerieLoteMaterialPendiente WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote AND Articulo = @Articulo AND SubCuenta = @SubCuenta)
SELECT @Ok = 25260
END*/
              IF @Ok IS NOT NULL
                AND @OkRef IS NULL
                SELECT
                  @OkRef = @ProdSerieLote
            END
          IF @MovTipo = 'INV.CM'
            AND @Accion = 'CANCELAR'
            AND NOT EXISTS ( SELECT
                              *
                             FROM
                              ProdSerieLotePendiente
                             WHERE
                              Empresa = @Empresa
                              AND ProdSerieLote = @ProdSerieLote )
            SELECT
              @Ok = 25256,
              @OkRef = @ProdSerieLote
          IF @MovTipo = 'PROD.O'
            AND @Accion = 'CANCELAR'
            AND @Ok IS NULL
            IF ROUND((
                       SELECT
                        SUM(ISNULL(Cargo, 0.0) - ISNULL(Abono, 0.0))
                       FROM
                        ProdSerieLoteCosto
                       WHERE
                        Empresa = @Empresa
                        AND ProdSerieLote = @ProdSerieLote
                     ), @RedondeoMonetarios) <> 0.0
              SELECT
                @Ok = 25370,
                @OkRef = @ProdSerieLote
          IF @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
            AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
            AND @OrigenTipo <> 'VMOS'
            BEGIN
              IF @RenglonTipo = 'J'
                EXEC spInvValidarJuego @Empresa, @Modulo, @ID, @Almacen, @RenglonID, @Articulo, @Cantidad, @Ok OUTPUT,
                  @OkRef OUTPUT
              IF @RenglonTipo IN ( 'C', 'E' )
                BEGIN
                  IF @Modulo = 'VTAS'
                    IF NOT EXISTS ( SELECT
                                      *
                                    FROM
                                      VentaD
                                    WHERE
                                      ID = @ID
                                      AND RenglonID = @RenglonID
                                      AND RenglonTipo = 'J' )
                      SELECT
                        @Ok = 20620
                    ELSE
                      IF @Modulo = 'COMS'
                        IF NOT EXISTS ( SELECT
                                          *
                                        FROM
                                          CompraD
                                        WHERE
                                          ID = @ID
                                          AND RenglonID = @RenglonID
                                          AND RenglonTipo = 'J' )
                          SELECT
                            @Ok = 20620
                        ELSE
                          IF @Modulo = 'INV'
                            IF NOT EXISTS ( SELECT
                                              *
                                            FROM
                                              InvD
                                            WHERE
                                              ID = @ID
                                              AND RenglonID = @RenglonID
                                              AND RenglonTipo = 'J' )
                              SELECT
                                @Ok = 20620
                            ELSE
                              IF @Modulo = 'PROD'
                                IF NOT EXISTS ( SELECT
                                                  *
                                                FROM
                                                  ProdD
                                                WHERE
                                                  ID = @ID
                                                  AND RenglonID = @RenglonID
                                                  AND RenglonTipo = 'J' )
                                  SELECT
                                    @Ok = 20620
                END
              IF @Ok = 20620
                EXEC xpOk_20620 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Renglon, @RenglonSub, @Ok OUTPUT,
                  @OkRef OUTPUT
            END
          IF @@FETCH_STATUS <> -2
            AND @Cantidad <> 0.0
            AND @Ok IS NULL
            BEGIN
              IF @AlmacenTipo = 'ACTIVOS FIJOS'
                AND (
                      @CfgCompraPresupuestosCategoria = 0
                      AND @MovTipo <> 'COMS.PR'
                    )
                BEGIN
                  SELECT
                    @CategoriaActivoFijo = NULL
                  SELECT
                    @CategoriaActivoFijo = NULLIF(RTRIM(CategoriaActivoFijo), '')
                  FROM
                    Art
                  WHERE
                    Articulo = @Articulo
                  IF (
                       @ArtTipo NOT IN ( 'SERIE', 'VIN' )
                       OR @CfgSeriesLotesMayoreo = 0
                     )
                    SELECT
                      @Ok = 44010
                  ELSE
                    IF @CategoriaActivoFijo IS NULL
                      SELECT
                        @Ok = 44110
                    ELSE
                      IF @Modulo IN ( 'VTAS', 'COMS' )
                        AND (
                              SELECT
                                UPPER(Propietario)
                              FROM
                                ActivoFCat
                              WHERE
                                Categoria = @CategoriaActivoFijo
                            ) <> 'EMPRESA'
                        SELECT
                          @Ok = 44180
                END
              IF @Modulo IN ( 'VTAS', 'COMS' )
                BEGIN
                  EXEC spCalculaImporte @Accion, @Modulo, @CfgImpInc, @MovTipo, @EsEntrada, @CantidadCalcularImporte,
                    @Precio, @DescuentoTipo, @DescuentoLinea, @DescuentoGlobal, @SobrePrecio, @Impuesto1, @Impuesto2,
                    @Impuesto3, @Impuesto5, @Importe OUTPUT, @ImporteNeto OUTPUT, @DescuentoLineaImporte OUTPUT,
                    @DescuentoGlobalImporte OUTPUT, @SobrePrecioImporte OUTPUT, @Impuestos OUTPUT,
                    @ImpuestosNetos OUTPUT, @Articulo = @Articulo, @CantidadObsequio = @CantidadObsequio,
                    @CfgPrecioMoneda = @CfgPrecioMoneda, @MovTipoCambio = @MovTipoCambio,
                    @PrecioTipoCambio = @PrecioTipoCambio, @Retencion1 = @Retencion1, @Retencion2 = @Retencion2,
                    @Retencion3 = @Retencion3, @ID = @ID, @AnticipoFacturado = @AnticipoFacturado,
                    @Retencion1Neto = @Retencion1Neto OUTPUT, @Retencion2Neto = @Retencion2Neto OUTPUT,
                    @Retencion3Neto = @Retencion3Neto OUTPUT, @RetencionesNeto = @RetencionesNeto OUTPUT 
                  IF @Modulo = 'VTAS'
                    AND ROUND(ISNULL(@Precio, 0.0), 0) < 0.0
                    AND @AutoCorrida IS NULL
                    SELECT
                      @Ok = 20305
                  IF @Modulo = 'COMS'
                    SELECT
                      @Costo = @ImporteNeto / @Cantidad
                  IF @@ERROR <> 0
                    SELECT
                      @Ok = 1
                END
              IF (
                   (
                     @AfectarCostos = 1
                     AND @EsEntrada = 1
                     AND @Accion NOT IN ( 'GENERAR', 'CANCELAR' )
                   )
                   OR (
                        @MovTipo = 'COMS.O'
                        AND @Accion IN ( 'AFECTAR', 'VERIFICAR' )
                        AND @CfgValidarOrdenCompraTolerancia = 1
                      )
                 )
                AND @CfgToleranciaTipoCosto IN ( 'PROMEDIO', 'ESTANDAR', 'ULTIMO COSTO' )
                AND (
                      (
                        @Autorizacion IS NULL
                        OR @Mensaje NOT IN ( 20600, 20610 )
                      )
                      AND @Ok IS NULL
                    )
                BEGIN
                  SELECT
                    @ArtCosto = NULL
                  IF @CfgCosteoNivelSubCuenta = 1
                    AND NULLIF(RTRIM(@Subcuenta), '') IS NOT NULL
                    BEGIN
                      IF @CfgToleranciaTipoCosto = 'ULTIMO COSTO'
                        SELECT
                          @ArtCosto = UltimoCosto
                        FROM
                          ArtSubCosto
                        WHERE
                          Sucursal = @Sucursal
                          AND Empresa = @Empresa
                          AND Articulo = @Articulo
                          AND SubCuenta = @Subcuenta
                      ELSE
                        IF @CfgToleranciaTipoCosto = 'PROMEDIO'
                          SELECT
                            @ArtCosto = CostoPromedio
                          FROM
                            ArtSubCosto
                          WHERE
                            Sucursal = @Sucursal
                            AND Empresa = @Empresa
                            AND Articulo = @Articulo
                            AND SubCuenta = @Subcuenta
                        ELSE
                          IF @CfgToleranciaTipoCosto = 'ESTANDAR'
                            SELECT
                              @ArtCosto = CostoEstandar
                            FROM
                              Art
                            WHERE
                              Articulo = @Articulo
                          ELSE
                            IF @CfgToleranciaTipoCosto = 'REPOSICION'
                              SELECT
                                @ArtCosto = CostoReposicion
                              FROM
                                Art
                              WHERE
                                Articulo = @Articulo
                    END
                  ELSE
                    BEGIN
                      IF @CfgToleranciaTipoCosto = 'ULTIMO COSTO'
                        SELECT
                          @ArtCosto = UltimoCosto
                        FROM
                          ArtCosto
                        WHERE
                          Sucursal = @Sucursal
                          AND Empresa = @Empresa
                          AND Articulo = @Articulo
                      ELSE
                        IF @CfgToleranciaTipoCosto = 'PROMEDIO'
                          SELECT
                            @ArtCosto = CostoPromedio
                          FROM
                            ArtCosto
                          WHERE
                            Sucursal = @Sucursal
                            AND Empresa = @Empresa
                            AND Articulo = @Articulo
                        ELSE
                          IF @CfgToleranciaTipoCosto = 'ESTANDAR'
                            SELECT
                              @ArtCosto = CostoEstandar
                            FROM
                              Art
                            WHERE
                              Articulo = @Articulo
                          ELSE
                            IF @CfgToleranciaTipoCosto = 'REPOSICION'
                              SELECT
                                @ArtCosto = CostoReposicion
                              FROM
                                Art
                              WHERE
                                Articulo = @Articulo
                    END
                  IF @ArtCosto IS NOT NULL
                    BEGIN
                      EXEC spMoneda NULL, @MovMoneda, @MovTipoCambio, @ArtMonedaCosto, @ArtFactorCosto OUTPUT,
                        @ArtTipoCambioCosto OUTPUT, @Ok OUTPUT
                      SELECT
                        @ArtCosto = @ArtCosto * @ArtFactorCosto
                      IF @ArtNivelToleranciaCosto = 'ARTICULO'
                        SELECT
                          @CfgToleranciaCostoInferior = ISNULL(@ArtToleranciaCostoInferior, 0),
                          @CfgToleranciaCosto = ISNULL(@ArtToleranciaCosto, 0)
                      SELECT
                        @Minimo = @ArtCosto * ( 1 - ( @CfgToleranciaCostoInferior / 100 ) ),
                        @Maximo = @ArtCosto * ( 1 + ( @CfgToleranciaCosto / 100 ) )




                      IF @Costo / @Factor < @Minimo													
/*PST EBG 08/04/2014 Para omitir la validacion de Costos en Refacturacion*/
                        AND @Refacturado = 0
/****************************/
                        BEGIN
                          SELECT
                            @Ok = 20600
                          EXEC xpOk_20600 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Renglon, @RenglonSub, @Ok OUTPUT,
                            @OkRef OUTPUT
                        END
                      ELSE
                        IF @Costo / @Factor > @Maximo
/*PST EBG 08/04/2014 Para omitir la validacion de Costos en Refacturacion*/
                          AND @Refacturado = 0
/****************************/
                          BEGIN
                            SELECT
                              @Ok = 20610
                            EXEC xpOk_20610 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Renglon, @RenglonSub, @Ok OUTPUT,
                              @OkRef OUTPUT
                          END
                      IF @Ok IS NOT NULL
                        SELECT
                          @Autorizar = 1 
                    END
                END
              IF @CfgValidarPrecios <> 'NO'
                AND @FacturarVtasMostrador = 0
                AND @MovTipo IN ( 'VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.S', 'VTAS.R', 'VTAS.F', 'VTAS.FAR', 'VTAS.FC',
                                  'VTAS.FB', 'VTAS.VC', 'VTAS.VCR', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM' )
                AND @RenglonTipo NOT IN ( 'C', 'E' )
                AND @AlmacenTipo <> 'GARANTIAS'
                AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
                AND (
                      @Autorizacion IS NULL
                      OR @Mensaje NOT IN ( 65010, 65020, 65040, 20310 )
                    )
                AND @Ok IS NULL
                BEGIN
                  IF @CfgPrecioMinimoSucursal = 1
                    SELECT
                      @ArtPrecioMinimo = ISNULL(PrecioMinimo, @ArtPrecioMinimo)
                    FROM
                      ArtSucursal
                    WHERE
                      Articulo = @Articulo
                      AND Sucursal = @AlmacenSucursal
                  SELECT
                    @PrecioUnitarioNeto = ABS(( @ImporteNeto / @Cantidad ) / @Factor),
                    @ArtCosto = NULL




                  IF @CfgValidarPrecios = 'PRECIO MINIMO'
                    BEGIN
                      EXEC spMoneda NULL, @MovMoneda, @MovTipoCambio, @ArtMonedaVenta, @ArtFactorVenta OUTPUT,
                        @ArtTipoCambioVenta OUTPUT, @Ok OUTPUT
/* Modificacion en validacion de error 20310 para evitarlo al reservar-desreservar. Judith Ramirez 08-Feb-2013. */  
                      IF ROUND(@PrecioUnitarioNeto, 2) < ROUND(@ArtPrecioMinimo * @ArtFactorVenta, @RedondeoMonetarios)
                        AND @Accion NOT IN ( 'DESRESERVAR', 'RESERVAR' )
                        SELECT
                          @Ok = 20310 --Kike Prueba  


                    END
                  IF @CfgValidarPrecios IN ( 'ULTIMO COSTO', 'COSTO PROMEDIO', 'COSTO ESTANDAR', 'COSTO REPOSICION' )
                    AND @ArtTipo NOT IN ( 'JUEGO', 'SERVICIO' )
                    SELECT
                      @CfgValidarMargenMinimo = @CfgValidarPrecios,
                      @CfgValidarPrecios = 'MARGEN MINIMO',
                      @ArtMargenMinimoBorrar = 1
                  ELSE
                    SELECT
                      @CfgValidarPrecios = @CfgValidarPreciosAux
                  IF @ArtMargenMinimoBorrar = 1
                    SELECT
                      @ArtMargenMinimo = 0.0
                  IF @CfgValidarPrecios = 'MARGEN MINIMO'
                    AND @CfgValidarMargenMinimo <> 'NO'
                    BEGIN
                      SELECT
                        @CostoEstandar = ISNULL(CostoEstandar, 0),
                        @CostoReposicion = ISNULL(CostoReposicion, 0)
                      FROM
                        Art
                      WHERE
                        Articulo = @Articulo
                      IF @CfgCosteoNivelSubCuenta = 1
                        AND NULLIF(RTRIM(@Subcuenta), '') IS NOT NULL
                        SELECT
                          @UltimoCosto = ISNULL(UltimoCosto, 0),
                          @CostoPromedio = ISNULL(CostoPromedio, 0)
                        FROM
                          ArtSubCosto
                        WHERE
                          Sucursal = @Sucursal
                          AND Empresa = @Empresa
                          AND Articulo = @Articulo
                          AND SubCuenta = @Subcuenta
                      ELSE
                        SELECT
                          @UltimoCosto = ISNULL(UltimoCosto, 0),
                          @CostoPromedio = ISNULL(CostoPromedio, 0)
                        FROM
                          ArtCosto
                        WHERE
                          Sucursal = @Sucursal
                          AND Empresa = @Empresa
                          AND Articulo = @Articulo
                      IF @CfgValidarMargenMinimo = 'ULTIMO COSTO'
                        SELECT
                          @ArtCosto = @UltimoCosto
                      ELSE
                        IF @CfgValidarMargenMinimo = 'COSTO PROMEDIO'
                          SELECT
                            @ArtCosto = @CostoPromedio
                        ELSE
                          IF @CfgValidarMargenMinimo = 'COSTO ESTANDAR'
                            SELECT
                              @ArtCosto = @CostoEstandar
                          ELSE
                            IF @CfgValidarMargenMinimo = 'COSTO REPOSICION'
                              SELECT
                                @ArtCosto = @CostoReposicion
                            ELSE
                              IF @CfgValidarMargenMinimo = '(MAYOR COSTO)'
                                BEGIN
                                  SELECT
                                    @ArtCosto = @UltimoCosto
                                  IF @CostoPromedio > @ArtCosto
                                    SELECT
                                      @ArtCosto = @CostoPromedio
                                  ELSE
                                    IF @CostoEstandar > @ArtCosto
                                      SELECT
                                        @ArtCosto = @CostoEstandar
                                    ELSE
                                      IF @CostoReposicion > @ArtCosto
                                        SELECT
                                          @ArtCosto = @CostoReposicion
                                END

                      IF @ArtCosto IS NOT NULL
                        BEGIN
                          EXEC spMoneda NULL, @MovMoneda, @MovTipoCambio, @ArtMonedaCosto, @ArtFactorCosto OUTPUT,
                            @ArtTipoCambioCosto OUTPUT, @Ok OUTPUT
                          SELECT
                            @ArtCosto = @ArtCosto * @ArtFactorCosto
/* Modificacion en validacion de error 20310 para evitarlo al reservar-desreservar. Judith Ramirez 08-Feb-2013. */  
                          IF ROUND(@PrecioUnitarioNeto - ( @PrecioUnitarioNeto * ( @ArtMargenMinimo / 100 ) ),
                                   @RedondeoMonetarios) < ROUND(@ArtCosto, @RedondeoMonetarios)
                            AND @Accion NOT IN ( 'DESRESERVAR', 'RESERVAR' )
                            SELECT
                              @Ok = 20310
		--, @OkRef = 'PrecioUnitarioNeto: ' + CAST(@PrecioUnitarioNeto AS varchar) 
    	--+ '<BR>'  + 'ArtMargenMinimo: ' + CAST(@ArtMargenMinimo AS varchar ) 
	    --+ '<BR>'  + 'RedondeosMonetarios: ' + CAST(@RedondeoMonetarios AS varchar ) 
		--+ '<BR>'  + 'ArtCosto: ' + CAST(@ArtCosto AS VARCHAR)
		--+ '<BR>'  + 'Valor1: ' + CAST(ROUND(@PrecioUnitarioNeto  - ( @PrecioUnitarioNeto * ( @ArtMargenMinimo   / 100 ) ),@RedondeoMonetarios) AS varchar ) 
		--   + '<BR>'  + 'ArtCosto con Round 2: ' + CAST( ROUND(@ArtCosto,  @RedondeoMonetarios) AS varchar ) 
		--    +  '<BR>'  + 'CfgValidarPrecios: ' + @CfgValidarPrecios  -- Kike Prueba : Original : 20310  
                        END
                    END
                  IF @Ok = 20310
                    IF EXISTS ( SELECT
                                  *
                                FROM
                                  Cte
                                WHERE
                                  Cliente = @ClienteProv
                                  AND PreciosInferioresMinimo = 1 )
                      SELECT
                        @Ok = NULL
                  EXEC xpValidarPrecios @Empresa, @Modulo, @ID, @Accion, @Articulo, @Subcuenta, @CfgValidarPrecios,
                    @Ok OUTPUT, @OkRef OUTPUT
                  IF @Ok IS NOT NULL
                    SELECT
                      @Autorizar = 1
                END
              IF (
                   @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
                   OR @Accion IN ( 'RESERVAR', 'CANCELAR' )
                 )
                AND @Ok IS NULL
                AND (
                      @Generar = 0
                      OR @MovTipo = 'INV.IF'
                    )
                AND (
                      @Utilizar = 0
                      OR (
                           @Utilizar = 1
                           AND @MovTipo IN ( 'VTAS.R', 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.FB',
                                             'VTAS.SG', 'VTAS.EG', 'VTAS.VC', 'VTAS.VCR', 'COMS.F', 'COMS.FL', 'COMS.EG',
                                             'COMS.EI', 'COMS.IG', 'COMS.CC' )
                           AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
                         )
                    )
                BEGIN
                  SELECT
                    @AplicaOrdenado = 0.0,
                    @AplicaPendiente = 0.0,
                    @AplicaReservada = 0.0
                  IF @AfectarMatando = 1
                    AND @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
                    AND @Ok IS NULL
                    BEGIN
                      IF @Utilizar = 0
                        BEGIN
                          IF ( @AplicaMov IS NULL )
                            OR ( NULLIF(RTRIM(@AplicaMovID), '') IS NULL )
                            BEGIN
                              IF @AfectarMatandoOpcional = 0
                                SELECT
                                  @Ok = 20170					
                            END
                          ELSE
                            BEGIN
                              IF @SustitutoArticulo IS NOT NULL
                                AND @Articulo <> @SustitutoArticulo
                                SELECT
                                  @ArticuloMatar = @SustitutoArticulo
                              ELSE
                                SELECT
                                  @ArticuloMatar = @Articulo
                              IF @SustitutoSubcuenta IS NOT NULL
                                AND @Subcuenta <> @SustitutoSubcuenta
                                SELECT
                                  @SubCuentaMatar = @SustitutoSubcuenta
                              ELSE
                                SELECT
                                  @SubCuentaMatar = @Subcuenta
                              EXEC spInvPendiente @ID, @Modulo, @Empresa, @MovTipo, @Almacen, @AlmacenDestino,
                                @AplicaMov, @AplicaMovID, @AplicaMovTipo, @ArticuloMatar, @SubCuentaMatar, @MovUnidad,
                                @AplicaOrdenado OUTPUT, @AplicaPendiente OUTPUT, @AplicaReservada OUTPUT,
                                @AplicaClienteProv OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
                              IF @Ok IS NULL
                                BEGIN
                                  IF ROUND(@CantidadCalcularImporte, 4) > ROUND(@AplicaPendiente + @AplicaReservada, 4)
                                    BEGIN
                                      SELECT
                                        @ExcendeteDemas = ROUND(( ( ( ROUND(@CantidadCalcularImporte, 4)
                                                                      + @AplicaOrdenado - ROUND(@AplicaPendiente
                                                                                                + @AplicaReservada, 4) )
                                                                    / @AplicaOrdenado ) - 1 ) * 100, 4)
                                      IF (
                                           @AplicaMovTipo IN ( 'VTAS.P', 'VTAS.S' )
                                           AND @CfgVentaSurtirDemas = 1
                                         )
                                        OR (
                                             @AplicaMovTipo IN ( 'CXC.CA', 'CXC.CAP' )
                                             AND @Modulo = 'VTAS'
                                           )
                                        OR (
                                             @AplicaMovTipo IN ( 'COMS.R' )
                                             AND @CfgCompraRecibirDemas = 1
                                           )
                                        OR (
                                             @AplicaMovTipo IN ( 'COMS.O', 'COMS.OP', 'COMS.OG', 'COMS.OI' )
                                             AND (
                                                   @CfgCompraRecibirDemas = 1
                                                   AND (
                                                         @CfgCompraRecibirDemasTolerancia IS NULL
                                                         OR @ExcendeteDemas <= @CfgCompraRecibirDemasTolerancia
                                                       )
                                                 )
                                           )
                                        OR (
                                             @AplicaMovTipo IN ( 'INV.OT', 'INV.OI' )
                                             AND @CfgTransferirDemas = 1
                                           )
                                        OR (
                                             @AplicaMovTipo = 'INV.SM'
                                             AND @MovTipo = 'INV.CM'
                                           ) /*OR
(@AplicaMovTipo = 'PROD.O')*/
                                        SELECT
                                          @Ok = NULL
                                      ELSE
                                        BEGIN
                                          SELECT 
                      /*@Ok = 20184,  -- Kike Sierra @Ok = 20180 ,    
                      @OkRef = 'Kike Datos Prueba: <BR>ExcendeteDemas= ' + CONVERT(VARCHAR, ISNULL(@ExcendeteDemas,0.00))     
                      + ' <BR>@aplicaMovTipo  = ' +  @AplicaMovTipo    
                       + ' <BR>@CfgCompraRecibirDemas = ' + CONVERT(VARCHAR, ISNULL(@CfgCompraRecibirDemas,0.00))    
                      + ' <BR>CfgComprarecibirDemasTolerancia = ' + CONVERT(VARCHAR, ISNULL(@CfgCompraRecibirDemasTolerancia,0.00))    
                      + ' <BR>@CantidadCalcularImporte = ' + CONVERT(VARCHAR, ISNULL(@CantidadCalcularImporte,0.00))    
                      + ' <BR>@AplicaPendiente = ' + CONVERT(VARCHAR, ISNULL(@AplicaPendiente,0.00))    
                      + ' <BR>@AplicaReservada = ' + CONVERT(VARCHAR, ISNULL(@AplicaReservada,0.00))    
                      + '<BR><BR>'*/
                                            @Ok = 20180,
                                            @OkRef = 'Articulo: ' + RTRIM(@Articulo) + '<BR><BR>Ordenado: '
                                            + CONVERT(VARCHAR, @AplicaOrdenado) + '<BR>Pendiente: '
                                            + CONVERT(VARCHAR, ( @AplicaPendiente + @AplicaReservada ))
                                            + '<BR><BR>Aplicar: ' + CONVERT(VARCHAR, @Cantidad) + '<BR>Excedente: '
                                            + CONVERT(VARCHAR, @ExcendeteDemas) + '%'  



                                          IF @MovTipo = 'PROD.E'
                                            AND UPPER(@DetalleTipo) = 'EXCEDENTE'
                                            SELECT
                                              @Ok = NULL,
                                              @OkRef = NULL
                                        END





                                    END
                                  ELSE
                                    IF @ClienteProv <> @AplicaClienteProv
                                      AND NULLIF(RTRIM(@AplicaClienteProv), '') IS NOT NULL
                                      BEGIN
                                        IF @Modulo = 'VTAS'
                                          BEGIN
                                            IF NOT EXISTS ( SELECT
                                                              *
                                                            FROM
                                                              CteRelacion
                                                            WHERE
                                                              (
                                                                Cliente = @ClienteProv
                                                                AND Relacion = @AplicaClienteProv
                                                              )
                                                              OR (
                                                                   Cliente = @AplicaClienteProv
                                                                   AND Relacion = @ClienteProv
                                                                 ) )
                                              SELECT
                                                @Ok = 20191
                                          END
                                        ELSE
                                          IF @Modulo = 'COMS'
                                            AND @MovTipo <> 'COMS.EI'
                                            BEGIN
                                              IF NOT EXISTS ( SELECT
                                                                *
                                                              FROM
                                                                ProvRelacion
                                                              WHERE
                                                                (
                                                                  Proveedor = @ClienteProv
                                                                  AND Relacion = @AplicaClienteProv
                                                                )
                                                                OR (
                                                                     Proveedor = @AplicaClienteProv
                                                                     AND Relacion = @ClienteProv
                                                                   ) )
                                                SELECT
                                                  @Ok = 20192
                                            END
                                          ELSE
                                            IF @Modulo IN ( 'INV', 'PROD' )
                                              SELECT
                                                @Ok = 20190
                                        IF @Ok IS NOT NULL
                                          SELECT
                                            @OkRef = @AplicaClienteProv
                                      END
                                END
                            END
                        END
                      ELSE
                        IF @UtilizarMovTipo IN ( 'VTAS.P', 'VTAS.S', 'INV.SOL', 'INV.OT', 'INV.OI', 'INV.SM' )
                          SELECT
                            @AplicaReservada = @CantidadReservada
                    END
                  IF @MovTipo = 'INV.CP'
                    AND @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
                    BEGIN
                      IF @ArticuloDestino IS NULL
                        SELECT
                          @Ok = 20220
                      ELSE
                        IF @Articulo = @ArticuloDestino
                          AND ISNULL(@Subcuenta, '') = ISNULL(@SubCuentaDestino, '')
                          SELECT
                            @Ok = 20250
                        ELSE
                          IF @ArtTipo NOT IN ( 'NORMAL', 'SERIE', 'VIN', 'LOTE', 'PARTIDA' ) /*OR @ArtTipoOpcion <> 'NO' */ SELECT
                                                                                                        @Ok = 20235
                          ELSE
                            IF @ArtTipo <> (
                                             SELECT
                                              Tipo
                                             FROM
                                              Art
                                             WHERE
                                              Articulo = @ArticuloDestino
                                           )
                              SELECT
                                @Ok = 20236
                            ELSE
                              IF NULLIF(@SubCuentaDestino, '') IS NOT NULL
                                EXEC spOpcionValidar @ArticuloDestino, @SubCuentaDestino, @Accion,
                                  @CfgOpcionBloquearDescontinuado, @CfgOpcionPermitirDescontinuado, @Ok OUTPUT,
                                  @OkRef OUTPUT 
                    END
                  IF @MovTipo = 'INV.CP'
                    AND @Accion = 'CANCELAR'
                    AND ISNULL(@AfectarAlmacen, '') <> ''
                    BEGIN
                      EXEC spArtDisponible @Empresa, @AfectarAlmacen, @Articulo, @AfectarConsignacion,
                        @AfectarAlmacenTipo, @Factor, @Disponible OUTPUT, @Ok OUTPUT, @Tarima = @Tarima
                      IF ROUND(@Disponible, 4) < ROUND(@Cantidad, 4)
                        SELECT
                          @Ok = 20020
                    END
                  SELECT
                    @AfectarAlmacen = @Almacen,
                    @AfectarAlmacenTipo = @AlmacenTipo
                  IF (
                       @EsSalida = 1
                       OR @EsTransferencia = 1
                       OR @Accion = 'RESERVAR'
                     )
                    AND @ArtTipo NOT IN ( 'JUEGO', 'SERVICIO' )
                    AND @FacturarVtasMostrador = 0
                    AND @Ok IS NULL
                    BEGIN
                      IF (
                           @AplicaMovTipo = 'VTAS.R'
                           AND @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX' )
                         )
                        SELECT
                          @Ok = @Ok
                      ELSE
                        BEGIN
                          SELECT
                            @ValidarDisponible = ~@NoValidarDisponible
                          IF @Subcuenta IS NULL
                            BEGIN
                              IF @ArtTipoOpcion = 'MATRIZ'
                                SELECT
                                  @Ok = 20070 
/*IF @ValidarDisponible = 0 AND @MovTipo = 'VTAS.FM' AND @ArtTipo IN ('SERIE','LOTE','VIN','PARTIDA')
SELECT @ValidarDisponible = 1*/
                              IF @Cantidad > @AplicaReservada
                                AND @ValidarDisponible = 1
                                BEGIN
                                  EXEC spArtDisponible @Empresa, @AfectarAlmacen, @Articulo, @AfectarConsignacion,
                                    @AfectarAlmacenTipo, @Factor, @Disponible OUTPUT, @Ok OUTPUT, @Tarima = @Tarima
                                  SELECT
                                    @Disponible = @Disponible + @AplicaReservada
                                  IF ROUND(@Disponible, 4) < ROUND(@Cantidad, 4)
                                    SELECT
                                      @Ok = 20020              	   
                                END
                            END
                          ELSE
                            BEGIN
                              IF @Cantidad > @AplicaReservada
                                AND @ValidarDisponible = 1
                                BEGIN
                                  EXEC spArtSubDisponible @Empresa, @AfectarAlmacen, @Articulo, @ArtTipo, @Subcuenta,
                                    @AfectarConsignacion, @AfectarAlmacenTipo, @Factor, @Disponible OUTPUT, @Ok OUTPUT,
                                    @Tarima = @Tarima
                                  SELECT
                                    @Disponible = @Disponible + @AplicaReservada
                                  IF ROUND(@Disponible, 4) = 0.0
                                  BEGIN
                                    IF @ArtTipoOpcion <> 'NO'
                                      SELECT
                                        @Ok = 20040   
                                    ELSE
                                      SELECT
                                        @Ok = 20020
                              
                                  END
                                  ELSE IF ROUND(@Disponible, 4) < ROUND(@Cantidad, 4)
                                    SELECT
                                      @Ok = 20020

                                  -- Kike Sierra 2017-02-08: Procedimiento almacenado encargado de extender la validacion
                                  -- sobre el error 20040 ( "No existe disponible esa opcion" )
                                  IF @Ok = 20040
                                  BEGIN
                                    EXEC CUP_SPP_20040
                                      @Empresa,
                                      @Usuario,
                                      @Accion,
                                      @Estatus,
                                      @Modulo,
                                      @ID,
                                      @Mov,
                                      @MovTipo,
                                      @Articulo,
                                      @Subcuenta,
                                      @Renglon,
                                      @RenglonSub,
                                      @RenglonID,
                                      @RenglonTipo,
                                      @Ok OUTPUT,
                                      @OkRef OUTPUT
                                  END
                                END
                            END
                          IF @Cantidad > @AplicaReservada
                            AND @ValidarDisponible = 1
                            BEGIN
                              IF NOT EXISTS ( SELECT
                                                *
                                              FROM
                                                #ValidarDisponible
                                              WHERE
                                                Articulo = @Articulo
                                                AND Subcuenta = @Subcuenta
                                                AND Almacen = @AfectarAlmacen )
                                INSERT  #ValidarDisponible
                                        (
                                          Articulo,
                                          Subcuenta,
                                          Cantidad,
                                          Disponible,
                                          Almacen
                                        )
                                VALUES
                                        (
                                          @Articulo,
                                          @Subcuenta,
                                          @Cantidad,
                                          @Disponible,
                                          @AfectarAlmacen
                                        ) 
                              ELSE
                                UPDATE
                                  #ValidarDisponible
                                SET
                                  Cantidad = Cantidad + @Cantidad
                                WHERE
                                  Articulo = @Articulo
                                  AND Subcuenta = @Subcuenta
                                  AND Almacen = @AfectarAlmacen 
                              IF ROUND((
                                         SELECT
                                          Disponible - Cantidad
                                         FROM
                                          #ValidarDisponible
                                         WHERE
                                          Articulo = @Articulo
                                          AND Subcuenta = @Subcuenta
                                          AND Almacen = @AfectarAlmacen
                                       ), 4) < 0 
-- Kike :05/01/2015: SE modifico el OKREf  para hacerlo mas claro.
                                SELECT
                                  @Ok = 20020,
                                  @OkRef = 'La Cantidad Indicada excede al disponbile: ' + '<BR>' + 'Articulo: '
                                  + @Articulo + '  ' + 'Subcuenta: ' + ISNULL(@Subcuenta, '') + '<BR>' + 'Disponible: '
                                  + CONVERT(VARCHAR, CAST(Disponible AS DECIMAL(30, 8))) + '<BR>' + 'Cantidad: '
                                  + CONVERT(VARCHAR, CAST(Cantidad AS DECIMAL(30, 8)))
                                FROM
                                  #ValidarDisponible
                                WHERE
                                  Articulo = @Articulo
                                  AND Subcuenta = @Subcuenta
                                  AND Almacen = @AfectarAlmacen
--
                            END
                        END
                    END

                  IF @MovTipo IN ( 'COMS.B', 'COMS.CA', 'COMS.GX' )
                  AND @AfectarCostos = 1
                  AND @Costo = 0.0
                  AND @ArtTipo NOT IN ( 'JUEGO', 'SERVICIO' )
                    SELECT
                      @Ok = 20100		

                  IF @EsTransferencia = 1
                    SELECT
                      @AfectarAlmacen = @AlmacenDestino,
                      @AfectarAlmacenTipo = @AlmacenDestinoTipo

                  IF (
                       @EsEntrada = 1
                       OR @EsTransferencia = 1
                       OR @MovTipo = 'COMS.O'
                     )
                  AND @EsSalida = 0
                  AND @Ok IS NULL
                  AND @EstatusNuevo <> 'BORRADOR'
                  BEGIN
                    IF @AfectarPiezas = 1
                    BEGIN
                      IF @Costo <> 0.0
                        SELECT
                          @Ok = 20140  								
                    END ELSE IF (
                      @AfectarCostos = 1
                      OR @MovTipo = 'COMS.O'
                    )
                    AND @AlmacenTipo <> 'GARANTIAS'
                    AND @Accion <> 'CANCELAR'
                    AND @ArtTipo NOT IN ( 'JUEGO', 'SERVICIO' )
                    BEGIN
                      IF @Costo = 0.0
                      AND @MovTipo NOT IN ( 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM', 'PROD.E', 'INV.CM' )
                      AND @CfgInvEntradasSinCosto = 0
                        SELECT
                          @Ok = 20100
                      ELSE
                        IF @Costo < 0.0
                          AND @MovTipo <> 'INV.TC'
                          SELECT
                            @Ok = 20101									
                    END

                  -- Kike Sierra 2017-02-07: Procedimiento almacenado encargado de extender la validacion
                  -- sobre el error 20100 ( "Falta Indicar el Costo" )
                  IF @Ok = 20100
                  BEGIN
                    EXEC CUP_SPP_20100
                      @Empresa,
                      @Usuario,
                      @Accion,
                      @Estatus,
                      @Modulo,
                      @ID,
                      @Mov,
                      @MovTipo,
                      @Articulo,
                      @Subcuenta,
                      @Renglon,
                      @RenglonSub,
                      @RenglonID,
                      @RenglonTipo,
                      @Ok OUTPUT,
                      @OkRef OUTPUT
                  END
              END
                  IF (
                       @EsEntrada = 1
                       OR @EsTransferencia = 1
                     )
                    AND @EsSalida = 0
                    AND @Ok IS NULL
                    BEGIN
                      IF @Subcuenta IS NULL
                        AND @ArtTipoOpcion = 'MATRIZ'
                        SELECT
                          @Ok = 20070 
                    END
                  IF @MovTipo IN ( 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B' )
                    AND @ArtTipo NOT IN ( 'JUEGO', 'SERVICIO' )
                    BEGIN
                      IF @CfgVentaDevSinAntecedente = 0
                        BEGIN
                          IF NOT EXISTS ( SELECT
                                            *
                                          FROM
                                            Venta e,
                                            VentaD d,
                                            MovTipo mt
                                          WHERE
                                            e.ID = d.ID
                                            AND e.Empresa = @Empresa
                                            AND e.Cliente = @ClienteProv
                                            AND e.Estatus NOT IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO' )
                                            AND mt.Modulo = 'VTAS'
                                            AND mt.Mov = e.Mov
                                            AND mt.Clave IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.N', 'VTAS.NO', 'VTAS.NR',
                                                              'VTAS.FM', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX' )
                                            AND d.Articulo = @Articulo
                                            AND ISNULL(d.SubCuenta, '') = ISNULL(@Subcuenta, '') )
                            BEGIN
                              SELECT
                                @Ok = 20670,
                                @OkRef = @Articulo
                              EXEC xpOk_20670 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Renglon, @RenglonSub,
                                @Ok OUTPUT, @OkRef OUTPUT
                            END
                        END
                      IF @ArtTipo IN ( 'SERIE', 'LOTE', 'VIN', 'PARTIDA' )
                        AND @Ok IS NULL
                        BEGIN
                          IF @CfgVentaDevSeriesSinAntecedente = 0
                            BEGIN
                              SELECT
                                @OkRef = NULL
                              SELECT
                                @OkRef = MIN(SerieLote)
                              FROM
                                SerieLoteMov
                              WHERE
                                ID = @ID
                                AND SerieLote NOT IN (
                                SELECT
                                  SerieLote
                                FROM
                                  SerieLoteMov
                                WHERE
                                  ID IN (
                                  SELECT
                                    e.ID
                                  FROM
                                    Venta e,
                                    VentaD d,
                                    MovTipo mt
                                  WHERE
                                    e.ID = d.ID
                                    AND e.Empresa = @Empresa
                                    AND e.Cliente = @ClienteProv
                                    AND e.Estatus NOT IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR', 'CANCELADO' )
                                    AND mt.Modulo = 'VTAS'
                                    AND mt.Mov = e.Mov
                                    AND mt.Clave IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM',
                                                      'VTAS.FC', 'VTAS.FG', 'VTAS.FX' )
                                    AND d.Articulo = @Articulo
                                    AND ISNULL(d.SubCuenta, '') = ISNULL(@Subcuenta, '') ) )
                              IF @OkRef IS NOT NULL
                                SELECT
                                  @Ok = 20670,
                                  @OkRef = RTRIM(@Articulo) + ' / ' + RTRIM(@OkRef)
                            END
                        END
                    END
                  IF @MovTipo = 'INV.IF'
                    BEGIN
                      IF EXISTS ( SELECT
                                    *
                                  FROM
                                    InvD
                                  WHERE
                                    ID = @ID
                                    AND Articulo = @Articulo
                                    AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                                    AND (
                                          Renglon <> @Renglon
                                          OR RenglonSub <> @RenglonSub
                                        ) )
                        SELECT
                          @Ok = 10245,
                          @OkRef = @Articulo
                      IF @Subcuenta IS NULL
                        AND @ArtTipoOpcion = 'MATRIZ'
                        SELECT
                          @Ok = 20070 
                    END
                  IF @Estatus NOT IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
                    AND @CobroIntegrado = 1
                    AND @OrigenTipo <> 'VMOS'
                    AND @Ok IS NULL
                    BEGIN
                      DECLARE crVerificarSaldoTarjeta CURSOR
                      FOR
                      SELECT
                        Serie,
                        SUM(ISNULL(Cargo, 0))
                      FROM
                        AuxiliarValeSerie
                      WHERE
                        Modulo = @Modulo
                        AND ModuloID = @ID
                        AND ISNULL(Cargo, 0) > 0
                      GROUP BY
                        Serie
                      OPEN crVerificarSaldoTarjeta
                      FETCH NEXT FROM crVerificarSaldoTarjeta INTO @Tarjeta, @PuntosTarjeta
                      WHILE @@FETCH_STATUS = 0
                        BEGIN
                          SELECT
                            @Saldo = NULL
                          SELECT
                            @Saldo = dbo.fnVerSaldoVale(@Tarjeta)
                          IF @Saldo < @PuntosTarjeta
                            SELECT
                              @Ok = 30096
                          FETCH NEXT FROM crVerificarSaldoTarjeta INTO @Tarjeta, @PuntosTarjeta
                        END
                      CLOSE crVerificarSaldoTarjeta
                      DEALLOCATE crVerificarSaldoTarjeta
                    END
                  IF @MovTipo IN ( 'INV.EI', 'INV.DTI', 'INV.TIF', 'INV.TIS' )
                    AND @ArtTipo IN ( 'SERIE', 'LOTE' )
                    AND @Accion IN ( 'VERIFICAR', 'AFECTAR' )
                    BEGIN
                      DELETE FROM
                        #SerieLoteTransito
                      INSERT  #SerieLoteTransito
                              (
                                Modulo,
                                ModuloID,
                                Articulo,
                                SubCuenta,
                                SerieLote,
                                Cantidad
                              )
                      SELECT
                        i.Modulo,
                        i.ID,
                        i.Articulo,
                        i.SubCuenta,
                        i.SerieLote,
                        ISNULL(i.Cantidad, 0)
                      FROM
                        SerieLoteMov i
                      WHERE
                        i.Modulo = 'INV'
                        AND i.ID = @IDAplica
                      INSERT  #SerieLoteTransito
                              (
                                Modulo,
                                ModuloID,
                                Articulo,
                                SubCuenta,
                                SerieLote,
                                Cantidad
                              )
                      SELECT
                        i.Modulo,
                        i.ID,
                        i.Articulo,
                        i.SubCuenta,
                        i.SerieLote,
                        ISNULL(i.Cantidad, 0) * -1
                      FROM
                        SerieLoteMov i
                        JOIN MovFlujo mf ON i.ID = mf.DID
                                            AND i.Modulo = mf.DModulo
                                            AND mf.Cancelado = 0
                        JOIN MovTipo mt ON mf.DModulo = mt.Modulo
                                           AND mf.DMov = mt.Mov
                      WHERE
                        mt.Clave IN ( 'INV.EI', 'INV.DTI', 'INV.TIF', 'INV.TIS' )
                        AND mf.OID = @IDAplica
                      INSERT  #SerieLoteTransito
                              (
                                Modulo,
                                ModuloID,
                                Articulo,
                                SubCuenta,
                                SerieLote,
                                Cantidad
                              )
                      SELECT
                        i.Modulo,
                        i.ID,
                        i.Articulo,
                        i.SubCuenta,
                        i.SerieLote,
                        ISNULL(i.Cantidad, 0) * -1
                      FROM
                        SerieLoteMov i
                      WHERE
                        i.Modulo = 'INV'
                        AND i.ID = @ID
                      IF EXISTS ( SELECT
                                    SerieLote
                                  FROM
                                    #SerieLoteTransito
                                  WHERE
                                    Modulo = @Modulo
                                    AND Articulo = @Articulo
                                    AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                                  GROUP BY
                                    Modulo,
                                    Articulo,
                                    SubCuenta,
                                    SerieLote
                                  HAVING
                                    SUM(Cantidad) < 0 )
                        BEGIN
                          SELECT
                            @Ok = 20052
                          SELECT TOP 1
                            @OkRef = ' APLICACION: ' + RTRIM(@AplicaMov) + ' ' + RTRIM(@AplicaMovID) + ' - SERIE/LOTE: '
                            + MAX(SerieLote)
                          FROM
                            #SerieLoteTransito
                          WHERE
                            Modulo = @Modulo
                            AND Articulo = @Articulo
                            AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                          GROUP BY
                            Modulo,
                            Articulo,
                            SubCuenta,
                            SerieLote
                          HAVING
                            SUM(Cantidad) < 0
                        END
                    END
                END
              ELSE
                BEGIN
                  IF @AfectarPiezas = 0
                    AND @MovTipo <> 'INV.IF'
                    AND @Ok IS NULL
                    AND @Estatus = 'PENDIENTE'
                    BEGIN
                      IF @Base = 'SELECCION'
                        AND @Cantidad > @CantidadPendiente + @CantidadReservada
                        AND @Accion <> 'DESASIGNAR'
                        BEGIN
                          IF @Utilizar = 1
                            AND (
                                  (
                                    @UtilizarMovTipo IN ( 'VTAS.P', 'VTAS.S' )
                                    AND @CfgVentaSurtirDemas = 1
                                  )
                                  OR (
                                       @UtilizarMovTipo IN ( 'COMS.O', 'COMS.OP', 'COMS.OG', 'COMS.OI' )
                                       AND @CfgCompraRecibirDemas = 1
                                     )
                                  OR (
                                       @UtilizarMovTipo IN ( 'INV.OT', 'INV.OI' )
                                       AND @CfgTransferirDemas = 1
                                     )
                                  OR @UtilizarMovTipo IN ( 'INV.SM' )
                                )
                            SELECT
                              @Ok = NULL
                          ELSE
                            SELECT
                              @Ok = 20160
                        END
                      ELSE
                        IF @Base = 'SELECCION'
                          AND @Accion = 'RESERVAR'
                          AND @Cantidad > @CantidadPendiente
                          SELECT
                            @Ok = 20160								   	
                        ELSE
                          IF @Base = 'RESERVADO'
                            AND @Accion <> 'GENERAR'
                            AND @Cantidad > @CantidadReservada
                            SELECT
                              @Ok = 20165
                          ELSE
                            IF @Base = 'ORDENADO'
                              AND @Cantidad > @CantidadOrdenada
                              SELECT
                                @Ok = 20167
                    END
                END


					----Kike Prueba
					--select 
					--	@okref =  'AplicaMovTipo: '  + @AplicaMovtipo
					--			+  '<BR>' + 'ArtTipo: ' + @ArtTipo
					--			+  '<BR>' + '@Generar: ' + CAST(@Generar as VARCHAR)
					--			+  '<BR>' + '@MovTipo: ' + @MovTipo
					--			+  '<BR>' + 'Utilizar: ' + CAST(@Utilizar as VARCHAR)
					--			+  '<BR>' + '@CfgSeriesLotesMayoreo: ' + CAST(@CfgSeriesLotesMayoreo as VARCHAR)
					--			+  '<BR>' + 'EsEntrada: ' + CAST(@EsEntrada as VARCHAR)
					--			+  '<BR>' + '@EsSalida: ' + CAST(@EsSalida as VARCHAR)
					--			+  '<BR>' + '@EsTransferencia: ' + CAST(@EsTransferencia as VARCHAR)
					--			+  '<BR>' + '@OK: ' + CAST(@Ok as Varchar),
					--	@ok = 99999 
					----Kike Prueba
            				        
            				        
              IF @ArtTipo IN ( 'SERIE', 'VIN', 'LOTE', 'PARTIDA' )
                AND @Generar = 0
                AND @Utilizar = 0
                AND @CfgSeriesLotesMayoreo = 1
                AND @Ok IS NULL
                AND @MovTipo IN ( 'COMS.CC', 'COMS.CE/GT', 'COMS.D', 'COMS.DC', 'COMS.DG', 'COMS.EG', 'COMS.EI',
                                  'COMS.F', 'COMS.FL', 'COMS.IG', 'INV.A', 'INV.CM', 'INV.CP', 'INV.DTI', 'INV.E',
                                  'INV.EI', 'INV.EP', 'INV.P', 'INV.R', 'INV.S', 'INV.SI', 'INV.T', 'INV.TG', 'INV.TI',
                                  'INV.TIF', 'INV.TIS', 'VTAS.D', 'VTAS.DC', 'VTAS.DCR', 'VTAS.F', 'VTAS.FA', 'VTAS.FB',
                                  'VTAS.FC', 'VTAS.FG', 'VTAS.FM', 'VTAS.FPR', 'VTAS.FR', 'VTAS.FX', 'VTAS.N', 'VTAS.NO',
                                  'VTAS.NR', 'VTAS.SG', 'VTAS.VC', 'VTAS.VCR', 'VTAS.P', 'VTAS.EG', 'PROD.E' )
                BEGIN
                  IF @ArtTipo = 'SERIE'
                    AND EXISTS ( SELECT
                                  *
                                 FROM
                                  SerieLoteMov
                                 WHERE
                                  Empresa = @Empresa
                                  AND Modulo = @Modulo
                                  AND ID = @ID
                                  AND Articulo = @Articulo
                                  AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                                 GROUP BY
                                  Empresa,
                                  Modulo,
                                  ID,
                                  Articulo,
                                  SubCuenta,
                                  SerieLote
                                 HAVING
                                  COUNT(SerieLote) > 1 )
                    SELECT
                      @Ok = 20054 --El Número de Serie se encuentra duplicado en este Movimiento
		
                  IF ROUND(ABS(@Cantidad * @Factor), @CfgDecimalesCantidades) <> ROUND((
                                                                                         SELECT
                                                                                          ISNULL(SUM(ABS(Cantidad)), 0.0)
                                                                                         FROM
                                                                                          SerieLoteMov
                                                                                         WHERE
                                                                                          Empresa = @Empresa
                                                                                          AND Modulo = @Modulo
                                                                                          AND ID = @ID
                                                                                          AND Articulo = @Articulo
                                                                                          AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta,
                                                                                                        '')
                                                                                          AND RenglonID = @RenglonID
                                                                                       ), @CfgDecimalesCantidades)
                    BEGIN
                      IF NOT EXISTS ( SELECT
                                        *
                                      FROM
                                        SerieLoteMov
                                      WHERE
                                        Empresa = @Empresa
                                        AND Modulo = @Modulo
                                        AND ID = @ID
                                        AND Articulo = @Articulo
                                        AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                                        AND RenglonID = @RenglonID )
                        BEGIN
                          IF (
                               @EsEntrada = 1
                               OR @MovTipo IN (/*'INV.IF',*/ 'COMS.B', 'COMS.CA', 'COMS.GX', 'VTAS.CO'/** JH 31.10.2006 **/,
                                                             'INV.CP' /**/)
                               OR @SeriesLotesAutoOrden = 'NO'
                             )
                            AND (
                                  @ArtSerieLoteInfo = 0
                                  OR (
                                       @EsSalida = 1
                                       AND @Accion <> 'CANCELAR'
                                     )
                                )
                            AND @Ok IS NULL
                            AND @EsEstadistica = 0
                            AND @AplicaMovTipo <> 'COMS.CC'  /** JH 13.2.2007 **/
                            BEGIN
                              SELECT
                                @CantidadSugerida = ABS(@Cantidad * @Factor)
                              EXEC spSugerirSerieLoteMov @Empresa, @Modulo, @ID, @MovTipo, @Almacen, @RenglonID,
                                @Articulo, @Subcuenta, @Sucursal, @Cantidad, @Paquete, @EnSilencio = 1
                              IF NOT EXISTS ( SELECT
                                                *
                                              FROM
                                                SerieLoteMov
                                              WHERE
                                                Empresa = @Empresa
                                                AND Modulo = @Modulo
                                                AND ID = @ID
                                                AND Articulo = @Articulo
                                                AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                                                AND RenglonID = @RenglonID )
                                BEGIN
                                  IF @ArtTipo = 'VIN'
                                    SELECT
                                      @Ok = 20325
                                  ELSE
                                    SELECT
                                      @Ok = 20320   
					                        
                                  IF @Ok IS NOT NULL
                                  BEGIN
                                    IF @Modulo = 'VTAS'
                                      AND @OrigenTipo = 'VMOS'
                                      SELECT
                                        @Ok = NULL
                                    IF @MovTipo IN ( 'VTAS.C', 'VTAS.P' )
                                      AND @CfgVentaRefSerieLotePedidos = 0
                                      SELECT
                                        @Ok = NULL
                                    IF @Ok = 20320
                                      AND @MovTipo = 'VTAS.F'
                                      AND @AplicaMovTipo = 'VTAS.R'
                                      SELECT
                                        @Ok = NULL
                                  END

                                  -- Kike Sierra 2017-02-09: Procedimiento almacenado encargado de extender la validacion
                                  -- sobre el error 20320 ( "Falta indicar los números de Serie/Lote" )
                                  IF @Ok = 20320
                                  BEGIN
                                    EXEC CUP_SPP_20320
                                      @Empresa,
                                      @Usuario,
                                      @Accion,
                                      @Estatus,
                                      @Modulo,
                                      @ID,
                                      @Mov,
                                      @MovTipo,
                                      @Articulo,
                                      @Subcuenta,
                                      @Renglon,
                                      @RenglonSub,
                                      @RenglonID,
                                      @RenglonTipo,
                                      @Ok OUTPUT,
                                      @OkRef OUTPUT
                                  END
		                            --
                                END
                            END
                        END
		                --Kike SIerra: 19/01/2015: SE modifico el siguiente apartado para "igualar" la logica que utilizaba la version 2800
		                -- para marcar este error. Realmente un segmento grande eeste procedimiento cambiom, pero despues de algunas pruebas
		                --se considera que el error solo debe entrar para el siguiente criterio.
		                 /*COdigo Original: ELSE SELECT @Ok = 20330 */
                      ELSE
                        BEGIN
                          IF (
                               @EsEntrada = 1
                               OR @MovTipo IN ( 'COMS.B', 'COMS.CA', 'INV.IF', 'VTAS.CO' )
                               OR @EsSalida = 1
                               OR @EsTransferencia = 1
                             ) 
                            -- X | Se obtuvo de la validacion del snippet de la 2800
                            SELECT
                              @Ok = 20330

                          -- Kike Sierra 2017-02-09: Procedimiento almacenado encargado de extender la validacion
                          -- sobre el error 20330 ( "No corresponde la cantidad con los números de Serie/Lote" )
                          IF @Ok = 20330
                          BEGIN
                            EXEC CUP_SPP_20330
                              @Empresa,
                              @Usuario,
                              @Accion,
                              @Estatus,
                              @Modulo,
                              @ID,
                              @Mov,
                              @MovTipo,
                              @Articulo,
                              @Subcuenta,
                              @Renglon,
                              @RenglonSub,
                              @RenglonID,
                              @RenglonTipo,
                              @Ok OUTPUT,
                              @OkRef OUTPUT
                          END
                          --
                        END
                    END
                END
              IF @ArtTipo IN ( 'SERIE', 'VIN', 'LOTE', 'PARTIDA' )
                AND (
                      @Generar = 0
                      OR @MovTipo IN ( 'INV.IF' )
                    )
                AND @Utilizar = 0
                AND @CfgSeriesLotesMayoreo = 1
                AND (
                      @EsEntrada = 1
                      OR @MovTipo IN ( 'PROD.O', 'COMS.B', 'COMS.CA', 'COMS.GX', 'INV.IF', 'VTAS.CO' )
                      OR @EsSalida = 1
                      OR @EsTransferencia = 1
                    )
                AND (
                      @AfectarUnidades = 1
                      OR (
                           @MovTipo = 'PROD.O'
                           AND @CfgProdSerieLoteDesdeOrden = 1
                         )
                    )
                AND @Ok IS NULL
                BEGIN
                  IF /*(@AplicaMovTipo = 'COMS.CC' AND @MovTipo IN ('COMS.F','COMS.FL','COMS.EG', 'COMS.EI')) OR */ /*@FacturarVtasMostrador = 1 OR */ (
                                                                                                        @AplicaMovTipo = 'VTAS.R'
                                                                                                        AND @MovTipo IN (
                                                                                                        'VTAS.F',
                                                                                                        'VTAS.FAR',
                                                                                                        'VTAS.FC',
                                                                                                        'VTAS.FG',
                                                                                                        'VTAS.FX' )
                                                                                                        )
                    BEGIN
                      IF @MovTipo <> 'VTAS.FM'
                        IF EXISTS ( SELECT
                                      *
                                    FROM
                                      SerieLoteMov
                                    WHERE
                                      Empresa = @Empresa
                                      AND Modulo = @Modulo
                                      AND ID = @ID
                                      AND Articulo = @Articulo
                                      AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                                      AND RenglonID = @RenglonID )
                          SELECT
                            @Ok = 20095
                    END
                  ELSE
                    BEGIN
                      IF @ArtTipo = 'VIN'
                        IF EXISTS ( SELECT
                                      *
                                    FROM
                                      SerieLoteMov s,
                                      VIN v
                                    WHERE
                                      s.Empresa = @Empresa
                                      AND s.Modulo = @Modulo
                                      AND s.ID = @ID
                                      AND s.Articulo = @Articulo
                                      AND ISNULL(s.SubCuenta, '') = ISNULL(@Subcuenta, '')
                                      AND s.RenglonID = @RenglonID
                                      AND s.SerieLote = v.VIN
                                      AND v.Articulo <> @Articulo )
                          SELECT
                            @Ok = 20690
                      IF ROUND(ABS(@Cantidad * @Factor), @CfgDecimalesCantidades) = ROUND((
                                                                                            SELECT
                                                                                              ISNULL(SUM(ABS(Cantidad)),
                                                                                                     0.0)
                                                                                            FROM
                                                                                              SerieLoteMov
                                                                                            WHERE
                                                                                              Empresa = @Empresa
                                                                                              AND Modulo = @Modulo
                                                                                              AND ID = @ID
                                                                                              AND Articulo = @Articulo
                                                                                              AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta,
                                                                                                        '')
                                                                                              AND RenglonID = @RenglonID
                                                                                          ), @CfgDecimalesCantidades)
                        BEGIN
                          IF (
                               @EsEntrada = 1
                               OR @MovTipo = 'PROD.O'
                             )
                            AND @ArtTipo IN ( 'SERIE', 'VIN' )
                            BEGIN
                              SELECT
                                @SerieLote = MIN(s.SerieLote)
                              FROM
                                SerieLoteMov sm,
                                SerieLote s
                              WHERE
                                s.Sucursal = @Sucursal
                                AND s.Empresa = sm.Empresa
                                AND s.Articulo = sm.Articulo
                                AND s.SubCuenta = sm.SubCuenta
                                AND s.SerieLote = sm.SerieLote
                                AND (
                                      ISNULL(s.Existencia, 0) > 0
                                      OR ISNULL(s.ExistenciaActivoFijo, 0) > 0
                                    )
                                AND sm.Empresa = @Empresa
                                AND sm.Modulo = @Modulo
                                AND sm.ID = @ID
                                AND sm.Articulo = @Articulo
                                AND sm.RenglonID = @RenglonID
                              IF @SerieLote IS NOT NULL
                                SELECT
                                  @Ok = 20080
                              IF @Ok IS NULL
                                AND @OrigenMovTipo NOT IN ( 'INV.TI', 'INV.TIF', 'INV.TIS' )
                                AND @Accion <> 'CANCELAR'
                                SELECT
                                  @SerieLote = MIN(s.SerieLote)
                                FROM
                                  SerieLoteMov sm,
                                  SerieLote s
                                WHERE
                                  s.Sucursal = @Sucursal
                                  AND s.Empresa = sm.Empresa
                                  AND s.Articulo = sm.Articulo
                                  AND s.SubCuenta = sm.SubCuenta
                                  AND s.SerieLote = sm.SerieLote
                                  AND dbo.fnSerieExistenciaTransito(sm.SerieLote, sm.Articulo, sm.SubCuenta, sm.Empresa) = 1
                                  AND sm.Empresa = @Empresa
                                  AND sm.Modulo = @Modulo
                                  AND sm.ID = @ID
                                  AND sm.Articulo = @Articulo
                                  AND sm.RenglonID = @RenglonID
                              IF @SerieLote IS NOT NULL
                                SELECT
                                  @Ok = 20080
/** JH 31.10.2006 **/
                              IF @Ok = 20080
                                AND @Accion = 'CANCELAR'
                                AND @MovTipo = 'INV.CP'
                                AND @Cantidad > 0.0
                                SELECT
                                  @Ok = NULL
/**/
                            END
                          ELSE
                            IF (
                                 @EsSalida = 1
                                 OR @EsTransferencia = 1
                                 OR @MovTipo IN ( 'COMS.B', 'COMS.CA', 'COMS.GX', 'VTAS.N' /*,'INV.IF'*/)
                               )
                              AND @ArtSerieLoteInfo = 0
                              BEGIN
                                SELECT
                                  @SerieLote = MIN(SerieLote)
                                FROM
                                  SerieLoteMov
                                WHERE
                                  Empresa = @Empresa
                                  AND Modulo = @Modulo
                                  AND ID = @ID
                                  AND Articulo = @Articulo
                                  AND SubCuenta = ISNULL(@Subcuenta, '')
                                  AND RenglonID = @RenglonID
                                  AND ISNULL(Cantidad, 0) > 0
                                  AND SerieLote NOT IN ( SELECT
                                                          SerieLote
                                                         FROM
                                                          SerieLote
                                                         WHERE
                                                          Empresa = @Empresa /*AND Modulo = @Modulo */
                                                          AND Articulo = @Articulo
                                                          AND SubCuenta = ISNULL(@Subcuenta, '')
                                                          AND Almacen = @Almacen
                                                          AND Tarima = ISNULL(@Tarima, '')
                                                          AND (
                                                                ISNULL(Existencia, 0) > 0
                                                                OR ISNULL(ExistenciaActivoFijo, 0) > 0
                                                              ) )
                                IF @SerieLote IS NOT NULL
                                  SELECT
                                    @Ok = 20090
                                IF @Ok IS NOT NULL
                                  AND @Modulo = 'VTAS'
                                  AND (
                                        @OrigenTipo = 'VMOS'
                                        OR @MovTipo = 'VTAS.FM'
                                      )
                                  SELECT
                                    @Ok = NULL
                                IF @MovTipo IN ( 'VTAS.N', 'VTAS.NR', 'VTAS.NO', 'VTAS.FM' )
                                  AND @CfgNotasBorrador = 1
                                  SELECT
                                    @Ok = NULL
                                IF @MovTipo IN ( 'VTAS.N', 'VTAS.NR', 'VTAS.NO', 'VTAS.FM' )
                                  AND @Accion = 'CANCELAR'
                                  SELECT
                                    @Ok = NULL
                              END
                          IF @Ok IS NULL
                            AND @MovTipo IN ( 'COMS.DC', 'COMS.DG' )
                            AND @ArtSerieLoteInfo = 0
                            BEGIN
                              SELECT
                                @CantidadSeries = COUNT(*)
                              FROM
                                SerieLoteMov
                              WHERE
                                Empresa = @Empresa
                                AND Modulo = @Modulo
                                AND Articulo = @Articulo
                                AND ID = @IDAplica
                                AND SerieLote IN ( SELECT
                                                    SerieLote
                                                   FROM
                                                    SerieLoteMov
                                                   WHERE
                                                    Empresa = @Empresa
                                                    AND Modulo = @Modulo
                                                    AND ID = @ID
                                                    AND Articulo = @Articulo
                                                    AND RenglonID = @RenglonID )
                              IF @CantidadSeries <> @Cantidad
                                SELECT
                                  @Ok = 20090
                            END
                        END
                    END
                END
              IF @MovTipo = 'COMS.CA'
                IF (
                     SELECT
                      ROUND(SUM(ISNULL(Inventario, 0)), 4)
                     FROM
                      ArtSubExistenciaInv
                     WHERE
                      Empresa = @Empresa
                      AND Almacen = @Almacen
                      AND Articulo = @Articulo
                      AND ISNULL(SubCuenta, '') = ISNULL(@Subcuenta, '')
                   ) <= 0.0
                  SELECT
                    @Ok = 20810
              IF @MovTipo IN ( 'COMS.OG', 'COMS.IG', 'COMS.DG' )
                AND @AlmacenTipo <> 'GARANTIAS'
                AND @Ok IS NULL
                SELECT
                  @Ok = 20440
              IF NULLIF(@ArtCaducidadMinima, 0) IS NULL
                AND (
                      SELECT
                        TieneCaducidad
                      FROM
                        Art
                      WHERE
                        Articulo = @Articulo
                    ) = 1
                AND @MovTipo IN ( 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.CC' )
                AND @Accion <> 'GENERAR'
                AND @CfgCompraCaducidad = 1
                AND @Ok IS NULL
                SELECT
                  @Ok = 25124
              IF @MovTipo IN ( 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI', 'COMS.CC' )
                AND @Accion <> 'GENERAR'
                AND @CfgCompraCaducidad = 1
                AND @ArtCaducidadMinima IS NOT NULL
                AND @Ok IS NULL
                BEGIN
                  IF @FechaCaducidad IS NULL
                    SELECT
                      @Ok = 25125
                  ELSE
                    IF @FechaCaducidad < DATEADD(DAY, @ArtCaducidadMinima, @FechaEmision)
                      SELECT
                        @Ok = 25126
                END
              IF @Modulo = 'VTAS'
                AND @Accion <> 'CANCELAR'
                AND @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
                AND @Ok IS NULL
                EXEC xpInvVerificarCteArtBloqueo @Empresa, @ID, @Usuario, @ClienteProv, @Articulo, @Ok OUTPUT,
                  @OkRef OUTPUT
              IF @Ok IS NULL
                EXEC xpInvVerificarDetalle @ID, @Accion, @Base, @Empresa, @Usuario, @Modulo, @Mov, @MovID, @MovTipo,
                  @MovMoneda, @MovTipoCambio, @Estatus, @EstatusNuevo, @FechaEmision, @Renglon, @RenglonSub, @Articulo,
                  @Cantidad, @Importe, @ImporteNeto, @Impuestos, @ImpuestosNetos, @Ok OUTPUT, @OkRef OUTPUT
              IF @Ok IS NOT NULL
                AND @OkRef IS NULL
                BEGIN
                  SELECT
                    @OkRef = 'Articulo: ' + RTRIM(@Articulo)
                  IF NULLIF(RTRIM(@Subcuenta), '') IS NOT NULL
                    SELECT
                      @OkRef = @OkRef + ' (' + RTRIM(@Subcuenta) + ')'
                  IF NULLIF(RTRIM(@SerieLote), '') IS NOT NULL
                    SELECT
                      @OkRef = @OkRef + ' - ' + RTRIM(@SerieLote)
                END
              SELECT
                @AfectarAlgo = 1
              IF @Modulo = 'VTAS'
                BEGIN
                  SELECT
                    @SumaImporteNeto = @SumaImporteNeto + @ImporteNeto,
                    @SumaImpuestosNetos = @SumaImpuestosNetos + @ImpuestosNetos,
                    @SumaRetencionesNeto = @SumaRetencionesNeto + @RetencionesNeto
                  IF (
                       @AplicaAutorizacion IS NULL
                       OR @CfgAutoAutorizacionFacturas = 0
                     )
                    SELECT
                      @SumaImporteNetoSinAutorizar = @SumaImporteNetoSinAutorizar + @ImporteNeto,
                      @SumaImpuestosNetosSinAutorizar = @SumaImpuestosNetosSinAutorizar + @ImpuestosNetos
                END
              IF @Accion = 'CANCELAR'
                SELECT
                  @SumaCantidadOriginal = @SumaCantidadOriginal + @CantidadOriginal,
                  @SumaCantidadPendiente = @SumaCantidadPendiente + @CantidadPendiente + @CantidadReservada
            END  
          IF @Ok IS NULL
            BEGIN
              FETCH NEXT FROM crVerificarDetalle INTO @Seccion, @AutoGenerado, @Renglon, @RenglonSub, @RenglonID,
                @RenglonTipo, @CantidadOriginal, @CantidadObsequio, @CantidadInventario, @CantidadReservada,
                @CantidadOrdenada, @CantidadPendiente, @CantidadA, @MovUnidad, @Factor, @Articulo, @Subcuenta,
                @ArticuloDestino, @SubCuentaDestino, @SustitutoArticulo, @SustitutoSubcuenta, @Costo, @Precio,
                @DescuentoTipo, @DescuentoLinea, @Impuesto1, @Impuesto2, @Impuesto3, @AplicaMov, @AplicaMovID,
                @AlmacenRenglon, @ArtTipo, @ArtSerieLoteInfo, @ArtTipoOpcion, @ArtTipoCompra, @ArtSeProduce,
                @ArtSeCompra, @ArtEsFormula, @ArtUnidad, @ArtPrecioMinimo, @ArtMonedaVenta, @ArtMargenMinimo,
                @ArtMonedaCosto, @ProdSerieLote, @ProdRuta, @ProdOrden, @ProdOrdenDestino, @ProdCentro,
                @ProdCentroDestino, @DetalleTipo, @CantidadMinimaVenta, @CantidadMaximaVenta, @ArtCaducidadMinima,
                @FechaCaducidad, @ArtActividades, @FechaRequeridaD, @Paquete, @EsEstadistica, @PrecioTipoCambio, @Tarima,
                @ArtNivelToleranciaCosto, @ArtToleranciaCosto, @ArtToleranciaCostoInferior, @Retencion1, @Retencion2,
                @Retencion3, @Impuesto5, @AnticipoFacturado 
              IF @@ERROR <> 0
                SELECT
                  @Ok = 1
            END
          ELSE
            IF @OkRef IS NULL
              BEGIN
                SELECT
                  @OkRef = 'Articulo: ' + @Articulo
                IF @Subcuenta IS NOT NULL
                  SELECT
                    @OkRef = @OkRef + ' (' + @Subcuenta + ')'
              END
        END  
      CLOSE crVerificarDetalle
    END
  DEALLOCATE crVerificarDetalle
  IF @Ok IS NULL
    BEGIN



      IF @Modulo = 'VTAS'
        BEGIN
          SELECT
            @ImporteTotalSinAutorizar = @SumaImporteNetoSinAutorizar + @SumaImpuestosNetosSinAutorizar
            - @AnticiposFacturados,
            @ImporteTotal = @SumaImporteNeto + @SumaImpuestosNetos - @AnticiposFacturados
          IF @CfgAutoAutorizacionFacturas = 1
            AND ISNULL(@ImporteTotalSinAutorizar, 0) <> 0.0
            BEGIN
              IF @AnexoID IS NOT NULL
                SELECT
                  @ImporteTotalSinAutorizar = 0.0
              ELSE
                IF @OrigenTipo = @Modulo
-- Kike SIerra 15/01/2014: Se modifico esta validacion ya que de manera equivocada. 
-- EN los pedidos que provenian de cotizaciones autorizadas por descuento, ponia el importe sin autorizar = 0
-- lo que saltaba las validaciones de morosidad y limite de credito.
-- Codigo Original: IF @OrigenTipo = @Modulo     
                  AND (
                        @MovTipo <> 'VTAS.P'
                        OR @Mov = 'Orden Surtido'
                      )
                  IF (
                       SELECT
                        NULLIF(RTRIM(Autorizacion), '')
                       FROM
                        Venta
                       WHERE
                        Empresa = @Empresa
                        AND Mov = @Origen
                        AND MovID = @OrigenID
                        AND Estatus IN ( 'PENDIENTE', 'CONCLUIDO' )
                     ) IS NOT NULL
                    SELECT
                      @ImporteTotalSinAutorizar = 0.0
            END
        END
      IF @Modulo = 'VTAS'
        AND @CfgImpInc = 1
        BEGIN
          SELECT
            @SumaImporteNeto = @SumaImporteNeto - ( @SumaImporteNeto + @SumaImpuestosNetos - @ImporteTotal )
        END
      IF @AfectarAlgo = 0
        AND @EstatusNuevo <> 'CONFIRMAR'
        AND @MovTipo NOT IN ( 'INV.IF', 'VTAS.OP' )
        IF @Accion = 'CANCELAR'
          SELECT
            @Ok = 60015
        ELSE
          SELECT
            @Ok = 60010				
      IF @Accion = 'CANCELAR'
        BEGIN
          IF @Estatus = 'PENDIENTE'
            AND ROUND(@SumaCantidadOriginal, 4) <> ROUND(@SumaCantidadPendiente, 4)
            AND @Base = 'TODO'
            SELECT
              @Ok = 60080
        END
      ELSE
        IF @Modulo = 'VTAS'
          AND @Accion NOT IN ( 'GENERAR', 'CANCELAR' )
          AND @Estatus <> 'PENDIENTE'
          BEGIN
            IF @CfgVentaBloquearMorosos <> 'NO'
              AND @MovTipo NOT IN ( 'VTAS.PR', 'VTAS.EST', 'VTAS.SD', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B',
                                    'VTAS.DR', 'VTAS.DC', 'VTAS.DCR', 'VTAS.VP' )
              AND (
                    @Autorizacion IS NULL
                    OR @Mensaje NOT IN ( 65010, 65020, 65040 )
                  )
              AND @CobroIntegrado = 0
              AND @ImporteTotalSinAutorizar <> 0.0
              AND @Ok IS NULL
              BEGIN
                SELECT
                  @DiasTolerancia = 0
                IF SUBSTRING(@CfgVentaBloquearMorosos, 1, 1) <> 'S'
                  BEGIN
                    IF dbo.fnEsNumerico(@CfgVentaBloquearMorosos) = 1
                      SELECT
                        @DiasTolerancia = CONVERT(INT, @CfgVentaBloquearMorosos)
                    ELSE
                      BEGIN
                        IF dbo.fnEsNumerico(RTRIM(SUBSTRING(@CfgVentaBloquearMorosos, 1, 2))) = 1
                          SELECT
                            @DiasTolerancia = CONVERT(INT, RTRIM(SUBSTRING(@CfgVentaBloquearMorosos, 1, 2)))
                      END
                  END


--------------------------------------------------------------------------------------------------------------
--Kike Sierra: 29/Abril/2015: Se modifico el siguiente snippet para considerar solo los saldos pendientes que 
--superen el rango establecido por la herramienta de eliminacion de saldos menores. 

  /*Codigo Original
  SELECT @MaxDiasMoratorios = ISNULL(MAX(p.DiasMoratorios), 0)
  FROM   CxcPendiente p, MovTipo  mt
  WHERE  p.Empresa = @Empresa
  AND    p.Cliente = @ClienteProv
  AND    mt.Modulo = 'CXC' 
  AND    mt.Mov = p.Mov 
  AND    mt.Clave NOT IN ('CXC.A', 'CXC.AR', 'CXC.NC', 'CXC.DAC', 'CXC.NCD','CXC.NCF')
  */

  /*Codigo Nuevo*/
                SELECT
                  @MaxDiasMoratorios = ISNULL(MAX(p.DiasMoratorios), 0)
                FROM
                  CxcPendiente p
                  JOIN MovTipo mt ON 'CXC' = mt.Modulo
                                     AND p.Mov = mt.Mov
                  JOIN Mon ON p.Moneda = Mon.Moneda
                WHERE
                  p.Empresa = @Empresa
                  AND p.Cliente = @ClienteProv
                  AND mt.Clave NOT IN ( 'CXC.A', 'CXC.AR', 'CXC.NC', 'CXC.DAC', 'CXC.NCD', 'CXC.NCF' )
                  AND ROUND(ISNULL(p.Saldo, 0), 2, 1) > ISNULL(Mon.CxcEliminarSaldosMenores, 0)
  /**/
-----------------------------------------------------------------------------------------------


-- Kike Sierra:  04/07/2013: SE modifico la condicion para marcar el 65040 debido a los cambios por el 
-- desarrollo de las autorizaciones
-- CODIGO ORIGNAL:    IF @MaxDiasMoratorios > @DiasTolerancia  
                IF @MaxDiasMoratorios > @DiasTolerancia
--
                  AND NOT (
                            @Modulo = 'VTAS'
                            AND @Mov = 'Pedido'
                            AND EXISTS ( SELECT
                                          Id
                                         FROM
                                          CuprumEstadoAutorizaVta
                                         WHERE
                                          Id = @ID
                                          AND CHARINDEX(CAST(65040 AS VARCHAR), ISNULL(Autorizados, '')) > 0 )
                          )
                  AND (
                        SELECT
                          ISNULL(Situacion, '')
                        FROM
                          Venta
                        WHERE
                          ID = @ID
                      ) <> 'Por Enviar a Venta Perdida'
--   
                  BEGIN
                    SELECT
                      @Ok = 65040


/* adecuacion para actualizar situacion. Judith Ramirez 15-Ene-2013.*/  
--Kike Sierra: 27/06/2013: Se cambio para el pedido: IF (@MovTipo in ('VTAS.P') AND (SELECT Mov FROM Venta WHERE ID=@ID AND Estatus='SINAFECTAR')='Pedido') 

                    IF (
                         @MovTipo IN ( 'VTAS.P' )
                         AND (
                               SELECT
                                Mov
                               FROM
                                Venta
                               WHERE
                                ID = @ID
                                AND Estatus = 'SINAFECTAR'
                             ) = 'Pedido'
                       )
                      BEGIN 
    --DECLARE @TipoCondicion varchar(20)  
                        SELECT
                          @TipoCondicion = C.TipoCondicion
                        FROM
                          Venta V,
                          Condicion C
                        WHERE
                          V.ID = @ID
                          AND V.Condicion = C.Condicion   
                        IF ( @TipoCondicion = 'Credito' )
                          BEGIN  
                            IF ( EXISTS ( SELECT
                                            ID
                                          FROM
                                            AuxError65040
                                          WHERE
                                            ID = @ID ) )
                              DELETE FROM
                                AuxError65040
                              WHERE
                                ID = @ID   
			 --UPDATE Venta SET Situacion='Por Revision de Cxc' WHERE ID=@ID   
                            INSERT  INTO AuxError65040
                            SELECT
                              @ID   
                          END
                      END  
										 									
                    IF @Ok = 65040
                      AND @MovTipo = 'VTAS.F'
                      AND @AplicaMovTipo = 'VTAS.P'
                      AND EXISTS ( SELECT
                                    *
                                   FROM
                                    VentaCobro
                                   WHERE
                                    ID = @IDAplica )
                      SELECT
                        @Ok = NULL


                    EXEC xpValidacionMorosos @Empresa, @Accion, @Modulo, @ID, @MovTipo, @ServicioGarantia, @Ok OUTPUT

                  END
                IF @Ok IS NOT NULL
                  SELECT
                    @Autorizar = 1
              END


/*****DIVISION  Politica de  CREDITO (COmentario de Kike Sierra 10/07/213) */   
            IF @ChecarCredito = 1
              AND @MovTipo NOT IN ( 'VTAS.PR', 'VTAS.EST', 'VTAS.SD', 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B',
                                    'VTAS.DR', 'VTAS.DC', 'VTAS.DCR', 'VTAS.VP' )
              AND (
                    @Autorizacion IS NULL
                    OR @Mensaje NOT IN ( 65010, 65020 )
                  )
              AND @Accion <> 'GENERAR'
              AND @Ok IS NULL
              BEGIN
                SELECT
                  @DiasVencimiento = 0
                IF @Condicion IS NOT NULL
                  BEGIN
                    SELECT
                      @DiasVencimiento = NULL
       
                    SELECT
                      @DiasVencimiento = DiasVencimiento
                    FROM
                      Condicion
                    WHERE
                      Condicion = @Condicion
       
       
/*Apartado "La Condicion del Movimiento Difiere con la Politica de Credito del Cliente"*/        
                    IF @DiasVencimiento IS NULL
                      SELECT
                        @DiasVencimiento = DATEDIFF(DAY, @FechaEmision, @Vencimiento)
                    ELSE
                      BEGIN
                        IF @DiasCredito IS NOT NULL
                          IF @DiasVencimiento > @DiasCredito
                            SELECT
                              @Ok = 65020
                        IF @CondicionesValidas IS NOT NULL
                          IF CHARINDEX(UPPER(@Condicion), @CondicionesValidas) = 0
                            SELECT
                              @Ok = 65020
                      END
                  END

                IF @ConCredito = 0
                  AND @DiasVencimiento > 0
                  SELECT
                    @Ok = 65020


/*Apartado Limite de Credito*/
                IF @ConCredito = 1
                  AND @ConLimiteCredito = 1
                  AND @MovTipo NOT IN ( 'VTAS.D', 'VTAS.DF', 'VTAS.DFC', 'VTAS.B', 'VTAS.DR' )
                  AND @ImporteTotalSinAutorizar <> 0.0
                  AND @Ok IS NULL
                  BEGIN
                    IF ( @CfgVentaChecarCredito = 'COTIZACION' )
                      OR (
                           @CfgVentaChecarCredito = 'PEDIDO'
                           AND @MovTipo NOT IN ( 'VTAS.C', 'VTAS.CS' )
                         )
                      OR ( @MovTipo NOT IN ( 'VTAS.C', 'VTAS.CS', 'VTAS.P', 'VTAS.S' ) )
                      BEGIN
                        SELECT
                          @Saldo = 0.0,
                          @VentasPendientes = 0.0,
                          @PedidosPendientes = 0.0
                        IF @CfgLimiteCreditoNivelUEN = 1
                          BEGIN
                            IF @CfgLimiteCreditoNivelGrupo = 1
                              SELECT
                                @Saldo = ISNULL(SUM(s.Saldo * m.TipoCambio), 0.0)
                              FROM
                                Cxc s,
                                Mon m,
                                Empresa e
                              WHERE
                                e.Grupo = @EmpresaGrupo
                                AND s.Empresa = e.Empresa
                                AND s.Cliente = @ClienteProv
                                AND s.Moneda = m.Moneda
                                AND s.UEN = @VentaUEN
                                AND s.Estatus = 'PENDIENTE'
                            ELSE
                              SELECT
                                @Saldo = ISNULL(SUM(s.Saldo * m.TipoCambio), 0.0)
                              FROM
                                Cxc s,
                                Mon m
                              WHERE
                                s.Empresa = @Empresa
                                AND s.Cliente = @ClienteProv
                                AND s.Moneda = m.Moneda
                                AND s.UEN = @VentaUEN
                                AND s.Estatus = 'PENDIENTE'
                          END
                        ELSE
                          BEGIN
                            IF @CfgLimiteCreditoNivelGrupo = 1
                              SELECT
                                @Saldo = ISNULL(SUM(s.Saldo * m.TipoCambio), 0.0)
                              FROM
                                CxcSaldo s,
                                Mon m,
                                Empresa e
                              WHERE
                                e.Grupo = @EmpresaGrupo
                                AND s.Empresa = e.Empresa
                                AND s.Cliente = @ClienteProv
                                AND s.Moneda = m.Moneda
                            ELSE
                              SELECT
                                @Saldo = ISNULL(SUM(s.Saldo * m.TipoCambio), 0.0)
                              FROM
                                CxcSaldo s,
                                Mon m
                              WHERE
                                s.Empresa = @Empresa
                                AND s.Cliente = @ClienteProv
                                AND s.Moneda = m.Moneda
                          END
                        IF @MovTipo IN ( 'VTAS.P', 'VTAS.S' )
                          AND @ConLimitePedidos = 1
                          BEGIN
                            IF @CfgLimiteCreditoNivelUEN = 1
                              BEGIN
                                IF @CfgLimiteCreditoNivelGrupo = 1
                                  SELECT
                                    @PedidosPendientes = ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
                                  FROM
                                    VentaPendiente v,
                                    MovTipo mt,
                                    Mon
                                  WHERE
                                    mt.Modulo = 'VTAS'
                                    AND mt.Mov = v.Mov
                                    AND mt.Clave IN ( 'VTAS.P', 'VTAS.S' )
                                    AND v.Estatus = 'PENDIENTE'
                                    AND /**/ v.Empresa = @Empresa
                                    AND v.Cliente = @ClienteProv
                                    AND v.Moneda = Mon.Moneda
                                    AND v.UEN = @VentaUEN
                                ELSE
                                  SELECT
                                    @PedidosPendientes = ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
                                  FROM
                                    VentaPendiente v,
                                    MovTipo mt,
                                    Mon,
                                    Empresa e
                                  WHERE
                                    mt.Modulo = 'VTAS'
                                    AND mt.Mov = v.Mov
                                    AND mt.Clave IN ( 'VTAS.P', 'VTAS.S' )
                                    AND v.Estatus = 'PENDIENTE'
                                    AND e.Grupo = @EmpresaGrupo
                                    AND v.Empresa = e.Empresa
                                    AND v.Cliente = @ClienteProv
                                    AND v.Moneda = Mon.Moneda
                                    AND v.UEN = @VentaUEN
                              END
                            ELSE
                              BEGIN
                                IF @CfgLimiteCreditoNivelGrupo = 1
                                  SELECT
                                    @PedidosPendientes = ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
                                  FROM
                                    VentaPendiente v,
                                    MovTipo mt,
                                    Mon
                                  WHERE
                                    mt.Modulo = 'VTAS'
                                    AND mt.Mov = v.Mov
                                    AND mt.Clave IN ( 'VTAS.P', 'VTAS.S' )
                                    AND v.Estatus = 'PENDIENTE'
                                    AND /**/ v.Empresa = @Empresa
                                    AND v.Cliente = @ClienteProv
                                    AND v.Moneda = Mon.Moneda
                                ELSE
                                  SELECT
                                    @PedidosPendientes = ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
                                  FROM
                                    VentaPendiente v,
                                    MovTipo mt,
                                    Mon,
                                    Empresa e
                                  WHERE
                                    mt.Modulo = 'VTAS'
                                    AND mt.Mov = v.Mov
                                    AND mt.Clave IN ( 'VTAS.P', 'VTAS.S' )
                                    AND v.Estatus = 'PENDIENTE'
                                    AND e.Grupo = @EmpresaGrupo
                                    AND v.Empresa = e.Empresa
                                    AND v.Cliente = @ClienteProv
                                    AND v.Moneda = Mon.Moneda
                              END
                            SELECT
                              @DifCredito = ( @LimitePedidos * @TipoCambioCredito ) - @PedidosPendientes
                              - ( @SumaImporteNetoSinAutorizar * @MovTipoCambio )
                            IF ROUND(@DifCredito, 0) < 0.0
                              BEGIN
                                SELECT
                                  @ImporteAutorizar = -@DifCredito
                                SELECT
                                  @Ok = 65010,
                                  @OkRef = 'Limite Pedidos: ' + '$'
                                  + CONVERT(VARCHAR, CAST(@LimitePedidos * @TipoCambioCredito AS MONEY), 3)
                                  + '<BR>Pedidos Pendientes: ' + '$'
                                  + CONVERT(VARCHAR, CAST(@PedidosPendientes AS MONEY), 3) + '<BR>Importe Movimiento: '
                                  + '$' + CONVERT(VARCHAR, CAST(@SumaImporteNetoSinAutorizar * @MovTipoCambio AS MONEY), 3)
                                  + '<BR><BR>Diferencia: ' + '$' + CONVERT(VARCHAR, CAST(-@DifCredito AS MONEY), 3)
                                  + '<BR>Importe Autorizar: ' + '$' + CONVERT(VARCHAR, CAST(@ImporteAutorizar AS MONEY), 3)
                                IF @ImporteAutorizar > @SumaImporteNetoSinAutorizar * @MovTipoCambio
                                  SELECT
                                    @ImporteAutorizar = @SumaImporteNetoSinAutorizar * @MovTipoCambio
                                UPDATE
                                  Venta
                                SET
                                  DifCredito = @ImporteAutorizar
                                WHERE
                                  ID = @ID

/* adecuacion para actualizar situacion. Judith Ramirez 15-Ene-2013.*/  
                                IF (
                                     @MovTipo = 'VTAS.P'
                                     AND (
                                           SELECT
                                            Mov
                                           FROM
                                            Venta
                                           WHERE
                                            ID = @ID
                                            AND Estatus = 'SINAFECTAR'
                                         ) = 'Pedido'
                                   )
                                  BEGIN   
	 --DECLARE @TipoCondicion varchar(20)  
                                    SELECT
                                      @TipoCondicion = C.TipoCondicion
                                    FROM
                                      Venta V,
                                      Condicion C
                                    WHERE
                                      V.ID = @ID
                                      AND V.Condicion = C.Condicion 
	 
                                    IF ( @TipoCondicion = 'Credito' )
                                      BEGIN  
                                        IF ( EXISTS ( SELECT
                                                        ID
                                                      FROM
                                                        AuxError65010
                                                      WHERE
                                                        ID = @ID ) )
                                          DELETE FROM
                                            AuxError65010
                                          WHERE
                                            ID = @ID   
		         --UPDATE Venta SET Situacion='Por Revision de Cxc' WHERE ID=@ID   
                                        INSERT  INTO AuxError65010
                                        SELECT
                                          @ID   
                                      END  
                                  END   
																
                              END
                          END
                        ELSE
                          BEGIN
                            IF @CfgVentaPedidosDisminuyenCredito = 1
                              SELECT
                                @Saldo = @Saldo + ISNULL(SUM(ISNULL(v.Saldo, 0) * Mon.TipoCambio), 0)
                              FROM
                                VentaPendiente v,
                                MovTipo mt,
                                Mon,
                                Empresa e
                              WHERE
                                mt.Modulo = 'VTAS'
                                AND mt.Mov = v.Mov
                                AND mt.Clave IN ( 'VTAS.P', 'VTAS.S' )
                                AND v.Estatus = 'PENDIENTE'
                                AND ISNULL(e.Grupo, '') = ISNULL(@EmpresaGrupo, '') -- Kike Sierra : 10/07/2013: Faltaba el ISNULL 
                                AND v.Empresa = e.Empresa
                                AND v.Cliente = @ClienteProv
                                AND v.Moneda = Mon.Moneda



                            IF @CfgLimiteCreditoNivelUEN = 1
                              BEGIN
                                IF @CfgLimiteCreditoNivelGrupo = 1
                                  SELECT
                                    @VentasPendientes = ISNULL(SUM(( ISNULL(v.Saldo, 0) /*+ ISNULL(v.SaldoImpuestos, 0)*/ )
                                                                   * Mon.TipoCambio), 0)
                                  FROM
                                    VentaPendiente v,
                                    MovTipo mt,
                                    Mon,
                                    Empresa e
                                  WHERE
                                    mt.Modulo = 'VTAS'
                                    AND mt.Mov = v.Mov
                                    AND mt.Clave IN ( 'VTAS.R', /*'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', */
                                                      'VTAS.VC', 'VTAS.VCR' )
                                    AND v.Estatus = 'PENDIENTE'
                                    AND e.Grupo = @EmpresaGrupo
                                    AND v.Empresa = e.Empresa
                                    AND v.Cliente = @ClienteProv
                                    AND v.Moneda = Mon.Moneda
                                    AND v.UEN = @VentaUEN
                                ELSE
                                  SELECT
                                    @VentasPendientes = ISNULL(SUM(( ISNULL(v.Saldo, 0) /*+ ISNULL(v.SaldoImpuestos, 0)*/ )
                                                                   * Mon.TipoCambio), 0)
                                  FROM
                                    VentaPendiente v,
                                    MovTipo mt,
                                    Mon
                                  WHERE
                                    mt.Modulo = 'VTAS'
                                    AND mt.Mov = v.Mov
                                    AND mt.Clave IN ( 'VTAS.R', /*'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', */
                                                      'VTAS.VC', 'VTAS.VCR' )
                                    AND v.Estatus = 'PENDIENTE'
                                    AND v.Empresa = @Empresa
                                    AND v.Cliente = @ClienteProv
                                    AND v.Moneda = Mon.Moneda
                                    AND v.UEN = @VentaUEN
                              END
                            ELSE
                              BEGIN
                                IF @CfgLimiteCreditoNivelGrupo = 1
                                  SELECT
                                    @VentasPendientes = ISNULL(SUM(( ISNULL(v.Saldo, 0) /*+ ISNULL(v.SaldoImpuestos, 0)*/ )
                                                                   * Mon.TipoCambio), 0)
                                  FROM
                                    VentaPendiente v,
                                    MovTipo mt,
                                    Mon,
                                    Empresa e
                                  WHERE
                                    mt.Modulo = 'VTAS'
                                    AND mt.Mov = v.Mov
                                    AND mt.Clave IN ( 'VTAS.R', /*'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', */
                                                      'VTAS.VC', 'VTAS.VCR' )
                                    AND v.Estatus = 'PENDIENTE'
                                    AND e.Grupo = @EmpresaGrupo
                                    AND v.Empresa = e.Empresa
                                    AND v.Cliente = @ClienteProv
                                    AND v.Moneda = Mon.Moneda
                                ELSE
                                  SELECT
                                    @VentasPendientes = ISNULL(SUM(( ISNULL(v.Saldo, 0) /*+ ISNULL(v.SaldoImpuestos, 0)*/ )
                                                                   * Mon.TipoCambio), 0)
                                  FROM
                                    VentaPendiente v,
                                    MovTipo mt,
                                    Mon
                                  WHERE
                                    mt.Modulo = 'VTAS'
                                    AND mt.Mov = v.Mov
                                    AND mt.Clave IN ( 'VTAS.R', /*'VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', */
                                                      'VTAS.VC', 'VTAS.VCR' )
                                    AND v.Estatus = 'PENDIENTE'
                                    AND v.Empresa = @Empresa
                                    AND v.Cliente = @ClienteProv
                                    AND v.Moneda = Mon.Moneda
                              END
                            SELECT
                              @RemisionesAplicadas = 0.0
                            SELECT
                              @RemisionesAplicadas = ISNULL(SUM(d.ImporteTotal * m.TipoCambio), 0.0)
                            FROM
                              VentaTCalc d,
                              MovTipo mt,
                              Mon m
                            WHERE
                              d.ID = @ID
                              AND mt.Mov = d.Aplica
                              AND mt.Modulo = 'VTAS'
                              AND mt.Clave IN ( 'VTAS.R', 'VTAS.VCR' )
                              AND d.Moneda = m.Moneda



                            IF @RemisionesAplicadas IS NOT NULL
                              SELECT
                                @VentasPendientes = @VentasPendientes - @RemisionesAplicadas
                            SELECT
                              @DifCredito = ( @LimiteCredito * @TipoCambioCredito ) - @Saldo - @VentasPendientes
                              - ( @ImporteTotalSinAutorizar * @MovTipoCambio )

  -- Kike Sierra:  04/07/2013: SE modifico la condicion para marcar el 65010 debido a los cambios por el 
  --desarrollo de las autorizaciones.
   --CODIGO ORIGNAL:  IF ROUND(@DifCredito, 0) < 0.0  
                            IF ROUND(@DifCredito, 0) < 0.0
   --
                              AND NOT (
                                        @Modulo = 'VTAS'
                                        AND @Mov = 'Pedido'
                                        AND EXISTS ( SELECT
                                                      Id
                                                     FROM
                                                      CuprumEstadoAutorizaVta
                                                     WHERE
                                                      Id = @ID
                                                      AND CHARINDEX(CAST(65010 AS VARCHAR), ISNULL(Autorizados, '')) > 0 )
                                      )
                              AND (
                                    SELECT
                                      ISNULL(Situacion, '')
                                    FROM
                                      Venta
                                    WHERE
                                      ID = @ID
                                  ) <> 'Por Enviar a Venta Perdida'
   --   
                              BEGIN
                                SELECT
                                  @ImporteAutorizar = -@DifCredito
                                SELECT
                                  @Ok = 65010,
                                  @OkRef = 'Limite Credito: ' + '$'
                                  + CONVERT(VARCHAR, CAST(@LimiteCredito * @TipoCambioCredito AS MONEY), 3)
                                  + '<BR><BR>Saldo Actual: ' + '$' + CONVERT(VARCHAR, CAST(@Saldo AS MONEY), 3)
                                  + '<BR>Remisiones Pendientes: ' + '$'
                                  + CONVERT(VARCHAR, CAST(@VentasPendientes AS MONEY), 3) + '<BR>Importe Movimiento: '
                                  + '$' + CONVERT(VARCHAR, CAST(@ImporteTotalSinAutorizar * @MovTipoCambio AS MONEY), 3)
                                  + '<BR><BR>Diferencia: ' + '$' + CONVERT(VARCHAR, CAST(-@DifCredito AS MONEY), 3)
                                  + '<BR>Importe Autorizar: ' + '$' + CONVERT(VARCHAR, CAST(@ImporteAutorizar AS MONEY), 3)
                                IF @ImporteAutorizar > @SumaImporteNetoSinAutorizar * @MovTipoCambio
                                  SELECT
                                    @ImporteAutorizar = @SumaImporteNetoSinAutorizar * @MovTipoCambio
                                UPDATE
                                  Venta
                                SET
                                  DifCredito = @ImporteAutorizar
                                WHERE
                                  ID = @ID

/* adecuacion para actualizar situacion. Judith Ramirez 15-Ene-2013.*/  
                                IF (
                                     @MovTipo = 'VTAS.P'
                                     AND (
                                           SELECT
                                            Mov
                                           FROM
                                            Venta
                                           WHERE
                                            ID = @ID
                                            AND Estatus = 'SINAFECTAR'
                                         ) = 'Pedido'
                                   )
                                  BEGIN   
                                    SELECT
                                      @TipoCondicion = C.TipoCondicion
                                    FROM
                                      Venta V,
                                      Condicion C
                                    WHERE
                                      V.ID = @ID
                                      AND V.Condicion = C.Condicion
		   
                                    IF ( EXISTS ( SELECT
                                                    ID
                                                  FROM
                                                    AuxError65010
                                                  WHERE
                                                    ID = @ID ) )
                                      DELETE FROM
                                        AuxError65010
                                      WHERE
                                        ID = @ID   
		 --UPDATE Venta SET Situacion='Por Revision de Cxc' WHERE ID=@ID   
                                    INSERT  INTO AuxError65010
                                    SELECT
                                      @ID   
                                  END   
-----------------------------------------------------------------------  
                                                             
                              END
                          END
                      END
                  END
                IF @Ok IS NOT NULL
                  SELECT
                    @Autorizar = 1
              END
/**** Fin division Politica de Credito Kike Sierra*/


            IF @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FB', 'VTAS.FM' )
              AND @Estatus IN ( 'SINAFECTAR', 'CONFIRMAR', 'BORRADOR' )
              AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
              AND @Ok IS NULL
              AND @AutoCorrida IS NULL
              IF ROUND(@ImporteTotal, 0) < 0.0
                SELECT
                  @Ok = 20410
            IF @MovTipo = 'VTAS.S'
              AND @CfgServiciosRequiereTareas = 1
              AND @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
              AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
              IF NOT EXISTS ( SELECT
                                *
                              FROM
                                ServicioTarea
                              WHERE
                                ID = @ID )
                BEGIN
                  SELECT
                    @TareaOmision = NULLIF(RTRIM(VentaServiciosTareaOmision), '')
                  FROM
                    EmpresaCfg
                  WHERE
                    Empresa = @Empresa
                  IF @TareaOmision IS NULL
                    SELECT
                      @Ok = 20490
                  ELSE
                    BEGIN
                      SELECT
                        @TareaOmisionEstado = NULL
                      SELECT
                        @TareaOmisionEstado = Estado
                      FROM
                        TareaEstado
                      WHERE
                        Orden = 1
                      INSERT  ServicioTarea
                              (
                                Sucursal,
                                ID,
                                Tarea,
                                Estado
                              )
                      VALUES
                              (
                                @Sucursal,
                                @ID,
                                @TareaOmision,
                                @TareaOmisionEstado
                              )
                    END
                END
            IF @MovTipo = 'VTAS.S'
              AND @CfgServiciosValidarID = 1
              AND @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
              AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
              AND @AnexoID IS NULL
              BEGIN
                SELECT
                  @Flotante = NULLIF(ServicioNumero, 0),
                  @Identificador = NULLIF(RTRIM(ServicioIdentificador), '')
                FROM
                  Venta
                WHERE
                  ID = @ID
                IF @Flotante IS NOT NULL
                  OR @Identificador IS NOT NULL
                  IF EXISTS ( SELECT
                                ID
                              FROM
                                Venta
                              WHERE
                                Empresa = @Empresa
                                AND Estatus = 'PENDIENTE'
                                AND ServicioNumero = @Flotante
                                AND ServicioIdentificador = @Identificador
                                AND ServicioSerie <> @ServicioSerie )
                    SELECT
                      @Ok = 26120,
                      @OkRef = ISNULL(@Identificador, '') + ' ' + CONVERT(VARCHAR, @Flotante)
              END
            IF @MovTipo IN ( 'VTAS.SG', 'VTAS.EG' )
              AND @ImporteTotal > 0.0
              AND @Ok IS NULL
              SELECT
                @Ok = 20420
            IF @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FB' )
              AND @CfgLimiteRenFacturas > 0
              AND (
                    @FacturarVtasMostrador = 0
                    OR @CfgVentaLimiteRenFacturasVMOS = 1
                  )
              AND @Accion <> 'GENERAR'
              AND @Ok IS NULL
              AND @FacturacionRapidaAgrupada = 0
              BEGIN
                SELECT
                  @Conteo = ISNULL(COUNT(*), 0)
                FROM
                  VentaD
                WHERE
                  ID = @ID
                IF @CfgLimiteRenFacturas < @Conteo
                  SELECT
                    @Ok = 60210,
                    @OkRef = 'Limite: ' + LTRIM(CONVERT(CHAR, @CfgLimiteRenFacturas)) + ', Renglones: '
                    + LTRIM(CONVERT(CHAR, @Conteo))
              END
            IF @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
              AND @CobroIntegrado = 1
              AND @OrigenTipo <> 'VMOS'
              AND @Ok IS NULL
              BEGIN
                SELECT
                  @Importe1 = 0.0,
                  @Importe2 = 0.0,
                  @Importe3 = 0.0,
                  @Importe4 = 0.0,
                  @Importe5 = 0.0,
                  @CobroDesglosado = 0.0,
                  @CobroCambio = 0.0,
                  @CobroDelEfectivo = 0.0,
                  @ValesCobrados = 0.0,
                  @CobroRedondeo = 0.0,
                  @TarjetasCobradas = 0.0 	
                SELECT
                  @Importe1 = ISNULL(Importe1, 0.0),
                  @Importe2 = ISNULL(Importe2, 0.0),
                  @Importe3 = ISNULL(Importe3, 0.0),
                  @Importe4 = ISNULL(Importe4, 0.0),
                  @Importe5 = ISNULL(Importe5, 0.0),
                  @FormaCobro1 = NULLIF(RTRIM(FormaCobro1), ''),
                  @FormaCobro2 = NULLIF(RTRIM(FormaCobro2), ''),
                  @FormaCobro3 = NULLIF(RTRIM(FormaCobro3), ''),
                  @FormaCobro4 = NULLIF(RTRIM(FormaCobro4), ''),
                  @FormaCobro5 = NULLIF(RTRIM(FormaCobro5), ''),
                  @CobroDelEfectivo = ROUND(ISNULL(DelEfectivo, 0.0), @RedondeoMonetarios),
                  @CobroRedondeo = ISNULL(Redondeo, 0)
                FROM
                  VentaCobro
                WHERE
                  ID = @ID
                EXEC spVentaCobroTotal @FormaCobro1, @FormaCobro2, @FormaCobro3, @FormaCobro4, @FormaCobro5, @Importe1,
                  @Importe2, @Importe3, @Importe4, @Importe5, @CobroDesglosado OUTPUT, @Moneda = @MovMoneda,
                  @TipoCambio = @MovTipoCambio
                IF @FormaCobro1 = @FormaCobroVales
                  SELECT
                    @ValesCobrados = @ValesCobrados + @Importe1
                IF @FormaCobro2 = @FormaCobroVales
                  SELECT
                    @ValesCobrados = @ValesCobrados + @Importe2
                IF @FormaCobro3 = @FormaCobroVales
                  SELECT
                    @ValesCobrados = @ValesCobrados + @Importe3
                IF @FormaCobro4 = @FormaCobroVales
                  SELECT
                    @ValesCobrados = @ValesCobrados + @Importe4
                IF @FormaCobro5 = @FormaCobroVales
                  SELECT
                    @ValesCobrados = @ValesCobrados + @Importe5
                IF @FormaCobro1 = @FormaCobroTarjetas
                  SELECT
                    @TarjetasCobradas = @TarjetasCobradas + @Importe1
                IF @FormaCobro2 = @FormaCobroTarjetas
                  SELECT
                    @TarjetasCobradas = @TarjetasCobradas + @Importe2
                IF @FormaCobro3 = @FormaCobroTarjetas
                  SELECT
                    @TarjetasCobradas = @TarjetasCobradas + @Importe3
                IF @FormaCobro4 = @FormaCobroTarjetas
                  SELECT
                    @TarjetasCobradas = @TarjetasCobradas + @Importe4
                IF @FormaCobro5 = @FormaCobroTarjetas
                  SELECT
                    @TarjetasCobradas = @TarjetasCobradas + @Importe5
                IF @CfgFormaPagoRequerida = 1
                  IF (
                       @Importe1 > 0.0
                       AND @FormaCobro1 IS NULL
                     )
                    OR (
                         @Importe2 > 0.0
                         AND @FormaCobro2 IS NULL
                       )
                    OR (
                         @Importe3 > 0.0
                         AND @FormaCobro3 IS NULL
                       )
                    OR (
                         @Importe4 > 0.0
                         AND @FormaCobro4 IS NULL
                       )
                    OR (
                         @Importe5 > 0.0
                         AND @FormaCobro5 IS NULL
                       )
                    SELECT
                      @Ok = 30530
                IF @ImporteTotal - ISNULL(@SumaRetencionesNeto, 0.0) < @CobroDesglosado + @CobroDelEfectivo
                  SELECT
                    @CobroCambio = @CobroDesglosado + @CobroDelEfectivo - ( @ImporteTotal - ISNULL(@SumaRetencionesNeto,
                                                                                                   0.0) )
                    - @CobroRedondeo
                IF @ImporteTotal = @CobroDelEfectivo
                  AND @CobroDesglosado <> 0
                  SELECT
                    @Ok = 30100
                IF @ValesCobrados > 0.0
                  OR @TarjetasCobradas <> 0.0
                  BEGIN
                    EXEC spValeValidarCobro @Empresa, @Modulo, @ID, @Accion, @FechaEmision, @ValesCobrados,
                      @TarjetasCobradas, @MovMoneda, @Ok OUTPUT, @OkRef OUTPUT
                    IF @TarjetasCobradas = 0
                      AND EXISTS ( SELECT
                                    *
                                   FROM
                                    TarjetaSerieMov
                                   WHERE
                                    Empresa = @Empresa
                                    AND Modulo = @Modulo
                                    AND ID = @ID
                                    AND ISNULL(Importe, 0) <> 0 )
                      SELECT
                        @Ok = 36171
                    IF @ValesCobrados = 0
                      AND EXISTS ( SELECT
                                    *
                                   FROM
                                    ValeSerieMov
                                   WHERE
                                    Empresa = @Empresa
                                    AND Modulo = @Modulo
                                    AND ID = @ID )
                      SELECT
                        @Ok = 36170
                  END
                IF (
                     @MovTipo IN ( 'VTAS.N', 'VTAS.FM' )
                     AND @CfgVentaLiquidaIntegral = 1
                   )
                  OR (
                       @MovTipo IN ( 'VTAS.F', 'VTAS.FAR' )
                       AND @CfgFacturaCobroIntegrado = 1
                     )
                  OR @MovTipo IN ( 'VTAS.P', 'VTAS.S', 'VTAS.SD', 'VTAS.VP' )
                  SELECT
                    @ValidarCobroIntegrado = 1
                ELSE
                  SELECT
                    @ValidarCobroIntegrado = 0
                IF @CobroDesglosado + @CobroDelEfectivo = 0.0
                  AND @ValidarCobroIntegrado = 0
                  AND @MovID IS NULL
                  SELECT
                    @AfectarConsecutivo = 1
                ELSE
                  BEGIN
                    IF ROUND(@CobroDesglosado + @CobroDelEfectivo, 2) < ROUND(ROUND(@ImporteTotal,
                                                                                    @CfgVentaCobroRedondeoDecimales)
                                                                              - @SumaRetencionesNeto + @CobroRedondeo, 2)
                      AND @Ok IS NULL
                      BEGIN
                        IF ABS(( @ImporteTotal + @CobroRedondeo - @SumaRetencionesNeto ) - ( @CobroDesglosado
                                                                                             + @CobroDelEfectivo )) > 0.01
                          BEGIN
                            SELECT
                              @Ok = 20370,
                              @OkRef = 'Diferencia: ' + LTRIM(CONVERT(VARCHAR, ( @ImporteTotal + @CobroRedondeo
                                                                                 - @SumaRetencionesNeto )
                                                              - ( @CobroDesglosado + @CobroDelEfectivo )))
                            IF @CobroIntegradoParcial = 1
                              SELECT
                                @Ok = NULL,
                                @OkRef = NULL
                          END
                      END
                    IF @ImporteTotal >= 0.0
                      AND ROUND(@CobroCambio, 1) > ROUND(@CobroDesglosado, 1)
                      AND @Ok IS NULL
                      SELECT
                        @Ok = 30250
                    IF @CobroDelEfectivo > 0.0
                      AND @MovTipo NOT IN ( 'VTAS.SD', 'VTAS.VP' )
                      AND @Ok IS NULL
                      BEGIN
                        SELECT
                          @Efectivo = 0.0
                        SELECT
                          @Efectivo = ISNULL(Saldo, 0.0)
                        FROM
                          CxcEfectivo
                        WHERE
                          Empresa = @Empresa
                          AND Cliente = @ClienteProv
                          AND Moneda = @MovMoneda
                        IF ROUND(@CobroDelEfectivo, 0) > ROUND(-@Efectivo, 0)
                          SELECT
                            @Ok = 30090
                      END
                    ELSE
                      IF @CobroDelEfectivo < 0.0
                        SELECT
                          @Ok = 30100
                  END
              END
          END
    END
  IF @Estatus IN ( 'SINAFECTAR', 'BORRADOR', 'CONFIRMAR' )
    AND @Accion NOT IN ( 'CANCELAR', 'GENERAR' )
    AND @Ok IS NULL
    BEGIN
      IF @CfgValidarCC = 1
        AND @Modulo IN ( 'VTAS', 'COMS', 'INV' )
        BEGIN
          SELECT
            @ContUso = NULL
          IF @Modulo = 'VTAS'
            BEGIN
              IF @ContUso IS NULL
                SELECT
                  @ContUso = MIN(d.ContUso)
                FROM
                  VentaD d
                WHERE
                  d.ID = @ID
                  AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                  AND d.ContUso NOT IN ( SELECT
                                          v.CentroCostos
                                         FROM
                                          CentroCostosEmpresa v
                                         WHERE
                                          v.Empresa = @Empresa )
              IF @ContUso IS NULL
                SELECT
                  @ContUso = MIN(d.ContUso)
                FROM
                  VentaD d
                WHERE
                  d.ID = @ID
                  AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                  AND d.ContUso NOT IN ( SELECT
                                          v.CentroCostos
                                         FROM
                                          CentroCostosSucursal v
                                         WHERE
                                          v.Sucursal = @Sucursal )
              IF @ContUso IS NULL
                SELECT
                  @ContUso = MIN(d.ContUso)
                FROM
                  VentaD d
                WHERE
                  d.ID = @ID
                  AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                  AND d.ContUso NOT IN ( SELECT
                                          v.CentroCostos
                                         FROM
                                          CentroCostosUsuario v
                                         WHERE
                                          v.Usuario = @Usuario )
            END
          ELSE
            IF @Modulo = 'COMS'
              BEGIN
                IF @ContUso IS NULL
                  SELECT
                    @ContUso = MIN(d.ContUso)
                  FROM
                    CompraD d
                  WHERE
                    d.ID = @ID
                    AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                    AND d.ContUso NOT IN ( SELECT
                                            v.CentroCostos
                                           FROM
                                            CentroCostosEmpresa v
                                           WHERE
                                            v.Empresa = @Empresa )
                IF @ContUso IS NULL
                  SELECT
                    @ContUso = MIN(d.ContUso)
                  FROM
                    CompraD d
                  WHERE
                    d.ID = @ID
                    AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                    AND d.ContUso NOT IN ( SELECT
                                            v.CentroCostos
                                           FROM
                                            CentroCostosSucursal v
                                           WHERE
                                            v.Sucursal = @Sucursal )
                IF @ContUso IS NULL
                  SELECT
                    @ContUso = MIN(d.ContUso)
                  FROM
                    CompraD d
                  WHERE
                    d.ID = @ID
                    AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                    AND d.ContUso NOT IN ( SELECT
                                            v.CentroCostos
                                           FROM
                                            CentroCostosUsuario v
                                           WHERE
                                            v.Usuario = @Usuario )
              END
            ELSE
              IF @Modulo = 'INV'
                BEGIN
                  IF @ContUso IS NULL
                    SELECT
                      @ContUso = MIN(d.ContUso)
                    FROM
                      InvD d
                    WHERE
                      d.ID = @ID
                      AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                      AND d.ContUso NOT IN ( SELECT
                                              v.CentroCostos
                                             FROM
                                              CentroCostosEmpresa v
                                             WHERE
                                              v.Empresa = @Empresa )
                  IF @ContUso IS NULL
                    SELECT
                      @ContUso = MIN(d.ContUso)
                    FROM
                      InvD d
                    WHERE
                      d.ID = @ID
                      AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                      AND d.ContUso NOT IN ( SELECT
                                              v.CentroCostos
                                             FROM
                                              CentroCostosSucursal v
                                             WHERE
                                              v.Sucursal = @Sucursal )
                  IF @ContUso IS NULL
                    SELECT
                      @ContUso = MIN(d.ContUso)
                    FROM
                      InvD d
                    WHERE
                      d.ID = @ID
                      AND NULLIF(RTRIM(d.ContUso), '') IS NOT NULL
                      AND d.ContUso NOT IN ( SELECT
                                              v.CentroCostos
                                             FROM
                                              CentroCostosUsuario v
                                             WHERE
                                              v.Usuario = @Usuario )
                END
          IF @ContUso IS NOT NULL
            SELECT
              @Ok = 20765,
              @OkRef = @ContUso
        END
      IF @CfgVentaRestringida = 1
        AND @MovTipo IN ( 'VTAS.F', 'VTAS.FAR', 'VTAS.FB', 'VTAS.FM', 'VTAS.N' )
        AND @Ok IS NULL
        AND @Accion NOT IN ( 'GENERAR', 'CANCELAR' )
        EXEC spVentaRestringida @ID, @Accion, @Empresa, @Ok OUTPUT, @OkRef OUTPUT
      IF @CfgRestringirArtBloqueados = 1
        AND @Modulo IN ( 'VTAS', 'COMS' )
        AND @Ok IS NULL
        BEGIN
          SELECT
            @OkRef = NULL
          IF @Modulo = 'VTAS'
            SELECT
              @OkRef = MIN(d.Articulo)
            FROM
              VentaD d,
              Art a
            WHERE
              d.ID = @ID
              AND d.Articulo = a.Articulo
              AND a.Estatus = 'BLOQUEADO'
          ELSE
            IF @Modulo = 'COMS'
              SELECT
                @OkRef = MIN(d.Articulo)
              FROM
                CompraD d,
                Art a
              WHERE
                d.ID = @ID
                AND d.Articulo = a.Articulo
                AND a.Estatus = 'BLOQUEADO'
          IF @OkRef IS NOT NULL
            SELECT
              @Ok = 26110
        END
    END
  IF @MovTipo = 'VTAS.CTO'
    IF EXISTS ( SELECT
                  *
                FROM
                  Venta
                WHERE
                  ID = @ID
                  AND (
                        ConVigencia = 0
                        OR VigenciaDesde IS NULL
                        OR VigenciaHasta IS NULL
                        OR VigenciaHasta < VigenciaDesde
                      ) )
      SELECT
        @Ok = 10095
  IF @MovTipo = 'PROD.E'
    AND @Accion NOT IN ( 'GENERAR', 'CANCELAR' )
    AND @Ok IS NULL
    IF EXISTS ( SELECT
                  *
                FROM
                  ProdD
                WHERE
                  ID = @ID
                  AND NULLIF(RTRIM(Tipo), '') IS NULL )
      SELECT
        @Ok = 25390
  IF (
       @MovTipo IN ( 'COMS.F', 'COMS.FL', 'COMS.EG', 'COMS.EI' )
       OR (
            @CfgCompraValidarPresupuesto = 'ORDEN COMPRA'
            AND @MovTipo = 'COMS.O'
          )
       OR (
            @MovTipo = 'COMS.O'
            AND @CfgCompraValidarPresupuestoMov IN ( 'REQUISICION', 'ORDEN COMPRA' )
          )
       OR (
            @MovTipo = 'COMS.R'
            AND @CfgCompraValidarPresupuestoMov = 'REQUISICION'
          )
     )
    AND @Accion NOT IN ( 'GENERAR', 'CANCELAR' )
    AND @Ok IS NULL
    AND (
          @Autorizacion IS NULL
          OR @Mensaje NOT IN ( 20900, 20901, 20265 )
        )
    BEGIN
      IF @CfgCompraPresupuestosCategoria = 1
        EXEC spCompraValidarPresupuestoCategoria @Empresa, @ID, @FechaEmision, @Ok OUTPUT, @OkRef OUTPUT
      ELSE
        EXEC spCompraValidarPresupuesto @Empresa, @ID, @FechaEmision, @Ok OUTPUT, @OkRef OUTPUT
      IF @Ok IS NOT NULL
        SELECT
          @Autorizar = 1
    END
  IF @Ok IS NULL
    EXEC spProdSerieLoteDesdeOrdenVerificar @Sucursal, @Modulo, @ID, @Accion, @EstatusNuevo, @Ok OUTPUT, @OkRef OUTPUT
  RETURN
END

GO

