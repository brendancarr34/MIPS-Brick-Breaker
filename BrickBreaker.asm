#############################################################################################
#
# Brendan Carr
# COMP 541 Final Project
# Nov 10, 2020
#
# This is a MIPS program that simulates the game BrickBreaker,
# using a VGA display, a keyboard, sound, and an accelerometer.
#
# This program assumes the memory-IO map introduced in class specifically for the final
# projects.  In MARS, please select:  Settings ==> Memory Configuration ==> Default.
#
#############################################################################################

.data 0x10010000 			# Start of data memory


.text 0x00400000			# Start of instruction memory

main:

	lui 	$sp, 0x1001			# Initialize stack pointer to the 64th location above start of data
	ori  	$sp, $sp, 0x1000		# top of the stack is the word at address [0x10010ffc - 0x10010fff]
	addi 	$fp, $sp, -4 			# Set $fp to the start of main's stack frame
	
	li 	$s0, 14				# initialize x-coordinate of paddle_left,  Y=24 always
	li 	$s1, 24				# initialize x-coordinate of paddle_right, Y=24 always
	li 	$s2, 19				# ball initial x-coordinate
	li 	$s3, 23				# ball initial y-coordinate
	li 	$s5, 3				# intial lives = 3
	li	$s6, 35
	
	li	$a0, 14
	move	$a1, $s2
	move	$a2, $s3
	jal 	putChar_atXY
	
	li	$a0, 15
	addi	$a1, $s6, 1
	li	$a2, 27
	jal	putChar_atXY
	
	li	$a0, 15
	addi	$a1, $s6, 2
	li	$a2, 27
	jal	putChar_atXY
	
	li	$a0, 15
	addi	$a1, $s6, 3
	li	$a2, 27
	jal	putChar_atXY
	
	j 	start
	
restart:

	bne	$s5, 0, not_new_game
	
	new_game:
	
	li	$s5, 3
	
	li	$a0, 15
	addi	$a1, $s6, 1
	li	$a2, 27
	jal	putChar_atXY
	
	li	$a0, 15
	addi	$a1, $s6, 2
	li	$a2, 27
	jal	putChar_atXY
	
	li	$a0, 15
	addi	$a1, $s6, 3
	li	$a2, 27
	jal	putChar_atXY
	
	not_new_game:

	li	$a0, 0				# make old ball turn black
	move	$a1, $s2
	move	$a2, $s3
	jal 	putChar_atXY	
	
	#################### TODO replace bar back to original spot
	
	move	$t0, $s0
	addi	$t1, $s1, 1
	
	replace_bar_loop1:
	
	li	$a0, 0				
	move	$a1, $t0
	li	$a2, 24
	jal 	putChar_atXY
	
	addi	$t0, $t0, 1
	
	bne	$t0, $t1, replace_bar_loop1
	
	
	li	$s0, 14
	li	$s1, 24
	li	$s2, 19				# reset to start
	li	$s3, 23
	
	li	$a0, 11
	move	$a1, $s0
	li	$a2, 24
	jal	putChar_atXY
	
	addi	$t0, $s0, 1
	move	$t1, $s1
	
	replace_bar_loop2:
	
	li	$a0, 13			
	move	$a1, $t0
	li	$a2, 24
	jal 	putChar_atXY
	
	addi	$t0, $t0, 1
	
	bne	$t0, $t1, replace_bar_loop2
	
	li	$a0, 12
	move	$a1, $s1
	li	$a2, 24
	jal	putChar_atXY
	
	li	$a0, 14				# put new ball back
	move	$a1, $s2
	move	$a2, $s3
	jal 	putChar_atXY
	
	li	$a0, 20
	jal	pause

start:
	
	li	$a0, 10
	jal 	pause_and_getkey		# get kepyress
	move 	$t0,$v0				# store keypress in $t0
	move 	$s4,$t0				# store keypress in $s4 - it corresponds to the direction we need
	
	li	$a0, 5
	jal 	pause
	
	beq	$t0, 1, first_move		# if keypress is right, go to first_move
	beq	$t0, 2, first_move		# if keypress is left, go to first_move
	j	start				# else wait for key again
	
