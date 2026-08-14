# Diseño de Juego Whack-a-Mole (FPGA / Lógica Discreta)

## Primer Nivel: Descripción General del Sistema

En este primer nivel describe la función básica del circuito como juego de Whack-a-mole, partiendo de un circuito que tiene como entradas 8 botones los cuales controlan el desarrollo de la partida y una señal de reset general y mediante un circuito discreto encargado de generar la posición de los topos en la salida se estaría reflejando dos señales principales, una para un arreglo de LED´s (ON=topo activo) y un display de 7 segmentos para poder visualizar tanto los aciertos acumulados a lo largo de la partida como los fallos seguidos

![Diagrama de Bloques de Primer Nivel](../images/nivel1.png)
---

## Segundo Nivel: Arquitectura de Subsistemas

Para el diagrama de segundo nivel se manejan dos señales de CLK independientes, uno para el circuito discreto generado con un 555 que tiene como función principal controlar e indicar cuando se activa un botón(los cuales están asignados al “topo activo dados por los LEDs”) y otro CLK para la FPGA establecido en 100MHz, el cual controla e brinda las señales de activación de los LEDs(“topos”)

![Diagrama de Bloques de Segundo Nivel](../images/nivel2.png)

## Cuarto Nivel


### Generador pseudoaleatorio de 3 bits

#### a) Diagrama / Diseño 

Este módulo corresponde al bloque encargado de generar la posición pseudoaleatoria utilizada posteriormente por el sistema para determinar cuál topo debe activarse.

![Diagrama modular del generador pseudoaleatorio](../images/generador_pseudoaleatorio.png)

#### b) Objetivo del módulo

El objetivo de este módulo es generar de manera continua una **secuencia binaria pseudoaleatoria de 3 bits**, la cual será utilizada por los módulos posteriores del sistema para seleccionar la posición del topo que debe activarse.

Para generar esta secuencia se utiliza un registro de desplazamiento con realimentación lineal (**LFSR**) compuesto por tres flip-flops tipo D y una compuerta XOR. La actualización de los estados se realiza mediante una señal de reloj producida por un temporizador 555.

Las entradas `Seed_0`, `Seed_1` y `Seed_2` permiten establecer un estado inicial en el registro, mientras que `Rst` permite reiniciar los flip-flops.

#### c) Entradas

| Entrada | Descripción |
|---|---|
| `Seed_0` | Permite establecer el estado inicial del flip-flop `U1`. |
| `Seed_1` | Permite establecer el estado inicial del flip-flop `U2`. |
| `Seed_2` | Permite establecer el estado inicial del flip-flop `U3`. |
| `Rst` | Señal de reinicio común para los tres flip-flops. |

Adicionalmente, el módulo utiliza una alimentación de **5 V** para el circuito discreto.


#### d) Salidas

| Salida | Descripción |
|---|---|
| `Q0` | Bit almacenado en el flip-flop `U1`. |
| `Q1` | Bit almacenado en el flip-flop `U2`. |
| `Q2` | Bit almacenado en el flip-flop `U3`. |

Las tres señales en conjunto forman la salida pseudoaleatoria:

`Q2 Q1 Q0`

Esta combinación binaria representa el estado actual del generador y puede ser utilizada por los siguientes módulos para determinar la posición correspondiente al topo activo.

#### e) Relación con otros módulos

El generador pseudoaleatorio funciona como la fuente de selección de posiciones para el resto del sistema. Su salida de 3 bits es enviada al módulo encargado emisor del UART que enviara la informacion de manera serial al registro del receptor UART dentro de la fpga.

De esta manera, este módulo no activa directamente los LEDs, sino que proporciona el valor pseudoaleatorio utilizado posteriormente para seleccionar cuál de las posiciones disponibles debe representar al **topo activo**.


Por su parte, el temporizador 555 genera de forma independiente la señal de reloj requerida por el registro de desplazamiento, por lo que la velocidad con la que cambia el valor pseudoaleatorio depende de la frecuencia configurada en este temporizador.

#### f) Explicación de funcionamiento

El circuito está constituido por un temporizador 555, tres flip-flops tipo D (`U1`, `U2` y `U3`) y una compuerta XOR (`U5`).

El temporizador 555 funciona como generador de reloj. Su salida se encuentra conectada a las entradas de reloj de los tres flip-flops, permitiendo que todos actualicen su estado de forma sincronizada con cada pulso.

