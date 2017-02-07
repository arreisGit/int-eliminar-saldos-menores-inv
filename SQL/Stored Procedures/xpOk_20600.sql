USE [Cuprum];
GO

/****** Object:  StoredProcedure [dbo].[xpOk_20600]    Script Date: 07/02/2017 03:58:02 p.m. ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [dbo].[xpOk_20600]
	@Empresa    CHAR(5),
	@Usuario    CHAR(10),
	@Accion     CHAR(20),
	@Modulo     CHAR(5),
	@ID         INT,
	@Renglon    FLOAT,
	@RenglonSub INT,
	@Ok         INT OUTPUT,
	@OkRef      VARCHAR(255) OUTPUT
AS BEGIN
	IF @Modulo = 'PROD'
			AND @Accion = 'AFECTAR'
	BEGIN
		SELECT
			@Ok = NULL
	END;

  --  Kike Sierra: 2017-02-07: Permite afectar ajustes de 
  -- saldos menores inventarios, sin considerar el error de
  -- 'Costo indicado es menor al minimo aceptable ( 2060 )'
  IF @Ok = '20600'
  AND @Modulo = 'INV'
  AND @Usuario = 'PRODAUT'
  AND EXISTS
  (
    SELECT 
      i.ID 
    FROM 
      Inv i 
    JOIN Movtipo t ON t.Modulo = 'INV'
                  AND t.Mov = i.Mov
    WHERE
      i.ID = @ID
    AND t.Clave = 'INV.A'
    AND i.Concepto = 'Ajuste por saldos menores'
    AND i.Estatus = 'SINAFECTAR'
  )
  BEGIN
    SELECT
      @OK = NULL,
      @OkRef = NULL
  END 
	RETURN;
END;