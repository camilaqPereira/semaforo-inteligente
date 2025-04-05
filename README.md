# Semáforo inteligente implementado no microcontrolador 8051

<p align="center">Semáforo inteligente com modo de emergência e contávem de veículos para extenção do tempo do sinal verde</p>

> [!note]
> Simulação realizada no MCU 8051


## 🛠️ Periféricos usados
- 2 displays de 7 segmentos
- 2 pushbuttons
- 3 leds: vermelho, verde e amarelo

## ✨ Features
- **Ciclo normal:** vermelho (7 segundos), verde (10 segundos), amarelo (3 segundos)
- **Modo de emergência:** desvia o fluxo normal para o sinal vermelho e extende o tempo do mesmo para 15 segundos
- **Contagem de veículos:** conta o número de veículos que passam durante o sinal verde. Caso mais de 5 veículos passem, extende o tempo do
sinal verde para 15 segundos. Contagem foi implementada por meio de pushbutton

## ▶️ Demostração da simulação
> [Projeto em execução | Youtube](https://youtu.be/O6GmhtaJViY)

