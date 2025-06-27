# Colorear tablero de azul
.macro print_ocean (%player_table)
li $t0 0x0000FF	#Azul
li $t1 0
loop_2:

sw $t0 %player_table($t1)
addi $t1 $t1 4
beq $t1 2048 end_loop_2
j loop_2

end_loop_2:

.end_macro


.macro print_ship_space (%player,%color,%ship_orientation,%ship_long) #Colocar barco		
li $t1 1 		# Iterador
# %color
# %ship_orientation 4=Horizontal ; 128=Vertical
# %ship_long	# Longitud del barco

loop_3:	 #Pinto el barco
sw %color %player($t0)
add $t0 $t0 %ship_orientation
beq $t1 %ship_long end_loop_3
addi $t1 $t1 1
j loop_3
end_loop_3:
move $t2 %ship_orientation
move $t3 %ship_long
mul $t1 $t2 $t3
sub $t0 $t0 $t1

.end_macro

#.macro read_move (%caracter)

#.macro border_exceded ()

#Si esta en la ultima fila (8)

#Si esta en la fila 7

#Si esta en la fila 6

#Si esta en la fila 5

#Si esta en la fila 4

#Si esta en la fila 3

#Si esta en la fila 2

#Si esta en la fila 1
