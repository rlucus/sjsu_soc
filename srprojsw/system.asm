##########################################################
# TEST KERNEL AND ISR
# 
# Author: Kai Wetlesen & Ryan Lucus
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
										# [xxxxxxxxx| 1 | 6543210 | 6543210 ]
	.eqv	SCHED_STATUS_INIT 0x6003	# [unused  |init|currTask |validTask]
	
	## Data Section
	# Note: Uncomment the include for the assembler file that 
	# corresponds to the environment you're running in.
	.include "mmap_hw.asm" # Memorpy map for the hardware
	.include "data.asm"
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
	jal __SCHEDULER_INIT
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
	jal __SCHEDULER
	lw $k0, ISRS0($zero)
	jr $k0

	jr $ra # Shouldn't go here
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
			sw $ra, ISRI2($zero)
			jal __SCHEDULER
			lw $ra, ISRI2($zero)
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


__SCHEDULER_INIT:
    #set PC, RA to first address
    addi $k1, $0, PCB_BASE0
    #addi $k0, $0, task0Start
	la $k0, task0Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 0
    #sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1) # $fp = last addr in task
    sw   $k0, PCB_SP_OFFSET($k1) # $sp = $fp

    addi $k1, $0, PCB_BASE1
    #addi $k0, $0, task1Start
	la $k0, task1Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 1
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE2
    #addi $k0, $0, task2Start
	la $k0, task2Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 2
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE3
    #addi $k0, $0, task3Start
	la $k0, task3Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 3
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE4
    #addi $k0, $0, task4Start
	la $k0, task4Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 4
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE5
    #addi $k0, $0, task5Start
	la $k0, task5Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 5
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE6
    #addi $k0, $0, task6Start
	la $k0, task6Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    sw $k0, ISRS0($0)  # should be first address of iMEM for task6
    sw $k0, ISRS1($0)  # this should be where INTR passes RA
    addi $k0, $0, 6
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    #set status register
    addi   $k0,  $0, SCHED_STATUS      # [xxxxxxxxx| 1 | 6543210 | 6543210 ]
    addi   $k1,  $0, SCHED_STATUS_INIT # [unused  |init|currTask |validTask]
    sw     $k1,  SCHED_STATUS($0)

    #jump sched
    j       __SCHEDULER   #DEBUG pick this line if using in test simulation
    #jr  $ra        #DEBUG pick this line if using in BootLoader

