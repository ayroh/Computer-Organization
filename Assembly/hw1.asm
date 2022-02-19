	.data
space: .asciiz " "
endl: .asciiz  "\n"
arr: .space 804 	          # read all lines from file
result: .asciiz "result.txt"      # result filename
file: .asciiz "array.txt"	  # filename
input: .asciiz "Array_inp: "
maximum_array: .asciiz " | Array_outp: "
size: .asciiz " | size: " 
bufferarr: .space 40	   # buffer array for single line
curarr: .space 40          # current array to evaluate bufferarr and compare it with maxarr
maxarr: .space 40	   # array with maximum length
iter: .word 0              # to iterate through buffer array also through this we find 'curarr's size to compare it with maxsize
arrsize: .word 0	   # size of array from read file
maxsize: .word 0	   # size of array with maximum size



	

	.text
	.globl main
main:
	jal read_all_file # reads all file and writes it to arr
	
	# Open (for writing) a file
	li $v0 13     # open file
	la $a0 result # result file name
	li $a1 1      # write mode
	syscall       # open a file (file descriptor returned in $v0)
	move $s3 $v0  # save the file descriptor
	
	la $s4 arr	# from now on we iterate through this array line by line
move_on:
	la $t0 bufferarr # memory to registers
	la $t1 maxarr
	la $t6 curarr
	lw $t4 arrsize
	lw $t5 maxsize
	jal read_line    # reads 1 line from arr and stores it to bufferarr
	la $t0 bufferarr # address of start of bufferarr
	addi $s4 $s4 1   # add 1 for reaching the next line for next line
	la $t1 maxarr	 # address of start of maxarr
	la $t6 curarr    # address of start of curarr
	j evaluate_line  # finds all possibilities, prints it to console and stores longest one to maxarr
evaluated:
	li $v0 4 # print new line to console to separate all lines of curarr's
	la $a0 endl
	syscall
	
	jal write_to_file # writes bufferarr + maxarr + size to file
	beq $a3 1 end # this means we read last line
	sw $zero maxsize # restart maxsize
	la $t0 bufferarr # address of start of bufferarr
	la $t1 maxarr    # address of start of maxarr
	jal clear_max_array # since we write maxarr already to file its time to clear it for next line
	j move_on # read next line

	end:
	# Close the file 
	li $v0, 16       # system call for close file
	move $a0, $s3    # Restore file descriptor
	syscall          # close file
	  
li $v0, 10 		# end the file
syscall 
	  
	  
########################################################	  
	  
	  
read_all_file: # reads all file and writes it to arr

	# Open (for reading) a file
	li $v0, 13       # system call for open file
	la $a0, file     # board file name
	li $a1, 0        # Open for reading
	syscall            # open a file (file descriptor returned in $v0)
	move $s3, $v0      # save the file descriptor
	
	# Read to file just opened 
	li $v0, 14       # system call for read to file
	move $a0, $s3    # put the file descriptor in $a0		
	la $a1, arr      # address of array from which to write
	li $a2, 800        # hardcoded buffer length
	syscall          # read from file	  

	li $v0, 16       # system call for close file
	move $a0, $s3    # Restore fd
	syscall          # close file
	
	jr $ra





read_line: # reads 1 line from arr and stores it to bufferarr
	add $t4 $zero $zero # clearing arrsize to 0
	la $t0 bufferarr # address of start of bufferarr
reading_loop:	
	lb $t2,($s4)	# takes 1 element from line
	beq $t2 0 end_reading # return if end of file
	beq $t2 10 end_reading_loop	# return if end of line
	
	addi $t2 $t2 -48 # ascii to number
	addi $t4 $t4 1 # adding arrsize 1
	addi $s4 $s4 2 # add arr 2 to skip commas and reach next number
	sb  $t2 ($t0)	# store it to bufferarr
	addi $t0 $t0 4 # iterate to next bufferarr storage
	j reading_loop
end_reading:	
	li $a3 1 # flag for running program one last time
