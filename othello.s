########################################################################
# Othello!
#
# A simple game of Othello.
#
########################################################################

# Constant definitions.

# Bools
TRUE  = 1
FALSE = 0

# Players
PLAYER_EMPTY = 0
PLAYER_BLACK = 1
PLAYER_WHITE = 2

# Character shown when rendering board
WHITE_CHAR         = 'W'
BLACK_CHAR         = 'B'
POSSIBLE_MOVE_CHAR = 'x'
EMPTY_CELL_CHAR    = '.'

# Smallest and largest possible board sizes (standard Othello board size is 8)
MIN_BOARD_SIZE = 4
MAX_BOARD_SIZE = 12

# There are 8 directions a capture line can have (2 vertical, 2 horizontal and 4 diagonal).
NUM_DIRECTIONS = 8

# Some constants for accessing vectors
VECTOR_ROW_OFFSET = 0
VECTOR_COL_OFFSET = 4
SIZEOF_VECTOR     = 8


########################################################################
# DATA SEGMENT
	.data
	.align 2

# The actual board size, selected by the player
board_size:		.space 4

# Who's turn it is - either PLAYER_BLACK or PLAYER_WHITE
current_player:		.word PLAYER_BLACK

# The contents of the board
board:			.space MAX_BOARD_SIZE * MAX_BOARD_SIZE

# The 8 directions which a line can have when capturing
directions:
	.word	-1, -1  # Up left
	.word	-1,  0  # Up
	.word	-1,  1  # Up right
	.word	 0, -1  # Left
	.word	 0,  1  # Right
	.word	 1, -1  # Down left
	.word	 1,  0  # Down
	.word	 1,  1  # Down right

welcome_to_reversi_str:		.asciiz "Welcome to Reversi!\n"
board_size_prompt_str:		.asciiz "How big do you want the board to be? "
wrong_board_size_str_1:		.asciiz "Board size must be between "
wrong_board_size_str_2:		.asciiz " and "
wrong_board_size_str_3:		.asciiz "\n"
board_size_must_be_even_str:	.asciiz "Board size must be even!\n"
board_size_ok_str:		.asciiz "OK, the board size is "
white_won_str:			.asciiz "The game is a win for WHITE!\n"
black_won_str:			.asciiz "The game is a win for BLACK!\n"
tie_str:			.asciiz "The game is a tie! Wow!\n"
final_score_str_1:		.asciiz	"Score for black: "
final_score_str_2:		.asciiz ", for white: "
final_score_str_3:		.asciiz ".\n"
whos_turn_str_1:		.asciiz "\nIt is "
whos_turn_str_2:		.asciiz "'s turn.\n"
no_valid_move_str_1:		.asciiz "There are no valid moves for "
no_valid_move_str_2:		.asciiz "!\n"
game_over_str_1:		.asciiz "There are also no valid moves for "
game_over_str_2:		.asciiz "...\nGame over!\n"
enter_move_str:			.asciiz "Enter move (e.g. A 1): "
invalid_row_str:		.asciiz "Invalid row!\n"
invalid_column_str:		.asciiz "Invalid column!\n"
invalid_move_str:		.asciiz "Invalid move!\n"
white_str:			.asciiz "white"
black_str:			.asciiz "black"
board_str:			.asciiz "Board:\n   "


################################################################################
# .TEXT <main>
	.text
main:
	# Args:     void
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra]
	# Uses:     [$v0, $a0]
	# Clobbers: [$v0, $a0]
	#
	# Locals:
	#   - 
	#
	# Structure:
	#   main
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]

main__prologue:
	begin
	push	$ra

main__body:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, welcome_to_reversi_str	#
	syscall					# printf("%s", "Welcome to Reversi!\n");

	jal	read_board_size

	jal	initialise_board

	jal	place_initial_pieces

	jal	play_game


main__epilogue:
	pop	$ra
	end

	jr	$ra				# return;


################################################################################
# Read in the board size, and check that it's not too big, not too small, and even.
# If it isn't, ask agin.
# .TEXT <read_board_size>
	.text
read_board_size:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $v0, $a0]
	# Clobbers: [$t0, $t1, $v0, $a0]
	#
	# Locals:
	#   - $t0, $t1
	#
	# Structure:
	#   read_board_size
	#   -> [prologue]
	#       -> body
	#		-> read_board_size_first_if
	#		-> read_board_size_second_if	
	#		-> read_board_size__end
	#   -> [epilogue]

read_board_size__prologue:

read_board_size__body:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, board_size_prompt_str	#
	syscall					# printf("%s", "How big do you want the board to be? ");

	li	$v0, 5				# syscall 5: read_int
	syscall					#
	move	$t0, $v0			# scanf("%d", &board_size);

	#board size is in $t0

