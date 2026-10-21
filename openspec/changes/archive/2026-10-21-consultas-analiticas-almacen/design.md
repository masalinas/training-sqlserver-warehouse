# Design

## Context

El almacén cuenta con datos mock generados en las tablas `dbo.Estanteria` y `dbo.Stock`. Con el fin de evaluar situaciones comunes del negocio (roturas de stock, capacidad ociosa, estanterías al límite y alertas de caducidad), se formaliza la creación de un script `queries.sql` que encapsula cuatro consultas analíticas especializadas.

Ver `proposal.md` y `specs/warehouse-stock/spec.md` para los requisitos y alcance.

## Goals / Non-Goals

**Goals:**
- Proporcionar un script SQL `queries.sql` formateado, documentado y ejecutable de forma independiente.
- Resolver la detección de rotura de stock sin alterar el modelo relacional existente, empleando un catálogo de artículos simulado en un CTE.
- Proveer consultas analíticas para estanterías vacías, estantería más/menos llena y próximos productos a caducar.
- Garantizar la compatibilidad T-SQL en Microsoft SQL Server.

**Non-Goals:**
- No se crea una nueva tabla de artículos (`dbo.Producto`).
- No se crean vistas persistentes ni procedimientos almacenados en la base de datos.
- No se modifican las tablas existentes ni los datos mock ya cargados.

## Decisions

### 1. Detección de Rotura de Stock mediante Catálogo en CTE
- **Decisión**: Declarar un CTE `CatalogoProductos` con constructores de valores de tabla (`VALUES ('P00', 'Producto Sin Stock'), ('P01', ...), ...`) y cruzarlo mediante `LEFT JOIN` con `dbo.Stock`, filtrando con `HAVING COUNT(S.StockId) = 0 OR SUM(S.Cantidad) = 0`.
- **Alternativa descartada**: Crear una tabla física `dbo.Producto`. Aunque normalizado, requeriría modificar el modelo DDL, actualizar scripts previos y alterar las restricciones existentes.
- **Razón**: Mantiene el modelo sencillo y sin cambios estructurales innecesarios para las pruebas actuales.

### 2. Estanterías Vacías a Nivel Mueble (`CodigoEstanteria`)
- **Decisión**: Agrupar por `E.CodigoEstanteria` y filtrar con `HAVING COUNT(S.StockId) = 0`.
- **Razón**: Permite identificar de inmediato muebles completos disponibles (como `E03`) sin dispersar la información a nivel de celda `(x, y)`.

### 3. Carga Extrema mediante `UNION ALL` de `TOP 1`
- **Decisión**: Usar un CTE común `OcupacionEstanterias` que calcula `ISNULL(SUM(S.Cantidad), 0.00)` y extraer en un solo conjunto la estantería más llena y la menos llena mediante `UNION ALL`.
- **Razón**: Devuelve un resultado unificado, etiquetado y fácil de interpretar en una única ejecución.

### 4. Proximidad de Caducidad por Producto
- **Decisión**: Filtrar `WHERE Caducidad IS NOT NULL`, agrupar por `CodigoProducto`, calcular `MIN(Caducidad)` y ordenar ascendentemente limitando a `TOP 2`.
- **Razón**: Evita falsos positivos con productos imperecederos (`NULL`) y muestra el lote más crítico de cada artículo.

## Risks / Trade-offs

- **[Riesgo] Empates en valores extremos**: Si dos estanterías tienen la misma cantidad total, un simple `TOP 1` tomaría una de ellas de forma no determinista.
  - *Mitigación*: Incluir un criterio secundario de ordenación determinista por `CodigoEstanteria` (`ORDER BY TotalCantidad DESC, CodigoEstanteria ASC`).
