.data
welcome: .asciiz "Welcome! This is the FILA parking garage. Please scan your TouchNGo card to enter!"
cardDetected: .asciiz "Card detected (y/n)? " 
enterCardBalance: .asciiz "What is your card balance? "

.text
#t0 = pressure sensor to detect whether car is present or not at the barrier
#t1 = RFID card reader
#t2 = proximity sensor to detect whether car is in the spot or not
#t3 = LED (red/green)

start:
la $a0, welcome
jal printString


j exit

readInt:
li $v0, 5
syscall
jr $ra

readChar:
li $v0, 12
syscall
jr $ra

printString:
li $v0, 4
syscall
jr $ra 
	
exit:
li $v0, 10
syscall
