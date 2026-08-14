# Diseño de Juego Whack-a-Mole (FPGA / Lógica Discreta)

## Primer Nivel: Descripción General del Sistema

En este primer nivel describe la función básica del circuito como juego de Whack-a-mole, partiendo de un circuito que tiene como entradas 8 botones los cuales controlan el desarrollo de la partida y una señal de reset general y mediante un circuito discreto encargado de generar la posición de los topos en la salida se estaría reflejando dos señales principales, una para un arreglo de LED´s (ON=topo activo) y un display de 7 segmentos para poder visualizar tanto los aciertos acumulados a lo largo de la partida como los fallos seguidos

![Diagrama de Bloques de Primer Nivel](diagrama_primer_nivel.png)

---

## Segundo Nivel: Arquitectura de Subsistemas

Para el diagrama de segundo nivel se manejan dos señales de CLK independientes, uno para el circuito discreto generado con un 555 que tiene como función principal controlar e indicar cuando se activa un botón(los cuales están asignados al “topo activo dados por los LEDs”) y otro CLK para la FPGA establecido en 100MHz, el cual controla e brinda las señales de activación de los LEDs(“topos”)

![Diagrama de Bloques de Segundo Nivel](diagrama_segundo_nivel.png)

## Cuarto Nivel


### Generador pseudoaleatorio de 3 bits

#### b) Diagrama

Este módulo corresponde al bloque encargado de generar la posición pseudoaleatoria utilizada posteriormente por el sistema para determinar cuál topo debe activarse.

![Diagrama modular del generador pseudoaleatorio](generador_pseudoaleatorio.png)

#### c) Objetivo del módulo

El objetivo de este módulo es generar de manera continua una **secuencia binaria pseudoaleatoria de 3 bits**, la cual será utilizada por los módulos posteriores del sistema para seleccionar la posición del topo que debe activarse.

Para generar esta secuencia se utiliza un registro de desplazamiento con realimentación lineal (**LFSR**) compuesto por tres flip-flops tipo D y una compuerta XOR. La actualización de los estados se realiza mediante una señal de reloj producida por un temporizador 555.

Las entradas `Seed_0`, `Seed_1` y `Seed_2` permiten establecer un estado inicial en el registro, mientras que `Rst` permite reiniciar los flip-flops.

#### d) Entradas

| Entrada | Descripción |
|---|---|
| `Seed_0` | Permite establecer el estado inicial del flip-flop `U1`. |
| `Seed_1` | Permite establecer el estado inicial del flip-flop `U2`. |
| `Seed_2` | Permite establecer el estado inicial del flip-flop `U3`. |
| `Rst` | Señal de reinicio común para los tres flip-flops. |

Adicionalmente, el módulo utiliza una alimentación de **5 V** para el circuito discreto.


#### e) Salidas

| Salida | Descripción |
|---|---|
| `Q0` | Bit almacenado en el flip-flop `U1`. |
| `Q1` | Bit almacenado en el flip-flop `U2`. |
| `Q2` | Bit almacenado en el flip-flop `U3`. |

Las tres señales en conjunto forman la salida pseudoaleatoria:

`Q2 Q1 Q0`

Esta combinación binaria representa el estado actual del generador y puede ser utilizada por los siguientes módulos para determinar la posición correspondiente al topo activo.

#### f) Relación con otros módulos

El generador pseudoaleatorio funciona como la fuente de selección de posiciones para el resto del sistema. Su salida de 3 bits es enviada al módulo encargado emisor del UART que enviara la informacion de manera serial al registro del receptor UART dentro de la fpga.

De esta manera, este módulo no activa directamente los LEDs, sino que proporciona el valor pseudoaleatorio utilizado posteriormente para seleccionar cuál de las posiciones disponibles debe representar al **topo activo**.


Por su parte, el temporizador 555 genera de forma independiente la señal de reloj requerida por el registro de desplazamiento, por lo que la velocidad con la que cambia el valor pseudoaleatorio depende de la frecuencia configurada en este temporizador.

#### g) Explicación de funcionamiento

