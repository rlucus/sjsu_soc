	.eqv	UART	0x7EEF
	.eqv	DATA1	0x4A
	.eqv	DATA2	0x56
.data
	TEST:	.word 	0x00000000
.text	
__INIT:
	addi $s0, $zero, DATA1
	addi $s1, $zero, 20
	sw $s0, UART
LOOP:	addi $s1, $s1, -1
	beq $s1, $zero, DONE
	j LOOP
DONE:	addi $s0, $zero, DATA2
	sw $s0, UART
__HALT:	j __HALT