# warehouse-stock Specification

## Purpose

Proporciona el modelo de datos relacional y las restricciones de integridad para gestionar las estanterías del almacén y el stock de productos ubicado en las mismas.

## Requirements

### Requirement: Estructura e integridad de la entidad Estanteria
El sistema SHALL definir la tabla `Estanteria` para almacenar ubicaciones del almacén con las siguientes características:
- Columna `EstanteriaId` de tipo `INT IDENTITY(1,1)` como clave primaria obligatoria.
- Columna `CodigoEstanteria` de tipo `CHAR(3)` obligatoria, restringida al formato alfanumérico que inicia con `'E'` seguido de dos dígitos numéricos (`E[0-9][0-9]`).
- Columna `x` de tipo `INT` obligatoria con valor mayor o igual a 0.
- Columna `y` de tipo `INT` obligatoria con valor mayor o igual a 0.
- Restricción de unicidad compuesta sobre la tupla `(CodigoEstanteria, x, y)` para garantizar que una estantería no repita la misma ubicación pero pueda contener múltiples ubicaciones diferenciadas.

#### Scenario: Inserción válida de estantería
- **WHEN** se inserta un registro con `CodigoEstanteria = 'E01'`, `x = 0` e `y = 0` y otro con `CodigoEstanteria = 'E01'`, `x = 0` e `y = 1`
- **THEN** la base de datos acepta ambas inserciones y genera identificadores autonuméricos `EstanteriaId` distintos

#### Scenario: Rechazo por código de estantería duplicado
- **WHEN** se intenta insertar una estantería con una tupla `(CodigoEstanteria, x, y)` que ya existe en la tabla
- **THEN** la base de datos rechaza la operación por violación de restricción de unicidad compuesta

#### Scenario: Rechazo por formato de código de estantería inválido
- **WHEN** se intenta insertar una estantería con un `CodigoEstanteria` que no cumple el patrón `'E[0-9][0-9]'` (por ejemplo `'A01'`, `'E1'` o `'EAA'`)
- **THEN** la base de datos rechaza la operación por violación de la restricción CHECK

#### Scenario: Rechazo por coordenadas negativas
- **WHEN** se intenta insertar una estantería con `x < 0` o `y < 0`
- **THEN** la base de datos rechaza la operación por violación de la restricción CHECK

### Requirement: Estructura e integridad de la entidad Stock
El sistema SHALL definir la tabla `Stock` para registrar el producto y cantidad en una estantería con las siguientes características:
- Columna `StockId` de tipo `INT IDENTITY(1,1)` como clave primaria obligatoria.
- Columna `EstanteriaId` de tipo `INT` obligatoria como clave foránea referenciando a `Estanteria(EstanteriaId)`.
- Columna `CodigoProducto` de tipo `CHAR(3)` obligatoria, restringida al formato alfanumérico que inicia con `'P'` seguido de dos dígitos numéricos (`P[0-9][0-9]`).
- Columna `Cantidad` de tipo `DECIMAL(5,2)` obligatoria, con restricción de valor estrictamente positivo (`Cantidad > 0.00`).
- Columna `Caducidad` de tipo `DATE` opcional (`NULL`).

#### Scenario: Inserción válida de stock con caducidad
- **WHEN** se inserta un registro de stock con un `EstanteriaId` existente, `CodigoProducto = 'P01'`, `Cantidad = 15.50` y `Caducidad = '2026-12-31'`
- **THEN** la base de datos acepta la inserción y genera un `StockId`

#### Scenario: Inserción válida de stock sin caducidad
- **WHEN** se inserta un registro de stock con un `EstanteriaId` existente, `CodigoProducto = 'P02'`, `Cantidad = 1.00` y `Caducidad = NULL`
- **THEN** la base de datos acepta la inserción correctamente

#### Scenario: Rechazo por referencia a estantería inexistente
- **WHEN** se intenta insertar stock indicando un `EstanteriaId` que no existe en la tabla `Estanteria`
- **THEN** la base de datos rechaza la operación por violación de clave foránea

#### Scenario: Rechazo por formato de código de producto inválido
- **WHEN** se intenta insertar stock con un `CodigoProducto` que no cumple el patrón `'P[0-9][0-9]'` (por ejemplo `'X01'` o `'P999'`)
- **THEN** la base de datos rechaza la operación por violación de la restricción CHECK

