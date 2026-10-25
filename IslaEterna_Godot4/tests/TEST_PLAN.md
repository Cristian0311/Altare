# Plan de pruebas manuales — fase inicial

1. Abrir el proyecto con Godot 4.3 o posterior y confirmar que carga scenes/main.tscn.
2. Arrancar el servidor con `godot --headless --path . -- --server`; verificar el mensaje de puerto.
3. Conectar un cliente a 127.0.0.1:7777 y después un segundo cliente.
4. Confirmar spawn/despawn de jugadores.
5. Confirmar movimiento con teclado y joystick.
6. Cerrar un cliente y verificar que su personaje desaparece.
7. Verificar el cambio de zona de prueba.
8. Probar el servidor exportado en Linux y comprobar el puerto UDP asignado en Altare.

Criterios de aceptación: sin errores de parseo, dos clientes conectados, movimiento sincronizado, servidor autoritativo y desconexión limpia. Registrar versión de Godot, dispositivos y logs. Estas pruebas aún no están certificadas como ejecutadas.
