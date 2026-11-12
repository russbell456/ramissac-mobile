# RAMIS ERP — Auditoría y optimización de Artículos

## 1. Resumen

Se revisó el módulo de Artículos en Flutter y FastAPI. Los cambios aplicados corrigen resultados fuera de orden en el notifier, evitan una recarga duplicada tras crear un artículo, centralizan la serialización de los payloads del modelo y reducen consultas repetidas al cargar imágenes en listados del backend. La pantalla de detalle también arma las URL de imagen usando la configuración Dio existente.

No se cambiaron endpoints, métodos HTTP, formatos JSON, permisos, roles, validaciones de inventario ni flujos de préstamos/devoluciones. No se crearon paquetes ni widgets visuales nuevos.

## 2. Arquitectura inspeccionada

### Flutter

- `lib/features/almacen/articulos/`: listado, detalle, formulario, notifier Riverpod y widgets propios del módulo.
- `lib/data/models/articulo_model.dart` y `articulo_imagen_model.dart`: deserialización y payloads enviados por el cliente.
- `lib/data/services/articulo_service.dart`: llamadas Dio a `/articulo`, `/articulo/disponibles`, `/articulo/buscar`, `/articulo/{id}`, activación, desactivación e imágenes.
- Design System: listado, detalle y formulario ya componían `RamisScaffold`, `RamisCard`, `RamisTextField`, `RamisButton`, `RamisLoading`, `RamisEmptyState`, `RamisErrorView` y widgets específicos de Artículos.

### Backend

- Router: `app/routers/almacen_articulo_router.py`.
- Servicio: `app/services/almacen_articulo_service.py`.
- Repositorio: `app/repositories/almacen_articulo_repository.py`.
- Esquemas y modelos: `app/schemas/almacen_articulo_schema.py`, `app/models/almacen_articulos.py` y `app/models/almacen_articulo_imagen.py`.
- Los préstamos consultan artículos disponibles por su propio provider y el backend de préstamos actualiza el inventario. Se revisó esa interacción; no se modificó ese módulo.

## 3. Hallazgos y cambios

### Archivos modificados por esta auditoría

**Flutter:**

- `lib/features/almacen/articulos/articulo_provider.dart`
- `lib/features/almacen/articulos/articulos_list_screen.dart`
- `lib/features/almacen/articulos/articulo_detail_screen.dart`
- `lib/data/models/articulo_model.dart`
- `test/features/almacen/articulos/articulo_provider_test.dart` (nuevo)
- `test/features/almacen/articulos/articulo_model_test.dart` (nuevo)

**Backend:**

- `app/repositories/almacen_articulo_repository.py`
- `app/services/almacen_articulo_service.py`
- `app/test/unit/test_articulo_gestion.py`

**Documentación:** `docs/RAMIS_ARTICULOS_OPTIMIZATION_REPORT.md`.

`articulo_service.dart`, `articulo_imagen_model.dart` y los widgets existentes se inspeccionaron sin cambiar el contrato de imágenes. El formulario recibió luego una sección para seleccionar y previsualizar imágenes antes de subirlas.

### Frontend y componentes

- Se reutilizaron los widgets existentes `ArticuloListCard`, `ArticuloDetailSection`, `ArticuloDetailRow`, `ArticuloInfoBanner` y `ArticuloImageTile`; no se añadió una abstracción nueva sin necesidad.
- El listado usaba un `LayoutBuilder` cuyo `constraints` no intervenía en el layout. Se eliminó el wrapper y se conservó el `ListView.separated` con construcción diferida.
- `ArticuloDetailScreen` tenía un dominio de producción escrito directamente para imágenes. Ahora usa `buildBackendUrl` y el `baseUrl` del Dio configurado, conservando URL absolutas cuando ya vienen completas.
- El formulario ya estaba compuesto por secciones y controles RAMIS. Se conservaron sus campos, validaciones, protección de stock, configuración de alto valor, confirmaciones y resultado de navegación.
- El formulario de creación y edición ahora permite seleccionar varias imágenes JPG, PNG o WEBP de hasta 5 MB, verlas y quitarlas antes de guardar. Después de crear o actualizar el artículo, sube cada archivo al endpoint multipart existente usando el ID devuelto por la API; si alguna carga falla, informa los nombres y permite reintentar desde la edición.
- Las cargas múltiples se realizan desde `ArticulosListNotifier.subirImagenes`; los fallos parciales se devuelven por archivo y la lista compartida se actualiza una sola vez si hubo cargas correctas.

### Notifier Riverpod

- `ArticulosListNotifier` y `articulosListProvider` conservan nombres, firmas públicas, tipos y operaciones de servicio.
- Cada carga recibe una revisión. Una búsqueda o recarga nueva invalida la respuesta anterior, incluso si la carga inicial seguía pendiente.
- Los datos actuales se mantienen durante la carga. Si una actualización falla, el estado conserva los datos previos junto al error; el `AsyncValue.when` existente sigue mostrando el estado de error y el botón de reintento.
- Crear, actualizar, activar, desactivar, subir imagen y eliminar imagen continúan sincronizando la lista mediante el notifier.

### Servicio Flutter y modelos

- `ArticuloService` ya tenía una llamada por operación, parser de listas compartido y contratos diferenciados por endpoint. No se cambió para evitar reducir capas de error o alterar requests sin un beneficio probado.
- `toCreateJson()` y `toUpdateJson()` compartían casi todos los mismos campos. Ahora delegan en `_toRequestJson`; `stock_total` y `stock_actual` solo se incluyen en creación, como antes.
- Las operaciones de consulta y mutación del detalle mantienen las lecturas necesarias para refrescar su modelo local y la lista compartida.

