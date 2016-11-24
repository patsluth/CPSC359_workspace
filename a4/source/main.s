// CPSC 359, Assignment 4
// By: Nathan Escandor, Charlie Roy, and Patrick Sluth
// Tutorial 3
// Submitted: November XX, 2016





//##############################################################//
.section    .init
.global     _start

_start:
    b       main

//##############################################################//
.section .text

main:

	mov     sp, #0x8000
	bl		EnableJTAG
	bl		InitFrameBuffer


	bl		clearScreen
	b		StartGame




/*  To-do Charlie:
 *  CPU could not be halted error
 *
 */
MainMenu:                                       
    bl      ClearScreenBlack                    //Clears the screen
    bl      drawMainMenu                        //draws the base menu
    
    PointerAt   .req    r9                      //r8 holds which button is hovered
    Sample      .req    r10
    
    mov PointerAt, #0                           //initialize to 0, ie Start
MainMenuPrompt:
    ldr     r0, =10000                          //delay 1/100th of a second to avoid
    bl      startTimer                          //querying too often without input  

    bl      sampleSNES                          //check what buttons are pressed
                                                //returned in r0
    mov     sample, r0                          //stores the sample in secure register sample
    
    mvn     r1, #0x100                          //moves 1 to every bit except bit 8
    bic     r0, r1                              //clears every bit of r0 except 8
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     MainMenuAPressed                    //if equal, then A was pressed, so branch
                                                //else fall through
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x10                           //moves 1 to every bit except bit 4
    bic     r0, r1                              //clears every bit except bit 4
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     MainMenuUpPressed                   //if equal, then Up was pressed, so branch
                                                //else fall through
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x20                           //moves 1 to every bit except bit 5
    bic     r0, r1                              //clears every bit except bit 5
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     MainMenuDownPressed                 //if equal, then Down was pressed, so branch
                                                //else fall through 
    b       MainMenuPrompt
    
//if A == pressed
MainMenuAPressed:
    cmp     PointerAt, #0                       //Checks if r9 points to start
    beq     StartGame                           //if it does, start game
    bl      ClearScreenBlack                    //if not, clear screen
    b       mainEnd                             //then hang

//if up == pressed
MainMenuUpPressed:
    cmp PointerAt, #0                           //see if r9 already point to top element 
    beq MainMenuPrompt                          //if so do nothing and re-prompt
    mov PointerAt, #0                           //else make r9 point to start
    bl  setMainMenuIndicatorStart               //and re draw indicator
    ldr     r0, =0x10000                        //delay to stop fluttering
    bl      startTimer
    b   MainMenuPrompt                          //And re prompt for input

//if down == pressed
MainMenuDownPressed:
    cmp PointerAt, #1                           //see if r9 already points to the bottom element
    beq MainMenuPrompt                          //if so do nothing and re-prompt
    mov PointerAt, #1                           //else make r9 point to quit
    bl  setMainMenuIndicatorQuit                //and re draw indicator
    ldr     r0, =0x10000                        //delay to stop fluttering
    bl      startTimer
    b   MainMenuPrompt                          //and re prompt for input

    .unreq  PointerAt
    .unreq  Sample

StartGame:




  //TODO: Nathan - figure out the warning
  //      "register range not in ascending order"

  //Use this branch to sample from SNES controller.
  //Button bitmask will be returned to r0 in form:
  //  B button pressed (button 1)
  //  r0 = 0xfffe = 1111 1111 1111 1110

	bl	sampleSNES
		
	bl tetrisInitGrid

    bl  ClearScreenBlack
    bl	DrawBoard
    
    //bl	PauseMenuStart
    
	bl	tetrisCreateNewBlock
	
	
	
	
	// tetrisSetGridBlockColor(int x, int y, int color)
	mov		r0, #3
	mov		r1, #18
	ldr		r2, =0xABC777
	stmfd	sp!, 	{ r0 - r2 }
	bl	 	tetrisSetGridBlockColor
	
	mov		r0, #4
	mov		r1, #18
	ldr		r2, =0xABC777
	stmfd	sp!, 	{ r0 - r2 }
	bl	 	tetrisSetGridBlockColor
	
	mov		r0, #5
	mov		r1, #18
	ldr		r2, =0xABC777
	stmfd	sp!, 	{ r0 - r2 }
	bl	 	tetrisSetGridBlockColor
	
	mov		r0, #6
	mov		r1, #18
	ldr		r2, =0xABC777
	stmfd	sp!, 	{ r0 - r2 }
	bl	 	tetrisSetGridBlockColor
	
	mov		r0, #7
	mov		r1, #18
	ldr		r2, =0xABC777
	stmfd	sp!, 	{ r0 - r2 }
	bl	 	tetrisSetGridBlockColor
	
	mov		r0, #8
	mov		r1, #18
	ldr		r2, =0xABC777
	stmfd	sp!, 	{ r0 - r2 }
	bl	 	tetrisSetGridBlockColor
	
	mov		r0, #9
	mov		r1, #18
	ldr		r2, =0xABC777
	stmfd	sp!, 	{ r0 - r2 }
	bl	 	tetrisSetGridBlockColor
	
	mainLoop:
	
		//        ldr     r0, =scoreNumber
		//        ldr     r10, [r0]
		//        add     r10, #1
		//        str     r10, [r0]
		//        bl      UpdateScore
		
		bl	tetrisDrawBlock
		bl	tetrisDrawGrid
		
		
		applyUserTranslation:
		
			// tetrisTranslateBlock(int dx, int dy)
			mov		r0, #0
			mov		r1, #0
			bl		tetrisTranslateBlock
		
		applyUserRotation:
		
			// tetrisRotateBlock(right)
			mov	r0, #1
			bl	tetrisRotateBlock
			
		applyGravityTranslation:
		
			// tetrisTranslateBlock(int dx, int dy)
			mov		r0, #0
			mov		r1, #1
			bl		tetrisTranslateBlock
			
			
			
			
			
		mov		r0, #18
		push	{ r0 }
		bl 		tetrisGridIsRowComplete
		pop		{ r0 }
		teq		r0, #0
		bne 	rowClear
		beq 	rowNotClear
		
		rowClear:
			mov		r0, #18
			push	{ r0 }
			bl		tetrisGridClearRow
		rowNotClear:
		
		
		ldr	r0, =0xFF//FFF
		bl 	startTimer
		
		
		
		b	mainLoop

