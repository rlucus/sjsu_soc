	.eqv	PCB_BASE0	0x2F00
	.eqv	PCB_BASE1	0x2F20
	.eqv	PCB_BASE2	0x2F40
	.eqv	PCB_BASE3	0x2F60
	.eqv	PCB_BASE4	0x2F80
	.eqv	PCB_BASE5	0x2FA0
	.eqv	PCB_BASE6	0x2FC0
	.eqv	SCHED_STATUS	0x7FE0
	.eqv	iMEM_BASE_MASK	0x1000
	.eqv	dMEM_END_MASK	0x0FFF

	.eqv	SCHEDS0	0x7FF0 # CP0/R14 - Interrupted Instruction
	.eqv	SCHEDS1	0x7FF4 # $ra - Return address of interrupted proc
	.eqv	SCHEDS2	0x7FF8 # $k1 - Kernel register
	.eqv	SCHEDS3	0x7FFC # $t0 - Temporary register 0
	
  	.eqv	ISRS0	0x7EE0 # CP0/R14 - Interrupted Instruction
	.eqv	ISRS1	0x7EE4 # $ra - Return address of interrupted proc
	.eqv	ISRS2	0x7EE8 # $k1 - Kernel register
	.eqv	ISRS3	0x7EEC # $t0 - Temporary register 0
	
		.eqv	PCB_PC_OFFSET	0
	.eqv	PCB_AT_OFFSET	4
	.eqv	PCB_V0_OFFSET	8
	.eqv	PCB_V1_OFFSET	12
	.eqv	PCB_A0_OFFSET	16
	.eqv	PCB_A1_OFFSET	20
	.eqv	PCB_A2_OFFSET	24
	.eqv	PCB_A3_OFFSET	28
	.eqv	PCB_T0_OFFSET	32
	.eqv	PCB_T1_OFFSET	36
	.eqv	PCB_T2_OFFSET	40
	.eqv	PCB_T3_OFFSET	44
	.eqv	PCB_T4_OFFSET	48
	.eqv	PCB_T5_OFFSET	52
	.eqv	PCB_T6_OFFSET	56
	.eqv	PCB_T7_OFFSET	60
	.eqv	PCB_S0_OFFSET	64
	.eqv	PCB_S1_OFFSET	68
	.eqv	PCB_S2_OFFSET	72
	.eqv	PCB_S3_OFFSET	76
	.eqv	PCB_S4_OFFSET	80
	.eqv	PCB_S5_OFFSET	84
	.eqv	PCB_S6_OFFSET	88
	.eqv	PCB_S7_OFFSET	92
	.eqv	PCB_T8_OFFSET	96
	.eqv	PCB_T9_OFFSET	100
	.eqv	PCB_K0_OFFSET	104
	.eqv	PCB_K1_OFFSET	108
	.eqv	PCB_GP_OFFSET	112
	.eqv	PCB_SP_OFFSET	116
	.eqv	PCB_FP_OFFSET	120
	.eqv	PCB_RA_OFFSET	124


  .text
schedInit:
    #addi   $fp,	$0,	0x7fff

  #load base addresses into memory
    #addi   $k0,  $0, 0x7f00

    add $k0, $0, $0 #i = 0

  beginFor:  
    slti    $k1,	$k0,	7 # i < 7
    beq     $k1,	$0,	endFor #break For Loop

    #k0 =i
    addi $k1,  $0,  PCB_BASE0 
    sll $v0,  $k0,  5
    or  $v0, $v0, $k1 

    #k1 = &task[i]
    #lw $v0, 0($k1)


    sll $v1, $k0, 8  
    ori $v1, $v1, iMEM_BASE_MASK    #task[i] iMem baseAddr

    sw $v1, PCB_PC_OFFSET($v0)          #pc
    sw $v1, PCB_RA_OFFSET($v0)         #setup $ra = baseAddr 

    sll $v1, $k0, 12  #task[i] dMem baseAddr
    ori $v1, $v1, dMEM_END_MASK  
    sw $v1, PCB_FP_OFFSET($v0)         # $fp = last addr in task
    sw $v1, PCB_SP_OFFSET($v0)         # $sp = $fp

    addi   $k0,	$k0,	1
    j beginFor

  endFor:
    #setup cp0 to make scheduler simpler
    addi    $k0,	 $0,	 0x1600 # should be first address of iMEM for task6
    #mtc0    $k0,	 $14
    sw $k0, ISRS0($0)
    #addi $k1, $0, 0x7ee0  
    sw $k0, ISRS1($0)  # this should be where INTR passes RA

    #addi $k0, $0, 0x7f00 #TODO should be first address of task0???
    #sw $k0, 0($k1)


    #set status register
    addi   $k0,  $0, SCHED_STATUS    #  [xxxxxxxxx| 1 | 6543210 | 6543210 ]
    addi   $k1,  $0, 0x6003    #  [unused  |init|currTask | validTask ]
    sw      $k1,  SCHED_STATUS($0)

    #jump sched
    j       sched


