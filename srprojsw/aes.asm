.include "mmap_hw.asm"
.include "data.asm"
.eqv AES_GP 0x0000
.eqv AES_FP 0x0080
.eqv AES_SP 0x00B0

.eqv sentence 0x0 # Keep the message in the phrase


PROC_ENCR_AES:
	# Frame init
	addi $gp, $zero, AES_GP
	addi $fp, $zero, AES_FP
	addi $sp, $zero, AES_SP

	# Load the key directly into the coprocessor
	addi $t0, $zero, AES_KEY_HWORD0
	addi $t1, $zero, AES_KEY_HWORD1
	addi $t2, $zero, AES_KEY_HWORD2
	addi $t3, $zero, AES_KEY_HWORD3
	addi $t4, $zero, AES_KEY_HWORD4
	addi $t5, $zero, AES_KEY_HWORD5
	addi $t6, $zero, AES_KEY_HWORD6
	addi $t7, $zero, AES_KEY_HWORD7
	# TODO: Every time this is compiled, replace ANY MTC0 instruction with MTC2!!! Manually...
	mtc0 $t0, $2
	mtc0 $t1, $3
	mtc0 $t2, $4
	mtc0 $t3, $5
	mtc0 $t4, $6
	mtc0 $t5, $7
	mtc0 $t6, $8
	mtc0 $t7, $9

	addi $t1, $fp, sentence # Set up a pointer to start loading the phrase

	## The next N stanzas simply load the phrase in, one agonizing word at a time
	addi $t0, $zero, MSG_03
	sll $t0, $t0, 0x8
	addi $t0, $t0, MSG_02
	sll $t0, $t0, 0x8
	addi $t0, $t0, MSG_01
	sll $t0, $t0, 0x8
	addi $t0, $t0, MSG_00
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $t0, $zero, MSG_07
	sll $t0, $t0, 0x8
	addi $t0, $t0, MSG_06
	sll $t0, $t0, 0x8
	addi $t0, $t0, MSG_05
	sll $t0, $t0, 0x8
	addi $t0, $t0, MSG_04
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $t0, $zero, MSG_11
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_10
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_09
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_08
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $t0, $zero, MSG_15
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_14
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_13
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_12
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $t0, $zero, MSG_19
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_18
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_17
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_16
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $t0, $zero, MSG_23
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_22
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_21
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_20
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $t0, $zero, MSG_27
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_26
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_25
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_24
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $t0, $zero, MSG_31
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_30
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_29
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_28
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $t0, $zero, MSG_35
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_34
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_33
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_32
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1
	
	addi $t0, $zero, MSG_39
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_38
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_37
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_36
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1
	
	addi $t0, $zero, MSG_43
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_42
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_41
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_40
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1
	
	addi $t0, $zero, MSG_47
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_46
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_45
	sll $t0, $t0, 0x8
	addi $t0, $zero, MSG_44
	sw $t0, 0x0($t1)
	addi $t1, $t1, 0x1

	addi $s0, $fp, sentence # Set up a pointer to give to the AES
	addi $s1, $zero, CRLF
	sll $s1, $s1, 0xF # Set up a register that I can randomly print newline with
	sw $s1, UART($zero)
	sw $s1, UART($zero) # Write a couple newlines
	
	beq $zero, $zero, PROC_ENCR_AES
	jr $ra
