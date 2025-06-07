# Para hacer este contrato de subasta, primero leí bien la consiga.

---

Y luego de a poco fui cargando el esqueleto que iba a necesitar (con la logica y funciones)para luego ir desarrollandolo.

**Tuve que ir testeando cada vez para asegurarme de que todo funcionara correctamente.**

Por ejemplo lo que hice para controlar si la función canParticipate tornaba a false una vez terminado el tiempo de la subasta,fue poner 30 segundos, 
entonces pasado ese tiempo llamaba a la función y efectivamente cambiaba el booleano.

Al principio seteé variables para el dueño del contrato y otras como el tiempo del contrato, la oferta ganadora y su correspondiente dueño.
Las puse privadas porque luego se mostrarán dentro de una función. Eso es para no marear y tenerlas visibles repetidas.
En un array guardé las ofertas, pero cada una tenía 2 variables importantes: el monto de oferta y su dirección asi que las guardé en un Struct.
En el constructor se envía la duración y quién iba a ser el dueño.

Al ser un contrato que iba a recibir Ether, es necesario agregar la función receive() y es indispensable poner la palabra reservada "payable" 
en la función makeAnOffer. La misma NO recibe parámetros, porque de hacerlo sería un grave error. Ya que la única manera en que se acumula dinero real 
es con msg.value y en Remix por default se utiliza desde el frontend.
Para verificar que el contrato estuviera recibiendo correctamente los montos, había creado una función que devuelva:address(this).balanceno se le puede 
asignar montos, es de solo lectura pero me servia para corroborar lo que estaba haciendo. Es por esoque una vez finalizada las pruebas la he eliminado.
Para hacer la oferta se pusieron los requiere solicitados en la consigna.Verificando que la oferta supere la anterior por al menos un 5%.

Se guardaba en la variable como oferta nueva y se emitia el evento.Lo he probado y se puede ver. Hay que decodificar el string porque está en hexa.
La función para retirar también funciona.Chequeando que quién quiera llamarla previamente haya depositado.Que no pueda sacar más de lo que tenga.
Y que el ganador no pueda utilizarla.

Se muestra un listado con todas las personas participantes (solo sus addresses por temas de privacidad) junto con sus ofertas.
Y una función para que solo el dueño pueda retirar la plata una vez que haya terminado el tiempo, junto con el modificador necesario.
