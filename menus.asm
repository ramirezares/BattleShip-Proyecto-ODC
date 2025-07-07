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
	move $s7 $v0
	#Leo el valor que esta en $v0 para iniciar el juego
	# Si es 1 es PvP
	beq $v0 49 pvp #49 es el equivalente al número 1 en ASCII
	beq $v0 50 pvcpu #50 es el equivalente al número 2 en ASCII
	
	
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
	
	j end_initiator


	# Si es 2 es PvCPU
	pvcpu:
		#El primer jugador arma su tablero
		print_message (next_line) #\n
		print_message (initialize_board_p1)
		print_ocean(display_board)
		place_boat (display_board, 5 ,location_ac1) #Colocamos cada barco y guardamos su posicion
		place_boat (display_board, 4 ,location_dn1) 
		place_boat (display_board, 3 ,location_sm1) 	
		place_boat (display_board, 2 ,location_fgt1)
		
		#REVISAR EN DONDE SE HACE EL CAMBIO DEL BOARD2 PARA SOLO DEJAR EL DISPLAYBOARD
		#save_board (display_board, board_p1) Guardar tablero en otro espacio de memoria

		#El CPU  arma su tablero
		print_message (next_line)#\n
		print_message (initialize_board_cpu)
		print_ocean(board_p2)
		
		#Colocamos cada barco y guardamos su posicion
		CPU_place_boat (board_p2, 5 ,location_ac2)
		CPU_place_boat (board_p2, 4 ,location_dn2) 
		CPU_place_boat (board_p2, 3 ,location_sm2) 	
		CPU_place_boat (board_p2, 2 ,location_fgt2)
		
	j end_initiator

	end_initiator:
.end_macro

.macro player_turn (%player_in_turn_board, %oponent_board, %location_ac, %location_dn, %location_sm, %location_fgt, %score)
	#Cargo el tablero del jugador en turno
	load_board (%player_in_turn_board,display_board) # Carga el valor del tablero del jugador al display
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
	
	#Guardo el tablero al finalizar el turno	
	save_board (display_board, %player_in_turn_board)
	
.end_macro

.macro game ()
	beq $s7 49 pvp
	beq $s7 50 pvcpu
	
	pvp:
	pvp_game ()
	
	pvcpu:
	pvcpu_game ()

.end_macro



.macro pvp_game ()

	li score_p1 0
	li score_p2 0

	loop_pvp:
	#Turno del jugador 1
	print_message(message_turn_p1) 
	player_turn (board_p1,board_p2,location_ac2, location_dn2, location_sm2, location_fgt2,score_p1)

	#Turno del jugador 2
	print_message(message_turn_p2)
	player_turn (board_p2,board_p1,location_ac1, location_dn1, location_sm1, location_fgt1,score_p2)
	j loop_pvp

.end_macro



.macro pvcpu_game ()

	li score_p1 0
	li score_p2 0

	loop_pvp:
	#Turno del jugador 1
	print_message(message_turn_p1) 
	player_turn (display_board,board_p2,location_ac2, location_dn2, location_sm2, location_fgt2,score_p1)

	#Turno del CPU
	print_message(message_turn_p2)
	player_turn (board_p2,display_board,location_ac1, location_dn1, location_sm1, location_fgt1,score_p2)
	
	j loop_pvp

.end_macro

