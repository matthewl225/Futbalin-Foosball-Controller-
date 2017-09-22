.equ REDLEDS, 0xFF200002
.equ LEGOCONTROLLA, 0xFF200070
.equ LEGOCONTROLLA_ECR, 0xFF20007C
.equ KEYBOARD, 0xFF200100

.equ PIXEL_BUFF, 0x08000000
.equ CHAR_BUFF, 0x09000000

.equ DOWN, 	0x72
.equ LEFT, 	0x6B
.equ RIGHT, 0x74
.equ UP, 	0x75
.equ BREAK, 0xF0

.text
.global ReadFromKeyboard

ReadFromKeyboard:
	addi sp, sp, -4
	stwio ra, 0(sp)
	
ReadPoll:
	movia r9, KEYBOARD
	ldwio r2, 0(r9)
	andi r15, r2, 0b1000000000000000
	beq r15, r0, ReadPoll
	movia r15, 0xFF
	and r2, r15, r2
	
	ldwio ra, 0(sp)
	addi sp, sp, 4
	ret