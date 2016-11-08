// CPSC 359, Assignment 3
// By: Nathan Escandor and Patrick Sluth
// Tutorial 3
// Submitted: November 7, 2016





//##############################################################//
.section    .init
.global     _start

_start:
    b       main

//##############################################################//
.section .text

main:
	mov sp, #0x8000               	// Initializing the stack pointer
	bl EnableJTAG                 	// Enable JTAG
	bl InitUART                  	// Initialize the UART

	//Print names of creators
	ldr r0, =creatorString
	mov r1, #48
	bl WriteStringUART
	nop

	//Print "Please press a button...\n\r"
	ldr r0, =SNESPleasePressButtonText
	mov r1, #26
	bl WriteStringUART

	initSNES:

		// CLOCK = PIN 11
		mov r0, #0b001			// Output
		mov r1, #1				// GPFSEL{1}
		mov r2, #3				// bits 3-5
		bl setGPIOFunction

		// LATCH = PIN 9
		mov r0, #0b001			// Output
		mov r1, #0				// GPFSEL{0}
		mov r2, #27				// bits 27-29
		bl setGPIOFunction

		// DATA = PIN 10
		mov r0, #0b000			// Input
		mov r1, #1				// GPFSEL{1}
		mov r2, #0				// bits 0-2
		bl setGPIOFunction

		// 4
		startSamplingSNESButtons:

			// 1
				// * Moved to 6.1

			// 2
			mov r0, #11			// CLOCK GPIO PIN
			mov r1, #1
			bl writeGPIO

			// 3
			mov r0, #9			// LATCH GPIO PIN
			mov r1, #1
			bl writeGPIO

			// 4
			mov r0, #12
			//ldr r0, =0xFFFFF	// longer timer for testing
			bl startTimer

			// 5
			mov r0, #9			// LATCH GPIO PIN
			mov r1, #0
			bl writeGPIO

			// 6.1
			buttonIndex		.req r7
			buttonBitmask	.req r8
			mov buttonBitmask, #0
			mov buttonIndex, #0

			pulseLoop:

				//6.2
				// Wait 6ms (falling edge)
				mov r0, #6
				bl startTimer

				// 6.3
				mov r0, #11			// CLOCK GPIO PIN
				mov r1, #0
				bl writeGPIO

				// 6.4
				// Wait 6ms (rising edge)
				mov r0, #6
				bl startTimer

				// 6.5
				mov r0, #10			// DATA GPIO PIN
				mov r1, #0
				bl readGPIO

				// 6.6 - Write button bitmask
				lsl r0, buttonIndex
				orr buttonBitmask, r0

				//6.7
				mov r0, #11			// CLOCK GPIO PIN
				mov r1, #1
				bl writeGPIO

				// 6.8 && 6.9
				add buttonIndex, #1
				cmp buttonIndex, #16			// if (i < 16)
				blt pulseLoop

			pulseLoopEnd:

				mov r0, buttonBitmask
				bl areAnySNESButtonsPressed

				.unreq buttonIndex
				.unreq buttonBitmask

				teq r1, #1								// if (1 or more buttons are pressed)
				bleq printSNESButtonPressedMessage		// print pressed button message
				blne startSamplingSNESButtons			// Sample buttons again

				mov r1, #3								// if (start button is pressed)
				bl isSNESButtonPressedForIndex
				teq r1, #1
				beq killProgram							// killProgram
				bne startSamplingSNESButtons			// else resample



mainEnd:
	b killProgram





killProgram:
	ldr r0, =exitMessage
	mov r1, #20
	bl WriteStringUART

	mov r0, #0
	mov r7, #1
	SWI #0
killProgramEnd:





//r1 holds currentTime


//NEW ONE BASED ON LEC SLIDES
startTimer:

  mov r3, r0            //r3 holds the delay length
  ldr r0, =0x3F003004  //address of CLO og: 0x3F003004
  ldr r1, [r0]          //read CLO
  add r1, r3            //add delay (should just be 12 micros)

  waitLoop:
    ldr r2, [r0]
    cmp r1, r2          //stop when CLO = r1
    bhi waitLoop

  mov pc, lr            //return




//OLD startTimer function
// input r0 = delay in microseconds
//startTimer:

//	ldr r2, =0x3F003004		//address of CLO
//	ldr r2, [r2]					// CLO - Timer Counter (Low 32 bits)
//	add r2, r0						// r2 = currentTime + delay
                        // TODO note: in final version, should be adding 12 micros

//	timerTick_:

//		ldr r1, =0x3F003004
//		ldr r1, [r1]					// CLO - Timer Counter (Low 32 bits)