end_reading_loop:
	jr $ra

	
	
			
new_max_array:	# if current arrays size is bigger than maxsize then store it to maxarr
	move $t5 $t7	# new maxsize is current arrsize
	sw $t5 maxsize # store it to stack
	li $t8 0 # creating new variable for 'for' loop
	la $t6 curarr # address of start of curarr
	la $t1 maxarr    # address of start of maxarr
new_max_loop:
	lb $t2 ($t6) # current array to register
	sb $t2 ($t1) # register to maxarray
	addi $t8 $t8 1 # incrementing for 'for' loop
	beq $t5 $t8 new_max_array_return # if all elements transfered end function

	addi $t6 $t6 4 # incrementing buffer array iteration
	addi $t1 $t1 4 # incrementing max array iteration
	j new_max_loop
			
	
evaluate_line: # finds all possibilities, prints it to console and stores longest one to maxarr
	li $s5 0    # for outer loop
	li $s6 0    # for middle loop
	li $s7 0    # for inner loop
	la $t0 bufferarr # address of start of bufferarr, this one is to reach from start and changes only through outer loop
	la $t9 bufferarr # address of start of bufferarr, this one is to iterate it through all loops
	la $t6 curarr # address of start of curarr
outer_loop:	 # for(i = 0;i < arrsize;i++)
	la $t9 bufferarr # reset it for all outer_loops
	
	li $t7 0    # iter to register
	li $t2 4	# calculating bufferarr[i]
	mult $s5 $t2	# calculating bufferarr[i]
	mflo $t2	# calculating bufferarr[i]
	add $t9 $t9 $t2 # incrementing outer loop counter like iterator
	lb $t3 ($t9)    # load from bufferarr[i] to t3
	sub $t9 $t9 $t2 # decrementing it because we still need it as counter
	
	li $t2 4	 # calculating curarr[iter]
	mult $t7 $t2	 # calculating curarr[iter]
	mflo $t2 	 # calculating curarr[iter]
	add $t6 $t6 $t2  # incrementing curarr iterator
	sb $t3 ($t6)     # save t3 to curarr[iter]
	sub $t6 $t6 $t2  # decrementing it because we still need it as fixed counter
	
	addi $t7 $t7 1 # incrementing iter because we fill curarr's first element as outer_loops first element
	addi $s6 $s5 1 # j = i + 1
	beq $s6 $t4 last_loop # this possibility is if j == arrsize, for loop ends for j
	middle_loop:	# for(j = i + 1;j < arrsize;j++)
		la $t9 bufferarr # address of start of bufferarr
		
		li $t2 4	# calculating bufferarr[i]
		mult $s6 $t2	# calculating bufferarr[j]
		mflo $t2	# calculating bufferarr[j]
		add $t9 $t9 $t2 # incrementing middle loop counter like iterator
		lb $t3 ($t9)    # load from bufferarr[j]
		sub $t9 $t9 $t2	# decrementing it because we still need it as counter
		li $t2 4	 # calculating curarr[iter]
		mult $t7 $t2	 # calculating curarr[iter]
		mflo $t2 	 # calculating curarr[iter]
		addi $t2 $t2 -4  # because we need (iter-1) * 4 byte
		add $t6 $t6 $t2  # incrementing curarr iterator
		lb $t8 ($t6)     # load curarr[iter-1] to t8
		sub $t6 $t6 $t2  # decrementing it because we still need it as fixed counter
		
		slt $t9 $t3 $t8	 # 	  if(arr[j] < curarr[iter-1]) continue;
		beq $s6 $t4 jump_continue # this operation prevents us from printing same array more than one time
		add $s6 $s6 $t9  # stores if 'slt $t9 $t3 $t8' is true
		beq $s6 $t4 last_loop # this possibility is if j == arrsize, 'for' loop ends for j
		beq $t9 1 middle_loop # continue;
		jump_continue:
		la $t9 bufferarr # address of start of bufferarr
		move $s7 $s6 # k = j
		inner_loop:	#for(k = j;k < arrsize;k++)
			li $t2 4	# calculating bufferarr[k]
			mult $s7 $t2	# calculating bufferarr[k]
			mflo $t2	# calculating bufferarr[k]
			add $t9 $t9 $t2 # incrementing inner loop counter like iterator
			lb $t3 ($t9)    # load from bufferarr[k]
			sub $t9 $t9 $t2	# decrementing it because we still need it as counter
			
			li $t2 4	 # calculating curarr[iter]
			mult $t7 $t2	 # calculating curarr[iter]
			mflo $t2 	 # calculating curarr[iter]
			addi $t2 $t2 -4  # because we need (iter-1) * 4 byte
			add $t6 $t6 $t2  # incrementing curarr iterator
			lb $t8 ($t6)     # load curarr[iter-1] to t8
			sub $t6 $t6 $t2  # decrementing it because we still need it as fixed counter
			
			ble $t3 $t8 inner_loop_not_equal  #    if(arr[k] <= curarr[iter - 1])
		
			li $t2 4	# calculating bufferarr[k]
			mult $s7 $t2	# calculating bufferarr[k]
			mflo $t2	# calculating bufferarr[k]
			add $t9 $t9 $t2 # incrementing inner loop counter like iterator
			lb $t3 ($t9)    # load from bufferarr[k]
			sub $t9 $t9 $t2	# decrementing it because we still need it as counter
			
			li $t2 4	 # calculating curarr[iter]
			mult $t7 $t2	 # calculating curarr[iter]
			mflo $t2 	 # calculating curarr[iter]
			add $t6 $t6 $t2  # incrementing curarr iterator
			sb $t3 ($t6)     # save bufferarr[k] to curarr[iter]
			sub $t6 $t6 $t2  # decrementing it because we still need it as fixed counter
			
			addi $t7 $t7 1   # incrementing iter because we added an element to curarr
			inner_loop_not_equal:
			addi $s7 $s7 1 # increment inner loop
			bne $s7 $t4 inner_loop
			
		j print_curarr # prints curarr to console
		end_of_print:		
		
		bgt  $t7 $t5 new_max_array # if current arrays size is bigger than maxsize then store it to maxarr
		new_max_array_return:
		
		jal clear_curarr # clears current array since we already printed it to console for next line
		la $t6 curarr # address of start of curarr
		li $t7 0 # restart iter to 0
		
		# fills curarr's first element as outer_loops first element like start of outer_loop
		li $t2 4	# calculating bufferarr[i]
		mult $s5 $t2	# calculating bufferarr[i]
		mflo $t2	# calculating bufferarr[i]
		add $t9 $t9 $t2 # incrementing outer loop counter like iterator
		lb $t3 ($t9)    # load from bufferarr[i] to t3
		sub $t9 $t9 $t2	# decrementing it because we still need it as counter
	
		li $t2 4	 # calculating curarr[iter]
		mult $t7 $t2	 # calculating curarr[iter]
		mflo $t2 	 # calculating curarr[iter]
		add $t6 $t6 $t2  # incrementing curarr iterator
		sb $t3 ($t6)     # save t3 to curarr[iter]
		sub $t6 $t6 $t2 # decrementing it because we still need it as counter

		addi $t7 $t7 1 # incrementing iter we added an element to curarr
		
		la $t1 maxarr # address of start of maxarr
		addi $s6 $s6 1 # increment middle_loops counter
		bne $s6 $t4 middle_loop # if j == arrsize
		last_loop:
		jal clear_curarr # clears current array since we already printed it to console for next line
		la $t6 curarr # address of start of curarr
		
		
	
	addi $t0 $t0 4 # add 4 for next outer_loop bufferarr
	addi $s5 $s5 1 # incrementing outer_loop counter
	bne $s5 $t4 outer_loop	# if i == arrsize
	j evaluated
	


