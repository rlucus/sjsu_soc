## TASK 1: Calculate Fibonacci numbers.
# Compute first twelve Fibonacci numbers and put in array, then print
.eqv	fibs	0x1000 # 12 words
	.text
PROC_CALC_FIBONACCI:
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
beq $zero, $zero, PROC_CALC_FIBONACCI # Keep running the task forever
# End CalcFibonacci

# Surplus stuff to use if we ever implement syscall:
      #la   $a0, fibs        # first argument for print (array)
      #add  $a1, $zero, $t5  # second argument for print (size)
      #jal  print            # call print routine. 
      #li   $v0, 10          # system call for exit
      #syscall               # we are out of here.
		
# Syscall is not supported, so this whole routine is commented out
#########  routine to print the numbers on one line. 
#
#      .data
#space:.asciiz  " "          # space to insert between numbers
#head: .asciiz  "The Fibonacci numbers are:\n"
#      .text
#print:add  $t0, $zero, $a0  # starting address of array
#      add  $t1, $zero, $a1  # initialize loop counter to array size
#      la   $a0, head        # load address of print heading
#      li   $v0, 4           # specify Print String service
#      syscall               # print heading
#out:  lw   $a0, 0($t0)      # load fibonacci number for syscall
#      li   $v0, 1           # specify Print Integer service
#      syscall               # print fibonacci number
#      la   $a0, space       # load address of spacer for syscall
#      li   $v0, 4           # specify Print String service
#      syscall               # output string
#      addi $t0, $t0, 4      # increment address
#      addi $t1, $t1, -1     # decrement loop counter
#      bgtz $t1, out         # repeat if not finished
#      jr   $ra              # return
