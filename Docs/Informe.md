# Proyecto 1: Whack-a-mole

**Integrantes**

**Steven Sancho Orozco**  
*Escuela de Ingeniería Electrónica*
*Tecnológico de Costa Rica*  
Carné: 2019015506

**Dennis Manuel Arce Alvarez**  
*Escuela de Ingeniería Electrónica*  
*Tecnológico de Costa Rica*  
Carné: 2018151568

**Brayan Diaz Ruiz**  
*Escuela de Ingeniería Electrónica*  
*Tecnológico de Costa Rica*  
Carné: 

**Joan Franco Sandoval Campos**  
*Escuela de Ingeniería Electrónica*  
*Tecnológico de Costa Rica*  
Carné: 

*Fecha : 27/08/2026*
---


## Introducción

El juego “Whack-a-mole” trata de intentar presionar un topo dentro de una ventana de tiempo, donde para la adaptación se generó mediante el uso de un circuito discreto compuesto por 8 LED´s funcionando como los “8 topos” y 8 botones asignados a cada LED, además se implementa la arquitectura necesaria para poder construir la lógica del juego mediante una FPGA y módulos, con reglas específicas.
Primeramente, no hay manera de “ganar” el juego, se registrarán los aciertos hasta 99, al igual que los fallos en dos display de 7 segmentos. Las posibles formas de obtener fallos en el juego son mediante time-out, donde se presiona la tecla de una forma tardía para la ventana de tiempo, que va a disminuir mientras más aciertos acumulados tenga el usuario y la otra forma de obtener fallos es presionando el botón incorrecto. En otro display de 7 segmentos se mostrará el conteo del acumulado de hasta 3 fallos consecutivos hará que se reiniciará el juego, los cuales van a estar mostrados, reiniciándose desde 0 después de cada acierto, limpiando todos los datos, por aparte se integra un botón de reset general para cuando se quiere reiniciar manualmente la partida.

--- 


## Fundamentación teórica

Para comprender la elaboración de la arquitectura y circuito para el juego Whack-a-mole es importante tener varios conceptos presentes.empezando por un modelado de comportamiento, el cual describe el funcionamiento del ciercuito, con la debida implementación, por otra parte está la estructura del diseño, la cual describe las conexiones físicas del diseño, ya sea como para la parte discreta como para la comunicación entre la FPGA y el circuito discreto.
Las buenas prácticas de diseño parten de un diseño modular donde se describe el proyecto a gran escala hasta llegar a la lógica detrás de cada módulo implementado con VIVADO, quien traduce la lógica en un circuito, los cuales cumplen funciones indispensables para el funcionamiento del juego, incluyendo lógica de máquinas de estados, decodificadores, debouncer entre otros, los cuales manejan señales físicas, funcionando bajo un reloj de la FPGA establecido en 100MHz, mientras en el ASIC la lógica está dad por compuertas que manejar la aleatoriedad del topo activo.
En el proyecto se construye un circuito  con una parte discreta la cual incluye compuertas, LED´s, botones y temporizadores, los cuales comunican datos con la parte digital del circuito, en la FPGA, la cual sioncroniza los pines de entrada y salida, las cuales van a ser el medio de trabajo de los módulos, recibiendo señales como las pulsaciones de los botones y el reset del juego y enviando señales de topo activo y puntaje de aciertos y fallos en los display de 7 segmentos.
Es necesario para la elaboración del juego Whack-a-mole diferenciar entre la máquina de estados finitos de Mealy y Moore. En el funcionamiento de una máquina de Moore, la salida solo depende del estado actual, mientras que el funcionamiento de una máquina de Mealy la salida depende del estado actual y las entradas 

![Máquina de Mealy aplicada al proyecto](../images/fsm_Mealy.png)

En este ejemplo de la máquina de Mealy se puede evidenciar la lógica principal del juego 

![Ejemplo máquina de Moore](../images/fsm_Moore_ej.png)

En la máquina de Moore se observa que cada estado ya cuenta con una salida previamente definida de acuerdo al estado en el que se encuentre. La máquina de estados va funcionar sin problema mientras se tenga un buen manejo de tiempos en el diseño de hardware, con el set up time, que es el tiempo mínimo en el que el dato a trabajar esté estable a diferencia del hold time, que es el tiempo en el que un dato debe de estar después de sun flanco. Además se debe tomar en cuenta los tiempos de propagación, que es el tiempo máximo que tarda una salida en reflejar el cambio y el tiempo de contaminación es el tiempo mínimo que tarda la salida en empezar a cambiar, ya que al no ser tomados en cuenta dentro del análisis, puede llegar a causar señales erróneas o desalineadas, también existe una ruta crítica entre los componentes físicos del bloque combinacionacional, donde se presenta el mayor tiempo de propagación entre el registro origen y el registro destino.
Dentro de la lógica de la FPGA se utiliza un mismo reloj par todos los sistemas digitales(módulos) mediante el uso de clk enable al memento de registrar el pulso de cada botón del sistema discreto el cual se llegará a leer y verificar el acierto contra el LED asignado al botón presionado, evitando múltiples relojes entre mósulos y perder la sincronía interna. Siguiendo con la lógica del botón, se implementó un módulo debouncer, para evitar multiples flancos de señal en la entrada, el cual al presionar solo reciba un cambio de estado y el módulo lo pueda procesar la información correspondiente, teniendo en cuenta que el sistema completo funcionamediante una comunicación asíncrona, donde existe el riesgo de metaestabilidad, la cual se logra reducir mediante el uso de dos flip-flops (con las señales button_sync_0 y button_sync_1)en cascada sincronizados con un mismo reloj dentro de la lógica del módulo.

Para el procesamiento de información se implenta un registro de desplazamiento, el cual está elaborado con una cadena de flip-flops y compuertas XOR la cual va moviendo los bits de información de una forma ordenada(tabs) la cual va a ser procesada por el receptor, escogiendo el bit que alimenta a la compuerta XOR, existen dos formas de enviar y recibir la inormación,  en el proceso de un serie-paralelo, los bits de información entran uno a uno con N cantidad de pulsos de reloj, seguidamente el receptor maneja el bloque de N bits para su debida necesidad y para un proceso paralelo-serie, se carga un dato de N bits el cual seguidamente el receptor irá sacando bit a bit, por cada pulso de reloj. Para el proyecto Whack-a-mole, se utiliza un proceso serie-serie, donde se implementa un decodificador, que tiene como función principal leer una palabra binaria de N bits     la traduce a una salida de 2<sup>N</sup>. 
Finalmente se utiliza un bloque UART para la comicación asíncrona entra la FPGA y el sircuito discreto, regulada por el baurate, que con 1 bit de inicio activa la lectura de los 8 bits de información y finalmente dedica otro bit para cerrar la lectura, bajo un acuerdo de tiempo de bit.

---
