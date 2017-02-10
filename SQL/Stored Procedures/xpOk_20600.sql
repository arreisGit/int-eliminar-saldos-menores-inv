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

  DECLARE 
    @CUP_Origen INT,
    @MovTipo CHAR(20)
  
  IF @OK = 20600
  BEGIN
      
    -- ??? : No se sabe quien o cuando se puso este criterio.
    IF @Modulo = 'PROD'
		AND @Accion = 'AFECTAR'
	  BEGIN
		  SELECT
			  @Ok = NULL
	  END;

    IF @Modulo = 'INV'
    BEGIN
      
      SELECT 
        @CUP_Origen = CUP_Origen,
        @MovTipo = t.Clave
      FROM 
        Inv i
      JOIN Movtipo t ON t.Modulo = 'INV'
                    AND t.Mov = i.Mov
      WHERE 
        i.ID = @ID
      
      -- Kike Sierra: 2017-02-07: Permite afectar ajustes de 
      -- saldos menores inv sin considerar el error de
      -- 'Costo indicado es menor al minimo aceptable ( 20600 )
      IF @MovTipo = 'INV.A'
      AND @CUP_Origen = 13 
      BEGIN
        SELECT
          @OK = NULL,
          @OkRef = NULL
      END 

    END

  END
 
	RETURN;
END;