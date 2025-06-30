
####### Imports de archivos  #########
.include "helpers.asm"
.include "game functions.asm"
.include "menus.asm"

###### Etiquetas ###############
.data

#Tablero Jugador 1 
p1: .space 2048

# Espacios de los barcos     <---------FALTAN EL RESTO DE LOS BARCOS
location_ac: .space 4# Acorazado

#Menu principal
welcome: .asciiz "\n			~~~~ Bienvenido a BattleShip ~~~~"
mode_selection: .asciiz "\nIngrese el número del modo de juego que desea: "
mode_1: .asciiz "\n	1. Jugador 1 vs Jugador 2."
mode_2: .asciiz "\n	2. Jugador 1 vs CPU."
ask_mode: .asciiz "\nIngrese el número del modo de juego o 0 para salir: "  #<-----------REVISAR HAY UNO REPETIDO
next_line:.asciiz "\n"

ask_move: .asciiz "\nElija la ubicacion:\nA->Mover a la izquierda.\nD->Mover a la derecha.\nW->Mover hacia arriba.\nS->Mover hacia abajo.\n"
achieved:.asciiz "\n Llegue" #<---------DEBUG MESSAGE

.eqv BLUE 0x0000FF
.eqv GRAY 0x808080
.eqv RED 0xFF0000
.eqv WHITE 0xFFFFFF
.eqv YELLOW 0xFFFF00

.eqv AUX $t9
.text

# Muestro el menu
#	main_menu (print_message, read_character,stop_program) # Nos da la eleccion del jugador

# Inicia el modo de juego elegido
#initiator ()

# Pintamos azul ambos tableros ( TODO: COLOCAR P2, RESERVAR MEMORIA ARRIBA )
print_ocean(p1)
place_boat (5)
place_boat (8)

	#Iterar por barco
	#Colocar barco en la esquina superior si no hay nada
print_message (achieved)
