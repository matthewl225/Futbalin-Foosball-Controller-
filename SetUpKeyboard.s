.equ KEYBOARD, 0xFF200100
.equ KEYBOARD_CONTROL, 4

.global SetUpKeyboard

SetUpKeyboard:

	movia r8, KEYBOARD         			# load address PS2 1 port into r8
	movia r9, 0x1
	stw r9, KEYBOARD_CONTROL(r8)		# enable read interrupts
	
	ret