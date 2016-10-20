.section    .init
.global     _start

_start:
    b       main

.section .text

main:
	mov sp, #0x8000               // Initializing the stack pointer
	bl EnableJTAG                 // Enable JTAG
	bl InitUART                   // Initialize the UART



	ldr r1, =inputBuffer
  ldrb r0, [r1]

  //NJE:
  ldr r0, =creatorString
  mov r1, #47
  bl WriteStringUART
  nop

  //NJE:
  ldr r0, =listSizeString
  mov r1, #43
  bl  WriteStringUART
  bl  getNumberListSize

//Go back here if get number list size doesn't work properly
wrongListFormat:
  ldr r0, =wrongListSizeFormatString
  mov r1, #50
  bl  WriteStringUART
  //NJE: Get size of number list

getNumberListSize:
  ldr r0, =inputBuffer
  mov r1, #4
  bl  ReadLineUART
  nop

  //NJE: Make sure that it's within [1-9].
  // Otherwise, branch to get number list again.

  // after calling readLineUART, r0 holds length of input buffer (I THINK??)
  // if r0 != 1, wrong format.
  cmp r0, #1
  bne wrongListFormat

  // Otherwise, load value from input buffer, continue with checks
  ldr r4, =inputBuffer
  ldrb r0, [r4]

  // if r0 (ascii value) < 489 (ascii for 1), wrong format
  cmp r0, #49
  blt  wrongListFormat

  // if r0 (ascii value) > 57 (ascii for 9), wrong format
  cmp r0, #57
  bgt  wrongListFormat


//TODO

//If we make it this far, the value should be an integer from 1-9
  //Save this value to a register/array for later use.

//Need to build the main loop tonight



  //NJE: This is how to load
  //ldr r4, =inputBuffer
  //ldrb r5, [r4]
  //ldrb r6, [r4, #1]
  //mov r1, r1
  //nop
  //

































	// PRINT INT ARRAY EXAMPLE (IN ASCII)
	ldr r0, =testArray
	ldr r1, =testArrayEnd
	sub	r1, r0						// r1 = length of testArray
	bl WriteStringUART




	// Print new line
	ldr r0, =newline
	mov	r1, #1
	bl WriteStringUART

	// Print new line
	ldr r0, =newline
	mov	r1, #1
	bl WriteStringUART

	// Print new line
	ldr r0, =newline
	mov	r1, #1
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




	// decimal to asci

	ldr r0, =decToASCIBuffer
	mov r3, r2
	mov r4, #10

	// iterate digits
	// let r2 = n
	// let r3 = n copy

	loooooop:

		udiv r3, r3, r4			// n /= 10
		mul r5, r3, r4			// r3 * 10
		sub r5, r2, r5			// n - (n / 10)
		// r5 = (n % 10) at this point

		strb r5, [r0]
		ldrb r7, [r0]

		mov r2, r3				// update n

		cmp r2, #0				// if (n <= 0) then done

		ble donelooooop


		b loooooop

	donelooooop:













	ldr r0, =testArray
	ldr r1, =testArrayEnd
	sub	r1, r0						// r1 = length of testArray
	bl WriteStringUART





	b stop







  b stop



  // SORT BYTE ARRAY OF INTS (WORKING)
	ldr r0, =testArray
  ldr r1, =testArrayEnd
  bl sortArray


  ldr r0, =testArray
  ldrb r3, [r0], #1





stop:
	b	stop





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















	.section .data

testArray:
	.byte 99, 97, 120, 100, 101, 102, 106, 105, 104
testArrayEnd:

decToASCIBuffer:
	.asciz "000000"

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
