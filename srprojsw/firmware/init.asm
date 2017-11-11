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
