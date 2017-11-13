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

	.macro append_intr_flag_mask(%reg)
	# Basically this macro does this:
	#sll %reg, %reg,  0x10
	#addi %reg, %reg, 0x8501
	# This also holds the processor in kernel mode and normal level (see KSU, ERL, and EXL)
	sll %reg, %reg, 0x8
	addi %reg, %reg, 0x85 # Enable interrupts 7 and 1
	sll %reg, %reg, 0x8
	addi %reg, %reg, 0x01 # Enable master interrupt flag and sets KSU, ERL, and EXL
	.end_macro 
	
	.macro push(%reg)
	addi $sp, $sp, -0x4
	sw %reg, 0x0($sp)
	.end_macro
	
	.macro pop(%reg)
	lw %reg, 0x0($sp)
	addi $sp, $sp, 0x4
	.end_macro
	
	.data
	EXCP_CODE:	.word 0x0000
	TRAP0_SET:	.word 0x0000
	AES_DONE:	.word 0x0000

	.text # Starting off at 0x0000_0000
__INIT:
	# Two zero test instructions
	mtc0 $zero, $12
	mtc0 $zero, $13
	## This is where critical peripheral initializtion takes place
	addi $t1, $zero, 0x5000 # N3: Enable interrupts, CP0, and CP2
	append_intr_flag_mask($t1)
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
		
##################################################### 
# X180 Handler
# 
# Handles exceptions and interrupts asynchronously
# sent by the CPU. Routes interrupts to appropriate
# processing routines and (for now) stores other 
# exceptions to memory location EXCP_CODE for OS
# processing.
# 
# Note: This routine must be positioned at ROM 
#       address 0x180 per MIPS documentation.
#####################################################

__X180_HANDLER: ## Regs clobbered: K0
	addi $sp, $sp, -0xC # N4: store the registers that I'm going to use to the stack
	sw $ra, 0x8($sp)
	sw $k1, 0x4($sp)
	sw $a0, 0x0($sp)
	
	sw $ra, 0x7FEF
	
	mfc0 $k0, $12 # Turn off the master interrupt flag
	srl $k0, $k0, 0x1
	sll $k0, $k0, 0x1
	mtc0 $k0, $12
	
	## TODO: Consider pushing $t1 to the stack and restoring once done
	mfc0 $k0, $13 # Grab the interrupt statuses
	addi $k1, $zero, 0x007C # N2: Mask out everything except exception code
	and  $k1, $k0, $k1
	srl $k1, $k1, 0x2
	sw  $k1, EXCP_CODE($zero)
	
	beq $k1, $zero, IS_INTR # Would do a bne here, but not available in the arch, hence this skip-step if
	j OTHER_EXCP
	IS_INTR:
		sll $k0, $k0, 0x8 # N3: Look at the interrupt flags
		addi $k1, $zero, 0xFF
		and $k0, $k1, $k0
		
		addi $k1, $zero, 0x80 # N3: Case HWINTR5 (also for next few blocks for different interrupts)
		and $k1, $k0, $k1
		beq $k1, $zero, CASE_HWINTR5
		
		#addi $k1, $zero, 0x40
		#and $k1, $k0, $k1
		#beq $k1, $zero, CASE_HWINTR4
		
		#addi $k1, $zero, 0x20
		#and $k1, $k0, $k1
		#beq $k1, $zero, CASE_HWINTR3
		
		#addi $k1, $zero, 0x10
		#and $k1, $k0, $k1
		#beq $k1, $zero, CASE_HWINTR2
		
		#addi $k1, $zero, 0x08
		#and $k1, $k0, $k1
		#beq $k1, $zero, CASE_HWINTR1
		
		addi $k1, $zero, 0x04
		and $k1, $k0, $k1
		beq $k1, $zero, CASE_HWINTR0
		
		#addi $k1, $zero, 0x02
		#and $k1, $k0, $k1
		#beq $k1, $zero, CASE_SWINTR1
		
		#addi $k1, $zero, 0x01
		#and $k1, $k0, $k1
		#beq $k1, $zero, CASE_SWINTR0
		
		j CASE_DEFAULT
		
		CASE_HWINTR5:
			jal PROC_INTR_HANDLE_TIMER
			addi $a0, $zero, 0x80
		#CASE_HWINTR4:
		#CASE_HWINTR3:
		#CASE_HWINTR2:
		#CASE_HWINTR1:
		CASE_HWINTR0:
			jal PROC_INTR_HANDLE_AES
			addi $a0, $zero, 0x04
		#CASE_SWINTR1:
		CASE_SWINTR0:
			jal PROC_INTR_HANDLE_ACKBAR
			addi $a0, $zero, 0x01
		CASE_DEFAULT:
			addi $a0, $zero, $zero # It's an interrupt we don't handle, reset all?
	OTHER_EXCP:
		# What do we want to do with exceptions?
	END_IS_INTR:
	
	jal PROC_RESET_INTR # Reset interrupt $a0
		
	lw $a0, 0x0($sp)
	lw $k1, 0x4($sp)
	lw $ra, 0x8($sp)
	addi $sp, $sp, 0xC
	
	mfc0 $k0, $14 # N2: return to whence we've interrupted
	jr $k0 # End ISR


		nop # N8: Padding instructions to separate ISR from main line code (not really needed, discard if space gets short)
		nop
		nop
		nop
		nop
		nop
		nop
		nop


PROC_RESET_INTR:
	# In MIPS convention these shouldn't be stack saved, but because of the sensitive nature of the ISR, they are here
	push($k0)
	push($k1)
	## Reset interrupt controls
	mfc0 $k1, $12
	addi $k0, $k0, 0xFF # N7: Construct a disabling mask
	sll $k0, $k0, 0x8
	addi $k0, $k0, 0xFF
	sll $k0, $k0, 0x8 # N2: Reset all interrupts ($a0 is the interrupt pin that was triggered)
	add $k0, $k0, $a0
	sll $k0, $k0, 0x8
	addi $k0, $k0, 0xFF
	
	and $k1, $k1, $k0 # Turn off relevant bits
	mtc0 $k1, $12 # Set new register value
	
	srl $k1, $k1, 0x10 # N2: Truncate the interrupt bits and append new
	append_intr_flag_mask($k1)
	or $k1, $k1, $k0
	mtc0 $k1, $12
	
	pop($k1)
	pop($k0)
	jr $ra


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


PROC_INTR_HANDLE_TIMER:
	# Handle the timer
	
	jr $ra # K0 designated as return address for interrupt handlers


PROC_INTR_HANDLE_ACKBAR:
	# It's a trap!
	push($t0)
	addi $t0, $zero, 0x1 # Signal that trap was received
	sw $t0, TRAP0_SET($zero)
	pop($t0)
	jr $ra


PROC_INTR_HANDLE_AES:
	# Handle AES
	push($t0)
	addi $t0, $zero, 0x1 # Signal that AES is now complete
	sw $t0, AES_DONE($zero)
	pop($t0)
	jr $ra # K0 designated as return address for interrupt handlers


__HALT:	# End of program
	j __HALT