#### Scenario: Rechazo por cantidad cero o negativa
- **WHEN** se intenta insertar stock con `Cantidad <= 0.00` (por ejemplo `0.00` o `-5.00`)
- **THEN** la base de datos rechaza la operación por violación de la restricción CHECK

### Requirement: Archivo de script de base de datos
El sistema SHALL contener la definición completa del esquema T-SQL en un archivo denominado `model.sql`.

#### Scenario: Generación del script de modelo
- **WHEN** se implementa el modelo de base de datos
- **THEN** el script T-SQL resultante se encuentra en `model.sql`

### Requirement: Generación y carga de datos mock
El sistema SHALL proporcionar un script denominado `mocks.sql` para poblar la base de datos con datos de prueba siguiendo las siguientes reglas:
- Realizar limpieza previa completa y ordenada de las tablas `Stock` y `Estanteria`, reiniciando los contadores autonuméricos (`IDENTITY`).
- Generar 3 estanterías (`E01`, `E02`, `E03`) con 3 posiciones longitudinales (`x` de 1 a 3) y 4 alturas (`y` de 1 a 4), creando un total de 36 ubicaciones.
- Generar registros de stock aleatorios para productos (`P01`, `P02`, `P03`) ubicados exclusivamente en ubicaciones pertenecientes a las estanterías `E01` y `E02`.
- Asignar a cada registro de stock una cantidad aleatoria estrictamente positiva (`DECIMAL(5,2)` mayor a `0.00`).
- Asignar fechas de caducidad aleatorias (con presencia de valores `NULL`).

#### Scenario: Ejecución idempotente de mocks.sql
- **WHEN** se ejecuta el script `mocks.sql` sobre la base de datos
- **THEN** las tablas `Estanteria` y `Stock` quedan pobladas con exactamente 36 ubicaciones y registros de stock válidos cumpliendo todas las restricciones de integridad sin arrojar errores

#### Scenario: Distribución de stock en estanterías autorizadas
- **WHEN** se consultan las ubicaciones asignadas en la tabla `Stock` tras ejecutar `mocks.sql`
- **THEN** todos los registros de stock están asociados únicamente a ubicaciones de las estanterías `E01` y `E02`, y ninguna ubicación de `E03` posee stock asignado

### Requirement: Consultas Analíticas del Almacén
El sistema SHALL proporcionar un script denominado `queries.sql` con un conjunto de consultas analíticas optimizadas en T-SQL para verificar el estado operativo del almacén y sus datos:
- Consulta de rotura de stock mediante comparación de un catálogo esperado en CTE con las existencias reales en `Stock`.
- Consulta de estanterías vacías identificando los códigos de estantería que carecen de stock almacenado.
- Consulta de ocupación extrema identificando la estantería más llena y la menos llena en base a la cantidad acumulada de unidades de producto.
- Consulta de productos próximos a caducar obteniendo los 2 productos con fecha de vencimiento más temprana, excluyendo registros con caducidad no informada (`NULL`).

#### Scenario: Detección de productos en rotura de stock
- **WHEN** se ejecuta la consulta de rotura de stock sobre los datos del almacén
- **THEN** el resultado incluye los códigos de productos definidos en el catálogo que no cuentan con ningún registro de stock en `Stock`

#### Scenario: Identificación de estanterías vacías
- **WHEN** se ejecuta la consulta de estanterías vacías
- **THEN** el resultado retorna exclusivamente los códigos de estantería que no poseen ningún registro en `Stock` (por ejemplo `E03`)

#### Scenario: Determinación de estanterías con carga máxima y mínima
- **WHEN** se ejecuta la consulta de ocupación de estanterías
- **THEN** el resultado presenta en un único conjunto de resultados la estantería con mayor volumen de unidades (`MÁS LLENA`) y la de menor volumen (`MENOS LLENA`)

#### Scenario: Listado de productos con caducidad más cercana
- **WHEN** se ejecuta la consulta de proximidad de caducidad
- **THEN** el resultado retorna exactamente los 2 productos con la menor fecha de caducidad válida (`IS NOT NULL`) ordenados ascendentemente
