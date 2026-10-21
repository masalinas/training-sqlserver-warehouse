# Tasks: Modelo de Almacén y Stock

## 1. Script T-SQL de Creación del Esquema

- [x] 1.1 Crear el archivo `model.sql` con la estructura base e idempotencia para definir la tabla `Estanteria` con `EstanteriaId` (IDENTITY), `CodigoEstanteria` (`CHAR(3)` UNIQUE, CHECK `LIKE 'E[0-9][0-9]'`), `x` e `y` (enteros >= 0), verificando la sintaxis T-SQL.
- [x] 1.2 Incorporar en `model.sql` la definición de la tabla `Stock` con `StockId` (IDENTITY), `EstanteriaId` (FK referenciando `Estanteria`), `CodigoProducto` (`CHAR(3)`, CHECK `LIKE 'P[0-9][0-9]'`), `Cantidad` (`DECIMAL(5,2)`, CHECK `Cantidad > 0.00`) y `Caducidad` (`DATE` nullable), verificando la consistencia relacional.

## 2. Casos de Prueba y Verificación de Restricciones

- [x] 2.1 Crear el archivo `test_restricciones.sql` con bloques de prueba que ejecuten inserciones válidas de estanterías y stock en `model.sql`, verificando la persistencia correcta.
- [x] 2.2 Incluir en `test_restricciones.sql` casos de prueba negativos (mediante bloques `TRY...CATCH`) que validen el rechazo explícito ante violaciones de unicidad, claves foráneas, formatos de código (`E##` y `P##`), coordenadas negativas y cantidades menores o iguales a cero.
