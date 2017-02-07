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
	RETURN;
END;