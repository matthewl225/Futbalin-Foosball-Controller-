.equ TIMER0, 0xFF202000
.equ TIMER0_CONTROL,   4

.global _timer
_timer:

   movia r8, TIMER0        # r8 contains the base address for the timer
   addi  r9, r0, 0x8			# stop counter

   stwio r9, TIMER0_CONTROL(r8)
   
   # Set the period registers to 10^7
   addi  r9, r0, %lo (TICKSPERSEC)
   stwio r9, 8(r8)
   addi  r9, r0, %hi(TICKSPERSEC)
   stwio r9, 12(r8)

   srli r10, r4, 16
   stwio r10, 12(r8)

   movia r9, 0x7	#starts continues and enables interrupts
   stwio r9, 4(r8)

onesec:
      ldwio       r9, TIMER0_STATUS(r8)   # check if the TO bit of the status register is 1
      andi        r9, r9, 0x1
      beq         r9, r0, onesec
      movi        r9, 0x0             # clear the TO bit
	  
      stwio       r9, TIMER0_STATUS(r8)

      # stop the counter before exiting
      movi        r9, 8         
      stwio       r9, TIMER0_CONTROL(r8)
      ret