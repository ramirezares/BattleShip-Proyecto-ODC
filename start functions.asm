# Colorear tablero de azul
.macro print_ocean (%board)
		li $t0 blue	#Azul claro
		li $t1 0
	loop_2:
		sw $t0 %board($t1)
		addi $t1 $t1 4
		
		#Tablero de abajo
		beq $t1 1024 other_blue
		j continue
		
		other_blue:
		li $t0 BLUE	#Azul oscuro
		#Condición de parada
		continue:
		beq $t1 2048 end_loop_2
		
		j loop_2
	end_loop_2:

.end_macro

.macro save_board (%display_board, %reserved_space)
    	# %display_board es el tablero del Bitmap Display
    	# %reserved_space es el espacio de memoria reservado para ese tablero
	li $t0, 0                      # Inicializa el índice en 0
    	li $t1, 2048                   # Tamaño total del tablero (2048 bytes)
	loop_save:
	beq $t0, $t1, end_save_board   # Si copiamos todas las celdas sale

	lw $t2, %display_board($t0)     # Carga el valor del tablero del display
	sw $t2, %reserved_space($t0)     # Guarda el valor en el espacio reservado

	addi $t0, $t0, 4                # Avanza 
	j loop_save                     
	end_save_board:
.end_macro

.macro load_board (%reserved_space,%display_board)
    	# %reserved_space es el tablero que se desea cargar
    	# %display_board es el tablero del Bitmap Display
	li $t0, 0                      # Inicializa el índice en 0
    	li $t1, 2048                   # Tamaño total del tablero (2048 bytes)
	loop_save:
	beq $t0, $t1, end_save_board   # Si copiamos todas las celdas sale

	lw $t2, %reserved_space($t0)     # Carga el valor del tablero guardado
	sw $t2, %display_board($t0)     # Coloca el valor en el display

	addi $t0, $t0, 4                # Avanza 
	j loop_save                     
	end_save_board:
.end_macro

#Colocar barco 
.macro print_ship_space (%player,%color,%ship_orientation,%ship_size,%ship_memory) 	
	li $t1 1 		# Iterador de pintar
	li $t4 0   		# Iterador para el espacio de memoria del barco
	# %color
	# %ship_orientation 	4=Horizontal ; 64=Vertical
	# %ship_size			Longitud del barco
	# %ship_memory		Espacio de memoria donde guardaré la posición del barco cada posicion 	
	
	loop_3:	 #Pinto el barco y guardo sus celdas
		sw %color %player($t0)
		#Guardo sus celdas
		sw $t0 %ship_memory($t4)	#Cargo la posición en el espacio reservado
		# Este espacio reservado se ve como un arreglo de tantos espacios como
		# se le haya indicado en el .space. Recordar que para una palabra se reservan 4 bytes
		
		add $t0 $t0 %ship_orientation
		beq $t1 %ship_size end_loop_3
		addi $t1 $t1 1
		addi $t4 $t4 4 #Avanzo en la palabra
		j loop_3
	end_loop_3:
		move $t2 %ship_orientation
		move $t3 %ship_size
		mul $t1 $t2 $t3
		sub $t0 $t0 $t1
.end_macro

#Funcion que valida los límites laterales
.macro border_exceded (%direction,%ship_orientation, %ship_size)
    # $t0 tiene la posición 
    # %direction 0 = límite izquierdo ; 1 = límite derecho
    # %ship_orientation 4=H ; 64=V Si la nave esta horizontal o vertical
    # %ship_size tamaño del barco

    # En $v0 queda el límite 

    # Calculamos tamaño del barco en bytes (n_celdas * 4)
    sll $t1 %ship_size 2       # $t1 = %ship_size * 4

    # Determinamos fila actual (0-15)
    li   $t2 64   # Tamaño para moverme entre filas
    sub  $t3 $t0 1024
                # Resto 1024
    srl  $t3 $t3 6               # $t3 = (posición - 1024) / 6 (fila)

    # Límite izquierdo
    li $t4 %direction
    beqz $t4 left_limit     # Si es límite izquierdo, calcularlo

    # Límite derecho
    move $t5 %ship_orientation
    beq $t5 64 ship_is_vertical
    j right_limit
    
    ship_is_vertical:
    li $t1 4
    
    right_limit:
    li $t4 0
    addi $t4 $t3 1               # $t4 = fila + 1
    mul  $t4 $t4 $t2             # $t4 = (fila + 1) * 64
    addi $t4 $t4 1024            # $t4 = 1024 + (fila + 1) * 64
    sub  $v0 $t4 $t1             # Límite derecho = límite derecho - tamaño_barco
    j    end_macro_border_exceded  # Salta al final

left_limit:
    # Límite izquierdo = 1024 + fila * 64
    mul  $t4 $t3 $t2             # $t4 = fila * 64
    addi $v0 $t4 1024            # Límite izquierdo = 1024 + fila * 64
	
end_macro_border_exceded:
.end_macro

# Función que verifica si los siguientes espacios estan 
# disponibles para colocar el barco 

# ship orientation es 64
#ship size es 5
# iterador es 5
.macro verify_availability (%board,%ship_orientation,%ship_size,%iterator)
	# %board  es el tablero a verificar
	# %ship_orientation es la orientacion del barco, 4 horizontal, 64 vertical
	# %ship_size es el tamaño del barco
	# %iterator  es un iterador para validar
	
	move $t5 %iterator
	loop_5: # Verificamos la colocación inicial del barco y las celdas siguientes
		# Condicion de parada
		beqz $t5 end_loop_5 # Si el iterador llega a 0 consiguio el espacio necesario
		bgt $t0 2044 stop_verify # Si se sale del tablero detiene el bucle

		lw $t3 %board(AUX2) #Tomo el color que esta en la casilla
		beq $t3 BLUE available

		move $t5 %iterator  #Si no es azul quiere decir que esta ocupada, reinicio la cuenta
		move $t0 AUX2   #Muevo el cursor donde colocare el barco
		add $t0 $t0 %ship_orientation # y avanzo una posición
		add AUX2 AUX2 %ship_orientation #Avanzo una posición
		j loop_5

		available:
		addi $t5 $t5 -1
		add AUX2 AUX2 %ship_orientation #Avanzo una posición
		j loop_5 # Continuo
		
		stop_verify:
		move $t0 AUX
		
	end_loop_5:
.end_macro


#Mover  
.macro place_boat (%board,%ship_size,%ship_memory) # MACRO COLOCAR BARCO
	li $s1 4  # Indica la orientación 4=Horizontal ; 64=Vertical
	li $s2 %ship_size  # Indica la longitud del barco
	  
	#Situo inicialmente el barco para verificar si la posición no esta ocupada
	li $t0 1024 #Ubicacion en la mitad del tablero
	li $t1 %ship_size # Contador para revisar las posiciones
	move AUX2 $t0 # Para disponibililidad
	
	verify_availability (%board,$s1,$s2,$t1)

	li $t2 GRAY #Color gris
	print_ship_space (%board,$t2,$s1,$s2,%ship_memory)

	loop_4:	#Bucle para mover el barco a colocar
		print_message (ask_move)
		read_character ()
		beq $v0 97 left
		beq $v0 100 right
		beq $v0 119 up
		beq $v0 115 down
		beq $v0 114 rotate
		beq $v0 10 end_loop_4 #Tecla enter
		j continue_4

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
	j loop_4

	end_loop_4:

.end_macro