clear_curarr: # clears curarr
	la $s2 curarr # address of start of curarr
	li $t2 0
clear_curarr_loop:
	sb $zero ($s2) # set curarr to 0
	addi $s2 $s2 4 # increment iterator
	addi $t2 $t2 1 # increment counter
	bne $t2 $t4 clear_curarr_loop
	jr $ra

print_curarr: # prints curarr to console
	li $t2 0
	la $s2 curarr  # address of start of curarr
	lb $t5 maxsize # load maxsize
print_loop:
	li $v0 1     # print integer to console
	lb $a0 ($s2) # load curarr's element
	syscall
	
	addi $s2 $s2 4 		# increment iterator
	addi $t2 $t2 1		# increment counter
	bne $t2 $t7 print_loop  # t7 is iter size
	
	li $v0 4   # print new line to console
	la $a0 endl
	syscall

	j end_of_print


clear_max_array:
	la $s2 maxarr # address of start of maxarr 
	li $t2 0      # counter
clear_maxarr_loop:
	sb $zero ($s2) # clear maxarr
	addi $s2 $s2 4 # increment iterator
	addi $t2 $t2 1 # increment counter
	bne $t2 $t4 clear_maxarr_loop
	jr $ra

			
write_to_file: # writes bufferarr + maxarr + size to file
	li $t2 0         # arrsize is $t4
	la $t0 bufferarr # address of start of bufferarr
	move $a0, $s3    # put the file descriptor in $a0	

	li $v0, 15       # system call for read to file
	la $a1, input    # address of array from which to write
	li $a2, 11       # hardcoded buffer length
	syscall          # write to file
