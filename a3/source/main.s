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
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	
	//1
	mov r7, #0
	
	
	
	//2
	mov r0, #0b000			// Input
	bl setCLOCKFunction
	mov r0, #1
	bl writeCLOCK
	
	
	
	// 3
	mov r0, #0b000			// Input
	bl setLATCHFunction
	mov r0, #1
	bl writeLATCH
	
	
	
	//4
	startSNESButtonSampleTimer:
		//ldr r0, =onTimerComplete
		//mov r1, #12
		mov r1, #1
		lsl r1, #19
		bl startTimer
		
		mov r0, #0b000			// Input
		bl setLATCHFunction
		mov r0, #0
		bl writeLATCH
		
		
		
		//6
		
		// 6.1
		mov r9, #0	// r9 = button index
	
		pulseLoop:	
		
			//6.2
			//mov r1, #6
			mov r1, #1
			lsl r1, #19
			bl startTimer
	
			ldr r0, =timerMessage
			ldr r1, =timerMessageEnd
			sub r1, r0
			bl WriteStringUART
	
	
	
			// 6.3
			mov r0, #0b000			// Input
			bl setCLOCKFunction
			mov r0, #0
			bl writeCLOCK
		
		
		
			// 6.4
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
	
	
	
	
			// 6.6
			// write to SNESButtonBuffer at index
			// SNESButtonBuffer
			
			//6.7
			mov r0, #0b000			// Input
			bl setCLOCKFunction
			mov r0, #1
			bl writeCLOCK
		
			// 6.8 && 6.9	
			add r9, #1
			cmp r9, #16			// if (i < 16)
			blt pulseLoop
			
		pulseLoopEnd:
		
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
		
		
		
		
		
		
	
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
			
			
			
			
			
			
			
			
			
			
		
	
	
	
	
	
	
// LATCH = PIN 21 = GPFSEL2
// input r0 = GP Function Select (ex #0b0001 -> Output)
setLATCHFunction:
	
	ldr r1, =0x3F200000				// base GPIO Register
	ldr r2, [r1, #0x08]				// GPFSEL2			
	
	// clear bits 3-6 (for PIN 21)
	mov r3, #0b111
	bic r2, r3, lsl #3	
	
	// set bits 3-6 (for PIN 21) to r0 (Function)			
	orr r2, r0, lsl #3
	
	str r2, [r1, #0x08]				// write back to GPFSEL2
	
	mov pc, r14						// return
	
	
	
// LATCH = PIN 21 = GPSET0
// input r0 = writeValue {0, 1}
writeLATCH:

	ldr r1, =0x3F200000				// base GPIO Register
	mov r2, #0b01					// 
	lsl r2, #21						// align for PIN 21
	
	teq r0, #0						// if (writeValue == 0)			
	streq r2, [r1, #0x28]			// GPCLR0
	strne r2, [r1, #0x1C]			// GPSET0

	mov pc, r14						// return
	
	
	
// LATCH = PIN 21 = GPLEV0
// output r0 = PIN 21 (LATCH) value
readLATCH:

	ldr r1, =0x3F200000				// base GPIO Register
	ldr r2, [r1, #0x34]				// GPLEV0			
	mov r3, #0b01
	lsl r3, #21						// align for PIN 21
	and r2, r3						// mask everything else
	
	teq r2, #0						// if (value == 0)
	moveq r0, #0					// return 0
	movne r0, #1					// return 1
	
	mov pc, r14						// return
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
// CLOCK = PIN 23 = GPFSEL2
// input r0 = GP Function Select (ex #0b0001 -> Output)
setCLOCKFunction:
	
	ldr r1, =0x3F200000				// base GPIO Register
	ldr r2, [r1, #0x08]				// GPFSEL2			
	
	// clear bits 9-11 (for PIN 23)
	mov r3, #0b111
	bic r2, r3, lsl #9	
	
	// set bits 9-11 (for PIN 23) to r0 (Function)			
	orr r2, r0, lsl #9
	
	str r2, [r1, #0x08]				// write back to GPFSEL2
	
	mov pc, r14						// return
	
	
	
// LATCH = PIN 23 = GPSET0
// input r0 = writeValue {0, 1}
writeCLOCK:

	ldr r1, =0x3F200000				// base GPIO Register
	mov r2, #0b01					// 
	lsl r2, #23						// align for PIN 23
	
	teq r0, #0						// if (writeValue == 0)			
	streq r2, [r1, #0x28]			// GPCLR0
	strne r2, [r1, #0x1C]			// GPSET0

	mov pc, r14						// return
	
	
	
// LATCH = PIN 23 = GPLEV0
// output r0 = PIN 23 (LATCH) value
readCLOCK:

	ldr r1, =0x3F200000				// base GPIO Register
	ldr r2, [r1, #0x34]				// GPLEV0			
	mov r3, #0b01
	lsl r3, #23						// align for PIN 23
	and r2, r3						// mask everything else
	
	teq r2, #0						// if (value == 0)
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




