# Isla Eterna Online — Godot 4 / Altare

El proyecto Godot se encuentra en `IslaEterna_Godot4/`. El workflow de GitHub Actions está preparado para importar el proyecto y generar un paquete Linux de servidor dedicado.

## Estado real
- Código fuente: subido a este repositorio.
- Exportación Linux dedicada: automatizada en `.github/workflows/validate-godot.yml`, pendiente de confirmar con una ejecución exitosa.
- Artefacto de servidor: se genera solo si el workflow termina correctamente.
- Altare: el contenedor observado usa Node.js 20 y busca `index.js`; eso no arranca directamente una aplicación Godot.
- Red: ENet usa UDP. Hay que confirmar con Altare que admite binarios Linux personalizados y UDP en el puerto asignado antes de cambiar el arranque.

## Cómo continuar desde Android
1. Abre la pestaña Actions de este repositorio: https://github.com/Cristian0311/Altare/actions
2. Abre la ejecución más reciente de **Validate and build Godot dedicated server**.
3. Si está en verde, descarga el artefacto `IslaEterna-Linux-Dedicated-Server` desde Artifacts.
4. No cambies el comando de inicio de Altare hasta confirmar que acepta ejecutables Linux personalizados y tráfico UDP.
5. Cuando el proveedor confirme UDP y el puerto asignado, configura `SERVER_PORT` con ese puerto y prueba una conexión real desde el cliente.

## Importante
Este proyecto sigue siendo un prototipo multijugador, no un MMORPG completo. Compilar el servidor no implementa por sí solo cuentas, base de datos, combate, inventario, persistencia ni protección anti-trampas. No se afirmará que está desplegado hasta que el proceso arranque y un cliente conecte correctamente.

No subas contraseñas, tokens, claves privadas ni credenciales SFTP a GitHub.
