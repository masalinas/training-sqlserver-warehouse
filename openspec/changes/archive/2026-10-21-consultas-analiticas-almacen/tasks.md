# Tasks

## 1. Implementación de Consultas T-SQL

- [x] 1.1 Crear el archivo `queries.sql` con la cabecera, comentarios estructurados y la Consulta 1 (Rotura de stock) comparando el catálogo esperado en CTE con `dbo.Stock`.
- [x] 1.2 Agregar en `queries.sql` la Consulta 2 (Estanterías vacías) filtrando los códigos de estantería sin stock asociado.
- [x] 1.3 Agregar en `queries.sql` la Consulta 3 (Estantería más llena y menos llena) mediante CTE y `UNION ALL` con ordenación determinista por cantidad acumulada.
- [x] 1.4 Agregar en `queries.sql` la Consulta 4 (Próximos productos a caducar) filtrando caducidades válidas y obteniendo los dos productos con fecha más cercana.

## 2. Validación y Ejecución

- [x] 2.1 Ejecutar el archivo `queries.sql` contra Microsoft SQL Server utilizando el MCP `mssql` y verificar que los resultados devueltos coincidan con los datos de prueba (`P00` en rotura, `E03` vacía, `E02`/`E01` en carga máxima/mínima y los 2 productos ordenados por vencimiento).
