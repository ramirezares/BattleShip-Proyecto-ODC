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
	
	# Llamar a la macro para colocar el 0 en la posición acertada
	mark_ship_hit(location_ac2, 5)  # Portaaviones
	mark_ship_hit(location_dn2, 4)  # Acorazado
	mark_ship_hit(location_sm2, 3)  # Submarino
	mark_ship_hit(location_fgt2, 2)  # Fragata
	
	finished_shot:
.end_macro

# Marca con 0 el espacio acertado si lo consigue en el registro del barco
.macro mark_ship_hit (%ship_memory, %ship_length)
	# %ship_memory: dirección de memoria del barco
	# %ship_length: longitud del barco
	# %hit_position: posición que fue acertada

	# En $t0 esta la posición a comparar
	li $t1 1 # Iterador
	li $t2 0 # Puntero

	check_hit:
		#Condicion de parada
		beq $t1, %ship_length, end_mark_ship_hit # Si hemos revisado todas las posiciones, salir
		
		lw $t3, %ship_memory($t2)      # Carga la posición del barco
		beq $t3, $t0, hit_found # Si la posición coincide, se ha acertado

		addi $t1, $t1, 1                # Sigo iterando
		addi $t2, $t2, 4                # Avanza al siguiente espacio
		j check_hit                     # Repite el bucle

	hit_found:
		sw $zero, %ship_memory($t1)     # Coloca un cero en la posición del barco

	end_mark_ship_hit:
.end_macro

.macro check_ship_sunk (%ship_memory, %ship_length, %ship_name)
	# ship_memory: espacio de memoria donde se guardan las posiciones del barco
	# %ship_length: longitud del barco
	# %ship_name: nombre del barco para imprimir en el mensaje

	li $t3 0	# Contador de iteraciones
	li $t4 0	# Contador de 0
	li $t5 0     # Puntero

	loop_check:
		#Condicion de parada
		beq $t3, %ship_length, end_check_ship_sunk # Si hemos revisado todas las posiciones, salir

		lw $t6, %ship_memory($t5)      # Carga la posición del barco
		beqz $t6, increment_hitted      # Si la posición es 0, cuenta como hundido
		j continue_check                # Si no, continúa

		increment_hitted:
		addi $t4 $t4 1                # Incrementa el contador de posiciones en 0

		continue_check:
		addi $t3 $t3 1
    		addi $t5, $t5, 4                # Avanza al siguiente espacio de memoria
	    	j loop_check                    # Repite el bucle

	end_check_ship_sunk:
		beq $t4, %ship_length, ship_sunk # Si todas las posiciones están hundidas, el barco está hundido
		j end_check_ship_sunk_done

		ship_sunk:
		
		# COLOCAR MENSAJE DE HUNDIDO
		
		print_message (%ship_name)     # Imprime el nombre del barco
    
end_check_ship_sunk_done:
.end_macro

.macro check_all_ships_sunk (%location_ac, %location_dn, %location_sm, %location_fgt)
	# %location_ac: dirección de memoria del Portaaviones
	# %location_dn: dirección de memoria del Acorazado
	# %location_sm: dirección de memoria del Submarino
	# location_fgt: dirección de memoria de la Fragata

	# Verifica si cada barco ha sido hundido
	li $t0 0  #contador

	# Verifica el Portaaviones
	li $t1, 5                      # Longitud del Portaaviones
	check_ship_sunk(%location_ac, $t1, aircraft_carrier_name)
	beqz $v0, increment_hitted_ac   # Si no está hundido, incrementa el contador
	j continue_check

	increment_hitted_ac:
    	addi $t0, $t0, 1                # Incrementa el contador de barcos hundidos

	continue_check:
	# Verifica el Acorazado
	li $t1, 4                      # Longitud del Acorazado
	check_ship_sunk(%location_dn, $t1, dreadnought_name)
	beqz $v0, increment_hitted_dn   # Si no está hundido, incrementa el contador
	j continue_check_dn

	increment_hitted_dn:
	addi $t0, $t0, 1                # Incrementa el contador de barcos hundidos

	continue_check_dn:	# Verifica el Submarino
	li $t1, 3                      # Longitud del Submarino
	check_ship_sunk(%location_sm, $t1, submarine_name)
	beqz $v0, increment_hitted_sm    # Si no está hundido, incrementa el contador
	j continue_check_sm

	increment_hitted_sm:
	addi $t0, $t0, 1                # Incrementa el contador de barcos hundidos

	continue_check_sm:	
	# Verifica la Fragata
	li $t1, 2                      # Longitud de la Fragata
	check_ship_sunk(%location_fgt, $t1, frigate_name)
	beqz $v0, increment_hitted_fgt   # Si no está hundido, incrementa el contador
	j end_check_all_ships_sunk

	increment_hitted_fgt:
	addi $t0, $t0, 1                # Incrementa el contador de barcos hundidos

	end_check_all_ships_sunk:
	# Si todos los barcos están hundidos, termina el juego
    	li $t1, 4                      # Total de barcos
    	beq $t0, $t1, all_ships_sunk   # Si el contador de hundidos es igual al total de barcos

	j end_check_all_ships_sunk_done # Si no, termina la verificación

	all_ships_sunk:    # Imprime el mensaje de victoria
    	print_message(victory_message)

end_check_all_ships_sunk_done:
.end_macro