read_board_size_first_if:
	slt	$t1, $t0, MIN_BOARD_SIZE	# set $t1 to 1 if board_size < MIN_BOARD_SIZE, else 0
	sgt	$t2, $t0, MAX_BOARD_SIZE	# set $t2 to 1 if board_size > MAX_BOARD_SIZE, else 0
	or	$t3, $t1, $t2			# set $t3 to 1 if $t2 OR $t1 is true, else 0

	bne	$t3, 1, read_board_size_second_if

	li	$v0, 4				# syscall 4: print_string
	la	$a0, wrong_board_size_str_1	#
	syscall					# printf("%s", "Board size must be between ");

	li 	$a0, MIN_BOARD_SIZE     	#   printf("%d" MIN_BOARD_SIZE);
    	li   	$v0, 1
    	syscall

	li	$v0, 4				# syscall 4: print_string
	la	$a0, wrong_board_size_str_2	#
	syscall					# printf("%s", " and ");

	li 	$a0, MAX_BOARD_SIZE     	#   printf("%d" MAX_BOARD_SIZE);
    	li   	$v0, 1
    	syscall

	li	$v0, 4				# syscall 4: print_string
	la	$a0, wrong_board_size_str_3	#
	syscall					# printf("%s", "\n");
	
	b	read_board_size__body

read_board_size_second_if:
	rem	$t1, $t0, 2				# board_size % 2
	beq	$t1, $zero, read_board_size__end	#if (board_size % 2 != 0) {

	li	$v0, 4				# syscall 4: print_string
	la	$a0, board_size_must_be_even_str	
	syscall					# printf("%s", "Board size must be even!\n");

	b	read_board_size__body

read_board_size__end:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, board_size_ok_str		#
	syscall					# printf("%s", "OK, the board size is ");

	move 	$a0, $t0     			#   printf("%d" board_size);
    	li   	$v0, 1
    	syscall

	li	$v0, 4				# syscall 4: print_string
	la	$a0, wrong_board_size_str_3	#
	syscall					# printf("%s", "\n");

	#find board size
	la	$t1, board_size			# t1 is its adress
	sw	$t0, ($t1)			# t0 is board size

read_board_size__epilogue:
	jr	$ra		# return;


################################################################################
# Fill the board with all EMPTY
# .TEXT <initialise_board>
	.text
initialise_board:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $t2, $t3, $t4]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4]
	#
	# Locals:
	#   - $t0, $t1, $t2, $t3, $t4
	#
	# Structure:
	#   initialise_board
	#   -> [prologue]
	#       -> body
	#		-> loop1
	#			->loop2
	#		-> loop1 end
	#   -> [epilogue]

initialise_board__prologue:

initialise_board__body:
	#find board size
	la	$t1, board_size			#t1 is its adress
	lw	$t0, ($t1)			#t0 is board_size

	#can change $t1 cuz we dont need adress amymore
	li	$t1, 0		#row = $t1

initialise_board__loop1:
	bge	$t1, $t0, initialise_board__epilogue

	li	$t2, 0		#col = $t2

initialise_board__loop2:
	bge	$t2, $t0, initialise_board__loop1_end

	#get adress 1.	$t3
	mul	$t3, $t1, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t3, $t3, $t2			#                    + col
	addi	$t3, board			#                    + &board

	#load empty
	li	$t4, PLAYER_EMPTY
	sb	$t4, ($t3)			# board[row][col] = PLAYER_EMPTY;

	addi	$t2, 1
	b	initialise_board__loop2

initialise_board__loop1_end:
	addi	$t1, 1
	b	initialise_board__loop1

initialise_board__epilogue:
	jr	$ra				# return;


################################################################################
# Place the centre four pieces:
#    W B
#    B W
# .TEXT <place_initial_pieces>
	.text
place_initial_pieces:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    []
	# Uses:     [ $t1, $t2, $t3, $t4, $t5, $t6]
	# Clobbers: [ $t1, $t2, $t3, $t4, $t5, $t6]
	#
	# Locals:
	#   - $t1, $t2, $t3, $t4, $t5, $t6
	#
	# Structure:
	#   place_initial_pieces
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]

place_initial_pieces__prologue:

