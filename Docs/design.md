# Diseño de Juego Whack-a-Mole (FPGA / Lógica Discreta)

## Primer Nivel: Descripción General del Sistema

En este primer nivel describe la función básica del circuito como juego de Whack-a-mole, partiendo de un circuito que tiene como entradas 8 botones los cuales controlan el desarrollo de la partida y una señal de reset general y mediante un circuito discreto encargado de generar la posición de los topos en la salida se estaría reflejando dos señales principales, una para un arreglo de LED´s (ON=topo activo) y un display de 7 segmentos para poder visualizar tanto los aciertos acumulados a lo largo de la partida como los fallos seguidos

![Diagrama de Bloques de Primer Nivel](diagrama_primer_nivel.png)

---

## Segundo Nivel: Arquitectura de Subsistemas

Para el diagrama de segundo nivel se manejan dos señales de CLK independientes, uno para el circuito discreto generado con un 555 que tiene como función principal controlar e indicar cuando se activa un botón(los cuales están asignados al “topo activo dados por los LEDs”) y otro CLK para la FPGA establecido en 100MHz, el cual controla e brinda las señales de activación de los LEDs(“topos”)

![Diagrama de Bloques de Segundo Nivel](diagrama_segundo_nivel.png)

