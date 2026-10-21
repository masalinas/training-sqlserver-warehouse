# Design: Despliegue del Modelo de Almacén mediante MCP mssql

## Context

Véase `proposal.md` para la motivación general del cambio. El proyecto cuenta con el script DDL idempotente `model.sql` y la suite de pruebas `test_restricciones.sql`. El acceso a la base de datos SQL Server 2025 se efectúa mediante el servidor MCP `mssql` configurado en `.agents/mcp_config.json`, utilizando el controlador `pymssql` y comunicación stdio.

## Goals / Non-Goals

**Goals:**
- Proporcionar una estrategia sistemática de ejecución de scripts T-SQL con separadores `GO` a través de la herramienta `execute_sql` del MCP `mssql`.
- Garantizar que las tablas `dbo.Estanteria` y `dbo.Stock` queden desplegadas con todas sus restricciones en la base de datos `training`.
- Validar la integridad referencial y de dominio ejecutando `test_restricciones.sql`.
- Asegurar que los recursos expuestos por el MCP reflejen las nuevas tablas disponibles.

**Non-Goals:**
- Modificar el código fuente de `model.sql` para remover los separadores `GO`.
- Implementar un motor de migraciones complejo o herramientas externas tipo Flyway/Liquibase; el despliegue se apoya directamente en la infraestructura MCP existente.

## Decisions

### Decisión 1: Segmentación de scripts por lotes `GO` en el orquestador
- **Elección**: El orquestador / cliente MCP lee el archivo SQL, detecta los delimitadores `GO` (expresión regular `^\s*GO\s*$`) y despacha cada bloque resultante de forma secuencial a la herramienta `execute_sql`.
- **Razón**: El protocolo TDS y los drivers DB-API como `pymssql` no admiten la instrucción de cliente `GO`. Esta estrategia permite preservar intacto el código de `model.sql` manteniendo compatibilidad absoluta con SSMS y `sqlcmd`.
- **Alternativas consideradas**:
  - *Modificar `model.sql` para quitar `GO`*: Descartado para mantener el script estandarizado para herramientas nativas de SQL Server.
  - *Modificar `mssql_mcp_server`*: Descartado por estar fuera del alcance del proyecto actual y requerir cambios en repositorios externos.

### Decisión 2: Idempotencia basada en `DROP TABLE` condicional ordenado
- **Elección**: Ejecutar primero la eliminación condicional de `Stock` y luego la de `Estanteria` antes de recrearlas.
- **Razón**: `Stock` posee una clave foránea (`FK_Stock_Estanteria`) que apunta a `Estanteria`. Si se intentara eliminar `Estanteria` primero, SQL Server bloquearía la operación por violación de integridad referencial.
- **Alternativas consideradas**:
  - *Modo `ALTER TABLE ... CREATE IF NOT EXISTS`*: Menos limpio en T-SQL para pruebas de concepto donde se busca un estado determinista y reproducible desde cero.

### Decisión 3: Verificación de restricciones mediante ejecución de `test_restricciones.sql`
- **Elección**: Ejecutar el script completo de verificación que evalúa las 10 restricciones mediante bloques `TRY...CATCH`.
- **Razón**: Certifica de extremo a extremo que el esquema desplegado no solo tiene la definición correcta en metadatos, sino que el motor de base de datos aplica efectivamente las restricciones ante datos válidos y datos infractores.

## Risks / Trade-offs

- **[Riesgo: Pérdida accidental de datos por DROP TABLE en entornos no dev]** → *Mitigación*: La base de datos es `training` en entorno local/desarrollo y la ejecución está confinada a este alcance.
- **[Riesgo: Desconexión o timeout del contenedor SQL Server]** → *Mitigación*: Validación previa del estado del contenedor Docker (`sql-server-training`) y configuración de timeouts en el cliente MCP.
- **[Riesgo: Incompatibilidad de versión del SDK `mcp`]** → *Mitigación*: Fijación estricta de `mcp>=1.0.0,<2` en `pyproject.toml` del servidor MCP.

## Migration Plan

1. Iniciar el contenedor de base de datos SQL Server si se encuentra detenido.
2. Comprobar que `.agents/mcp_config.json` tenga los parámetros correctos de conexión (`localhost:1433`, usuario `sa`, BD `training`).
3. Ejecutar los 4 lotes de `model.sql` en orden secuencial vía `execute_sql`.
4. Ejecutar `test_restricciones.sql` vía `execute_sql` y verificar que las 10 comprobaciones resulten satisfactorias.
5. Invocar `list_resources` en el MCP `mssql` para certificar la disponibilidad de `mssql://Estanteria/data` y `mssql://Stock/data`.
