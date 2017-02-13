TRUNCATE TABLE CUP_EliminarSaldosMenoresInv_Escenarios

INSERT INTO
  CUP_EliminarSaldosMenoresInv_Escenarios 
(
  Descripcion,
  Empleado,
  FechaAlta
)
VALUES
(
  'SEGURO',
  63527,
  GETDATE()
),
(
  'SALDOS MENORES SL',
  63527,
  GETDATE()
)

SET IDENTITY_INSERT dbo.CUP_EliminarSaldosMenoresInv_Escenarios ON;  

INSERT INTO
  CUP_EliminarSaldosMenoresInv_Escenarios 
(
  ID,
  Descripcion,
  Empleado,
  FechaAlta
)
VALUES
(
  0,
  'DESCONOCIDO',
  63527,
  GETDATE()
)

SET IDENTITY_INSERT dbo.CUP_EliminarSaldosMenoresInv_Escenarios OFF;  

SELECT
  Id,
  Descripcion,
  Empleado,
  FechaAlta
FROM 
  CUP_EliminarSaldosMenoresInv_Escenarios