Los tres flip-flops forman un registro de desplazamiento. La salida `Q` de `U1` se conecta a la entrada `D` de `U2`, mientras que la salida `Q` de `U2` se conecta a la entrada `D` de `U3`. Por lo tanto, en cada pulso de reloj los bits almacenados se desplazan de una etapa hacia la siguiente.

La entrada del primer flip-flop `U1` se obtiene mediante la realimentación producida por la compuerta XOR `U5`. Esta compuerta recibe como entradas los estados correspondientes a `U2` y `U3`.

Por lo tanto, el estado siguiente del registro puede expresarse como:

```text
Q0(n+1) = Q1(n) XOR Q2(n)
Q1(n+1) = Q0(n)
Q2(n+1) = Q1(n)
```



### Indicador de posición mediante LEDs

#### a) Diagrama modular / Diseño 

Este módulo corresponde al bloque encargado de representar visualmente la posición del topo activo mediante un arreglo de 8 LEDs controlados individualmente por la FPGA.

![Diagrama modular del indicador de posición](../images/indicador_leds.png)

#### b) Objetivo del módulo

El objetivo de este módulo es indicar visualmente cuál de las **8 posiciones posibles del topo** se encuentra activa durante el desarrollo de la partida.

Para realizar esta función se utilizan 8 LEDs independientes, donde cada LED representa una posición diferente dentro del juego. La FPGA controla individualmente cada una de las salidas, permitiendo encender únicamente el LED correspondiente a la posición seleccionada.

Cada LED se conecta en serie con una resistencia de **330 Ω**, utilizada para limitar la corriente que circula a través del dispositivo y proteger tanto el LED como la salida de la FPGA.

#### c) Entradas

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

#### d) Salidas

Las salidas de este módulo son de tipo visual. El LED encendido representa directamente la posición en la que se encuentra el topo activo durante la partida.

#### e) Relación con otros módulos

Este módulo se encuentra directamente relacionado con el sistema de control implementado en la FPGA. La FPGA recibe la información correspondiente a la posición que debe ocupar el topo y, a partir de esta información, genera las señales `LED_Encendido_0` hasta `LED_Encendido_7`.

Cada una de estas señales controla una posición específica del arreglo de LEDs. De esta manera, el valor de posición determinado por los módulos anteriores se transforma en una indicación visual para el jugador.

El módulo también se relaciona indirectamente con el sistema de botones del juego, ya que el LED activo determina cuál de los botones debe presionar el jugador para registrar un acierto.

#### f) Explicación de funcionamiento

El circuito está compuesto por **8 LEDs**, cada uno conectado a una salida independiente de la FPGA mediante una resistencia de **330 Ω**.

Cada señal `LED_Encendido_n` controla directamente el LED asociado a la posición `n`. Cuando la FPGA coloca una de estas señales en nivel lógico alto, circula corriente desde la salida de la FPGA a través de la resistencia de 330 Ω y posteriormente a través del LED hacia tierra.



### Administrador de puntajes

#### a) Diagrama modular

Este módulo corresponde al bloque encargado de administrar los **aciertos, fallos totales y fallos consecutivos** producidos durante la partida. Además, permite determinar cuándo el jugador alcanza tres fallos consecutivos para generar una señal hacia el controlador principal.

![Diagrama modular del administrador de puntajes](../images/indicador_leds.png)
#### b) Objetivo del módulo

El objetivo del módulo es llevar el registro de los resultados obtenidos por el jugador durante la partida.

El administrador mantiene tres valores principales: la cantidad de **aciertos acumulados**, la cantidad de **fallos acumulados** y la cantidad de **fallos consecutivos**.

Los valores correspondientes a los aciertos y fallos acumulados son enviados al sistema de visualización mediante displays de 7 segmentos. Por otra parte, el registro de fallos consecutivos es comparado con el valor `3` para determinar cuándo el jugador ha cometido tres fallos consecutivos.

Cuando esta condición se cumple, el módulo genera la señal `3_fallos`, que es enviada al controlador principal para indicar que debe finalizar o reiniciar la partida.

#### c) Entradas