place_initial_pieces__body:
	#find board size
	la	$t1, board_size			# t1 is its adress
	lw	$t2, ($t1)			# t2 is board size

	#claculate board_size / 2	$t3
	div	$t3, $t2, 2

	#calculate board_size / 2 - 1	$t4
	addi	$t4, $t3, -1			


	#get adress 1.	$t5
	mul	$t5, $t4, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t5, $t5, $t4			#                    + col
	addi	$t5, board			#                    + &board

	#load white
	li	$t6, PLAYER_WHITE
	sb	$t6, ($t5)			# board[board_size / 2 - 1][board_size / 2 - 1] = PLAYER_WHITE;

	#get adress 2.	$t5
	mul	$t5, $t3, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t5, $t5, $t3			#                    + col
	addi	$t5, board			#                    + &board

	#load white
	li	$t6, PLAYER_WHITE
	sb	$t6, ($t5)			# board[board_size / 2][board_size / 2] = PLAYER_WHITE;
	
	#get adress 3.	$t5
	mul	$t5, $t4, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t5, $t5, $t3			#                   + col
	addi	$t5, board			#                   + &board

	#load black
	li	$t6, PLAYER_BLACK
	sb	$t6, ($t5)			# board[board_size / 2 - 1][board_size / 2] = PLAYER_BLACK;

	#get adress 3.	$t5
	mul	$t5, $t3, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t5, $t5, $t4			#                    + col
	addi	$t5, board			#                    + &board

	#load black
	li	$t6, PLAYER_BLACK
	sb	$t6, ($t5)			# board[board_size / 2][board_size / 2 - 1] = PLAYER_BLACK;

place_initial_pieces__epilogue:
	jr	$ra				# return;


################################################################################
# // Repeatedly call play_turn until the game is over, then call announce_winner
# .TEXT <play_game>
	.text
play_game:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    [$ra]
	# Uses:     [$v0]
	# Clobbers: [$v0]
	#
	# Locals:
	#   - 
	#
	# Structure:
	#   play_game
	#   -> [prologue]
	#       -> body
	#	-> loop
	#	-> body_end:
	#   -> [epilogue]

play_game__prologue:
	begin	
	push	$ra

play_game__body:
	jal	play_turn

play_game__loop:
	beq	$v0, 0, play_game__end

	jal	play_turn
	b	play_game__loop

play_game__end:
	jal	announce_winner

play_game__epilogue:
	pop	$ra
	end
	
	jr	$ra		# return;


################################################################################
# Count up how many pieces and black and how many are white, and then
# accordingly display the outcome of the game
# .TEXT <announce_winner>
	.text
announce_winner:
	# Args:     void
	#
	# Returns:  void
	#
	# Frame:    [$ra, $s1, $s2]
	# Uses:     [$v0, $a0, $s1, $s2]
	# Clobbers: [$v0, $a0, $s1, $s2]
	#
	# Locals:
	#   - $s1, $s2
	#
	# Structure:
	#   announce_winner
	#   -> [prologue]
	#       -> body
	#	-> if
	#	-> else if
	#	-> else
	#	-> end
	#   -> [epilogue]

announce_winner__prologue:
	begin
	push	$ra
	push	$s1
	push	$s2

announce_winner__body:
	li	$a0, PLAYER_BLACK
	jal	count_discs
	move	$s1, $v0

	li	$a0, PLAYER_WHITE
	jal	count_discs
	move	$s2, $v0

announce_winner__body_if:
	ble	$s2, $s1, announce_winner__body_else_if

	li	$v0, 4				# syscall 4: print_string
	la	$a0, white_won_str		#
	syscall					# printf("%s", "The game is a win for WHITE!\n");

	li	$a0, PLAYER_EMPTY
	jal	count_discs
	
	add	$s2, $v0

	j	announce_winner__body_end

announce_winner__body_else_if:
	ble	$s1, $s2, announce_winner__body_else

	li	$v0, 4				# syscall 4: print_string
	la	$a0, black_won_str		#
	syscall					# # printf("%s", "The game is a win for BLACK!\n");

	li	$a0, PLAYER_EMPTY
	jal	count_discs
	
	add	$s1, $v0

	j	announce_winner__body_end

announce_winner__body_else:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, tie_str			#
	syscall					# printf("%s", "The game is a tie! Wow!\n");

announce_winner__body_end:
	li	$v0, 4				
	la	$a0, final_score_str_1	
	syscall					

	move	$a0, $s1     	
    	li   	$v0, 1
    	syscall

	li	$v0, 4				
	la	$a0, final_score_str_2	
	syscall					

	move	$a0, $s2 	
    	li   	$v0, 1
    	syscall

	li	$v0, 4				
	la	$a0, final_score_str_3	
	syscall					

announce_winner__epilogue:
	
	pop	$s2
	pop	$s1
	pop	$ra
	end
	jr	$ra				# return;


################################################################################
# Count the number of pieces on the board belonging to a specific player
# .TEXT <count_discs>
	.text
