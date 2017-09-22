.equ LEGOCONTROLLA, 0xFF200070

.global SetUpPushButtons

# As of 4/2, sensor 3 is the controlled user and sensor 4 is the human user

SetUpPushButtons:

   movia  r8, LEGOCONTROLLA         # load address GPIO JP1 into r8
   movia  r9, 0x07f557ff       		# set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs 
   stwio  r9, 4(r8)

# load sensor3 threshold value E and enable sensor3
 
   movia  r9,  0xff3effff       # set motors off enable threshold load sensor 3
   stwio  r9,  0(r8)            # store value into threshold register
   movia  r9,  0xff7fffff		# turn off sensor 3 and load thres to lock in thres value
   stwio  r9,  0(r8)
   
# load sensor4 threshold value E and enable sensor4
 
   movia  r9,  0xff3bffff       # set motors off enable threshold load sensor 4
   stwio  r9,  0(r8)            # store value into threshold register
   movia  r9,  0xff7fffff		# turn off sensor 4 and load thres to lock in thres value
   stwio  r9,  0(r8)

# disable threshold register and enable state mode
  
   movia  r9,  0xff5fffff      # keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)
 
# enable interrupts

   movia  r9, 0xc0000000       # enable interrupts on sensor 3 & 4
   stwio  r9, 8(r8)
	
# clear the edge capture register
   
   movia r9, 0xffffffff
   stwio r9, 12(r8)

   ret