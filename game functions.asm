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

#Colocar barco	
.macro print_ship_space (%player,%color,%ship_orientation,%ship_long) 	
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


#Funcion que valida los límites laterales
.macro border_exceded (%direction,%ship_orientation, %ship_size)
    # $t0 tiene la posición 
    # %direction 0 = límite izquierdo ; 1 = límite derecho
    # %ship_orientation 4=H ; 128=V Si la nave esta horizontal o vertical
    # %ship_size tamaño del barco

    # En $v0 queda el límite 

    # Calculamos tamaño del barco en bytes (n_celdas * 4)
    sll $t1, %ship_size, 2       # $t1 = %ship_size * 4

    # Determinamos fila actual (0-15)
    li   $t2, 128                  # Tamaño para moverme entre filas
    sub  $t3, $t0, 1024            # Resto 1024
    srl  $t3, $t3, 7               # $t3 = (posición - 1024) / 128 (fila)

    # Límite izquierdo
    li $t4 %direction
    beqz $t4, left_limit     # Si es límite izquierdo, calcularlo

    # Límite derecho
    move $t5 %ship_orientation
    beq $t5 128 ship_is_vertical
    j right_limit
    
    ship_is_vertical:
    li $t1 4
    
    right_limit:
    li $t4 0
    addi $t4, $t3, 1               # $t4 = fila + 1
    mul  $t4, $t4, $t2             # $t4 = (fila + 1) * 128
    addi $t4, $t4, 1024            # $t4 = 1024 + (fila + 1) * 128
    sub  $v0, $t4, $t1             # Límite derecho = límite derecho - tamaño_barco
    j    end_macro_border_exceded  # Salta al final

left_limit:
    # Límite izquierdo = 1024 + fila * 128
    mul  $t4, $t3, $t2             # $t4 = fila * 128
    addi $v0, $t4, 1024            # Límite izquierdo = 1024 + fila * 128
	#REVISAR AQUI SI ES MENOR QUE EL LIMITE MENOS 4
end_macro_border_exceded:
.end_macro


#Mover 
.macro place_boat (%ship_long) # MACRO COLOCAR BARCO
	li $s1 4  # Indica la orientación 4=Horizontal ; 128=Vertical
	li $s2 %ship_long  # Indica la longitud del barco
	  
	#Situo inicialmente el barco para verificar si la posición no esta ocupada
	li $t0 1024 #Ubicacion en la mitad del tablero
	li $t1 %ship_long # Contador para revisar las posiciones
	li $t2 1024 #auxiliar para ir verificando
	
	loop_5: # Verificamos la colocación inicial del barco y las 5 celdas siguientes
		# Condicion de parada
		beqz $t1 end_loop_5			

		lw $t3 p1($t2) #Tomo el color que esta en la casilla
		beq $t3 BLUE available

		li $t1 %ship_long  #Si no es azul quiere decir que esta ocupada, reinicio la cuenta
		move $t0 $t2   #Muevo el cursor donde colocare el barco
		addi $t0 $t0 4 # y avanzo una posición
		addi $t2 $t2 4 #Avanzo una posición

		available:
		addi $t1 $t1 -1
		addi $t2 $t2 4 #Avanzo una posición
		j loop_5 # Continuo
	end_loop_5:

	li $t2 GRAY #Color gris
	print_ship_space (p1,$t2, $s1,$s2)

	loop_4:	#Bucle para mover el barco a colocar
		print_message (ask_move)
		read_caracter ()
		beq $v0 97 left
		beq $v0 100 right
		beq $v0 119 up
		beq $v0 115 down
		beq $v0 114 rotate
		beq $v0 10 end_loop_4 #Tecla enter
		j continue_4

	left:
	# $t0 tiene la posición actual
	li $t2 BLUE	
	print_ship_space (p1,$t2, $s1,$s2)
	border_exceded (0,$s1,$s2)
	addi $t0 $t0 -4
	blt $t0 1024 left_exceded #Verifica que no se salga del cuadro inferior del tablero

	blt $t0 $v0 border_left_exceded
	j continue_4

	border_left_exceded:
	move $t0 $v0
	j continue_4			
	
	left_exceded:
	li $t0 1024 
	j continue_4

	right:
	# $t0 tiene la posición actual
	li $t2 BLUE
	print_ship_space (p1,$t2, $s1, $s2)
	move AUX $t0
	border_exceded (1,$s1,$s2)
	addi $t0 $t0 4
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
	print_ship_space (p1,$t2, $s1,$s2)
	move AUX $t0 
	addi $t0 $t0 -128
	blt $t0 1024 up_exceded 
	j continue_4

	up_exceded:
	move $t0 AUX 
	j continue_4

	down:
	# $t0 tiene la posición actual
	li $t2 BLUE
	print_ship_space (p1,$t2, $s1,$s2)
	move AUX $t0 
	addi $t0 $t0 128 

	bgt $t0 2044 down_exceded_simple #Verificacion simple de salidar
	beq $s1 128 verify_ship_exceded_down	#Verifico si es vertical
	j continue_4

	verify_ship_exceded_down:	
	mul $t3 $s2 128
	add $t0 $t0 $t3
	bgt $t0 2044 reset
	sub $t0 $t0 $t3
	j continue_4

	reset:
	move $t0 AUX

	down_exceded_simple:
	move $t0 AUX
	j continue_4

	rotate:
	li $t2 BLUE
	print_ship_space (p1,$t2, $s1,$s2)
	beq $s1 4 to_vertical # Si es horizontal (4) cambio a vertical (128)
	beq $s1 128 to_horizontal # Si es vertical (128) cambio a horizontal (4) 

	to_vertical:
	li $s1 128
	j continue_4

	to_horizontal:
	li $s1 4

	continue_4:
	li $t2 GRAY #Color gris
	print_ship_space (p1,$t2, $s1,$s2)
	j loop_4

	end_loop_4:

.end_macro
