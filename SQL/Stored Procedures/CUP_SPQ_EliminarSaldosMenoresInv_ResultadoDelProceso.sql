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
    proceso.Fecha,
    proceso_ajustes.Modulo,
    proceso_ajustes.ModuloId,
    proceso_ajustes.Escenario,
    i.Almacen,
    i.Estatus,
    ab.Accion,
    ab.Base,
    ab.GenerarMov,
    ab.Usuario,
    ab.FechaRegistro,
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

  SELECT * from #tmp_CUP_SaldosMenoresSU

  /*
  -- Detalle Ajustes
  SELECT
    ajm.Id,
    ajm.Modulo,
    ajm.ModuloId,
    i.Mov,
    i.Movid,
    i.Almacen,
    d.Articulo,
    d.SubCuenta,
    d.Cantidad,
    d.Factor,
    d.CantidadInventario,
    d.Costo
  FROM
    CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
  JOIN inv i ON i.ID = ajm.ModuloID
  JOIN InvD d ON d.ID = ajm.ID
  WHERE 
    ajm.Id = @ID
  AND ajm.Modulo = 'INV'
  */

END