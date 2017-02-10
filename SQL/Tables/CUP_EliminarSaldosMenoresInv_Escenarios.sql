SET ANSI_NULLS, ANSI_WARNINGS ON;

IF OBJECT_ID('dbo.CUP_EliminarSaldosMenoresInv_Escenarios', 'U') IS NOT NULL 
  DROP TABLE dbo.CUP_EliminarSaldosMenoresInv_Escenarios; 

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-10

  Description: Tabla encargada de contener
  los tipos de escenario disponibles para 
  la eliminacion desaldos menores inv.
 ============================================= */

CREATE TABLE dbo.CUP_EliminarSaldosMenoresInv_Escenarios
(
  ID INT PRIMARY KEY NOT NULL IDENTITY(1,1), 
  Descripcion VARCHAR(100) NOT NULL,
  Empleado INT NOT NULL,
  FechaAlta DATETIME NOT NULL
            CONSTRAINT [DF_CUP_EliminarSaldosMenoresInv_Escenarios_FechaAlta] DEFAULT GETDATE() 
  CONSTRAINT AK_CUP_EliminarSaldosMenoresInv_Escenarios
  UNIQUE (
    Descripcion
  )  
) 