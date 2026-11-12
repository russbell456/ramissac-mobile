# Módulo de préstamos en Flutter

## Organización

El código del módulo se concentra en `lib/features/almacen/prestamos/`:

- `screens/`: catálogo y carrito, solicitud QR, registro manual, lectura QR, confirmación, consulta de préstamos y devoluciones.
- `providers/`: estado del carrito, artículos, trabajador actual, trabajador seleccionable y operaciones del préstamo.
- `services/`: llamadas al backend y construcción de solicitudes multipart.
- `widgets/`: controles reutilizables del módulo, incluida la captura/selección de fotos.

Se actualizaron las pantallas de almacén y dashboard para usar esta ubicación. Se eliminaron archivos vacíos o sin referencias y providers duplicados que no eran usados por el flujo activo. El carrito vigente (`carrito_provider.dart`) se conservó porque lo consume el módulo y también el dashboard.

## Flujo disponible en Flutter

### Trabajador: solicitud por QR

1. Consulta artículos disponibles, elige cantidades y revisa el carrito.
2. Selecciona la fecha prevista de devolución y revisa el resumen.
3. Envía la solicitud al backend y presenta el código QR para que almacén la recupere.

### Almacenero: confirmación de solicitud

1. Escanea el QR y revisa los datos de la solicitud.
2. Captura la firma de entrega.
3. Para artículos marcados como alto valor, solicita y envía fotos de estado inicial por multipart.
4. Confirma el préstamo; el backend registra la entrega y actualiza el stock según sus reglas.

### Almacenero: registro manual

1. Arma el carrito antes de poder seleccionar al trabajador.
2. Define fecha prevista, tipo de préstamo y asociación/datos requeridos.
3. Revisa el resumen, recoge firma y evidencia fotográfica de artículos de alto valor.
4. Registra el préstamo.

### Consulta y devolución

- Se pueden consultar los préstamos del trabajador y revisar el detalle/documento PDF.
- La devolución parte del préstamo seleccionado, admite cantidades parciales pendientes y usa multipart para firma y fotos de los artículos que requieren evidencia.
- Al backend le corresponde registrar la fecha real, actualizar estados/stock retornable, guardar fotos y calcular el importe informativo.

## Rutas del backend consideradas

El servicio Flutter se integra con estas rutas bajo el prefijo de almacén:

| Operación | Ruta |
| --- | --- |
| Crear solicitud del trabajador | `POST /almacen/solicitudes-prestamo` |
| Recuperar solicitud por código QR | `GET /almacen/solicitudes-prestamo/{codigo_unico}` |
| Confirmar solicitud con firma y evidencias | `POST /almacen/solicitudes-prestamo/{prestamo_id}/confirmar` |
| Registrar préstamo QR | `POST /almacen/registrar-prestamo-qr` |
| Registrar préstamo manual | `POST /almacen/registrar-prestamo-manual` |
| PDF del préstamo | `GET /almacen/prestamo/{prestamo_id}/pdf` |
| Préstamos de un trabajador | `GET /almacen/trabajador/{trabajador_id}/prestamos` |
| Préstamos asociados a un artículo | `GET /almacen/articulo/{articulo_id}/prestamos` |
| Registrar devolución parcial/total | `POST /almacen/registrar-devolucion-qr` |
| Listar/consultar obras | `GET /almacen/obra/`, `GET /almacen/obra/{obra_id}` |

La devolución usa multipart con `datos`, `firma`, `fotos` y `fotos_metadata`. El backend devuelve por detalle `minutos_efectivos`, `dias_tarifa`, `minutos_residuales`, tarifas aplicadas, importe informativo y URL de la foto final; la respuesta también incluye el almacenero que recibió y la firma.

## Pendiente para completar la paridad funcional

1. **Desglose del cálculo informativo en UI.** El backend ya calcula minutos efectivos dentro del horario permitido, días de tarifa, minutos residuales y tarifas aplicadas. Flutter debe presentar ese desglose por artículo/devolución; actualmente la pantalla se centra en el total informativo.
2. **Historial de devoluciones en el detalle del préstamo.** Verificar y completar la presentación de cada devolución con fecha, cantidades, almacenero, firma y `foto_estado_fin_url`. El esquema del préstamo anidado no expone hoy todo el desglose de cálculo de la respuesta individual de devolución; para reconstruirlo desde historial el backend tendría que exponer esos campos en `devoluciones`.
3. **Recuperación de solicitudes QR pendientes.** El flujo permite generar y mostrar el QR, pero no hay endpoint backend para listar/recuperar las solicitudes pendientes del trabajador ni para cancelarlas. Si se cierra la pantalla antes de que almacén escanee el QR, falta una ruta backend y una pantalla de pendientes para recuperar la solicitud.
4. **Búsqueda general de préstamos para almacén.** El backend ofrece consulta por trabajador o por artículo, pero no una lista general filtrable de préstamos activos. La operación de almacén funciona principalmente desde QR; para bandeja de pendientes/activos se requiere endpoint backend.
5. **Historial por artículo desde Flutter.** Existe `GET /almacen/articulo/{articulo_id}/prestamos`, pero no está conectado a una pantalla del módulo.
6. **Documento tras devoluciones.** El backend mantiene/regenera el PDF general del préstamo conforme se registran devoluciones. Flutter debe volver a descargar/abrir el PDF después de una devolución si la pantalla muestra un documento que ya estaba cargado; no se genera un PDF separado por devolución.
7. **Validación integral en dispositivo.** Revisar en el teléfono los permisos de cámara/galería, selección de imágenes, compresión, firma, escaneo de ambos tipos de QR, conectividad y apertura/descarga del PDF, incluidos artículos de alto valor y devoluciones parciales.

## Reglas que debe conservar la interfaz

- Los tipos de préstamo son `interno`, `obra` y `externo`; los datos requeridos deben seguir las validaciones del backend.
- Solo los artículos con indicador de alto valor obligan a adjuntar evidencia en entrega y devolución.
- Una devolución solo afecta detalles pendientes del préstamo seleccionado y puede ser parcial.
- El cálculo es informativo y utiliza el horario efectivo definido por backend (06:00–12:00 y 13:00–18:00; 11 horas efectivas equivalen a un día). El frontend no debe recalcular ni reemplazar el valor del backend.
- El almacenero que entrega/recibe, las firmas y las evidencias forman parte de la trazabilidad del préstamo.
