.section    .init
.global     _start

_start:
    b       main

.section .text

main:
	mov sp, #0x8000               // Initializing the stack pointer
	bl EnableJTAG                 // Enable JTAG
	bl InitUART                   // Initialize the UART


  //NJE: Print names of creators
  ldr r0, =creatorString
  mov r1, #47
  bl WriteStringUART
  nop

  //NJE: Asking for size of list
  ldr r0, =listSizeString
  mov r1, #43
  bl  WriteStringUART
  bl  getNumberListSize

//Go back here if get number list size doesn't work properly
wrongListFormat:
  ldr r0, =wrongListSizeFormatString
  mov r1, #50
  bl  WriteStringUART


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

  // if r0 (ascii value) < 49 (ascii for 1), wrong format
  cmp r0, #49
  blt  wrongListFormat

  // if r0 (ascii value) > 57 (ascii for 9), wrong format
  cmp r0, #57
  bgt  wrongListFormat


  //If we make it this far, value for list size should be good.
  //Subtract 48 from r0 to convert to decimal
  //Save this into r12
  sub r0, r0, #48
  mov r12, r0


/////////////////////////////////////////////////////////////////


  //Setup for while loop//
  //NOTES: r11 will be used to store iteration counter
  mov r11, #0


test:
  cmp r11, r12

  bge doneLoop    //might have to switch order. not sure if there's a delay slot
  bl mainLoop

badInt:
  //We go here if input is not int.

  //TODO: Print that it's the wrong input.


mainLoop:

  //This is where the stuff happens for the main loop


    //Write "Please enter xth number"
    ldr r0, =inputRequest   //"Please enter the "
    mov r1, #17
    bl WriteStringUART

      //!!!!!Number goes here!!!!!

    ldr r0, =inputRequest2  //" number\n\r"
    mov r1, #9
    bl WriteStringUART

    nop
    bl intInput


//------------------------------------------------------//
    //NJE TODO: Take in UART input

intInput:

    ldr r0, =inputBuffer
    mov r1, #4            //reading 4 characters. Up to 3 numbers + \n character
    bl  ReadLineUART
    nop


//------------------------------------------------------//
    //CHECKING INPUT
    //After ReadLine, r0 holds the number of characters read in
    //r8 is my result (converting from ascii string to decimal)
    //r9 is my iterator
    //r10 used to keep track of how many elements to look at

    mov r8, #0
    mov r9, #0
    mov r10, r0

    //NOTE TODO: Actually want to offset inputBuffer by r9
    ldr r1, =inputBuffer
    ldrb r0, [r1, r9]

    //while loop
    intTest:
      cmp r9, r10
      bge doneIntTest


      //if construct (test to see if the ascii code isn't an int)
      // if r0 (ascii value) < 48 (ascii for 0), wrong format
      cmp r0, #48
      blt  badInt

      // if r0 (ascii value) > 57 (ascii for 9), wrong format
      cmp r0, #57
      bgt  badInt

      //if r10 == 1, we can just convert by subtracting 48
      cmp r10, #1
      bne atoi

      sub r8, r0, #48
      bl endOfIteration


      atoi:
        //convert to decimal, add it to result (r8)
        //num places is r10 - r9
        sub r7, r10, r9
        mov r6, #0
        mov r5, #1          //r5 is multiplication factor
        mov r4, #10         //I guess multiplication can't take constants??


      expLoop:
        //get multiplication factor (r5) by multiplying r5 by 10, r7 times
        cmp r6, r7
        bge afterExpLoop

        //while r6 < r7
        mul r5, r5, r4
        add r6, r6, #1  //increment r6

      afterExpLoop:

        sub r0, r0, #48   //convert to int value
        mul r0, r0, r5    //raise it to the appropriate power
        add r8, r8, r0    //add it to my result
        bl endOfIteration





      endOfIteration:

      add r9, r9, #1    //increment r9
      bl intTest

      //If it gets here, the value is good and can be stored


    doneIntTest:

      //NJE TODO: Save value in r8 array
      //Store value in r8 into the array (atodArray), offset by r9

      ldr r0, =atodArray
      ldr r1, =atodArrayEnd
      sub r1, r0

      strb r8, [r0, r9]


      //end of loop
      add r11, r11, #1       //increment r11
      bl test     //We always want to jump back to test


//Stuff after loop
doneLoop:

// PATRICK'S STUFF GOES HERE////////////////////////////////////////////////////



// PRINT INT ARRAY EXAMPLE (IN ASCII)
ldr r0, =testArray
ldr r1, =testArrayEnd
sub	r1, r0						// r1 = length of testArray
bl WriteStringUART

// Sort array
ldr r0, =testArray
ldr r1, =testArrayEnd
bl sortArray

// Get median value of sorted array
ldr r0, =testArray
ldr r1, =testArrayEnd
bl getMedian


// decimal to ascii
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













// END OF PATRICK'S STUFF //////////////////////////////////////////////////////

  //Print sorted list
  ldr r0, =storedListMessage
  mov r1, #20
  bl WriteStringUART
  nop

    //Print values


  //Print median
  ldr r0, =medianMessage
  mov r1, #15
  bl WriteStringUART
  nop

    //Print value


  //NJE: End of program. Print "###################"
  ldr r0, =endOfRun
  mov r1, #21
  bl WriteStringUART
  nop


//##############################################################//


	.section .data

testArray:
	.byte 99, 97, 120, 100, 101, 102, 106, 105, 104
testArrayEnd:

decToASCIBuffer:
	.asciz "000000"

atodArray:
  .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
atodArrayEnd:

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

wrongIntInput:
  .ascii "Wrong input format! Please input int from [1-100]\n\r"
wrongIntInputEnd:

storedListMessage:
  .ascii "The sorted list is: "
storedListMessageEnd:

medianMessage:
  .ascii "The median is: "
medianMessageEnd:

endOfRun:
  .ascii "###################\n\r"
endofRunEnd:

newline:
	.asciz "\n"

inputRequest:
  .ascii "Please enter the "
inputRequestEnd:

inputRequest2:
  .ascii " number\n\r"
inputRequest2End:


.align 8
loopNumberString:
  .asciz "first\0", "second\0", "third\0", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth"
loopNumberStringEnd:

loopNumberSize:
  .byte 5, 6, 5, 6, 5, 5, 7, 6, 5
loopNumberSizeEnd:


.end












//TODO: DELETE THIS SECTION AFTER DONE. THIS IS NOTES.

//NJE: This is how to load
//ldr r4, =inputBuffer
//ldrb r5, [r4]
//ldrb r6, [r4, #1]
//mov r1, r1
//nop

//NOTE: THIS WORKS NOW. THIS IS HOW TO READ FROM ARRAY
    //I just don't know how to access individual elements.
      //Think it has to do with the "This is how to load"
//ldr r4, =loopNumberString
//mov r0, r4
//mov r1, #7
//bl WriteStringUART

//ldr r4, =loopNumberString
//ldrb r0, [r4, #1]
//mov r1, #6
//bl WriteStringUART

//ldr r4, =loopNumberSize
//ldrb r1, [r4, #4]
//bl WriteStringUART
//nop
//nop
//nop
//ENDTODO