El circuito está constituido por un temporizador 555, tres flip-flops tipo D (`U1`, `U2` y `U3`) y una compuerta XOR (`U5`).

El temporizador 555 funciona como generador de reloj. Su salida se encuentra conectada a las entradas de reloj de los tres flip-flops, permitiendo que todos actualicen su estado de forma sincronizada con cada pulso.

Los tres flip-flops forman un registro de desplazamiento. La salida `Q` de `U1` se conecta a la entrada `D` de `U2`, mientras que la salida `Q` de `U2` se conecta a la entrada `D` de `U3`. Por lo tanto, en cada pulso de reloj los bits almacenados se desplazan de una etapa hacia la siguiente.

La entrada del primer flip-flop `U1` se obtiene mediante la realimentación producida por la compuerta XOR `U5`. Esta compuerta recibe como entradas los estados correspondientes a `U2` y `U3`.

Por lo tanto, el estado siguiente del registro puede expresarse como:

```text
Q0(n+1) = Q1(n) XOR Q2(n)
Q1(n+1) = Q0(n)
Q2(n+1) = Q1(n)

---

### Indicador de posición mediante LEDs

#### b) Diagrama modular / Diseño 

Este módulo corresponde al bloque encargado de representar visualmente la posición del topo activo mediante un arreglo de 8 LEDs controlados individualmente por la FPGA.

![Diagrama modular del indicador de posición](indicador_leds.png)

#### c) Objetivo del módulo

El objetivo de este módulo es indicar visualmente cuál de las **8 posiciones posibles del topo** se encuentra activa durante el desarrollo de la partida.

Para realizar esta función se utilizan 8 LEDs independientes, donde cada LED representa una posición diferente dentro del juego. La FPGA controla individualmente cada una de las salidas, permitiendo encender únicamente el LED correspondiente a la posición seleccionada.

Cada LED se conecta en serie con una resistencia de **330 Ω**, utilizada para limitar la corriente que circula a través del dispositivo y proteger tanto el LED como la salida de la FPGA.

#### d) Entradas

| Entrada | Descripción |
|---|---|
| `LED_Encendido_0` | Señal de control proveniente de la FPGA para activar el LED 0. |
| `LED_Encendido_1` | Señal de control proveniente de la FPGA para activar el LED 1. |
| `LED_Encendido_2` | Señal de control proveniente de la FPGA para activar el LED 2. |
| `LED_Encendido_3` | Señal de control proveniente de la FPGA para activar el LED 3. |
| `LED_Encendido_4` | Señal de control proveniente de la FPGA para activar el LED 4. |
| `LED_Encendido_5` | Señal de control proveniente de la FPGA para activar el LED 5. |
| `LED_Encendido_6` | Señal de control proveniente de la FPGA para activar el LED 6. |
| `LED_Encendido_7` | Señal de control proveniente de la FPGA para activar el LED 7. |

Cada entrada corresponde a una salida digital independiente de la FPGA.

#### e) Salidas

Las salidas de este módulo son de tipo visual. El LED encendido representa directamente la posición en la que se encuentra el topo activo durante la partida.

#### f) Relación con otros módulos

Este módulo se encuentra directamente relacionado con el sistema de control implementado en la FPGA. La FPGA recibe la información correspondiente a la posición que debe ocupar el topo y, a partir de esta información, genera las señales `LED_Encendido_0` hasta `LED_Encendido_7`.

Cada una de estas señales controla una posición específica del arreglo de LEDs. De esta manera, el valor de posición determinado por los módulos anteriores se transforma en una indicación visual para el jugador.

El módulo también se relaciona indirectamente con el sistema de botones del juego, ya que el LED activo determina cuál de los botones debe presionar el jugador para registrar un acierto.

#### g) Explicación de funcionamiento

El circuito está compuesto por **8 LEDs**, cada uno conectado a una salida independiente de la FPGA mediante una resistencia de **330 Ω**.

Cada señal `LED_Encendido_n` controla directamente el LED asociado a la posición `n`. Cuando la FPGA coloca una de estas señales en nivel lógico alto, circula corriente desde la salida de la FPGA a través de la resistencia de 330 Ω y posteriormente a través del LED hacia tierra.