/*
newBlock:
        //Increment Score by 1
		ldr     r0, =scoreNumber
		ldr     r1, [r0]
		add     r1, #1
		str     r1, [r0]
		bl      UpdateScore
        
        nextDropTime    .req    r4
        sample          .req    r5
        dropLoop:
            ldr     r0, =0x3F003004                         //loads the address for the timer into r0
            ldr     nextDropTime, [r0]                      //loads the current time into nextDropTime
            ldr     r0, =1000000                            //loads 1mil into r0
            add     nextDropTime, r0                        //increments nextDropTime by 1mil microseconds. (1 second)
                rotateLoop:
                bl      sampleSNES                          //query the SNES
                
                mov     sample, r0                          //backs up the sample
        
        
        
        
        
        
        
        
        
        .unreq  nextDropTime
*/



mainEnd:
	b	mainEnd
	
	
	
	
	
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
//		0 = y (row)
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = boolean gridRowComplete (0 == false)
//		--------
//
tetrisGridIsRowComplete:

	x					.req r0
	y					.req r1
	tetrisGrid			.req r4
	tetrisGridCols		.req r5
	tetrisGridRows		.req r6
	tetrisGridBlockSize	.req r7
	tetrisGridData		.req r8

	pop		{ y }
	push	{ lr }
	push	{ tetrisGrid - tetrisGridBlockSize }
	
		ldr 	tetrisGrid, 	=TetrisGrid
		ldmfd	tetrisGrid, 	{ tetrisGridCols - tetrisGridBlockSize }
		ldr 	tetrisGridData, =TetrisGridEnd
		
		// start of bottom row
		mov		x, #0
		//mov		y, tetrisGridRows
		//sub		y, #1
		
		// push default return value
		mov		r3, #1
		push	{ r3 }
		
		tetrisGridIsRowComplete_for_x_lessThan_cols_loop:
		
			// tetrisGetGridBlockColor(int x, int y)
			push	{ x - y }
			push	{ x - y }
			bl 		tetrisGetGridBlockColor
			pop		{ r3 }
			
			// if block color is empty, replace return value with 0
			teq		r3, #0
			pop		{ x - y }
			popeq	{ r3 }
			moveq	r3, #0
			pusheq	{ r3 }
			
			beq		tetrisGridIsRowCompleteEnd
		
			add		x, #1
			cmp		x, tetrisGridCols
			blt		tetrisGridIsRowComplete_for_x_lessThan_cols_loop
		
	tetrisGridIsRowCompleteEnd:
		
	pop		{ r0 }
	pop		{ tetrisGrid - tetrisGridBlockSize }
	pop		{ lr }
	push	{ r0 }
	
	.unreq 	x
	.unreq 	y
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
//		0 = y (row)
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
//		--------
//
tetrisGridClearRow:

	x					.req r0
	y					.req r1
	tetrisGrid			.req r4
	tetrisGridCols		.req r5
	tetrisGridRows		.req r6

	pop		{ y }
	push	{ lr }
	push	{ tetrisGrid - tetrisGridRows }
	
		ldr 	tetrisGrid, 	=TetrisGrid
		ldmfd	tetrisGrid, 	{ tetrisGridCols - tetrisGridRows }
		
		mov		x, #0
		
		tetrisGridClearRow_for_x_lessThan_cols_loop:
		
			// tetrisGetGridBlockColor(int x, int y)
			push	{ x - y }
			bl 		tetrisClearGridBlock
			pop		{ x - y }
			
			beq		tetrisGridClearRowEnd
		
			add		x, #1
			cmp		x, tetrisGridCols
			blt		tetrisGridClearRow_for_x_lessThan_cols_loop
		
	tetrisGridClearRowEnd:
		
	pop		{ tetrisGrid - tetrisGridRows }
	pop		{ lr }
	
	.unreq 	x
	.unreq 	y
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	
	mov 	pc, lr				// return
	
	
	
	
/*
 *Branch here when the start button is pressed to pause
 *Creates the pause menu
 */
PauseMenuStart:
    push    {r4, r9-r10, lr}
    
    bl      drawPauseMenu                       //draws the pause menu
    
    PointerAt   .req    r9                      //r8 holds which button is hovered
    Sample      .req    r10
    
    mov PointerAt, #0                           //initialize to 0, ie restart
PauseMenuPrompt:
    ldr     r0, =10000                          //delay 1/100th of a second to avoid
    bl      startTimer                          //querying too often without input
    
    bl      sampleSNES                          //check what buttons are pressed
                                                //returned in r0
    mov     sample, r0                          //stores the sample in secure register sample
    
    mvn     r1, #0x8                            //moves 1 into every bit except bit 3
    bic     r0, r1                              //clear every bit of r0 except 3
    cmp     r0, #0                              //compares masked sample with 0
    beq     PauseMenuStartPressed               //if equal, Start was pressed, so branch
                                                //else fall through    
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x100                          //moves 1 to every bit except bit 8
    bic     r0, r1                              //clears every bit of r0 except 8
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     PauseMenuAPressed                   //if equal, then A was pressed, so branch
                                                //else fall through
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x10                           //moves 1 to every bit except bit 4
    bic     r0, r1                              //clears every bit except bit 4
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     PauseMenuUpPressed                  //if equal, then Up was pressed, so branch
                                                //else fall through
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x20                           //moves 1 to every bit except bit 5
    bic     r0, r1                              //clears every bit except bit 5
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     PauseMenuDownPressed                //if equal, then Down was pressed, so branch
                                                //else fall through
    b       PauseMenuPrompt
    
