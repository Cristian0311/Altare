# Isla Eterna Online — prototipo Godot 4

Base técnica inicial para un MMORPG móvil isométrico.

## Incluye
- Proyecto Godot 4 con escena 3D sencilla y cámara isométrica.
- Servidor autoritativo ENet/UDP configurable mediante `SERVER_PORT` (por defecto 7777).
- Movimiento procesado por servidor y controles táctiles básicos.
- Prototipo técnico; no es un MMORPG terminado ni está certificado para producción.

## Ejecutar localmente
Servidor: `godot --headless --path . -- --server`
Cliente: `godot --path . -- --client`

Requiere Godot 4.3 o posterior. Antes de publicar se necesitan pruebas de red, seguridad, persistencia, carga y compatibilidad.

## Altare
El servidor Altare informado es `th-bkk03.altare.global:25571`. El contenedor actualmente configurado es Node.js 20 y no ejecuta directamente este proyecto. Hace falta un build Linux dedicado de Godot y confirmar que la asignación permite UDP/ENet. No cambies el comando de arranque de Altare hasta completar esas verificaciones.
