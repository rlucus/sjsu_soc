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
#.globl __INTR, INTR_CODE
.data
	INTR_CODE:	.word 0x0000
.text 0x00000180 # Align ISR at 0x180
__INTR: ## Regs used: T0, T1
	mfc0 $t8, $12 # Turn off the master interrupt flag
	srl $t8, $t8, 0x1
	sll $t8, $t8, 0x1
	mtc0 $12, $t9
	
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
	
	mfc0 $t9, $14 # N2: return to whence we've interrupted
	jr $t9 # End ISR
