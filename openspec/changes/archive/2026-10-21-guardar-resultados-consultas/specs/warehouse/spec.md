# Spec Delta

## ADDED Requirements

### Requirement: Persistencia y Documentación de Resultados Analíticos
El sistema SHALL volcar el resultado de la ejecución de las consultas contenidas en `queries.sql` en un archivo denominado `results.md` en la raíz del proyecto, presentando de forma legible y estructurada el código SQL ejecutado y su correspondiente tabla de resultados obtenida a través de la herramienta `execute_sql` del servidor MCP `mssql`.

#### Scenario: Generación exitosa de results.md
- **WHEN** se ejecutan las consultas analíticas de `queries.sql` mediante el MCP `mssql`
- **THEN** se crea el archivo `results.md` conteniendo las 4 consultas analíticas junto a sus tablas de resultados formateadas en Markdown

#### Scenario: Correspondencia de datos analíticos
- **WHEN** se inspecciona el archivo `results.md`
- **THEN** los resultados reflejan la rotura de stock para `P00`, la estantería vacía `E03`, los extremos de ocupación para `E02` y `E03`, y los 2 productos con vencimiento más próximo ordenados ascendentemente
