# Design

## Context

El proyecto dispone del script `queries.sql` que implementa cuatro consultas analíticas clave para auditar el inventario del almacén (roturas de stock, estanterías vacías, ocupación máxima/mínima y vencimientos próximos). La base de datos Microsoft SQL Server está integrada con el entorno mediante el servidor MCP `mssql`. Se requiere plasmar de manera estática y accesible los resultados en `results.md`.

## Goals / Non-Goals

**Goals:**
- Ejecutar secuencialmente las consultas de `queries.sql` utilizando la herramienta `execute_sql` del MCP `mssql`.
- Documentar en `results.md` cada consulta con su descripción/propósito, su sentencia SQL T-SQL exacta y su tabla de resultados en Markdown.
- Mantener un formato visualmente limpio, legible y navegable.

**Non-Goals:**
- Modificar el script `queries.sql`, el esquema en `model.sql` ni la generación de datos en `mocks.sql`.
- Implementar un sistema dinámico automatizado de renderizado continuo de consultas.

## Decisions

- **Estructura del documento `results.md`**: Cada consulta dispondrá de una sección independiente con:
  1. Título descriptivo y objetivo analítico.
  2. Bloque de código con la sintaxis T-SQL ejecutada.
  3. Tabla Markdown con las columnas y registros devueltos por el motor SQL Server.
- **Formato de datos**: Utilizar formato Markdown estándar con alineación de columnas numéricas y de texto para máxima legibilidad.

## Risks / Trade-offs

- **[Variación de datos mock]** → Si se regenera `mocks.sql` con una semilla aleatoria diferente, los valores de `results.md` podrían diferir de una ejecución posterior. *Mitigación*: Se documentará la fecha de ejecución y el estado correspondiente a los datos actuales desplegados.
