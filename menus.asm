# menus
		#main menu
.macro main_menu (%fn_print,%fn_read,%stop) # Guarda la eleccion del modo de juego en $v0

	loop_1:
	%fn_print (welcome)
	%fn_print (mode_selection)
	%fn_print (mode_1)
	%fn_print (mode_2)
	%fn_print (next_line)
	%fn_print (ask_mode)
	%fn_read ()

	beq $v0 48 exit 		# Es cero
	beq $v0 49 end_loop_1	# Es uno
	beq $v0 50 end_loop_1	# Es dos

	j next_attempt
	# Salir
	exit:
	%stop ()
	next_attempt:
	j loop_1

	end_loop_1:
.end_macro

# initiator
.macro initiator ()
	move AUX $v0
	#Leo el valor que esta en $v0 para iniciar el juego
	# Si es 1 es PvP
	beq $v0 49 pvp
	
	pvp:
	#El primer jugador arma su tablero
	print_message (next_line)
	print_message (initialize_board_p1)
	print_ocean(display_board)
	place_boat (display_board, 5 ,location_ac1) #Colocamos cada barco y guardamos su posicion
	place_boat (display_board, 4 ,location_dn1) 
	place_boat (display_board, 3 ,location_sm1) 	
	place_boat (display_board, 2 ,location_fgt1)
	save_board (display_board, board_p1) #Guardar tablero en otro espacio de memoria

	#El segundo jugador arma su tablero
	print_message (next_line)
	print_message (initialize_board_p2)
	print_ocean(display_board)
	place_boat (display_board, 5 ,location_ac2)
	place_boat (display_board, 4 ,location_dn2) 
	place_boat (display_board, 3 ,location_sm2) 	
	place_boat (display_board, 2 ,location_fgt2)
	save_board (display_board, board_p2) 

	# Si es 2 es PvCPU
		#Logica PvCPU
	
	j end_initiator

	pvcpu:
		#Colocar PvCPU

	end_initiator:
.end_macro

.macro player_turn (%player_in_turn_board, %oponent_board, %location_ac, %location_dn, %location_sm, %location_fgt)
	#Cargo el tablero del jugador en turno
	load_board (%player_in_turn_board,display_board) # Carga el valor del tablero del jugador al display
	# En $s1 guardaré la condición de turno. Si el jugador acierta se mantiene en 1, si falla se iguala a 0
	li $s1 1 #Condicion de tiro
	loop_shot:
		# Muevo el cursor
		move_cursor (display_board)
		evaluate_fire (%oponent_board)

		#Evaluo si tiene otro acierto
		beqz $s1 end_loop_shot
		
		# Verifica si un barco ha sido hundido
	        check_all_ships_sunk(%location_ac, %location_dn, %location_sm, %location_fgt)
		
		j loop_shot
	end_loop_shot:
	
	#Verifico hundimiento
	
	#Guardo el tablero al finalizar el turno	
	save_board (display_board, %player_in_turn_board)
	
.end_macro
