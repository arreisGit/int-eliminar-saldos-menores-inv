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
 
============================================= */

CREATE PROCEDURE dbo.CUP_SPQ_EliminarSaldosMenoresInv_ResultadoDelProceso
  @ID INT
AS BEGIN 

  SELECT
    proceso.ID,
    proceso.Usuario,
    proceso_ajustes.Modulo,
    proceso_ajustes.ModuloId,
    proceso_ajustes.Escenario,
    i.Almacen,
    i.Estatus,
    ab.Accion,
    ab.Base,
    ab.GenerarMov,
    ab.Usuario,
    FechaRegistro = CONVERT( VARCHAR(MAX), ab.FechaRegistro, 121),
    ab.Ok,
    ab.OkRef,
    MensajeDesc =  m.Descripcion
  FROM
    CUP_EliminarSaldosMenoresInv proceso
  JOIN CUP_EliminarSaldosMenoresInv_AjustesGenerados proceso_ajustes ON proceso_ajustes.ID = proceso.ID
  JOIN inv i ON i.ID = proceso_ajustes.ModuloID
  LEFT JOIN AfectarBitacora ab ON ab.Modulo = proceso_ajustes.Modulo
                              AND ab.ModuloID = proceso_ajustes.ModuloID
  LEFT JOIN MensajeLista m ON m.Mensaje = ab.OK
  WHERE 
    proceso.Id = @ID
  AND proceso_ajustes.Modulo = 'INV'
  ORDER BY
    proceso.Id,
    proceso_ajustes.Modulo,
    proceso_ajustes.ModuloID,
    ab.ID ASC

  --/*
  -- Detalle Ajustes
  SELECT
    ajm.Id,
    ajm.Modulo,
    ajm.ModuloId,
    i.Mov,
    i.Movid,
    i.Almacen,
    d.RenglonID,
    d.Articulo,
    d.SubCuenta,
    d.Cantidad,
    d.Factor,
    d.CantidadInventario,
    d.Costo,
    slm.SerieLote,
    slm.Propiedades,
    slm.Cantidad
  FROM
    CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
  JOIN inv i ON i.ID = ajm.ModuloID
  JOIN InvD d ON d.ID = i.ID
  LEFT JOIN SerieLoteMov slm ON slm.Modulo = 'INV'
                            AND slm.ID = i.ID
                            AND slm.RenglonID = d.RenglonID
                            AND slm.Articulo = d.Articulo
                            AND ISNULL(slm.SubCuenta,'') = ISNULL(d.SubCuenta,'')
  WHERE 
    ajm.Id = @ID
  AND ajm.Modulo = 'INV'
  --*/

END