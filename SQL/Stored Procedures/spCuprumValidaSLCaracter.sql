USE [Cuprum]
GO

/****** Object:  StoredProcedure [dbo].[spCuprumValidaSLCaracter]    Script Date: 10/02/2017 05:04:12 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE @Ok  int,
			@OkRef varchar(255)

	EXEC spCuprumValidaSLCaracter 440193, 'vtas', @Ok OUTPUT, @OkRef output

	select @Ok, @OkRef
*/

ALTER PROCEDURE [dbo].[spCuprumValidaSLCaracter]  @ID Int, @Modulo Varchar(20),@Ok  int = NULL OUTPUT, @OkRef    varchar(255) = NULL OUTPUT                       
   
AS      
BEGIN
Declare @TotalSeries    Int,
        @MaxRegistros   Int,
        @RegNum         Int,
        @Serielote      Varchar(255),
        @TextoValido    Varchar(255), 
        @Largo          Int,
        @PosicionActual Int,  
        @Contador       Int,
        @Caracter       Varchar(1),
        @NovalidosNum   Int      
        
Select @TotalSeries=Count(*)
From   SerieloteMov
Where  Modulo=@Modulo
And    ID=@ID

IF @TotalSeries<>0
Begin
	--------------------------------- Texto Valido -----------------------------------------
	Select @TextoValido='-/qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPASDFGHJKLÑZXCVBNM1234567890'

	Select @Largo=Len(@TextoValido),@Contador=1
	Create Table #ListaCaracteresValidos(Caracter varchar(1) Not null,CodigoAscii int null)

	WHILE @Contador<=@Largo
	Begin 
		Select @Caracter=Substring(@TextoValido,@Contador,1)
	    
		Insert into #ListaCaracteresValidos(Caracter,CodigoAscii)
		Select @Caracter, ASCII (@Caracter)
	    
		Select @Contador=@Contador+1
End
----------------------------------------------------------------------------------------


Create Table #ListaRevisaSerieLote(Orden     Int IDENTITY(1,1) NOT NULL,
                                   RenglonID Int, 
                                   Articulo  Varchar(50) not null, 
                                   Subcuenta Varchar(50) null,
                                   Serielote Varchar(255)not null,
                                   Error     Int         Null)
                                      
Insert into #ListaRevisaSerieLote(RenglonID, 
                                  Articulo, 
                                  Subcuenta,
                                  Serielote)
                                    
Select RenglonID,
       Articulo,
       Subcuenta,
       Serielote
From   SerieloteMov
Where  Modulo=@Modulo
And    ID=@ID
--Kike Sierra: 19/01/2015: Control de excepciones. 
--AND Serielote not in ('c-6186-07k4h2b  cal')
--and SerieLote NOT in ('IPC-6934-01H0B2 CBA')

Select @RegNum=Min(Orden)
From   #ListaRevisaSerieLote


Select @MaxRegistros=max(Orden)
From   #ListaRevisaSerieLote


Create Table #ListaCaracteres(Orden Int,Caracter varchar(1) Not null,CodigoAscii int null)

------------------- Comienza a analizar la serielote -----------------------------------
WHILE @RegNum<=@MaxRegistros
Begin 

    Select @Serielote=Serielote
    From   #ListaRevisaSerieLote
    Where  Orden=@RegNum

    ----------------------- Inicio Descompone Serielote --------------------------
    Select @Largo=Len(@Serielote),@Contador=1


    WHILE @Contador<=@Largo
    Begin 
    Select @Caracter=Substring(@Serielote,@Contador,1)
    
    Insert into #ListaCaracteres(Orden,Caracter,CodigoAscii)
    Select @RegNum,@Caracter, ASCII (@Caracter)
    
    Select @Contador=@Contador+1
    
    End
    

    Select @NovalidosNum=COUNT(*)
    From   #ListaCaracteres
    Where  Caracter not in(Select Caracter
                           From  #ListaCaracteresValidos)
    And    Orden=@RegNum                        

    IF @NovalidosNum<>0
    Begin
       Update #ListaRevisaSerieLote Set  Error=@NovalidosNum Where Orden=@RegNum 
    End  

        IF @NovalidosNum=0
    Begin
       Update #ListaRevisaSerieLote Set  Error=0 Where Orden=@RegNum 
    End  

    ----------------------- Fin  Descompone Serielote   --------------------------
    
    Select @RegNum=@RegNum+1
End
------------------- Fin analizar la serielote -----------------------------------


 Select @NovalidosNum=Count(*)
 From   #ListaRevisaSerieLote
 Where  Error<>0
 
 
 IF @NovalidosNum<>0
 Begin
 
	--Kike Sierra 23/01/2015: Se modifico el mensaje de error.
   Select top 1
          @OkRef='Existen Caracteres Inválidos en alguna de las SeriesLote capturadas.'
				+'<BR>' +'Los únicos caracteres que pueden ser usados son:'
				+' ' + '[A-Z][0-9][-][/]'
				+'<BR><BR>'
				+'Articulo: '+Ltrim(Rtrim(Articulo))+' '+Ltrim(Rtrim(Subcuenta))+' Serielote: '+Ltrim(Rtrim(Serielote))
   From   #ListaRevisaSerieLote
   Where  Error<>0
   Order By Orden
   
   Select @Ok=800090   
 End 

Drop table #ListaRevisaSerieLote
Drop table #ListaCaracteresValidos
Drop table #ListaCaracteres


End 

Return
End 





GO