//if Start == pressed
PauseMenuStartPressed:
    ldr     r4, =0x0                            //color
    ldr     r3, =616                            //height
    ldr     r2, =648                            //width
    mov     r1, #76                             //y
    mov     r0, #188                            //x
    stmfd   sp!,{r0-r4}                         //push all
    bl      drawRect
    bl      DrawBoard                           //redraw the board
    pop     {r4, r9-r10, pc}
//if A == pressed
PauseMenuAPressed:
    cmp     PointerAt, #0                       //Checks if r9 points to restart
    mov     r1, #0                              //resets the score to 0
    ldr     r0, =scoreNumber
    str     r1, [r0]
    beq     StartGame                           //if it does, start game
    b       MainMenu                            //else quit was hovered so go to main menu

//if up == pressed
PauseMenuUpPressed:
    cmp     PointerAt, #0                       //see if r9 already point to top element
    beq     PauseMenuPrompt                     //if so do nothing and re-prompt
    mov     PointerAt, #0                       //else make r9 point to restart
    bl      setPauseMenuIndicatorRestart        //and re draw indicator
    ldr     r0, =0x10000                        //delay to stop fluttering
    bl      startTimer
    b       PauseMenuPrompt                     //And re prompt for input

//if down == pressed
PauseMenuDownPressed:
    cmp     PointerAt, #1                       //see if r9 already points to the bottom element
    beq     PauseMenuPrompt                     //if so do nothing and re-prompt
    mov     PointerAt, #1                       //else make r9 point to quit
    bl      setPauseMenuIndicatorQuit           //and re draw indicator
    ldr     r0, =0x10000                        //delay to stop fluttering
    bl      startTimer
    b       PauseMenuPrompt                     //and re prompt for input


    .unreq  PointerAt
    .unreq  Sample
    
    pop     {r4, r9-r10, pc}
    

/*
 *Draws the gameboard peripherals
 *
 */    
DrawBoard:

    push    {r4, lr}
    
    //Draws the border
    ldr     r4, =0xE000                 //color
    mov     r3, #4                      //height
    ldr     r2, =648                    //width
    mov     r1, #76                     //y
    mov     r0, #188                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xE000                 //color
    mov     r3, #4                      //height
    ldr     r2, =648                    //width
    ldr     r1, =688                    //y
    mov     r0, #188                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect    
    ldr     r4, =0xE000                 //color
    ldr     r3, =608                    //height
    mov     r2, #4                      //width
    mov     r1, #80                     //y
    mov     r0, #188                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xE000                 //color
    ldr     r3, =608                    //height
    mov     r2, #4                      //width
    mov     r1, #80                     //y
    ldr     r0, =512                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xE000                 //color
    ldr     r3, =608                    //height
    mov     r2, #4                      //width
    mov     r1, #80                     //y
    ldr     r0, =832                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect 
    
    //Prints "Score" label
    ldr     r0, =scoreHeader            //load the score header
    ldr     r1, =0x34A0                 //set the color
    ldr     r2, =617                    //load the x offset
    mov     r3, #230                    //load the y offset
    bl      WriteSentence               //write the sentence
    
    //Draws a box for the score to print in
    ldr     r4, =0x34A0                 //color
    mov     r3, #54                     //height
    mov     r2, #54                     //width
    mov     r1, #211                    //y
    ldr     r0, =663                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xADB5                 //color
    mov     r3, #50                     //height
    mov     r2, #50                     //width
    mov     r1, #213                    //y
    ldr     r0, =665                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    //Prints "Upcoming" label    
    ldr     r0, =QueueHeader            //load the queue header
    ldr     r1, =0x618                  //load the color
    ldr     r2, =574                    //load the x offset
    ldr     r3, =586                    //load the y offset
    bl      WriteSentence               //write the sentence
    
    //Draws a box for the next block to appear in
    ldr     r4, =0x618                  //color
    mov     r3, #136                    //height
    mov     r2, #136                    //width
    ldr     r1, =528                    //y
    ldr     r0, =644                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xADB5                 //color
    mov     r3, #132                    //height
    mov     r2, #132                    //width
    ldr     r1, =530                    //y
    ldr     r0, =646                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    bl      UpdateScore
    
    pop {r4, pc}


/*
 *Updates the printed value for the score
 *
 */
UpdateScore:
    push {r4, lr}
    //clears the score board
    
    ldr     r4, =0xADB5                 //color
    mov     r3, #20                     //height
    mov     r2, #24                     //width
    mov     r1, #228                    //y
    ldr     r0, =678                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    //prints the int stored in the score section
    ldr     r0, =scoreNumber            //loads the address of scoreNumber
    ldr     r1, [r0]                    //loads the int stored there
    cmp     r1, #99                     //compares it with 99
    bgt     threeDigitScore             //if it's greater, the score is 3 digits, so branch
    cmp     r1, #9                      //compares it with 9
    bgt     twoDigitScore               //if its greater, the score is 2 digits, so branch
                                        //else fall through
