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

	.macro append_intr_flag_mask(%reg)
	# Basically this macro does this:
	#sll %reg, %reg,  0x10
	#addi %reg, %reg, 0x8501
	# This also holds the processor in kernel mode and normal level (see KSU, ERL, and EXL)
	sll %reg, %reg, 0x8
	addi %reg, %reg, 0x95 # Enable interrupts 5, 2, and 0
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
	sw $t0, TEST_WORD($zero)
	add $t1, $zero, $zero
	lw $t1, TEST_WORD($zero)
	slt $t2, $t0, $t1
	beq $t2, $zero, MEMIO_TEST_OK
	j __HALT # Load/Store test failed, we're dead
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
	

		nop # N(whatever): Padding instructions to align the ISR in the program to address 0x180
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
		
###################################################### 
# X180 Handler
# 
# Handles exceptions and interrupts asynchronously
# sent by the CPU then defers to interrupt processor.
# 
# Note: This routine must be positioned at ROM 
#       address 0x180 per MIPS documentation.
# 
# WARNING: This routine is exceptionally delicate!
# Any registers that are touched must be stored in 
# an ISR Shared location so that the scheduler can
# capture valid process values instead of ISR garbage.
######################################################

__X180_HANDLER: ## Regs clobbered: K0
	mfc0 $k0, $14 # N2: Grab the address of the interrupted instruction to memory
	sw $k0, ISRS0($zero)
	sw $ra, ISRS1($zero) # N2: store the registers that I'm going to use to memory
	sw $k1, ISRS2($zero)
	
	mfc0 $k0, $13 # N2: Grab the interrupt statuses to memory
	sw $k0, ISRI0($zero)

	mfc0 $k0, $12 # N8: Acknowledge all interrupts and turn off master flag
	addi $k1, $zero, 0xFFF
	sll $k1, $k1, 0xC
	addi $k1, $k1, 0xF00
	sll $k1, $k1, 0x8
	addi $k1, $k1, 0xFE
	and $k0, $k1, $k0
	mtc0 $k0, $12

	jal PROC_INTR_PROCESS

	mfc0 $k1, $12
	add $k0, $zero, $zero
	append_intr_flag_mask($k0) # N2: Reset all interrupts
	or $k1, $k0, $k1
	mtc0 $k1, $12 # Set new register value

	lw $k1, ISRS2($zero) # N2: restore the registers I used
	lw $ra, ISRS1($zero)
	lw $k0, ISRS0($zero) # N2: return to whence we've interrupted
	jr $k0
# End ISR


		nop # N8: Padding instructions to separate ISR from main line code (not really needed, discard if space gets short)
		nop # Note: You need these if you see your code show up in X200!!!! You've been warned!!!!!
		nop
		nop
		nop
		nop
		nop
		nop


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
		beq $zero, $zero, END_FOO
	FOO:	# Then FOO
		lw $t1, TEST_WORD($zero)
		add $t1, $s0, $t1
		sw $t1, TEST_WORD($zero)
		add $s0, $zero, $zero
	END_FOO:
	
	beq $zero, $zero, WHILE_SCHED_SLICE
	# Should not return out of main, but here for correctness:
	jr $ra
# End __KMAIN

#################################################
# Procedure: Interrupt Processor
# 
# Routes interrupts to appropriate processing 
# routines and (for now) stores other exceptions 
# to memory location EXCP_CODE for OS processing.
#################################################

## Interrupt processor. This is called by the X180 handler!
PROC_INTR_PROCESS:
	sw $t0, ISRS3($zero) # Save $t0 to RAM, I need it

	lw $k0, ISRI0($zero) # Load interrupt status to memory (Note: CP0/R13 no longer viable as interrupts reset)
	addi $k1, $zero, 0x007C # N2: Mask out everything except exception code
	and  $k1, $k0, $k1
	srl $k1, $k1, 0x2
	sw  $k1, EXCP_CODE($zero) # Store it to memory
	
	beq $k1, $zero, IS_INTR # Would do a bne here, but not available in the arch, hence this skip-step if
	beq $zero, $zero, OTHER_EXCP
	IS_INTR:

		srl $k0, $k0, 0x8 # N3: Look at the interrupt flags
		addi $k1, $zero, 0xFF
		and $k0, $k1, $k0
		
		addi $k1, $zero, 0x80 # N4: Case HWINTR5 (also for next few blocks for different interrupts)
		add $t0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $t0, CASE_HWINTR5
		
		addi $k1, $zero, 0x40
		add $t0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $t0, CASE_HWINTR4
		
		addi $k1, $zero, 0x20
		add $t0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $t0, CASE_HWINTR3
		
		addi $k1, $zero, 0x10
		add $t0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $t0, CASE_HWINTR2
		
		addi $k1, $zero, 0x08
		add $t0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $t0, CASE_HWINTR1
		
		addi $k1, $zero, 0x04
		add $t0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $t0, CASE_HWINTR0 # TODO: Compare with zero incorrect, fix this (fixed)
		
		addi $k1, $zero, 0x02
		add $t0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $t0, CASE_SWINTR1
		
		addi $k1, $zero, 0x01
		add $t0, $zero, $k1
		and $k1, $k0, $k1
		beq $k1, $t0, CASE_SWINTR0
		
		beq $zero, $zero, END_IS_INTR
		
		CASE_HWINTR5: # Pet the timer then defer to the scheduler
			mtc0 $zero, $22
			beq $zero, $zero, END_IS_INTR
		CASE_HWINTR4: # Store A0 which corresponds to the fired interrupt
		CASE_HWINTR3:
		CASE_HWINTR2:
		CASE_HWINTR1:
			sw $t0, OTHER_INTR($zero)
			beq $zero, $zero, END_IS_INTR # Hardware interrupts 1 through 4 ignored, simply note and reset them
		CASE_HWINTR0:
			sw $t0, AES_DONE($zero) # Signal that AES is now complete (make sure A0 has 1 in it!)
			nop # Why did I put this here? I'll keep it for now . . .
			beq $zero, $zero, END_IS_INTR
		CASE_SWINTR1:
			addi $t0, $zero, 0x11
			sw $t0, TRAP_SET($zero)
			beq $zero, $zero, END_IS_INTR
		CASE_SWINTR0: # Any traps noted down by Adm. Ackbar
			addi $t0, $zero, 0x10
			sw $t0, TRAP_SET($zero)
			beq $zero, $zero, END_IS_INTR
	## Exception Handling: At this time, we simply skip the instruction that screwed up. Should do something more intelligent someday.
	OTHER_EXCP:
		lw $k0, ISRS0($zero)
		addi $k0, $k0, 0x4 # Skip offending instruction (ref: http://www.cs.uwm.edu/classes/cs315/Bacon/Lecture/HTML/ch15s10.html)
		sw $k0, ISRS0($zero)
	END_IS_INTR:

	lw $t0, ISRS3($zero) # Restore $t0 from RAM
	jr $ra


__HALT:	# End of program
	j __HALT
