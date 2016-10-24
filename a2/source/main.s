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

  // if r0 == "Q" or "q", exit program.
  cmp r0, #81
  beq killProgram

  cmp r0, #113
  beq killProgram

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
  //NOTE: r11 will be used to store iteration counter
  mov r11, #0


test:
  cmp r11, r12

  bge doneLoop    //might have to switch order. not sure if there's a delay slot
  bl mainLoop

badInt:
  //We go here if input is not int or is wrong value.

  ldr r0, =wrongIntInput
  mov r1, #52
  bl WriteStringUART

mainLoop:

  //This is where the stuff happens for the main loops

    //Write "Please enter xth number"
    ldr r0, =inputRequest   //"Please enter the "
    mov r1, #17
    bl WriteStringUART


    mov r4, #4

    ldr r0, =loopNumberString
    mul r3, r11, r4
    add r0, r0, r3



    mov r1, #4
    bl WriteStringUART

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


    intTest:
      //load the value of the input buffer specified by our iterator (r9)
      ldr r1, =inputBuffer
      ldrb r0, [r1, r9]

    //ASDF 5:01 - this part looks good. I'm pretty sure it's offsetting properly

    //while loop

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
      bl doneIntTest //og had this as endOfIteration
      //ASDF 5:19 - This condition works.

      atoi:
        //convert to decimal, add it to result (r8)
        //num places is r10 - r9
        sub r7, r10, r9     //r7 is number of spaces
        mov r6, #0          //r6 is iterator to get r5 to the right multipplication factor
        mov r5, #1          //r5 is multiplication factor
        mov r4, #10         //I guess multiplication can't take constants??


      expLoop:
        //get multiplication factor (r5) by multiplying r5 by 10, r7 times
        cmp r6, r7
        bge afterExpLoop

        //while r6 < r7
        mul r5, r5, r4
        add r6, r6, #1  //increment r6
        bl expLoop

      afterExpLoop:

        sub r0, r0, #48   //convert to int value
        mul r0, r0, r5    //raise it to the appropriate power
        add r8, r8, r0    //add it to my result


      endOfIteration:

      add r9, r9, #1    //increment r9
      bl intTest

      //If it gets here, the value is good and can be stored


    doneIntTest:

      //At this point, need to div r8 by #10 if we went through the atoi label.
      cmp r10, #1
      beq noDiv

      udiv r8, r8, r4

      //if value is >100, not good.
      cmp r8, #100
      bgt badInt

      //Store value in r8 into the array (atodArray), offset by r11
    noDiv:
      ldr r0, =atodArray
      ldr r1, =atodArrayEnd
      sub r1, r0

      strb r8, [r0, r11]


      //end of loop
      add r11, r11, #1       //increment r11
      bl test     //We always want to jump back to test


//Stuff after loop
doneLoop:

// PATRICK'S STUFF GOES HERE////////////////////////////////////////////////////

//Sort array
ldr r0, =atodArray
ldr r1, =atodArrayEnd
bl sortArray



//Get median of sorted array
ldr r0, =atodArray
ldr r1, =atodArrayEnd
bl getMedian
mov r6, r2  //Going to hold this value in r6 for now.

bl finalPrint


// END OF PATRICK'S STUFF //////////////////////////////////////////////////////

finalPrint:

  //Print sorted list
  ldr r0, =storedListMessage
  mov r1, #20
  bl WriteStringUART
  nop



    mov r11, #0

  beginListPrint:

    //print while i = 0; i < r12; i++
    cmp r11, r12
    bge afterListPrint

    ldr r0, =atodArray
    ldrb r3, [r0, r11]    //This is loaded properly. Need to convert to ascii

    mov r0, r3
    bl uDecToASCII
    bl WriteStringUART

    add r11, r11, #1
    bl beginListPrint

  afterListPrint:




  //Print median
  ldr r0, =medianMessage
  mov r1, #17
  bl WriteStringUART
  nop

    //Print value
    //Should be stored in r2

  //NJE: End of program. Print "###################"
  ldr r0, =endOfRun
  mov r1, #24
  bl WriteStringUART
  nop


  bl main

////////////////////////FUNCTIONS///////////////////////////////////////////////

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



killProgram:
  mov r0, #1
  mov r7, #1
  SWI 0


//##############################################################//

	.section .data

uDecToASCIIBuffer:	// 10 byte buffer
  .ascii "          "
uDecToASCIIBufferEnd:

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
  .ascii "\n\rThe median is: "
medianMessageEnd:

endOfRun:
  .ascii "\n\r###################\n\n\r"
endofRunEnd:

newline:
	.ascii "\n"

inputRequest:
  .ascii "Please enter the "
inputRequestEnd:

inputRequest2:
  .ascii " number\n\r"
inputRequest2End:

loopNumberString:
  .ascii "1st ", "2nd ", "3rd ", "4th ", "5th ", "6th ", "7th ", "8th ", "9th "
loopNumberStringEnd:


.end
