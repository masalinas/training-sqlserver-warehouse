# Tasks

## 1. Actualización del Modelo y Pruebas

- [x] 1.1 Modificar en `model.sql` la restricción de unicidad de `dbo.Estanteria` sustituyendo `UQ_Estanteria_CodigoEstanteria UNIQUE (CodigoEstanteria)` por `UQ_Estanteria_Ubicacion UNIQUE (CodigoEstanteria, x, y)` y verificar que el script no contiene errores de sintaxis DDL.
- [x] 1.2 Actualizar en `test_restricciones.sql` las pruebas de unicidad de estantería para verificar la clave compuesta `(CodigoEstanteria, x, y)` y comprobar que la ejecución de las pruebas refleje el nuevo comportamiento.

## 2. Implementación del Script de Mocks

- [x] 2.1 Crear el archivo `mocks.sql` con la cabecera, control de transacciones/mensajes y la limpieza ordenada idempotente (`DELETE` de `Stock` y `Estanteria` con `DBCC CHECKIDENT` a 0).
- [x] 2.2 Agregar en `mocks.sql` la generación de las 36 ubicaciones para las estanterías `E01`, `E02` y `E03` con 3 posiciones en `x` (1..3) y 4 alturas en `y` (1..4) mediante producto cartesiano (`CROSS JOIN`).
- [x] 2.3 Agregar en `mocks.sql` la inserción de registros de stock aleatorio para los productos `P01`, `P02` y `P03`, ubicándolos aleatoriamente de forma exclusiva en estanterías `E01` y `E02` con cantidades positivas (`DECIMAL(5,2)`) y fechas de caducidad opcionales (incluyendo `NULL`).

## 3. Verificación de Integridad

- [x] 3.1 Verificar mediante comprobaciones en el script que se hayan creado exactamente 36 ubicaciones, que `E03` no contenga stock asociado y que no se hayan violado restricciones de integridad referencial o de dominio.
