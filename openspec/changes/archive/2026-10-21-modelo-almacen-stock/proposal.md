# Proposal: Modelo de Dominio de Almacén y Stock

## Why

Se requiere un modelo de datos relacional para gestionar el inventario y la ubicación física de productos dentro de un almacén en SQL Server. Como prueba de concepto inicial, el modelo debe permitir registrar estanterías con coordenadas en dos dimensiones y el stock de productos asociado a cada una, garantizando la integridad de datos mediante restricciones a nivel de base de datos.

## What Changes

- Crear la entidad `Estanteria` con clave primaria autonumérica, código alfanumérico único con formato específico (`E` seguido de dos dígitos) y coordenadas cartesianas longitudinal (`x`) y en altura (`y`) no negativas.
- Crear la entidad `Stock` con clave primaria autonumérica, clave foránea hacia `Estanteria`, código de producto (`P` seguido de dos dígitos), cantidad decimal estrictamente positiva (> 0) y fecha de caducidad opcional.
- Definir un script T-SQL idempotente denominado `model.sql` para SQL Server que declare las tablas, tipos de datos óptimos, claves foráneas y restricciones `CHECK` de formato y rango.

## Capabilities

### New Capabilities
- `warehouse-stock`: Gestión de estanterías y stock de productos en el almacén mediante esquema relacional en SQL Server en el archivo `model.sql`.

### Modified Capabilities
<!-- None -->

## Impact

- Creación del archivo `model.sql` con el script DDL de creación de tablas en T-SQL para SQL Server.
- No afecta sistemas existentes ya que es el modelo inicial del repositorio.
