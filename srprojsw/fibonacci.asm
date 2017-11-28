## TASK 1: Calculate Fibonacci numbers.
# Compute first twelve Fibonacci numbers and put in array, then print
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