| Entrada | Descripción |
|---|---|
| `Sumar_acierto` | Señal que indica que el jugador acertó la posición del topo y que debe incrementarse el registro de aciertos. |
| `Sumar_fallo` | Señal que indica que el jugador cometió un fallo y que deben actualizarse los registros correspondientes. |
| `Rst` | Señal utilizada para reiniciar los registros del administrador de puntajes. |

####d) Salidas

| Salida | Descripción |
|---|---|
| `Aciertos` | Valor almacenado en el registro de aciertos y enviado al sistema de visualización de 7 segmentos. |
| `Fallos` | Valor almacenado en el registro de fallos y enviado al sistema de visualización de 7 segmentos. |
| `3_fallos` | Señal que indica que se han alcanzado tres fallos consecutivos. |

El registro de fallos consecutivos se utiliza internamente para determinar la condición de tres fallos y no necesita mostrarse directamente en los displays.

#### e) Relación con otros módulos

El administrador de puntajes recibe las señales `Sumar_acierto` y `Sumar_fallo` provenientes del módulo encargado de determinar si la acción realizada por el jugador corresponde a un acierto o a un fallo.

Cuando se recibe `Sumar_acierto`, el módulo actualiza el registro de aciertos y reinicia el conteo de fallos consecutivos, debido a que un acierto interrumpe la secuencia de fallos.

Cuando se recibe `Sumar_fallo`, se incrementa tanto el registro de fallos acumulados como el registro de fallos consecutivos.

Los registros de aciertos y fallos se conectan con el módulo encargado de controlar los displays de 7 segmentos, permitiendo visualizar el puntaje durante la partida.

Por otra parte, el registro de fallos consecutivos se conecta internamente con un comparador. Cuando este registro alcanza el valor `3`, se genera la señal `3_fallos`, la cual es enviada al controlador principal para indicar que se ha alcanzado la condición de finalización correspondiente.

#### f) Explicación de funcionamiento

El módulo utiliza tres registros independientes para almacenar los resultados de la partida:

- **Registro de aciertos:** almacena la cantidad total de aciertos realizados por el jugador.
- **Registro de fallos:** almacena la cantidad total de fallos realizados durante la partida.
- **Registro de fallos consecutivos:** almacena únicamente la cantidad de fallos realizados de manera consecutiva.

Cada registro posee un sumador asociado. La salida actual del registro se realimenta hacia su respectivo sumador, permitiendo incrementar el valor almacenado cuando se recibe la señal correspondiente.

Cuando `Sumar_acierto` se activa, el registro de aciertos incrementa su valor en una unidad:

```text
Aciertos(n+1) = Aciertos(n) + 1
```

Al mismo tiempo, el registro de fallos consecutivos se reinicia, ya que el acierto rompe la secuencia de fallos consecutivos.

Cuando Sumar_fallo se activa, se incrementa el registro de fallos totales:

```text
Fallos(n+1) = Fallos(n) + 1
```

También se incrementa el registro de fallos consecutivos:

```text
Fallos_consecutivos(n+1) = Fallos_consecutivos(n) + 1
```

El valor almacenado en el registro de fallos consecutivos se conecta a un comparador, el cual lo compara constantemente con el valor binario:

```text
3 = 2'b11
```
Cuando ambos valores son iguales, el comparador activa la señal, esta señal es enviada al controlador principal para indicar que el jugador ha alcanzado tres fallos consecutivos.

Por lo tanto, el módulo no solamente lleva el puntaje general de la partida, sino que también permite detectar una de las condiciones utilizadas para determinar su finalización.

#### g) Diseño
##Tabla de verdad de aciertos
Tabla de acierto
| Estado actual | Acierto | Siguiente estado | Acción | 
| ------------ | ------------ | ------------ | ------------ | 
| 00      | 0      | 00      | Inicio      | 
| 00      | 1      | 01      | Incremento en 1      | 
| 01      | 0      | 01      | Mantiene el valor      | 
| 01      | 1      | 10      | Incremento en 1      | 
| 10      | 0      | 10      | Mantiene el valor      | 
| 10      | 1      | 11      | Incremento en 1      | 

##Tabla de verdad de fallos