oneDigitScore:                          //the score must be 1 digit at this point
    ldr     r0, =scoreText              //load the address of score text
    add     r1, #48                     //convert the score to an ascii value    
    strb     r1, [r0, #6]               //store the value at the new offset
    b       PrintScore                  //print it out
    
twoDigitScore:
    ldr     r0, =scoreText              //loads the address of score text
    mov     r2, #0                      //initializes r2 to 0
twoDigitScoreLoop:
    cmp     r1, #10                      //compares the score to 10
    blt     twoDigitScoreLoopDone       //if r1 <10, the loop is over
    sub     r1, #10                     //subtracts 10 from r1
    add     r2, #1                      //increases the counter by 1
    b       twoDigitScoreLoop           //else fall through and repeat
twoDigitScoreLoopDone:
    add     r1, #48                     //converting the values to ascii
    add     r2, #48                     
    strb    r2, [r0, #5]                //stores the 10's value at the right location
    strb    r1, [r0, #6]                //stores the 1's value at the right location
     
    b       PrintScore                  //print the score out    
    
threeDigitScore:                        //game ends at 150 score so there is a 1 in 100's index
    sub     r1, #100                    //subtract 100 from the score
    ldr     r0, =scoreText              //loads the address of the score text
    mov     r2, #49                      //initialize r2 to ascii 1 so it can be stored
    strb    r2, [r0, #4]                //store the 1 at the 100's index
    b       twoDigitScore               //now treat remaining score as 2 digits

PrintScore:
    ldr     r0, =scoreText              //load the queue header    
    mov     r1, #0                      //load the color
    ldr     r2, =678                    //load the x offset
    mov     r3, #230                     //load the y offset
    bl      WriteSentence               //write the sentence
    
    pop {r4, pc}

/*
 *Sets the entire screen to black
 */
ClearScreenBlack:
    push {r9-r10, lr}

    // Get width/height
    ldr	 	r0, =FrameBufferInit
    ldr		r9, [r0, #20]
    ldr		r10, [r0, #24]

    //Clear screen
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    str     r10, [sp, #-4]!             //push height
    str     r9, [sp, #-4]!              //push width
    mov     r0, #0
    str     r0, [sp, #-4]!              //push y
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    pop     {r9-r10, pc}
    
    
    
    
    
// INPUT
//
// OUTPUT
//
tetrisInitGrid:

	tetrisGrid			.req r0
	tetrisGridData		.req r1
	tetrisGridEnd		.req r2
	emptyBlockColor		.req r3
	
	ldr 	tetrisGrid, 			=TetrisGrid
	add 	tetrisGridData, 		tetrisGrid, #12
	ldr 	tetrisGridEnd, 			=TetrisGridEnd
	
	ldr		emptyBlockColor,		=0x000000	// black

	forEach_block_in_tetrisGrid_loop:
	
		str		emptyBlockColor, [tetrisGridData, #0]
		add 	tetrisGridData, #4
		
		cmp		tetrisGridData, tetrisGridEnd
		bge		forEach_block_in_tetrisGrid_loopEnd
		blt		forEach_block_in_tetrisGrid_loop
		
	forEach_block_in_tetrisGrid_loopEnd:
	
	.unreq 	tetrisGrid
	.unreq 	tetrisGridData
	.unreq 	tetrisGridEnd
	.unreq	emptyBlockColor

	mov 	pc, lr            // return
		
		
		
		
		
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
// 		2 = color
//		--------
// OUTPUT
//
tetrisSetGridBlockColor:

	x					.req r0
	y					.req r1
	blockColor			.req r2
	tetrisGrid			.req r3
	tetrisGridCols		.req r4
	tetrisGridRows		.req r5
	tetrisGridBlockSize	.req r6
	tetrisGridData		.req r7
	tetrisGridOffset	.req r8
	
	pop		{ x - blockColor }
	push 	{ lr }
	push	{ tetrisGridCols - tetrisGridOffset }
	
	ldr 	tetrisGrid, 			=TetrisGrid
	ldmfd	tetrisGrid,				{ tetrisGridCols - tetrisGridBlockSize }
	add 	tetrisGridData, 		tetrisGrid, #12
	
	push	{ blockColor }

	// int tetrisGridOffset = positionToArrayOffset(int x, int y, int cols)
	stmfd	sp!, 	{ x, y, tetrisGridCols }
	bl 		positionToArrayOffset
	pop 	{ tetrisGridOffset }
	lsl		tetrisGridOffset, #2
	
	pop	{ blockColor }

	// write color to tetrisGridData
	str		blockColor, 		[tetrisGridData, tetrisGridOffset]
	
	pop		{ tetrisGridCols - tetrisGridOffset }
	pop 	{ lr }
	
	.unreq	x
	.unreq	y
	.unreq 	blockColor
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	.unreq	tetrisGridOffset

	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = blockColor
//		--------
//
tetrisGetGridBlockColor:

	x					.req r1
	y					.req r2
	tetrisGrid			.req r3
	tetrisGridCols		.req r4
	tetrisGridRows		.req r5
	tetrisGridBlockSize	.req r6
	tetrisGridData		.req r7
	tetrisGridOffset	.req r8
	blockColor			.req r9
	
	pop		{ x - y }
	push 	{ lr }
	push	{ tetrisGridCols - blockColor }
	
	ldr 	tetrisGrid, 			=TetrisGrid
	ldmfd	tetrisGrid,				{ tetrisGridCols - tetrisGridBlockSize }
	add 	tetrisGridData, 		tetrisGrid, #12
	
	// default value, so we can use the grid bitmask to check for grid bounds
	ldr		blockColor, 		=0xFFFFFF
		
	//********************************
	//*****check for valid input******
	//********************************
	cmp		x, #0
	blt		tetrisGetGridBlockColorEnd
	cmp		x, tetrisGridCols
	bge		tetrisGetGridBlockColorEnd
	//********************************
	cmp		y, #0
	blt		tetrisGetGridBlockColorEnd
	cmp		y, tetrisGridRows
	bge		tetrisGetGridBlockColorEnd
	//********************************
	
	tetrisGetGridBlockColor_validInput:

		// int tetrisGridOffset = positionToArrayOffset(int x, int y, int cols)
		stmfd	sp!, 	{ x, y, tetrisGridCols }
		bl 		positionToArrayOffset
		pop 	{ tetrisGridOffset }
		lsl		tetrisGridOffset, #2
			
		ldr		blockColor, 		[tetrisGridData, tetrisGridOffset]
	
tetrisGetGridBlockColorEnd:
	
	mov		r0, blockColor
	pop		{ tetrisGridCols - blockColor }
	pop 	{ lr }
	push	{ r0 }
	
	.unreq	x
	.unreq	y
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	.unreq	tetrisGridOffset
	.unreq 	blockColor

	mov 	pc, lr				// return





// INPUT
// 		r0 = x
// 		r1 = y
// OUTPUT
//
tetrisClearGridBlock:

	x					.req r0
	y					.req r1
	color				.req r2

	push 	{ lr }

	// TODO: set background color of grid and load here
	ldr 	color, 	=0x000000
	stmfd	sp!,	{ x - color }
	bl 		tetrisSetGridBlockColor

	.unreq	x
	.unreq	y
	.unreq 	color

	pop 	{ lr }

	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//	
tetrisDrawGrid:

	curCol				.req r4
	curRow				.req r5
	curColor			.req r6
	tetrisGrid			.req r7
	tetrisGridCols		.req r8
	tetrisGridRows		.req r9
	tetrisGridBlockSize	.req r10
	tetrisGridData		.req r11
	tetrisGridOffset	.req r12
	
	mov		r0, sp

	push	{ lr }  
	push	{ curCol - tetrisGridOffset }
	
	ldr 	tetrisGrid, 	=TetrisGrid
	ldmfd	tetrisGrid, 	{ tetrisGridCols - tetrisGridBlockSize }
	add 	tetrisGridData, tetrisGrid, #12
	
	mov		r7, r0
	
	mov		curCol, 		#0
	mov		curRow, 		#0
	mov		curColor, 		#0

	tetrisDrawGrid_for_curCol_lessThan_cols_loop:

		push 	{ curRow }

		tetrisDrawGrid_for_curRow_lessThan_rows_loop:

			push 	{ curCol - tetrisGridOffset }
			
			push	{ lr } 
			push	{ r0 - r12 }
			
			// current tetris block copy
			ldmfd	r7, 	{ r6 - r10 }
			push	{ r6 - r10 }
			push 	{curCol - curRow}
			
			bl		tetrisBlockHasDataForGridPoint
			pop		{ r0 }
			teq		r0, #0
			pop		{ r6 - r10 }
			pop		{ r0 - r12 }
			pop		{ lr }
			
			// skip drawing current grid block if current 
			// tetris block is in same position
			
			
			
			beq		tetrisDrawGridBlock
			
			tetrisDrawGridBlockSkip:
			
				nop
				b		tetrisDrawGridBlockEnd
			
			tetrisDrawGridBlock:
				
				// int offset = positionToArrayOffset(int x, int y, int cols)
				stmfd	sp!, 	{ curCol, curRow, tetrisGridCols }
				bl 		positionToArrayOffset
				pop 	{ tetrisGridOffset }
				lsl		tetrisGridOffset, #2
			
				ldr		curColor, 				[tetrisGridData, tetrisGridOffset]


				x		.req r0
				y		.req r1
				width	.req r2
				height	.req r3
			
				push	{ x - height }
				
			
				// tetrisGetRectForGridPosition(int x, int y)
				stmfd	sp!, 	{ curCol, curRow }
				bl 		tetrisGetRectForGridPosition
				ldmfd	sp!, 	{ x - height  }
				
				
				// drawRect(int x, int y, int width, int height, int color)

				// push paramaters to stack
				add x, #192
				add y, #80
				stmfd	sp!,	{ x - height, curColor }

				bl		drawRect
				
				pop		{ x - height }
				
				.unreq	x
				.unreq	y
				.unreq	width
				.unreq	height

			tetrisDrawGridBlockEnd:

				pop 	{ curCol - tetrisGridOffset }

				add 	curRow, #1
				cmp 	curRow, tetrisGridRows
				blt 	tetrisDrawGrid_for_curRow_lessThan_rows_loop

		pop 	{ curRow }
		add 	curCol, #1
		cmp 	curCol, tetrisGridCols
		blt 	tetrisDrawGrid_for_curCol_lessThan_cols_loop

	pop	{ curCol - tetrisGridOffset }
	
	.unreq 	curCol
	.unreq 	curRow
	.unreq 	curColor
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	.unreq	tetrisGridOffset

	pop 	{ lr }
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
// 		2 = width
// 		3 = height
//		--------
//
tetrisGetRectForGridPosition:

	x					.req r0
	y					.req r1
	width				.req r2
	height				.req r3
	tetrisGrid			.req r4
	tetrisGridCols		.req r5
	tetrisGridRows		.req r6
	tetrisGridBlockSize	.req r7

	ldmfd	sp!, 		{ x, y }
	push	{ tetrisGrid - tetrisGridBlockSize }
	
	ldr 	tetrisGrid, 	=TetrisGrid
	ldmfd	tetrisGrid, 	{ tetrisGridCols - tetrisGridBlockSize }
	
	// calulate return values
	mov		width,	tetrisGridBlockSize
	mov		height,	tetrisGridBlockSize
	mul		x, width
	mul		y, height
	
	pop		{ tetrisGrid - tetrisGridBlockSize }
	
	stmfd	sp!, 		{ x, y, width, height }
	
	.unreq 	x
	.unreq 	y
	.unreq	width
	.unreq	height
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	
	mov 	pc, lr				// return
	
	
	
	
	
//**********************************************************************
//**********************************************************************
//**********************************************************************
//**********************************************************************
//**********************************************************************
blockX				.req r4
blockY				.req r5
blockColor			.req r6
blockTypeAddress	.req r7
blockTypeOffset		.req r8

// INPUT
//
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
tetrisCreateNewBlock:
	
	push	{ lr }
	
	ldr		r0, 	=TetrisBlock
	ldmfd	r0,		{ blockX - blockTypeOffset }

	initializeTetrisBlock:
	
		bl		randomNumber

		mov 	blockX, 			#0//#4					// load from data section?
		mov 	blockY,				#0
		
		ldr 	blockColor,	 		=TetrisBlockColors
		lsl		r1, 				r0, #2
		ldr		blockColor,			[blockColor, r1]
		
		ldr		blockTypeAddress, 	=TetrisBlockA
		teq		r0, 				#1
		//ldreq	blockTypeAddress, 	=TetrisBlockB	
		teq		r0, 				#2
		//ldreq	blockTypeAddress, 	=TetrisBlockC	
		teq		r0, 				#3
		//ldreq	blockTypeAddress, 	=TetrisBlockD	
		teq		r0, 				#4
		//ldreq	blockTypeAddress, 	=TetrisBlockE	
		teq		r0, 				#5
		//ldreq	blockTypeAddress, 	=TetrisBlockF	
		teq		r0, 				#6
		//ldreq	blockTypeAddress, 	=TetrisBlockG	
		
		mov		blockTypeOffset,	#0				

	initializeTetrisBlockEnd:
	
	pop		{ lr }

	stmfd	sp!,		{ blockX - blockTypeOffset }

	mov 	pc, lr				// return





// INPUT
//		--------
//		On Stack
//		--------
// 		1 = blockX
// 		2 = blockY
// 		3 = blockColor
// 		4 = blockTypeAddress
// 		5 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisDrawBlock:
	
	mov		r0, sp
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r0, 		{ blockX - blockTypeOffset }

	i	.req r11
	j	.req r12
	
	push	{ i - j }

	mov		i, #0
	mov 	j, #0

	for_i_lessThan_4_loop:

		push 	{ j }

		for_j_lessThan_4_loop:

			push 	{ blockX - blockColor }

			blockBitForXY	.req r1
			blockGridData	.req r2
	
			ldrh	blockGridData, [blockTypeAddress, blockTypeOffset]

			add 	blockX, i
			add 	blockY, j

			// calculate bit corresponding to block position
			mov		blockBitForXY, 	#4
			mul		blockBitForXY, 	blockBitForXY, j
			add		blockBitForXY, 	i
			lsl		blockGridData, 	blockBitForXY
			mov		blockBitForXY, 	#0b1000000000000000
			and		blockBitForXY, 	blockGridData
			teq		blockBitForXY,	#0
			
			push	{ blockColor }
			moveq	blockColor, #0//black
			beq		blockHasNoData
			
			// if (blockBitForXY != 0)
			blockHasData:
			
				x		.req r0
				y		.req r1
				width	.req r2
				height	.req r3
			
				push	{ x - height }
				
				nop
			
				// tetrisGetRectForGridPosition(int x, int y)
				stmfd	sp!, 	{ blockX, blockY  }
				bl 		tetrisGetRectForGridPosition
				ldmfd	sp!, 	{ x - height  }
				
				nop
				
				// drawRect(int x, int y, int width, int height, int color)

				// push paramaters to stack
				// TODO: draws faster when commented out?
				add 	x, #192
				add 	y, #80
				stmfd	sp!, { x - height, blockColor }
				bl		drawRect
				
				pop		{ x - height }
				
				.unreq	x
				.unreq	y
				.unreq	width
				.unreq	height
			
			blockHasNoData:
			
			pop	{ blockColor }

			.unreq	blockBitForXY
			.unreq 	blockGridData

			pop 	{ blockX - blockColor }

			add 	j, #1
			cmp 	j, #4
			blt 	for_j_lessThan_4_loop

		pop 	{ j }
		add 	i, #1
		cmp 	i, #4
		blt 	for_i_lessThan_4_loop
	
	pop		{ i - j }
		
	.unreq	i
	.unreq 	j

	pop		{ blockX - blockTypeOffset }

	pop 	{ lr }
	mov 	pc, lr				// return
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = boolean didCollide (0 == false)
//		--------
//
tetrisCheckBlockGridCollisions:

	gridBitMask			.req r0
	blockGridData		.req r1
	
	mov		r0, 			sp
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r0, 			{ blockX - blockTypeOffset }
	
	push	{ blockX - blockTypeOffset }
	bl 		tetrisGetGridBitmaskForBlock
	pop		{ gridBitMask }
	pop		{ blockX - blockTypeOffset }
	
	nop
	
	ldrh	blockGridData, 	[blockTypeAddress, blockTypeOffset]
	and		gridBitMask, 	gridBitMask, blockGridData
	cmp		gridBitMask, 	#0
	movne	gridBitMask, 	#1
	
	pop		{ blockX - blockTypeOffset }
	pop		{ lr }
	push	{ gridBitMask }
	
	.unreq 	gridBitMask
	.unreq 	blockGridData
	
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisOnBlockCollision:

	blockGridData		.req r3
	
	pop		{ blockX - blockTypeOffset }
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	
	ldrh		r3, [blockTypeAddress, blockTypeOffset]
	nop
	
	bl 		writeBlockToGrid
	
	// delete current block and generate new one
	pop		{ blockX - blockTypeOffset }
	bl		tetrisCreateNewBlock
	pop		{ blockX - blockTypeOffset }
	pop 	{ lr }
	push	{ blockX - blockTypeOffset }
	
	.unreq 	blockGridData		

	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		1 = blockX
// 		2 = blockY
// 		3 = blockColor
// 		4 = blockTypeAddress
// 		5 = blockTypeOffset
//		--------
// OUTPUT
//	
writeBlockToGrid:

	mov		r0, 		sp
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r0, 		{ blockX - blockTypeOffset }

	i	.req r11
	j	.req r12
	
	push	{ i - j }

	mov		i, #0
	mov 	j, #0

	writeBlockToGrid_for_i_lessThan_4_loop:

		push 	{ j }

		writeBlockToGrid_for_j_lessThan_4_loop:

			push 	{ blockX - blockColor }

			blockBitForXY	.req r1
			blockGridData	.req r2
	
			ldrh	blockGridData, [blockTypeAddress, blockTypeOffset]

			add 	blockX, i
			add 	blockY, j

			// calculate bit corresponding to block position
			mov		blockBitForXY, 	#4
			mul		blockBitForXY, 	blockBitForXY, j
			add		blockBitForXY, 	i
			lsl		blockGridData, 	blockBitForXY
			mov		blockBitForXY, 	#0b1000000000000000
			and		blockBitForXY, 	blockGridData
			teq		blockBitForXY,	#0
			beq		writeBlockToGrid_blockHasNoData
			
			// if (blockBitForXY != 0)
			writeBlockToGrid_blockHasData:
			
				// tetrisSetGridBlockColor(int x, int y, int color)
				stmfd	sp!, 	{ blockX - blockColor }
				bl	 	tetrisSetGridBlockColor
			
			writeBlockToGrid_blockHasNoData:

				.unreq	blockBitForXY
				.unreq 	blockGridData

			pop 	{ blockX - blockColor }

			add 	j, #1
			cmp 	j, #4
			blt 	writeBlockToGrid_for_j_lessThan_4_loop

		pop 	{ j }
		add 	i, #1
		cmp 	i, #4
		blt 	writeBlockToGrid_for_i_lessThan_4_loop
	
	pop		{ i - j }
		
	.unreq	i
	.unreq 	j

	pop		{ blockX - blockTypeOffset }

	pop 	{ lr }
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		r0 = CC/CCW	(0 == CC, otherwise CCW)
//
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisRotateBlock:

	rotationDirection	.req r0
	
	pop		{ blockX - blockTypeOffset }
	push	{ lr }
	
	// copy block in current state
	push 	{ blockX - blockTypeOffset }
	
	// update block values
	//
	teq		rotationDirection, 	#0
	beq		handleRotateLeft
	bne		handleRotateRight
	
	handleRotateLeft:
	
		add		blockTypeOffset, 	#2
		cmp		blockTypeOffset, 	#6
		movgt	blockTypeOffset, 	#0		// wrap around
	
		b 	handleRotateEnd
	
	handleRotateRight:
	
		sub		blockTypeOffset, 	#2
		cmp		blockTypeOffset, 	#0
		movlt	blockTypeOffset, 	#6		// wrap around
	
		b 	handleRotateEnd
		
	handleRotateEnd:
		push 	{ blockX - blockTypeOffset }
	
	// didCollide = tetrisCheckBlockGridCollisions(block)
	bl		tetrisCheckBlockGridCollisions
	pop		{ r0 }
	teq		r0, #0
	bne		onRotationCollision
	beq		onNoRotationCollision
	
	onRotationCollision:
		
		pop		{ blockX - blockTypeOffset }	// delete updated block
		pop		{ blockX - blockTypeOffset }	// pop previous block copy
		pop		{ lr }
		push	{ blockX - blockTypeOffset }	// push previous block copy
		b 		tetrisRotateBlockEnd
		
	onNoRotationCollision:
	
		pop		{ blockX - blockTypeOffset }	// pop updated block
		addeq	sp, #20							// delete previous block copy
		pop		{ lr }
		push	{ blockX - blockTypeOffset }	// push updated bloc
		b 		tetrisRotateBlockEnd
	
tetrisRotateBlockEnd:

	.unreq 	rotationDirection
	
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		r0 = dx
//		r1 = dy
//
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = didCollide
//		--------
//
tetrisTranslateBlock:

	dx					.req r0
	dy					.req r1
	
	pop		{ blockX - blockTypeOffset }
	push	{ lr }
	
	// copy block in current state
	push 	{ blockX - blockTypeOffset }
	
	// update block values
	add		blockX, dx
	add		blockY, dy
	push 	{ dx, dy }
	push 	{ blockX - blockTypeOffset }
	
	// didCollide = tetrisCheckBlockGridCollisions(block)
	bl		tetrisCheckBlockGridCollisions
	didCollide			.req r3
	pop		{ didCollide }
	pop 	{ blockX - blockTypeOffset }
	pop		{ dx, dy }
	push 	{ blockX - blockTypeOffset }
	teq		didCollide, #0
	.unreq	didCollide
	bne		onTranslationCollision
	beq		onNoTranslationCollision
	
	onTranslationCollision:
		
		pop		{ blockX - blockTypeOffset }	// delete updated block
		pop		{ blockX - blockTypeOffset }	// pop previous block copy
		teq		dy, #0
		beq		onTranslationCollision_Horizontal
		bne		onTranslationCollision_Vertical
		
		// we only need to create a new block on vertical collisions,
		// because horizontal collisions still allow the block to move
		// downwards 
		
		onTranslationCollision_Horizontal:
		
			pop		{ lr }
			push	{ blockX - blockTypeOffset }	// push previous block
			
			b 		tetrisTranslateBlockEnd
		
		onTranslationCollision_Vertical:
		
			push	{ blockX - blockTypeOffset }	// push previous block copy
			bl		tetrisOnBlockCollision
			pop		{ blockX - blockTypeOffset }	// pop new block
			pop		{ lr }
			push	{ blockX - blockTypeOffset }	// push new block
			
			b 		tetrisTranslateBlockEnd
		
	onNoTranslationCollision:
	
		pop		{ blockX - blockTypeOffset }	// pop updated block
		addeq	sp, #20							// delete previous block copy
		pop		{ lr }
		push	{ blockX - blockTypeOffset }	// push updated block
		b 		tetrisTranslateBlockEnd
		
tetrisTranslateBlockEnd:

	.unreq	dx
	.unreq	dy
	
	mov 	pc, lr            // return	
	

	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
// 		2 = blockX
// 		3 = blockY
// 		4 = blockColor
// 		5 = blockTypeAddress
// 		6 = blockTypeOffset
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = boolean hasData (0 == false)
//		--------
//
tetrisBlockHasDataForGridPoint:

	x					.req r0
	y					.req r1
	hasData				.req r2
	
	pop 	{ x, y }
	ldm		sp, 		{ blockX - blockTypeOffset }
	
	// if (x > blockX && x < blockX + blockWidth)
		cmp		x, 			blockX
		movlt	hasData,	#0
		blt		tetrisBlockHasDataForGridPointEnd

		push	{ blockX }
		add		blockX,		#4
		cmp		x, 			blockX
		pop		{ blockX }
		movge	hasData,	#0
		bge		tetrisBlockHasDataForGridPointEnd
	// endif
	
	// if (y > blockY && y < blockY + blockHeight)
		cmp		y, 			blockY
		movlt	hasData,	#0
		blt		tetrisBlockHasDataForGridPointEnd
		
		push	{ blockY }
		add		blockY, #4
		cmp		y, 			blockY
		pop		{ blockY }
		movge	hasData,	#0
		bge		tetrisBlockHasDataForGridPointEnd
	// endif
	
	sub		x, x, blockX
	sub		y, y, blockY
	
	blockBitForXY	.req r8
	blockGridData	.req r9
	
	push	{ blockBitForXY, blockBitForXY }

		ldrh	blockGridData, [blockTypeAddress, blockTypeOffset]

		// calculate bit corresponding to block position
		mov		blockBitForXY, 	#4
		mul		blockBitForXY, 	blockBitForXY, y
		add		blockBitForXY, 	x
		lsl		blockGridData, 	blockBitForXY
		mov		blockBitForXY, 	#0b1000000000000000
		and		blockBitForXY, 	blockGridData
		teq		blockBitForXY,	#0
		moveq	hasData,		#0
		movne	hasData,		#1
		
	pop		{ blockBitForXY, blockBitForXY }
		
	.unreq	blockBitForXY
	.unreq 	blockGridData
		
tetrisBlockHasDataForGridPointEnd:

	push	{ hasData }

	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = bitmask
//		--------
//
tetrisGetGridBitmaskForBlock:

	bitmask				.req r0
	blockGridData		.req r3
	
	mov		r0, sp
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r0, { blockX - blockTypeOffset }

	i	.req r11
	j	.req r12
	
	push	{ i - j }

	mov		bitmask, #0
	mov		i, #0
	mov 	j, #0

	tetrisGetGridBitmaskForBlock_for_i_lessThan_4_loop:

		push 	{ j }

		tetrisGetGridBitmaskForBlock_for_j_lessThan_4_loop:

			push 	{ blockX - blockColor }

			add 	blockX, i
			add 	blockY, j
			
			push	{ bitmask, i - j }
			
			// tetrisGetGridBlockColor(int x, int y)
			push	{ blockX - blockY }
			bl 		tetrisGetGridBlockColor
			pop		{ blockColor }
			pop		{ bitmask, i - j }
			teq		blockColor, #0
			
			movne	r1, #4
			mulne	r1, j, r1
			addne	r1, i
			ldrne	r2, =0b1000000000000000
			lsrne	r2, r1
			orrne	bitmask, bitmask, r2

			pop 	{ blockX - blockColor }

			add 	j, #1
			cmp 	j, #4
			blt 	tetrisGetGridBitmaskForBlock_for_j_lessThan_4_loop

		pop 	{ j }
		add 	i, #1
		cmp 	i, #4
		blt 	tetrisGetGridBitmaskForBlock_for_i_lessThan_4_loop
	
	pop		{ i - j }
		
	.unreq	i
	.unreq 	j

	pop		{ blockX - blockTypeOffset }
	pop 	{ lr }
	push	{ bitmask }

	.unreq	bitmask
	.unreq	blockGridData

	mov 	pc, lr				// return
	
//**********************************************************************
//**********************************************************************
//**********************************************************************
//**********************************************************************
//**********************************************************************
.unreq	blockX
.unreq	blockY
.unreq 	blockColor
.unreq	blockTypeAddress
.unreq	blockTypeOffset





//##############################################################//
.section .data

.align 4
TetrisGrid:	
	.int		10			// tetrisGridCols
	.int		19			// tetrisGridRows
	.int		32			// tetrisGridBlockSize (n x n pixels)
	.space		10 * 19 * 4	// tetrisGridData (cols x rows)
TetrisGridEnd:

TetrisBlock:
	.int		0			// blockX
	.int		0			// blockY
	.word		0xFFFFFF	// blockColor
	.word 		0			// blockTypeAddress
	.int 		0			// blockTypeOffset (0 - 3)
TetrisBlockEnd:

.align 4
TetrisBlockColors:
	.word		0xFFFFFF
	.word		0xAAAAAA
	.word		0xBBBBBB	
	.word		0xCCCCCC	
	.word		0xDDDDDD	
	.word		0x112233	
	.word		0x445566		

.align 4
TetrisBlockA:
	.hword		0x8888			// 0
	.hword		0xF000			// pi/2
	.hword		0x8888			// pi
	.hword		0xF000			// 3pi/4

.align 4
TetrisBlockB:
	.hword		0x8E00			// 0
	.hword		0x44C0			// pi/2
	.hword		0xE200			// pi
	.hword		0xC880			// 3pi/4

.align 4
TetrisBlockC:
	.hword		0x2E00			// 0
	.hword		0xC440			// pi/2
	.hword		0xE800			// pi
	.hword		0x88C0			// 3pi/4

.align 4
TetrisBlockD:
	.hword		0xCC00			// 0
	.hword		0xCC00			// pi/2
	.hword		0xCC00			// pi
	.hword		0xCC00			// 3pi/4

.align 4
TetrisBlockE:
	.hword		0x6C00			// 0
	.hword		0x8C40			// pi/2
	.hword		0x6C00			// pi
	.hword		0x8C40			// 3pi/4

.align 4
TetrisBlockF:
	.hword		0x4E00			// 0
	.hword		0x4C40			// pi/2
	.hword		0xE400			// pi
	.hword		0x8C80			// 3pi/4

.align 4
TetrisBlockG:
	.hword		0xC600			// 0
	.hword		0x4C80			// pi/2
	.hword		0xC600			// pi
	.hword		0x4C80			// 3pi/4

.align 4
font:		.incbin	"font.bin"



.align 4
scoreHeader:
    .int    5
    .ascii  "Score" //Length 5
    
.align 4
scoreText:
    .int    3
    .ascii  "000"
    
.align 4
scoreNumber:
    .int    0

.align 4
QueueHeader:
    .int    8
    .ascii  "Upcoming" //Length 8



.end



