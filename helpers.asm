# Macros de ayuda (funciones)
.data

.text

.macro print_message (%message) #Imprime un mensaje dado
li $v0 4
la $a0 %message
syscall
.end_macro

.macro read_caracter  # Lee un caracter 
li $v0 12
syscall
.end_macro

.macro stop_program	# Detiene el programa (sys 10)
li $v0 10
syscall
.end_macro
 
