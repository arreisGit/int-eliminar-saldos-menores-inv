/********************* CONFIGURAR SQL SERVER **********************************/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * 
		   FROM SYSOBJECTS 
		   WHERE ID = OBJECT_ID('dbo.CUP_SPP_EliminarSaldosMenoresSL') AND 
				 TYPE = 'P') BEGIN
				 
	 DROP PROCEDURE dbo.CUP_SPP_EliminarSaldosMenoresSL
		  
END	
GO 

/*
  -- Ejemplo Llamado.
  EXEC CUP_SPP_EliminarSaldosMenoresSL 'ESIERRA',1      
*/


CREATE PROCEDURE [dbo].[CUP_SPP_EliminarSaldosMenoresSL] 
  @Usuario CHAR(10),
  @Verbose BIT = 0
AS BEGIN TRY

  DECLARE 
    @UsuarioAfectar VARCHAR(10) = 'PRODAUT',
    @HOY DATE = GETDATE(),
    @MonedaCosteo VARCHAR(10),
    @TipoCambio FLOAT,
    @Ejercicio INT,
    @Periodo INT,
    @r_Empresa  CHAR(5),
    @r_Sucursal INT,
    @r_Almacen CHAR(10),
    @r_AjusteID INT,   
    @r_RenglonID INT,
    @r_Articulo CHAR(20),
    @r_Subcuenta VARCHAR(20),
    @r_CantidadInv DECIMAL(18,4),
    @r_SerieLote VARCHAR(50),
    @r_Propiedades VARCHAR(20),
    @r_ExistenciaSL DECIMAL(18,4),
    @MensajeID INT

  DECLARE @ResultadoAfectar Table 
  (
    RegID INT PRIMARY KEY IDENTITY(1,1),
    Modulo    CHAR(5),
    ModuloID  INT,
    Almacen   CHAR(10),
    Ok        INT,      
    OkDesc    VARCHAR(255),      
    OKTipo    VARCHAR(50),      
    OkRef     VARCHAR(255),      
    IDGenerar INT
  )      

  -- Tabla para contener el resumen del SaldoU del art vs La suma de sus
  -- saldos menores Series Lote.
  IF OBJECT_ID('tempdb..#SaldoU_vs_SaldosSLM') IS NOT NULL
    DROP TABLE #SaldoU_vs_SaldosSLM

  CREATE TABLE #SaldoU_vs_SaldosSLM
  (
    Empresa                   CHAR(5)        NOT NULL,
    Sucursal                  INT            NOT NULL,
    Almacen                   CHAR(10)       NOT NULL,
    Articulo                  CHAR(20)       NOT NULL ,
    Subcuenta                 VARCHAR(20)    NULL,
    SaldoU                    DECIMAL(30,16) NOT NULL,
    SaldoUReal                DECIMAL(18,4)  NOT NULL,
    SaldoURemanente           DECIMAL(30,16) NOT NULL,
    SaldoUDisponible          DECIMAL(30,16) NOT NULL,
    SaldoUDisponibleReal      DECIMAL(18,4)  NOT NULL,
    SaldoUDisponibleRemanente DECIMAL(30,16) NOT NULL,
    SaldoSLMenor              DECIMAL(30,16) NOT NULL,
    SaldoSLMenorReal          DECIMAL(18,4)  NOT NULL,
    SaldoSLMenorRemanente     DECIMAL(30,16) NOT NULL
  )

  CREATE INDEX IDX_C_SUvsSM_SucAlmArtSub
  ON #SaldoU_vs_SaldosSLM (Sucursal,Almacen,Articulo,Subcuenta) 
  INCLUDE
  (
    SaldoU,
    SaldoUReal,
    SaldoURemanente,
    SaldoUDisponible,
    SaldoUDisponibleReal,
    SaldoUDisponibleRemanente,
    SaldoSLMenor,
    SaldoSLMenorReal,
    SaldoSLMenorRemanente
  )
  
  EXEC spReconstruirArtR


  -- 2 )  Perepara la informacion sobre los saldos SerieLote
  EXEC CUP_SPI_SaldosMenoresSL @Usuario, 0


  ;WITH SaldosMenoresSL
  (
    Empresa,
    Sucursal,
    Almacen,
    Articulo,
    Subcuenta,
    SaldoSLMenor,
    SaldoSLMenorReal,
    SaldoSLMenorRemanente
  )
  AS 
  (
    SELECT   
      slm.Empresa,
      slm.Sucursal,
      slm.Almacen,
      slm.Articulo,
      slm.Subcuenta,
      SaldoSLMenor = SUM(ISNULL(slm.Existencia,0)),
      SaldoSLMenorReal = SUM(ISNULL(slm.ExistenciaReal,0)),
      SaldoSLMenorRemanente = SUM(ISNULL(slm.ExistenciaRemanente,0))
    FROM 
      CUP_EliminarSaldosMenoresSL slm
    JOIN Art a On a.Articulo = slm.Articulo
    WHERE 
      slm.Usuario = @Usuario
    AND a.UnidadTraspaso = 'KGS'
    AND a.Categoria IN( 'ALUMINIO','ACERO INOX')
    AND ISNULL(a.Grupo,'') IN( 
                              'Lamina',
                              'Placa',
                              'Placa Alum',
                              ''
                              )
    GROUP BY 
      slm.Empresa,
      slm.Sucursal,
      slm.Almacen,
      slm.Articulo,
      slm.Subcuenta
  ) 

  INSERT INTO #SaldoU_vs_SaldosSLM
  (
    Empresa,
    Sucursal,
    Almacen,
    Articulo,
    Subcuenta,
    SaldoU,
    SaldoUReal,
    SaldoURemanente,
    SaldoUDisponible,
    SaldoUDisponibleReal,
    SaldoUDisponibleRemanente,
    SaldoSLMenor,
    SaldoSLMenorReal,
    SaldoSLMenorRemanente
  )
  SELECT 
    sm.Empresa,
    sm.Sucursal,
    sm.Almacen,
    sm.Articulo,
    sm.SubCuenta,
    SaldoU = ISNULL(su.SaldoU,0),
    SaldoUReal = ROUND(ISNULL(su.SaldoU,0),4,1),
    SaldoURemanente = ISNULL(su.SaldoU,0) - ROUND(ISNULL(su.SaldoU,0),4,1),
    SaldoUDisponible = ISNULL(dis.Disponible,0),
    SaldoUDisponibleReal = ROUND(ISNULL(dis.Disponible,0),4,1),
    SaldoUDisponibleRemanente = ISNULL(dis.Disponible,0) - ROUND(ISNULL(dis.Disponible,0),4,1) ,
    SaldoSLMenor = ISNULL(sm.SaldoSLMenor,0),
    SaldoSLMenorReal = ISNULL(sm.SaldoSLMenorReal,0),
    SaldoSLRemanente = ISNULL(sm.SaldoSLMenorRemanente,0)
  FROM
     SaldosMenoresSL sm
 JOIN SaldoU su ON  su.Rama = 'INV'
                AND su.Moneda = 'Pesos'
                AND su.Empresa              = sm.Empresa 
                AND su.Sucursal             = sm.Sucursal
                AND su.Grupo                = sm.Almacen
                AND su.Cuenta               = sm.Articulo
                AND ISNULL(su.SubCuenta,'') = ISNULL(sm.SubCuenta,'')
 OUTER APPLY(
              SELECT 
                Disponible = SUM(s.SaldoU * r.Factor) 
              FROM
                SaldoU s 
              JOIN Rama r ON s.SubCuenta is NOT NULL 
                        AND s.Rama=r.Rama 
                        AND r.Mayor = 'INV'
              WHERE  
                s.Empresa = sm.Empresa
              AND s.Sucursal =  sm.Sucursal
              AND s.Grupo = sm.Almacen
              AND s.Cuenta  = sm.Articulo
              AND s.SubCuenta = ISNULL(sm.Subcuenta,'')
            )  dis

  -- Movimientos de Ajuste.
  IF @@ROWCOUNT > 0 
  AND EXISTS(SELECT Articulo 
             FROM #SaldoU_vs_SaldosSLM 
             WHERE SaldoUDisponibleReal > 0 
               AND SaldoSLMenorReal > 0)
  BEGIN      
   
    BEGIN TRANSACTION    
                
    -- Creamos un cursor para poder insertar un ajuste por cada 
    -- Suc/Alm distinto.
    DECLARE crSucAlm CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT
      Empresa,
      Sucursal,
      Almacen 
    FROM
      dbo.CUP_EliminarSaldosMenoresSL sl 
    WHERE 
      sl.Usuario = @Usuario
    AND EXISTS(SELECT vs.Articulo 
               FROM #SaldoU_vs_SaldosSLM vs
               WHERE vs.Empresa = sl.Empresa
               AND   vs.Sucursal = sl.Sucursal
               AND   vs.Almacen = sl.Almacen
               AND   vs.SaldoUDisponibleReal > 0 
               AND   vs.SaldoSLMenorReal > 0)

    OPEN crSucAlm

    FETCH NEXT FROM  crSucAlm INTO  @r_Empresa, @r_Sucursal,@r_Almacen

    WHILE @@FETCH_STATUS = 0
    BEGIN
  
        SELECT @r_AjusteID = NULL, @MensajeID = NULL

        SELECT 
          @MonedaCosteo = MonedaCosteo,
          @TipoCambio = Mon.TipoCambio,
          @Ejercicio = YEAR(@HOY),
          @Periodo = MONTH(@HOY)
        FROM 
          EmpresaCFG e
        JOIN Mon ON e.MonedaCosteo = Mon.Moneda
        WHERE 
          e.Empresa = @r_Empresa
          
        --Insertamo el Encabezado del Ajuste.
        INSERT INTO INV 
        (
          Empresa,
          Mov,
          FechaEmision,
          UltimoCambio,
          Concepto,
          Moneda,
          TipoCambio,
          Usuario,
          Observaciones,
          Estatus,
          Almacen,
          Directo,
          Periodo,
          Ejercicio,
          Sucursal
         )  
			  SELECT
          Empresa = @r_Empresa, 
          Mov ='Ajuste', 
          FechaEmision = @Hoy, 
          UltimoCambio = @Hoy, 
          Concepto ='Ajuste por saldos menores', 
          Moneda = @MonedaCosteo, 
          TipoCambio = @TipoCambio, 
          Usuario = @Usuario, 
          Observaciones = 'Mediante proceso automático',
          Estatus = 'SINAFECTAR', 
          Almacen = @r_Almacen, 
          Directo = 1,
          Periodo = @Periodo,
          Ejercicio = @Ejercicio, 
          Sucursal = @r_Sucursal
      
      --Obtenemos el ID del Ajuste
      SET @r_AjusteID = SCOPE_IDENTITY()

      IF @r_AjusteID IS NOT NULL
      BEGIN
     
        --Insertamos el detalle del Ajuste
        INSERT INTO InvD 
        ( 
          ID,
          Renglon,
          RenglonSub,
          RenglonID,
          RenglonTipo,
          Cantidad,
          Almacen,
          Articulo,
          SubCuenta,
          Costo,
          Unidad,
          Factor,
          CantidadInventario,
          Sucursal 
        )  
		    SELECT 
          ID = @r_AjusteID, 
          Renglon = CAST(2048 * ROW_NUMBER() OVER (ORDER BY vs.Articulo,vs.Subcuenta) AS FLOAT),  --(de 2048 en 2048)
          RenglonSub= ROW_NUMBER() OVER (PARTITION BY vs.Articulo,vs.Subcuenta ORDER BY vs.Subcuenta) - 1, 
          RenglonID = ROW_NUMBER() OVER (ORDER BY vs.Articulo,vs.Subcuenta),                        
          RenglonTipo = dbo.fnRenglonTipo(a.Tipo),                                                
          Cantidad = CASE 
                       WHEN ISNULL(vs.SaldoUDisponibleReal,0) > ISNULL(vs.SaldoSLMenorReal,0) THEN 
                         ISNULL(vs.SaldoSLMenorReal,0) 
                       ELSE 
                         ISNULL(vs.SaldoUDisponibleReal,0)
                     END * -1, 
          Almacen = vs.Almacen, 
          Articulo = vs.Articulo, 
          SubCuenta = vs.Subcuenta, 
          Costo = CASE -- Costo. ** Basarse en lo que hace el  spVerCosto ** 
                    WHEN a.MonedaCosto = @MonedaCosteo THEN  
                        Round(ISNULL(ac.CostoPromedio,ISNULL(ace.CostoPromedio,0)),4)
                    ELSE 
                      CASE 
                        WHEN  a.MonedaCosto = 'Pesos' THEN 
                            ROUND(ISNULL(ac.CostoPromedio,ISNULL(ace.CostoPromedio,0))  / @TipoCambio,4)
                        ELSE 
                            ROUND(ISNULL(ac.CostoPromedio,ISNULL(ace.CostoPromedio,0)) / mcosto.TipoCambio,4) *  ROUND(@TipoCambio,4)
                      END 
                  END,  
          Unidad = a.UnidadTraspaso,
          Factor = 1,
          CantidadInventario = CASE 
                                 WHEN ISNULL(vs.SaldoUDisponibleReal,0) > ISNULL(vs.SaldoSLMenorReal,0) THEN 
                                   ISNULL(vs.SaldoSLMenorReal,0) 
                                 ELSE 
                                   ISNULL(vs.SaldoUDisponibleReal,0)
                               END * -1, 
          Sucursal = vs.Sucursal  
        FROM 
          #SaldoU_vs_SaldosSLM vs
        JOIN art a ON vs.Articulo = a.Articulo   
        left OUTER JOIN ArtCosto ac ON vs.Articulo = ac.Articulo
                                    AND vs.Sucursal = ac.Sucursal
                                    AND vs.Empresa = ac.Empresa
        LEFT OUTER JOIN ArtCostoEmpresa ace ON vs.Articulo = ace.Articulo
                                           AND vs.Empresa = ace.Empresa
        JOIN mon mcosto ON a.MonedaCosto = mcosto.Moneda                    
        WHERE 
          vs.Empresa = @r_Empresa
        AND vs.Sucursal = @r_Sucursal
        AND vs.Almacen = @r_Almacen
        AND ISNULL(vs.SaldoUDisponibleReal,0) > 0
        AND ISNULL(vs.SaldoSLMenorReal,0) > 0

        UPDATE i 
        SET RenglonID = (SELECT MAX(d.RenglonID)
                         FROM InvD d 
                         WHERE d.ID = i.ID)
        FROM inv i 
        WHERE i.ID = @r_AjusteID

        -- Todos los series lote que sumados den una existencia Total menor o igual a el saldoU
        -- se pueden insertar al vuelo
        INSERT INTO SerieLoteMov 
        (
          Empresa,
          Modulo,
          ID,
          RenglonID,
          Articulo,
          SubCuenta,
          SerieLote,
          Cantidad,
          Propiedades,
          Sucursal
        )  
			  SELECT 
            @r_Empresa, 
            'INV',
            d.ID,
            d.RenglonID,
            d.Articulo,
            d.Subcuenta,
            esm.SerieLote,
            esm.ExistenciaReal,
            esm.Propiedades,
            d.Sucursal
        FROM
          InvD  d  
        JOIN #SaldoU_vs_SaldosSLM vs ON @r_Empresa = vs.Empresa
                                       AND d.Sucursal = vs.Sucursal
                                       AND d.Almacen = vs.Almacen
                                       AND d.Articulo = vs.Articulo
                                       AND ISNULL(d.SubCuenta,'') = ISNULL(vs.Subcuenta,'')
        JOIN dbo.CUP_EliminarSaldosMenoresSL esm ON @r_Empresa = esm.Empresa
                                                 AND d.Sucursal = esm.Sucursal
                                                 AND d.Almacen = esm.Almacen
                                                 AND d.Articulo = esm.Articulo
                                                 AND ISNULL(d.SubCuenta,'') = ISNULL(esm.Subcuenta,'')
        WHERE
          d.Id = @r_AjusteID
        AND ISNULL(vs.SaldoUDisponibleReal,0) >= ISNULL(vs.SaldoSLMenorReal,0)
        AND ISNULL(esm.ExistenciaReal,0) > 0

       -- Por el contrario, cuando la suma de la existencia de los Series Lote  es mayor que el saldo del articulo,
       -- se debe ir descontando el saldo hasta agotar la existencia.
       DECLARE cr_ArtConSaldoMenorSL CURSOR LOCAL FAST_FORWARD FOR
       SELECT 
            d.RenglonID,
            d.Articulo,
            d.Subcuenta,
            ABS(d.CantidadInventario)
        FROM
          InvD  d  
        JOIN #SaldoU_vs_SaldosSLM vs ON @r_Empresa = vs.Empresa
                                  AND d.Sucursal = vs.Sucursal
                                  AND d.Almacen = vs.Almacen
                                  AND d.Articulo = vs.Articulo
                                  AND ISNULL(d.SubCuenta,'') = ISNULL(vs.Subcuenta,'')
        WHERE
          d.Id = @r_AjusteID
        AND ISNULL(vs.SaldoUDisponibleReal,0) < ISNULL(vs.SaldoSLMenorReal,0)
        AND ISNULL(vs.SaldoSLMenorReal,0) > 0
      
        OPEN cr_ArtConSaldoMenorSL
      
        FETCH NEXT FROM cr_ArtConSaldoMenorSL INTO  @r_RenglonId,@r_Articulo,@r_Subcuenta,@r_CantidadInv
      
        WHILE @@FETCH_STATUS = 0
        BEGIN
          
          -- Recorremos los series lote del articulo para agotar la existencia.
          DECLARE cr_ArtSeriesLote CURSOR LOCAL FAST_FORWARD FOR 
          SELECT 
            esm.SerieLote,
            esm.Propiedades,
            esm.ExistenciaReal
          FROM 
            dbo.CUP_EliminarSaldosMenoresSL esm
          WHERE 
            esm.Empresa = @r_Empresa
          AND esm.Sucursal = @r_Sucursal
          AND esm.Almacen = @r_Almacen
          AND esm.Articulo = @r_Articulo
          AND ISNULL(esm.Subcuenta,'') = ISNULL(@r_Subcuenta,'')
          AND ISNULL(esm.ExistenciaReal,0) > 0

          OPEN cr_ArtSeriesLote 

          FETCH NEXT FROM cr_ArtSeriesLote INTO @r_SerieLote,@r_Propiedades,@r_ExistenciaSL 

          WHILE @@FETCH_STATUS = 0
          AND ISNULL(@r_CantidadInv,0) > 0 
          BEGIN
            
            IF @r_ExistenciaSL > @r_CantidadInv
            BEGIN
              SET @r_ExistenciaSL = @r_CantidadInv
              SET @r_CantidadInv = 0
            END 
            ELSE 
            BEGIN
              SET @r_CantidadInv -= @r_ExistenciaSL
            END

            IF ISNULL(@r_ExistenciaSL,0) > 0
            BEGIN
              INSERT INTO SerieLoteMov 
              (
                Empresa,
                Modulo,
                ID,
                RenglonID,
                Articulo,
                SubCuenta,
                SerieLote,
                Cantidad,
                Propiedades,
                Sucursal
              )  
			        SELECT 
                Empresa = @r_Empresa, 
                Modulo = 'INV',
                Id = @r_AjusteID,
                RengloNID = @r_RenglonID,
                Articulo = @r_Articulo,
                Subcuenta = @r_Subcuenta,
                SerieLote = @r_SerieLote,
                Cantidad =  @r_ExistenciaSL,
                Propiedades = @r_Propiedades,
                Sucursal = @r_Sucursal
            END
            
            FETCH NEXT FROM cr_ArtSeriesLote INTO @r_SerieLote,@r_Propiedades,@r_ExistenciaSL 

          END 

          CLOSE cr_ArtSeriesLote

          DEALLOCATE cr_ArtSeriesLote

          FETCH NEXT FROM cr_ArtConSaldoMenorSL INTO  @r_RenglonId,@r_Articulo,@r_Subcuenta,@r_CantidadInv
        END 
      
        CLOSE cr_ArtConSaldoMenorSL
      
        DEALLOCATE cr_ArtConSaldoMenorSL 

        -- Afecta el ajuste recien creado y guardamos el resultado.
        INSERT INTO @ResultadoAfectar( OK, OKDesc, OKTipo, OkRef, IDGenerar)
        EXEC spAfectar 'INV', @r_AjusteID , 'AFECTAR', 'TODO', NULL, 'PRODAUT',0,0

        SELECT @MensajeID = SCOPE_IDENTITY()

        UPDATE @ResultadoAfectar SET Modulo = 'INV',ModuloID = @r_AjusteID, Almacen = @r_Almacen WHERE RegID = @MensajeID

      END

      FETCH NEXT FROM crSucAlm INTO @r_Empresa,@r_Sucursal,@r_Almacen
    END

    CLOSE crSucAlm

    DEALLOCATE crSucAlm
    
    -- * Redondear los saldo u y series lote a 4 decimales.
    -- * Los Series Lote 
    IF XACT_STATE() = 1 
      COMMIT TRANSACTION
        
    --Reconstruimos ArtR al final para reflejar los cambios
    EXEC spReconstruirArtR

    DELETE CUP_EliminarSaldosMenoresSL WHERE Usuario = @Usuario

  END
    
  IF ISNULL(@Verbose,1) = 1
  BEGIN
    SELECT
      RegID,
      Modulo,
      ModuloID,
      Almacen,
      Ok,
      OkDesc,
      OKTipo,
      OkRef,
      IDGenerar
    FROM
      @ResultadoAfectar
  END
  RETURN
END TRY 
BEGIN CATCH

  IF (XACT_STATE()) IN (-1,1)
  BEGIN
    ROLLBACK TRANSACTION
        
    PRINT 'The transaction is in an uncommittable state.' +
          ' Rolling back transaction.'
  END;
  
  SELECT Error =  ERROR_MESSAGE()

END CATCH;

GO


