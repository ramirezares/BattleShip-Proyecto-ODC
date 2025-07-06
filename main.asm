
####### Imports de archivos  #########

.include "helpers.asm"
.include "start functions.asm"
.include "pvp functions.asm"
.include "menus.asm"

.data
###### Etiquetas ###############
#Tablero Jugador 1 
display_board: .space 2048 #Tablero que se muestra en el Bitmap Display
board_p1: .space 2048
board_p2: .space 2048
# Espacios de los barcos     

#Player 1
location_ac1: .space 20	# Portaaviones = Aircraft Carrier = ac. Tamaño: 5
location_dn1: .space 16	# dreadnought = Acorazado = dn. Tamaño: 4 
location_sm1: .space 12  # Submarine = Submarino = sm. Tamaño: 3
location_fgt1: .space 8  # Frigate = fragata = fgt.  Tamaño: 2

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
ask_move: .asciiz "\nElija la ubicacion:\nA->Mover a la izquierda.\nD->Mover a la derecha.\nW->Mover hacia arriba.\nS->Mover hacia abajo.\n\nCon R puede rotar el barco y con enter acepta la posición.\n"
ask_fire: .asciiz "\nElija la ubicacion donde desea disparar:\nA->Mover a la izquierda.\nD->Mover a la derecha.\nW->Mover hacia arriba.\nS->Mover hacia abajo.\n\nCon enter acepta la posición de disparo.\n"
invalid_fire: .asciiz "Disparo invalido. Seleccione una ubicacion a la que no haya disparado antes"
message_successful_shot: .asciiz "\n¡Disparo exitoso!\n"
message_fail_shot: .asciiz "\nDisparo fallido D: \n"
message_turn_p1: .asciiz "\nTurno del jugador 1\n"
message_turn_p2: .asciiz "\nTurno del jugador 2\n"

aircraft_carrier_name: .asciiz "\nPortaaviones\n"
dreadnought_name: .asciiz "\nAcorazado\n"
submarine_name: .asciiz "\nSubmarino\n"
frigate_name: .asciiz "\nFragata\n"

sunk_message: .asciiz "¡El barco ha sido hundido: "
victory_message: .asciiz "¡Todos los barcos han sido hundidos! ¡Ha ganado!"

achieved:.asciiz "\n Llegue" #<---------DEBUG MESSAGE
 
.eqv BLUE 0x0000FF
.eqv blue 0x87CEFA
.eqv GRAY 0x808080
.eqv RED 0xFF0000
.eqv WHITE 0xFFFFFF
.eqv YELLOW 0xFFFF00

.eqv AUX $t8
.eqv AUX2 $t9
.text

# Muestro el menu
main_menu (print_message, read_character,stop_program) # Nos da la eleccion del jugador en $v0

# Preparo el modo de juego elegido
initiator () 	# Arma los tableros colocando los barcos y guarda sus posiciones y cada tablero en board_p1 y board_p2
#Inicio el modo de juego
#game ()	MACRO 	#Inician los turnos

#Turno del jugador 1
print_message(message_turn_p1) 
player_turn (board_p1,board_p2,location_ac2, location_dn2, location_sm2, location_fgt2)

#Turno del jugador 2

print_message(message_turn_p2)
player_turn (board_p2,board_p1,location_ac1, location_dn1, location_sm1, location_fgt1)
