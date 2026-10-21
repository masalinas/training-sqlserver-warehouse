# Proposal

## Why

Una vez implementado el modelo relacional y pobladas las tablas con datos mock representativos mediante `mocks.sql`, se requiere disponer de un conjunto estandarizado de consultas T-SQL agrupadas en un script `queries.sql`. Este script permite verificar el comportamiento del almacén ante situaciones operativas comunes: identificación de roturas de stock, localización de estanterías vacías, análisis de carga de estanterías (máxima y mínima) y detección preventiva de productos próximos a caducar.

## What Changes

- Creación del archivo `queries.sql` con 4 consultas analíticas en T-SQL:
  - **Consulta 1 (Rotura de stock)**: Detección de productos de un catálogo esperado que no cuentan con existencias en el almacén mediante un catálogo simulado en CTE (`P00`), sin alterar el modelo relacional existente.
  - **Consulta 2 (Estanterías vacías)**: Localización de estanterías que tienen cero registros de stock en todas sus ubicaciones (mostrando el código de estantería, ej. `E03`).
  - **Consulta 3 (Estantería más y menos llena)**: Identificación de los dos extremos de carga volumétrica de stock en una única consulta (`MÁS LLENA` y `MENOS LLENA`).
  - **Consulta 4 (Próximos a caducar)**: Obtención de los 2 productos con fecha de vencimiento más cercana (`MIN(Caducidad)`), excluyendo aquellos sin caducidad (`NULL`).

## Capabilities

### Modified Capabilities
- `warehouse-stock`: Añade los requisitos funcionales y escenarios de prueba para el archivo de consultas analíticas `queries.sql`.

## Impact

- **Código del proyecto**: Nuevo archivo de script SQL `queries.sql`.
- **Base de datos**: Consultas de solo lectura sobre las tablas existentes `dbo.Estanteria` y `dbo.Stock` sin impacto en el esquema DDL.
