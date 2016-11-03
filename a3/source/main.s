// CPSC 359, Assignment 3
// By: Nathan Escandor and Patrick Sluth
// Tutorial 3
// Submitted: October XX, 2016





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
	
	
	
	
	
	
	initSNES:
	
		mov r0, #0b001			// Output
		bl setCLOCKFunction
	
		mov r0, #0b001			// Output
		bl setLATCHFunction
	
		mov r0, #0b000			// Input
		bl setDATAFunction
		
		// 4
		startSamplingSNESButtons:
		
			//1
			mov r7, #0
		
			// 2
			mov r0, #1
			bl writeCLOCK
	
			// 3
			mov r0, #1
			bl writeLATCH

			mov r1, #12
			// TODO: uncomment long timer
				mov r1, #1
				lsl r1, #20
			bl startTimer
		
			mov r0, #0
			bl writeLATCH
		
			//6
			// 6.1
			mov r8, #0
			mov r9, #0	// r9 = button index
	
			pulseLoop:	
		
				//6.2
				// Wait 6ms (falling edge)
				mov r1, #6
				bl startTimer
				
				// 6.3
				mov r0, #0
				bl writeCLOCK
		
				// 6.4
				// Wait 6ms (rising edge)
				mov r1, #6
				bl startTimer
			
				// 6.5
				bl readDATA
			
				// 6.6 - Write button bitmask
				lsl r0, r9
				orr r8, r0
			
				//6.7
				mov r0, #1
				bl writeCLOCK
		
				// 6.8 && 6.9	
				add r9, #1
				cmp r9, #16			// if (i < 16)
				blt pulseLoop	
			
			pulseLoopEnd:
		
				mov r0, r8
				bl printSNESButtonDownMessage
				
				b startSamplingSNESButtons
		
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
		
		
		
		
		
		
	
mainEnd:
	b killProgram
	
	
	
	
	
killProgram:
	ldr r0, =exitMessage
	mov r1, #20
	bl WriteStringUART

	mov r0, #1
	mov r7, #1
	SWI 0
killProgramEnd:





// Will jump to supplied return address after specified delay
// input r0 	= address to jump to on invoke
// input r1 	= delay in microseconds
startTimer:

	ldr r2, =0x3F003004				// r2 = currentTime
	ldr r2, [r2]					// CLO - Timer Counter (Low 32 bits)
	add r2, r1						// r1 = currentTime + delay
	
	timerTick_:
	
		ldr r1, =0x3F003004						
		ldr r1, [r1]					// CLO - Timer Counter (Low 32 bits)
		
		cmp r1, r2						// if (currentTime >= (currentTime + delay))
		bge timerComplete_				// then Invoke
		
		b timerTick_
		
		timerComplete_:
		
			mov pc, lr						// return
			
			
			
			
			
//****************************************************
//					SNES FUNCTIONS
//****************************************************
		
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
	
	
	
// DATA = PIN 10 = GPLEV0
// output r0 = PIN 10 (DATA) value
readDATA:

	ldr r1, =0x3F200000					// base GPIO Register
	ldr r2, [r1, #0x34]					// GPLEV0			
	mov r3, #0b01
	lsl r3, #10							// align for PIN 10
	and r2, r3							// mask everything else
		
	teq r2, #0							// if (value == 0)
	moveq r0, #0						// return 0
	movne r0, #1						// return 1
	
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
	
	
	
// LATCH = PIN 9 = GPSET0
// input r0 = writeValue {0, 1}
writeLATCH:

	ldr r1, =0x3F200000					// base GPIO Register
	mov r2, #0b01						// 
	lsl r2, #9							// align for PIN 9
	
	teq r0, #0							// if (writeValue == 0)			
	streq r2, [r1, #0x28]				// GPCLR0
	strne r2, [r1, #0x1C]				// GPSET0

	mov pc, lr							// return
	
	
	
// LATCH = PIN 9 = GPLEV0
// output r0 = PIN 9 (LATCH) value
readLATCH:

	ldr r1, =0x3F200000					// base GPIO Register
	ldr r2, [r1, #0x34]					// GPLEV0			
	mov r3, #0b01
	lsl r3, #9							// align for PIN 21
	and r2, r3							// mask everything else
	
	teq r2, #0							// if (value == 0)
	moveq r0, #0						// return 0
	movne r0, #1						// return 1
	
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
	
	
	
// CLOCK = PIN 11 = GPSET0
// input r0 = writeValue {0, 1}
writeCLOCK:

	ldr r1, =0x3F200000					// base GPIO Register
	mov r2, #0b01						// 
	lsl r2, #11							// align for PIN 11
	
	teq r0, #0							// if (writeValue == 0)			
	streq r2, [r1, #0x28]				// GPCLR0
	strne r2, [r1, #0x1C]				// GPSET0

	mov pc, lr							// return
	
	
	
// CLOCK = PIN 11 = GPLEV1
// output r0 = PIN 11 (CLOCK) value
readCLOCK:

	ldr r1, =0x3F200000					// base GPIO Register
	ldr r2, [r1, #0x34]					// GPLEV0			
	mov r3, #0b01
	lsl r3, #11							// align for PIN 11
	and r2, r3							// mask everything else
	
	teq r2, #0							// if (value == 0)
	moveq r0, #0						// return 0
	movne r0, #1						// return 1
	
	mov pc, lr							// return
	
	
	
// input r0 = button bitmask (1 == up, 0 == down)
printSNESButtonDownMessage:

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
	bl printCarriageReturn
	
	
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
	
	
	
printCarriageReturn:

	push { lr }							// save return address
	
	ldr r0, =carriageReturn
	ldr r1, =carriageReturnEnd
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

buttonMessage:
	.ascii "x Button Down\n\r"
buttonMessageEnd:

SNESPleasePressButtonText:
	.ascii "Please press a button...\n\r"
SNESPleasePressButtonTextEnd:

SNESYouHavePressedText:
	.ascii "You have pressed "
SNESYouHavePressedTextEnd:

SNES_B_ButtonText:
	.ascii " B "
SNES_B_ButtonTextEnd:

SNES_Y_ButtonText:
	.ascii " Y "
SNES_Y_ButtonTextEnd:

SNES_Select_ButtonText:
	.ascii " Select "
SNES_Select_ButtonTextEnd:

SNES_Start_ButtonText:
	.ascii " Start "
SNES_Start_ButtonTextEnd:

SNES_Up_ButtonText:
	.ascii " Up "
SNES_Up_ButtonTextEnd:

SNES_Down_ButtonText:
	.ascii " Down "
SNES_Down_ButtonTextEnd:

SNES_Left_ButtonText:
	.ascii " Left "
SNES_Left_ButtonTextEnd:

SNES_Right_ButtonText:
	.ascii " Right "
SNES_Right_ButtonTextEnd:

SNES_A_ButtonText:
	.ascii " A "
SNES_A_ButtonTextEnd:

SNES_X_ButtonText:
	.ascii " X "
SNES_X_ButtonTextEnd:

SNES_L_ButtonText:
	.ascii " L "
SNES_L_ButtonTextEnd:

SNES_R_ButtonText:
	.ascii " R "
SNES_R_ButtonTextEnd:









SNESButtonTest:
	.ascii "BYsSuplrAXLR"
SNESButtonTestEnd:

newline:
	.ascii "\n"
newlineEnd:

carriageReturn:
	.ascii "\r"
carriageReturnEnd:

.end




