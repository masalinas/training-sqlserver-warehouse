# Tasks: Despliegue del Modelo de Almacén mediante MCP mssql

## 1. Validación de Infraestructura y Configuración MCP

- [x] 1.1 Verificar la disponibilidad del contenedor Docker `sql-server-training` y la conectividad activa a la base de datos `training` mediante la herramienta `execute_sql` del MCP.
- [x] 1.2 Validar que la configuración de conexión en `.agents/mcp_config.json` y la versión compatible `mcp<2` en el entorno virtual de `mssql_mcp_server` permitan la comunicación sin errores.

## 2. Despliegue del Esquema T-SQL por Lotes

- [x] 2.1 Segmentar el archivo `model.sql` por las líneas de separación `GO` y ejecutar los lotes de limpieza idempotente (`DROP TABLE dbo.Stock` y `DROP TABLE dbo.Estanteria`) vía `execute_sql`.
- [x] 2.2 Ejecutar los lotes de creación DDL para `dbo.Estanteria` y `dbo.Stock` mediante `execute_sql`, verificando que ambas tablas y sus restricciones figuren en los metadatos de `sys.tables` y `sys.objects`.

## 3. Verificación de Integridad y Recursos MCP

- [x] 3.1 Ejecutar el script `test_restricciones.sql` mediante `execute_sql` comprobando que las 10 pruebas (2 positivas y 8 negativas) se completen con éxito.
- [x] 3.2 Consultar la API `list_resources` del servidor MCP `mssql` para verificar que los recursos `mssql://Estanteria/data` y `mssql://Stock/data` queden expuestos.