first_move:
	
	addi	$a0, $0, 0			# make existing ball a black square
	move	$a1, $s2
	move	$a2, $s3
	jal 	putChar_atXY
	
	move	$a0, $s4
	jal 	move_ball
	
	li	$a0, 14
	move	$a1, $s2
	move	$a2, $s3
	jal 	putChar_atXY

	beq 	$s4, 1, move_paddle_r		# right is pressed, move paddle right
	beq 	$s4, 2, move_paddle_l		# left
	
animate_loop:

	move 	$a0,$s4				# store direction in $a0
	jal 	move_ball			# change $s2 and $s3 based on direction	
	
	li	$a0, 10
	jal 	pause	
	
	addi	$a0, $0, 0			# make existing ball a black square
	move	$a1, $s2
	move	$a2, $s3
	jal 	putChar_atXY
	
	move	$s2, $v0			# store new ballX
	move	$s3, $v1			# store new ballY
	
	addi	$a0, $0, 14
	move	$a1, $s2
	move	$a2, $s3
	jal 	putChar_atXY			# place ball at new target

	jal	find_next_move			# $s4 is updated here to the new direction
	

	# get rid of the blocks that are touched
	
	beq 	$s3,26,lost_life			# ball goes below paddle
	
	li	$a0, 1
	jal	pause_and_getkey
	move	$t0, $v0
	
	beq	$t0, 1, move_paddle_r
	beq	$t0, 2, move_paddle_l
	j	done_move_paddle			#should be a catch for no move made
	
move_paddle_r:

	jal 	move_paddle_right
	li	$t0, 0
	j	start_move_paddle
	
move_paddle_l:

	jal 	move_paddle_left
	li	$t0, 0
	j	start_move_paddle
	
start_move_paddle:
	# $t8 = x-coord of old endcap to turn black
	# $t9 = x-coord of old endcap to turn to center

	li	$a0, 0
	move	$a1, $t8
	li	$a2, 24
	jal	putChar_atXY
	
	move	$s0, $v0
	move	$s1, $v1
	
	li	$a0, 11
	move	$a1, $s0
	li	$a2, 24
	jal	putChar_atXY
	
	li	$a0, 12
	move	$a1, $s1
	li	$a2, 24
	jal	putChar_atXY
	
	li	$a0, 13
	move	$a1, $t9
	li	$a2, 24
	jal	putChar_atXY
	
done_move_paddle:
	#addi	$a0, $0, 25
	#jal 	pause
	
	j 	animate_loop
	
lost_life:

	li	$a0, 0
	add	$a1, $s6, $s5
	li	$a2, 27
	jal	putChar_atXY
	
	subi 	$s5, $s5, 1			# subtract life from $s6

	beq 	$s5, $0, end_game		# if lives = 0, end_game
	
lost_life_loop:
	li	$a0, 1
	jal	pause_and_getkey
	
	beq	$v0, $0, lost_life_loop
	
	j 	restart				

end_game:

	jal	get_key
	
	
	
	beq	$v0, 3, restart
	
	j	end_game

######## END OF MAIN #################################################################################



.text

#####################################
# procedure move_ball
# $a0:  direction (1=UR, 2=UL, 3=DR, 4=DL)
# $a1:  bounce (0=switch left/right, 1= switch up/down
#
# return values:
# $v0:  new x coord
# $v1:  new y coord
#####################################

move_ball:
	addi    $sp, $sp, -8        	# Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         	# Save $ra
    	sw      $fp, 0($sp)        	# Save $fp
    	addi    $fp, $sp, 4         	# Set $fp to the start of proc1's stack frame
    	
    	move 	$t0, $a0		# store direction in $t0
    	
up_right:
	bne	$t0,1,up_left
	
	addi	$v0, $s2, 1
	subi	$v1, $s3, 1
	
	j done_moving
	
up_left:
	bne	$t0,2,down_right
	
	subi	$v0, $s2, 1
	subi	$v1, $s3, 1
	
	j 	done_moving
	
