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
)