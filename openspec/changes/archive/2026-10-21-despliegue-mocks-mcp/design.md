# Design

## Context

El proyecto dispone del script `mocks.sql` y del modelo de datos `model.sql` actualizado con la restricción `UQ_Estanteria_Ubicacion`. La herramienta `execute_sql` del servidor MCP `mssql` permite interactuar directamente con la instancia de Microsoft SQL Server para aplicar cambios DDL, ejecutar cargas de prueba y comprobar métricas de integridad.

Ver `proposal.md` y `specs/mcp-schema-deployment/spec.md` para los requisitos y alcance.

## Goals / Non-Goals

**Goals:**
- Validar programáticamente la presencia de la restricción `UQ_Estanteria_Ubicacion` en `dbo.Estanteria` en SQL Server mediante el MCP.
- Ejecutar el script `mocks.sql` mediante `execute_sql` asegurando la limpieza idempotente previa.
- Certificar a través de consultas analíticas MCP la correcta distribución de datos (36 ubicaciones, stock en E01 y E02, y E03 sin stock).

**Non-Goals:**
- No se modifican los archivos locales `model.sql` ni `mocks.sql`.
- No se altera la configuración ni el servidor MCP `mssql`.

## Decisions

### 1. Ejecución de sentencias en bloque a través de `execute_sql`
- **Decisión**: Enviar las sentencias de `mocks.sql` como un bloque transaccional o secuencial compatible sin depender del comando cliente `GO`.
- **Razón**: El controlador TDS del servidor MCP ejecuta las consultas directamente en el motor y no interpreta comandos de consola como `GO`.

### 2. Comprobación de estado vía metadatos y agregación SQL
- **Decisión**: Emplear consultas a `INFORMATION_SCHEMA.TABLE_CONSTRAINTS` y agregaciones `GROUP BY CodigoEstanteria` para verificar el estado de la base de datos tras la ejecución.
- **Razón**: Proporciona telemetría determinista e inspeccionable tanto para el agente como para el usuario.

## Risks / Trade-offs

- **[Riesgo] Reescritura accidental de datos reales**: `mocks.sql` ejecuta un `DELETE` completo sobre las tablas `Stock` y `Estanteria`.
  - *Mitigación*: Este entorno es exclusivo de pruebas de almacén (`training`) y la operación está explícitamente autorizada.
