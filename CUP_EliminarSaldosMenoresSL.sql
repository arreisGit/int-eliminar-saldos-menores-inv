 -- TRUNCATE TABLE CUP_EliminarSaldosMenoresSL
IF OBJECT_ID('CUP_EliminarSaldosMenoresSL') IS NOT NULL
  DROP TABLE  CUP_EliminarSaldosMenoresSL

CREATE TABLE CUP_EliminarSaldosMenoresSL
(   
  ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  Usuario CHAR(10) NOT NULL, 
  Empresa CHAR(5) NOT NULL,
  Sucursal INT NOT NULL ,
  Almacen CHAR(10) NOT NULL,
  Articulo CHAR(20) NOT NULL,
  Subcuenta VARCHAR(20) NULL,
  SerieLote VARCHAR(50) NOT NULL,
  Propiedades VARCHAR(50) NULL,
  Existencia DECIMAL(30,16) NOT NULL,
  ExistenciaReal DECIMAL(18,4) NOT NULL,
  ExistenciaRemanente   DECIMAL(30,16) NOT NULL
)

GO

CREATE INDEX IDX_C_EliSaldosSLMen_Usuario
ON CUP_EliminarSaldosMenoresSL ( Usuario ) 
INCLUDE
(
  Empresa,
  Sucursal,
  Almacen,
  Articulo,
  Subcuenta,
  SerieLote,
  Propiedades,
  Existencia,
  ExistenciaReal,
  ExistenciaRemanente
)