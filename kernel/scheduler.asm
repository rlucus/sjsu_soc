  .text
schedInit:
    addi   $fp,	$0,	0x7fff

  #load base addresses into memory
    addi   $k0,  $0, 0x7f00

  beginFor:  
    slti    $k1,	$k0,	7 # i < 7
    beq     $k1,	$0,	endFor #break For Loop

    #k0 =i
    addi $k1,  $sp,  $k0 #k1 = &task[i]
    lw $v0, 0($k1)

    sll $v1, $k0, 8  
    ori $v1, $v1, 0x1000    #task[i] iMem baseAddr
    sw $v1, 1($v0)          #pc
    sw $v1, 31($v0)         #setup $ra = baseAddr 

    sll $v1, $k0, 12  #task[i] dMem baseAddr
    ori $v1, $v1, 0x0FFF  
    sw $v1, 30($v0)         # $fp = last addr in task
    sw $v1, 29($v0)         # $sp = $fp

    addi   $k0,	$k0,	1
    b       beginFor

  endFor:
    #setup cp0 to make scheduler simpler
    addi    $k0,	 $0,	 0x1600 # should be first address of iMEM for task6
    mtc0    $k0,	 $14

    addi $k1, $0, 0x7ee0  
    sw $k0, 0($k1)  # this should be where INTR passes RA

    #addi $k0, $0, 0x7f00 #TODO should be first address of task0???
    #sw $k0, 0($k1)


    #set status register
    addi   $k0,  $0, 0x7fe0    #  [xxxxxxxxx| 1 | 6543210 | 6543210 ]
    addi   $k1,  $0, 0x6003    #  [unused  |init|currTask | validTask ]
    sw      $k1,  0($k0)

    #jump sched
    b       sched


sched:
#TODO: check the return address location
#
#
    sw $ra, 0x7ff0($0) #save current RA to 0x7ff0
    sw $k1, 0x7ff1($0)
    sw $a0, 0x7ff2($0)
    sw $t0, 0x7ff3($0)

    addi $k1,  $0, 0x7fe0 #working space
    sw $k0, 1($k1)
    sw $v0, 2($k1)
    sw $v1, 3($k1)
    lw $v0, 0($k1) #load status register

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
    addi $k0, $0, 0x7f00
    b caseTaskEnd
  caseTask1:
    addi $k0, $0, 0x7f20
    b caseTaskEnd
  caseTask2:
    addi $k0, $0, 0x7f40
    b caseTaskEnd
  caseTask3:
    addi $k0, $0, 0x7f60
    b caseTaskEnd
  caseTask4:
    addi $k0, $0, 0x7f80
    b caseTaskEnd
  caseTask5:
    addi $k0, $0, 0x7fA0
    b caseTaskEnd
  caseTask6:
    addi $k0, $0, 0x7fC0

  caseTaskEnd:
    srl $v1, $v1, 8   #8 because I want it to be 0 if task0 is running
    sw $v1, 5($k1)    #set aside current running task number for later

    # save all the registers into the PCB

    lw $ra, 0x7ee0($0) #retrieve passed RA from memory 0x7ee0 INTR passes here
    lw $a0, 0x7ee2($0)
    lw $t0, 0x7ee3($0)

    mfc0 $v1, $14
    sw $v1, 0($k0) #PC saved into register 0 spot... 
    lw $v0, 2($k1)#recover clobbered regs from memory and load them first
    lw $v1, 3($k1)

    #normal from here
    sw $1, 1($k0)
    sw $2, 2($k0)
    sw $3, 3($k0) 
    sw $4, 4($k0)
    sw $5, 5($k0)
    sw $6, 6($k0)
    sw $7, 7($k0)
    sw $8, 8($k0)
    sw $9, 9($k0)
    sw $10, 10($k0)
    sw $11, 11($k0)
    sw $12, 12($k0)
    sw $13, 13($k0)
    sw $14, 14($k0)
    sw $15, 15($k0)
    sw $16, 16($k0)
    sw $17, 17($k0)
    sw $18, 18($k0)
    sw $19, 19($k0)
    sw $20, 20($k0)
    sw $21, 21($k0)
    sw $22, 22($k0)
    sw $23, 23($k0)
    sw $24, 24($k0)
    sw $25, 25($k0) #skip 26,27 because they are kernal registers only
    sw $28, 28($k0)
    sw $29, 29($k0)
    sw $30, 30($k0)
    sw $31, 31($k0)



  #figure out next task
  addi $k1, $0, 0x7fe0
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
    addi $k0, $0, 0x7f00
    b caseNextEnd
  caseNext1:
    addi $k0, $0, 0x7f20
    b caseNextEnd
  caseNext2:
    addi $k0, $0, 0x7f40
    b caseNextEnd
  caseNext3:
    addi $k0, $0, 0x7f60
    b caseNextEnd
  caseNext4:
    addi $k0, $0, 0x7f80
    b caseNextEnd
  caseNext5:
    addi $k0, $0, 0x7fA0
    b caseNextEnd
  caseNext6:
    addi $k0, $0, 0x7fC0

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
    lw $k1, 0($k0)
    mtc0 $k1, $14 #PC goes into cp0

    lw $1, 1($k0)
    lw $2, 2($k0)
    lw $3, 3($k0)
    lw $4, 4($k0)
    lw $5, 5($k0)
    lw $6, 6($k0)
    lw $7, 7($k0)
    lw $8, 8($k0)
    lw $9, 9($k0)
    lw $10, 10($k0)
    lw $11, 11($k0)
    lw $12, 12($k0)
    lw $13, 13($k0)
    lw $14, 14($k0)
    lw $15, 15($k0)
    lw $16, 16($k0)
    lw $17, 17($k0)
    lw $18, 18($k0)
    lw $19, 19($k0)
    lw $20, 20($k0)
    lw $21, 21($k0)
    lw $22, 22($k0)
    lw $23, 23($k0)
    lw $24, 24($k0)
    lw $25, 25($k0)
    lw $28, 28($k0)
    lw $29, 29($k0)
    lw $30, 30($k0)

    #ra, a0, t0 comes from PCB and goes into 0x7ee0
    lw $31, 31($k0)
    sw $31, 0x7ee0($0)
    sw $4,  0x7ee2($0)
    sw $8,  0x7ee3($0)

    lw $ra, 0x7ff0($0) #retrieve regs from beggining
    lw $k1, 0x7ff1($0)
    lw $a0, 0x7ff2($0)
    lw $t0, 0x7ff3($0)

  jr $ra