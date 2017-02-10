IF COLUMNPROPERTY(OBJECT_ID('dbo.Inv'), 'CUP_Origen', 'ColumnId') IS NULL
BEGIN
    ALTER TABLE Inv 
    ADD CUP_Origen INT NULL
                   CONSTRAINT FK_Inv_to_CUP_Procesos
                   FOREIGN KEY
                   REFERENCES CUP_Procesos( Proceso )
END

IF COLUMNPROPERTY(OBJECT_ID('dbo.Inv'), 'CUP_OrigenID', 'ColumnId') IS NULL
BEGIN
    ALTER TABLE Inv 
    ADD CUP_OrigenID INT NULL
END