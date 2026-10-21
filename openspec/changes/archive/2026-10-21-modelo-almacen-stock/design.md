# Design: Modelo de Almacén y Stock en T-SQL

## Context

Véase `proposal.md` para la motivación. Se implementa un modelo de datos relacional para Microsoft SQL Server utilizando T-SQL estándar. El repositorio está configurado como un entorno de entrenamiento y prueba de concepto para gestión de almacenes.

## Goals / Non-Goals

**Goals:**
- Generar un script DDL en T-SQL idempotente y bien estructurado denominado `model.sql` que cree las tablas `Estanteria` y `Stock`.
- Implementar validaciones declarativas estrictas mediante restricciones `CHECK` para formato de códigos (`E##` y `P##`), valores no negativos para coordenadas y cantidades estrictamente positivas (`> 0.00`).
- Configurar claves primarias autonuméricas (`IDENTITY(1,1)`) y la relación de integridad referencial (FK) entre `Stock` y `Estanteria`.
- Proporcionar casos de prueba para verificar las restricciones declaradas.

**Non-Goals:**
- Gestión de pasillos o topología 3D compleja (se mantiene en 2D `(x, y)` por estantería).
- Separación de una tabla intermedia `Ubicacion` (descartada para mantener la simplicidad de la PoC).
- Lógica procedural (Stored Procedures, Triggers o Funciones de negocio).

## Decisions

### Decisión 1: Modelo directo de dos entidades
- **Elección:** Diseñar directamente las tablas `Estanteria` y `Stock` vinculadas mediante clave foránea.
- **Razón:** Elegido durante la fase de exploración como Opción 1 para mantener la máxima simplicidad en una prueba de concepto.
- **Alternativas consideradas:** Crear una entidad intermedia `Ubicacion (EstanteriaId, x, y)` para estanterías multicelda. Se descartó por sobrediseño en esta fase inicial.

### Decisión 2: Nombre del script de base de datos
- **Elección:** Archivo `model.sql` en la raíz del proyecto.
- **Razón:** Simplifica el acceso y ejecución del script DDL principal para el modelo relacional.

### Decisión 3: Tipos de datos para códigos con formato fijo
- **Elección:** `CHAR(3)` para `CodigoEstanteria` y `CodigoProducto`.
- **Razón:** Los códigos tienen longitud estricta y fija de 3 caracteres (`'E'` o `'P'` seguido de dos dígitos numéricos). `CHAR(3)` es más eficiente y comunica claramente la longitud fija sin sobrecarga de longitud variable.
- **Alternativas consideradas:** `VARCHAR(3)` o `NVARCHAR(3)`.

### Decisión 4: Precisión de columna Cantidad
- **Elección:** `DECIMAL(5, 2)`.
- **Razón:** El requisito pide 3 dígitos enteros y 2 decimales. En SQL Server la precisión total es la suma de enteros y escala: `3 + 2 = 5`, con escala `2`. Rango: hasta `999.99`.
- **Restricción:** `CHECK (Cantidad > 0.00)` para garantizar positividad estricta.

### Decisión 5: Validación de formato con CHECK y LIKE
- **Elección:** `CHECK (LEN(CodigoEstanteria) = 3 AND CodigoEstanteria LIKE 'E[0-9][0-9]')` y `CHECK (LEN(CodigoProducto) = 3 AND CodigoProducto LIKE 'P[0-9][0-9]')`.
- **Razón:** Las expresiones regulares completas no son nativas en T-SQL sin CLR, pero la coincidencia de patrones por rangos `[0-9]` en `LIKE` es nativa, altamente eficiente y estándar en SQL Server.

### Decisión 6: Idempotencia y orden de creación
- **Elección:** Control de existencia mediante `DROP TABLE IF EXISTS dbo.Stock; DROP TABLE IF EXISTS dbo.Estanteria;` (o comprobación con `OBJECT_ID`).
- **Razón:** Permite ejecutar `model.sql` múltiples veces en entornos de prueba y desarrollo sin errores de colisión.

## Risks / Trade-offs

- **[Riesgo: Dependencia de integridad referencial al eliminar tablas]** → **Mitigación:** Asegurar que en el script de limpieza se elimine primero la tabla hija `Stock` y posteriormente la tabla padre `Estanteria`.
- **[Riesgo: Colación no distingue mayúsculas (Case-Insensitive) permitiendo 'e01' o 'p01']** → **Mitigación:** Especificar colación binaria en la condición del CHECK (`COLLATE Latin1_General_BIN2 LIKE 'E[0-9][0-9]'`) para forzar que la letra inicial sea estrictamente mayúscula.
