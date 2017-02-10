SET ANSI_NULLS, ANSI_WARNINGS ON;

GO

IF EXISTS (SELECT * 
		   FROM SYSOBJECTS 
		   WHERE ID = OBJECT_ID('dbo.CUP_SPP_EliminarSaldosMenoresInv_AfectarAjustes') AND 
				 TYPE = 'P')
BEGIN
  DROP PROCEDURE dbo.CUP_SPP_EliminarSaldosMenoresInv_AfectarAjustes
END	

GO

/* =============================================

  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-10

  Description: Afecta los ajustes de inventario
  ligados a un proceso de eliminacion de saldos 
  menores inv.
 
============================================= */

CREATE PROCEDURE dbo.CUP_SPP_EliminarSaldosMenoresInv_AfectarAjustes
  @ID INT
AS BEGIN 
  
  DECLARE
    @Ok INT,
    @OkRef VARCHAR(255),
    @r_AjusteID INT

  -- Afecta los Ajustes Menores.
  DECLARE cr_AjustesMenores CURSOR LOCAL FAST_FORWARD FOR 
  SELECT 
    i.ID 
  FROM 
    CUP_EliminarSaldosMenoresInv_AjustesGenerados ajm
  JOIN Inv i ON i.ID = ajm.ModuloID
  WHERE 
    ajm.Id = @ID 
  AND ajm.Modulo = 'INV'

  OPEN cr_AjustesMenores

  FETCH NEXT FROM cr_AjustesMenores INTO @r_AjusteID

  WHILE @@FETCH_STATUS = 0
  BEGIN

    SELECT 
      @OK = NULL,
      @OKRef = NULL

    EXEC spAfectar
      @Modulo = 'INV', 
      @ID = @r_AjusteID ,
      @Accion = 'AFECTAR',
      @Base = 'TODO',
      @GenerarMov =NULL, 
      @Usuario = 'PRODAUT',
      @SincroFinal = 0, 
      @EnSilencio = 1,
      @OK = @OK OUTPUT,
      @OkRef = @OkRef OUTPUT

    ---- Apartado para eliminar renglones con el problema del costeo.
    --WHILE @Ok = 20101
    --  EXEC CUP_SPP_EliminaSMInv_RemueveArtProblemaCosto
    --    @ID = @r_AjusteID,
    --    @Ok = @OK INT OUTPUT,
    --    @OkREf = @OkRef INT OUTPUT
    --

    FETCH NEXT FROM cr_AjustesMenores INTO @r_AjusteID
  END

  CLOSE cr_AjustesMenores

  DEALLOCATE cr_AjustesMenores

END