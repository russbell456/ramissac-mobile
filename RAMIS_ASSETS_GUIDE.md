# RAMIS ERP · Emerald Tech — Paquete gráfico v1.0

## Precisión de marca
- `ramis_logo_original_referencia.png` conserva **exactamente** el logo enviado por el usuario (100×100 px).
- `ramis_logo_original_ampliado.png` es un reescalado de ese mismo archivo; **no es un logo vectorial ni ofrece detalle adicional**.
- `ramis_lockup_light.png` y `ramis_lockup_dark.png` son composiciones provisionales con el logo original dentro de una pastilla blanca y texto añadido: **no son una reproducción oficial autorizada del lockup**.
- `ramis_emblema_emerald_propuesto.png` y `ramis_app_icon_propuesto.png` son **rediseños visuales propuestos**, no el logotipo oficial. Usar solo tras validación de la empresa.
- Los fondos y banners son gráficos de interfaz originales, no imágenes de instalaciones reales.

## Archivos

### assets/logos/
- `ramis_logo_original_referencia.png` — respaldo original de marca.
- `ramis_logo_original_ampliado.png` — uso provisional en pantalla de inicio, especialmente sobre blanco.
- `ramis_lockup_light.png` — cabecera de login claro / splash, versión provisional.
- `ramis_lockup_dark.png` — cabecera de login oscuro / splash, con placa blanca por legibilidad.
- `ramis_emblema_emerald_propuesto.png` — símbolo ilustrativo transparente opcional.
- `ramis_app_icon_propuesto.png` — propuesta para launcher; aún requiere generar assets adaptativos Android si se aprueba.

### assets/images/
- `ramis_bg_login_light.png` — decorativo detrás del login claro.
- `ramis_bg_login_dark.png` — decorativo detrás del login oscuro.
- `ramis_bg_dashboard_light.png` — decorativo opcional para cabecera del dashboard claro.
- `ramis_bg_dashboard_dark.png` — decorativo opcional para cabecera del dashboard oscuro.
- `ramis_banner_abstract_light.png` — banner claro, sin texto.
- `ramis_banner_abstract_dark.png` — banner oscuro, sin texto.

## Reglas de Flutter
Usar `Image.asset('assets/logos/ramis_lockup_light.png')`, etc. El selector debe basarse en `Theme.of(context).brightness`. No introducir estos fondos como wallpaper de todos los formularios, porque reduce legibilidad.

`pubspec.yaml` ya contiene `assets/images/` y `assets/logos/`, por lo que no es necesario añadir rutas individuales. Tras copiar ejecutar `flutter pub get` y reiniciar completamente la app si el asset no se refleja con hot reload.

## Uso recomendado
- Login: fondo login de tema + logo oficial o lockup provisional, con formularios sobre superficie sólida.
- Dashboard: cabecera o banner opcional, tarjetas limpias sobre `scaffoldBackgroundColor`.
- Listados, préstamos, EPP, flota, requerimientos: sin fondos ilustrados detrás de tablas/formularios.
- Preferir texto `CORPORACIÓN RAMIS S.A.C.` renderizado en Flutter para asegurar nitidez y accesibilidad.

## Pendiente
Pedir logo maestro oficial SVG o PNG transparente de alta resolución para sustituir los provisionales sin pérdida de calidad. Verificar que los archivos de identidad propuesta son aprobados antes del lanzamiento público.
