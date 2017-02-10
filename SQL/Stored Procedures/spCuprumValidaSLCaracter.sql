USE [Cuprum];
GO

/****** Object:  StoredProcedure [dbo].[spCuprumValidaSLCaracter]    Script Date: 10/02/2017 05:04:12 p.m. ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/*
	DECLARE @Ok  int,
			@OkRef varchar(255)

	EXEC spCuprumValidaSLCaracter 440193, 'vtas', @Ok OUTPUT, @OkRef output

	select @Ok, @OkRef
*/

ALTER PROCEDURE [dbo].[spCuprumValidaSLCaracter]
	@ID     INT,
	@Modulo VARCHAR(20),
	@Ok     INT          = NULL OUTPUT,
	@OkRef  VARCHAR(255) = NULL OUTPUT
AS BEGIN
	DECLARE
		@TotalSeries    INT,
		@MaxRegistros   INT,
		@RegNum         INT,
		@Serielote      VARCHAR(255),
		@TextoValido    VARCHAR(255),
		@Largo          INT,
		@PosicionActual INT,
		@Contador       INT,
		@Caracter       VARCHAR(1),
		@NovalidosNum   INT,
		@CUP_Origen     INT;

	SELECT
		@TotalSeries = COUNT(*)
	FROM
		SerieloteMov
	WHERE
    Modulo = @Modulo
	AND ID = @ID;

	IF @Modulo = 'INV'
	BEGIN
		SELECT
			@CUP_Origen = CUP_Origen
		FROM
			Inv
		WHERE
      ID = @ID;
	END;

	IF @TotalSeries <> 0
  AND @CUP_Origen NOT IN (13) -- Eliminar Saldos Menores Inv
	BEGIN
		--------------------------------- Texto Valido -----------------------------------------
		SELECT
			@TextoValido = '-/qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPASDFGHJKLÑZXCVBNM1234567890';

		SELECT
			@Largo = LEN(@TextoValido),
			@Contador = 1;

		CREATE TABLE #ListaCaracteresValidos
		(
			Caracter    VARCHAR(1) NOT NULL,
			CodigoAscii INT NULL
		);

		WHILE @Contador <= @Largo
		BEGIN
			SELECT
				@Caracter = SUBSTRING(@TextoValido, @Contador, 1);

			INSERT INTO #ListaCaracteresValidos
			(
				Caracter,
				CodigoAscii
			)
			SELECT
				@Caracter,
				ASCII(@Caracter);

			SELECT
				@Contador = @Contador + 1;
		END;
		----------------------------------------------------------------------------------------

		CREATE TABLE #ListaRevisaSerieLote
		(
			Orden     INT IDENTITY(1, 1) NOT NULL,
			RenglonID INT,
			Articulo  VARCHAR(50) NOT NULL,
			Subcuenta VARCHAR(50) NULL,
			Serielote VARCHAR(255) NOT NULL,
			Error     INT NULL
		);

		INSERT INTO #ListaRevisaSerieLote
		(
			RenglonID,
			Articulo,
			Subcuenta,
			Serielote
		)
		SELECT
			RenglonID,
			Articulo,
			Subcuenta,
			Serielote
		FROM
			SerieloteMov
		WHERE
      Modulo = @Modulo
		AND ID = @ID;

		SELECT
			@RegNum = MIN(Orden)
		FROM
			#ListaRevisaSerieLote;

		SELECT
			@MaxRegistros = MAX(Orden)
		FROM
			#ListaRevisaSerieLote;

		CREATE TABLE #ListaCaracteres
		(
			Orden       INT,
			Caracter    VARCHAR(1) NOT NULL,
			CodigoAscii INT NULL
		);

		------------------- Comienza a analizar la serielote -----------------------------------
		WHILE @RegNum <= @MaxRegistros
		BEGIN

			SELECT
				@Serielote = Serielote
			FROM
				#ListaRevisaSerieLote
			WHERE
        Orden = @RegNum;

			----------------------- Inicio Descompone Serielote --------------------------
			SELECT
				@Largo = LEN(@Serielote),
				@Contador = 1;

			WHILE @Contador <= @Largo
			BEGIN
				SELECT
					@Caracter = SUBSTRING(@Serielote, @Contador, 1);

				INSERT INTO #ListaCaracteres
				(
					Orden,
					Caracter,
					CodigoAscii
				)
				SELECT
					@RegNum,
					@Caracter,
					ASCII(@Caracter);

				SELECT
					@Contador = @Contador + 1;

			END;

			SELECT
				@NovalidosNum = COUNT(*)
			FROM
				#ListaCaracteres
			WHERE
        Caracter NOT IN (
				                  SELECT
					                  Caracter
				                  FROM
					                  #ListaCaracteresValidos
			                  )
			AND Orden = @RegNum;

			IF @NovalidosNum <> 0
			BEGIN
				UPDATE #ListaRevisaSerieLote
				SET
					Error = @NovalidosNum
				WHERE
					Orden = @RegNum;
			END;

			IF @NovalidosNum = 0
			BEGIN
				UPDATE #ListaRevisaSerieLote
				SET
					Error = 0
				WHERE
					Orden = @RegNum;
			END;

			----------------------- Fin  Descompone Serielote   --------------------------

			SELECT
				@RegNum = @RegNum + 1;
		END;
		------------------- Fin analizar la serielote -----------------------------------

		SELECT
			@NovalidosNum = COUNT(*)
		FROM
			#ListaRevisaSerieLote
		WHERE
      Error <> 0;

		IF @NovalidosNum <> 0
		BEGIN

			--Kike Sierra 23/01/2015: Se modifico el mensaje de error.
			SELECT TOP 1
				@OkRef = 'Existen Caracteres Inválidos en alguna de las SeriesLote capturadas.'+'<BR>'+'Los únicos caracteres que pueden ser usados son:'+' '+'[A-Z][0-9][-][/]'+'<BR><BR>'+'Articulo: '+LTRIM(RTRIM(Articulo))+' '+LTRIM(RTRIM(Subcuenta))+' Serielote: '+LTRIM(RTRIM(Serielote))
			FROM
				#ListaRevisaSerieLote
			WHERE
        Error <> 0
			ORDER BY
				Orden;

			SELECT
				@Ok = 800090;
		END;

		DROP TABLE #ListaRevisaSerieLote;
		DROP TABLE #ListaCaracteresValidos;
		DROP TABLE #ListaCaracteres;

	END;

	RETURN;
END;