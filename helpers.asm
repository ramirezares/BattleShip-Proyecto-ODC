# Macros de ayuda (funciones)
.data

.text

#Imprime un mensaje dado
.macro print_message (%message) 
	li $v0 4
	la $a0 %message
syscall
.end_macro

.macro print_number (%number)
	move $a0 %number
	li $v0 1
	syscall
.end_macro

# Función utilizada para debuggear imprimiendo los numeros
# que se guardaron en la memoria de los barcos
.macro print_number_in_memory (%ship_memory) 
	li $t1 12
	lw $a0 %ship_memory($t1)
	li $v0 1
	syscall
.end_macro

 # Lee un caracter introducido por el teclado 
.macro read_character ()
	li $v0 12
	syscall
.end_macro

# Detiene el programa (sys 10)
.macro stop_program	
	li $v0 10
	syscall
.end_macro
 
