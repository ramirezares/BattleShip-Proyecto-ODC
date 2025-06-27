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

.text
# Muestro el menu
#	main_menu (print_message, read_caracter,stop_program) # Nos da la eleccion del jugador

# Inicia el modo de juego elegido
#initiator ()

# Pintamos azul ambos tableros ( TODO: COLOCAR P2, RESERVAR MEMORIA ARRIBA )
print_ocean(p1)

	# MACRO COLOCAR BARCO

#Situo inicialmente el barco verificando si la posición no esta ocupada
li $t0 1024 #Ubicacion en la mitad del tablero

li $t9 0  # Indica si finalizó el proceso de colocar
li $t8 4  # Indica la orientación
li $t7 5  # Indica la longitud del barco
	  # 4=Horizontal ; 128=Vertical

li $t2 0  # Estado de la celda donde deseo colocar el inicio del barco
	  # 1 = disponible ; 0 = ocupado
li $t3 0
loop_5: # Verificamos la colocación inicial del barco y las 5 celdas siguientes
# Condicion de parada
beq $t3 0 end_loop_5		#REVISAR ESTA FUNCIÓN CUANDO 
	#Cambiar el 0 a t7			#COLOQUEMOS VARIOS BARCOS

#li $t1 p1($t0)	ESTO DA ERROR #Tomo el color que esta en la casilla 
beq $t1 BLUE available

li $t3 0 #Si no es azul quiere decir que esta ocupada, reinicio la cuenta

available:
addi $t3 $t3 1

j loop_5 # Continuo
end_loop_5:

li $t0 1024
li $t2 GRAY #Color gris
print_ship_space (p1,$t2, $t8,$t7)

loop_4:	#Bucle para mover el barco a colocar
print_message (ask_move)
#read_move ()		# NO ME ACUERDO QUE HACIA, 
			#BUSCARLA o ver si era extraer a una macro
read_caracter ()
beq $v0 97 left
beq $v0 100 right
beq $v0 119 up
beq $v0 115 down
beq $v0 114 rotate
j continue_4

left:
li $t2 BLUE
print_ship_space (p1,$t2, $t8,$t7)
addi $t0 $t0 -4
blt $t0 1024 left_exceded #Verifica que no se salga del cuadro inferior del tablero

# MACRO de limites por fila	recibe un parametro para indicar iz o derecha
	#Verificamos la fila 
	#Verificamos el tamaño del barco
	#Guardamos en un registro el limite de la fila

#Comparación t0 con el registro que guardamos 
#Enviarlo al limite izq

j continue_4			
	
left_exceded:
li $t0 1024 
j continue_4

right:
li $t2 BLUE
print_ship_space (p1,$t2, $t8,$t7)
addi $t0 $t0 4
bgt $t0 2044 right_exceded #Verifica que no se salga del cuadro inferior del tablero

#macro de limite por fila
j continue_4

right_exceded:
li $t0 2044
j continue_4

up:
li $t2 BLUE
print_ship_space (p1,$t2, $t8,$t7)
addi $t0 $t0 -128
blt $t0 1024 up_exceded 
j continue_4

up_exceded:
li $t0 1024 
j continue_4

down:
li $t2 BLUE
print_ship_space (p1,$t2, $t8,$t7)
addi $t0 $t0 128
bgt $t0 1920 down_exceded 
j continue_4

down_exceded:
li $t0 1920 
j continue_4

rotate:
li $t2 BLUE
print_ship_space (p1,$t2, $t8,$t7)
beq $t8 4 to_vertical # Si es horizontal (4) cambio a vertical (128)
beq $t8 128 to_horizontal # Si es vertical (128) cambio a horizontal (4) 

to_vertical:
li $t8 128
j continue_4

to_horizontal:
li $t8 4

continue_4:
li $t2 GRAY #Color gris
print_ship_space (p1,$t2, $t8,$t7)
j loop_4

end_loop_4:
	#Iterar por barco
	#Colocar barco en la esquina superior si no hay nada
print_message (achieved)
