# Spec Delta: warehouse-stock

## Purpose

Proporciona el modelo de datos relacional y las restricciones de integridad para gestionar las estanterías del almacén y el stock de productos ubicado en las mismas.

## ADDED Requirements

### Requirement: Estructura e integridad de la entidad Estanteria
El sistema SHALL definir la tabla `Estanteria` para almacenar ubicaciones del almacén con las siguientes características:
- Columna `EstanteriaId` de tipo `INT IDENTITY(1,1)` como clave primaria obligatoria.
- Columna `CodigoEstanteria` de tipo `CHAR(3)` obligatoria, única, y restringida al formato alfanumérico que inicia con `'E'` seguido de dos dígitos numéricos (`E[0-9][0-9]`).
- Columna `x` de tipo `INT` obligatoria con valor mayor o igual a 0.
- Columna `y` de tipo `INT` obligatoria con valor mayor o igual a 0.

#### Scenario: Inserción válida de estantería
- **WHEN** se inserta un registro con `CodigoEstanteria = 'E01'`, `x = 0` e `y = 0`
- **THEN** la base de datos acepta la inserción y genera un identificador autonumérico `EstanteriaId`

#### Scenario: Rechazo por código de estantería duplicado
- **WHEN** se intenta insertar una estantería con un `CodigoEstanteria` que ya existe en la tabla
- **THEN** la base de datos rechaza la operación por violación de restricción de unicidad

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