count_discs:
	# Args:
	#    - $a0: int player
	#
	# Returns:
	#    - $v0: unsigned int
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $t2, $t3, $t4, $t5, $t7, $v0, $a0]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t7, $v0]
	#
	# Locals:
	#   - $t0, $t1, $t2, $t3, $t4, $t5, $t7
	#
	# Structure:
	#   count_discs
	#   -> [prologue]
	#       -> body
	#	-> loop1
	#		-> loop2
	#		-> loop2 end
	#	->loop1 end
	#	->end
	#   -> [epilogue]

count_discs__prologue:

count_discs__body:
	#find board size
	la	$t7, board_size			
	lw	$t0, ($t7)			#t0 is board size

	#initialise count
	li	$t3, 0				#count = t3
	
	#initialise loop 1
	li	$t1, 0				#row = t1

count_discs__body__loop1:
	bge	$t1, $t0, count_discs__body_end

	#initialise loop 2
	li	$t2, 0	#col = 0

count_discs__body__loop2:
	bge	$t2, $t0, count_discs__body__loop1_end

	#get adress $t4
	mul	$t4, $t1, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t4, $t2			#                   + col
	addi	$t4, board			#                   + &board

	#get value	$t5
	lb	$t5, ($t4)
	
	bne	$t5, $a0, count_discs__body__loop2_end

	addi	$t3, 1


count_discs__body__loop2_end:
	addi	$t2, 1
	j	count_discs__body__loop2

count_discs__body__loop1_end:
	addi	$t1, 1
	j	count_discs__body__loop1

count_discs__body_end:
	move	$v0, $t3

count_discs__epilogue:
	jr	$ra				# return;


################################################################################
# Attempt to play a single turn.
# Returns TRUE if the game is continuing.
# Otherwise returns FALSE if the game is over
# .TEXT <play_turn>
	.text
play_turn:
	# Args:     void
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra, $s1, $s2]
	# Uses:     [$s1, $s2, $t0, $t7, $t3, $a0, $a1, $v0]
	# Clobbers: [$s1, $s2, $t0, $t7, $t3, $a0, $a1, $v0]
	#
	# Locals:
	#   - $s1, $s2, $t0, $t7, $t3
	#
	# Structure:
	#   play_turn
	#   -> [prologue]
	#       -> body
	#	-> body2
	#		->scan loop
	#		-> scan int
	#	-> body 2 again
	#		->if1 condition
	#		-> if 1
	#		->if2 condition
	#		-> if 2
	#		->if 3 condition
	#		->if 3
	#	-> end
	#	-> return true
	#	-> return false
	#   -> [epilogue]

play_turn__prologue:
	begin
	push	$ra
	push	$s1
	push	$s2

play_turn__body:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, whos_turn_str_1		
	syscall					 	
	
	jal	current_player_str
	
	#v0 contains the adress of the string to be printed
	move	$a0, $v0
	li	$v0, 4				# syscall 4: print_string
	syscall					 


	li	$v0, 4				# syscall 4: print_string
	la	$a0, whos_turn_str_2		
	syscall					

	jal	print_board

	#find player_has_a_valid_move()
	jal	player_has_a_valid_move
	bne	$zero, $v0, play_turn__body2

	#printf("There are no valid moves for %s!\n", current_player_str());

	li	$v0, 4				# syscall 4: print_string
	la	$a0, no_valid_move_str_1
	syscall						
	
	jal	current_player_str
	
	#v0 contains the adress of the string to be printed
	move	$a0, $v0
	li	$v0, 4				# syscall 4: print_string
	syscall					 

	li	$v0, 4				# syscall 4: print_string
	la	$a0, no_valid_move_str_2	
	syscall					

	#current_player = other_player()
	jal	other_player

	la	$t3, current_player
	sw	$v0, ($t3)			

	jal	player_has_a_valid_move

	bne	$zero, $v0, play_turn__return_true

	# printf("There are also no valid moves for %s...\n", current_player_str());

	li	$v0, 4				# syscall 4: print_string
	la	$a0, game_over_str_1		
	syscall						
	
	jal	current_player_str
	
	#v0 contains the adress of the string to be printed
	move	$a0, $v0
	li	$v0, 4				# syscall 4: print_string
	syscall					

	li	$v0, 4				# syscall 4: print_string
	la	$a0, game_over_str_2		
	syscall					

	j	play_turn__return_false

play_turn__body2:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, enter_move_str		
	syscall					 

play_turn__body2_scan_loop:
	li	$v0, 12				# scanf(" %c", move col letter);
	syscall
	move	$t0, $v0

	beq	$t0, 10, play_turn__body2_scan_loop
	beq	$t0, 9, play_turn__body2_scan_loop
	beq	$t0, 32, play_turn__body2_scan_loop

play_turn__body2_scan_integer:
	li	$v0, 5				# scanf("%d", move row);
	syscall
	move	$s1, $v0


