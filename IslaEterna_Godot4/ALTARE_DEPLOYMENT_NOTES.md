# Notas de despliegue Altare

Este directorio contiene el código fuente de Godot, no un ejecutable Linux exportado.

El servidor lee la variable de entorno SERVER_PORT si existe y usa UDP 7777 como valor predeterminado. Para una prueba local: `godot --headless --path . -- --server`.

Altare muestra actualmente un contenedor Node.js 20 y un comando de inicio que busca index.js/TypeScript; eso no ejecuta Godot. Se necesita un build Linux dedicado (ejecutable más recursos exportados o PCK, según la forma de exportación elegida). También debe confirmarse que el puerto asignado 25571 admite UDP. El hostname y puerto por sí solos no prueban que ENet sea compatible.

No subas credenciales, claves ni contraseñas al repositorio. No declares el despliegue exitoso hasta ver el servidor Godot arrancado y un cliente conectándose por ENet.