down_right:
	bne	$t0, 3, down_left
	
	addi	$v0, $s2, 1
	addi	$v1, $s3, 1
	
	j 	done_moving
	
down_left:
	bne	$t0, 4, done_moving
	
	subi	$v0, $s2, 1
	addi	$v1, $s3, 1
	
	j	done_moving
	
done_moving:
	
return_from_move_ball:
	addi    $sp, $fp, 4     	# Restore $sp
    	lw      $ra, 0($fp)     	# Restore $ra
    	lw      $fp, -4($fp)    	# Restore $fp
    	jr      $ra             	# Return from procedure
    	
# =============================================================

#####################################
# procedure move_paddle_right
#
# return values:
# $v0:  new left x coord of paddle
# $v1:  new right x coord of paddle
# $t9:  new center piece x coord
# $t8:  new black square
#####################################

move_paddle_right:
	addi    $sp, $sp, -8        	# Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         	# Save $ra
    	sw      $fp, 0($sp)        	# Save $fp
    	addi    $fp, $sp, 4         	# Set $fp to the start of proc1's stack frame
    	
    	move	$t8, $s0
    	move	$t9, $s1
    	move 	$v0, $s0
    	move	$v1, $s1
    	
    	beq	$v1, 39, return_from_move_paddle_right	# check that the paddle isnt already all the way to the right
    	

    	addi	$v0, $v0, 1
    	addi	$v1, $v1, 1
    	
return_from_move_paddle_right:
	addi    $sp, $fp, 4     	# Restore $sp
    	lw      $ra, 0($fp)     	# Restore $ra
    	lw      $fp, -4($fp)    	# Restore $fp
    	jr      $ra             	# Return from procedure
    	
# =============================================================

#####################################
# procedure move_paddle_left
#
# return values:
# $v0:  new left x coord of paddle
# $v1:  new right x coord of paddle
# $t9:	new middle paddle piece
# $t8:  new black square
#####################################

move_paddle_left:
	addi    $sp, $sp, -8        	# Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         	# Save $ra
    	sw      $fp, 0($sp)        	# Save $fp
    	addi    $fp, $sp, 4         	# Set $fp to the start of proc1's stack frame
    	
    	move	$t8, $s1		# this will be
    	move	$t9, $s0
    	move	$v0, $s0
    	move	$v1, $s1
    	
    	beq	$v0, 0, return_from_move_paddle_left
    	

    	subi	$v0, $v0, 1
    	subi	$v1, $v1, 1

return_from_move_paddle_left:
	
	addi    $sp, $fp, 4     	# Restore $sp
    	lw      $ra, 0($fp)     	# Restore $ra
    	lw      $fp, -4($fp)    	# Restore $fp
    	jr      $ra             	# Return from procedure

# =============================================================	

#####################################
# procedure find_next_move
#
# return values:
# $v0:  new direction
# $s6:  block1 to remove?
# $s7:  block2 to remove?
#####################################

find_next_move:

	addi    $sp, $sp, -8        	# Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         	# Save $ra
    	sw      $fp, 0($sp)        	# Save $fp
    	addi    $fp, $sp, 4         	# Set $fp to the start of proc1's stack frame
    	
    	beq	$s4, 1, moving_UR
    	beq	$s4, 2, moving_UL
    	beq	$s4, 3, moving_DR
    	beq	$s4, 4, moving_DL
    	j	return_from_find_next_move
    	
moving_UR:
	
	beq	$s2, 39, wall_bounce		# if X = 39, wall bounce, also checks for corners
	
	beq	$s3, $0, ceiling_bounce		# if Y = 0, celing bounce
	
	move	$a1, $s2
	subi	$a2, $s3, 1
	jal	getChar_atXY			# if char(X,Y-1) is not 0, there is a block above
	
	bne	$v0, $0, above_bounce		# bounce above
	
	addi	$a1, $s2, 1	
	move	$a2, $s3
	jal 	getChar_atXY			# if char(X+1,Y) is not 0, there is an adjacent block
	
	bne	$v0, $0, adj_bounce		# adj_bounce
	
	addi	$a1, $s2, 1
	subi	$a2, $s3, 1
	jal	getChar_atXY			# char(X+1, Y-1)
	move	$t0, $v0
	
	beq	$t0, 0, not_at_corner_block_UR
	
	move	$a0, $0
	addi	$a1, $s2, 1
	subi	$a2, $s3, 1
	jal	putChar_atXY
	
	move	$a0, $0
	addi	$a1, $s2, 2
	subi	$a2, $s3, 1
	jal	putChar_atXY
	
	j	to_DL
	
	not_at_corner_block_UR:
	
	j	return_from_find_next_move	# else direction doesnt change
	
