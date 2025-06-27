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
%fn_print (achieved)	#Exit
.end_macro


# initiator
.macro initiator (%fn_print)

#Leo el valor que esta en $v0 para iniciar el juego

# Si es 1 es PvP
beq $v0 49 pvp

# Si es 2 es PvCPU
	#Logica PvCPU

pvp:


.end_macro