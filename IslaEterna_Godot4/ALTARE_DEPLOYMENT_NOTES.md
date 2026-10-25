# Notas de despliegue Altare

El proyecto Godot está en `IslaEterna_Godot4/`. GitHub Actions intenta importar/validar el proyecto y exportar un servidor Linux dedicado de Godot 4.3.

## Compilación automática
- Workflow: `.github/workflows/validate-godot.yml`
- Se ejecuta al cambiar archivos del proyecto o manualmente desde GitHub Actions.
- Si termina correctamente, publica el artefacto `IslaEterna-Linux-Dedicated-Server` con ejecutable, PCK, script de arranque y estas instrucciones.
- Un commit en GitHub o la existencia del workflow no significa que la compilación haya pasado; hay que revisar el resultado real del workflow.

## Altare: bloqueadores que faltan por confirmar
Altare muestra un contenedor Node.js 20 y un comando de inicio que busca `index.js`/TypeScript; eso no ejecuta directamente el servidor Godot. Antes de cambiarlo, confirma en Altare que permite:
1. Ejecutar un binario Linux personalizado (no solamente Node.js).
2. Tráfico UDP entrante y saliente para ENet.
3. Usar el puerto UDP asignado. El puerto mostrado previamente es `25571`, pero no debe configurarse como UDP hasta que el proveedor lo confirme.

El servidor usa la variable de entorno `SERVER_PORT`; si no está definida, usa UDP 7777. Cuando Altare confirme que el puerto 25571 admite UDP, configura `SERVER_PORT=25571` y utiliza el script `start-server.sh` incluido en el artefacto.

## Verificación de despliegue
1. Comprueba que el workflow terminó en verde y que el artefacto existe.
2. Descarga el ZIP desde la sección Artifacts de la ejecución de GitHub Actions.
3. Sube los archivos extraídos al servicio Altare solamente si permite binarios Linux personalizados.
4. Arranca el proceso y revisa que la consola indique que el servidor está escuchando en el puerto configurado.
5. Prueba desde un cliente Godot externo. El despliegue no se considera validado hasta que un cliente conecte por ENet/UDP.

No subas contraseñas, tokens, claves privadas ni credenciales SFTP al repositorio.