### Backend

- `get_all`, `get_all_disponibles` y `search` serializan las imágenes de cada artículo. Antes la relación SQLAlchemy se cargaba de forma diferida por artículo; ahora `selectinload` trae todas las imágenes en una consulta adicional por lote.
- `get_by_id` declara también la carga anticipada de imágenes, manteniendo el mismo resultado de detalle.
- La subida de imagen ahora lee como máximo el límite permitido más un byte antes de rechazar un archivo grande. Se conserva el mismo límite de 5 MB, tipos permitidos y respuesta de error.
- Se añadieron pruebas de consulta por lote y de representación de los indicadores de foto en el esquema. Se conserva la regla existente de alto valor y fotos.

## 4. Comparación de medidas

| Medida | Antes | Después | Base de comparación |
|---|---:|---:|---|
| Líneas en los siete archivos principales de Flutter | 2,546 | 2,439 | Conteo de líneas en el árbol de trabajo al inicio y después de los cambios; reducción de 107 líneas (4.2%). Incluye listado, detalle, formulario, notifier, servicio y modelos. |
| GET de lista después de crear correctamente | 2 | 1 | La creación hace POST y el notifier una recarga GET; el listado repetía el GET al volver. Ahora solo se reintenta desde el listado si la recarga del notifier falló. |
| SELECT para listar `N` artículos con imágenes | `1 + N` | `2` | Forma de carga SQLAlchemy observada en el código: consulta de artículos más una por artículo con la relación lazy; ahora consulta de artículos más carga select-in por lote. Es una comparación estructural, no una medición de tiempo. |
| Componentes de Artículos nuevos | 0 | 0 | Se conservaron los widgets RAMIS y específicos ya existentes. |
| Latencia HTTP/SQL medida | No disponible | No disponible | No se reportan mejoras de tiempo porque los tests de backend no pudieron ejecutarse en este entorno. |

El conteo de líneas cubre los mismos siete archivos principales antes y después, no todos los archivos del repositorio. Había otros cambios sin confirmar en ambos worktrees al iniciar la tarea; no se revirtieron ni se atribuyeron a esta optimización.

## 5. Contratos, seguridad y compatibilidad

- No se modificaron endpoints, métodos HTTP, headers, parámetros, cuerpos de request ni formato de respuesta.
- No se modificaron transacciones, esquema de base de datos ni reglas de stock.
- No se modificaron préstamos ni devoluciones.
- No se cambiaron autenticación, roles ni autorización. Las escrituras de artículos siguen restringidas por el router a `admin` y `almacenero`; las lecturas conservan la exposición que ya tenían.
- Las rutas de activación/desactivación, su validación de unidades prestadas y los mensajes/códigos de estado existentes se mantuvieron.
- La edición sigue omitiendo el stock; la creación conserva ambos campos de stock.

## 6. Pruebas y validación

### Línea base

- `flutter test --no-pub`: no produjo salida durante 45 segundos; se interrumpió. No se pudo obtener un resultado de pruebas de línea base.
- `pytest -q ...`: `pytest` no estaba disponible en el Python global.
- `.venv\Scripts\python.exe -m pytest ...`: el entorno virtual no tenía `pytest`.
- `venv\Scripts\python.exe -m pytest ...`: encontró pytest, pero la carga de `app/conftest.py` falló porque falta `python-dotenv` (`ModuleNotFoundError: No module named 'dotenv'`).

### Después de los cambios

- `dart analyze` sobre Artículos, modelos, servicio Flutter y las pruebas nuevas: **No issues found**.
- `flutter test --no-pub test/features/almacen/articulos`: no produjo salida durante 45 segundos; se interrumpió. Los tests nuevos están escritos, pero no se consideran ejecutados.
- `venv\Scripts\python.exe -m pytest -q app/test/unit/test_articulo_gestion.py app/test/integration/test_articulo_integration.py`: continúa bloqueado por la dependencia faltante `python-dotenv`.
- Parseo AST de los archivos Python modificados: **correcto**.
- `git diff --check` de los archivos modificados: sin errores de whitespace. Dart reportó avisos de conversión LF/CRLF de Git.
- `dart format` formateó los archivos, pero el proceso terminó con código 1 al no poder actualizar el archivo de telemetría en `%APPDATA%\.dart-tool`; el formato de los archivos sí se aplicó.

### Pruebas añadidas

- Flutter: carga inicial frente a búsqueda, búsquedas fuera de orden, conservación de datos durante una recarga fallida y contratos de payload del modelo.
- Backend: carga por lote de imágenes y representación de banderas fotográficas para artículos de alto valor.

## 7. Limitaciones y próximos pasos

- Para validar ejecución real de backend, instalar las dependencias del proyecto en el entorno de pruebas y volver a correr `venv\Scripts\python.exe -m pytest -q app/test/unit/test_articulo_gestion.py app/test/integration/test_articulo_integration.py`.
- Para validar los tests Flutter, resolver el bloqueo de `flutter test --no-pub` y ejecutar también `flutter test --no-pub test/features/almacen/articulos`.
- No se midieron tiempos de respuesta ni se usó una base de datos de producción. El cambio SQL reduce la forma de consultas de N+1 a carga por lote, pero la latencia real queda pendiente de medición bajo el mismo conjunto de datos.
- Los endpoints GET conservan el acceso que tenían. Cualquier cambio de autorización requiere una revisión independiente y no se incluye en esta optimización.
