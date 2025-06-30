.include "helpers.asm"
.include "game functions.asm"
.include "menus.asm"
.data
# 			Proyecto Organización del computador.
#Integrantes: 
# 	Mendez Diego
#	Ares Ramirez
#	Zambrano Daniela
p1: .space 2048

# Espacios de los barcos
location_ac: .space 4# Aircraft carrier Portaaviones 

#Menu principal
welcome: .asciiz "\n			Bienvenido a Batalla Naval  BattleShip"
mode_selection: .asciiz "\nSeleccione el modo de juego indicando el numero:"
mode_1: .asciiz "\n	1. Jugador vs Jugador PvP."
mode_2: .asciiz "\n	2. Jugador vs CPU PvCPU."
ask_mode: .asciiz "\nIngrese el numero del modo de juego o 0 para salir: "
next_line:.asciiz "\n"

ask_move: .asciiz "\nElija la ubicacion:\nA->Mover a la izquierda.\nD->Mover a la derecha.\nW->Mover hacia arriba.\nS->Mover hacia abajo.\n"
achieved:.asciiz "\n Llegue"

.eqv BLUE 0x0000FF
.eqv GRAY 0x808080
.eqv RED 0xFF0000
.eqv WHITE 0xFFFFFF
.eqv YELLOW 0xFFFF00

.eqv AUX $t9
.text
# Muestro el menu
#	main_menu (print_message, read_caracter,stop_program) # Nos da la eleccion del jugador

# Inicia el modo de juego elegido
#initiator ()

# Pintamos azul ambos tableros ( TODO: COLOCAR P2, RESERVAR MEMORIA ARRIBA )
print_ocean(p1)

place_boat (5)
place_boat (8)
	#Iterar por barco
	#Colocar barco en la esquina superior si no hay nada
print_message (achieved)