play_turn__body2_again:
	addi	$s1, -1				# move_row -= 1;
	
	li	$t7, 65				#'A' ascii value is 65
	sub	$s2, $t0, $t7			# move_col = move_col_letter - 'A'

	#find board size
	la	$t7, board_size			
	lw	$t0, ($t7)			#t0 is board size

play_turn__body2_if1_condition:	
	blt	$s1, $zero, play_turn__body2_if1
	bge	$s1, $t0, play_turn__body2_if1

	j	play_turn__body2_if2_condition

play_turn__body2_if1:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, invalid_row_str		#
	syscall					# 

	j	play_turn__return_true


play_turn__body2_if2_condition:
	blt	$s2, $zero, play_turn__body2_if2
	bge	$s2, $t0, play_turn__body2_if2

	j	play_turn__body2_if3_condition

play_turn__body2_if2:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, invalid_column_str	
	syscall					

	j	play_turn__return_true

play_turn__body2_if3_condition:
	move	$a0, $s1
	move	$a1, $s2

	jal	is_valid_move

	bne	$zero, $v0, play_turn__end

play_turn__body2_if3:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, invalid_move_str	
	syscall					

	j	play_turn__return_true

play_turn__end:
	move	$a0, $s1
	move	$a1, $s2

	jal	place_move

	#current_player = other_player()
	jal	other_player

	la	$t3, current_player
	sw	$v0, ($t3)	

play_turn__return_true:
	li	$v0, TRUE
	j	play_turn__epilogue

play_turn__return_false:
	li	$v0, FALSE
	j	play_turn__epilogue

play_turn__epilogue:
	pop	$s2
	pop	$s1
	pop	$ra
	end
	jr	$ra				# return;


################################################################################
# Execute a move by the current player and (move_row, move_col)
# .TEXT <place_move>
	.text
place_move:
	# Args:
	#    - $a0: int row
	#    - $a1: int col
	#
	# Returns:  void
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3]
	# Uses:     [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $s0, $s1, $s2, $s3, $a0, $a1, $v0]
	# Clobbers: [$t0, $t1, $t2, $t3, $t4, $t5, $t6, $s0, $s1, $s2, $s3, $a0, $a1, $a2, $v0]
	#
	# Locals:
	#   - $t0, $t1, $t2, $t3, $t4, $t5, $t6, $s0, $s1, $s2, $s3
	#
	# Structure:
	#   place_move
	#   -> [prologue]
	#       -> body
	#	-> loop1
	#		-> loop2
	#	-> loop1 end
	#   -> [epilogue]

place_move__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3

place_move__body:
	#save input
	move	$s1, $a0
	move	$s2, $a1

	#intialise loop
	li	$s0, 0				#direction

place_move__loop1:
	bge	$s0, NUM_DIRECTIONS, place_move__epilogue

	#s3 is vector

	mul	$s3, $s0, 8			#  calculate &directions[direction] == directions + 8 * direction
	addi	$s3, directions			#  each direction is 8 bytes (2 * words)

	#call capture amount from direction function
	move	$a0, $s1
	move	$a1, $s2
	move	$a2, $s3

	jal	capture_amount_from_direction

	move	$t0, $v0			#capture amount is t0

	#intialise loop 2
	li	$t3, 0

place_move__loop2:
	bgt	$t3, $t0, place_move__loop1_end
	
	#calculate row 	$t1		
	lw	$t4, ($s3)			#delta->row

	mul	$t4, $t4, $t3			#i * delta->row

	add	$t1, $t4, $s1			# move_row + i * delta->row

	#calculate col
	lw	$t4, 4($s3)			#delta->col

	mul	$t4, $t4, $t3			#i * delta->col

	add	$t2, $t4, $s2			# move_col + i * delta->col

	#change board
	mul	$t4, $t1, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t4, $t4, $t2			#                   + col
	addi	$t4, board			#                   + &board

	la	$t5, current_player
	lw	$t6, ($t5)			# t6 = current player
	
	
	sb	$t6, ($t4)			# t4 = board[row][col]

	#next iteration
	addi	$t3, 1
	j	place_move__loop2

place_move__loop1_end:
	addi	$s0, 1
	j	place_move__loop1

place_move__epilogue:
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	
	jr	$ra				# return;


################################################################################
# Return TRUE if the player has ANY possible move, other return FALSE
# .TEXT <player_has_a_valid_move>
	.text
