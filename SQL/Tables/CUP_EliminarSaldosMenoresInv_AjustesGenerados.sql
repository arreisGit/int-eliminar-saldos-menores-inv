SET ANSI_NULLS, ANSI_WARNINGS ON;

IF OBJECT_ID('dbo.CUP_EliminarSaldosMenoresInv_AjustesGenerados', 'U') IS NOT NULL 
  DROP TABLE dbo.CUP_EliminarSaldosMenoresInv_AjustesGenerados; 

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-02-10

 Description: Tabla encargada de llevar el registro de los
 ajustes junto con su tipo de escenario que fueron creados
 por al correr el proceso de eliminar saldos menores inv.

 ============================================= */

CREATE TABLE dbo.CUP_EliminarSaldosMenoresInv_AjustesGenerados
(
  RID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
  ID  INT
      CONSTRAINT NN_CUP_EliminarSaldosMenoresInv_AjustesGenerados_ID
      NOT NULL
      CONSTRAINT FK_CUP_EliminarSaldosMenoresInv_AjustesGenerados_ID
      FOREIGN KEY
      REFERENCES CUP_EliminarSaldosMenoresInv( ID ),
  Modulo   CHAR(5)  
           CONSTRAINT NN_CUP_EliminarSaldosMenoresInv_AjustesGenerados_Modulo
           NOT NULL,
  ModuloID INT  
           CONSTRAINT NN_CUP_EliminarSaldosMenoresInv_AjustesGenerados_ModuloID
           NOT NULL,
  Escenario INT
            CONSTRAINT FK_CUP_EliminarSaldosMenoresInv_AjustesGenerados_Escenario
            FOREIGN KEY
            REFERENCES CUP_EliminarSaldosMenoresInv_Escenarios( ID )
)


CREATE NONCLUSTERED INDEX [IX_CUP_EliminarSaldosMenoresInv_AjustesGenerados_ID]
ON [dbo].[CUP_EliminarSaldosMenoresInv_AjustesGenerados] ( ID )
INCLUDE ( 
           RID,
           Modulo,
           ModuloId,
           Escenario
        )

CREATE NONCLUSTERED INDEX [IX_CUP_EliminarSaldosMenoresInv_AjustesGenerados_Escenario]
ON [dbo].[CUP_EliminarSaldosMenoresInv_AjustesGenerados] ( Escenario )
INCLUDE ( 
           RID,
           ID,
           Modulo,
           ModuloId
        )


CREATE NONCLUSTERED INDEX [IX_CUP_EliminarSaldosMenoresInv_AjustesGenerados_Modulo_ModuloID]
ON [dbo].[CUP_EliminarSaldosMenoresInv_AjustesGenerados] ( Modulo, ModuloID  )
INCLUDE ( 
           RID,
           ID,
           Escenario
        )