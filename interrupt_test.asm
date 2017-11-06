	.data
	INTR_SET:	.word 0x0000
	.text # Starting off at 0x0000_0000
	### Comment notation (wildcards denoted with regex):
	###
	###    instr $1, $2, $3 # N[0-9]+: Comment here -> Next four instructions, comment applies
	###
	###    instr $1, $2, $3 # Comment here -> Comment applies only for colinear instruction
	###
	###    ## Comment -> For this block, comment applies
	
	# Binary to Hex scratch space
	# 31   27   23   19     15   11   7    3  
	# 0000 0000 0000 0000 - 0000 0000 0000 0000
	# 0101 0000 0000 0000 - 1000 0100 0000 0001
	#    5    0    0    0      8    5    0    1

__INIT:
	## This is where critical peripheral initializtion takes place
	addi $t1, $zero, 0x5000 # N4: Enable interrupts, CP0, and CP2
	sll $t1, $t1, 0x10
	addi $t1, $t1, 0x8501
	mtc0 $t1, $12
	mtc0 $zero, $13 # N2: Init the other registers to zero
	mtc0 $zero, $14
	## Start main, then halt if we somehow return out
	jal __KMAIN
	j __HALT
	
	.ktext 0x00000180
__INTR: ## Regs used: T0, T1
	mfc0 $s0, $12 # Turn off the master interrupt flag
	srl $t0, $t0, 0x1
	sll $t0, $t0, 0x1
	mtc0 $12, $t0
	
	mfc0 $t0, $13 # Grab the interrupt statuses
	addi $t1, $zero, 0x007C # N2: Mask out everything except exception code
	and  $t1, $t0, $t1
	
	beq $t1, $zero, IS_INTR
	IS_NOT_INTR:
		srl $t1, $t1, 1 # N2: Align exception code to bits 6 through 1, and leave bit 0 to as 0 signalling !is_external
		j END_IS_INTR
	IS_INTR:
		addi $t1, $zero, 0xFC00 # N3: Mask out everything except external interrupt flags then align to bits 6 through 1
		and $t1, $t1, $t0
		sll $t1, $t1, 0x9
		addi $t1, $t1, 0x1 # Signal is_external by setting bit 0 to 1
	END_IS_INTR:
	
	sw  $t1, INTR_SET($zero)
	# TODO: figure out the rest of the test ISR
	
__KMAIN:
	WHILE_SCHED_SLICE:
	addi $s0, $s0, 1 # Just a simple counter to while away the time until I can properly implement this
	
	# This is an example of how to do a single compare conditional
	addi $t1, $zero, 0xA
	# If $s0 < $t1 then foo else bar
	slt $t0, $s0, $t1
	beq $t1, $zero, FOO # TODO: Must double test branch due to quirk with the processor
	BAR:	# Else BAR
		xor $zero, $zero, $zero
		j END_FOO
	FOO:	# Then FOO
		xor $zero, $zero, $zero
	END_FOO:
	
	j WHILE_SCHED_SLICE
	# Should not return out of main, but here for correctness:
	jr $ra
	
__HALT:	# End of program