player_has_a_valid_move:
	# Args:     void
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra, $s0, $s1, $s1, $s2]
	# Uses:     [$s0, $s1, $s1, $s2, $t0, $a0, $a1, $v0]
	# Clobbers: [$s0, $s1, $s1, $s2, $t0, $a0, $a1, $v0]
	#
	# Locals:
	#   - $t0, $s0, $s1, $s1, $s2
	#
	# Structure:
	#   player_has_a_valid_move
	#   -> [prologue]
	#       -> body
	#	-> loop1
	#		-> loop2
	#	-> return false
	#	-> return true
	#   -> [epilogue]

player_has_a_valid_move__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2

player_has_a_valid_move__body:
	#find board size
	la	$t0, board_size			#t0 is its adress
	lw	$s0, ($t0)			#s0 is board size

	#initialise loop 1
	li	$s1, 0				#row = 0

player_has_a_valid_move__loop1:
	bge	$s1, $s0, player_has_a_valid_move__return_false

	#initialise loop 2
	li	$s2, 0				#col = 0

player_has_a_valid_move__loop2:
	bge	$s2, $s0, player_has_a_valid_move__loop1_end

	#move arguements
	move	$a0, $s1
	move	$a1, $s2

	jal	is_valid_move

	bne	$zero, $v0, player_has_a_valid_move__return_true

	addi	$s2, 1
	j	player_has_a_valid_move__loop2

player_has_a_valid_move__loop1_end:
	addi	$s1, 1
	j	player_has_a_valid_move__loop1

player_has_a_valid_move__return_false:
	li	$v0, FALSE
	b	player_has_a_valid_move__epilogue

player_has_a_valid_move__return_true:
	li	$v0, TRUE
	b	player_has_a_valid_move__epilogue

player_has_a_valid_move__epilogue:
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra				# return;


################################################################################
# Check if a move at (row, col) is valid, meaning that it's on
# an empty square, and that it captures at least one piece from
# the other player
# .TEXT <is_valid_move>
	.text
is_valid_move:
	# Args:
	#    - $a0: int row
	#    - $a1: int col
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    [$ra, $s0, $s1, $s2]
	# Uses:     [$s0, $s1, $s2, $a0, $a1, $a2, $v0, $t0, $t1]
	# Clobbers: [$s0, $s1, $s2, $a0, $a1, $a2, $v0, $t0, $t1]
	#
	# Locals:
	#   - $s0, $s1, $s2, $t0, $t1
	#
	# Structure:
	#   is_valid_move
	#   -> [prologue]
	#       -> body
	#	-> loop
	#	-> return true
	#	-> return false
	#   -> [epilogue]

is_valid_move__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2

is_valid_move__body:
	# save input
	move	$s1, $a0
	move	$s2, $a1
	
	#get address $t0
	mul	$t0, $s1, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t0, $s2			#                   + col
	addi	$t0, board			#                   + &board
	
	#load byte $t1
	lb	$t1, ($t0)

	bne	$t1, PLAYER_EMPTY, is_valid_move__return_false

	#intialise for loop
	#need direction variable after function call 
	li	$s0, 0

is_valid_move__loop:
	bge	$s0, NUM_DIRECTIONS, is_valid_move__return_false

	#calculate adress $t0
	mul	$t0, $s0, 8			# calculate &directions[direction] == directions + 8 * direction
	addi	$t0, directions			# each direction is 8 bytes (2 * words)

	#move arguements
	move	$a0, $s1
	move	$a1, $s2
	move	$a2, $t0

	jal	capture_amount_from_direction

	#if condition
	bne	$zero, $v0, is_valid_move__return_true
	addi	$s0, 1
	b	is_valid_move__loop

is_valid_move__return_true:
	li	$v0, TRUE
	b	is_valid_move__epilogue

is_valid_move__return_false:
	li	$v0, FALSE
	b	is_valid_move__epilogue

is_valid_move__epilogue:
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end

	jr	$ra		


################################################################################
# Returns the number length of the capture line at (row, col) for the
# current player, in the direction of the delta vector. Returns 0 to
# indicate that that there is no captures because the line is invalid
# .TEXT <capture_amount_from_direction>
	.text
capture_amount_from_direction:
	# Args:
	#    - $a0: int row
	#    - $a1: int col
	#    - $a2: const vector *delta
	#
	# Returns:
	#    - $v0: unsigned int
	#
	# Frame:    [$ra, $s0, $s1, $s2]
	# Uses:     [$a0, $v0, $t1, $t0, $t3, $t4, $t5, $s0, $s1, $s2]
	# Clobbers: [$a0, $v0, $t1, $t0, $t3, $t4, $t5, $s0, $s1, $s2]
	#
	# Locals:
	#   - $t1, $t0, $t3, $t4, $t5, $s0, $s1, $s2
	#
	# Structure:
	#   capture_amount_from_direction
	#   -> [prologue]
	#       -> body
	#	-> loop
	#		-> if1
	#		-> if2
	#	->endloop
	#	->if	
	#	->return 0
	#	->end
	#   -> [epilogue]

