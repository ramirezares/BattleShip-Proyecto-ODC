
# MACRO COLOCAR BARCO CPU
.macro CPU_place_boat (%board,%ship_size,%ship_memory) 
	li $s1 4  # Indica la orientación 4=Horizontal ; 64=Vertical
	li $s2 %ship_size  # Indica la longitud del barco
	  
	#Situo inicialmente el barco para verificar si la posición no esta ocupada
	li $t0 1024 #Ubicacion al principio del tablero
	li $t1 %ship_size # Contador para revisar las posiciones
	move AUX2 $t0 # Para disponibililidad
	
	
	#t0 se guarda la posición del primer cuadro del barco
	#s1 = orientación
	#s2 = longitud
	#t1 contador (tamaño otra vez)
	
	verify_availability (%board,$s1,$s2,$t1) #verifica en la memoria 
	
	li $t2 GRAY #Color gris
	#se guarda en memoria el color gris en 
	print_ship_space (%board,$t2,$s1,$s2,%ship_memory)
	
	li $s4 0
	
	loop_4:	#Bucle para mover el barco a colocar
	#CAMBIAR CANTIDAD DE MOVIMIENTOS
		beq $s4 3 enter
		
		li $a0, 97       # Límite inferior 
		li $a1, 120		# Límite superior 
		li $v0, 42        # Syscall 42: Generar número aleatorio
		syscall
		
		move $v0, $a0     # Guarda el número aleatorio en $t0
		
		beq $v0 97 left
		beq $v0 100 right
		beq $v0 119 up
		beq $v0 115 down
		beq $v0 114 rotate
		
		j continue_4
	
	enter:
	li $v0 10
	beq $v0 10 end_loop_4 
	
	
	left:		# $t0 tiene la posición actual
	li $t2 BLUE	
	print_ship_space (%board,$t2, $s1,$s2,%ship_memory)
	border_exceded (0,$s1,$s2) # Guardo el borde antes de modificar la posicion
	move AUX $t0
	addi $t0 $t0 -4
	move AUX2 $t0 
	li $t4 %ship_size

	blt $t0 1024 left_exceded #Verifica que no se salga del cuadro inferior del tablero

	verify_availability (%board,$s1,$s2,$t4) #Verifica que los espacios esten disponibles
	
	blt $t0 $v0 border_left_exceded #Verifica el limite izquierdo de la fila
	j continue_4

	border_left_exceded:
	move $t0 $v0
	j continue_4			
	
	left_exceded:
	li $t0 1024 
	j continue_4

	right:	# $t0 tiene la posición actual
	li $t2 BLUE
	print_ship_space (%board,$t2, $s1, $s2,%ship_memory)
	border_exceded (1,$s1,$s2)
	move AUX $t0
	addi $t0 $t0 4
	move AUX2 $t0
	li $t4 %ship_size
	verify_availability (%board,$s1,$s2,$t4)
	bgt $t0 2044 right_exceded #Verifica que no se salga del cuadro inferior del tablero

	bgt $t0 $v0 border_right_exceded
	j continue_4

	border_right_exceded:
	move $t0 AUX 	
	j continue_4

	right_exceded:
	li $t0 2044
	j continue_4

	up:# $t0 tiene la posición actual
	li $t2 BLUE
	print_ship_space (%board,$t2, $s1,$s2,%ship_memory)
	move AUX $t0 
	addi $t0 $t0 -64
	border_exceded (1,$s1,$s2)
	
	move AUX2 $t0	
	move $t4 $s2	
	verify_availability (%board,$s1,$s2,$t4)	#Verifico el borde
	bgt $t0 $v0 up_exceded_right
	
	blt $t0 1024 up_exceded 
	j continue_4

	up_exceded_right:
	move $t0 AUX 
	j continue_4

	up_exceded:
	move $t0 AUX 
	j continue_4

	down: 	# $t0 tiene la posición actual
	li $t2 BLUE
	print_ship_space (%board,$t2, $s1,$s2,%ship_memory)
	move AUX $t0 #Guardamos la posición
	addi $t0 $t0 64 #Avanzamos
	border_exceded (1,$s1,$s2)	#Verifico el borde

	move AUX2 $t0	
	move $t4 $s2	
	verify_availability (%board,$s1,$s2,$t4) 
	
	bgt $t0 $v0 down_exceded_right
	bgt $t0 2044 down_exceded_simple #Verificacion simple de salidar
	beq $s1 64 verify_ship_exceded_down	#Verifico si es vertical
	
	j continue_4
	
	down_exceded_right:
	move $t0 AUX 
	j continue_4

	verify_ship_exceded_down:	
	#Tamaño de la nave
	mul $t3 $s2 64	#Tamaño del barco hacia abajo en la fila
	sub $t3 $t3 64
	add $t0 $t0 $t3		# Avanzo en la fila para verificar si se sale del tablero
	bgt $t0 2044 reset	# Si es mayor a la ultima celda se salió
	sub $t0 $t0 $t3		# Si no es mayor resto el avance de la (fila 64 * n)
	#addi $t0 $t0 64		# Y avanzo una posición

	j continue_4

	reset:
	move $t0 AUX
	j continue_4

	down_exceded_simple:
	move $t0 AUX
	j continue_4

	rotate:
	li $t2 BLUE
	print_ship_space (%board,$t2,$s1,$s2,%ship_memory)
	move AUX $t0 #Guardo la posición
	beq $s1 4 to_vertical # Si es horizontal (4) cambio a vertical (64)
	beq $s1 64 to_horizontal # Si es vertical (64) cambio a horizontal (4) 
	
	to_vertical:
	li $t3 0
	mul $t3 $s2 64 #Evaluo el espacio del barco al rotar
	sub $t3 $t3 64
	add $t0 $t0 $t3		# Sumo para verificar si se sale del tablero
	bgt $t0 2044 cant_to_vertical	# Si es mayor a la ultima celda se salió
	li $s1 64 #Roto el barco
	move $t0 AUX #Restauro la posición
	cant_to_vertical:
	move $t0 AUX
	j continue_4

	to_horizontal:
	li $t4 4
	border_exceded (1,$t4,$s2)
	bgt $t0 $v0 cant_to_horizontal
	li $s1 4 #Roto el barco
	move $t0 AUX #Restauro la posición
	cant_to_horizontal:
	move $t0 AUX
	j continue_4
	
	continue_4:
	li $t2 GRAY #Color gris
	print_ship_space (%board,$t2, $s1,$s2,%ship_memory)
	addi $s4 $s4 1
	j loop_4

	end_loop_4:

.end_macro



#TURNO DE LA CPU

.macro CPU_turn (%player_in_turn_board, %oponent_board, %location_ac, %location_dn, %location_sm, %location_fgt, %score)
	
	# En $s1 guardaré la condición de turno. Si el jugador acierta se mantiene en 1, si falla se iguala a 0
	li $s1 1 #Condicion de tiro
	loop_shot:
		# Muevo el cursor
		move_cursor (display_board)
		evaluate_fire (%oponent_board, %score,%location_ac, %location_dn, %location_sm, %location_fgt)

		# Verifica hundidos
	        check_all_ships_sunk(%location_ac, %location_dn, %location_sm, %location_fgt,%score)
	        
	        #Evaluo si tiene otro acierto
		beqz $s1 end_loop_shot
		
		j loop_shot
	end_loop_shot:
	
.end_macro