sched:
#TODO: check the return address location
#
#
    sw $ra, 0x7ff0($0) #save current RA to 0x7ff0
    sw $k1, 0x7ff1($0)
    sw $a0, 0x7ff2($0)
    sw $t0, 0x7ff3($0)

    addi $k0,  $0, SCHED_STATUS #working space
    sw $k0, 1($k0)
    sw $v0, 2($k0)
    sw $v1, 3($k0)
    lw $v0, 0($k0) #load status register

    #mask the status register to find the current task
    addi $v1, $0, 1
    sll $v1, $v1, 7

    and $k0, $v0, $v1
    bne $k0, $0, caseTask0  #if (mask & statusReg != 0)

    sll $v1, $v1, 1
    and $k0, $v0, $v1
    bne $k0, $0, caseTask1    

    sll $v1, $v1, 1
    and $k0, $v0, $v1
    bne $k0, $0, caseTask2  

    sll $v1, $v1, 1
    and $k0, $v0, $v1
    bne $k0, $0, caseTask3  

    sll $v1, $v1, 1
    and $k0, $v0, $v1
    bne $k0, $0, caseTask4  

    sll $v1, $v1, 1
    and $k0, $v0, $v1
    bne $k0, $0, caseTask5

    sll $v1, $v1, 1
    and $k0, $v0, $v1
    bne $k0, $0, caseTask6


  # set k0 to base address of PCB for current task
  caseTask0:
    addi $k0, $0, PCB_BASE0
    b caseTaskEnd
  caseTask1:
    addi $k0, $0, PCB_BASE1
    b caseTaskEnd
  caseTask2:
    addi $k0, $0, PCB_BASE2
    b caseTaskEnd
  caseTask3:
    addi $k0, $0, PCB_BASE3
    b caseTaskEnd
  caseTask4:
    addi $k0, $0, PCB_BASE4
    b caseTaskEnd
  caseTask5:
    addi $k0, $0, PCB_BASE5
    b caseTaskEnd
  caseTask6:
    addi $k0, $0, PCB_BASE6

  caseTaskEnd:
    srl $v1, $v1, 8   #8 because I want it to be 0 if task0 is running
    sw $v1, 5($k1)    #set aside current running task number for later

    # save all the registers into the PCB

    lw $ra, ISRS1($0) #retrieve passed RA from memory 0x7ee0 INTR passes here
    #lw $a0, ISRS2($0)
    lw $t0, ISRS3($0)

    #mfc0 $v1, $14
    lw $v1, ISRS0($0)
    sw $v1, PCB_PC_OFFSET($k0) #PC saved into register 0 spot... 
    
    lw $v0, PCB_V0_OFFSET($k1)#recover clobbered regs from memory and load them first
    lw $v1, PCB_V1_OFFSET($k1)

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
  lw $k0, 5($k1)  #last task
  lw $k1, 0($k1)  #status register

  beq $k0, $0, caseLast0
  srl $k0, $k0, 1
  beq $k0, $0, caseLast1
  srl $k0, $k0, 1
  beq $k0, $0, caseLast2
  srl $k0, $k0, 1
  beq $k0, $0, caseLast3
  srl $k0, $k0, 1
  beq $k0, $0, caseLast4
  srl $k0, $k0, 1
  beq $k0, $0, caseLast5
  srl $k0, $k0, 1
  beq $k0, $0, caseLast6


  caseLast0: #if (last=0 && 1.isValid) then next = 1 else keep going
    addi $k0, $0, 2
    and $k0, $k0, $k1
    bne $k0, $0, caseNext1
  caseLast1:
    addi $k0, $0, 4    #2^next
    and $k0, $k0, $k1
    bne $k0, $0, caseNext2
  caseLast2:
    addi $k0, $0, 8
    and $k0, $k0, $k1
    bne $k0, $0, caseNext3
  caseLast3:
    addi $k0, $0, 16
    and $k0, $k0, $k1
    bne $k0, $0, caseNext4
  caseLast4:
    addi $k0, $0, 32
    and $k0, $k0, $k1
    bne $k0, $0, caseNext5
  caseLast5:
    addi $k0, $0, 64
    and $k0, $k0, $k1
    bne $k0, $0, caseNext6
  caseLast6:
    addi $k0, $0, 1
    and $k0, $k0, $k1
    bne $k0, $0, caseNext0

  b caseLast0 #circular list


#setup loading next task
  caseNext0:
    addi $k0, $0, PCB_BASE0
    b caseNextEnd
  caseNext1:
    addi $k0, $0, PCB_BASE1
    b caseNextEnd
  caseNext2:
    addi $k0, $0, PCB_BASE2
    b caseNextEnd
  caseNext3:
    addi $k0, $0, PCB_BASE3
    b caseNextEnd
  caseNext4:
    addi $k0, $0, PCB_BASE4
    b caseNextEnd
  caseNext5:
    addi $k0, $0, PCB_BASE5
    b caseNextEnd
  caseNext6:
    addi $k0, $0, PCB_BASE6

  caseNextEnd:

#TODO might not need whole section
#determine if this is the initial run
#k1 = statusReg, #k0 = PCB of next task
  #addi $v0, $0, 1
  #sll $v0, $v0, 14  #location of init bit in status register
  #and $v0, $k1, $v0
 # beq $v0, $0 finishUp
  #TODO setup init maybe don't need...
  #place imem start address into 
  #TODO clear init bit

  finishUp:
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

    #ra, a0, t0 comes from PCB and goes into 0x7ee0
    lw $31, PCB_RA_OFFSET($k0)
    sw $31, ISRS1($0)
    #sw $27,  ISRS2($0)
    sw $8,  ISRS3($0)

    lw $ra, SCHEDS1($0) #retrieve regs from beggining
    lw $k1, SCHEDS2($0)
    lw $t0, SCHEDS3($0)

  jr $ra