capture_amount_from_direction__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2

capture_amount_from_direction__body:
	#save input	
	move	$s0, $a2			# vector
	move	$s1, $a0			# row
	move	$s2, $a1			# col

	jal	other_player

	move	$t0, $v0			# opposite = t0

	li	$t1, 0				# line length = t1

capture_amount_from_direction__loop:
	#calculate delta->row 			
	lw	$t4, ($s0)
	
	add	$s1, $t4

	#calculate delta->col			
	lw	$t4, 4($s0)
	
	add	$s2, $t4

capture_amount_from_direction__loop_if1:
	blt	$s1, $zero, capture_amount_from_direction__return_0
	blt	$s2, $zero, capture_amount_from_direction__return_0

	#find board size
	la	$t3, board_size			#t3 is its adress
	lw	$t4, ($t3)			#t4 is board_size
	
	bge	$s1, $t4, capture_amount_from_direction__return_0
	bge	$s2, $t4, capture_amount_from_direction__return_0

capture_amount_from_direction__loop_if2:
	#get adress	$t3
	mul	$t3, $s1, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t3, $t3, $s2			#                   + col
	addi	$t3, board			#                   + &board

	lb	$t4, ($t3)			# t4 = board[row][col]

	bne	$t4, $t0, capture_amount_from_direction_if


capture_amount_from_direction__loop_end:
	addi	$t1, 1
	j	capture_amount_from_direction__loop

capture_amount_from_direction_if:
	la	$t3, current_player
	lw	$t5, ($t3)			#t5 = current player

	mul	$t3, $s1, MAX_BOARD_SIZE	# &board[row][col] = row * MAX_BOARD_SIZE
	add	$t3, $t3, $s2			#                   + col
	addi	$t3, board			#                   + &board

	lb	$t4, ($t3)			# t4 = board[row][col]

	bne	$t4, $t5, capture_amount_from_direction__return_0
	j	capture_amount_from_direction__end

capture_amount_from_direction__return_0:
	li	$v0, 0
	j	capture_amount_from_direction__epilogue

capture_amount_from_direction__end:
	move	$v0, $t1
	j 	capture_amount_from_direction__epilogue

capture_amount_from_direction__epilogue:
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end
	
	jr	$ra				# return;


################################################################################
# Returns the player which isn't the current player
# .TEXT <other_player>
	.text
other_player:
	# Args:     void
	#
	# Returns:
	#    - $v0: int
	#
	# Frame:    []
	# Uses:     [$t1, $t0, $v0]
	# Clobbers: [$v0, $t0, $t1]
	#
	# Locals:
	#   - $t1, $t0
	#
	# Structure:
	#   other_player
	#   -> [prologue]
	#       -> body1
	#	-> body2
	#   -> [epilogue]

other_player__prologue:

other_player__body:
	la	$t0, current_player
	lw	$t1, ($t0)
	bne	$t1, PLAYER_WHITE, other_player__body2
	li	$v0, PLAYER_BLACK
	b	other_player__epilogue

other_player__body2:
	li	$v0, PLAYER_WHITE

other_player__epilogue:
	jr	$ra		# return;


################################################################################
# Returns a string representation of the current player
# .TEXT <current_player_str>
	.text
current_player_str:
	# Args:     void
	#
	# Returns:
	#    - $v0: const char *
	#
	# Frame:    []
	# Uses:     [$t1, $t2, $v0]
	# Clobbers: [$t1, $t0, $v0]
	#
	# Locals:
	#   - $t0, $t1
	#
	# Structure:
	#   current_player_str
	#   -> [prologue]
	#       -> body
	#	-> body2
	#   -> [epilogue]

current_player_str__prologue:
	
current_player_str__body:
	la	$t0, current_player
	lw	$t1, ($t0)
	bne	$t1, PLAYER_WHITE, current_player_str__body2
	la	$v0, white_str
	b	current_player_str__epilogue

current_player_str__body2:
	la	$v0, black_str

current_player_str__epilogue:
	jr	$ra		# return;


################################################################################
# Print out a display of the current board
# .TEXT <print_board>
	.text