| Estado actual | Acierto | Fallo | Siguiente estado | Acción |
| ------------ | ------------ | ------------ | ------------ | ------------ |
| 00 | 0 | 0 | 00 | Inicio |
| 00 | 1 | 0 | 00 | Mantiene el valor |
| 00 | 0 | 1 | 01 | Incremento fallo en 1 |
| 01 | 1 | 0 | 00 | Reset de fallo acumulado |
| 01 | 0 | 1 | 10 | Incremento fallo en 1 |
| 10 | 1 | 0 | 00 | Reset de fallo acumulado |
| 10 | 0 | 1 | 11 | Incremento fallo en 1 |
| 11 | 0 | 1 | 11 | 3 fallos/reset |

---

### Receptor de botones

#### a) Diagrama modular

Este módulo corresponde al bloque encargado de recibir y validar las señales provenientes de los botones físicos del juego. Su función principal es evitar que cambios rápidos o rebotes mecánicos en los botones sean interpretados como pulsaciones válidas.

Cada botón dispone de una arquitectura independiente compuesta por un registro, un contador, un comparador y una compuerta AND.

![Diagrama modular del receptor de botones](../images/receptor_botones.png)

#### b) Objetivo del módulo

El objetivo del módulo es recibir las señales generadas por los botones físicos y producir una señal estable y validada que pueda ser utilizada de forma segura por los demás módulos implementados en la FPGA.

Debido al comportamiento mecánico de los pulsadores, al presionar o liberar un botón pueden producirse múltiples cambios rápidos entre los niveles lógicos `0` y `1`. Estos cambios pueden ser interpretados erróneamente por el sistema como varias pulsaciones.

Para evitar este problema, el receptor verifica que la señal del botón permanezca estable durante un período mínimo de **0,1 s** antes de considerarla válida.

#### c) Entradas

| Entrada | Descripción |
|---|---|
| `Boton_precionado` | Señal digital proveniente del botón físico. |
| `CLK` | Señal de reloj de 100 MHz de la FPGA utilizada para actualizar el registro y el contador. |
| `Rst` | Señal de reinicio utilizada para devolver el registro y el contador a su condición inicial. |

El sistema utiliza una arquitectura independiente para cada uno de los botones disponibles en el juego.

#### d) Salidas

| Salida | Descripción |
|---|---|
| `Botones` | Señal del botón después de ser almacenada, temporizada y validada. |

La salida `Botones` solamente representa una pulsación activa cuando la entrada correspondiente ha permanecido estable durante el tiempo establecido.

#### e) Relación con otros módulos

El receptor de botones funciona como una etapa intermedia entre los botones físicos del juego y los módulos digitales encargados de procesar las acciones realizadas por el jugador.

Las señales físicas provenientes de los botones ingresan al receptor mediante `Boton_precionado`. Después del proceso de validación, se genera `Botones`, que puede ser utilizada por el módulo encargado de determinar si el botón presionado corresponde con la posición del topo activo.

De esta forma, los módulos posteriores no trabajan directamente con las señales provenientes de los pulsadores, sino con señales previamente estabilizadas y validadas.

El módulo utiliza el reloj interno de **100 MHz** de la FPGA como referencia temporal para determinar cuánto tiempo ha permanecido estable una señal.

#### f) Explicación de funcionamiento

El funcionamiento comienza cuando la señal `Boton_precionado`, proveniente de un botón físico, ingresa al registro. El registro almacena el estado actual del botón y genera la señal interna `Btn_reg`.

A partir de este valor, un contador determina durante cuánto tiempo se ha mantenido estable la señal. Mientras `Btn_reg` conserve el mismo estado, el contador continúa incrementando su valor.

Si se detecta un cambio en el estado del botón antes de completar el tiempo establecido, el contador se reinicia. De esta manera, los cambios rápidos producidos por el rebote mecánico no llegan a ser considerados como una entrada válida.

Para aceptar una pulsación, el valor debe permanecer estable durante al menos **0,1 s**. El contador se conecta a un comparador encargado de determinar cuándo se ha alcanzado el número de ciclos de reloj correspondiente a dicho intervalo.

Cuando se cumple esta condición, el comparador activa la señal interna `valido`.

Finalmente, la señal `valido` se combina mediante una compuerta AND con el valor almacenado del botón:

```text
Botones = Btn_reg AND valido
```
Por lo tanto, Botones solamente se activa cuando el botón se encuentra presionado y su estado ha permanecido estable durante el período requerido.

Este procedimiento permite filtrar los rebotes producidos por los botones físicos y entregar al resto del sistema una señal estable para el procesamiento de las acciones del jugador.

#### g) Diseño









