1.  Articulos con SaldoU = 0 pero con existencias a nivel
Serielote.

    _**Solucion:** Darle Update a todos los series lote para tener existencia
  en 0._

2.  Articulos con un saldo menor en SaldoU ( menor a 1 ),  que no sean de tipo
SERIE o LOTE o que su saldoU sea igual al saldo SerieLote

    _**Solucion:** Estas transacciones se consideran seguras, se pueden 
  sacar por un ajuste regular._

3.  Serieslote con existencia menor a .05donde exista un Remanente entre la
existencia SaldoU de su Art - La suma de La existencia series lote con un saldo
mayor o igual a .05

    _**Solucion:** Estos series lotes deberian poder ajustarse de manera
    regular. Solo que hay que la cantidad en la partida del detalle del ajuste,
    debe ser solo la sumatoria de los saldos series lote menores