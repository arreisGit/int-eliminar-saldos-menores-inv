IF NOT EXISTS
(
  SELECT 
    Descripcion
  FROM 
    CUP_Procesos
  WHERE
    descripcion = 'Eliminacion saldos menores Inv'
)
BEGIN
  INSERT INTO 
    CUP_Procesos
  (
    Descripcion,
    FechaAlta,
    Usuario
  )
  SELECT 
    'Eliminacion saldos menores Inv',
    GETDATE(),
    63527
END