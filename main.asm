
####### Imports de archivos  #########

.include "helpers.asm"
.include "start functions.asm"
.include "pvp functions.asm"
.include "pvcpu functions.asm"
.include "menus.asm"

.data
###### Etiquetas ###############
#Tablero Jugador 1 
display_board: .space 2048 #Tablero que se muestra en el Bitmap Display
board_p1: .space 2048
board_p2: .space 2048
# Espacios de los barcos     

#Player 1
location_ac1: .space 20	# Aircraft Carrier =Portaaviones = ac. Tamaño: 5
location_dn1: .space 16	# Dreadnought = Acorazado = dn. Tamaño: 4 
location_sm1: .space 12  # Submarine = Submarino = sm. Tamaño: 3
location_fgt1: .space 8  # Frigate = Fragata = fgt.  Tamaño: 2

#Player 2
location_ac2: .space 20	# Portaaviones = Aircraft Carrier = ac.  Tamaño: 5
location_dn2: .space 16	# Acorazado = Dreadnought  = dn. Tamaño: 4 
location_sm2: .space 12 # Submarino = Submarine = sm. Tamaño: 3
location_fgt2: .space 8  # Fragata = Frigate = fgt.  Tamaño: 2

#Menu principal
welcome: .asciiz "\n			~~~~ Bienvenido a BattleShip ~~~~"
mode_selection: .asciiz "\nIngrese el número del modo de juego que desea: "
mode_1: .asciiz "\n	1. Jugador 1 vs Jugador 2."
mode_2: .asciiz "\n	2. Jugador 1 vs CPU."
ask_mode: .asciiz "\nIngrese el número del modo de juego o 0 para salir: " 
next_line:.asciiz "\n"
initialize_board_p1: .asciiz "\n	Jugador 1. Ubique cada uno de sus barcos:"
initialize_board_p2: .asciiz "\n	Jugador 2. Ubique cada uno de sus barcos:"
initialize_board_cpu: .asciiz "\n	La CPU esta ubicando sus barcos."
ask_move: .asciiz "\nElija la ubicacion:\nA->Mover a la izquierda.\nD->Mover a la derecha.\nW->Mover hacia arriba.\nS->Mover hacia abajo.\n\nCon R puede rotar el barco y con enter acepta la posición.\n"
ask_fire: .asciiz "\nElija la ubicacion donde desea disparar:\nA->Mover a la izquierda.\nD->Mover a la derecha.\nW->Mover hacia arriba.\nS->Mover hacia abajo.\n\nCon enter acepta la posición de disparo.\n"
invalid_fire: .asciiz "Disparo invalido. Seleccione una ubicacion a la que no haya disparado antes"
message_successful_shot: .asciiz "\n¡Disparo exitoso!\n"
message_fail_shot: .asciiz "\n¡Disparo fallido! \n"
message_turn_p1: .asciiz "\nTurno del jugador 1\n"
message_turn_p2: .asciiz "\nTurno del jugador 2\n"
message_turn_CPU: .asciiz "\nTurno de la CPU\n"

aircraft_carrier_name: .asciiz "\nPortaaviones"
dreadnought_name: .asciiz "\nAcorazado"
submarine_name: .asciiz "\nSubmarino"
frigate_name: .asciiz "\nFragata"

sunk_message: .asciiz "Ha hundido: "
victory_message: .asciiz "\n¡Todos los barcos han sido hundidos! ¡Ha ganado!\n"
punctuation_p1_message: .asciiz "\nPuntuacion jugador 1:"
punctuation_p2_message: .asciiz "\nPuntuacion jugador 2:"
achieved:.asciiz "\n Llegue" #<---------DEBUG MESSAGE
 
.eqv BLUE 0x0e2ea8
.eqv blue 0x87CEFA
.eqv GRAY 0x6e8198
.eqv RED 0xc0162b
.eqv WHITE 0xFFFFFF
.eqv YELLOW 0xFFFF00

.eqv AUX $t8
.eqv AUX2 $t9
.eqv score_p1 $s5
.eqv score_p2 $s6
.text

# Muestro el menu
main_menu (print_message, read_character,stop_program) # Nos da la eleccion del jugador en $v0

# Preparo el modo de juego elegido
initiator () 	# Arma los tableros colocando los barcos y guarda sus posiciones y cada tablero en board_p1 y board_p2
#Inicio el modo de juego
game()
