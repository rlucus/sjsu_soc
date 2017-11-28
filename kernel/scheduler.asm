.include "mm_marssim.asm"  #DEBUG remove after testing

.eqv  SCHED_STATUS_INIT 0x6003

  .text
__SCHEDULER_INIT:
    #set PC, RA to first address
    addi $k1, $0, PCB_BASE0
    addi $k0, $0, task0Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 0
    #sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1) # $fp = last addr in task
    sw   $k0, PCB_SP_OFFSET($k1) # $sp = $fp

    addi $k1, $0, PCB_BASE1
    addi $k0, $0, task1Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 1
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE2
    addi $k0, $0, task2Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 2
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE3
    addi $k0, $0, task3Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 3
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE4
    addi $k0, $0, task4Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 4
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE5
    addi $k0, $0, task5Start
    sw $k0, PCB_PC_OFFSET($k1)
    sw $k0, PCB_RA_OFFSET($k1)
    addi $k0, $0, 5
    sll  $k0, $k0, 12
    ori  $k0, $k0, dMEM_END_MASK
    sw   $k0, PCB_FP_OFFSET($k1)
    sw   $k0, PCB_SP_OFFSET($k1)

    addi $k1, $0, PCB_BASE6
    addi $k0, $0, task6Start
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
  addi $31, $0, task0Start 
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
