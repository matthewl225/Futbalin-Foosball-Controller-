

.equ TIMER, 0xff202000
.equ TIMER2, 0xff202020 
.equ second_period, 100000000
.equ speed_period, 20000000
.equ TIMEOUT, 0x01

.equ REDLEDS, 0xFF200002
.equ LEGOCONTROLLA, 0xFF200070
.equ LEGOCONTROLLA_ECR, 0xFF20007C
.equ KEYBOARD, 0xFF200100

.equ PIXEL_BUFF, 0x08000000
.equ CHAR_BUFF, 0x09000000

.equ DOWN, 			0x1B
.equ LEFT, 			0x1C
.equ RIGHT, 		0x23
.equ UP, 			0x1D
.equ KICK_FRONTROW, 0x3A	#M
.equ KICK_BACKROW,  0x31	#N
.equ BREAK, 		0xF0

#------------------------------------------------Some Global Variables------------------------------------------------#
.data

TIME_DIGITS:
	SECOND_ONES: .byte 0
	SECOND_TENS: .byte 0
	MINUTE_ONES: .byte 0
	MINUTE_TENS: .byte 0
	
SCORES:
	HUMAN_USER: .byte 0
	HUMAN_USER_TENS: .byte 0
	CONTROLLED_USER: .byte 0
	CONTROLLED_USER_TENS: .byte 0
	
READ_BYTES:
	BYTE1: .byte 0
	BYTE2: .byte 0
	BYTE3: .byte 0

.align 4
myfile:
	.incbin "scoreboard.bmp"
#---------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------Interrupt Service Routines---------------------------------------------#	
.section .exceptions, "ax"

handler:
	addi sp, sp, -48
	stw r8, 0(sp)
	stw r2, 4(sp)
	stw r3, 8(sp)
	stw r4, 12(sp)
	stw r5, 16(sp)
	stw r6, 20(sp)
	stw r9, 24(sp)
	stw r15, 28(sp)
	stw r16, 32(sp)
	stw r10, 36(sp)
	stw r11, 40(sp)
	stw r7, 44(sp)
	br handler_text

 #--------------------------------------------------------------------------------------------------------#

epilogue:
	ldw r8, 0(sp)
	ldw r2, 4(sp)
	ldw r3, 8(sp)
	ldw r4, 12(sp)
	ldw r5, 16(sp)
	ldw r6, 20(sp)
	ldw r9, 24(sp)
	ldw r15, 28(sp)
	ldw r16, 32(sp)
	ldw r10, 36(sp)
	ldw r11, 40(sp)
	ldw r7, 44(sp)
	addi sp, sp, 48
	
	subi ea, ea, 4
	eret
#------------------------------------------------------------------------------------------------------------------#


.text
.global _start
_start:

	movia sp, 0x04000000

	call SetUpPushButtons
	call SetUpKeyboard	
	call SetUpTimer
	
	movia r9, 0x1081			# control register interrupt enabling (b12 for JP2, b7 for PS/2 keyboard, 2 for Timer 1, b0 for Timer0)
	wrctl ctl3, r9
	
	movia r9, 0x1
	wrctl ctl0, r9

	#-------------------------------CONFIGURING VGA DISPLAY----------------------------------------#
	
	
	movia r10, PIXEL_BUFF
	movia r20, PIXEL_BUFF
	movia r11, CHAR_BUFF	

		
	mov r15, r0					#r15 is 2*x
	mov r16, r0					#r16 is 1024*y
	mov r17, r0					#r15 + r16 shift
	movia r18, 638				#x-limit
	movia r19, 244736			#y-limit
	movia r13, myfile
	addi r13, r13, 0x34
	
draw_background_x:

	ldhio r14, 0(r13)
	sthio r14, 0(r20)
	
	addi r15, r15, 2  			#r15 is counter*2 (for x)
	add r17, r15, r16
	add r20, r10, r17
	addi r13, r13, 2
	
	bgt r15, r18, end_draw_x
	br draw_background_x
	
end_draw_x:

	#increment y
	mov r15, r0
	addi r16, r16, 1024
	
	bgt r16, r19, draw_letters
	br draw_background_x

