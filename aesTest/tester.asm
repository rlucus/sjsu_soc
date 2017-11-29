#config for cp2
addi $t0, $zero, 1025
addi $t7, $zero, 1024

mtc0 $zero, $12
mtc0 $zero, $13
mtc0 $zero, $14

#start config for addi
#t6 encrypt, t8 decrypt
addi $t6, $zero, 7
addi $t8, $zero, 6
sll $t6, $t6, 28
sll $t8, $t8, 28
addi $t6, $t6, 1
addi $t8, $t8, 1
#feed a block of data in
addi $t1, $zero, 97
addi $t2, $zero, 98
addi $t3, $zero, 99
addi $t4, $zero, 100
addi $t5, $zero, 0


#store to memory
sw $t1, ($t5)
addi $t5, $t5, 4
sw $t2, ($t5)
addi $t5, $t5, 4
sw $t3, ($t5)
addi $t5, $t5, 4
sw $t4, ($t5)

#enable interrupts
mtc0 $t0, $12
nop


#write the key 2-9
mtc0 $t1, $2
mtc0 $t2, $3
mtc0 $t3, $4
mtc0 $t4, $5
mtc0 $t1, $6
mtc0 $t2, $7
mtc0 $t3, $8
mtc0 $t4, $9

#write the start address 1
mtc0 $zero, $1

#write the status register 0
#30, 29, 28 should all be 1s, smallest bit should be length. in this case 1
mtc0 $t6, $0

nop
test: j test
nop
nop
nop







#Begin ISR
#disable IE
mtc0 $t7, $12
#output to UART
lw $s0, 0x0
sw $s0, 0x7000
lw $s0, 0x4
sw $s0, 0x7000
lw $s0, 0x8
sw $s0, 0x7000
lw $s0, 0xc
sw $s0, 0x7000

#clear 
mtc0 $zero, $12
#decrypt
mtc0 $t0, $12
mtc0 $t8, $0
j test




