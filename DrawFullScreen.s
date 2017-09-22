.data
.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

.text

.global DrawFullScreen

DrawFullScreen:

	addi sp, sp, -32 #8 registers to save on the stack
	stw ra, 28(sp) #stack pointer
	stw r16, 24(sp) # holds the VGA (this will change)
	stw r17, 20(sp) # holds the VGA (always holds the VGA)
	stw r18, 16(sp) # holds the X
	stw r19, 12(sp) # holds the Y
	stw r20, 8(sp) # holds the XMAX value - boundary condition
	stw r21, 4(sp) # holds the YMAX value - boundary condition
	stw r22, 0(sp) # stores the colour and puts it on the screen
	
	movia r16, ADDR_VGA
	movia r17, ADDR_VGA
	
	mov r18, r0 #X
	mov r19, r0 #Y
	addi r20, r0, 640 #Xmax
	movia r21, 246720 #Ymax
	add r4, r4, r5 #offset #assuming that the offset is the same for ALL images
  #need to account for header offset from 0x270 to 0x2B4
	br Draw_loop
  
Draw_loop:

  bgt r21, r19, Yloop #go to Yloop
  br the_end

Yloop:
	
	bgt r20, r18, Xloop #go to Xlooploop
	addi r19, r19, 1024 #increment Y
	sub r16, r16, r18 #reset the xshift on the VGA
 	addi r18, r0, 0 #reset the X
	br Draw_loop
  
Xloop:
	
	add r16, r17, r18 #do the x-shift
	add r16, r16, r19 #do the y-shift

	ldhio r22, 0(r4) #grab the color
	sthio r22, 0(r16) #store the color 
	
	addi r18, r18, 2 #increment the X
	addi r4, r4, 2 #shift the colour
	br Yloop #keep looping
	
the_end:

	ldw ra, 28(sp) #restore the registers
	ldw r16, 24(sp) 
	ldw r17, 20(sp) 
	ldw r18, 16(sp) 
	ldw r19, 12(sp) 
	ldw r20, 8(sp) 
	ldw r21, 4(sp) 
	ldw r22, 0(sp) 
	
	addi sp, sp, 32 
	ret
	br the_end #just in case it doesn't return code will infini-loop here