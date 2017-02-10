USE [Cuprum]
GO

/****** Object:  StoredProcedure [dbo].[spCuprumValidaRefCaracter]    Script Date: 10/02/2017 04:26:34 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[spCuprumValidaRefCaracter]  @ID Int, @Modulo Varchar(20),@Ok  int = NULL OUTPUT, @OkRef    varchar(255) = NULL OUTPUT                       
   
AS      
BEGIN
	Declare @Referencia     Varchar(255),
			@TextoValido    Varchar(255), 
			@Largo          Int,
			@PosicionActual Int,  
			@Contador       Int,
			@Caracter       Varchar(1),
			@NovalidosNum   Int,
			@RegNum         Int,
			@MaxRegistros   Int

	Select @NovalidosNum=0

	--------------------------------- Texto Valido -----------------------------------------
	Select @TextoValido='-_/ .$%qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPASDFGHJKLÑZXCVBNM1234567890,;()áéíóúÁÉÍÓÚüÜ:' 

					    

	Select @Largo=Len(@TextoValido),@Contador=1
	PRINT('Largo: ' + CAST(@Largo as Varchar))
	Create Table #ListaCaracteresValidos
	(
		Caracter char(1) Not null,
		CodigoAscii int null
	)

	WHILE @Contador<=@Largo
	Begin 
		Select @Caracter=Substring(@TextoValido,@Contador,1)
	    
		Insert into #ListaCaracteresValidos(Caracter,CodigoAscii)
		Select @Caracter, ASCII (@Caracter)
	    
		Select @Contador=@Contador+1
	End
	
	

	
	-----------------------Determina la referencia en base al modulo------------------------
	IF @Modulo='INV'
	Begin
	   Select @Referencia=Referencia
	   From   Inv
	   Where  Inv.ID=@ID
	End


	IF @Modulo='COMS'
	Begin
	   Select @Referencia=Referencia
	   From   Compra
	   Where  Compra.ID=@ID
	End
	        

	IF @Modulo='VTAS'
	Begin
	   Select @Referencia=Referencia
	   From   Movtipo, Venta
	   Where  Venta.ID=@ID
	End


	IF @Modulo='PROD'
	Begin
	   Select @Referencia=Referencia
	   From   Prod
	   Where  Prod.ID=@ID
	End


	IF @Modulo='CXC'
	Begin
	   Select @Referencia=Referencia
	   From   CXC
	   Where  CXC.ID=@ID
	End

	IF @Modulo='CXP'
	Begin
	   Select @Referencia=Referencia
	   From   CXP
	   Where  CXP.ID=@ID
	End
	             
	IF @Modulo='DIN'
	Begin
	   Select @Referencia=Referencia
	   From   Dinero
	   Where  Dinero.ID=@ID
	End             
	-----------------------------------------------------------------------------------------



	

		Create Table #ListaCaracteres(Orden Int NULL,Caracter varchar(1) Not null,CodigoAscii int null)
	    
		Create Table #RefGastoD(Orden Int IDENTITY(1,1) NOT NULL, Renglon Float,Referencia Varchar(255) NULL, Concepto Varchar(255) Null,  Error Int Null )
	   
	    

		IF @Modulo<>'GAS'
		Begin
		----------------------- Inicio Descompone la referencia --------------------------
		Select @Largo=Len(@Referencia),@Contador=1


		WHILE @Contador<=@Largo
		Begin 
		  Select @Caracter=Substring(@Referencia,@Contador,1)
	      
			 Insert into #ListaCaracteres(Orden,Caracter,CodigoAscii)
			 Select 1,@Caracter, ASCII (@Caracter)
	         
			 Select @Contador=@Contador+1
	    
		End
	    
	    
		Select @NovalidosNum=Count(*)
		From   #ListaCaracteres
		Where  Caracter  not in (Select Caracter
								 From   #ListaCaracteresValidos) 
	                             
	                             
		IF @NovalidosNum<>0 
		Begin
	 
		  Select top 1
				 @OkRef='Existen Caracteres inválidos en la Referencia.'
						+'<BR>' +'Los únicos caracteres que pueden ser usados son:'
						+' ' + '[A-Z][0-9][_,-,/, ,.,´,¨,),(,$.%]'
						+'<BR><BR>' 
						+'Caracter no valido: '+Caracter+' (ASCII = ' +CAST(ASCII(Caracter) as varchar) + ') en Referencia'
		  From   #ListaCaracteres
		  Where  Caracter  not in (Select Caracter
								   From   #ListaCaracteresValidos) 
	   
		  Select @Ok=800090   
		  End 
	                         
	    
	    
		End
	    
		----------------------- Fin Descompone la referencia --------------------------
	    
	    
	    
	    
		--------------------- Solo Para Gastos Inicio----------------------------------------
		IF @Modulo='GAS' And (Select Count(*) From GastoD Where ID=ID)<>0
		Begin
	    
		  Insert Into #RefGastoD(Renglon, Referencia,Concepto)
		  Select Renglon,
				 Referencia,
				 Concepto 
		  From   GastoD
		  Where  ID=@ID
      AND ISNULL(Referencia,'') <> ''
	    
	      
	      
		  Select @RegNum=Min(Orden)
		  From   #RefGastoD
	      
		  Select @MaxRegistros=Max(Orden)
		  From   #RefGastoD      
	      
	      
		  WHILE @RegNum<=@MaxRegistros
		  Begin 
	      
			Select @Referencia=Referencia
			From   #RefGastoD
			Where  Orden=@RegNum
	    
	    
		----------------------- Inicio Descompone la referencia --------------------------
		  Select @Largo=Len(@Referencia),@Contador=1

			 WHILE @Contador<=@Largo
			 Begin 
			   Select @Caracter=Substring(@Referencia,@Contador,1)
	      
				Insert into #ListaCaracteres(Orden,Caracter,CodigoAscii)
				Select @RegNum, @Caracter, ASCII (@Caracter)
	         
			   Select @Contador=@Contador+1
	    
			  End
	               
			  Select @NovalidosNum=COUNT(*)
			  From   #ListaCaracteres
			  Where  Caracter not in(Select Caracter
									 From  #ListaCaracteresValidos)
			  And    Orden=@RegNum  
	          
	          
			  IF @NovalidosNum<>0
			  Begin
				Update #RefGastoD Set  Error=1 Where Orden=@RegNum 
			  End  

			  IF @NovalidosNum=0
			  Begin
				Update #RefGastoD Set  Error=0 Where Orden=@RegNum 
			  End  
	          
			  Select @RegNum=@RegNum+1       
	   
		End
	    
			   Select @NovalidosNum=Count(*)
			   From   #RefGastoD
			   Where  Error<>0
	 
			   IF @NovalidosNum<>0
			   Begin
	 
				 Select top 1
						@OkRef='Existen Caracteres inválidos en el Concepto.'
								+'<BR>' +'Los únicos caracteres que pueden ser usados son:'
								+' ' + '[A-Z][0-9][_,-,/, ,.,´,¨,),(,$.%]'
								+'<BR><BR>'
								+ 'Concepto: '+Ltrim(Rtrim(Concepto))
				 From   #RefGastoD
				 Where  Error<>0
				 Order By Orden
	             
				 Select @Ok=800090
	                
				End 
	    
	    
		End
	    
		--------------------- Solo Para Gastos Fin ----------------------------------------
	   

	Drop table #ListaCaracteresValidos
	Drop table #ListaCaracteres
	Drop table #RefGastoD



	Return
End

GO

