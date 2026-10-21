# mcp-schema-deployment Specification

## Purpose

Permite aprovisionar de manera estructurada e idempotente esquemas relacionales T-SQL en Microsoft SQL Server mediante el servidor MCP mssql, verificando su integridad referencial y de dominio.

## Requirements

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
