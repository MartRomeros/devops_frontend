# Editar el pipeline para que despliegue las actualizaciones en una ec2

Se debe editar el pipeline `deploy.yaml` para que pueda desplegar esta aplicacion y ejecutarla como docker
contenedor en el puerto 80

se desplegara en un EC2 con ubuntu por lo que se debe comprobar que exista docker y git
el flujo es que si es primera vez clone el repositorio construya la imagen o haga un pull al repositorio
creado.

si se hace un push debe actualizar la aplicacion, pushear al docker hub. y llevar las actualizaciones
al ec2

ya hay algo armado. revisarlo y modificarlo para este caso de negocio
indicar que secretos se necesitan para que este pipeline funcione correctamente
