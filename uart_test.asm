	.eqv	UART	0x7EEF
	.eqv	JA	0x4A41
	.eqv	RK	0x524B
	.eqv	LTRV	0x56
	.eqv	SCOL	0x3B3B
.data
	TEST:	.word 	0x00000000
.text	
__INIT:
	addi $s0, $zero, JA
	sll $s0, $s0, 0x10
	addi $s0, $s0, RK
	sw $s0, UART

	addi $s0, $zero, SCOL
	sll $s0, $s0, 0x10
	addi $s0, $s0, SCOL
	sw $s0, UART
	
	addi $s1, $zero, 20
	
LOOP:	addi $s1, $s1, -1
	beq $s1, $zero, DONE
	j LOOP
DONE:	addi $s0, $zero, LTRV
	sw $s0, UART
__HALT:	j __HALT