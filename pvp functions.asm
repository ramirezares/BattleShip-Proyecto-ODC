.macro place_cursor (%player_table, %cursor_color, %position)
    #   %player_table = tablero del jugador
    #   %cursor_color: color del cursor
    #   %position: posición actual del cursor
    
	sw %cursor_color %player_table($t0)  # Pinta el cursor en la posición actual
.end_macro

.macro validate_border (%direction)
    # $t0 tiene la posición 
    # En $v0 queda el límite 

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
    li $t0 0               # Inicializa la posición del cursor en el inicio del tablero
    li $t1 0                   # Inicializa el iterador para el movimiento

    loop_move:
        li $t2 YELLOW
        place_cursor(%player_table, $t2, $t0)  # Pinta el cursor en la posición actual
        print_message(ask_move)  # Muestra el mensaje para mover el cursor
        read_character()          # Lee la entrada del usuario

        # Mover el cursor según la entrada
        beq $v0, 97, move_left    # 'A' para mover a la izquierda
        beq $v0, 100, move_right   # 'D' para mover a la derecha
        beq $v0, 119, move_up      # 'W' para mover hacia arriba
        beq $v0, 115, move_down    # 'S' para mover hacia abajo
        beq $v0, 10, select_position # Enter para seleccionar la posición

        j continue_move            # Continúa el bucle

    move_left:
	li $t2 blue	
	place_cursor(%player_table, $t2, $t0)
	move AUX $t0
        validate_border (0)
        addi $t0 $t0 -4 
        
        blt $t0 $v0 right_exceded        
        j continue_move
        
        right_exceded:
        move $t0 AUX
        j continue_move
        

    move_right:
	li $t2 blue	
	place_cursor(%player_table, $t2, $t0)
	move AUX $t0
	validate_border (1)
        addi $t0 $t0 4           # Mueve el cursor a la derecha
        bgt $t0 $v0 left_exceded
        j continue_move
        
        left_exceded:
        move $t0 AUX
        j continue_move
        
    move_up:
    
    	# VALIDAR
    	
    	li $t2 blue	
	place_cursor(%player_table, $t2, $t0)
        addi $t0, $t0, -64         # Mueve el cursor hacia arriba
        j continue_move

    move_down:
    
    	# VALIDAR
    
    	li $t2 blue	
	place_cursor(%player_table, $t2, $t0)
        addi $t0, $t0, 64          # Mueve el cursor hacia abajo
        j continue_move

    select_position:
        move $v0, $t0              # Guarda la posición seleccionada en $v0
        j end_move_cursor           # Salir del bucle

    continue_move:
        # Hacer
        j loop_move
    end_move_cursor:
.end_macro
