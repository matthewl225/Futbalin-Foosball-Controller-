.equ TIMER, 0xff202020
.equ period, 10000000
.equ TIMEOUT, 0x01

.global SetUpTimer2


SetUpTimer2:

	movia r8, TIMER					#assign TIMER address to r16
	
	#load period of 1 second (100M cycles) into timer
	
	movi r9, %lo(period)
	stwio r9, 8(r8) 				#store lower period into timer

	movi r9, %hi(period)
	stwio r9, 12(r8) 				#store higher period into timer

	
	stwio r0, 0(r8) 				#reset timer
	
	movi r9, 0x07
	stwio r9, 4(r8) 			    #start timer signal (0111: enables interrupts, continues after timeouts, starts counting down)
	
	ret