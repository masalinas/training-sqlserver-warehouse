# Design

## Context

El modelo de datos actual definido en `model.sql` contiene la tabla `dbo.Estanteria` con una restricción de unicidad estricta en `CodigoEstanteria`. Al requerir que cada estantería contenga una cuadrícula de 12 ubicaciones (`x` de 1 a 3 y `y` de 1 a 4), dicha restricción debe transformarse en una clave única compuesta `(CodigoEstanteria, x, y)`.
Para la carga de datos mock, se debe generar un script T-SQL `mocks.sql` autónomo e idempotente.

Ver `proposal.md` y `specs/warehouse-stock/spec.md` para los requisitos y alcance detallado.

## Goals / Non-Goals

**Goals:**
- Actualizar la restricción de integridad de `dbo.Estanteria` en `model.sql` a unicidad compuesta `(CodigoEstanteria, x, y)`.
- Desarrollar `mocks.sql` en T-SQL puro, idempotente y eficiente.
- Generar 36 ubicaciones (3 estanterías x 3 posiciones x 4 alturas) mediante producto cartesiano de conjuntos.
- Generar stock aleatorio para productos `P01`, `P02` y `P03`, distribuidos únicamente en las ubicaciones de `E01` y `E02`.
- Ajustar `test_restricciones.sql` para validar la nueva regla de unicidad.

**Non-Goals:**
- No se añade una entidad adicional de "Ubicación" separada para no alterar la estructura de claves foráneas existentes (`FK_Stock_Estanteria`).
- No se modifican los tipos de datos ni las restricciones de validación CHECK de códigos o cantidades.
- No se utilizan herramientas externas ni procedimientos almacenados permanentes en la base de datos.

## Decisions

### 1. Unicidad Compuesta en Estanteria
- **Decisión**: Modificar `UQ_Estanteria_CodigoEstanteria` a `UQ_Estanteria_Ubicacion UNIQUE (CodigoEstanteria, x, y)`.
- **Alternativa descartada**: Crear una tabla intermedia `Ubicacion` (`EstanteriaId`, `x`, `y`). Aunque es más normalizado, rompería el esquema existente y obligaría a modificar la clave foránea en `Stock`.
- **Razón**: Permite representar las 12 ubicaciones por estantería de forma directa y compatible con el esquema actual.

### 2. Limpieza idempotente con `DELETE` y `DBCC CHECKIDENT`
- **Decisión**: Usar `DELETE FROM dbo.Stock; DELETE FROM dbo.Estanteria;` seguido de `DBCC CHECKIDENT (..., RESEED, 0)`.
- **Alternativa descartada**: `TRUNCATE TABLE`. En SQL Server, `TRUNCATE TABLE dbo.Estanteria` arroja error de inmediato si existe una clave foránea que la referencia, incluso si la tabla hija está vacía.

### 3. Generación de ubicaciones mediante `CROSS JOIN`
- **Decisión**: Utilizar constructores de valores de tabla (`VALUES`) combinados con `CROSS JOIN`:
  ```sql
  SELECT E.CodigoEstanteria, X.x, Y.y
  FROM (VALUES ('E01'), ('E02'), ('E03')) AS E(CodigoEstanteria)
  CROSS JOIN (VALUES (1), (2), (3)) AS X(x)
  CROSS JOIN (VALUES (1), (2), (3), (4)) AS Y(y)
  ```
- **Razón**: Operación puramente basada en conjuntos (set-based), declarativa y legible sin bucles ni cursores.

### 4. Aleatoriedad en T-SQL con `CHECKSUM(NEWID())`
- **Decisión**: Para variar la cantidad y fecha de caducidad en cada registro insertado, usar expresiones basadas en `RAND(CHECKSUM(NEWID()))` o `ABS(CHECKSUM(NEWID()))`.
- **Razón**: En SQL Server, una llamada simple a `RAND()` dentro de una consulta de inserción devuelve el mismo valor para todas las filas procesadas. Sembrar con `NEWID()` garantiza valores distintos por fila.

## Risks / Trade-offs

- **[Riesgo] Pruebas existentes en `test_restricciones.sql` pueden fallar**: La prueba que verificaba la unicidad de `CodigoEstanteria` (insertando `E01` con las mismas coordenadas) debe probar específicamente la duplicidad de la tupla `(CodigoEstanteria, x, y)`.
  - *Mitigación*: Actualizar `test_restricciones.sql` en conjunto con la modificación de `model.sql`.
- **[Riesgo] Cantidades aleatorias fuera de rango**: La columna `Cantidad` es `DECIMAL(5,2)` y debe ser mayor que 0.00 y menor a 1000.00.
  - *Mitigación*: Acotar las fórmulas aleatorias a rangos seguros (por ejemplo entre 1.00 y 99.99).
