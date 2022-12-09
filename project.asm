.data
welcome: .asciiz "\nLCD DISPLAY: Welcome! This is the FILA parking garage. \nPlease scan your TouchNGo card to enter! " 
cardDetected: .asciiz "\nCard detected? (y/n) " 
weightDetectedOnPressureSensor: .asciiz "Weight detected on pressure sensor? (kg) "
enterCardBalance: .asciiz "\nWhat is the card balance? "
insufficientBalance: .asciiz "\nSorry insufficient funds. Please ensure you have at least RM10 in your TnG card"
cardBalanceLCD: .asciiz "\nLCD DISPLAY: Your card balance is: RM"

.text
#t0 = pressure sensor to detect whether car is present or not at the barrier
#t1 = RFID card reader
#t2 = proximity sensor to detect whether car is in the spot or not
#t3 = LED (red/green)
#t4 = motor for the barrier (0 = closed, 1 = opened)

start:

detectCarOnPressureSensor:
la $a0, weightDetectedOnPressureSensor
jal printString
jal readInt
move $t0, $v0
#If weight detected is less than 1000kg then keep waiting until weight is greater than 1000kg
ble $t0, 999, detectCarOnPressureSensor

la $a0, welcome
jal printString

detectCard:
la $a0, cardDetected
jal printString
jal readChar
#Move char read to register for RFID reader
move $t1, $v0 
bne $t1, 'y', detectCard

#Check balance of the TnG card, if it is less than RM10, display Insufficient Funds and return to the pressure sensor weight detection
checkBalance:
la $a0, enterCardBalance
jal printString
jal readInt
move $t5, $v0
ble $t0, 9, insufficientFunds
j displayBalance
insufficientFunds:
la $a0, insufficientBalance
jal printString
j detectCarOnPressureSensor

displayBalance:
la $a0, cardBalanceLCD
jal printString
move $a0, $t5
jal printInt

#Open the barrier 
li $t4, 1

#Wait until detected weight from pressure plate is zero

#Wait until sensor detected distance of less than 1 metre

#Turn LED green

#Start with exiting procedure 

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

printInt:
li $v0, 1
syscall
jr $ra
	
exit:
li $v0, 10
syscall

