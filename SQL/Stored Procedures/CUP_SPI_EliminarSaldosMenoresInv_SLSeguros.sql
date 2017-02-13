SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS (SELECT * 
		   FROM SYSOBJECTS 
		   WHERE ID = OBJECT_ID('dbo.CUP_SPI_EliminarSaldosMenoresInv_SLSeguros') AND 
				 TYPE = 'P')
BEGIN
  DROP PROCEDURE dbo.CUP_SPI_EliminarSaldosMenoresInv_SLSeguros
END	

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-13

  Description: Procedimiento almacenado encargado de preparar
  los Ajustes que eliminaran los saldos menores SL que son seguros.
  Es decir, aquellos donde no  deberiamos esperar problemas o procesos especiales.

============================================= */

CREATE PROCEDURE dbo.CUP_SPI_EliminarSaldosMenoresInv_SLSeguros
  @ProcesoID INT,
  @ID INT,
  @CantidadSegura FLOAT
AS BEGIN 

      DECLARE @AjustesGenerados TABLE
      (
        ID INT NOT NULL
      )
  
      INSERT INTO Inv
      (
        Empresa,
        Sucursal,
        Mov,
        Estatus,
        FechaEmision,
        FechaRegistro,
        Concepto,
        Moneda,
        TipoCambio,
        Almacen,
        Usuario,
        CUP_Origen,
        CUP_OrigenID
      )
      OUTPUT 
        INSERTED.ID
      INTO @AjustesGenerados
      (
        ID
      )
      SELECT DISTINCT 
          su.Empresa,
          su.Sucursal,
          Mov = 'Ajuste',
          Estatus = 'SINAFECTAR',
          FechaEmision = CAST(GETDATE() AS DATE),
          FechaRegistro = GETDATE(),
          Concepto = 'Ajuste por saldos Menores',
          Moneda = 'Pesos',
          TipoCambio = 1,
          su.Almacen,
          Usuario = 'PRODAUT',
          CUP_Origen = @ProcesoID,
          CUP_OrigenID  = @ID
      FROM 
        #tmp_CUP_SaldosMenoresSU su
      WHERE 
        su.Escenario = 2

      -- Guarda el registro del ajuste generado junto con su tipo.
      INSERT INTO
        CUP_EliminarSaldosMenoresInv_AjustesGenerados
      (
        ID,
        Modulo,
        ModuloID,
        Escenario
      )
      SELECT 
        @ID,
        Modulo = 'INV',
        ModuloID = ag.ID,
        2
      FROM 
        @AjustesGenerados ag

      -- Inserta el detalle de los movimientos.
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
        i.ID, 
        Renglon = CAST(   2048 
                        * ROW_NUMBER() OVER (
                                              ORDER BY
                                                i.ID,
                                                su.Articulo,
                                                su.Subcuenta
                                             ) 
                       AS FLOAT),  --(de 2048 en 2048)
        RenglonSub= ROW_NUMBER() OVER (
                                        PARTITION BY
                                          i.ID,
                                          su.Articulo,
                                          su.Subcuenta 
                                        ORDER BY
                                          su.Subcuenta
                                        ) - 1, 
        RenglonID = ROW_NUMBER() OVER (
                                        ORDER BY
                                          i.ID,
                                          su.Articulo,
                                          su.Subcuenta
                                       ),                        
        RenglonTipo = dbo.fnRenglonTipo(a.Tipo),                                                
        Cantidad =  ISNULL(su.ExistenciaSLMenor,0) * -1 , 
        Almacen = i.Almacen, 
        Articulo = su.Articulo, 
        SubCuenta = NULLIF(su.Subcuenta,''),
        su.Costo,  
        Unidad = a.Unidad,
        Factor = 1,
        CantidadInventario = ISNULL(su.ExistenciaSLMenor,0) * -1, 
        Sucursal = su.Sucursal  
      FROM 
        CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
      JOIN Inv i ON 'INV' = ajm.Modulo
                AND i.Id = ajm.ModuloID
      JOIN #tmp_CUP_SaldosMenoresSU su ON su.Escenario = ajm.Escenario  
                                      AND su.Empresa = i.Empresa
                                      AND su.Sucursal = i.Sucursal
                                      AND su.Almacen = i.Almacen
      JOIN art a ON a.Articulo = su.Articulo                
      WHERE 
          ajm.ID = @ID
      AND ajm.Modulo = 'INV'
      AND ajm.Escenario = 2

      -- Actualiza el Renglon Maximo del cabecero.
      UPDATE i 
      SET RenglonID = (SELECT MAX(d.RenglonID)
                        FROM InvD d 
                        WHERE d.ID = i.ID)
      FROM
        CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
      JOIN inv i ON i.ID = ajm.ModuloID
      WHERE 
        ajm.Id = @ID 
      AND ajm.Modulo = 'INV'
      AND ajm.Escenario = 2

      --SeriesLote
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
        i.Empresa, 
        ajm.Modulo,
        ajm.ModuloID,
        d.RenglonID,
        d.Articulo,
        Subcuenta = ISNULL(d.Subcuenta,''),
        sl.SerieLote,
        sl.Existencia,
        sl.Propiedades,
        i.Sucursal
      FROM
        CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
      JOIN Inv i ON  i.Id = ajm.ModuloID
      JOIN InvD d ON d.ID = i.ID   
      JOIN #tmp_CUP_ArtExistenciasSL sl ON i.Empresa = sl.Empresa
                                        AND i.Sucursal = sl.Sucursal
                                        AND i.Almacen = sl.Almacen
                                        AND d.Articulo = sl.Articulo
                                        AND ISNULL(d.SubCuenta,'') = ISNULL(sl.Subcuenta,'')
      WHERE
        ajm.ID = @ID
      AND ajm.Modulo = 'INV'
      AND ajm.Escenario = 2
      AND d.RenglonTipo IN ('S','L')
      AND ABS(ISNULL(sl.Existencia,0)) < @CantidadSegura

END