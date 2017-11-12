##########################################################
# TEST ISR
# 
# Author: Kai Wetlesen
# 
# Wires up an interrupt service routine which simply grabs
# the exception code or the interrupt flag set, then dumps
# that value into memory with an indicator bit. The 
# indicator will determine whether the interrupt came from
# an exception (internal) or a wire (external).
#
# Note: This should compile straight down to bytecode 
# representing these precise instructions. No instructions
# should expand out. You'll notice some instructions which
# seem superfluous (e.g. addi 0x12, sll 0x8, addi 0x34),
# however this is very intentional. This prevents the MARS
# assembler from splitting instructions apart into those
# which are not implemented in the J.A.R.K. MIPS CPU.
##########################################################
	.data
	INTR_CODE:	.word 0x0000
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
	# Two zero test instructions
	mtc0 $zero, $12
	mtc0 $zero, $13
	## This is where critical peripheral initializtion takes place
	addi $t1, $zero, 0x5000 # N4: Enable interrupts, CP0, and CP2
	#sll $t1, $t1, 0x10
	sll $t1, $t1, 0x8
	#addi $t1, $t1, 0x8501
	addi $t1, $t1, 0x85
	sll $t1, $t1, 0x5
	addi $t1, $t1, 0x01
	mtc0 $t1, $12
	mtc0 $zero, $13 # N2: Init the other registers to zero
	mtc0 $zero, $14
	## Start main, then halt if we somehow return out
	jal __KMAIN
	
	j __HALT
	
		#nop # N(whatever): Padding instructions to align the ISR in the program to address 0x180
		#nop # Note: Remove exactly one instruction for every instruction added above this comment!
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		
__INTR: ## Regs used: T0, T1
	mfc0 $t8, $12 # Turn off the master interrupt flag
	srl $t8, $t8, 0x1
	sll $t8, $t8, 0x1
	mtc0 $t9, $12
	
	## TODO: Consider pushing $t1 to the stack and restoring once done
	mfc0 $t8, $13 # Grab the interrupt statuses
	addi $t9, $zero, 0x007C # N2: Mask out everything except exception code
	and  $t9, $t8, $t9
	
	beq $t9, $zero, IS_EXTERN
	IS_NOT_EXTERN:
		srl $t9, $t9, 1 # N2: Align exception code to bits 6 through 1, and leave bit 0 to as 0 signalling !is_external
		j END_IS_EXTERN
	IS_EXTERN:
		#addi $t9, $zero, 0xFC00 # N5: Mask out everything except external interrupt flags then align to bits 6 through 1
		addi $t9, $zero, 0xFC # Note, previous instruction expands to a pseudoinstruction because of sign bit
		sll $t9, $t9, 0x8 
		and $t9, $t9, $t0
		sll $t9, $t9, 0x9
		addi $t9 $t9, 0x1 # Signal is_external by setting bit 0 to 1
	END_IS_EXTERN:
	
	sw  $t9, INTR_CODE($zero)
	mfc0 $t7, $14 # Test instruction to see when this register horks
	# TODO: Update this such that only the activated interrupt is triggered
	mfc0 $t9, $12 # N7: Reset interrupt controls
	addi $t8, $t8, 0xFF
	sll $t8, $t8, 0x8
	addi $t8, $t8, 0xFF
	sll $t8, $t8, 0x10
	addi $t8 $t8, 0x00FF
	and $t9, $t9, $t8
	mtc0 $t9, $12
	and $t9, $t9, 0x8501
	mtc0 $t9, $12
	nop # N?: How many NOPs for a Klondike bar?
	mfc0 $t9, $14 # N2: return to whence we've interrupted
	jr $t9 # End ISR
	
		nop # N8: Padding instructions to separate ISR from KMAIN
		nop
		nop
		nop
		nop
		nop
		nop
		nop

	## Main Program Start
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
