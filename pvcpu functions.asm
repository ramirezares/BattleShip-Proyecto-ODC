
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
		beq $s4 26 enter
		li $a1, 23	# Límite superior  rango(0-21)
		li $v0, 42        # Syscall 42: Generar número aleatorio
		syscall
		
		move $v0, $a0     # Guarda el número aleatorio en $v0
		addi $v0, $v0, 97
		#v0 van a ser número entre 97 y 119
		
		
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
		move_cursor_random(board_p2)
		evaluate_fire (%oponent_board, %score,%location_ac, %location_dn, %location_sm, %location_fgt)

		# Verifica hundidos
	        check_all_ships_sunk(%location_ac, %location_dn, %location_sm, %location_fgt,%score)
	        
	        #Evaluo si tiene otro acierto
		beqz $s1 end_loop_shot
		
		j loop_shot
	end_loop_shot:
	
.end_macro


.macro move_cursor_random (%player_table)
    li $t0 0		# Inicializa la posición del cursor en el inicio del tablero
    li $t1 0		# Inicializa el iterador para el movimiento
    li $s4 0 	#inicializa iterador de cantidad de movimientos
    
    loop_move:
	lw $t2 board_p2($t0)  #Color actual del cursor. Tomo el color que esta en la casilla    	
        li $t3 YELLOW
        place_cursor(board_p2, $t3, $t0)  # Pinta el cursor en la posición actual
        print_message(ask_fire)  # Muestra el mensaje para elegir la posicion para disparar moviendo el cursor
        
        beq $s4 50  select_position
		li $a1, 23	# Límite superior  rango(0-21)
		li $v0, 42        # Syscall 42: Generar número aleatorio
		syscall
		
	move $v0, $a0     # Guarda el número aleatorio en $v0
	addi $v0, $v0,97
	#v0 van a ser número entre 97 y 119
	
        # Mover el cursor según la entrada
        beq $v0, 97, move_left    # 'A' para mover a la izquierda
        beq $v0, 100, move_right   # 'D' para mover a la derecha
        beq $v0, 119, move_up      # 'W' para mover hacia arriba
        beq $v0, 115, move_down    # 'S' para mover hacia abajo
        j continue_move            # Continúa el bucle

	enter:
	
	move_left:
		move $t3 $t2	
		place_cursor(display_board, $t3, $t0) #Pinto el cuadro del color que estaba
	
		move AUX $t0		#Guardo la posicion para validar
	        validate_border (0)
        	addi $t0 $t0 -4 		# Avanzo con el cursor hacia la izquierda
	        blt $t0 $v0 left_exceded        
        	j continue_move
        
        left_exceded:
	        move $t0 AUX
        	j continue_move
        
	move_right:
		move $t3 $t2	
		place_cursor(display_board, $t3, $t0) #Pinto el cuadro del color que estaba
	
		move AUX $t0	#Guardo la posicion para validar
		validate_border (1)
	        addi $t0 $t0 4           # Avanzo con el cursor a la derecha
        	bgt $t0 $v0 right_exceded
	        j continue_move
        
        right_exceded:
        	move $t0 AUX
	        j continue_move
        
	move_up:    	
		move $t3 $t2	
		place_cursor(display_board, $t3, $t0) #Pinto el cuadro del color que estaba
		
		move AUX $t0	#Guardo la posicion para validar
		addi $t0, $t0, -64         # Mueve el cursor hacia arriba
		blt $t0 0 up_exceded 
		j continue_move
		
	up_exceded:
		move $t0 AUX
	        j continue_move

	move_down:
		move $t3 $t2	
		place_cursor(display_board, $t3, $t0) #Pinto el cuadro del color que estaba
		
		move AUX $t0		#Guardo la posicion para validar
	        addi $t0, $t0, 64          # Avanzo con el cursor hacia abajo
	        bgt $t0 1020 down_exceded
        	j continue_move

	down_exceded:
		move $t0 AUX
	        j continue_move

    select_position:    
    	move $t3 $t2	
	place_cursor(display_board, $t3, $t0) #Pinto el cuadro del color que estaba	
	
    	bne $t2 blue not_valid_fire

        move $v0, $t0              # Guarda la posición seleccionada en $v0 si la posicion es valida para disparo
        j end_move_cursor           # Salir del bucle
        
        not_valid_fire:
        print_message(invalid_fire)
        print_message(next_line)

    continue_move:
    	addi $s4 $s4 1
        j loop_move
    end_move_cursor:
.end_macro
