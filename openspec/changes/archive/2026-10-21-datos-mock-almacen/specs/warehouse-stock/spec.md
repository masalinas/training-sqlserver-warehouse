# Spec Delta

## MODIFIED Requirements

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

## ADDED Requirements

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
