SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS (SELECT * 
		   FROM SYSOBJECTS 
		   WHERE ID = OBJECT_ID('dbo.CUP_SPQ_EliminarSaldosMenoresInv_ResultadoDelProceso') AND 
				 TYPE = 'P')
BEGIN
  DROP PROCEDURE dbo.CUP_SPQ_EliminarSaldosMenoresInv_ResultadoDelProceso
END	

GO

/* =============================================

  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-10

  Description: Devuelve el resultado de un proceso
  de eliminacion de saldos menores inv.

  EXAMPLE: EXEC CUP_SPQ_EliminarSaldosMenoresInv_ResultadoDelProceso 1
 
============================================= */

CREATE PROCEDURE dbo.CUP_SPQ_EliminarSaldosMenoresInv_ResultadoDelProceso
  @ID INT
AS BEGIN 

  SELECT
    proceso.ID,
    proceso.Usuario,
    proceso_ajustes.Modulo,
    proceso_ajustes.ModuloId,
    Sucursal = suc.CUP_Alias,
    i.Mov,
    i.Movid,
    i.Almacen,
    i.Estatus,
    FechaAfectacion = CONVERT( VARCHAR(MAX), ab.FechaRegistro, 121),
    PartidasAfectadas = ISNULL(totales_detalle.Partidas,0),
    KgsTotales_Detalle = ISNULL(totales_detalle.KgsTotales,0),
    SeriesLoteAfectados = ISNULL(totales_sl.SeriesLote,0),
    KgsTotales_SerieLote = ISNULL(totales_sl.KgsTotales,0),
    CostoTotal = ISNULL(totales_detalle.CostoTotal,0),
    Cant_Mas_Pequeña_Detalle = ISNULL(totales_detalle.CantMasPequeña,0),
    Cant_Mas_Pequeña_SerieLote = ISNULL(totales_detalle.CantMasGrande,0),
    Cant_Mas_Grande_Detalle = ISNULL(totales_sl.CantMasPequeña,0),
    Cant_Mas_Grande_SerieLote = ISNULL(totales_sl.CantMasGrande,0),
    Error = ISNULL(CAST(ab.Ok AS VARCHAR(MAX)),''),
    ErrorRef = ISNULL(ab.OkRef,''),
    ErrorDescripcion = ISNULL(m.Descripcion,'')
  FROM
    CUP_EliminarSaldosMenoresInv proceso
  JOIN CUP_EliminarSaldosMenoresInv_AjustesGenerados proceso_ajustes ON proceso_ajustes.ID = proceso.ID
  JOIN inv i ON i.ID = proceso_ajustes.ModuloID
  JOIN Sucursal suc ON suc.Sucursal = i.Sucursal
  LEFT JOIN AfectarBitacora ab ON ab.Modulo = proceso_ajustes.Modulo
                              AND ab.ModuloID = proceso_ajustes.ModuloID
  LEFT JOIN MensajeLista m ON m.Mensaje = ab.OK
  OUTER APPLY(
               SELECT 
                 Partidas = COUNT(d.RenglonID),
                 CantMasGrande = MAX(ISNULL(d.Cantidad,0)),
                 CantMasPequeña= MIN(ISNULL(d.Cantidad,0)),
                 CostoTotal = SUM(ISNULL(d.Cantidad,0) * ISNULL(d.Costo,0)),
                 KgsTotales = SUM
                              (
                                  ISNULL(d.Cantidad,0)
                                * CASE ISNULL(a.Unidad,'')
                                    WHEN 'KGS'
                                      THEN 1
                                    ELSE
                                      ISNULL(a.Peso,1)
                                  END
                              )
               FROM 
                 InvD d
               JOIN art a ON a.Articulo = d.Articulo
               WHERE 
                d.ID = i.ID
             ) totales_detalle
  OUTER APPLY(
               SELECT 
                 SeriesLote = COUNT(slm.SerieLote),
                 CantMasGrande = MAX(ISNULL(slm.Cantidad,0) * calc.Factor),
                 CantMasPequeña= MIN(ISNULL(slm.Cantidad,0) * calc.Factor) ,
                 KgsTotales = SUM
                              (
                                ISNULL(slm.Cantidad,0) 
                              * calc.Factor
                              * CASE ISNULL(a.Unidad,'')
                                  WHEN 'KGS'
                                    THEN 1 
                                  ELSE
                                    ISNULL(a.Peso,1) 
                                END
                              )
               FROM 
                 SerieLoteMov slm
               JOIN InvD d ON d.Id  = slm.ID 
                          AnD d.RenglonID = slm.RenglonID
                          AND d.Articulo  = slm.Articulo
                          AND ISNULL(d.SubCuenta,'') = ISNULL(slm.SubCuenta,'')
               JOIN art a ON a.Articulo = slm.Articulo
               -- calculados
               CROSS APPLY( SELECT 
                              Factor = CASE
                                         WHEN ISNULL(d.Cantidad,0) < 1
                                           THEN -1 
                                         ELSE 
                                           1
                                       END 
                          ) calc
               WHERE 
                 slm.Modulo = 'INV'
               AND slm.ID   = i.ID   
             ) totales_sl
  WHERE 
    proceso.Id = @ID
  AND proceso_ajustes.Modulo = 'INV'
  ORDER BY
    proceso.Id,
    proceso_ajustes.Modulo,
    proceso_ajustes.ModuloID,
    ab.ID ASC

  ----/*
  ---- Detalle Ajustes
  --SELECT
  --  ajm.Id,
  --  ajm.Modulo,
  --  ajm.ModuloId,
  --  Escenario = esc.Descripcion,
  --  i.Mov,
  --  i.Movid,
  --  i.Almacen,
  --  d.RenglonID,
  --  d.Articulo,
  --  d.SubCuenta,
  --  d.Cantidad,
  --  d.Factor,
  --  d.CantidadInventario,
  --  d.Costo,
  --  slm.SerieLote,
  --  slm.Propiedades,
  --  slm.Cantidad
  --FROM
  --  CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
  --JOIN CUP_EliminarSaldosMenoresInv_Escenarios esc ON esc.ID = ajm.Escenario
  --JOIN inv i ON i.ID = ajm.ModuloID
  --JOIN InvD d ON d.ID = i.ID
  --LEFT JOIN SerieLoteMov slm ON slm.Modulo = 'INV'
  --                          AND slm.ID = i.ID
  --                          AND slm.RenglonID = d.RenglonID
  --                          AND slm.Articulo = d.Articulo
  --                          AND ISNULL(slm.SubCuenta,'') = ISNULL(d.SubCuenta,'')
  --WHERE 
  --  ajm.Id = @ID
  --AND ajm.Modulo = 'INV'
  ----*/

END