# Resultados de Consultas Analíticas del Almacén

Resultados obtenidos a partir de la ejecución del script [`queries.sql`](queries.sql) mediante el servidor MCP `mssql` sobre Microsoft SQL Server, utilizando el conjunto de datos de prueba aprovisionado por [`mocks.sql`](mocks.sql).

---

## 1. Roturas de Stock (Productos sin existencias)

### Objetivo
Identificar los productos definidos en el catálogo teórico de artículos que no cuentan con existencias físicas en la tabla `Stock` del almacén.

### Consulta SQL
```sql
SELECT 
    C.CodigoProducto,
    C.Descripcion,
    ISNULL(SUM(S.Cantidad), 0.00) AS StockDisponible
FROM (VALUES 
    ('P00', 'Producto Sin Existencias'),
    ('P01', 'Producto P01'),
    ('P02', 'Producto P02'),
    ('P03', 'Producto P03')
) AS C(CodigoProducto, Descripcion)
LEFT JOIN dbo.Stock S ON C.CodigoProducto = S.CodigoProducto
GROUP BY C.CodigoProducto, C.Descripcion
HAVING COUNT(S.StockId) = 0 OR ISNULL(SUM(S.Cantidad), 0.00) = 0.00
ORDER BY C.CodigoProducto;
```

### Resultado
| CodigoProducto | Descripcion | StockDisponible |
| :--- | :--- | :---: |
| `P00` | Producto Sin Existencias | `0.00` |

*Interpretación*: El producto `P00` está catalogado pero tiene `0.00` unidades disponibles, detectándose una rotura de stock completa.

---

## 2. Estanterías Vacías (Sin Stock)

### Objetivo
Detectar qué estanterías del almacén carecen por completo de existencias en todas sus ubicaciones o huecos físicos disponibles.

### Consulta SQL
```sql
SELECT 
    E.CodigoEstanteria,
    COUNT(DISTINCT E.EstanteriaId) AS TotalHuecosDisponibles,
    COUNT(S.StockId) AS TotalLotesStock,
    ISNULL(SUM(S.Cantidad), 0.00) AS TotalUnidades
FROM dbo.Estanteria E
LEFT JOIN dbo.Stock S ON E.EstanteriaId = S.EstanteriaId
GROUP BY E.CodigoEstanteria
HAVING COUNT(S.StockId) = 0
ORDER BY E.CodigoEstanteria;
```

### Resultado
| CodigoEstanteria | TotalHuecosDisponibles | TotalLotesStock | TotalUnidades |
| :--- | :---: | :---: | :---: |
| `E03` | 12 | 0 | `0.00` |

*Interpretación*: La estantería `E03` cuenta con 12 huecos disponibles (3 posiciones `x` por 4 alturas `y`) y ningún lote ni unidad almacenada, confirmando su aislamiento como estantería libre.

---

## 3. Estantería Más Llena y Menos Llena

### Objetivo
Presentar en un único conjunto de resultados los extremos operativos del almacén: la estantería con mayor volumen de unidades acumuladas y la de menor volumen.

### Consulta SQL
```sql
SELECT * FROM (
    SELECT TOP 1 
        'MÁS LLENA' AS Categoria,
        E.CodigoEstanteria,
        COUNT(DISTINCT E.EstanteriaId) AS TotalHuecos,
        COUNT(S.StockId) AS TotalLotes,
        ISNULL(SUM(S.Cantidad), 0.00) AS TotalUnidades
    FROM dbo.Estanteria E
    LEFT JOIN dbo.Stock S ON E.EstanteriaId = S.EstanteriaId
    GROUP BY E.CodigoEstanteria
    ORDER BY TotalUnidades DESC, E.CodigoEstanteria ASC
) AS MasLlena

UNION ALL

SELECT * FROM (
    SELECT TOP 1 
        'MENOS LLENA' AS Categoria,
        E.CodigoEstanteria,
        COUNT(DISTINCT E.EstanteriaId) AS TotalHuecos,
        COUNT(S.StockId) AS TotalLotes,
        ISNULL(SUM(S.Cantidad), 0.00) AS TotalUnidades
    FROM dbo.Estanteria E
    LEFT JOIN dbo.Stock S ON E.EstanteriaId = S.EstanteriaId
    GROUP BY E.CodigoEstanteria
    ORDER BY TotalUnidades ASC, E.CodigoEstanteria ASC
) AS MenosLlena;
```

### Resultado
| Categoria | CodigoEstanteria | TotalHuecos | TotalLotes | TotalUnidades |
| :--- | :--- | :---: | :---: | :---: |
| `MÁS LLENA` | `E02` | 12 | 9 | `621.39` |
| `MENOS LLENA` | `E03` | 12 | 0 | `0.00` |

*Interpretación*: La estantería `E02` es la de mayor ocupación con 9 lotes y un total de `621.39` unidades, mientras que `E03` es la de menor ocupación con 0 unidades.

---

## 4. Los 2 Productos que Antes Caduquen

### Objetivo
Identificar los 2 productos que presentan la fecha de vencimiento más temprana (excluyendo registros con caducidad no informada o `NULL`), ordenados ascendentemente.

### Consulta SQL
```sql
SELECT TOP 2 
    CodigoProducto, 
    MIN(Caducidad) AS ProximaCaducidad,
    COUNT(StockId) AS LotesConCaducidad,
    SUM(Cantidad) AS UnidadesEnRiesgo
FROM dbo.Stock
WHERE Caducidad IS NOT NULL
GROUP BY CodigoProducto
ORDER BY ProximaCaducidad ASC;
```

### Resultado
| CodigoProducto | ProximaCaducidad | LotesConCaducidad | UnidadesEnRiesgo |
| :--- | :---: | :---: | :---: |
| `P01` | 2026-11-27 | 4 | `306.13` |
| `P03` | 2026-12-02 | 4 | `293.48` |

*Interpretación*: El producto `P01` tiene su primer lote en riesgo de vencer el `2026-11-27` (con 4 lotes y `306.13` unidades en riesgo), seguido por `P03` con vencimiento el `2026-12-02` (4 lotes y `293.48` unidades).
