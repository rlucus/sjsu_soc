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
	addi $s1, $zero, 12 # Number of words to encrypt
	addi $s2, $zero, CRLF
	sll $s2, $s1, 0xF # Set up a register that I can randomly print newline with
	sw $s2, UART($zero)
	sw $s2, UART($zero) # Write a couple newlines

	## Write out the intial data to the UART
	add $t1, $zero, $s0 # Set up a pointer to start loading the phrase
	addi $t2, $t1, 48 # End pointer is 48 bytes away
	WRITE_OUT1:
		lw $t3, 0x0($t1)
		sw $t3, UART($zero)
		addi $t1, $t1, 0x4
		bne $t1, $t2, WRITE_OUT1

	# CPU interface/status reg    // 31 , 30,      29,     28,   27-25, 24(RO), ..., 15:0
	# [0] status                  // INT, go, 128/256, encDec, clkMult, hold  ,  0 , words of data
	# Guessing that 1 encodes and 0 decodes.
	mtc0 $s0, $1
	addi $t1, $zero, 0x5 # Set encrypt at 256 bit mode
	sll $t1, $t1, 0xF
	add $t1, $t1, $s1
	mtc0 $t1, $2
	 
	## DMA then starts, encryption starts and now we spin until AES is done
	addi $t2, $zero, 0x1
	SPINLOCK_1:
		lw $t1, AES_DONE($zero)
		bne $t1, $t2, SPINLOCK_1
	sw $s2, UART($zero) # N2: Write to CRLFs
	sw $s2, UART($zero)
	sw $zero, AES_DONE($zero) # Reset AES done flag

	## Write out the encrypted data to the UART
	add $t1, $zero, $s0 # Set up a pointer to start loading the phrase
	addi $t2, $t1, 48 # End pointer is 48 bytes away
	WRITE_OUT2:
		lw $t3, 0x0($t1)
		sw $t3, UART($zero)
		addi $t1, $t1, 0x4
		bne $t1, $t2, WRITE_OUT2
	sw $s2, UART($zero) # N2: Write to CRLFs
	sw $s2, UART($zero)
	sw $zero, UART($zero) # Write out a null terminator in case there is none

	# CPU interface/status reg    // 31 , 30,      29,     28,   27-25, 24(RO), ..., 15:0
	# [0] status                  // INT, go, 128/256, encDec, clkMult, hold  ,  0 , words of data
	# Guessing that 1 encodes and 0 decodes.
	mtc0 $s0, $1
	addi $t1, $zero, 0x4 # Set decrypt at 256 bit mode
	sll $t1, $t1, 0xF
	add $t1, $t1, $s1
	mtc0 $t1, $2
	 
	## DMA then starts, decryption starts and now we spin until AES is done
	addi $t2, $zero, 0x1
	SPINLOCK_2:
		lw $t1, AES_DONE($zero)
		bne $t1, $t2, SPINLOCK_2
	sw $s2, UART($zero) # N2: Write to CRLFs
	sw $s2, UART($zero)
	sw $zero, AES_DONE($zero) # Reset AES done flag

	## Write out the newly decrypted data to the UART
	add $t1, $zero, $s0 # Set up a pointer to start loading the phrase
	addi $t2, $t1, 48 # End pointer is 48 bytes away
	WRITE_OUT3:
		lw $t3, 0x0($t1)
		sw $t3, UART($zero)
		addi $t1, $t1, 0x4
		bne $t1, $t2, WRITE_OUT3
	sw $s2, UART($zero) # N2: Write to CRLFs
	sw $s2, UART($zero)
	sw $zero, UART($zero) # Write out a null terminator in case there is none
	
	beq $zero, $zero, PROC_ENCR_AES
	jr $ra
