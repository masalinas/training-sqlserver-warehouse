# warehouse Specification

## Purpose

Proporciona la especificación completa del sistema de gestión de almacén en Microsoft SQL Server, abarcando el modelo de datos relacional (Estanteria y Stock), las restricciones de integridad, el aprovisionamiento y despliegue idempotente mediante MCP mssql, la generación de datos mock y el conjunto de consultas analíticas operativas.

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

### Requirement: Despliegue de Esquemas T-SQL con Separadores de Lote
El sistema SHALL permitir desplegar scripts T-SQL que contienen separadores de lote cliente `GO` mediante el servidor MCP `mssql`, segmentando el script en lotes ejecutables individualmente a través de la herramienta `execute_sql`.

#### Scenario: Despliegue exitoso de tablas idempotentes
- **WHEN** se envía el script `model.sql` segmentado por lotes secuenciales
- **THEN** la base de datos elimina previamente las tablas existentes si existen y crea las tablas `dbo.Estanteria` y `dbo.Stock` con sus restricciones asociadas sin errores de sintaxis

### Requirement: Verificación Automatizada de Restricciones
El sistema SHALL ejecutar la suite de pruebas de integridad `test_restricciones.sql` mediante el MCP `mssql` para certificar que el modelo desplegado aplica de forma estricta las reglas de negocio y restricciones relacionales.

#### Scenario: Validación de casos positivos y negativos
- **WHEN** se ejecuta el script de pruebas sobre las tablas creadas
- **THEN** el sistema registra la inserción exitosa de registros válidos y captura el rechazo esperado ante violaciones de unicidad, formato de códigos, coordenadas negativas, cantidades no positivas y claves foráneas inexistentes

### Requirement: Exposición de Recursos MCP
El servidor MCP `mssql` SHALL exponer como recursos navegables (`resources`) las tablas de usuario creadas en el modelo de base de datos.

#### Scenario: Descubrimiento de recursos de tablas
- **WHEN** un cliente MCP solicita el listado de recursos mediante `list_resources`
- **THEN** la respuesta incluye los URIs `mssql://Estanteria/data` y `mssql://Stock/data`

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

### Requirement: Aprovisionamiento y Validación de Datos Mock mediante MCP
El sistema SHALL permitir el aprovisionamiento de datos mock en la base de datos Microsoft SQL Server mediante la ejecución del script `mocks.sql` a través de la herramienta `execute_sql` del servidor MCP `mssql`, garantizando la verificación remota de la distribución de ubicaciones y stock.

#### Scenario: Ejecución de mocks mediante MCP
- **WHEN** un cliente MCP ejecuta las sentencias de `mocks.sql` sobre la base de datos utilizando `execute_sql`
- **THEN** la base de datos se limpia de forma ordenada y se pueblan exactamente 36 ubicaciones en `Estanteria` y registros de stock en `Stock` sin errores de clave foránea ni de unicidad

#### Scenario: Certificación de aislamiento en estanterías
- **WHEN** se consulta el conteo de stock por estantería mediante `execute_sql` tras el aprovisionamiento
- **THEN** el resultado confirma que las estanterías `E01` y `E02` contienen stock asociado y que la estantería `E03` contiene exactamente 0 registros de stock

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

### Requirement: Persistencia y Documentación de Resultados Analíticos
El sistema SHALL volcar el resultado de la ejecución de las consultas contenidas en `queries.sql` en un archivo denominado `results.md` en la raíz del proyecto, presentando de forma legible y estructurada el código SQL ejecutado y su correspondiente tabla de resultados obtenida a través de la herramienta `execute_sql` del servidor MCP `mssql`.

#### Scenario: Generación exitosa de results.md
- **WHEN** se ejecutan las consultas analíticas de `queries.sql` mediante el MCP `mssql`
- **THEN** se crea el archivo `results.md` conteniendo las 4 consultas analíticas junto a sus tablas de resultados formateadas en Markdown

#### Scenario: Correspondencia de datos analíticos
- **WHEN** se inspecciona el archivo `results.md`
- **THEN** los resultados reflejan la rotura de stock para `P00`, la estantería vacía `E03`, los extremos de ocupación para `E02` y `E03`, y los 2 productos con vencimiento más próximo ordenados ascendentemente
