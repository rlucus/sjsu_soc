 Address    Code        Basic                     Source

# Begin init
0x00000000  0x00000820  add $1,$0,$0          62       add $at, $zero, $zero # N29: Initialize all the registers to zero (solves weird bugs that came up in the hardware simulator)
0x00000004  0x00001020  add $2,$0,$0          63       add $v0, $zero, $zero # Note: T0, T1, and T2 initialized after memory test routine because they're used in the test
0x00000008  0x00001820  add $3,$0,$0          64       add $v1, $zero, $zero
0x0000000c  0x00002020  add $4,$0,$0          65       add $a0, $zero, $zero
0x00000010  0x00002820  add $5,$0,$0          66       add $a1, $zero, $zero
0x00000014  0x00003020  add $6,$0,$0          67       add $a2, $zero, $zero
0x00000018  0x00003820  add $7,$0,$0          68       add $a3, $zero, $zero
0x0000001c  0x00005820  add $11,$0,$0         69       add $t3, $zero, $zero
0x00000020  0x00006020  add $12,$0,$0         70       add $t4, $zero, $zero
0x00000024  0x00006820  add $13,$0,$0         71       add $t5, $zero, $zero
0x00000028  0x00007020  add $14,$0,$0         72       add $t6, $zero, $zero
0x0000002c  0x00007820  add $15,$0,$0         73       add $t7, $zero, $zero
0x00000030  0x00008020  add $16,$0,$0         74       add $s0, $zero, $zero
0x00000034  0x00008820  add $17,$0,$0         75       add $s1, $zero, $zero
0x00000038  0x00009020  add $18,$0,$0         76       add $s2, $zero, $zero
0x0000003c  0x00009820  add $19,$0,$0         77       add $s3, $zero, $zero
0x00000040  0x0000a020  add $20,$0,$0         78       add $s4, $zero, $zero
0x00000044  0x0000a820  add $21,$0,$0         79       add $s5, $zero, $zero
0x00000048  0x0000b020  add $22,$0,$0         80       add $s6, $zero, $zero
0x0000004c  0x0000b820  add $23,$0,$0         81       add $s7, $zero, $zero
0x00000050  0x0000c020  add $24,$0,$0         82       add $t8, $zero, $zero
0x00000054  0x0000c820  add $25,$0,$0         83       add $t9, $zero, $zero
0x00000058  0x0000d020  add $26,$0,$0         84       add $k0, $zero, $zero
0x0000005c  0x0000d820  add $27,$0,$0         85       add $k1, $zero, $zero
0x00000060  0x0000e020  add $28,$0,$0         86       add $gp, $zero, $zero
0x00000064  0x0000e820  add $29,$0,$0         87       add $sp, $zero, $zero
0x00000068  0x0000f020  add $30,$0,$0         88       add $fp, $zero, $zero
0x0000006c  0x0000f820  add $31,$0,$0         89       add $ra, $zero, $zero
0x00000070  0x20081f3a  addi $8,$0,0x00001f3a 91       addi $t0, $zero 0x1F3A # N7: memory I/O test instructions
0x00000074  0xac087030  sw $8,0x00007030($0)  92       sw $t0, 0x7030($zero)
0x00000078  0x00004820  add $9,$0,$0          93       add $t1, $zero, $zero
0x0000007c  0x8c097030  lw $9,0x00007030($0)  94       lw $t1, 0x7030($zero)
0x00000080  0x0109502a  slt $10,$8,$9         95       slt $t2, $t0, $t1
0x00000084  0x11400001  beq $10,$0,0x00000001 96       beq $t2, $zero, MEMIO_TEST_OK
0x00000088  0x080003fe  j 0x00000ff8          97       j __HALT # Load/Store test failed, we're dead
0x0000008c  0x20095000  addi $9,$0,0x00005000 101      addi $t1, $zero, 0x5000 # N3: Enable interrupts, CP0, and CP2
0x00000090  0x00094a00  sll $9,$9,0x00000008  102  <33> sll $t1, $t1, 0x8
0x00000094  0x21290095  addi $9,$9,0x00000095 102  <34> addi $t1, $t1, 0x95 # Enable interrupts 5, 2, and 0
0x00000098  0x00094a00  sll $9,$9,0x00000008  102  <35> sll $t1, $t1, 0x8
0x0000009c  0x21290001  addi $9,$9,0x00000001 102  <36> addi $t1, $t1, 0x01 # Enable master interrupt flag and sets KSU, ERL, and EXL
0x000000a0  0x40806000  mtc0 $0,$12           103      mtc0 $zero, $12 # BUG FIX: CP0/R12 not zeroing correctly
0x000000a4  0x40896000  mtc0 $9,$12           104      mtc0 $t1, $12
0x000000a8  0x40806800  mtc0 $0,$13           105      mtc0 $zero, $13 # N2: Init the other registers to zero
0x000000ac  0x40807000  mtc0 $0,$14           106      mtc0 $zero, $14
0x000000b0  0x201d003f  addi $29,$0,0x0000003f108      addi $sp, $zero, 0x3F # N3: Initialize the stack pointer
0x000000b4  0x001dea00  sll $29,$29,0x00000008109      sll $sp, $sp, 0x8
0x000000b8  0x23bd00fc  addi $29,$29,0x000000f110      addi $sp, $sp, 0xFC
0x000000bc  0x20080400  addi $8,$0,0x00000400 112      addi $t0, $zero, 0x400 # N3: Initialize the timer
0x000000c0  0x4080b000  mtc0 $0,$22           113      mtc0 $zero, $22
0x000000c4  0x4088b800  mtc0 $8,$23           114      mtc0 $t0, $23
0x000000c8  0x00004020  add $8,$0,$0          116      add $t0, $zero, $zero # N3: Zero out T0, T1, and T2 after memory test OK and device initialization is complete
0x000000cc  0x00004820  add $9,$0,$0          117      add $t1, $zero, $zero
0x000000d0  0x00005020  add $10,$0,$0         118      add $t2, $zero, $zero
0x000000d4  0x0c0000ca  jal 0x00000328        120      jal __SCHEDULER_INIT
0x000000d8  0x0c000084  jal 0x00000210        121      jal __KMAIN
0x000000dc  0x080003fe  j 0x00000ff8          122      j __HALT
# End init
0x000000e0  0x00000000  nop                   125          nop # N(whatever): Padding instructions to align the ISR in the program to address 0x180
0x000000e4  0x00000000  nop                   126          nop # Note: Remove exactly one instruction for every instruction added above this comment!
0x000000e8  0x00000000  nop                   127          nop
0x000000ec  0x00000000  nop                   128          nop
0x000000f0  0x00000000  nop                   129          nop
0x000000f4  0x00000000  nop                   130          nop
0x000000f8  0x00000000  nop                   131          nop
0x000000fc  0x00000000  nop                   132          nop
0x00000100  0x00000000  nop                   133          nop
0x00000104  0x00000000  nop                   134          nop
0x00000108  0x00000000  nop                   135          nop
0x0000010c  0x00000000  nop                   136          nop
0x00000110  0x00000000  nop                   137          nop
0x00000114  0x00000000  nop                   138          nop
0x00000118  0x00000000  nop                   139          nop
0x0000011c  0x00000000  nop                   140          nop
0x00000120  0x00000000  nop                   141          nop
0x00000124  0x00000000  nop                   142          nop
0x00000128  0x00000000  nop                   143          nop
0x0000012c  0x00000000  nop                   144          nop
0x00000130  0x00000000  nop                   145          nop
0x00000134  0x00000000  nop                   146          nop
0x00000138  0x00000000  nop                   147          nop
0x0000013c  0x00000000  nop                   148          nop
0x00000140  0x00000000  nop                   149          nop
0x00000144  0x00000000  nop                   150          nop
0x00000148  0x00000000  nop                   151          nop
0x0000014c  0x00000000  nop                   152          nop
0x00000150  0x00000000  nop                   153          nop
0x00000154  0x00000000  nop                   154          nop
0x00000158  0x00000000  nop                   155          nop
0x0000015c  0x00000000  nop                   156          nop
0x00000160  0x00000000  nop                   157          nop
0x00000164  0x00000000  nop                   158          nop
0x00000168  0x00000000  nop                   159          nop
0x0000016c  0x00000000  nop                   160          nop
0x00000170  0x00000000  nop                   161          nop
0x00000174  0x00000000  nop                   162          nop
0x00000178  0x00000000  nop                   163          nop
0x0000017c  0x00000000  nop                   164          nop
0x00000180  0x00000000  nop                   165          nop
# Begin x180 handler
0x00000184  0x401a7000  mfc0 $26,$14          183      mfc0 $k0, $14 # N2: Grab the address of the interrupted instruction to memory
0x00000188  0xac1a7ee0  sw $26,0x00007ee0($0) 184      sw $k0, 0x7EE0($zero)
0x0000018c  0xac1f7ee4  sw $31,0x00007ee4($0) 185      sw $ra, 0x7EE4($zero) # N2: store the registers that I'm going to use to memory
0x00000190  0xac1b7ee8  sw $27,0x00007ee8($0) 186      sw $k1, 0x7EE8($zero)
0x00000194  0x401a6800  mfc0 $26,$13          188      mfc0 $k0, $13 # N2: Grab the interrupt statuses to memory
0x00000198  0xac1a7ec0  sw $26,0x00007ec0($0) 189      sw $k0, 0x7EC0($zero)
0x0000019c  0x401a6000  mfc0 $26,$12          191      mfc0 $k0, $12 # N8: Acknowledge all interrupts and turn off master flag
0x000001a0  0x201b0fff  addi $27,$0,0x00000fff192      addi $k1, $zero, 0xFFF
0x000001a4  0x001bdb00  sll $27,$27,0x0000000c193      sll $k1, $k1, 0xC
0x000001a8  0x237b0f00  addi $27,$27,0x00000f0194      addi $k1, $k1, 0xF00
0x000001ac  0x001bda00  sll $27,$27,0x00000008195      sll $k1, $k1, 0x8
0x000001b0  0x237b00fe  addi $27,$27,0x000000f196      addi $k1, $k1, 0xFE
0x000001b4  0x037ad024  and $26,$27,$26       197      and $k0, $k1, $k0
0x000001b8  0x409a6000  mtc0 $26,$12          198      mtc0 $k0, $12
0x000001bc  0x0c000089  jal 0x00000224        200      jal PROC_INTR_PROCESS
0x000001c0  0x401b6000  mfc0 $27,$12          202      mfc0 $k1, $12
0x000001c4  0x0000d020  add $26,$0,$0         203      add $k0, $zero, $zero
0x000001c8  0x001ad200  sll $26,$26,0x00000008204  <33> sll $k0, $k0, 0x8
0x000001cc  0x235a0095  addi $26,$26,0x0000009204  <34> addi $k0, $k0, 0x95 # Enable interrupts 5, 2, and 0
0x000001d0  0x001ad200  sll $26,$26,0x00000008204  <35> sll $k0, $k0, 0x8
0x000001d4  0x235a0001  addi $26,$26,0x0000000204  <36> addi $k0, $k0, 0x01 # Enable master interrupt flag and sets KSU, ERL, and EXL
0x000001d8  0x035bd825  or $27,$26,$27        205      or $k1, $k0, $k1
0x000001dc  0x409b6000  mtc0 $27,$12          206      mtc0 $k1, $12 # Set new register value
0x000001e0  0x8c1b7ee8  lw $27,0x00007ee8($0) 208      lw $k1, 0x7EE8($zero) # N2: restore the registers I used
0x000001e4  0x8c1f7ee4  lw $31,0x00007ee4($0) 209      lw $ra, 0x7EE4($zero)
0x000001e8  0x8c1a7ee0  lw $26,0x00007ee0($0) 210      lw $k0, 0x7EE0($zero) # N2: return to whence we've interrupted
0x000001ec  0x03400008  jr $26                211      jr $k0
# End x180 handler
0x000001f0  0x00000000  nop                   215          nop # N8: Padding instructions to separate ISR from main line code (not really needed, discard if space gets short)
0x000001f4  0x00000000  nop                   216          nop # Note: You need these if you see your code show up in X200!!!! You've been warned!!!!!
0x000001f8  0x00000000  nop                   217          nop
0x000001fc  0x00000000  nop                   218          nop
0x00000200  0x00000000  nop                   219          nop
0x00000204  0x00000000  nop                   220          nop
0x00000208  0x00000000  nop                   221          nop
0x0000020c  0x00000000  nop                   222          nop
# Begin KMain
0x00000210  0x4080b000  mtc0 $0,$22           227      mtc0 $zero, $22
0x00000214  0x0c00010e  jal 0x00000438        228      jal __SCHEDULER
0x00000218  0x8c1a7ee0  lw $26,0x00007ee0($0) 229      lw $k0, 0x7EE0($zero)
0x0000021c  0x03400008  jr $26                230      jr $k0
0x00000220  0x03e00008  jr $31                232      jr $ra # Shouldn't go here
# End KMain
# Begin Interrupt Processor
0x00000224  0xac087eec  sw $8,0x00007eec($0)  245      sw $t0, 0x7EEC($zero) # Save $t0 to RAM, I need it
0x00000228  0x8c1a7ec0  lw $26,0x00007ec0($0) 247      lw $k0, 0x7EC0($zero) # Load interrupt status to memory (Note: CP0/R13 no longer viable as interrupts reset)
0x0000022c  0x201b007c  addi $27,$0,0x0000007c248      addi $k1, $zero, 0x007C # N2: Mask out everything except exception code
0x00000230  0x035bd824  and $27,$26,$27       249      and  $k1, $k0, $k1
0x00000234  0x001bd882  srl $27,$27,0x00000002250      srl $k1, $k1, 0x2
0x00000238  0xac1b7020  sw $27,0x00007020($0) 251      sw  $k1, 0x7020($zero) # Store it to memory
0x0000023c  0x13600001  beq $27,$0,0x00000001 253      beq $k1, $zero, IS_INTR # Would do a bne here, but not available in the arch, hence this skip-step if
0x00000240  0x10000034  beq $0,$0,0x00000034  254      beq $zero, $zero, OTHER_EXCP
0x00000244  0x001ad202  srl $26,$26,0x00000008257          srl $k0, $k0, 0x8 # N3: Look at the interrupt flags
0x00000248  0x201b00ff  addi $27,$0,0x000000ff258          addi $k1, $zero, 0xFF
0x0000024c  0x037ad024  and $26,$27,$26       259          and $k0, $k1, $k0
0x00000250  0x201b0080  addi $27,$0,0x00000080261          addi $k1, $zero, 0x80 # N4: Case HWINTR5 (also for next few blocks for different interrupts)
0x00000254  0x001b4020  add $8,$0,$27         262          add $t0, $zero, $k1
0x00000258  0x035bd824  and $27,$26,$27       263          and $k1, $k0, $k1
0x0000025c  0x1368001d  beq $27,$8,0x0000001d 264          beq $k1, $t0, CASE_HWINTR5
0x00000260  0x201b0040  addi $27,$0,0x00000040266          addi $k1, $zero, 0x40
0x00000264  0x001b4020  add $8,$0,$27         267          add $t0, $zero, $k1
0x00000268  0x035bd824  and $27,$26,$27       268          and $k1, $k0, $k1
0x0000026c  0x1368001e  beq $27,$8,0x0000001e 269          beq $k1, $t0, CASE_HWINTR4
0x00000270  0x201b0020  addi $27,$0,0x00000020271          addi $k1, $zero, 0x20
0x00000274  0x001b4020  add $8,$0,$27         272          add $t0, $zero, $k1
0x00000278  0x035bd824  and $27,$26,$27       273          and $k1, $k0, $k1
0x0000027c  0x1368001a  beq $27,$8,0x0000001a 274          beq $k1, $t0, CASE_HWINTR3
0x00000280  0x201b0010  addi $27,$0,0x00000010276          addi $k1, $zero, 0x10
0x00000284  0x001b4020  add $8,$0,$27         277          add $t0, $zero, $k1
0x00000288  0x035bd824  and $27,$26,$27       278          and $k1, $k0, $k1
0x0000028c  0x13680016  beq $27,$8,0x00000016 279          beq $k1, $t0, CASE_HWINTR2
0x00000290  0x201b0008  addi $27,$0,0x00000008281          addi $k1, $zero, 0x08
0x00000294  0x001b4020  add $8,$0,$27         282          add $t0, $zero, $k1
0x00000298  0x035bd824  and $27,$26,$27       283          and $k1, $k0, $k1
0x0000029c  0x13680012  beq $27,$8,0x00000012 284          beq $k1, $t0, CASE_HWINTR1
0x000002a0  0x201b0004  addi $27,$0,0x00000004286          addi $k1, $zero, 0x04
0x000002a4  0x001b4020  add $8,$0,$27         287          add $t0, $zero, $k1
0x000002a8  0x035bd824  and $27,$26,$27       288          and $k1, $k0, $k1
0x000002ac  0x13680010  beq $27,$8,0x00000010 289          beq $k1, $t0, CASE_HWINTR0 # TODO: Compare with zero incorrect, fix this (fixed)
0x000002b0  0x201b0002  addi $27,$0,0x00000002291          addi $k1, $zero, 0x02
0x000002b4  0x001b4020  add $8,$0,$27         292          add $t0, $zero, $k1
0x000002b8  0x035bd824  and $27,$26,$27       293          and $k1, $k0, $k1
0x000002bc  0x1368000f  beq $27,$8,0x0000000f 294          beq $k1, $t0, CASE_SWINTR1
0x000002c0  0x201b0001  addi $27,$0,0x00000001296          addi $k1, $zero, 0x01
0x000002c4  0x001b4020  add $8,$0,$27         297          add $t0, $zero, $k1
0x000002c8  0x035bd824  and $27,$26,$27       298          and $k1, $k0, $k1
0x000002cc  0x1368000e  beq $27,$8,0x0000000e 299          beq $k1, $t0, CASE_SWINTR0
0x000002d0  0x10000013  beq $0,$0,0x00000013  301          beq $zero, $zero, END_IS_INTR
0x000002d4  0xac1f7ec8  sw $31,0x00007ec8($0) 304              sw $ra, 0x7EC8($zero)
0x000002d8  0x0c00010e  jal 0x00000438        305              jal __SCHEDULER
0x000002dc  0x4080b000  mtc0 $0,$22           306              mtc0 $zero, $22
0x000002e0  0x8c1f7ec8  lw $31,0x00007ec8($0) 307              lw $ra, 0x7EC8($zero)
0x000002e4  0x1000000e  beq $0,$0,0x0000000e  308              beq $zero, $zero, END_IS_INTR
0x000002e8  0xac08702c  sw $8,0x0000702c($0)  313              sw $t0, 0x702C($zero)
0x000002ec  0x1000000c  beq $0,$0,0x0000000c  314              beq $zero, $zero, END_IS_INTR # Hardware interrupts 1 through 4 ignored, simply note and reset them
0x000002f0  0xac087028  sw $8,0x00007028($0)  316              sw $t0, 0x7028($zero) # Signal that AES is now complete (make sure A0 has 1 in it!)
0x000002f4  0x00000000  nop                   317              nop # Why did I put this here? I'll keep it for now . . .
0x000002f8  0x10000009  beq $0,$0,0x00000009  318              beq $zero, $zero, END_IS_INTR
0x000002fc  0x20080011  addi $8,$0,0x00000011 320              addi $t0, $zero, 0x11
0x00000300  0xac087024  sw $8,0x00007024($0)  321              sw $t0, 0x7024($zero)
0x00000304  0x10000006  beq $0,$0,0x00000006  322              beq $zero, $zero, END_IS_INTR
0x00000308  0x20080010  addi $8,$0,0x00000010 324              addi $t0, $zero, 0x10
0x0000030c  0xac087024  sw $8,0x00007024($0)  325              sw $t0, 0x7024($zero)
0x00000310  0x10000003  beq $0,$0,0x00000003  326              beq $zero, $zero, END_IS_INTR
0x00000314  0x8c1a7ee0  lw $26,0x00007ee0($0) 329          lw $k0, 0x7EE0($zero)
0x00000318  0x235a0004  addi $26,$26,0x0000000330          addi $k0, $k0, 0x4 # Skip offending instruction (ref: http://www.cs.uwm.edu/classes/cs315/Bacon/Lecture/HTML/ch15s10.html)
0x0000031c  0xac1a7ee0  sw $26,0x00007ee0($0) 331          sw $k0, 0x7EE0($zero)
0x00000320  0x8c087eec  lw $8,0x00007eec($0)  334      lw $t0, 0x7EEC($zero) # Restore $t0 from RAM
0x00000324  0x03e00008  jr $31                335      jr $ra
# End Interrupt Processor
# Begin Scheduler
0x00000328  0x201b6000  addi $27,$0,0x00006000340      addi $k1, $0, 0x6000
0x0000032c  0x201a0744  addi $26,$0,0x00000744342      la $k0, task0Start
0x00000330  0xaf7a0000  sw $26,0x00000000($27)343      sw $k0, 0($k1)
0x00000334  0xaf7a007c  sw $26,0x0000007c($27)344      sw $k0, 124($k1)
0x00000338  0x201a0000  addi $26,$0,0x00000000345      addi $k0, $0, 0
0x0000033c  0x375a00ff  ori $26,$26,0x000000ff347      ori  $k0, $k0, 0x00FF
0x00000340  0xaf7a0078  sw $26,0x00000078($27)348      sw   $k0, 120($k1) # $fp = last addr in task
0x00000344  0xaf7a0074  sw $26,0x00000074($27)349      sw   $k0, 116($k1) # $sp = $fp
0x00000348  0x201b6100  addi $27,$0,0x00006100351      addi $k1, $0, 0x6100
0x0000034c  0x201a07a0  addi $26,$0,0x000007a0353      la $k0, task1Start
0x00000350  0xaf7a0000  sw $26,0x00000000($27)354      sw $k0, 0($k1)
0x00000354  0xaf7a007c  sw $26,0x0000007c($27)355      sw $k0, 124($k1)
0x00000358  0x201a0001  addi $26,$0,0x00000001356      addi $k0, $0, 1
0x0000035c  0x001ad200  sll $26,$26,0x00000008357      sll  $k0, $k0, 0x0008
0x00000360  0x375a00ff  ori $26,$26,0x000000ff358      ori  $k0, $k0, 0x00FF
0x00000364  0xaf7a0078  sw $26,0x00000078($27)359      sw   $k0, 120($k1)
0x00000368  0xaf7a0074  sw $26,0x00000074($27)360      sw   $k0, 116($k1)
0x0000036c  0x201b6200  addi $27,$0,0x00006200362      addi $k1, $0, 0x6200
0x00000370  0x201a0ff8  addi $26,$0,0x00000ff8364      la $k0, task2Start
0x00000374  0xaf7a0000  sw $26,0x00000000($27)365      sw $k0, 0($k1)
0x00000378  0xaf7a007c  sw $26,0x0000007c($27)366      sw $k0, 124($k1)
0x0000037c  0x201a0002  addi $26,$0,0x00000002367      addi $k0, $0, 2
0x00000380  0x001ad200  sll $26,$26,0x00000008368      sll  $k0, $k0, 0x0008
0x00000384  0x375a00ff  ori $26,$26,0x000000ff369      ori  $k0, $k0, 0x00FF
0x00000388  0xaf7a0078  sw $26,0x00000078($27)370      sw   $k0, 120($k1)
0x0000038c  0xaf7a0074  sw $26,0x00000074($27)371      sw   $k0, 116($k1)
0x00000390  0x201b6300  addi $27,$0,0x00006300373      addi $k1, $0, 0x6300
0x00000394  0x201a0ff8  addi $26,$0,0x00000ff8375      la $k0, task3Start
0x00000398  0xaf7a0000  sw $26,0x00000000($27)376      sw $k0, 0($k1)
0x0000039c  0xaf7a007c  sw $26,0x0000007c($27)377      sw $k0, 124($k1)
0x000003a0  0x201a0003  addi $26,$0,0x00000003378      addi $k0, $0, 3
0x000003a4  0x001ad200  sll $26,$26,0x00000008379      sll  $k0, $k0, 0x0008
0x000003a8  0x375a00ff  ori $26,$26,0x000000ff380      ori  $k0, $k0, 0x00FF
0x000003ac  0xaf7a0078  sw $26,0x00000078($27)381      sw   $k0, 120($k1)
0x000003b0  0xaf7a0074  sw $26,0x00000074($27)382      sw   $k0, 116($k1)
0x000003b4  0x201b6400  addi $27,$0,0x00006400384      addi $k1, $0, 0x6400
0x000003b8  0x201a0ff8  addi $26,$0,0x00000ff8386      la $k0, task4Start
0x000003bc  0xaf7a0000  sw $26,0x00000000($27)387      sw $k0, 0($k1)
0x000003c0  0xaf7a007c  sw $26,0x0000007c($27)388      sw $k0, 124($k1)
0x000003c4  0x201a0004  addi $26,$0,0x00000004389      addi $k0, $0, 4
0x000003c8  0x001ad200  sll $26,$26,0x00000008390      sll  $k0, $k0, 0x0008
0x000003cc  0x375a00ff  ori $26,$26,0x000000ff391      ori  $k0, $k0, 0x00FF
0x000003d0  0xaf7a0078  sw $26,0x00000078($27)392      sw   $k0, 120($k1)
0x000003d4  0xaf7a0074  sw $26,0x00000074($27)393      sw   $k0, 116($k1)
0x000003d8  0x201b6500  addi $27,$0,0x00006500395      addi $k1, $0, 0x6500
0x000003dc  0x201a0ff8  addi $26,$0,0x00000ff8397      la $k0, task5Start
0x000003e0  0xaf7a0000  sw $26,0x00000000($27)398      sw $k0, 0($k1)
0x000003e4  0xaf7a007c  sw $26,0x0000007c($27)399      sw $k0, 124($k1)
0x000003e8  0x201a0005  addi $26,$0,0x00000005400      addi $k0, $0, 5
0x000003ec  0x001ad200  sll $26,$26,0x00000008401      sll  $k0, $k0, 0x0008
0x000003f0  0x375a00ff  ori $26,$26,0x000000ff402      ori  $k0, $k0, 0x00FF
0x000003f4  0xaf7a0078  sw $26,0x00000078($27)403      sw   $k0, 120($k1)
0x000003f8  0xaf7a0074  sw $26,0x00000074($27)404      sw   $k0, 116($k1)
0x000003fc  0x201b6600  addi $27,$0,0x00006600406      addi $k1, $0, 0x6600
0x00000400  0x201a0ff8  addi $26,$0,0x00000ff8408      la $k0, task6Start
0x00000404  0xaf7a0000  sw $26,0x00000000($27)409      sw $k0, 0($k1)
0x00000408  0xaf7a007c  sw $26,0x0000007c($27)410      sw $k0, 124($k1)
0x0000040c  0xac1a7ee0  sw $26,0x00007ee0($0) 411      sw $k0, 0x7EE0($0)  # should be first address of iMEM for task6
0x00000410  0xac1a7ee4  sw $26,0x00007ee4($0) 412      sw $k0, 0x7EE4($0)  # this should be where INTR passes RA
0x00000414  0x201a0006  addi $26,$0,0x00000006413      addi $k0, $0, 6
0x00000418  0x001ad200  sll $26,$26,0x00000008414      sll  $k0, $k0, 0x0008
0x0000041c  0x375a00ff  ori $26,$26,0x000000ff415      ori  $k0, $k0, 0x00FF
0x00000420  0xaf7a0078  sw $26,0x00000078($27)416      sw   $k0, 120($k1)
0x00000424  0xaf7a0074  sw $26,0x00000074($27)417      sw   $k0, 116($k1)
0x00000428  0x201a7fe0  addi $26,$0,0x00007fe0420      addi   $k0,  $0, 0x7FE0      # [xxxxxxxxx| 1 | 6543210 | 6543210 ]
0x0000042c  0x201b6003  addi $27,$0,0x00006003421      addi   $k1,  $0, 0x6003 # [unused  |init|currTask |validTask]
0x00000430  0xac1b7fe0  sw $27,0x00007fe0($0) 422      sw     $k1,  0x7FE0($0)
0x00000434  0x03e00008  jr $31                426      jr  $ra        #DEBUG pick this line if using in BootLoader
0x00000438  0xac1f7ff4  sw $31,0x00007ff4($0) 433      sw $ra, 0x7FF4($0) #save current RA to 0x7ff0
0x0000043c  0xac1b7ff8  sw $27,0x00007ff8($0) 434      sw $k1, 0x7FF8($0)
0x00000440  0xac087ffc  sw $8,0x00007ffc($0)  436      sw $t0, 0x7FFC($0)
0x00000444  0x201a7fe0  addi $26,$0,0x00007fe0438      addi $k0,  $0, 0x7FE0
0x00000448  0x8f5f0000  lw $31,0x00000000($26)443      lw $31, 0($k0) #load status register
0x0000044c  0x20080001  addi $8,$0,0x00000001 447      addi $8, $0, 1
0x00000450  0x000841c0  sll $8,$8,0x00000007  448      sll $8, $8, 7
0x00000454  0x03e8d024  and $26,$31,$8        450      and $k0, $31, $8
0x00000458  0x17400012  bne $26,$0,0x00000012 451      bne $k0, $0, caseSchedTask0  #if (mask & statusReg != 0)
0x0000045c  0x00084040  sll $8,$8,0x00000001  453      sll $8, $8, 1
0x00000460  0x03e8d024  and $26,$31,$8        454      and $k0, $31, $8
0x00000464  0x17400011  bne $26,$0,0x00000011 455      bne $k0, $0, caseSchedTask1    
0x00000468  0x00084040  sll $8,$8,0x00000001  457      sll $8, $8, 1
0x0000046c  0x03e8d024  and $26,$31,$8        458      and $k0, $31, $8
0x00000470  0x17400010  bne $26,$0,0x00000010 459      bne $k0, $0, caseSchedTask2  
0x00000474  0x00084040  sll $8,$8,0x00000001  461      sll $8, $8, 1
0x00000478  0x03e8d024  and $26,$31,$8        462      and $k0, $31, $8
0x0000047c  0x1740000f  bne $26,$0,0x0000000f 463      bne $k0, $0, caseSchedTask3  
0x00000480  0x00084040  sll $8,$8,0x00000001  465      sll $8, $8, 1
0x00000484  0x03e8d024  and $26,$31,$8        466      and $k0, $31, $8
0x00000488  0x1740000e  bne $26,$0,0x0000000e 467      bne $k0, $0, caseSchedTask4  
0x0000048c  0x00084040  sll $8,$8,0x00000001  469      sll $8, $8, 1
0x00000490  0x03e8d024  and $26,$31,$8        470      and $k0, $31, $8
0x00000494  0x1740000d  bne $26,$0,0x0000000d 471      bne $k0, $0, caseSchedTask5
0x00000498  0x00084040  sll $8,$8,0x00000001  473      sll $8, $8, 1
0x0000049c  0x03e8d024  and $26,$31,$8        474      and $k0, $31, $8
0x000004a0  0x1740000c  bne $26,$0,0x0000000c 475      bne $k0, $0, caseSchedTask6
0x000004a4  0x201a6000  addi $26,$0,0x00006000482      addi $k0, $0, 0x6000
0x000004a8  0x1000000b  beq $0,$0,0x0000000b  483      beq $zero, $zero, caseSchedTaskEnd
0x000004ac  0x201a6100  addi $26,$0,0x00006100485      addi $k0, $0, 0x6100
0x000004b0  0x10000009  beq $0,$0,0x00000009  486      beq $zero, $zero, caseSchedTaskEnd
0x000004b4  0x201a6200  addi $26,$0,0x00006200488      addi $k0, $0, 0x6200
0x000004b8  0x10000007  beq $0,$0,0x00000007  489      beq $zero, $zero, caseSchedTaskEnd
0x000004bc  0x201a6300  addi $26,$0,0x00006300491      addi $k0, $0, 0x6300
0x000004c0  0x10000005  beq $0,$0,0x00000005  492      beq $zero, $zero, caseSchedTaskEnd
0x000004c4  0x201a6400  addi $26,$0,0x00006400494      addi $k0, $0, 0x6400
0x000004c8  0x10000003  beq $0,$0,0x00000003  495      beq $zero, $zero, caseSchedTaskEnd
0x000004cc  0x201a6500  addi $26,$0,0x00006500497      addi $k0, $0, 0x6500
0x000004d0  0x10000001  beq $0,$0,0x00000001  498      beq $zero, $zero, caseSchedTaskEnd
0x000004d4  0x201a6600  addi $26,$0,0x00006600500      addi $k0, $0, 0x6600
0x000004d8  0x0008da02  srl $27,$8,0x00000008 503      srl $k1, $8, 8   #8 because I want it to be 0 if task0 is running
0x000004dc  0xac1b7fe4  sw $27,0x00007fe4($0) 504      sw $k1, 0x7FE4($0)    #set aside current running task number for later
0x000004e0  0x3c010000  lui $1,0x00000000     505      addi $k1, $0, 0xFFFF
0x000004e4  0x3421ffff  ori $1,$1,0x0000ffff       
0x000004e8  0x0001d820  add $27,$0,$1              
0x000004ec  0x011b4026  xor $8,$8,$27         506      xor $8, $8, $k1
0x000004f0  0x03e8f824  and $31,$31,$8        507      and $31, $31, $8
0x000004f4  0xac1f7fe0  sw $31,0x00007fe0($0) 508      sw $31, 0x7FE0($0) #update sched status
0x000004f8  0x8c087ee0  lw $8,0x00007ee0($0)  515      lw $8, 0x7EE0($0)
0x000004fc  0xaf480000  sw $8,0x00000000($26) 516      sw $8, 0($k0) #PC saved into register 0 spot... 
0x00000500  0x8c1f7ee4  lw $31,0x00007ee4($0) 520      lw $ra, 0x7EE4($0) #retrieve passed RA from memory 0x7ee0 INTR passes here
0x00000504  0x8c087eec  lw $8,0x00007eec($0)  522      lw $t0, 0x7EEC($0)
0x00000508  0xaf410004  sw $1,0x00000004($26) 525      sw $1,  4($k0)
0x0000050c  0xaf420008  sw $2,0x00000008($26) 526      sw $2,  8($k0)
0x00000510  0xaf43000c  sw $3,0x0000000c($26) 527      sw $3,  12($k0) 
0x00000514  0xaf440010  sw $4,0x00000010($26) 528      sw $4,  16($k0)
0x00000518  0xaf450014  sw $5,0x00000014($26) 529      sw $5,  20($k0)
0x0000051c  0xaf460018  sw $6,0x00000018($26) 530      sw $6,  24($k0)
0x00000520  0xaf47001c  sw $7,0x0000001c($26) 531      sw $7,  28($k0)
0x00000524  0xaf480020  sw $8,0x00000020($26) 532      sw $8,  32($k0)
0x00000528  0xaf490024  sw $9,0x00000024($26) 533      sw $9,  36($k0)
0x0000052c  0xaf4a0028  sw $10,0x00000028($26)534      sw $10, 40($k0)
0x00000530  0xaf4b002c  sw $11,0x0000002c($26)535      sw $11, 44($k0)
0x00000534  0xaf4c0030  sw $12,0x00000030($26)536      sw $12, 48($k0)
0x00000538  0xaf4d0034  sw $13,0x00000034($26)537      sw $13, 52($k0)
0x0000053c  0xaf4e0038  sw $14,0x00000038($26)538      sw $14, 56($k0)
0x00000540  0xaf4f003c  sw $15,0x0000003c($26)539      sw $15, 60($k0)
0x00000544  0xaf500040  sw $16,0x00000040($26)540      sw $16, 64($k0)
0x00000548  0xaf510044  sw $17,0x00000044($26)541      sw $17, 68($k0)
0x0000054c  0xaf520048  sw $18,0x00000048($26)542      sw $18, 72($k0)
0x00000550  0xaf53004c  sw $19,0x0000004c($26)543      sw $19, 76($k0)
0x00000554  0xaf540050  sw $20,0x00000050($26)544      sw $20, 80($k0)
0x00000558  0xaf550054  sw $21,0x00000054($26)545      sw $21, 84($k0)
0x0000055c  0xaf560058  sw $22,0x00000058($26)546      sw $22, 88($k0)
0x00000560  0xaf57005c  sw $23,0x0000005c($26)547      sw $23, 92($k0)
0x00000564  0xaf580060  sw $24,0x00000060($26)548      sw $24, 96($k0)
0x00000568  0xaf590064  sw $25,0x00000064($26)549      sw $25, 100($k0) 
0x0000056c  0xaf5c0070  sw $28,0x00000070($26)552      sw $28, 112($k0)
0x00000570  0xaf5d0074  sw $29,0x00000074($26)553      sw $29, 116($k0)
0x00000574  0xaf5e0078  sw $30,0x00000078($26)554      sw $30, 120($k0)
0x00000578  0xaf5f007c  sw $31,0x0000007c($26)555      sw $31, 124($k0)
0x0000057c  0x8c1a7fe4  lw $26,0x00007fe4($0) 561    lw $k0, 0x7FE4($0)  #last task
0x00000580  0x8c1b7fe0  lw $27,0x00007fe0($0) 562    lw $k1, 0x7FE0($0)  #status register
0x00000584  0x1340000c  beq $26,$0,0x0000000c 564    beq $k0, $0, caseSchedLast0
0x00000588  0x001ad042  srl $26,$26,0x00000001565    srl $k0, $k0, 1
0x0000058c  0x1340000d  beq $26,$0,0x0000000d 566    beq $k0, $0, caseSchedLast1
0x00000590  0x001ad042  srl $26,$26,0x00000001567    srl $k0, $k0, 1
0x00000594  0x1340000e  beq $26,$0,0x0000000e 568    beq $k0, $0, caseSchedLast2
0x00000598  0x001ad042  srl $26,$26,0x00000001569    srl $k0, $k0, 1
0x0000059c  0x1340000f  beq $26,$0,0x0000000f 570    beq $k0, $0, caseSchedLast3
0x000005a0  0x001ad042  srl $26,$26,0x00000001571    srl $k0, $k0, 1
0x000005a4  0x13400010  beq $26,$0,0x00000010 572    beq $k0, $0, caseSchedLast4
0x000005a8  0x001ad042  srl $26,$26,0x00000001573    srl $k0, $k0, 1
0x000005ac  0x13400011  beq $26,$0,0x00000011 574    beq $k0, $0, caseSchedLast5
0x000005b0  0x001ad042  srl $26,$26,0x00000001575    srl $k0, $k0, 1
0x000005b4  0x13400012  beq $26,$0,0x00000012 576    beq $k0, $0, caseSchedLast6
0x000005b8  0x201f0002  addi $31,$0,0x00000002580      addi $31, $0, 2
0x000005bc  0x03fb4024  and $8,$31,$27        581      and $8, $31, $k1
0x000005c0  0x15000015  bne $8,$0,0x00000015  582      bne $8, $0, caseSchedNext1
0x000005c4  0x201f0004  addi $31,$0,0x00000004584      addi $31, $0, 4    #2^next
0x000005c8  0x03fb4024  and $8,$31,$27        585      and $8, $31, $k1
0x000005cc  0x15000014  bne $8,$0,0x00000014  586      bne $8, $0, caseSchedNext2
0x000005d0  0x201f0008  addi $31,$0,0x00000008588      addi $31, $0, 8
0x000005d4  0x03fb4024  and $8,$31,$27        589      and $8, $31, $k1
0x000005d8  0x15000013  bne $8,$0,0x00000013  590      bne $8, $0, caseSchedNext3
0x000005dc  0x201f0010  addi $31,$0,0x00000010592      addi $31, $0, 16
0x000005e0  0x03fb4024  and $8,$31,$27        593      and $8, $31, $k1
0x000005e4  0x15000012  bne $8,$0,0x00000012  594      bne $8, $0, caseSchedNext4
0x000005e8  0x201f0020  addi $31,$0,0x00000020596      addi $31, $0, 32
0x000005ec  0x03fb4024  and $8,$31,$27        597      and $8, $31, $k1
0x000005f0  0x15000011  bne $8,$0,0x00000011  598      bne $8, $0, caseSchedNext5
0x000005f4  0x201f0040  addi $31,$0,0x00000040600      addi $31, $0, 64
0x000005f8  0x03fb4024  and $8,$31,$27        601      and $8, $31, $k1
0x000005fc  0x15000010  bne $8,$0,0x00000010  602      bne $8, $0, caseSchedNext6
0x00000600  0x201f0001  addi $31,$0,0x00000001604      addi $31, $0, 1
0x00000604  0x03fb4024  and $8,$31,$27        605      and $8, $31, $k1
0x00000608  0x15000001  bne $8,$0,0x00000001  606      bne $8, $0, caseSchedNext0
0x0000060c  0x1000ffea  beq $0,$0,0xffffffea  608    beq $zero, $zero, caseSchedLast0 #circular list
0x00000610  0x201a6000  addi $26,$0,0x00006000613      addi $k0, $0, 0x6000
0x00000614  0x1000000b  beq $0,$0,0x0000000b  614      beq $zero, $zero, caseSchedNextEnd
0x00000618  0x201a6100  addi $26,$0,0x00006100616      addi $k0, $0, 0x6100
0x0000061c  0x10000009  beq $0,$0,0x00000009  617      beq $zero, $zero, caseSchedNextEnd
0x00000620  0x201a6200  addi $26,$0,0x00006200619      addi $k0, $0, 0x6200
0x00000624  0x10000007  beq $0,$0,0x00000007  620      beq $zero, $zero, caseSchedNextEnd
0x00000628  0x201a6300  addi $26,$0,0x00006300622      addi $k0, $0, 0x6300
0x0000062c  0x10000005  beq $0,$0,0x00000005  623      beq $zero, $zero, caseSchedNextEnd
0x00000630  0x201a6400  addi $26,$0,0x00006400625      addi $k0, $0, 0x6400
0x00000634  0x10000003  beq $0,$0,0x00000003  626      beq $zero, $zero, caseSchedNextEnd
0x00000638  0x201a6500  addi $26,$0,0x00006500628      addi $k0, $0, 0x6500
0x0000063c  0x10000001  beq $0,$0,0x00000001  629      beq $zero, $zero, caseSchedNextEnd
0x00000640  0x201a6600  addi $26,$0,0x00006600631      addi $k0, $0, 0x6600
0x00000644  0x001ff9c0  sll $31,$31,0x00000007635    sll $31, $31, 7
0x00000648  0x037fd825  or $27,$27,$31        636    or $k1, $k1, $31
0x0000064c  0xac1b7fe0  sw $27,0x00007fe0($0) 637    sw $k1, 0x7FE0($0)
0x00000650  0x20080001  addi $8,$0,0x00000001 642    addi $8, $0, 1
0x00000654  0x00084380  sll $8,$8,0x0000000e  643    sll $8, $8, 14  #location of init bit in status register
0x00000658  0x0368f824  and $31,$27,$8        644    and $31, $k1, $8
0x0000065c  0x13e00008  beq $31,$0,0x00000008 645    beq $31, $0 finishSchedUp
0x00000660  0x3c010000  lui $1,0x00000000     648    addi $31, $0, 0xFFFF
0x00000664  0x3421ffff  ori $1,$1,0x0000ffff       
0x00000668  0x0001f820  add $31,$0,$1              
0x0000066c  0x011f4026  xor $8,$8,$31         649    xor $8, $8, $31 #inverse mask
0x00000670  0x011bd824  and $27,$8,$27        650    and $k1, $8, $k1
0x00000674  0xac1b7fe0  sw $27,0x00007fe0($0) 651    sw $k1, 0x7FE0($0)
0x00000678  0x201f0744  addi $31,$0,0x00000744655    la $31, task0Start
0x0000067c  0xac1f7ff4  sw $31,0x00007ff4($0) 656    sw $31, 0x7FF4($0)
0x00000680  0x8f5b0000  lw $27,0x00000000($26)660      lw $k1, 0($k0)
0x00000684  0xac1b7ee0  sw $27,0x00007ee0($0) 662      sw $k1, 0x7EE0($0)
0x00000688  0x8f410004  lw $1,0x00000004($26) 663      lw $1,  4($k0)
0x0000068c  0x8f420008  lw $2,0x00000008($26) 664      lw $2,  8($k0)
0x00000690  0x8f43000c  lw $3,0x0000000c($26) 665      lw $3,  12($k0)
0x00000694  0x8f440010  lw $4,0x00000010($26) 666      lw $4,  16($k0)
0x00000698  0x8f450014  lw $5,0x00000014($26) 667      lw $5,  20($k0)
0x0000069c  0x8f460018  lw $6,0x00000018($26) 668      lw $6,  24($k0)
0x000006a0  0x8f47001c  lw $7,0x0000001c($26) 669      lw $7,  28($k0)
0x000006a4  0x8f480020  lw $8,0x00000020($26) 670      lw $8,  32($k0)
0x000006a8  0x8f490024  lw $9,0x00000024($26) 671      lw $9,  36($k0)
0x000006ac  0x8f4a0028  lw $10,0x00000028($26)672      lw $10, 40($k0)
0x000006b0  0x8f4b002c  lw $11,0x0000002c($26)673      lw $11, 44($k0)
0x000006b4  0x8f4c0030  lw $12,0x00000030($26)674      lw $12, 48($k0)
0x000006b8  0x8f4d0034  lw $13,0x00000034($26)675      lw $13, 52($k0)
0x000006bc  0x8f4e0038  lw $14,0x00000038($26)676      lw $14, 56($k0)
0x000006c0  0x8f4f003c  lw $15,0x0000003c($26)677      lw $15, 60($k0)
0x000006c4  0x8f500040  lw $16,0x00000040($26)678      lw $16, 64($k0)
0x000006c8  0x8f510044  lw $17,0x00000044($26)679      lw $17, 68($k0)
0x000006cc  0x8f520048  lw $18,0x00000048($26)680      lw $18, 72($k0)
0x000006d0  0x8f53004c  lw $19,0x0000004c($26)681      lw $19, 76($k0)
0x000006d4  0x8f540050  lw $20,0x00000050($26)682      lw $20, 80($k0)
0x000006d8  0x8f550054  lw $21,0x00000054($26)683      lw $21, 84($k0)
0x000006dc  0x8f560058  lw $22,0x00000058($26)684      lw $22, 88($k0)
0x000006e0  0x8f57005c  lw $23,0x0000005c($26)685      lw $23, 92($k0)
0x000006e4  0x8f580060  lw $24,0x00000060($26)686      lw $24, 96($k0)
0x000006e8  0x8f590064  lw $25,0x00000064($26)687      lw $25, 100($k0)
0x000006ec  0x8f5c0070  lw $28,0x00000070($26)690      lw $28, 112($k0)
0x000006f0  0x8f5d0074  lw $29,0x00000074($26)691      lw $29, 116($k0)
0x000006f4  0x8f5e0078  lw $30,0x00000078($26)692      lw $30, 120($k0)
0x000006f8  0x8f5f007c  lw $31,0x0000007c($26)695      lw $31, 124($k0)
0x000006fc  0xac1f7ee4  sw $31,0x00007ee4($0) 696      sw $31, 0x7EE4($0)
0x00000700  0xac087eec  sw $8,0x00007eec($0)  698      sw $8,  0x7EEC($0)
0x00000704  0x8c1f7ff4  lw $31,0x00007ff4($0) 700      lw $ra, 0x7FF4($0) #retrieve regs from beggining
0x00000708  0x8c1b7ff8  lw $27,0x00007ff8($0) 701      lw $k1, 0x7FF8($0)
0x0000070c  0x8c087ffc  lw $8,0x00007ffc($0)  702      lw $t0, 0x7FFC($0)
0x00000710  0x03e00008  jr $31                704    jr $ra
# End Scheduler
0x00000714  0x00000000  nop                   707  nop # N12: NOPs for sanity (or so I can find this task in the machine code)
0x00000718  0x00000000  nop                   708  nop
0x0000071c  0x00000000  nop                   709  nop
0x00000720  0x00000000  nop                   710  nop
0x00000724  0x00000000  nop                   711  nop
0x00000728  0x00000000  nop                   712  nop
0x0000072c  0x00000000  nop                   713  nop
0x00000730  0x00000000  nop                   714  nop
0x00000734  0x00000000  nop                   715  nop
0x00000738  0x00000000  nop                   716  nop
0x0000073c  0x00000000  nop                   717  nop
0x00000740  0x00000000  nop                   718  nop
# Begin Fibonacci
0x00000744  0x200d000c  addi $13,$0,0x0000000c724        addi $t5, $zero, 12   # load array size
0x00000748  0x200a0001  addi $10,$0,0x00000001725        addi $t2, $zero, 1    # 0 and 1 are the first and second Fib. numbers
0x0000074c  0xafa00000  sw $0,0x00000000($29) 726        sw   $zero, 0($sp)    # F[0] = 0
0x00000750  0xafaafffc  sw $10,0xfffffffc($29)727        sw   $t2, -4($sp)     # F[1] = F[0] = 1
0x00000754  0x21a9fffe  addi $9,$13,0xfffffffe728        addi $t1, $t5, -2     # Counter for loop, will execute (size-2) times
0x00000758  0x8fab0000  lw $11,0x00000000($29)729  loop: lw   $t3, 0($sp)      # Get value from array F[n] 
0x0000075c  0x8facfffc  lw $12,0xfffffffc($29)730        lw   $t4, -4($sp)     # Get value from array F[n+1]
0x00000760  0x016c5020  add $10,$11,$12       731        add  $t2, $t3, $t4    # $t2 = F[n] + F[n+1]
0x00000764  0xafaafff8  sw $10,0xfffffff8($29)732        sw   $t2, -8($sp)     # Store F[n+2] = F[n] + F[n+1] in array
0x00000768  0x23bdfffc  addi $29,$29,0xfffffff733        addi $sp, $sp, -4     # increment address of Fib. number source
0x0000076c  0x2129ffff  addi $9,$9,0xffffffff 734        addi $t1, $t1, -1     # decrement loop counter
0x00000770  0x1520fff9  bne $9,$0,0xfffffff9  735        bne  $t1, $zero, loop # repeat if not finished yet.
0x00000774  0x1000fff3  beq $0,$0,0xfffffff3  736  beq $zero, $zero, PROC_TASK_FIBONACCI # Keep running the task forever
# End Fibonacci
0x00000778  0x00000000  nop                   739  nop # N10: NOPs for sanity (or so I can find this task in the machine code)
0x0000077c  0x00000000  nop                   740  nop
0x00000780  0x00000000  nop                   741  nop
0x00000784  0x00000000  nop                   742  nop
0x00000788  0x00000000  nop                   743  nop
0x0000078c  0x00000000  nop                   744  nop
0x00000790  0x00000000  nop                   745  nop
0x00000794  0x00000000  nop                   746  nop
0x00000798  0x00000000  nop                   747  nop
0x0000079c  0x00000000  nop                   748  nop
# Begin AES
0x000007a0  0xac007028  sw $0,0x00007028($0)  756  	sw $zero, 0x7028($zero) # Set the AES done flag to zero to start
0x000007a4  0x20081100  addi $8,$0,0x00001100 759      addi $t0, $zero, 0x1100
0x000007a8  0x20093322  addi $9,$0,0x00003322 760      addi $t1, $zero, 0x3322
0x000007ac  0x200a1100  addi $10,$0,0x00001100761      addi $t2, $zero, 0x1100
0x000007b0  0x200b3322  addi $11,$0,0x00003322762      addi $t3, $zero, 0x3322
0x000007b4  0x200c1100  addi $12,$0,0x00001100763      addi $t4, $zero, 0x1100
0x000007b8  0x200d3322  addi $13,$0,0x00003322764      addi $t5, $zero, 0x3322
0x000007bc  0x200e1100  addi $14,$0,0x00001100765      addi $t6, $zero, 0x1100
0x000007c0  0x200f3322  addi $15,$0,0x00003322766      addi $t7, $zero, 0x3322
0x000007c4  0x40881000  mtc0 $8,$2            768      mtc0 $t0, $2
0x000007c8  0x40891800  mtc0 $9,$3            769      mtc0 $t1, $3
0x000007cc  0x408a2000  mtc0 $10,$4           770      mtc0 $t2, $4
0x000007d0  0x408b2800  mtc0 $11,$5           771      mtc0 $t3, $5
0x000007d4  0x408c3000  mtc0 $12,$6           772      mtc0 $t4, $6
0x000007d8  0x408d3800  mtc0 $13,$7           773      mtc0 $t5, $7
0x000007dc  0x408e4000  mtc0 $14,$8           774      mtc0 $t6, $8
0x000007e0  0x408f4800  mtc0 $15,$9           775      mtc0 $t7, $9
0x000007e4  0x20080073  addi $8,$0,0x00000073 780      addi $t0, $zero, 0x73
0x000007e8  0x00084200  sll $8,$8,0x00000008  781      sll $t0, $t0, 0x8
0x000007ec  0x21080069  addi $8,$8,0x00000069 782      addi $t0, $t0, 0x69
0x000007f0  0x00084200  sll $8,$8,0x00000008  783      sll $t0, $t0, 0x8
0x000007f4  0x21080068  addi $8,$8,0x00000068 784      addi $t0, $t0, 0x68
0x000007f8  0x00084200  sll $8,$8,0x00000008  785      sll $t0, $t0, 0x8
0x000007fc  0x21080054  addi $8,$8,0x00000054 786      addi $t0, $t0, 0x54
0x00000800  0xafa80000  sw $8,0x00000000($29) 787      sw $t0, 0x0($sp)
0x00000804  0x23bdfffc  addi $29,$29,0xfffffff788      addi $sp, $sp, -0x4
0x00000808  0x20080078  addi $8,$0,0x00000078 790      addi $t0, $zero, 0x78
0x0000080c  0x00084200  sll $8,$8,0x00000008  791      sll $t0, $t0, 0x8
0x00000810  0x21080065  addi $8,$8,0x00000065 792      addi $t0, $t0, 0x65
0x00000814  0x00084200  sll $8,$8,0x00000008  793      sll $t0, $t0, 0x8
0x00000818  0x21080074  addi $8,$8,0x00000074 794      addi $t0, $t0, 0x74
0x0000081c  0x00084200  sll $8,$8,0x00000008  795      sll $t0, $t0, 0x8
0x00000820  0x21080020  addi $8,$8,0x00000020 796      addi $t0, $t0, 0x20
0x00000824  0xafa80000  sw $8,0x00000000($29) 797      sw $t0, 0x0($sp)
0x00000828  0x23bdfffc  addi $29,$29,0xfffffff798      addi $sp, $sp, -0x4
0x0000082c  0x20080073  addi $8,$0,0x00000073 800      addi $t0, $zero, 0x73
0x00000830  0x00084200  sll $8,$8,0x00000008  801      sll $t0, $t0, 0x8
0x00000834  0x20080069  addi $8,$0,0x00000069 802      addi $t0, $zero, 0x69
0x00000838  0x00084200  sll $8,$8,0x00000008  803      sll $t0, $t0, 0x8
0x0000083c  0x20080020  addi $8,$0,0x00000020 804      addi $t0, $zero, 0x20
0x00000840  0x00084200  sll $8,$8,0x00000008  805      sll $t0, $t0, 0x8
0x00000844  0x20080074  addi $8,$0,0x00000074 806      addi $t0, $zero, 0x74
0x00000848  0xafa80000  sw $8,0x00000000($29) 807      sw $t0, 0x0($sp)
0x0000084c  0x23bdfffc  addi $29,$29,0xfffffff808      addi $sp, $sp, -0x4
0x00000850  0x20080073  addi $8,$0,0x00000073 810      addi $t0, $zero, 0x73
0x00000854  0x00084200  sll $8,$8,0x00000008  811      sll $t0, $t0, 0x8
0x00000858  0x20080020  addi $8,$0,0x00000020 812      addi $t0, $zero, 0x20
0x0000085c  0x00084200  sll $8,$8,0x00000008  813      sll $t0, $t0, 0x8
0x00000860  0x20080061  addi $8,$0,0x00000061 814      addi $t0, $zero, 0x61
0x00000864  0x00084200  sll $8,$8,0x00000008  815      sll $t0, $t0, 0x8
0x00000868  0x20080020  addi $8,$0,0x00000020 816      addi $t0, $zero, 0x20
0x0000086c  0xafa80000  sw $8,0x00000000($29) 817      sw $t0, 0x0($sp)
0x00000870  0x23bdfffc  addi $29,$29,0xfffffff818      addi $sp, $sp, -0x4
0x00000874  0x20080072  addi $8,$0,0x00000072 820      addi $t0, $zero, 0x72
0x00000878  0x00084200  sll $8,$8,0x00000008  821      sll $t0, $t0, 0x8
0x0000087c  0x20080065  addi $8,$0,0x00000065 822      addi $t0, $zero, 0x65
0x00000880  0x00084200  sll $8,$8,0x00000008  823      sll $t0, $t0, 0x8
0x00000884  0x20080070  addi $8,$0,0x00000070 824      addi $t0, $zero, 0x70
0x00000888  0x00084200  sll $8,$8,0x00000008  825      sll $t0, $t0, 0x8
0x0000088c  0x20080075  addi $8,$0,0x00000075 826      addi $t0, $zero, 0x75
0x00000890  0xafa80000  sw $8,0x00000000($29) 827      sw $t0, 0x0($sp)
0x00000894  0x23bdfffc  addi $29,$29,0xfffffff828      addi $sp, $sp, -0x4
0x00000898  0x20080063  addi $8,$0,0x00000063 830      addi $t0, $zero, 0x63
0x0000089c  0x00084200  sll $8,$8,0x00000008  831      sll $t0, $t0, 0x8
0x000008a0  0x20080065  addi $8,$0,0x00000065 832      addi $t0, $zero, 0x65
0x000008a4  0x00084200  sll $8,$8,0x00000008  833      sll $t0, $t0, 0x8
0x000008a8  0x20080073  addi $8,$0,0x00000073 834      addi $t0, $zero, 0x73
0x000008ac  0x00084200  sll $8,$8,0x00000008  835      sll $t0, $t0, 0x8
0x000008b0  0x20080020  addi $8,$0,0x00000020 836      addi $t0, $zero, 0x20
0x000008b4  0xafa80000  sw $8,0x00000000($29) 837      sw $t0, 0x0($sp)
0x000008b8  0x23bdfffc  addi $29,$29,0xfffffff838      addi $sp, $sp, -0x4
0x000008bc  0x20080020  addi $8,$0,0x00000020 840      addi $t0, $zero, 0x20
0x000008c0  0x00084200  sll $8,$8,0x00000008  841      sll $t0, $t0, 0x8
0x000008c4  0x20080074  addi $8,$0,0x00000074 842      addi $t0, $zero, 0x74
0x000008c8  0x00084200  sll $8,$8,0x00000008  843      sll $t0, $t0, 0x8
0x000008cc  0x20080065  addi $8,$0,0x00000065 844      addi $t0, $zero, 0x65
0x000008d0  0x00084200  sll $8,$8,0x00000008  845      sll $t0, $t0, 0x8
0x000008d4  0x20080072  addi $8,$0,0x00000072 846      addi $t0, $zero, 0x72
0x000008d8  0xafa80000  sw $8,0x00000000($29) 847      sw $t0, 0x0($sp)
0x000008dc  0x23bdfffc  addi $29,$29,0xfffffff848      addi $sp, $sp, -0x4
0x000008e0  0x20080069  addi $8,$0,0x00000069 850      addi $t0, $zero, 0x69
0x000008e4  0x00084200  sll $8,$8,0x00000008  851      sll $t0, $t0, 0x8
0x000008e8  0x20080062  addi $8,$0,0x00000062 852      addi $t0, $zero, 0x62
0x000008ec  0x00084200  sll $8,$8,0x00000008  853      sll $t0, $t0, 0x8
0x000008f0  0x20080020  addi $8,$0,0x00000020 854      addi $t0, $zero, 0x20
0x000008f4  0x00084200  sll $8,$8,0x00000008  855      sll $t0, $t0, 0x8
0x000008f8  0x20080038  addi $8,$0,0x00000038 856      addi $t0, $zero, 0x38
0x000008fc  0xafa80000  sw $8,0x00000000($29) 857      sw $t0, 0x0($sp)
0x00000900  0x23bdfffc  addi $29,$29,0xfffffff858      addi $sp, $sp, -0x4
0x00000904  0x20080065  addi $8,$0,0x00000065 860      addi $t0, $zero, 0x65
0x00000908  0x00084200  sll $8,$8,0x00000008  861      sll $t0, $t0, 0x8
0x0000090c  0x2008006d  addi $8,$0,0x0000006d 862      addi $t0, $zero, 0x6d
0x00000910  0x00084200  sll $8,$8,0x00000008  863      sll $t0, $t0, 0x8
0x00000914  0x20080020  addi $8,$0,0x00000020 864      addi $t0, $zero, 0x20
0x00000918  0x00084200  sll $8,$8,0x00000008  865      sll $t0, $t0, 0x8
0x0000091c  0x20080074  addi $8,$0,0x00000074 866      addi $t0, $zero, 0x74
0x00000920  0xafa80000  sw $8,0x00000000($29) 867      sw $t0, 0x0($sp)
0x00000924  0x23bdfffc  addi $29,$29,0xfffffff868      addi $sp, $sp, -0x4
0x00000928  0x20080067  addi $8,$0,0x00000067 870      addi $t0, $zero, 0x67
0x0000092c  0x00084200  sll $8,$8,0x00000008  871      sll $t0, $t0, 0x8
0x00000930  0x20080061  addi $8,$0,0x00000061 872      addi $t0, $zero, 0x61
0x00000934  0x00084200  sll $8,$8,0x00000008  873      sll $t0, $t0, 0x8
0x00000938  0x20080073  addi $8,$0,0x00000073 874      addi $t0, $zero, 0x73
0x0000093c  0x00084200  sll $8,$8,0x00000008  875      sll $t0, $t0, 0x8
0x00000940  0x20080073  addi $8,$0,0x00000073 876      addi $t0, $zero, 0x73
0x00000944  0xafa80000  sw $8,0x00000000($29) 877      sw $t0, 0x0($sp)
0x00000948  0x23bdfffc  addi $29,$29,0xfffffff878      addi $sp, $sp, -0x4
0x0000094c  0x20080065  addi $8,$0,0x00000065 880      addi $t0, $zero, 0x65
0x00000950  0x00084200  sll $8,$8,0x00000008  881      sll $t0, $t0, 0x8
0x00000954  0x20080068  addi $8,$0,0x00000068 882      addi $t0, $zero, 0x68
0x00000958  0x00084200  sll $8,$8,0x00000008  883      sll $t0, $t0, 0x8
0x0000095c  0x20080020  addi $8,$0,0x00000020 884      addi $t0, $zero, 0x20
0x00000960  0x00084200  sll $8,$8,0x00000008  885      sll $t0, $t0, 0x8
0x00000964  0x20080065  addi $8,$0,0x00000065 886      addi $t0, $zero, 0x65
0x00000968  0xafa80000  sw $8,0x00000000($29) 887      sw $t0, 0x0($sp)
0x0000096c  0x23bdfffc  addi $29,$29,0xfffffff888      addi $sp, $sp, -0x4
0x00000970  0x20080000  addi $8,$0,0x00000000 890      addi $t0, $zero, 0x00
0x00000974  0x00084200  sll $8,$8,0x00000008  891      sll $t0, $t0, 0x8
0x00000978  0x2008002e  addi $8,$0,0x0000002e 892      addi $t0, $zero, 0x2e
0x0000097c  0x00084200  sll $8,$8,0x00000008  893      sll $t0, $t0, 0x8
0x00000980  0x20080065  addi $8,$0,0x00000065 894      addi $t0, $zero, 0x65
0x00000984  0x00084200  sll $8,$8,0x00000008  895      sll $t0, $t0, 0x8
0x00000988  0x20080072  addi $8,$0,0x00000072 896      addi $t0, $zero, 0x72
0x0000098c  0xafa80000  sw $8,0x00000000($29) 897      sw $t0, 0x0($sp)
0x00000990  0x23bdfffc  addi $29,$29,0xfffffff898      addi $sp, $sp, -0x4
0x00000994  0x23d00000  addi $16,$30,0x0000000900      addi $s0, $fp, 0x0 # Set up a pointer to give to the AES
0x00000998  0x2011000c  addi $17,$0,0x0000000c901      addi $s1, $zero, 12 # Number of words to encrypt
0x0000099c  0x20120d0a  addi $18,$0,0x00000d0a902      addi $s2, $zero, 0x0d0a
0x000009a0  0x001293c0  sll $18,$18,0x0000000f903      sll $s2, $s2, 0xF # Set up a register that I can randomly print newline with
0x000009a4  0x40900800  mtc0 $16,$1           917      mtc0 $s0, $1
0x000009a8  0x20090070  addi $9,$0,0x00000070 918      addi $t1, $zero, 0x70 # Set encrypt at 256 bit mode
0x000009ac  0x00094e00  sll $9,$9,0x00000018  919      sll $t1, $t1, 0x18
0x000009b0  0x01314820  add $9,$9,$17         920      add $t1, $t1, $s1
0x000009b4  0x40890000  mtc0 $9,$0            921      mtc0 $t1, $0
0x000009b8  0x200a0001  addi $10,$0,0x00000001924      addi $t2, $zero, 0x1
0x000009bc  0x8c097028  lw $9,0x00007028($0)  926          lw $t1, 0x7028($zero)
0x000009c0  0x152afffe  bne $9,$10,0xfffffffe 927          bne $t1, $t2, SPINLOCK_1
0x000009c4  0xac007028  sw $0,0x00007028($0)  928      sw $zero, 0x7028($zero) # Reset AES done flag
0x000009c8  0x40900800  mtc0 $16,$1           945      mtc0 $s0, $1
0x000009cc  0x20090060  addi $9,$0,0x00000060 946      addi $t1, $zero, 0x60 # Set decrypt at 256 bit mode
0x000009d0  0x00094e00  sll $9,$9,0x00000018  947      sll $t1, $t1, 0x18
0x000009d4  0x01314820  add $9,$9,$17         948      add $t1, $t1, $s1
0x000009d8  0x40890000  mtc0 $9,$0            949      mtc0 $t1, $0
0x000009dc  0x200a0001  addi $10,$0,0x00000001952      addi $t2, $zero, 0x1
0x000009e0  0x8c097028  lw $9,0x00007028($0)  954          lw $t1, 0x7028($zero)
0x000009e4  0x152afffe  bne $9,$10,0xfffffffe 955          bne $t1, $t2, SPINLOCK_2
0x000009e8  0xac007028  sw $0,0x00007028($0)  956      sw $zero, 0x7028($zero) # Reset AES done flag
0x000009ec  0x00104820  add $9,$0,$16         959      add $t1, $zero, $s0 # Set up a pointer to start loading the phrase
0x000009f0  0x212affd0  addi $10,$9,0xffffffd0960      addi $t2, $t1, -48 # End pointer is 48 bytes away
0x000009f4  0x8d2b0000  lw $11,0x00000000($9) 962          lw $t3, 0x0($t1)
0x000009f8  0xac0b7000  sw $11,0x00007000($0) 963          sw $t3, 0x7000($zero)
0x000009fc  0x2129fffc  addi $9,$9,0xfffffffc 964          addi $t1, $t1, -0x4
0x00000a00  0x152afffc  bne $9,$10,0xfffffffc 965          bne $t1, $t2, WRITE_OUT3
0x00000a04  0xac127000  sw $18,0x00007000($0) 966      sw $s2, 0x7000($zero) # N2: Write to CRLFs
0x00000a08  0xac127000  sw $18,0x00007000($0) 967      sw $s2, 0x7000($zero)
0x00000a0c  0xac007000  sw $0,0x00007000($0)  968      sw $zero, 0x7000($zero) # Write out a null terminator in case there is none
0x00000a10  0x1000ff63  beq $0,$0,0xffffff63  970      beq $zero, $zero, PROC_TASK_AES
0x00000a14  0x03e00008  jr $31                971      jr $ra
# End AES
# Long NOP sled to the cattle catcher
0x00000a18  0x00000000  nop                   974  nop
0x00000a1c  0x00000000  nop                   975  nop
0x00000a20  0x00000000  nop                   976  nop
0x00000a24  0x00000000  nop                   977  nop
0x00000a28  0x00000000  nop                   978  nop
0x00000a2c  0x00000000  nop                   979  nop
0x00000a30  0x00000000  nop                   981  nop
0x00000a34  0x00000000  nop                   982  nop
0x00000a38  0x00000000  nop                   983  nop
0x00000a3c  0x00000000  nop                   984  nop
0x00000a40  0x00000000  nop                   985  nop
0x00000a44  0x00000000  nop                   986  nop
0x00000a48  0x00000000  nop                   987  nop
0x00000a4c  0x00000000  nop                   988  nop
0x00000a50  0x00000000  nop                   989  nop
0x00000a54  0x00000000  nop                   991  nop
0x00000a58  0x00000000  nop                   992  nop
0x00000a5c  0x00000000  nop                   993  nop
0x00000a60  0x00000000  nop                   994  nop
0x00000a64  0x00000000  nop                   995  nop
0x00000a68  0x00000000  nop                   996  nop
0x00000a6c  0x00000000  nop                   998  nop
0x00000a70  0x00000000  nop                   999  nop
0x00000a74  0x00000000  nop                   1000 nop
0x00000a78  0x00000000  nop                   1001 nop
0x00000a7c  0x00000000  nop                   1002 nop
0x00000a80  0x00000000  nop                   1003 nop
0x00000a84  0x00000000  nop                   1004 nop
0x00000a88  0x00000000  nop                   1005 nop
0x00000a8c  0x00000000  nop                   1006 nop
0x00000a90  0x00000000  nop                   1007 nop
0x00000a94  0x00000000  nop                   1008 nop
0x00000a98  0x00000000  nop                   1009 nop
0x00000a9c  0x00000000  nop                   1010 nop
0x00000aa0  0x00000000  nop                   1011 nop
0x00000aa4  0x00000000  nop                   1012 nop
0x00000aa8  0x00000000  nop                   1013 nop
0x00000aac  0x00000000  nop                   1014 nop
0x00000ab0  0x00000000  nop                   1015 nop
0x00000ab4  0x00000000  nop                   1016 nop
0x00000ab8  0x00000000  nop                   1017 nop
0x00000abc  0x00000000  nop                   1018 nop
0x00000ac0  0x00000000  nop                   1019 nop
0x00000ac4  0x00000000  nop                   1020 nop
0x00000ac8  0x00000000  nop                   1021 nop
0x00000acc  0x00000000  nop                   1022 nop
0x00000ad0  0x00000000  nop                   1023 nop
0x00000ad4  0x00000000  nop                   1024 nop
0x00000ad8  0x00000000  nop                   1025 nop
0x00000adc  0x00000000  nop                   1026 nop
0x00000ae0  0x00000000  nop                   1027 nop
0x00000ae4  0x00000000  nop                   1028 nop
0x00000ae8  0x00000000  nop                   1029 nop
0x00000aec  0x00000000  nop                   1030 nop
0x00000af0  0x00000000  nop                   1031 nop
0x00000af4  0x00000000  nop                   1032 nop
0x00000af8  0x00000000  nop                   1033 nop
0x00000afc  0x00000000  nop                   1034 nop
0x00000b00  0x00000000  nop                   1035 nop
0x00000b04  0x00000000  nop                   1036 nop
0x00000b08  0x00000000  nop                   1037 nop
0x00000b0c  0x00000000  nop                   1038 nop
0x00000b10  0x00000000  nop                   1039 nop
0x00000b14  0x00000000  nop                   1040 nop
0x00000b18  0x00000000  nop                   1041 nop
0x00000b1c  0x00000000  nop                   1042 nop
0x00000b20  0x00000000  nop                   1043 nop
0x00000b24  0x00000000  nop                   1044 nop
0x00000b28  0x00000000  nop                   1045 nop
0x00000b2c  0x00000000  nop                   1046 nop
0x00000b30  0x00000000  nop                   1047 nop
0x00000b34  0x00000000  nop                   1048 nop
0x00000b38  0x00000000  nop                   1049 nop
0x00000b3c  0x00000000  nop                   1050 nop
0x00000b40  0x00000000  nop                   1051 nop
0x00000b44  0x00000000  nop                   1052 nop
0x00000b48  0x00000000  nop                   1053 nop
0x00000b4c  0x00000000  nop                   1054 nop
0x00000b50  0x00000000  nop                   1055 nop
0x00000b54  0x00000000  nop                   1056 nop
0x00000b58  0x00000000  nop                   1057 nop
0x00000b5c  0x00000000  nop                   1058 nop
0x00000b60  0x00000000  nop                   1059 nop
0x00000b64  0x00000000  nop                   1060 nop
0x00000b68  0x00000000  nop                   1061 nop
0x00000b6c  0x00000000  nop                   1062 nop
0x00000b70  0x00000000  nop                   1063 nop
0x00000b74  0x00000000  nop                   1064 nop
0x00000b78  0x00000000  nop                   1065 nop
0x00000b7c  0x00000000  nop                   1066 nop
0x00000b80  0x00000000  nop                   1067 nop
0x00000b84  0x00000000  nop                   1068 nop
0x00000b88  0x00000000  nop                   1069 nop
0x00000b8c  0x00000000  nop                   1070 nop
0x00000b90  0x00000000  nop                   1071 nop
0x00000b94  0x00000000  nop                   1072 nop
0x00000b98  0x00000000  nop                   1073 nop
0x00000b9c  0x00000000  nop                   1074 nop
0x00000ba0  0x00000000  nop                   1075 nop
0x00000ba4  0x00000000  nop                   1076 nop
0x00000ba8  0x00000000  nop                   1077 nop
0x00000bac  0x00000000  nop                   1078 nop
0x00000bb0  0x00000000  nop                   1079 nop
0x00000bb4  0x00000000  nop                   1080 nop
0x00000bb8  0x00000000  nop                   1081 nop
0x00000bbc  0x00000000  nop                   1082 nop
0x00000bc0  0x00000000  nop                   1083 nop
0x00000bc4  0x00000000  nop                   1084 nop
0x00000bc8  0x00000000  nop                   1085 nop
0x00000bcc  0x00000000  nop                   1086 nop
0x00000bd0  0x00000000  nop                   1087 nop
0x00000bd4  0x00000000  nop                   1088 nop
0x00000bd8  0x00000000  nop                   1089 nop
0x00000bdc  0x00000000  nop                   1090 nop
0x00000be0  0x00000000  nop                   1091 nop
0x00000be4  0x00000000  nop                   1092 nop
0x00000be8  0x00000000  nop                   1093 nop
0x00000bec  0x00000000  nop                   1094 nop
0x00000bf0  0x00000000  nop                   1095 nop
0x00000bf4  0x00000000  nop                   1096 nop
0x00000bf8  0x00000000  nop                   1097 nop
0x00000bfc  0x00000000  nop                   1098 nop
0x00000c00  0x00000000  nop                   1099 nop
0x00000c04  0x00000000  nop                   1100 nop
0x00000c08  0x00000000  nop                   1101 nop
0x00000c0c  0x00000000  nop                   1102 nop
0x00000c10  0x00000000  nop                   1103 nop
0x00000c14  0x00000000  nop                   1104 nop
0x00000c18  0x00000000  nop                   1105 nop
0x00000c1c  0x00000000  nop                   1106 nop
0x00000c20  0x00000000  nop                   1107 nop
0x00000c24  0x00000000  nop                   1108 nop
0x00000c28  0x00000000  nop                   1109 nop
0x00000c2c  0x00000000  nop                   1110 nop
0x00000c30  0x00000000  nop                   1111 nop
0x00000c34  0x00000000  nop                   1112 nop
0x00000c38  0x00000000  nop                   1113 nop
0x00000c3c  0x00000000  nop                   1114 nop
0x00000c40  0x00000000  nop                   1115 nop
0x00000c44  0x00000000  nop                   1116 nop
0x00000c48  0x00000000  nop                   1117 nop
0x00000c4c  0x00000000  nop                   1118 nop
0x00000c50  0x00000000  nop                   1119 nop
0x00000c54  0x00000000  nop                   1120 nop
0x00000c58  0x00000000  nop                   1121 nop
0x00000c5c  0x00000000  nop                   1122 nop
0x00000c60  0x00000000  nop                   1123 nop
0x00000c64  0x00000000  nop                   1124 nop
0x00000c68  0x00000000  nop                   1125 nop
0x00000c6c  0x00000000  nop                   1126 nop
0x00000c70  0x00000000  nop                   1127 nop
0x00000c74  0x00000000  nop                   1128 nop
0x00000c78  0x00000000  nop                   1129 nop
0x00000c7c  0x00000000  nop                   1130 nop
0x00000c80  0x00000000  nop                   1131 nop
0x00000c84  0x00000000  nop                   1132 nop
0x00000c88  0x00000000  nop                   1133 nop
0x00000c8c  0x00000000  nop                   1134 nop
0x00000c90  0x00000000  nop                   1135 nop
0x00000c94  0x00000000  nop                   1136 nop
0x00000c98  0x00000000  nop                   1137 nop
0x00000c9c  0x00000000  nop                   1138 nop
0x00000ca0  0x00000000  nop                   1139 nop
0x00000ca4  0x00000000  nop                   1140 nop
0x00000ca8  0x00000000  nop                   1141 nop
0x00000cac  0x00000000  nop                   1142 nop
0x00000cb0  0x00000000  nop                   1143 nop
0x00000cb4  0x00000000  nop                   1144 nop
0x00000cb8  0x00000000  nop                   1145 nop
0x00000cbc  0x00000000  nop                   1146 nop
0x00000cc0  0x00000000  nop                   1147 nop
0x00000cc4  0x00000000  nop                   1148 nop
0x00000cc8  0x00000000  nop                   1149 nop
0x00000ccc  0x00000000  nop                   1150 nop
0x00000cd0  0x00000000  nop                   1151 nop
0x00000cd4  0x00000000  nop                   1152 nop
0x00000cd8  0x00000000  nop                   1153 nop
0x00000cdc  0x00000000  nop                   1154 nop
0x00000ce0  0x00000000  nop                   1155 nop
0x00000ce4  0x00000000  nop                   1156 nop
0x00000ce8  0x00000000  nop                   1157 nop
0x00000cec  0x00000000  nop                   1158 nop
0x00000cf0  0x00000000  nop                   1159 nop
0x00000cf4  0x00000000  nop                   1160 nop
0x00000cf8  0x00000000  nop                   1161 nop
0x00000cfc  0x00000000  nop                   1162 nop
0x00000d00  0x00000000  nop                   1163 nop
0x00000d04  0x00000000  nop                   1164 nop
0x00000d08  0x00000000  nop                   1165 nop
0x00000d0c  0x00000000  nop                   1166 nop
0x00000d10  0x00000000  nop                   1167 nop
0x00000d14  0x00000000  nop                   1168 nop
0x00000d18  0x00000000  nop                   1169 nop
0x00000d1c  0x00000000  nop                   1170 nop
0x00000d20  0x00000000  nop                   1171 nop
0x00000d24  0x00000000  nop                   1172 nop
0x00000d28  0x00000000  nop                   1173 nop
0x00000d2c  0x00000000  nop                   1174 nop
0x00000d30  0x00000000  nop                   1175 nop
0x00000d34  0x00000000  nop                   1176 nop
0x00000d38  0x00000000  nop                   1177 nop
0x00000d3c  0x00000000  nop                   1178 nop
0x00000d40  0x00000000  nop                   1179 nop
0x00000d44  0x00000000  nop                   1180 nop
0x00000d48  0x00000000  nop                   1181 nop
0x00000d4c  0x00000000  nop                   1182 nop
0x00000d50  0x00000000  nop                   1183 nop
0x00000d54  0x00000000  nop                   1184 nop
0x00000d58  0x00000000  nop                   1185 nop
0x00000d5c  0x00000000  nop                   1186 nop
0x00000d60  0x00000000  nop                   1187 nop
0x00000d64  0x00000000  nop                   1188 nop
0x00000d68  0x00000000  nop                   1189 nop
0x00000d6c  0x00000000  nop                   1190 nop
0x00000d70  0x00000000  nop                   1191 nop
0x00000d74  0x00000000  nop                   1192 nop
0x00000d78  0x00000000  nop                   1193 nop
0x00000d7c  0x00000000  nop                   1194 nop
0x00000d80  0x00000000  nop                   1195 nop
0x00000d84  0x00000000  nop                   1196 nop
0x00000d88  0x00000000  nop                   1197 nop
0x00000d8c  0x00000000  nop                   1198 nop
0x00000d90  0x00000000  nop                   1199 nop
0x00000d94  0x00000000  nop                   1200 nop
0x00000d98  0x00000000  nop                   1201 nop
0x00000d9c  0x00000000  nop                   1202 nop
0x00000da0  0x00000000  nop                   1203 nop
0x00000da4  0x00000000  nop                   1204 nop
0x00000da8  0x00000000  nop                   1205 nop
0x00000dac  0x00000000  nop                   1206 nop
0x00000db0  0x00000000  nop                   1207 nop
0x00000db4  0x00000000  nop                   1208 nop
0x00000db8  0x00000000  nop                   1209 nop
0x00000dbc  0x00000000  nop                   1210 nop
0x00000dc0  0x00000000  nop                   1211 nop
0x00000dc4  0x00000000  nop                   1212 nop
0x00000dc8  0x00000000  nop                   1213 nop
0x00000dcc  0x00000000  nop                   1214 nop
0x00000dd0  0x00000000  nop                   1215 nop
0x00000dd4  0x00000000  nop                   1216 nop
0x00000dd8  0x00000000  nop                   1217 nop
0x00000ddc  0x00000000  nop                   1218 nop
0x00000de0  0x00000000  nop                   1219 nop
0x00000de4  0x00000000  nop                   1220 nop
0x00000de8  0x00000000  nop                   1221 nop
0x00000dec  0x00000000  nop                   1222 nop
0x00000df0  0x00000000  nop                   1223 nop
0x00000df4  0x00000000  nop                   1224 nop
0x00000df8  0x00000000  nop                   1225 nop
0x00000dfc  0x00000000  nop                   1226 nop
0x00000e00  0x00000000  nop                   1227 nop
0x00000e04  0x00000000  nop                   1228 nop
0x00000e08  0x00000000  nop                   1229 nop
0x00000e0c  0x00000000  nop                   1230 nop
0x00000e10  0x00000000  nop                   1231 nop
0x00000e14  0x00000000  nop                   1232 nop
0x00000e18  0x00000000  nop                   1233 nop
0x00000e1c  0x00000000  nop                   1234 nop
0x00000e20  0x00000000  nop                   1235 nop
0x00000e24  0x00000000  nop                   1236 nop
0x00000e28  0x00000000  nop                   1237 nop
0x00000e2c  0x00000000  nop                   1238 nop
0x00000e30  0x00000000  nop                   1239 nop
0x00000e34  0x00000000  nop                   1240 nop
0x00000e38  0x00000000  nop                   1241 nop
0x00000e3c  0x00000000  nop                   1242 nop
0x00000e40  0x00000000  nop                   1243 nop
0x00000e44  0x00000000  nop                   1244 nop
0x00000e48  0x00000000  nop                   1245 nop
0x00000e4c  0x00000000  nop                   1246 nop
0x00000e50  0x00000000  nop                   1247 nop
0x00000e54  0x00000000  nop                   1248 nop
0x00000e58  0x00000000  nop                   1249 nop
0x00000e5c  0x00000000  nop                   1250 nop
0x00000e60  0x00000000  nop                   1251 nop
0x00000e64  0x00000000  nop                   1252 nop
0x00000e68  0x00000000  nop                   1253 nop
0x00000e6c  0x00000000  nop                   1254 nop
0x00000e70  0x00000000  nop                   1255 nop
0x00000e74  0x00000000  nop                   1256 nop
0x00000e78  0x00000000  nop                   1257 nop
0x00000e7c  0x00000000  nop                   1258 nop
0x00000e80  0x00000000  nop                   1259 nop
0x00000e84  0x00000000  nop                   1260 nop
0x00000e88  0x00000000  nop                   1261 nop
0x00000e8c  0x00000000  nop                   1262 nop
0x00000e90  0x00000000  nop                   1263 nop
0x00000e94  0x00000000  nop                   1264 nop
0x00000e98  0x00000000  nop                   1265 nop
0x00000e9c  0x00000000  nop                   1266 nop
0x00000ea0  0x00000000  nop                   1267 nop
0x00000ea4  0x00000000  nop                   1268 nop
0x00000ea8  0x00000000  nop                   1269 nop
0x00000eac  0x00000000  nop                   1270 nop
0x00000eb0  0x00000000  nop                   1271 nop
0x00000eb4  0x00000000  nop                   1272 nop
0x00000eb8  0x00000000  nop                   1273 nop
0x00000ebc  0x00000000  nop                   1274 nop
0x00000ec0  0x00000000  nop                   1275 nop
0x00000ec4  0x00000000  nop                   1276 nop
0x00000ec8  0x00000000  nop                   1277 nop
0x00000ecc  0x00000000  nop                   1278 nop
0x00000ed0  0x00000000  nop                   1279 nop
0x00000ed4  0x00000000  nop                   1280 nop
0x00000ed8  0x00000000  nop                   1281 nop
0x00000edc  0x00000000  nop                   1282 nop
0x00000ee0  0x00000000  nop                   1283 nop
0x00000ee4  0x00000000  nop                   1284 nop
0x00000ee8  0x00000000  nop                   1285 nop
0x00000eec  0x00000000  nop                   1286 nop
0x00000ef0  0x00000000  nop                   1287 nop
0x00000ef4  0x00000000  nop                   1288 nop
0x00000ef8  0x00000000  nop                   1289 nop
0x00000efc  0x00000000  nop                   1290 nop
0x00000f00  0x00000000  nop                   1291 nop
0x00000f04  0x00000000  nop                   1292 nop
0x00000f08  0x00000000  nop                   1293 nop
0x00000f0c  0x00000000  nop                   1294 nop
0x00000f10  0x00000000  nop                   1295 nop
0x00000f14  0x00000000  nop                   1296 nop
0x00000f18  0x00000000  nop                   1297 nop
0x00000f1c  0x00000000  nop                   1298 nop
0x00000f20  0x00000000  nop                   1299 nop
0x00000f24  0x00000000  nop                   1300 nop
0x00000f28  0x00000000  nop                   1301 nop
0x00000f2c  0x00000000  nop                   1302 nop
0x00000f30  0x00000000  nop                   1303 nop
0x00000f34  0x00000000  nop                   1304 nop
0x00000f38  0x00000000  nop                   1305 nop
0x00000f3c  0x00000000  nop                   1306 nop
0x00000f40  0x00000000  nop                   1307 nop
0x00000f44  0x00000000  nop                   1308 nop
0x00000f48  0x00000000  nop                   1309 nop
0x00000f4c  0x00000000  nop                   1310 nop
0x00000f50  0x00000000  nop                   1311 nop
0x00000f54  0x00000000  nop                   1312 nop
0x00000f58  0x00000000  nop                   1313 nop
0x00000f5c  0x00000000  nop                   1314 nop
0x00000f60  0x00000000  nop                   1315 nop
0x00000f64  0x00000000  nop                   1316 nop
0x00000f68  0x00000000  nop                   1317 nop
0x00000f6c  0x00000000  nop                   1318 nop
0x00000f70  0x00000000  nop                   1319 nop
0x00000f74  0x00000000  nop                   1320 nop
0x00000f78  0x00000000  nop                   1321 nop
0x00000f7c  0x00000000  nop                   1322 nop
0x00000f80  0x00000000  nop                   1323 nop
0x00000f84  0x00000000  nop                   1324 nop
0x00000f88  0x00000000  nop                   1325 nop
0x00000f8c  0x00000000  nop                   1326 nop
0x00000f90  0x00000000  nop                   1327 nop
0x00000f94  0x00000000  nop                   1328 nop
0x00000f98  0x00000000  nop                   1329 nop
0x00000f9c  0x00000000  nop                   1330 nop
0x00000fa0  0x00000000  nop                   1331 nop
0x00000fa4  0x00000000  nop                   1332 nop
0x00000fa8  0x00000000  nop                   1333 nop
0x00000fac  0x00000000  nop                   1334 nop
0x00000fb0  0x00000000  nop                   1335 nop
0x00000fb4  0x00000000  nop                   1336 nop
0x00000fb8  0x00000000  nop                   1337 nop
0x00000fbc  0x00000000  nop                   1338 nop
0x00000fc0  0x00000000  nop                   1339 nop
0x00000fc4  0x00000000  nop                   1340 nop
0x00000fc8  0x00000000  nop                   1341 nop
0x00000fcc  0x00000000  nop                   1342 nop
0x00000fd0  0x00000000  nop                   1343 nop
0x00000fd4  0x00000000  nop                   1344 nop
0x00000fd8  0x00000000  nop                   1345 nop
0x00000fdc  0x00000000  nop                   1346 nop
0x00000fe0  0x00000000  nop                   1347 nop
0x00000fe4  0x00000000  nop                   1348 nop
0x00000fe8  0x00000000  nop                   1349 nop
0x00000fec  0x00000000  nop                   1350 nop
0x00000ff0  0x00000000  nop                   1351 nop
0x00000ff4  0x00000000  nop                   1352 nop
0x00000ff8  0x080003fe  j 0x00000ff8          1363     j __HALT
