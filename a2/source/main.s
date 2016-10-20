.section    .init
.globl     _start

_start:
    b       main

.section .text

main:
	mov sp, #0x8000               // Initializing the stack pointer
	bl EnableJTAG                 // Enable JTAG
	bl InitUART                   // Initialize the UART
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	



	// PRINT INT ARRAY EXAMPLE (IN ASCII)
	ldr r0, =testArray
	ldr r1, =testArrayEnd
	sub r1, r0						// r1 = length of testArray
	bl WriteStringUART


	
	// Print new line
	ldr r0, =newline
	mov	r1, #1
	bl WriteStringUART
	
	
	
	
	
	
	// Sort array
	ldr r0, =testArray
	ldr r1, =testArrayEnd
	bl sortArray
	
	
	
	
	// Get median value of sorted array
	ldr r0, =testArray
	ldr r1, =testArrayEnd
	bl getMedian
	
	
	
	
	
	
	bl uDecToASCIITest
	
	b stop

stop:
	b stop





// input r0 = arrayStart
// input r1 = arrayEnd
// output r0  = arrayStart
sortArray:

mov r2, r0      // save reference to arrayStart

  loopBody:

    ldrb r3, [r0], #1				// r3 = r0[0]; r0 += 1;
	ldrb r4, [r0]					// r4 = r0[0];

    cmp r0, r1            			// end of array?
    beq loopEnd

    cmp r3, r4            			// if (r3 < r4) then array is not sorted
    blt notSorted

    b loopBody

    notSorted:
		strb r3, [r0], #-1
		strb r4, [r0]
		mov r0, r2          		// reset r0 to arrayStart
		b loopBody
	
	loopEnd:

	mov pc, r14			 			// return
	
	
	
	
	
	
	
	
	
// input r0 = arrayStart
// input r1 = arrayEnd
// output r2  = median value
getMedian:

mov r2, r0      // save reference to arrayStart

  loopBody_:

	add r0, #1						// advance array start 1 index
	sub r1, #1						// advance array end -1 index

    cmp r0, r1           			
    bge loopEnd_					// if (start index >= end index) then found mid

    b loopBody_

  loopEnd_:
  
	// if the array size is even, r1 will be r0 - 1
	// if the array size is odd, r1 will equal r0
	ldrb r2, [r1]

	mov pc, r14						// return
	
	
	
	

// Unsigned Decimal to ASCII
// input r0 = n (decimal)
// output r0 = pointer to stringStart 
// output r1 = length of string (bytes)
uDecToASCII:

	// let r3 = r4 = n
	mov r3, r0				
	mov r4, r3		
	mov r5, #10
	ldr r0, =uDecToASCIIBufferEnd	
	add r0, $-1						// last byte of uDecToASCIIBuffer
	
	// iterate digits
	// curDigit = n % 10
	// n /= 20
	// until n <= 0
	loopBody__:
	
		udiv r4, r4, r5				// n /= 10 (truncate)
		mul r6, r4, r5				// nCopy * 10
		// r6 = { k | k is divisble by 10 && k <= n }
		sub r6, r3, r6				// n - ((n / 10) * 10)
		// r6 = (n % 10)
		add r6, #48					// to ascii
		strb r6, [r0], #-1			// store ascii character in buffer
		mov r3, r4					// update n
		
		cmp r3, #0					// if (n <= 0) 
		ble loopEnd__				// then done
		b loopBody__				// else loopBody__
		
	loopEnd__:
	
		// r0 = pointer to stringStart
		// r1 = length of string (bytes)
		ldr r1, =uDecToASCIIBufferEnd
		sub	r1, r0

		mov pc, r14						// return
		
		
		
		
		
// loop 0 to n and print ASCII string
uDecToASCIITest:

	mov r8, #0
	mov r9, #150
	
	loopBody___:
	
		mov r0, r8
		add r8, #1
		mov r13, r14					// save return address
		bl uDecToASCII
		bl WriteStringUART
		mov r14, r13					// restore return address
		
		cmp r8, r9
		bgt loopEnd___
		b loopBody___
	
	loopEnd___:
	
		mov pc, r14						// return
		
		
		
		
		
	.section .data

testArray:
	.byte 99, 97, 120, 100, 101, 102, 106, 105, 104
testArrayEnd:

uDecToASCIIBuffer:	// 10 byte buffer
	.ascii "          "
uDecToASCIIBufferEnd:

inputBuffer:
  .ascii "", "", ""
inputBufferEnd:

creatorString:
  .ascii "Created by: Patrick Sluth and Nathan Escandor\n\r"
creatorStringEnd:

listSizeString:
  .ascii "Please enter the size of the number list:\n\r"
listSizeStringEnd:

wrongListSizeFormatString:
  .ascii "Wrong number format! Please input int from [1-9]\n\r"
wrongListSizeFormatStringEnd:

newline:
	.asciz "\n"
	
	
	
	
	
.end
