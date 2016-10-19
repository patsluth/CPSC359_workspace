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
//	ldrb	r0, [r0]
  //add r0, #48
	mov	r1, #6
  bl WriteStringUART


  b stop





  // SORT STRING ATTEMPT
  ldr r0, =testString

  mov	r1, #4
  bl WriteStringUART


  ldr r1, =testStringEnd
  bl sortArray

  ldr r0, =testString
  mov	r1, #10
  bl WriteStringUART



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

    ldrb r3, [r0], #1					    // r3 = r0[0]; r0 += 1;
		ldrb r4, [r0]					        // r4 = r0[0];

    cmp r0, r1            // end of array?
    beq loopEnd

    cmp r3, r4            // if (r3 < r4) then array is not sorted
    blt notSorted

    b loopBody

    notSorted:
      strb r3, [r0], #-1
      strb r4, [r0]
      mov r0, r2          // reset r0 to arrayStart
      b loopBody

  loopEnd:

    mov pc, r14





// input r0 = arrayStart
// input r1 = arrayEnd
// output r2  = bool isSorted
isArraySortedAscending:

    mov r2, #1     // default to true

  loopBody_:

    ldrb r3, [r0], #1					// r3 = r0[0]; r0 += 1;
    ldrb r4, [r0]					    // r4 = r0[0];

    cmp r4, r1      // end of array?
    beq loopEnd_

    cmp r3, r4      // if (r3 > r4) then array is not sorted
    bge notSorted_

    b loopBody_

    notSorted_:
      mov r2, #0

  loopEnd_:










	.section .data

testArray:
	.byte 97, 98, 99, 100, 101, 99
testArrayEnd:

testString:
  .ascii "abzy"
testStringEnd:



.end
