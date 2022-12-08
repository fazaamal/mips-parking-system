.data
welcome: .asciiz "Welcome! This is the FILA parking garage. Please scan your TouchNGo card to enter!"

.text
#t0 = pressure sensor to detect whether car is present or not at the barrier
#t1 = TnG card reader
#t2 = proximity sensor to detect whether car is in the spot or not
#t3 = LED (red/green)

start:
la $a0, welcome
j printString


printString:
li $v0, 4
syscall
j $ra 
	
