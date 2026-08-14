# Sistema de Juego Whack-a-Mole (FPGA / Lógica Discreta)

## Primer Nivel: Descripción General del Sistema

El sistema recibe las acciones del jugador mediante botones, controla el desarrollo de la partida, se comunica con un circuito discreto encargado de generar la posición del topo y presenta al usuario el estado del juego mediante los dispositivos de visualización.

![Diagrama de Bloques de Primer Nivel](diagrama_primer_nivel.png)

### Descripción Funcional

En este primer nivel se describe la función básica del circuito como juego de **Whack-a-mole**, partiendo de un circuito que cuenta con:

* **Entradas:**
  * **8 Botones:** Controlan el desarrollo de la partida.
  * **Reset:** Señal de reset general del sistema.

* **Salidas y Dispositivos de Visualización:**
  * **Arreglo de LEDs:** Indican el topo activo (`ON` = topo activo).
  * **Display de 7 Segmentos:** Permite visualizar tanto los aciertos acumulados a lo largo de la partida como los fallos seguidos.

---

## Segundo Nivel: Arquitectura de Subsistemas

Para el diagrama de segundo nivel se manejan dos señales de reloj (**CLK**) independientes:
1. **CLK1 (Circuito Discreto):** Generado con un temporizador **555**, cuya función principal es controlar e indicar cuándo se activa un botón.
2. **CLK2 (FPGA):** Establecido a **100 MHz**, el cual controla y brinda las señales de activación.

![Diagrama de Bloques de Segundo Nivel](diagrama_segundo_nivel.png)

### Descripción de Subsistemas

#### 1. Subsistema Circuito Discreto
Genera una posición pseudoaleatoria para el topo, activa el LED correspondiente y transmite dicha posición hacia la FPGA mediante comunicación serial UART.

#### 2. Subsistema FPGA
Implementa la lógica del juego, recibe la posición del topo enviada por el circuito discreto, procesa las acciones del jugador y controla la información mostrada en el display de siete segmentos.
