# Spec Delta

## ADDED Requirements

### Requirement: Aprovisionamiento y Validación de Datos Mock mediante MCP
El sistema SHALL permitir el aprovisionamiento de datos mock en la base de datos Microsoft SQL Server mediante la ejecución del script `mocks.sql` a través de la herramienta `execute_sql` del servidor MCP `mssql`, garantizando la verificación remota de la distribución de ubicaciones y stock.

#### Scenario: Ejecución de mocks mediante MCP
- **WHEN** un cliente MCP ejecuta las sentencias de `mocks.sql` sobre la base de datos utilizando `execute_sql`
- **THEN** la base de datos se limpia de forma ordenada y se pueblan exactamente 36 ubicaciones en `Estanteria` y registros de stock en `Stock` sin errores de clave foránea ni de unicidad

#### Scenario: Certificación de aislamiento en estanterías
- **WHEN** se consulta el conteo de stock por estantería mediante `execute_sql` tras el aprovisionamiento
- **THEN** el resultado confirma que las estanterías `E01` y `E02` contienen stock asociado y que la estantería `E03` contiene exactamente 0 registros de stock
