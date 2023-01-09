.data
welcome: .asciiz "\nLCD DISPLAY: Welcome! This is the FILA parking garage. \nPlease scan your TouchNGo card to enter! " 
exitScan: .asciiz "\n\Please scan your TouchNGo card to exit!\n" 
cardDetected: .asciiz "\nCard detected? (y/n) " 
weightDetectedOnPressureSensor: .asciiz "\nWeight detected on pressure sensor at barrier? (kg) "
heightDetectedOnPressureSensor: .asciiz "\nHeight detected on proximity sensor on top of parking spot? (cm) "
enterCardBalance: .asciiz "\nWhat is the card balance? "
insufficientBalance: .asciiz "\nLCD DISPLAY: Sorry insufficient funds. Please ensure you have at least RM10 in your TnG card\n"
cardBalanceLCD: .asciiz "\nLCD DISPLAY: Your card balance is: RM"
barrierOpened: .asciiz "\nBarrier opened!\n"
barrierClosed: .asciiz "\nBarrier closed!\n"
parkingIndicatorGreen: .asciiz "\nParking indicator turned green! No car is parked!\n"
parkingIndicatorRed: .asciiz "\nParking indicator turned red! Car is parked!\n"
enterHoursParked: .asciiz "\nHow many hours have you parked? "
parkingFeeCharged: .asciiz "\n Parking fee charged : RM"
goodbye: .asciiz "\nThank you for using FILA parking garage!\n"

.text
#t0 = pressure sensor to detect whether car is present or not at the barrier
#t1 = RFID card reader
#t2 = proximity sensor to detect whether car is in the spot or not
#t3 = LED (0 = red, 1 = green)
#t4 = motor for the barrier (0 = closed, 1 = opened)
#t5 = TnG card balance
#t6 = hours parked
#t7 = parking fee (hours parked * parking rate (RM1/hr))_
#t8 = hourly rate 

start:

li $t8, 1

detectCarOnPressureSensorOnEntry1:
la $a0, weightDetectedOnPressureSensor
jal printString
jal readInt
move $t0, $v0
#If weight detected is less than 1000kg then keep waiting until weight is greater than 1000kg
ble $t0, 999, detectCarOnPressureSensorOnEntry1

la $a0, welcome
jal printString

detectCard1:
la $a0, cardDetected
jal printString
jal readChar
#Move char read to register for RFID reader
move $t1, $v0 
bne $t1, 'y', detectCard1

#Check balance of the TnG card, if it is less than RM10, display Insufficient Funds and return to the pressure sensor weight detection
checkBalanceEntry:
la $a0, enterCardBalance
jal printString
jal readInt
move $t5, $v0
ble $t5, 9, insufficientFundsEntry
j displayBalanceEntry
insufficientFundsEntry:
la $a0, insufficientBalance
jal printString
j detectCarOnPressureSensorOnEntry1

displayBalanceEntry:
la $a0, cardBalanceLCD
jal printString
move $a0, $t5
jal printInt

#Open the barrier 
li $t4, 1
la $a0, barrierOpened
jal printString

#Wait until detected weight from pressure plate is less than 1000kg
detectCarOnPressureSensorOnEntry2:
la $a0, weightDetectedOnPressureSensor
jal printString
jal readInt
move $t0, $v0
#If weight detected is less than greater than or equal to 1000kg then keep waiting until weight is less than 1000kg
bge $t0, 1000, detectCarOnPressureSensorOnEntry2

#Close the barrier
li $t4, 0
la $a0, barrierClosed
jal printString

# Parking space detection on entry
detectCarOnProximitySensorEntry:
#Turn LED green
li $t3, 1
la $a0, parkingIndicatorGreen
jal printString
la $a0, heightDetectedOnPressureSensor
jal printString
jal readInt
move $t2, $v0
#If height detected is greater than or equal to 2000cm then keep waiting until height is less than 2000cm
bge $t2, 2000, detectCarOnProximitySensorEntry

#Start with exiting procedure 

# Parking space detection on exit
detectCarOnProximitySensorExit:
#Turn LED red
li $t3, 0
la $a0, parkingIndicatorRed
jal printString
la $a0, heightDetectedOnPressureSensor
jal printString
jal readInt
move $t2, $v0
#If height detected is greater than or equal to 2000cm then keep waiting until height is less than 2000cm
ble $t2, 1999, detectCarOnProximitySensorExit

#Turn LED green when car leaves parking spot
li $t3, 1
la $a0, parkingIndicatorGreen
jal printString

#Detect if car is on pressure sensor at exit barrier
detectCarOnPressureSensorOnExit1:
la $a0, weightDetectedOnPressureSensor
jal printString
jal readInt
move $t0, $v0
#If weight detected is less than 1000kg then keep waiting until weight is greater than 1000kg
ble $t0, 999, detectCarOnPressureSensorOnExit1

la $a0, exitScan
jal printString

#Wait until card detected
detectCard:
la $a0, cardDetected
jal printString

# solved by member
jal readChar
#Move char read to register for RFID reader
move $t1, $v0 
beq $t1, 'y', getHoursParked
j detectCard

getHoursParked:
la $a0, enterHoursParked
jal printString
jal readInt
move $t6, $v0
ble $t6, 1, getHoursParked
#Multiply hours parked by hourly rate to $t7 where parking fee is stored
mult $t6, $t8
mflo $t7
j checkBalanceExit

#Check balance of the TnG card, if it has RM1 on top of parking fee, else display Insufficient Funds and return to the pressure sensor weight detection
checkBalanceExit:
la $a0, enterCardBalance
jal printString
jal readInt
move $t5, $v0
ble $t5, $t7, insufficientFundsExit
sub $t5, $t5, $t7
j displayBalanceExit

insufficientFundsExit:
la $a0, insufficientBalance
jal printString
j detectCarOnPressureSensorOnExit1

displayBalanceExit:
la $a0, parkingFeeCharged
jal printString
move $a0, $t7
jal printInt 
la $a0, cardBalanceLCD
jal printString
move $a0, $t5
jal printInt

#Open the barrier 
li $t4, 1
la $a0, barrierOpened
jal printString

#Wait until detected weight from pressure plate is 0
detectCarOnPressureSensorOnExit2:
la $a0, weightDetectedOnPressureSensor
jal printString
jal readInt
move $t0, $v0
#If weight detected is less than 1000kg then keep waiting until weight is greater than 1000kg
bne $t0, 0, detectCarOnPressureSensorOnExit2

#Close the barrier
li $t4, 0
la $a0, barrierClosed
jal printString

#Print goodbye message
la $a0, goodbye
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

printInt:
li $v0, 1
syscall
jr $ra
	
exit:
li $v0, 10
syscall