draw_letters:
	
	# display "TIME:" above where the time elapsed in game is displayed
	movui r13, 0xffff  			# Set pixels to white from (37, 28) to (41, 29)
								# pixel address offset = x*2 + y*1024
	sthio r13, 29778(r10) 		# (41, 29)
	sthio r13, 28754(r10)		# (41, 28)
	sthio r13, 29776(r10)		# (40, 29)
	sthio r13, 28753(r10)		# (40, 28)
	sthio r13, 29774(r10)		# (39, 29)
	sthio r13, 28752(r10)		# (39, 28)
	sthio r13, 29772(r10)		# (38, 29)
	sthio r13, 28751(r10)		# (38, 28)
	sthio r13, 29770(r10)		# (37, 29)
	sthio r13, 28750(r10)		# (37, 28)
	
	movi r14, 0x54				# 'T'
	stbio r14, 3621(r11) 		# (37, 28)
	movi r14, 0x49				# 'I'
	stbio r14, 3622(r11) 		# (37, 28)
	movi r14, 0x4D				# 'M'
	stbio r14, 3623(r11) 		# (37, 28)
	movi r14, 0x45				# 'E'
	stbio r14, 3624(r11) 		# (37, 28)
	movi r14, 0x3A				# ':'
	stbio r14, 3625(r11) 		# (41, 28)
	
	# display "USER:" above the HUMAN_USER's score
	movui r13, 0x001f  			# Set pixels to blue from (47, 28) to (51, 28) and (50, 29) to (51, 29)
								# pixel address offset = x*2 + y*1024
	sthio r13, 28766(r10) 		# (47, 28)
	sthio r13, 28768(r10)		# (48, 28)
	sthio r13, 28770(r10)		# (49, 28)
	sthio r13, 28772(r10)		# (50, 28)
	sthio r13, 28774(r10)		# (51, 28)
	sthio r13, 29796(r10)		# (50, 29)
	sthio r13, 29797(r10)		# (51, 29)
	
	movi r14, 0x55				# 'U'
	stbio r14, 3631(r11) 		# (47, 28)
	movi r14, 0x53				# 'S'
	stbio r14, 3632(r11) 		# (48, 28)
	movi r14, 0x45				# 'E'
	stbio r14, 3633(r11) 		# (49, 28)
	movi r14, 0x52				# 'R'
	stbio r14, 3634(r11) 		# (50, 28)
	movi r14, 0x3A				# ':'
	stbio r14, 3635(r11) 		# (51, 28)
	
	# display "COMP:" above the CONTROLLED_USER's score
	movi r14, 0x43				# 'C'
	stbio r14, 3611(r11) 		# (27, 28)
	movi r14, 0x4F				# 'O'
	stbio r14, 3612(r11) 		# (28, 28)
	movi r14, 0x4D				# 'M'
	stbio r14, 3613(r11) 		# (29, 28)
	movi r14, 0x50				# 'P'
	stbio r14, 3614(r11) 		# (30, 28)
	movi r14, 0x3A				# ':'
	stbio r14, 3615(r11) 		# (31, 28)
	
	#----------------------------------------------------------------------------------------------#
	
LOOP:	
	
	movia  r13, SECOND_ONES   	# Get the seconds' ones digit and convert to a char by +0x30
	ldb r14, 0(r13)
	addi r14, r14, 0x30			# character address offset = x + y*128
	stbio r14, 3753(r11) 		# (41, 29)
	
	movia r13, SECOND_TENS
	ldb r14, 0(r13)
	addi r14, r14, 0x30			
	stbio r14, 3752(r11) 		# (40, 29)
		
	movi r14, 0x3A				# This character is a colon ':', ASCII: 0x3A		
	stbio r14, 3751(r11) 		# (39, 29)
	
	movia r13, MINUTE_ONES
	ldb r14, 0(r13)
	addi r14, r14, 0x30			
	stbio r14, 3750(r11) 		# (38, 29)
	
	movia r13, MINUTE_TENS
	ldb r14, 0(r13)
	addi r14, r14, 0x30			
	stbio r14, 3749(r11) 		# (37, 29)
	
	movia r13, HUMAN_USER
	ldb r14, 0(r13)
	addi r14, r14, 0x30
	stbio r14, 3763(r11)		# (51, 29)
	
	movia r13, CONTROLLED_USER
	ldb r14, 0(r13)
	addi r14, r14, 0x30
	stbio r14, 3743(r11)		# (31, 29)
	
	br LOOP

