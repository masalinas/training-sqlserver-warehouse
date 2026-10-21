# Proposal

## Why

Para realizar pruebas sobre la base de datos de almacén, se requiere un conjunto representativo de datos mock que simulen estanterías con cuadrículas de ubicaciones (3 posiciones longitudinales x 4 alturas) y stock distribuido de productos con cantidades y fechas de caducidad variadas.
Para posibilitar que cada estantería contenga sus 12 ubicaciones individuales (`x * y = 12`), es imprescindible adaptar la restricción de unicidad del modelo en `Estanteria`, pasando de unicidad exclusiva en `CodigoEstanteria` a unicidad compuesta `(CodigoEstanteria, x, y)`.

## What Changes

- **BREAKING**: Modificación en el modelo de datos (`model.sql`) de la tabla `dbo.Estanteria`, sustituyendo la restricción `UQ_Estanteria_CodigoEstanteria UNIQUE (CodigoEstanteria)` por una restricción de unicidad compuesta `UQ_Estanteria_Ubicacion UNIQUE (CodigoEstanteria, x, y)`.
- Creación de un script T-SQL idempotente `mocks.sql` con las siguientes características:
  - Limpieza previa y ordenada de las tablas `Stock` y `Estanteria`, reiniciando sus contadores autonuméricos (`IDENTITY`).
  - Generación de 3 estanterías (`E01`, `E02`, `E03`) con producto cartesiano de 3 posiciones (`x` de 1 a 3) y 4 alturas (`y` de 1 a 4), creando un total de 36 ubicaciones.
  - Inserción de registros de stock para productos (`P01`, `P02`, `P03`) ubicados aleatoriamente únicamente en las ubicaciones de `E01` y `E02`, con cantidades positivas aleatorias (`DECIMAL(5,2)`) y fechas de caducidad aleatorias (con presencia de valores `NULL`).
- Actualización de `test_restricciones.sql` para reflejar la nueva regla de unicidad por ubicación `(CodigoEstanteria, x, y)`.

## Capabilities

### Modified Capabilities
- `warehouse-stock`: Actualiza el requisito de unicidad de la entidad `Estanteria` a la tupla `(CodigoEstanteria, x, y)` y añade el requisito del script de datos mock `mocks.sql`.

## Impact

- `model.sql`: Modificación DDL de la restricción de unicidad en `dbo.Estanteria`.
- `mocks.sql`: Nuevo script para generación y carga de datos de prueba en T-SQL.
- `test_restricciones.sql`: Ajuste de pruebas automáticas para comprobar la unicidad compuesta.
