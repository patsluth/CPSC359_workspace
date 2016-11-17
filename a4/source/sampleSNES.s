// CPSC 359, SNES driver for use with A4 (Tetris)
// By: Nathan Escandor and Patrick Sluth
// Tutorial 3
// Submitted: November 7, 2016

//Calling bl sampleSNES from main.s returns buttons pressed bitmask to r0
//##############################################################//

//##############################################################//
.section .text

.globl sampleSNES
sampleSNES:
  STMDB sp!, {r4-r9, lr}

  //old one that worked for sure
  //STMFD sp!, {lr}

	initSNES:
		mov r0, #0b001			// Output
		bl setCLOCKFunction

		mov r0, #0b001			// Output
		bl setLATCHFunction

		mov r0, #0b000			// Input
		bl setDATAFunction

		startSamplingSNESButtons:
			mov r0, #11			// CLOCK GPIO PIN
			mov r1, #1
			bl writeGPIO

			mov r0, #9			// LATCH GPIO PIN
			mov r1, #1
			bl writeGPIO

			mov r0, #12
			bl startTimer

			mov r0, #9			// LATCH GPIO PIN
			mov r1, #0
			bl writeGPIO

			// 6.1
			buttonIndex		.req r7
			buttonBitmask	.req r8
			mov buttonBitmask, #0
			mov buttonIndex, #0

			pulseLoop:

				// Wait 6ms (falling edge)
				mov r0, #6
				bl startTimer

				mov r0, #11			// CLOCK GPIO PIN
				mov r1, #0
				bl writeGPIO

				// Wait 6ms (rising edge)
				mov r0, #6
				bl startTimer

				mov r0, #10			// DATA GPIO PIN
				mov r1, #0
				bl readGPIO

				//Write button bitmask
				lsl r0, buttonIndex
				orr buttonBitmask, r0

				mov r0, #11			// CLOCK GPIO PIN
				mov r1, #1
				bl writeGPIO

				// 6.8 && 6.9
				add buttonIndex, #1
				cmp buttonIndex, #16			// if (i < 16)
				blt pulseLoop

			pulseLoopEnd:

				mov r0, buttonBitmask

				.unreq buttonIndex
				.unreq buttonBitmask

        //need to return this bitmask through r0 to main program


mainEnd:
	b killProgram

killProgram:
  //old one that worked for sure
  //LDMFD sp!, {pc}

  LDMIA sp!, {r4-r9, pc}



//r1 holds currentTime
//NEW ONE BASED ON LEC SLIDES
startTimer:

  mov r3, r0            // r3 holds the delay length
  ldr r0, =0x3F003004  	// address of CLO og: 0x3F003004
  ldr r1, [r0]          // read CLO
  add r1, r3            // add delay (should just be 12 micros)

  waitLoop:
    ldr r2, [r0]
    cmp r1, r2          // stop when CLO = r1
    bhi waitLoop

  mov pc, lr            // return



//****************************************************
//					GPIO FUNCTIONS
//****************************************************



// input r0 = n where n = GPFSEL{n}
// input r1 = GP Function Select (ex #0b001 -> Output)
// input r2 = bit offset for PIN
setGPIOFunction:

	ldr r3, =0x3F200000					// base GPIO Register
	mov r4, #0x04
	mul r0, r4
	ldr r4, [r3, r0]					// GPFSEL{n}

	// clear bits r2 - r2 + 2 (for PIN)
	mov r5, #0b111
	lsl r5, r2
	bic r3, r5

	// set bits r2 - r2 + 2 (for PIN) to r1 (Function)
	lsl r1, r2
	orr r4, r1

	str r4, [r3, r0]					// write back to GPFSEL{n}

	mov pc, lr							// return


// DATA = PIN 10 = GPFSEL1
// input r0 = GP Function Select (ex #0b0001 -> Output)
setDATAFunction:

	ldr r1, =0x3F200000					// base GPIO Register
	ldr r2, [r1, #0x04]					// GPFSEL1

	// clear bits 0-3 (for PIN 10)
	mov r3, #0b111
	bic r2, r3

	// set bits 0-3 (for PIN 10) to r0 (Function)
	orr r2, r0

	str r2, [r1, #0x04]					// write back to GPFSEL1

	mov pc, lr							// return



// LATCH = PIN 9 = GPFSEL0
// input r0 = GP Function Select (ex #0b0001 -> Output)
setLATCHFunction:

	ldr r1, =0x3F200000					// base GPIO Register
	ldr r2, [r1]						// GPFSEL0

	// clear bits 27-29 (for PIN 9)
	mov r3, #0b111
	lsl r3, #27
	bic r2, r3

	// set bits 27-29 (for PIN 9) to r0 (Function)
	lsl r0, #27
	orr r2, r0

	str r2, [r1]						// write back to GPFSEL0

	mov pc, lr							// return



// CLOCK = PIN 11 = GPFSEL1
// input r0 = GP Function Select (ex #0b0001 -> Output)
setCLOCKFunction:

	ldr r1, =0x3F200000					// base GPIO Register
	ldr r2, [r1, #0x04]					// GPFSEL1

	// clear bits 3-5 (for PIN 11)
	mov r3, #0b111
	lsl r3, #3
	bic r2, r3

	// set bits 3-5 (for PIN 11) to r0 (Function)
	lsl r0, #3
	orr r2, r0

	str r2, [r1, #0x04]					// write back to GPFSEL1

	mov pc, lr							// return


// input r0 = GPIO PIN n
// output r0 = output of GPIO PIN n
readGPIO:

	ldr r1, =0x3F200000					// base GPIO Register

	cmp r0, #32
	ldrlt r2, [r1, #0x34]				// GPLEV0 (PIN 0-31)
	ldrge r2, [r1, #0x38]				// GPLEV1 (PIN 32-64)
	subge r0, #32						// correct offset for GP{n}

	mov r3, #0b01
	lsl r3, r0							// align for PIN n
	and r2, r3							// mask everything else

	teq r2, #0							// if (value == 0)
	moveq r0, #0						// return 0
	movne r0, #1						// return 1

	mov pc, lr							// return



// input r0 = GPIO PIN n
// input r1 = writeValue {0, 1}
writeGPIO:

	teq r1, #0							// if (writeValue == 0)
	ldr r1, =0x3F200000					// base GPIO Register
	addne r2, r1, #0x1C					// GPSET0
	addeq r2, r1, #0x28					// GPCLR0

	cmp r0, #32							// get GP(CLR|SET){n}
	subge r0, #32						// correct offset for GP(CLR|SET){n}
	mov r1, #0b01
	lsl r1, r0							// align for PIN n

	strlt r1, [r2, #0x00]				// GP(CLR|SET){0}
	strge r1, [r2, #0x04]				// GP(CLR|SET){1}

	mov pc, lr							// return



//****************************************************
//					SNES FUNCTIONS
//****************************************************

// input r0 = button bitmask (1 == up, 0 == down)
// output r0 = original button bitmask
// output r1 = boolean (1 = true, 0 = false)

// nathan: using r9 to generically store the previous input throughout program.

areAnySNESButtonsPressed:

	ldr r1, =0xFFFF						// 1111 1111 1111 1111
	sub r1, r0


  //compare this input to previous one (stored in r9)
  cmp r0, r9
  bne newButtonPress

    //if it's the same input count it as no input.
    mov r1, #0

  newButtonPress:

	// if the subtraction is 0, then the bitmask was 0xFFFF
	// and no buttons were pressed
	teq r1, #0
	moveq r1, #0
	movne r1, #1



  //save current output to compare against next.
  mov r9, r0

	mov pc, lr							// return


.section .data
.end