print_buffer: # prints bufferarr to file
	lb $t9 ($t0)     # update bufferarr with +48 for ascii
	add $t9 $t9 48
	sb $t9 ($t0)
	
	li $v0, 15       # system call for read to file
	la  $a1, ($t0)   # address of array from which to write
	li $a2, 1        # hardcoded buffer length
	syscall          # write to file
	
	li $v0, 15       # system call for read to file
	la $a1, space    # address of space from which to write
	li $a2, 1        # hardcoded buffer length
	syscall          # write to file
	
	add $t0 $t0 4    # increment iterator
	add $t2 $t2 1	 # increment counter
	bne $t2 $t4 print_buffer
	
	li $v0, 15       # system call for read to file
	la $a1, maximum_array     # address of array from which to write
	li $a2, 15       # hardcoded buffer length
	syscall          # write to file
	
	li $t2 0 # maxsize is $t5
	la $t1 maxarr
print_max: # prints maxarr to file
	lb $t9 ($t1)     # update maxarr with +48 for ascii
	add $t9 $t9 48
	sb $t9 ($t1)
	
	li $v0, 15       # system call for read to file
	la $a1, ($t1)    # address of array from which to write
	li $a2, 1        # hardcoded buffer length
	syscall          # write to file
	
	li $v0, 15       # system call for read to file
	la $a1, space    # address of space from which to write
	li $a2, 1        # hardcoded buffer length
	syscall          # write to file
	
	add $t1 $t1 4    # increment iterator
	add $t2 $t2 1	 # increment counter
	bne $t2 $t5 print_max    
	
	
	# prints size of maxarr to file
	li $v0, 15       # system call for read to file
	la $a1, size     # address of array from which to write
	li $a2, 9        # hardcoded buffer length
	syscall          # write to file
	
	li $v0 15
	add $t5 $t5 48   # update size with +48 for ascii
	sw $t5 maxsize   # store it to maxsize for reading through stack
	la $a1 maxsize   # address of array from which to write
	li $a2 1         # hardcoded buffer length
	syscall          # write to file
	add $t5 $t5 -48  # update size with -48 after writing to file
	sw $t5 maxsize	 # store it back to maxsize

	# prints new line to file
	li $v0 15
	la $a1 endl      # address of endl from which to write
	li $a2 1         # hardcoded buffer length
	syscall          # write to file
	
	jr $ra	
	
	
	

	
	
