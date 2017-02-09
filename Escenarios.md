1.  Articulos con SaldoU = 0 pero con existencias a nivel
Serielote.

    _**Solucion:** Darle Update a todos los series lote para tener existencia
  en 0._

2.  Articulos con un saldo menor en SaldoU ( menor a 1 ),  que no sean de tipo
SERIE o LOTE o que su saldoU sea igual al saldo SerieLote

    _**Solucion:** Estas transacciones se consideran segurass, se pueden 
  sacar por un ajuste regular._

3.  Articulos con un SaldoU menor a .0001, que no sean de tipo SERIE o LOTE
o que su saldo SerieLote sea tmb menor a .0001

    _**Solucion:** Estas transacciones se consideran segurass, se pueden 
  sacar por un ajuste regular._