moving_UL:
	
	beq	$s2, $0, wall_bounce		# if X = 0, wall bounce, also checks for corners
	
	beq	$s3, $0, ceiling_bounce		# if Y = 0, ceiling bounce
	
	move	$a1, $s2
	subi	$a2, $s3, 1
	jal	getChar_atXY			# char(x,y-1)
	
	bne	$v0, $0, above_bounce		# bounce above
	
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	getChar_atXY			# if char(X-1,Y) is not 0, there is an adjacent block
	
	bne	$v0, $0, adj_bounce		# adj_bounce
	
	subi	$a1, $s2, 1
	subi	$a2, $s3, 1
	jal	getChar_atXY
	
	beq	$v0, $0, not_at_corner_block_UL
	
	move	$a0, $0
	subi	$a1, $s2, 1
	subi	$a2, $s3, 1
	jal	putChar_atXY
	
	move	$a0, $0
	subi	$a1, $s2, 2
	subi	$a2, $s3, 1
	jal	putChar_atXY
	
	j	to_DR
	
	not_at_corner_block_UL:
	
	j	return_from_find_next_move	# else direction stays the same
	

moving_DR:

	beq	$s2, 39, wall_bounce		# if X = 39, wall bounce, this also checks for corner
	
	beq	$s3, 23, paddle_check		# if Y = 23, check for a paddle_center
	
	beq	$s3, 24, done_moving
	
	move	$a1, $s2
	addi	$a2, $s3, 1
	jal	getChar_atXY			# char(x,y+1)
	
	bne	$v0, $0, below_bounce		# bounce below
	
	addi	$a1, $s2, 1	
	move	$a2, $s3
	jal 	getChar_atXY			# if char(X+1,Y) is not 0, there is an adjacent block
	
	bne	$v0, $0, adj_bounce		# adj_bounce
	
	addi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	getChar_atXY
	
	beq	$v0, $0, not_at_corner_block_DR
	
	move	$a0, $0
	addi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	putChar_atXY
	
	move	$a0, $0
	addi	$a1, $s2, 2
	addi	$a2, $s3, 1
	jal	putChar_atXY
	
	j	to_UL
	
	not_at_corner_block_DR:
	
	# continue moving_DR.. check for adjacent blocks & ones below
	
	j 	return_from_find_next_move

moving_DL:

    	beq	$s2, 0, wall_bounce		# if X = 0, wall bounce, this also checks for corner
    	
    	beq	$s3, 23, paddle_check		# if Y = 23, check for paddle_center
    	
    	beq	$s3, 24, done_moving
    	
    	move	$a1, $s2
	addi	$a2, $s3, 1
	jal	getChar_atXY			# char(x,y+1)
	
	bne	$v0, $0, below_bounce		# bounce below
	
	subi	$a1, $s2, 1	
	move	$a2, $s3
	jal 	getChar_atXY			# if char(X-1,Y) is not 0, there is an adjacent block
	
	bne	$v0, $0, adj_bounce
	
	subi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	getChar_atXY
	
	beq	$v0, $0, not_at_corner_block_DL
	
	move	$a0, $0
	subi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	putChar_atXY
	
	move	$a0, $0
	subi	$a1, $s2, 2
	addi	$a2, $s3, 1
	jal	putChar_atXY
	
	j	to_UR
	
	not_at_corner_block_DL:
    	
    	j	return_from_find_next_move
    	
corner_bounce:

	beq	$s4, 1, to_DL
	beq	$s4, 2, to_DR
	beq	$s4, 3, to_UL
	beq	$s4, 4, to_UR
    	
