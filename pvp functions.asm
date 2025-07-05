.macro place_cursor (%player_table, %cursor_color, %position)
    #   %player_table = tablero del jugador
    #   %cursor_color: color del cursor
    #   %position: posición actual del cursor
    
	sw %cursor_color %player_table($t0)  # Pinta el cursor en la posición actual
.end_macro

.macro validate_border (%direction)
    # $t0 tiene la posición 
    # En $v0 queda el límite 
    # %direction es 0 si el limite a buscar es izquierdo y es 1 si el limite a calcular es derecho

    # Determinamos fila actual (0-15)
    li $t2 64   # Tamaño para moverme entre filas
    #sub $t3 $t0 1024
                # Resto 1024
    srl  $t3 $t0 6   # $t3 = (posición - 1024) / 6 (fila)

    # Límite izquierdo
    li $t4 %direction
    beqz $t4 left_limit     # Si es límite izquierdo, calcularlo

    # Límite derecho
    li $t4 0
    addi $t4 $t3 1               # $t4 = fila + 1
    mul  $t4 $t4 $t2             # $t4 = (fila + 1) * 64
    sub $v0 $t4 4
    j    end_macro_border_exceded  # Salta al final

left_limit:
    # Límite izquierdo = fila * 64
    mul  $t4 $t3 $t2             # $t4 = fila * 64
    move $v0 $t4
	
end_macro_border_exceded:
.end_macro

.macro move_cursor (%player_table)
    li $t0 0		# Inicializa la posición del cursor en el inicio del tablero
    li $t1 0		# Inicializa el iterador para el movimiento
    
    loop_move:
	lw $t2 display_board($t0)  #Color actual del cursor. Tomo el color que esta en la casilla    	
        li $t3 YELLOW
        place_cursor(display_board, $t3, $t0)  # Pinta el cursor en la posición actual
        print_message(ask_fire)  # Muestra el mensaje para elegir la posicion para disparar moviendo el cursor
        read_character()          # Lee la entrada del usuario

        # Mover el cursor según la entrada
        beq $v0, 97, move_left    # 'A' para mover a la izquierda
        beq $v0, 100, move_right   # 'D' para mover a la derecha
        beq $v0, 119, move_up      # 'W' para mover hacia arriba
        beq $v0, 115, move_down    # 'S' para mover hacia abajo
        beq $v0, 10, select_position # Enter para seleccionar la posición
        j continue_move            # Continúa el bucle

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
        j loop_move
    end_move_cursor:
.end_macro

.macro evaluate_fire (%oponent_board)
	# En $v0 esta la posicion del disparo resultado del proceso de mover cursor
	# En $t0 guardaré esa posicion y en $t1 la trasladada
	move $t0 $v0
	addi $t1 $v0 1024 
	
	 lw $t2 %oponent_board($t1)	 #Cargo el valor de color de la posicion indicada trasladada a la parte de abajo del tablero del oponente
	
	# Si en el tablero del oponente en la parte de abajo en la posicion indicada hay un barco (color gris)
	# se debe marcar en rojo el tablero de tiro del jugador y el tablero de los barcos del oponente
	 beq $t2 GRAY successful_shot
		
	# Si no se debe marcar en blanco (Buscar color distinto) el tablero de tiro y en COLOR el tablero del oponente
	# Marco en el tablero del jugador el fallo
	print_message(message_fail_shot) #Informo de fallo
	li $t2 WHITE
	sw $t2 display_board($t0)
	# Marco en el tablero del oponente el fallo
	li $t2 WHITE
	sw $t2 %oponent_board($t1)	
	
	# Como falló se acaba su turno
	li $s1 0 #Condicion de tiro
	j finished_shot
		
	successful_shot:
	print_message(message_successful_shot) #Informo de acierto
	#Marco en el tablero del jugador el acierto
	li $t2 RED
	sw $t2 display_board($t0)
	#Marco en el tablero del oponente el acierto
	li $t2 RED
	sw $t2 %oponent_board($t1)	
	
	finished_shot:
.end_macro
