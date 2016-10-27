// CPSC 359, Assignment 3
// By: Nathan Escandor and Patrick Sluth
// Tutorial 3
// Submitted: October XX, 2016

.section    .init
.global     _start

_start:
    b       main

.section .text





main:
	mov sp, #0x8000               // Initializing the stack pointer
	bl EnableJTAG                 // Enable JTAG
	bl InitUART                   // Initialize the UART
	
	
	
	
	
killProgram:
  ldr r0, =exitMessage
  mov r1, #20
  bl WriteStringUART

  mov r0, #1
  mov r7, #1
  SWI 0



//##############################################################//

.section .data
	
	
	
	
	
creatorString:
  .ascii "\rCreated by: Patrick Sluth and Nathan Escandor\n\r"
creatorStringEnd:

exitMessage:
  .ascii "Exiting program...\n\r"
exitMessageEnd:

newline:
	.ascii "\n"
newlineEnd:

.end