wall_bounce:

	beq	$s3, $0, corner_bounce
	beq	$s2, $0, check_UL_wall_adj
	beq	$s2, 39, check_UR_wall_adj
	beq	$s3, 24, corner_bounce

	# check if there is an adjacent block
	
	bne	$s4, 1, check_UL_wall_adj
	
	check_UR_wall_adj:
	
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	getChar_atXY
	
	beq	$v0, $0, continue_wall_bounce
	
	li	$a0, 0
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	subi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	to_DL
	
	check_UL_wall_adj:
	
	addi	$a1, $s2, 1
	move	$a2, $s3
	jal	getChar_atXY
	
	beq	$v0, 0, continue_wall_bounce
	
	li	$a0, 0
	addi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	addi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	to_DR
	
	#beq	$s2, , corner_bounce

	continue_wall_bounce:
	
	beq	$s4, 1, to_UL
	beq	$s4, 2, to_UR
	beq	$s4, 3, to_DL
	beq	$s4, 4, to_DR
	
	j	return_from_find_next_move    # catch
	
ceiling_bounce:

	bne	$s4, 1, below_left_check

	below_right_check:

	addi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	getChar_atXY
	
	beq	$v0, $0, no_interference
	
	move	$a0, $0
	addi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	putChar_atXY
	
	move	$a0, $0
	addi	$a1, $s2, 2
	addi	$a2, $s3, 1
	jal	putChar_atXY
	
	j	to_DL
	
	below_left_check:
	
	bne	$s4, 2, no_interference
	
	subi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	getChar_atXY
	
	beq	$v0, $0, no_interference
	
	move	$a0, $0
	subi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	putChar_atXY
	
	move	$a0, $0
	subi	$a1, $s2, 2
	addi	$a2, $s3, 1
	jal	putChar_atXY
	
	j	to_DR
	
	no_interference:
	
	beq	$s4, 1, to_DR
	beq	$s4, 2,	to_DL
	
	j	return_from_find_next_move    # catch
	
paddle_bounce:

	beq	$s4, 3, paddle_bounce_UR
	beq	$s4, 4, paddle_bounce_UL
	
paddle_bounce_UR:

	li	$s4, 1
	
	j 	animate_loop
	
paddle_bounce_UL:

	li	$s4, 2
	
	j	animate_loop
	
adj_bounce:

	UR_adj:

	bne	$s4, 1, UL_adj
	
	li	$a0, 0
	addi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	addi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	adj_set_direction
	
	UL_adj:
	
	bne	$s4, 2, DR_adj
	
	li	$a0, 0
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	subi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	adj_set_direction
	
	DR_adj:
	
	bne	$s4, 3, DL_adj
	
	li	$a0, 0
	addi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	addi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	adj_set_direction
	
	DL_adj:
	
	bne	$s4, 4, adj_set_direction
	
	li	$a0, 0
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	subi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	adj_set_direction
	
	# if not a corner, switch left/right dir and remove adj block
	
	######### SET BLOCK TO REMOVE FOR ADJ BLOCK ONLY HERE
	
	adj_set_direction:
	
	beq	$s4, 1, to_UL
	beq	$s4, 2, to_UR
	beq	$s4, 3, to_DL
	beq	$s4, 4, to_DR

	j return_from_find_next_move