//		cmp r1, r2						// if (currentTime >= (currentTime + delay))
//		bge timerComplete_				// then Invoke

//		b timerTick_

//		timerComplete_:

//		mov pc, lr						// return



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



// Available buttons
// 0 = B
// 1 = Y
// 2 = Select
// 3 = Start
// 4 = Up
// 5 = Down
// 6 = Left
// 7 = Right
// 8 = A
// 9 = X
// 10 = L
// 11 = R
//
// input r0 = button bitmask (1 == up, 0 == down)
// input r1 = buttonIndex
// output r0 = original button bitmask
// output r1 = boolean (1 = true, 0 = false)
isSNESButtonPressedForIndex:

	push { r0 }

	lsr r0, r1
	and r0, #1

	teq r0, #0
	moveq r1, #1
	movne r1, #0

	pop { r0 }

	mov pc, lr							// return



// input r0 = button bitmask (1 == up, 0 == down)
printSNESButtonPressedMessage:



	push { lr }							// save return address
	push { r0 }


	ldr r0, =SNESYouHavePressedText
	ldr r1, =SNESYouHavePressedTextEnd
	sub r1, r0
	bl WriteStringUART


		pop { r0 }
		push { r0 }


	// lsr r0, #0
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_B_ButtonText
	ldreq r1, =SNES_B_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #1
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_Y_ButtonText
	ldreq r1, =SNES_Y_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #2
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_Select_ButtonText
	ldreq r1, =SNES_Select_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #3
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_Start_ButtonText
	ldreq r1, =SNES_Start_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #4
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_Up_ButtonText
	ldreq r1, =SNES_Up_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #5
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_Down_ButtonText
	ldreq r1, =SNES_Down_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #6
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_Left_ButtonText
	ldreq r1, =SNES_Left_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #7
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_Right_ButtonText
	ldreq r1, =SNES_Right_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #8
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_A_ButtonText
	ldreq r1, =SNES_A_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #9
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_X_ButtonText
	ldreq r1, =SNES_X_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #10
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_L_ButtonText
	ldreq r1, =SNES_L_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


		pop { r0 }
		push { r0 }


	lsr r0, #11
	and r0, #1

	teq r0, #0
	ldreq r0, =SNES_R_ButtonText
	ldreq r1, =SNES_R_ButtonTextEnd
	subeq r1, r0
	bleq WriteStringUART


	bl printNewline


  //Print "Please press a button...\n\r"
  ldr r0, =SNESPleasePressButtonText
  mov r1, #26
  bl WriteStringUART



	pop { r0 }
	pop { lr }							// restore return address
	mov pc, lr							// return



printNewline:

	push { lr }							// save return address

	ldr r0, =newline
	ldr r1, =newlineEnd
	sub r1, r1, r0
	bl WriteStringUART

	pop { lr }							// restore return address

	mov pc, lr							// return





//##############################################################//
.section .data

creatorString:
	.ascii "\rCreated by: Patrick Sluth and Nathan Escandor\n\r"
creatorStringEnd:

exitMessage:
	.ascii "Exiting program...\n\r"
exitMessageEnd:

SNESPleasePressButtonText:
	.ascii "Please press a button...\n\r"
SNESPleasePressButtonTextEnd:

SNESYouHavePressedText:
	.ascii "You have pressed "
SNESYouHavePressedTextEnd:

SNES_B_ButtonText:
	.ascii "B "
SNES_B_ButtonTextEnd:

SNES_Y_ButtonText:
	.ascii "Y "
SNES_Y_ButtonTextEnd:

SNES_Select_ButtonText:
	.ascii "Select "
SNES_Select_ButtonTextEnd:

SNES_Start_ButtonText:
	.ascii "Start "
SNES_Start_ButtonTextEnd:

SNES_Up_ButtonText:
	.ascii "Up "
SNES_Up_ButtonTextEnd:

SNES_Down_ButtonText:
	.ascii "Down "
SNES_Down_ButtonTextEnd:

SNES_Left_ButtonText:
	.ascii "Left "
SNES_Left_ButtonTextEnd:

SNES_Right_ButtonText:
	.ascii "Right "
SNES_Right_ButtonTextEnd:

SNES_A_ButtonText:
	.ascii "A "
SNES_A_ButtonTextEnd:

SNES_X_ButtonText:
	.ascii "X "
SNES_X_ButtonTextEnd:

SNES_L_ButtonText:
	.ascii "L "
SNES_L_ButtonTextEnd:

SNES_R_ButtonText:
	.ascii "R "
SNES_R_ButtonTextEnd:

newline:
	.ascii "\n\r"
newlineEnd:

.end
