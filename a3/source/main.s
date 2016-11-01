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
	
	
	
	
	
	
	// SNES
	// GPFSEL1 (General Purpose Function Select Register)
		// PIN 9  = LATCH
		// PIN 10 = DATA
		// PIN 11 = CLOCK
	
	
	
	
	// LATCH TEST
	nop
	bl readLATCH
	nop
	mov r0, #1
	bl writeLATCH
	nop
	bl readLATCH
	nop
	mov r0, #0
	bl writeLATCH
	nop
	
	
	
	
	
	
	
	
	
	
	//1
	mov r7, #0
	
	
	
	//2
	bl writeClock1
	
	
	
	// 3
	mov r0, #1
	bl writeLATCH
	
	
	
	//4
	startSNESButtonSampleTimer:
		//ldr r0, =onTimerComplete
		//mov r1, #12
		mov r1, #1
		lsl r1, #19
		bl startTimer
	
		mov r0, #0
		bl writeLATCH
		
		
		
		//6
		
		// 6.1
		mov r9, #0	// r9 = button index
	
		pulseLoop:	
		
			//6.2
			//ldr r0, =onTimerComplete2
			//mov r1, #6
			mov r1, #1
			lsl r1, #19
			bl startTimer
	
			ldr r0, =timerMessage
			ldr r1, =timerMessageEnd
			sub r1, r0
			bl WriteStringUART
	
	
	
			// 6.3
			bl writeClock0
		
		
		
			// 6.4
			//ldr r0, =onTimerComplete3
			//mov r1, #6
			mov r1, #1
			lsl r1, #19
			bl startTimer
	
			ldr r0, =timerMessage2
			ldr r1, =timerMessage2End
			sub r1, r0
			bl WriteStringUART
	
	
	
			//6.5
			// TODO: Read GPIO data bit (r2 = index)
			// DATA
			ldr r0, =0x7F200000
			ldr r1, [r0, #52]
			mov r2, #1
			lsl r2, #10						// pin 10
			and r1, r2						// mask everything else
			teq r1, #0
			moveq r3, #0					// return 0
			movne r3, #1					// return 1
	
	
	
	
			// 6.6
			// write to SNESButtonBuffer at index
			// SNESButtonBuffer
			
			//6.7
			bl writeClock1
		
			// 6.8 && 6.9	
			add r9, #1
			cmp r9, #16			// if (i < 16)
			blt pulseLoop
			
		pulseLoopEnd:
		
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	// WORKING TIMER EXAMPLE
	
	onTimerComplete:

		ldr r0, =timerMessage
		ldr r1, =timerMessageEnd
		sub r1, r0
		bl WriteStringUART
		
		ldr r0, =onTimerComplete
		ldr r1, =timerInterval			
		ldr r1, [r1]
		bl timer
		
	*/
		
		
		
		
		
		
		
	
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
		
			mov pc, r14						// return
			
			
			
			
			
			
			
			
			
			
			
// TODO
// INPUTS - function code, GPOI pin #	
writeClock0:

	// clear bits 21-23 (for Line 47)
	mov		r2, #0b111
	bic		r1, r2, lsl #21
	
	// set bits 21-23 (for line 47) to 001 (Output function)
	mov		r2, #0b001
	orr		r1, r2, lsl #21

	// write back to Function Select Register 5
	str		r1, [r0]







	ldr r0, =0x7F200004				// GPFSEL1
	ldr r1, [r0]
	
	mov r2, #0b001					// Output (Function Select)
	bic r1, r2, lsl #11				// set bits for pin 11
	
	lsl r1, #11						// pin 11
	str r1, [r1]
	
	mov pc, r14						// return
	
writeClock1:
	
	ldr r0, =0x7F200004				// GPFSEL1
	mov r1, #0b001					// function select code
	lsl r1, #11						// pin 11
	str r1, [r1]
	
	mov pc, r14						// return
	
readClock:

	ldr r0, =0x3F200038				// GPLEV1
	ldr r1, [r0]
	
	mov pc, r14						// return
	mov r2, #1
	lsl r2, #11						// pin 11
	and r1, r2
	teq r1, #0
	moveq r10, #0
	movne r10, #1

	mov pc, r14						// return
	
// input r0 = value to write {0, 1}
writeLATCH:
	
	ldr r1, =0x7F200000				// base GPIO Register
	mov r2, #9						// PIN 9 = LATCH Line
	mov r3, #0b0010					// Input (Function Select)
	lsl r3, r2						// Align bit for PIN 9
	teq r0, #0
	streq r3, [r1, #40]				// GPCLR0
	streq r3, [r1, #28]				// GPSET0
	
	mov pc, r14						// return
	
// output r0
readLATCH:

	ldr r0, =0x7F200000				// base GPIO Register
	ldr r1, [r0, #52]				// GPLEV0
	mov r2, #9						// PIN 9 = LATCH Line
	mov r3, #0b001					// Output (Function Select)
	lsl r3, r2						// Align bit for PIN 9
	and r1, r3						// mask everything else
	teq r1, #0
	moveq r0, #0					// return 0
	movne r0, #1					// return 1
	
	mov pc, r14						// return
  
  
  
  
  
//##############################################################//
.section .data
	
creatorString:
	.ascii "\rCreated by: Patrick Sluth and Nathan Escandor\n\r"
creatorStringEnd:

exitMessage:
	.ascii "Exiting program...\n\r"
exitMessageEnd:

timerMessage:
	.ascii "Timer Complete\n\r"
timerMessageEnd:

timerMessage2:
	.ascii "\t\tTimer Complete\n\r"
timerMessage2End:

timerInterval:
	.int 1000000
	
SNESButtonBuffer:
	.int 0b1111111111111111
SNESButtonBufferEnd:

newline:
	.ascii "\n\r"
newlineEnd:

.end




