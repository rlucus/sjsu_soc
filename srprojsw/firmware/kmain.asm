.globl __KMAIN, __HALT
.text
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
	
__HALT:	# End of program
