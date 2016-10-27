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
	
	
	
	
	
	
	
	//*******************************************************
	//*******************************************************
	//*******************************************************
	
	// CLO increments every 1 microsecond (according to docs)
	// 'timerInvoke' branch will be invoked every 'timerInterval' microseconds
	
	//!!!!!!!!!!!!!!!!!!
	//!!!!!!!!!!!!!!!!!!
	// NATHAN!!
	// Not sure if this is right The Tut06 pdf says something about using the 
	// Timer Compare's, which I'm not doing. But we might not have to for a simple timer.
	
	
	mov r2, #0						// r2 = currentTime + delay
	mov r3, #0						// Tick count
	mov r4, #0						// Invoke count
	
	timerLoop:
	
		add r3, #1						// Increment Tick count
	
		ldr r0, =0x3F003000				// Timer Control Status
		ldr r1, =0x3F003004				// CLO - Timer Counter (Low 32 bits)
		ldr r1, [r1]
		
		cmp r1, r2						// if (currentTime >= (currentTime + delay))
		bge timerInvoke					// then Invoke
		
		b timerLoop
		
		timerInvoke:
			add r4, #1						// Increment Tick count
			ldr r2, =timerInterval			
			ldr r2, [r2]
			add r2, r1						// update r2 to equal (currentTime + delay)
			
			b timerLoop
			
	loopEnd:
	
	//*******************************************************
	//*******************************************************
	//*******************************************************
	
	
	
	
	
	
	
	
	

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
	.int 6

newline:
	.ascii "\n\r"
newlineEnd:

.end




