SET ANSI_NULLS, ANSI_WARNINGS ON;

IF OBJECT_ID('dbo.CUP_EliminarSaldosMenoresInv', 'U') IS NOT NULL 
  DROP TABLE dbo.CUP_EliminarSaldosMenoresInv; 

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-10

  Description: Tabla encargada de llevar el registro
  del uso de la herramienta para eliminar los saldos
  menores Inv.
 ============================================= */

CREATE TABLE dbo.CUP_EliminarSaldosMenoresInv
(
  ID INT PRIMARY KEY NOT NULL IDENTITY(1,1), 
  Usuario  CHAR(10) NOT NULL,
  Fecha DATETIME NOT NULL
        CONSTRAINT [DF_CUP_EliminarSaldosMenoresInv_Fecha] DEFAULT GETDATE(),
  Escenario INT
            CONSTRAINT FK_CUP_EliminarSaldosMenoresInv_Escenarios
            FOREIGN KEY
            REFERENCES CUP_EliminarSaldosMenoresInv( ID )
) 


CREATE NONCLUSTERED INDEX [IX_CUP_EliminarSaldosMenoresInv_Escenario]
ON [dbo].[CUP_EliminarSaldosMenoresInv] ( Escenario )
INCLUDE ( 
           ID,
           Usuario,
           Fecha
        )

CREATE NONCLUSTERED INDEX [IX_CUP_EliminarSaldosMenoresInv_Fecha]
ON [dbo].[CUP_EliminarSaldosMenoresInv] ( Fecha )
INCLUDE ( 
           ID,
           Usuario,
           Escenario
        )

CREATE NONCLUSTERED INDEX [IX_CUP_EliminarSaldosMenoresInv_Usuario]
ON [dbo].[CUP_EliminarSaldosMenoresInv] ( Usuario )
INCLUDE ( 
           ID,
           Fecha,
           Escenario
        )