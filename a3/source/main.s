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
	
	
	
	
	/*
	
	ldr r0, =0x3F003000				// Load System Timer interface
	
	// r2 = CLO - Timer Counter (Low 32 bits)
	// r3 = previous value of r2
	
	mov r3, #0
	
	loop:
	
		ldr r0, =0x3F003000				// Timer Control Status
		ldr r1, =0x3F003004				// CLO - Timer Counter (Low 32 bits)
		ldr r2, =0x3F003008				// CLO - Timer Counter (High 32 bits)	
		ldr r3, =0x3F00300C				// Timer Compare 0
		ldr r3, [r3]					
		ldr r4, =0x3F003010				// Timer Compare 1
		ldr r4, [r4]					
		ldr r5, =0x3F003014				// Timer Compare 2
		ldr r5, [r5]					
		ldr r6, =0x3F003018				// Timer Compare 3	
		ldr r6, [r6]
		
		
		//cmp r3, #0
		//ble print
		
		//sub r2, r3
		//cmp r2, r3
		//ldr r2, [r0]
		//blt dontPrint
		
		
	
		//print:
		
		//	ldr r3, =timerInterval
		//	ldr r3, [r3]
		//	add r3, r2
		
		//	mov r0, r1
		//	mov r1, #10
		//	bl  WriteStringUART
		
		//	ldr r0, =newline
		//	mov r1, #2
		//	bl WriteStringUART
		
		//dontPrint:
		
			b loop
		
		
		
		
		
	loopEnd:
	
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
  
  
  
  
  
//##############################################################//
.section .data
	
creatorString:
	.ascii "\rCreated by: Patrick Sluth and Nathan Escandor\n\r"
creatorStringEnd:

exitMessage:
	.ascii "Exiting program...\n\r"
exitMessageEnd:

timerInterval:
	.int 9999999

newline:
	.ascii "\n\r"
newlineEnd:

.end