#DEBUG This section can be placed independent of the upper section in memory.
__SCHEDULER:
#
#
#
    sw $ra, SCHEDS1($0) #save current RA to 0x7ff0
    sw $k1, SCHEDS2($0)
    #sw $a0, 0x7ff2($0)
    sw $t0, SCHEDS3($0)

    addi $k0,  $0, SCHED_STATUS
    #sw $k0, 1($k0)
    #sw $v0, 2($k0)
    #sw $v1, 3($k0)
    #lw $v0, 0($k0) #load status register
    lw $31, 0($k0) #load status register

    #mask the status register to find the current task
    #addi $v1, $0, 1
    addi $8, $0, 1
    sll $8, $8, 7

    and $k0, $31, $8
    bne $k0, $0, caseShedTask0  #if (mask & statusReg != 0)

    sll $8, $8, 1
    and $k0, $31, $8
    bne $k0, $0, caseShedTask1    

    sll $8, $8, 1
    and $k0, $31, $8
    bne $k0, $0, caseShedTask2  

    sll $8, $8, 1
    and $k0, $31, $8
    bne $k0, $0, caseShedTask3  

    sll $8, $8, 1
    and $k0, $31, $8
    bne $k0, $0, caseShedTask4  

    sll $8, $8, 1
    and $k0, $31, $8
    bne $k0, $0, caseShedTask5

    sll $8, $8, 1
    and $k0, $31, $8
    bne $k0, $0, caseShedTask6


  # set k0 to base address of PCB for current task
  caseShedTask0:
    addi $k0, $0, PCB_BASE0
    b caseShedTaskEnd
  caseShedTask1:
    addi $k0, $0, PCB_BASE1
    b caseShedTaskEnd
  caseShedTask2:
    addi $k0, $0, PCB_BASE2
    b caseShedTaskEnd
  caseShedTask3:
    addi $k0, $0, PCB_BASE3
    b caseShedTaskEnd
  caseShedTask4:
    addi $k0, $0, PCB_BASE4
    b caseShedTaskEnd
  caseShedTask5:
    addi $k0, $0, PCB_BASE5
    b caseShedTaskEnd
  caseShedTask6:
    addi $k0, $0, PCB_BASE6

  caseShedTaskEnd:
    srl $8, $8, 8   #8 because I want it to be 0 if task0 is running
    addi $k1, $0, SCHED_STATUS
    sw $8, 4($k1)    #set aside current running task number for later

    # save all the registers into the PCB



    #mfc0 $v1, $14
    lw $8, ISRS0($0)
    sw $8, PCB_PC_OFFSET($k0) #PC saved into register 0 spot... 
    
    #lw $v0, PCB_V0_OFFSET($0)#recover clobbered regs from memory and load them first
    #lw $v1, PCB_V1_OFFSET($0)
    lw $ra, ISRS1($0) #retrieve passed RA from memory 0x7ee0 INTR passes here
    #lw $a0, ISRS2($0)
    lw $t0, ISRS3($0)
    #normal from here ($k0)

    sw $1,  PCB_AT_OFFSET($k0)
    sw $2,  PCB_V0_OFFSET($k0)
    sw $3,  PCB_V1_OFFSET($k0) 
    sw $4,  PCB_A0_OFFSET($k0)
    sw $5,  PCB_A1_OFFSET($k0)
    sw $6,  PCB_A2_OFFSET($k0)
    sw $7,  PCB_A3_OFFSET($k0)
    sw $8,  PCB_T0_OFFSET($k0)
    sw $9,  PCB_T1_OFFSET($k0)
    sw $10, PCB_T2_OFFSET($k0)
    sw $11, PCB_T3_OFFSET($k0)
    sw $12, PCB_T4_OFFSET($k0)
    sw $13, PCB_T5_OFFSET($k0)
    sw $14, PCB_T6_OFFSET($k0)
    sw $15, PCB_T7_OFFSET($k0)
    sw $16, PCB_S0_OFFSET($k0)
    sw $17, PCB_S1_OFFSET($k0)
    sw $18, PCB_S2_OFFSET($k0)
    sw $19, PCB_S3_OFFSET($k0)
    sw $20, PCB_S4_OFFSET($k0)
    sw $21, PCB_S5_OFFSET($k0)
    sw $22, PCB_S6_OFFSET($k0)
    sw $23, PCB_S7_OFFSET($k0)
    sw $24, PCB_T8_OFFSET($k0)
    sw $25, PCB_T9_OFFSET($k0) 
   #sw $26, PCB_K0_OFFSET($k0)
   #sw $27, PCB_K1_OFFSET($k0)
    sw $28, PCB_GP_OFFSET($k0)
    sw $29, PCB_SP_OFFSET($k0)
    sw $30, PCB_FP_OFFSET($k0)
    sw $31, PCB_RA_OFFSET($k0)



  #figure out next task
  addi $k1, $0, SCHED_STATUS
  lw $k0, 4($k1)  #last task
  lw $k1, 0($k1)  #status register

  beq $k0, $0, caseShedLast0
  srl $k0, $k0, 1
  beq $k0, $0, caseShedLast1
  srl $k0, $k0, 1
  beq $k0, $0, caseShedLast2
  srl $k0, $k0, 1
  beq $k0, $0, caseShedLast3
  srl $k0, $k0, 1
  beq $k0, $0, caseShedLast4
  srl $k0, $k0, 1
  beq $k0, $0, caseShedLast5
  srl $k0, $k0, 1
  beq $k0, $0, caseShedLast6


  caseShedLast0: #if (last=0 && 1.isValid) then next = 1 else keep going
    addi $k0, $0, 2
    and $k0, $k0, $k1
    bne $k0, $0, caseShedNext1
  caseShedLast1:
    addi $k0, $0, 4    #2^next
    and $k0, $k0, $k1
    bne $k0, $0, caseShedNext2
  caseShedLast2:
    addi $k0, $0, 8
    and $k0, $k0, $k1
    bne $k0, $0, caseShedNext3
  caseShedLast3:
    addi $k0, $0, 16
    and $k0, $k0, $k1
    bne $k0, $0, caseShedNext4
  caseShedLast4:
    addi $k0, $0, 32
    and $k0, $k0, $k1
    bne $k0, $0, caseShedNext5
  caseShedLast5:
    addi $k0, $0, 64
    and $k0, $k0, $k1
    bne $k0, $0, caseShedNext6
  caseShedLast6:
    addi $k0, $0, 1
    and $k0, $k0, $k1
    bne $k0, $0, caseShedNext0

  b caseShedLast0 #circular list


#setup loading next task
  caseShedNext0:
    addi $k0, $0, PCB_BASE0
    b caseShedNextEnd
  caseShedNext1:
    addi $k0, $0, PCB_BASE1
    b caseShedNextEnd
  caseShedNext2:
    addi $k0, $0, PCB_BASE2
    b caseShedNextEnd
  caseShedNext3:
    addi $k0, $0, PCB_BASE3
    b caseShedNextEnd
  caseShedNext4:
    addi $k0, $0, PCB_BASE4
    b caseShedNextEnd
  caseShedNext5:
    addi $k0, $0, PCB_BASE5
    b caseShedNextEnd
  caseShedNext6:
    addi $k0, $0, PCB_BASE6

  caseShedNextEnd:


#determine if this is the initial run
#k1 = statusReg, #k0 = PCB of next task
  addi $8, $0, 1
  sll $8, $8, 14  #location of init bit in status register
  and $31, $k1, $8
  beq $31, $0 finishSchedUp

  #clear first bit
  addi $31, $0, 0xFFFF
  xor $8, $8, $31 #inverse mask
  and $k1, $8, $k1
  sw $k1, SCHED_STATUS($0)
  
  #place imem start address into 
  #addi $31, $0, task0Start 
  la $31, task0Start
  sw $31, SCHEDS1($0)

  finishSchedUp:
#load next task
    lw $k1, PCB_PC_OFFSET($k0)
   #mtc0 $k1, $14 #PC goes into cp0    
    sw $k1, ISRS0($0)
    lw $1,  PCB_AT_OFFSET($k0)
    lw $2,  PCB_V0_OFFSET($k0)
    lw $3,  PCB_V1_OFFSET($k0)
    lw $4,  PCB_A0_OFFSET($k0)
    lw $5,  PCB_A1_OFFSET($k0)
    lw $6,  PCB_A2_OFFSET($k0)
    lw $7,  PCB_A3_OFFSET($k0)
    lw $8,  PCB_T0_OFFSET($k0)
    lw $9,  PCB_T1_OFFSET($k0)
    lw $10, PCB_T2_OFFSET($k0)
    lw $11, PCB_T3_OFFSET($k0)
    lw $12, PCB_T4_OFFSET($k0)
    lw $13, PCB_T5_OFFSET($k0)
    lw $14, PCB_T6_OFFSET($k0)
    lw $15, PCB_T7_OFFSET($k0)
    lw $16, PCB_S0_OFFSET($k0)
    lw $17, PCB_S1_OFFSET($k0)
    lw $18, PCB_S2_OFFSET($k0)
    lw $19, PCB_S3_OFFSET($k0)
    lw $20, PCB_S4_OFFSET($k0)
    lw $21, PCB_S5_OFFSET($k0)
    lw $22, PCB_S6_OFFSET($k0)
    lw $23, PCB_S7_OFFSET($k0)
    lw $24, PCB_T8_OFFSET($k0)
    lw $25, PCB_T9_OFFSET($k0)
  # lw $25, PCB_K0_OFFSET($k0)
  # lw $25, PCB_K1_OFFSET($k0)
    lw $28, PCB_GP_OFFSET($k0)
    lw $29, PCB_SP_OFFSET($k0)
    lw $30, PCB_FP_OFFSET($k0)

    #ra, t0 comes from PCB and goes into 0x7ee0
    lw $31, PCB_RA_OFFSET($k0)
    sw $31, ISRS1($0)
    #sw $27,  ISRS2($0)
    sw $8,  ISRS3($0)

    lw $ra, SCHEDS1($0) #retrieve regs from beggining
    lw $k1, SCHEDS2($0)
    lw $t0, SCHEDS3($0)

  jr $ra


nop # N10: NOPs for sanity (or so I can find this task in the machine code)
nop
nop
nop
nop
nop
nop
nop
nop
nop

## TASK 1: Calculate Fibonacci numbers.
# Compute first twelve Fibonacci numbers and put in array, then print
task0Start:
PROC_TASK_FIBONACCI:
      addi $t0, $zero, fibs # load address of array
      addi $t5, $zero, 12   # load array size
      addi $t2, $zero, 1    # 0 and 1 are the first and second Fib. numbers
      sw   $zero, 0($t0)    # F[0] = 0
      sw   $t2, 4($t0)      # F[1] = F[0] = 1
      addi $t1, $t5, -2     # Counter for loop, will execute (size-2) times
loop: lw   $t3, 0($t0)      # Get value from array F[n] 
      lw   $t4, 4($t0)      # Get value from array F[n+1]
      add  $t2, $t3, $t4    # $t2 = F[n] + F[n+1]
      sw   $t2, 8($t0)      # Store F[n+2] = F[n] + F[n+1] in array
      addi $t0, $t0, 4      # increment address of Fib. number source
      addi $t1, $t1, -1     # decrement loop counter
      bne  $t1, $zero, loop # repeat if not finished yet.
beq $zero, $zero, PROC_TASK_FIBONACCI # Keep running the task forever
# End Task Fibonacci

nop # N10: NOPs for sanity (or so I can find this task in the machine code)
nop
nop
nop
nop
nop
nop
nop
nop
nop

task1Start:
PROC_TASK_AES:
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
	mtc0 $t1, $0
	 
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
	mtc0 $t1, $0
	 
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
	
	beq $zero, $zero, PROC_TASK_AES
	jr $ra
## End AES Task

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

## Trying to start these tasks will halt the CPU. If you want to use these tasks 
## then take a label and position it above your task and adjust the scheduler config.
task2Start:
task3Start:
task4Start:
task5Start:
task6Start:
## Cattle catcher. This should be somewhere down around line 1330 (whitespace and comments depending). Pad this down with no-ops
__HALT:	# End of program
	j __HALT
