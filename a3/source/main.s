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
	
	
	
	
	
	onTimerComplete:

		ldr r0, =timerMessage
		ldr r1, =timerMessageEnd
		sub r1, r0
		bl WriteStringUART
		
		ldr r0, =onTimerComplete
		ldr r1, =timerInterval			
		ldr r1, [r1]
		bl timer
		
		
		
		
		
		
		
	
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





// Timer - Will jump to supplied return address after specified delay
// input r0 	= address to jump to on invoke
// input r1 	= delay in microseconds
timer:

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
		
			mov pc, r0						// return
  
  
  
  
  
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

timerInterval:
	.int 1000000

newline:
	.ascii "\n\r"
newlineEnd:

.end