handler_text:

	#---------------------------Check Source of Interrupt-------------------------------------------#
	rdctl et, ctl4                  # check the interrupt pending register (ctl4) 
	
	check_sensors:
		movia r10, 0x1000    
		and	r11, r10, et              # check if the pending interrupt is from GPIO JP2 
		beq r11, r10, handler_sensor
		
	check_keyboard:
		movia r10, 0x80
		and r11, r10, et			  # check if the pending interrupt is from PS/2 Keyboard
		beq r11, r10, handler_keyboard

	check_timer:
		movia r10, 0x1
		and r11, r10, et			  # check if the pending interrupt is from Timer0
		beq r11, r10, handler_timer
		
	br epilogue

 #--------------------------------------ISR for touch sensors---------------------------------------------#
 handler_sensor:	

	#--------------------Double-check if interrupt came from touch sensors--------------------------#  
	movia r8, LEGOCONTROLLA			#r8 holds LEGOCONTROLLA
	
    ldwio et, 12(r8)				# check edge capture register from GPIO JP2 
    andhi r2, et, 0xc000            # mask bit 30 & 31(sensor 3 & 4)  
    beq r2, r0, epilogue        	# exit if sensor 3 or 4 did not interrupt
	#-----------------------------------------------------------------------------------------------#
	
	#check which player scored
	movi r15, 0x400
	bgt r2, r15, human_scores
	
	#-----------------------------If the controlled player scores----------------------------#
	controller_scores:
		
		movi r2, 9					#used for determining proper incrementation in decimal (time kept in decimal not hex)
		
		movia r15, CONTROLLED_USER	    #Add one to CONTROLLED_USER score if their touch sensor triggered
		ldb r16, 0(r15)					#get the current score
		beq r16, r2, score_nine_contr
		
		score_other_contr:
			addi r16, r16, 1				#add 1 to it
			br resume_contr
			
		score_nine_contr:
			movi r16, 0
		
		resume_contr:
			stb r16, 0(r15)
		
		br clear_sensor_interrupt
	#----------------------------------------------------------------------------------------#
	
	#-------------------------------If the human player scores-------------------------------#
	human_scores:
	
		movi r2, 9					#used for determining proper incrementation in decimal (time kept in decimal not hex)
		
		movia r15, HUMAN_USER
		ldb r16, 0(r15)		
		beq r16, r2, score_nine_human
		
		score_other_human:
			addi r16, r16, 1				#add 1 to it
			br resume_human
			
		score_nine_human:
			movi r16, 0
		
		resume_human:
			stb r16, 0(r15)
	#----------------------------------------------------------------------------------------#
	
	clear_sensor_interrupt:
	
		movia r2, 0xffffffff			#clear edge capture register to acknowledge interrupt
		stwio r2, 12(r8)
		
	br check_timer
 #--------------------------------------------------------------------------------------------------------#
 
 #--------------------------------------ISR for PS/2 Keyboard---------------------------------------------#
 handler_keyboard:
	
	movia r9, KEYBOARD									#r2 holds KEYBOARD
	
	ldwio r2, 0(r9)
	movia r15, 0b1000000000000000
	and r15, r15, r2
	beq r15, r0, epilogue
	
	movia r15, 0xFF
	and r15, r15, r2
	
	movia r8, REDLEDS
	stwio r15, 0(r8)
	
	movia r8, LEGOCONTROLLA
	movia r16, UP
	movia r2, DOWN
	movia r3, BREAK
	movia r4, RIGHT
	movia r5, LEFT
	movia r7, KICK_FRONTROW
	movia r9, KICK_BACKROW
	
	
	movia r17, BYTE1
	
	ldb r18, 0(r17)
	movia r6, 0x000000ff
	and r18, r18, r6
	stb r15, 0(r17)
	
	movia r6, 0xfffffff0
	
	beq r18, r3, kick_release
	beq r15, r3, kick_release
	beq r15, r16, kick_forward
	beq r15, r2, kick_backward
	beq r15, r4, move_right
	beq r15, r5, move_left
	beq r15, r7, actual_kick_frontrow
	beq r15, r9, actual_kick_backrow
	br check_timer
	
	kick_forward:
		ldwio r15, 0(r8)
		and r15, r15, r6
		addi r15, r15, 0xc
		stwio r15, 0(r8)

		br check_timer
	
	kick_backward:
		ldwio r15, 0(r8)
		and r15, r15, r6
		addi r15, r15, 0xe
		stwio r15, 0(r8)
		
		br check_timer

	move_right:
		ldwio r15, 0(r8)
		and r15, r15, r6
		addi r15, r15, 0x3
		stwio r15, 0(r8)
		
		br check_timer
	
	move_left:
		ldwio r15, 0(r8)
		and r15, r15, r6
		addi r15, r15, 0xb
		stwio r15, 0(r8)
		
		br check_timer
		
	kick_release:
		ldwio r15, 0(r8)
		movia r6, 0xffffff00
		and r15, r15, r6
		addi r15, r15, 0xff
		stwio r15, 0(r8)
		
		br check_timer
		
	actual_kick_frontrow:
		ldwio r15, 0(r8)
		movia r6, 0xffffff0f		#anding to keep all bits same except bits 7-4 (control motor 2&3)
		and r15, r15, r6
		addi r15, r15, 0xE0			#set b4 to 0 (motor 2 is on) and b5 to 1 (reverse direction)
		stwio r15, 0(r8)
		
		br check_timer
		
	actual_kick_backrow:
		ldwio r15, 0(r8)
		movia r6, 0xffffff0f		#anding to keep all bits same except bits 7-4 (control motor 2&3)
		and r15, r15, r6
		addi r15, r15, 0xC0			#set b4 to 0 (motor 2 is on) and b5 to 0 (forward direction)
		stwio r15, 0(r8)
		
		br check_timer
 #--------------------------------------------------------------------------------------------------------#
 
 #-----------------------------------------ISR for timer--------------------------------------------------#
 handler_timer:

	movia r8, TIMER				#acknowledge timeout
	stw r0, 0(r8)
	
	movi r2, 9					#used for determining proper incrementation in decimal (time kept in decimal not hex)
	movi r8, 5
	
	#--------------------------------------------------------------------------------------------------#
	increment_second_ones:
	
		movia r15, SECOND_ONES		
		ldb r16, 0(r15)
		
		#if the seconds' ones digit is 9, its time to increment the next digit
		beq r16, r2, increment_second_tens
		
		#else, we'll just increment this digit
		addi r16, r16, 1
		stb r16, 0(r15)
		
		br epilogue
	#--------------------------------------------------------------------------------------------------#
	increment_second_tens:
		
		
		
		mov r16, r0				#set prev digit to 0
		stb r16, 0(r15)
		
		movia r15, SECOND_TENS		
		ldb r16, 0(r15)
		
		#if the seconds' tens digit is 9, its time to increment the next digit
		beq r16, r8, increment_minute_ones
		
		#else, we'll just increment this digit
		addi r16, r16, 1
		stb r16, 0(r15)
		
		br epilogue
	#--------------------------------------------------------------------------------------------------#
	increment_minute_ones:
		
		mov r16, r0				#set prev digit to 0
		stb r16, 0(r15)
		
		movia r15, MINUTE_ONES		
		ldb r16, 0(r15)
		
		#if the minutes' ones digit is 5, its time to increment the next digit
		beq r16, r2, increment_minute_ones
		
		#else, we'll just increment this digit
		addi r16, r16, 1
		stb r16, 0(r15)
		
		br epilogue
	#--------------------------------------------------------------------------------------------------#
	increment_minute_tens:
		
		mov r16, r0				#set prev digit to 0
		stb r16, 0(r15)
		
		movia r15, MINUTE_TENS		
		ldb r16, 0(r15)
		
		#if the minutes' tens digit is 9, its time to increment the next digit
		beq r16, r2, increment_minute_ones
		
		#else, we'll just increment this digit
		addi r16, r16, 1
		stb r16, 0(r15)
		
		br epilogue
	#--------------------------------------------------------------------------------------------------#	
