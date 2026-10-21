# Spec Delta

## ADDED Requirements

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