above_bounce:
	# check char(X,Y-1) if occupied & dir = 1, new_dir = 3; if occupied  & dir = 2, new_dir = 4;
	move	$a1, $s2
	subi	$a2, $s3, 1
	jal	getChar_atXY		# get char(X, Y-1)
	
	move	$t0, $v0		# store it in $t0
	
	li	$a0, 0
	move	$a1, $s2
	subi	$a2, $s3, 1
	jal	putChar_atXY		# make char(X, Y-1) = 0
	
	addi	$a1, $s2, 1		# get char (X+1, Y-1)
	subi	$a2, $s3, 1
	jal	getChar_atXY
	
	move	$t1, $v0
	addi	$t0, $t0, 1
	
	beq	$t0, $t1, remove_right_above	# if char(X+1,Y-1)=char(X,Y-1)+1 delete both
						# else, delete above and above_left
	remove_left_above:
	li	$a0, 0
	subi	$a1, $s2, 1
	subi	$a2, $s3, 1
	jal	putChar_atXY
	
	j	check_corner_up
	
	remove_right_above:
	li	$a0, 0
	addi	$a1, $s2, 1
	subi	$a2, $s3, 1
	jal	putChar_atXY
	
	j	check_corner_up
	
	check_corner_up:
	
	UR_corner_check:
	
	bne	$s4, 1, UL_corner_check
	
	addi	$a1, $s2, 1
	move	$a2, $s3
	jal	getChar_atXY
	beq	$v0, $0, above_set_direction		# not a corner
	
	li	$a0, 0
	addi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	addi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	to_DL
	
	UL_corner_check:
	bne	$s4, 2, above_set_direction		# catch
	
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	getChar_atXY
	beq	$v0, $0, above_set_direction
	
	li	$a0, 0
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	subi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	to_DR
	
	above_set_direction:
	beq	$s4, 1, to_DR				# switch up/down direction
	beq	$s4, 2, to_DL

	j return_from_find_next_move
	
below_bounce:

	# check char(X,Y+1) if dir = __ , char( ) if dir = ____
	
	move	$a1, $s2
	addi	$a2, $s3, 1
	jal	getChar_atXY
	
	move	$t0, $v0
	
	li	$a0, 0
	move	$a1, $s2
	addi	$a2, $s3, 1
	jal	putChar_atXY		# make char(X, Y+1) = 0
	
	addi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	getChar_atXY		# char(X+1, Y+1)
	
	move	$t1, $v0
	addi	$t0, $t0, 1
	bne	$t0, $t1, remove_left_below
	
	remove_right_below:
	
	li	$a0, 0
	addi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	putChar_atXY		# make char(X+1, Y+1) = 0
	
	j	check_corner_down
	
	remove_left_below:
	
	li	$a0, 0
	subi	$a1, $s2, 1
	addi	$a2, $s3, 1
	jal	putChar_atXY		# make char(X-1, Y+1) = 0
	
	j	check_corner_down
	
	check_corner_down:
	
	DR_corner_check:
	
	bne	$s4, 3, DL_corner_check
	
	addi	$a1, $s2, 1
	move	$a2, $s3
	jal	getChar_atXY
	beq	$v0, $0, below_set_direction
	
	li	$a0, 0
	addi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	addi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	to_UL
	
	DL_corner_check:
	
	bne	$s4, 4, below_set_direction
	
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	getChar_atXY
	beq	$v0, $0, below_set_direction
	
	li	$a0, 0
	subi	$a1, $s2, 1
	move	$a2, $s3
	jal	putChar_atXY
	
	li	$a0, 0
	subi	$a1, $s2, 2
	move	$a2, $s3
	jal	putChar_atXY
	
	j	to_UR
	
	below_set_direction:
	
	beq	$s4, 3, to_UR
	beq	$s4, 4, to_UL

	j return_from_find_next_move
	
paddle_check:

	addi	$t0, $s0, 1		# leftmost center piece of paddle
	blt	$s2, $t0, done_moving	# if x < leftmost paddle, dont change direction
	
	subi	$t0, $s1, 1
	bgt	$s2, $t0, done_moving
	
	beq	$s4, 3, to_UR
	beq	$s4, 4, to_UL
	
	j 	return_from_find_next_move	
    	
to_DR:

	li	$s4, 3
	j	return_from_find_next_move

to_DL:

	li	$s4, 4
	j	return_from_find_next_move

to_UR:

	li	$s4, 1
	j	return_from_find_next_move

to_UL:

	li	$s4, 2
	j	return_from_find_next_move
    	
return_from_find_next_move:

	addi    $sp, $fp, 4     	# Restore $sp
    	lw      $ra, 0($fp)     	# Restore $ra
    	lw      $fp, -4($fp)    	# Restore $fp
    	jr      $ra             	# Return from procedure

.include "procs_board.asm"             # Use this line for board implementation
#.include "proc_mars.asm"               # Use this line for simulation in MARS
