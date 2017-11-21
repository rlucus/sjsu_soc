##########################################################
# TEST KERNEL AND ISR
# 
# Author: Kai Wetlesen
# 
# Wires up an interrupt service routine which classifies
# the interrupt then invokes the corresponding service
# routine. Has a small spin loop which generates some 
# observable behavior within the CPU
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
	
	.eqv	NTICKS	0x400 # Number of ticks until the timer interrupt fires
	
	## Data Section
	# Note: Uncomment the include for the assembler file that 
	# corresponds to the environment you're running in.
	.include "mmap_hw.asm" # Memorpy map for the hardware
	#.include "mmap_sim.asm" # Memory map for MARS
	
	.text # Starting off at 0x0000_0000
__INIT:
	add $at, $zero, $zero # N29: Initialize all the registers to zero (solves weird bugs that came up in the hardware simulator)
	add $v0, $zero, $zero # Note: T0, T1, and T2 initialized after memory test routine because they're used in the test
	add $v1, $zero, $zero
	add $a0, $zero, $zero
	add $a1, $zero, $zero
	add $a2, $zero, $zero
	add $a3, $zero, $zero
	add $t3, $zero, $zero
	add $t4, $zero, $zero
	add $t5, $zero, $zero
	add $t6, $zero, $zero
	add $t7, $zero, $zero
	add $s0, $zero, $zero
	add $s1, $zero, $zero
	add $s2, $zero, $zero
	add $s3, $zero, $zero
	add $s4, $zero, $zero
	add $s5, $zero, $zero
	add $s6, $zero, $zero
	add $s7, $zero, $zero
	add $t8, $zero, $zero
	add $t9, $zero, $zero
	add $k0, $zero, $zero
	add $k1, $zero, $zero
	add $gp, $zero, $zero
	add $sp, $zero, $zero
	add $fp, $zero, $zero
	add $ra, $zero, $zero
	addi $t0, $zero 0x1F3A # N7: memory I/O test instructions
	sw $t0, ISR00($zero)
	add $t1, $zero, $zero
	lw $t1, ISR00($zero)
	slt $t2, $t0, $t1
	beq $t2, $zero, MEMIO_TEST_OK
	j __HALT
MEMIO_TEST_OK:
	## Device Initialization
	addi $t1, $zero, 0x5000 # N3: Enable interrupts, CP0, and CP2
	append_intr_flag_mask($t1)
	mtc0 $zero, $12 # BUG FIX: CP0/R12 not zeroing correctly
	mtc0 $t1, $12
	mtc0 $zero, $13 # N2: Init the other registers to zero
	mtc0 $zero, $14
	
	addi $sp, $zero, 0x3F # N3: Initialize the stack pointer
	sll $sp, $sp, 0x8
	addi $sp, $sp, 0xFC
	
	addi $t0, $zero, NTICKS # N3: Initialize the timer
	mtc0 $zero, $22
	mtc0 $t0, $23
	
	add $t0, $zero, $zero # N3: Zero out T0, T1, and T2 after memory test OK and device initialization is complete
	add $t1, $zero, $zero
	add $t2, $zero, $zero
	## Start main, then halt if we somehow return out
	jal __KMAIN
	
	j __HALT
	
		#nop # N(whatever): Padding instructions to align the ISR in the program to address 0x180
		nop # Note: Remove exactly one instruction for every instruction added above this comment!
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
	sw $ra, ISR00($zero) # N5: store the registers that I'm going to use to the stack
	sw $k1, ISR01($zero)
	sw $a0, ISR02($zero)
	sw $t0, ISR03($zero)
	
	sw $ra, 0x7FEF($zero)
	
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
		srl $k0, $k0, 0x8 # N3: Look at the interrupt flags
		addi $k1, $zero, 0xFF
		and $k0, $k1, $k0
		
		addi $k1, $zero, 0x80 # N4: Case HWINTR5 (also for next few blocks for different interrupts)
		add $a0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $a0, CASE_HWINTR5
		
		addi $k1, $zero, 0x40
		add $a0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $a0, CASE_HWINTR4
		
		addi $k1, $zero, 0x20
		add $a0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $a0, CASE_HWINTR3
		
		addi $k1, $zero, 0x10
		add $a0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $a0, CASE_HWINTR2
		
		addi $k1, $zero, 0x08
		add $a0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $a0, CASE_HWINTR1
		
		addi $k1, $zero, 0x04
		add $a0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $a0, CASE_HWINTR0 # TODO: Compare with zero incorrect, fix this
		
		addi $k1, $zero, 0x02
		add $a0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $a0, CASE_SWINTR1
		
		addi $k1, $zero, 0x01
		add $a0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $a0, CASE_SWINTR0
		
		j END_IS_INTR
		
		CASE_HWINTR5:
			jal PROC_INTR_HANDLE_TIMER
			j END_IS_INTR
		CASE_HWINTR4:
		CASE_HWINTR3:
		CASE_HWINTR2:
		CASE_HWINTR1:
			j END_IS_INTR # Hardware interrupts 1 through 4 ignored, simply reset them
		CASE_HWINTR0:
			jal PROC_INTR_HANDLE_AES
			j END_IS_INTR
		CASE_SWINTR1:
		CASE_SWINTR0:
			jal PROC_INTR_HANDLE_ACKBAR # Both traps handled by Adm. Ackbar
			j END_IS_INTR
	END_IS_INTR:
		jal PROC_RESET_INTR # Reset interrupt $a0
	OTHER_EXCP:
		# What do we want to do with other exceptions?

	lw $ra, ISR00($zero) # N5: store the registers that I'm going to use to the stack
	lw $k1, ISR01($zero)
	lw $a0, ISR02($zero)
	lw $t0, ISR03($zero)
	
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
	# Disable the timer
	addi $t0, $zero, 0xFF
	sll $t0, $t0, 0x8
	addi $t0, $t0, 0xFF
	sll $t0, $t0, 0x8
	addi $t0, $t0, 0xFF
	sll $t0, $t0, 0x8
	addi $t0, $t0, 0xFF
	mtc0 $t0, $22
	sw $zero, TEST_WORD($zero)
	
	addi $s0, $zero, 1 # Just a simple count by 5 to while away the time until I can properly implement this. Also tests memory manipulation.
	addi $t1, $zero, 0x8
WHILE_SCHED_SLICE:
	# This is an example of how to do a single compare conditional
	# If $s0 < $t1 then foo else bar
	slt $t0, $s0, $t1
	beq $t0, $zero, FOO
	BAR:	# Else BAR
		addi $s0, $s0, 0x1
		j END_FOO
	FOO:	# Then FOO
		lw $t1, TEST_WORD($zero)
		add $t1, $s0, $t1
		sw $t1, TEST_WORD($zero)
		add $s0, $zero, $zero
	END_FOO:
	
	j WHILE_SCHED_SLICE
	# Should not return out of main, but here for correctness:
	jr $ra


PROC_INTR_HANDLE_TIMER:
	# Handle the timer
	mtc0 $zero, $22
	jr $ra


PROC_INTR_HANDLE_ACKBAR:
	# It's a trap!
	push($t0)
	addi $t0, $zero, 0x1 # Signal that trap was received
	sw $t0, TRAP_SET($zero)
	pop($t0)
	jr $ra


PROC_INTR_HANDLE_AES:
	# Handle AES
	push($t0)
	addi $t0, $zero, 0x1 # Signal that AES is now complete
	sw $t0, AES_DONE($zero)
	nop
	pop($t0)
	jr $ra


__HALT:	# End of program
	j __HALT