print_board:
	# Args: void
	#
	# Returns:  void
	#
	# Frame:    [$ra, $s0, $s1]
	# Uses:     [$a0, $v0, $t2, $t3, $t4, $s0, $s1]
	# Clobbers: [$a0, $v0, $t2, $t3, $t4]
	#
	# Locals:
	#   - $s0: col
	#   - $s1: row
	#   - $t2: board_size, row + 1
	#   - $t3: &board[row][col]
	#   - $t4: board[row][col]
	#
	# Structure:
	#   print_board
	#   -> [prologue]
	#   -> body
	#      -> header_loop
	#      -> header_loop__init
	#      -> header_loop__cond
	#      -> header_loop__body
	#      -> header_loop__step
	#      -> header_loop__end
	#      -> for_row
	#      -> for_row__init
	#      -> for_row__cond
	#      -> for_row__body
	#          -> print_row_num
	#          -> for_col
	#          -> for_col__init
	#          -> for_col__cond
	#          -> for_col__body
	#              -> white
	#              -> black
	#              -> possible_move
	#              -> output_cell
	#          -> for_col__step
	#          -> for_col__end
	#      -> for_row__step
	#      -> for_row__end
	#   -> [epilogue]

print_board__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1

print_board__body:
	li	$v0, 4
	la	$a0, board_str
	syscall						# printf("Board:\n   ");

print_board__header_loop:
print_board__header_loop__init:
	li	$s0, 0					# int col = 0;

print_board__header_loop__cond:
	lw	$s1, board_size
	bge	$s0, $s1, print_board__header_loop__end # while (col < board_size) {

print_board__header_loop__body:
	li	$v0, 11
	addi	$a0, $s0, 'A'
	syscall						#     printf("%c", 'A' + col);

	li	$a0, ' '
	syscall						#     putchar(' ');

print_board__header_loop__step:
	addi	$s0, $s0, 1				#     col++;
	b	print_board__header_loop__cond		# }

print_board__header_loop__end:
	li	$v0, 11
	li	$a0, '\n'
	syscall						# printf("\n");

print_board__for_row:
print_board__for_row__init:
	li	$s0, 0					# int row = 0;

print_board__for_row__cond:
	lw	$t2, board_size
	bge	$s0, $t2, print_board__for_row__end	# while (row < board_size) {

print_board__for_row__body:
	addi	$t2, $s0, 1
	bge	$t2, 10, print_board__print_row_num	#     if (row + 1 < 10) {

	li	$v0, 11
	li	$a0, ' '
	syscall						#         printf("%d ", row + 1);

print_board__print_row_num:				#     }
	li	$v0, 1
	move	$a0, $t2
	syscall						#     printf("%d", row + 1);

	li	$v0, 11
	li	$a0, ' '
	syscall						#     putchar(' ');

print_board__for_col:
print_board__for_col__init:
	li	$s1, 0					#     int col = 0;

print_board__for_col__cond:
	lw	$t2, board_size
	bge	$s1, $t2, print_board__for_col__end	#     while (col < board_size) {

print_board__for_col__body:
	mul	$t3, $s0, MAX_BOARD_SIZE		#         &board[row][col] = row * MAX_BOARD_SIZE
	add	$t3, $t3, $s1				#                            + col
	addi	$t3, board				#                            + &board

	lb	$t4, ($t3)				#         char cell = board[row][col];

	beq	$t4, PLAYER_WHITE, print_board__white	#         if (cell == PLAYER_WHITE) goto print_board__white;
	beq	$t4, PLAYER_BLACK, print_board__black	#         if (cell == PLAYER_BLACK) goto print_board__black;

	move	$a0, $s0
	move	$a1, $s1
	jal	is_valid_move
	bnez	$v0, print_board__possible_move		#         if (is_valid_move(row, col)) goto print_board__possible_move;

	li	$a0, EMPTY_CELL_CHAR			#         c = EMPTY_CELL_CHAR;
	b	print_board__output_cell		#         goto print_board__output_cell;

print_board__white:
	li	$a0, WHITE_CHAR				#         c = WHITE_CHAR;
	b	print_board__output_cell		#         goto print_board__output_cell;

print_board__black:
	li	$a0, BLACK_CHAR				#         c = BLACK_CHAR;
	b	print_board__output_cell		#         goto print_board__output_cell;

print_board__possible_move:
	li	$a0, POSSIBLE_MOVE_CHAR			#         c = POSSIBLE_MOVE_CHAR;
	b	print_board__output_cell		#         goto print_board__output_cell;

print_board__output_cell:
	li	$v0, 11
	syscall						#         printf("%c", c);

	li	$a0, ' '
	syscall						#         putchar(' ');

print_board__for_col__step:
	addi	$s1, $s1, 1				#         col++;
	b	print_board__for_col__cond		#     }

print_board__for_col__end:
	li	$v0, 11
	li	$a0, '\n'
	syscall						#     putchar('\n');

print_board__for_row__step:
	addi	$s0, $s0, 1				#     row++;
	b	print_board__for_row__cond		# }

print_board__for_row__end:
print_board__epilogue:
	pop	$s1
	pop	$s0
	pop	$ra
	end

	jr	$ra					# return;
