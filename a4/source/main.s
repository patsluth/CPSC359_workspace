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

	// bl		clearScreen


/*  To-do Charlie:
 *  CPU could not be halted error
 *
 */
//MainMenu:                                       
//    bl      ClearScreenBlack                    //Clears the screen
//    bl      DrawMainMenu                        //draws the base menu
//    
//    PointerAt   .req    r9                      //r8 holds which button is hovered
//    Sample      .req    r10
//    
//    mov PointerAt, #0                           //initialize to 0, ie Start
//MainMenuPrompt:
//    bl      sampleSNES                          //check what buttons are pressed
//                                                //returned in r0
//    mov     sample, r0                          //stores the sample in secure register sample
//    
//    mvn     r1, #0x100                          //moves 1 to every bit except bit 8
//    bic     r0, r1                              //clears every bit of r0 except 8
//    cmp     r0, #0                              //compares masked sample (r0) to 0
//    beq     APressed                            //if equal, then A was pressed, so branch
//                                                //else fall through
//    mov     r0, sample                          //move sample to r0
//    mvn     r1, #0x10                           //moves 1 to every bit except bit 4
//    bic     r0, r1                              //clears every bit except bit 4
//    cmp     r0, #0                              //compares masked sample (r0) to 0
//    beq     UpPressed                           //if equal, then Up was pressed, so branch
//                                                //else fall through
//    mov     r0, sample                          //move sample to r0
//    mvn     r1, #0x20                           //moves 1 to every bit except bit 5
//    bic     r0, r1                              //clears every bit except bit 5
//    cmp     r0, #0                              //compares masked sample (r0) to 0
//   beq     DownPressed                         //if equal, then Down was pressed, so branch
//                                                //else fall through
//                                                //might need to include some delay here
//    b       MainMenuPrompt
    
//if A == pressed
//APressed:
//    cmp PointerAt, #0                           //Checks if r8 points to start
//    beq StartGame                               //if it does, start game
//    bl ClearScreenBlack                         //if not, clear screen
//    b mainEnd                                   //then hang

//if up == pressed
//UpPressed:
//    cmp PointerAt, #0                           //see if r8 already point to top element
//    beq MainMenuPrompt                          //if so do nothing and re-prompt
//    mov PointerAt, #0                           //else make r8 point to start
//    bl  SetMainMenuIndicatorStart               //and re draw indicator
//    b   MainMenuPrompt                          //And re prompt for input

//if down == pressed
//DownPressed:
//    cmp PointerAt, #1                           //see if r8 already points to the bottom element
//    beq MainMenuPrompt                          //if so do nothing and re-prompt
//    mov PointerAt, #1                           //else make r8 point to quit
//    bl  SetMainMenuIndicatorQuit                //and re draw indicator
//    b   MainMenuPrompt                          //and re prompt for input


//    .unreq  PointerAt
//    .unreq  Sample

//StartGame:









  //TODO: Nathan - figure out the warning
  //      "register range not in ascending order"

  //Use this branch to sample from SNES controller.
  //Button bitmask will be returned to r0 in form:
  //  B button pressed (button 1)
  //  r0 = 0xfffe = 1111 1111 1111 1110

  bl    sampleSNES

	ldr 		r0, =TetrisGrid
	add r0, #12
	ldr 		r1, =TetrisGridEnd
	//ldr		r1, [r0, #0]
	//ldr		cols, [r0, #4]
	//ldr		r2, [r0, #8]

	looop:

		// init to black
		ldr		r2, =0x000000
		str		r2, [r0, #0]	// color
		add 	r0, #4

		sub 	r2, r1, r0
		cmp 	r2, #0
		bgt 	looop

















	bl	tetrisCreateNewBlock



	mainLoop:

		// TODO: check for current block on stack?
	
		
		// tetrisRotateBlock(right)
		mov	r0, #1
		bl	tetrisRotateBlock
		
		// tetrisTranslateBlock(int dx, int dy)
		mov	r0, #0
		mov	r1, #1
		bl	tetrisTranslateBlock
		bl	tetrisUpdateGridWithBlock
		
		bl	tetrisDrawGrid
		
		ldr	r0, =0xFF
		bl 	startTimer
		
		

		b	mainLoop


mainEnd:
	b	mainEnd


/*
 *Draws the Title
 */
DrawTitle:
    push {lr}
    
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #100
    str     r0, [sp, #-4]!              //push width
    mov     r0, #94
    str     r0, [sp, #-4]!              //push y
    mov     r0, #222
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #150
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #124
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =257
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    pop {pc}
    
/*
 *Sets the main menu indicator to Start
 */
SetMainMenuIndicatorStart:
    push {lr}

    //Clear the box for the Quit indicator
    ldr     r0, =0xFFFF                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =660
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //Set the box for the Start indicator
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =579
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    pop {pc}

/*
 *Sets the main menu indicator to Quit
 */
SetMainMenuIndicatorQuit:
    push {lr}

    //Clear the box for the Start indicator
    ldr     r0, =0xFFFF                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =579
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //Set the box for the Quit indicator
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =660
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    pop {pc}
    
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

/*
 *Draws the main menu in it's base state
 */
DrawMainMenu:
    push {r9-r10, lr}

    // Get width/height
    ldr	 	r0, =FrameBufferInit
    ldr		r9, [r0, #20]
    ldr		r10, [r0, #24]

    //Screen Background
    ldr     r0, =0x967F                 //color
    str     r0, [sp, #-4]!              //push color
    str     r10, [sp, #-4]!             //push height
    str     r9, [sp, #-4]!              //push width
    mov     r0, #0
    str     r0, [sp, #-4]!              //push y
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //blue rectangle
    ldr     r0, =0x297E                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #200
    str     r0, [sp, #-4]!              //push height
    mov     r0, #600
    str     r0, [sp, #-4]!              //push width
    mov     r0, #84
    str     r0, [sp, #-4]!              //push y
    mov     r0, #212
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    //blue rectangle 2
    ldr     r0, =0x297E                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #200
    str     r0, [sp, #-4]!              //push height
    mov     r0, #200
    str     r0, [sp, #-4]!              //push width
    mov     r0, #284
    str     r0, [sp, #-4]!              //push y
    mov     r0, #412
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //DrawTitle
    bl      DrawTitle

    ldr     r0, =createdHeader          //load the created by header
    mov     r1, #0x0                    //set the color
    ldr     r2, =370                    //load the x offset
    mov     r3, #68                     //load the y offset
    bl      WriteSentence               //write the sentence

    ldr     r0, =437                    //pass in x
    ldr     r1, =564                    //pass in y
    bl      drawStartMenuButton         //Draw the StartGame button

    ldr     r0, =startGameHeader        //load the StartGame button text
    mov     r1, #0x0                    //set the color
    ldr     r2, =487                    //load the x offset
    ldr     r3, =583                    //load the y offset
    bl      WriteSentence               //write the sentence
    
    ldr     r0, =437                    //pass in x
    ldr     r1, =645                    //pass in y
    bl      drawStartMenuButton         //draws the QuitGame button

    ldr     r0, =quitGameHeader         //load the QuitGame button text
    mov     r1, #0x0                    //set the color
    ldr     r2, =491                    //load the x offset
    ldr     r3, =664                    //load the y offset
    bl      WriteSentence               //write the sentence

    bl      SetMainMenuIndicatorStart   //draw the innitial location of the indicator    

    pop     {r9-r10, pc}

/* 
 * Draws a button on the start menu
 * r0 - x start
 * r1 - y start
 */
drawStartMenuButton:
    push    {r9-r10, lr}

    x       .req    r9
    y       .req    r10

    mov     x, r0                       //moves x to secure register
    mov     y, r1                       //moves y to secure register

    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #50
    str     r0, [sp, #-4]!              //push height
    mov     r0, #150
    str     r0, [sp, #-4]!              //push width
    mov     r0, y
    str     r0, [sp, #-4]!              //push y
    mov     r0, x
    str     r0, [sp, #-4]!              //push x
    bl      drawRect                    

    add     x, #5                       //increment x and y for next rectangle
    add     y, #5

    ldr     r0, =0xD7F                  //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #40
    str     r0, [sp, #-4]!              //push height
    mov     r0, #140
    str     r0, [sp, #-4]!              //push width
    mov     r0, y
    str     r0, [sp, #-4]!              //push y
    mov     r0, x
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    add     x, #5                       //Increment x and y for next rectangle
    add     y, #5

    ldr     r0, =0xFFFF                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, y
    str     r0, [sp, #-4]!              //push y
    mov     r0, x
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    .unreq x
    .unreq y

    pop {r9-r10, pc}

WriteSentence:
    push    {r4-r9, lr}         //saves these registers

    length  .req    r4
    address .req    r5
    color   .req    r6
    yAxis   .req    r7
    xAxis   .req    r8

    mov     address, r0         //moves the address to address
    ldr     length, [address]   //loads the length of the address
    add     address, #4         //moves the address pointer to the beginning of the ascii
    mov     color, r1           //stores the values in stable registers for safekeeping
    mov     xAxis, r2           //moves the x start to xAxis
    mov     yAxis, r3           //moves the y start to yAxis

LoadChar:
    ldrb    r0, [address], #1   //loads a byte from address and increments address 
    mov     r1, color           //loads the color
    mov     r2, yAxis           //loads y
    mov     r3, xAxis           //loads x
    bl      DrawChar            //Draws a char

    add     xAxis, #8           //moves x to location for next character
    sub     length, #1          //decreases length by 1
    cmp     length, #0          //checks if length = 0
    bgt     LoadChar            //if it isn't, load another character and repeat        

    .unreq  length
    .unreq  address
    .unreq  color
    .unreq  xAxis
    .unreq  yAxis

    pop     {r4-r9, pc}         //restores these registers

/*Writes a single character to the screen
 *  r0  -   Ascii for character to be printed
 *  r1  -   The color to draw the character
 *  r2  -   The x axis starting point
 *  r3  -   The y axis starting point
 */
DrawChar:
	push	{r4-r9, lr}

	chAdr	.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask	.req	r8
    color   .req    r9

    mov     color,  r1
	ldr		chAdr,	=font		// load the address of the font map
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)
	mov		py,		r2			// init the Y coordinate (pixel coordinate)

charLoop$:
	mov		px,		r3   		// init the X coordinate
	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$
	mov		r0,		px
	mov		r1,		py
	mov		r2,		color		// red
	bl		drawPixel			// draw pixel at (px, py)

noPixel$:
	add		px,		#1			// increment x coordinate by 1
	lsl		mask,	#1			// shift bitmask left by 1
	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$
	add		py,		#1			// increment y coordinate by 1
	tst		chAdr,	#0xF
	bne		charLoop$			// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask
    .unreq  color

	pop		{r4-r9, pc}
	
	
	
	
	
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
	tetrisGridRows		.req r4
	tetrisGridCols		.req r5
	tetrisGridBlockSize	.req r6
	tetrisGridData		.req r7
	tetrisGridOffset	.req r8
	
	ldmfd	sp!,				{ x - blockColor }
	
	push	{ tetrisGridRows - tetrisGridOffset }
	
	ldr 	tetrisGrid, 			=TetrisGrid
	ldr		tetrisGridRows,			[tetrisGrid, #0]
	ldr		tetrisGridCols,			[tetrisGrid, #4]
	ldr		tetrisGridBlockSize,	[tetrisGrid, #8]
	add 	tetrisGridData, 		tetrisGrid, #12

	// calculate tetris grid offset for block position
	mul		tetrisGridOffset, 	tetrisGridCols, y
	add		tetrisGridOffset, 	x
	lsl		tetrisGridOffset, 	#2

	// write color to tetrisGridData
	str		blockColor, 		[tetrisGridData, tetrisGridOffset]
	
	pop		{ tetrisGridRows - tetrisGridOffset }
	
	.unreq	x
	.unreq	y
	.unreq 	blockColor
	.unreq	tetrisGrid
	.unreq	tetrisGridRows
	.unreq	tetrisGridCols
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	.unreq	tetrisGridOffset

	mov 	pc, lr            // return





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
	ldr 	color, 			=0x000000
	stmfd	sp!,			{ x - color }
	bl 		tetrisSetGridBlockColor

	.unreq	x
	.unreq	y
	.unreq 	color

	pop 	{ lr }

	mov 	pc, lr            // return





tetrisDrawGrid:

	push 	{ lr }
	
	curRow				.req r4
	curCol				.req r5
	curColor			.req r6
	tetrisGrid			.req r7
	tetrisGridRows		.req r8
	tetrisGridCols		.req r9
	tetrisGridBlockSize	.req r10
	tetrisGridData		.req r11
	tetrisGridOffset	.req r12

	push	{ curRow - tetrisGridOffset }
	
	ldr 	tetrisGrid, 			=TetrisGrid
	ldr		tetrisGridRows,			[tetrisGrid, #0]
	ldr		tetrisGridCols,			[tetrisGrid, #4]
	ldr		tetrisGridBlockSize,	[tetrisGrid, #8]
	add 	tetrisGridData, 		tetrisGrid, #12

	mov		curRow, 		#0
	mov		curCol, 		#0
	mov		curColor, 		#0

	for_curRow_lessThan_rows_loop:

		push 	{ curCol }

		for_curCol_lessThan_cols_loop:

			push 	{ curRow - tetrisGridOffset }

			// drawRect(int x, int y, int width, int height, int color)

			// calculate tetris grid offset for block position
			mul		tetrisGridOffset, 		tetrisGridCols, curCol
			add		tetrisGridOffset, 		curRow
			lsl		tetrisGridOffset, 		#2
			
			ldr		curColor, 				[tetrisGridData, tetrisGridOffset]

			x		.req r0
			y		.req r1

			mul		x, curRow, tetrisGridBlockSize
			mul		y, curCol, tetrisGridBlockSize

			// push paramaters to stack
			//stmfd	sp!,	{ r1 - r7 }
			sub		sp, 					#20
			str 	x, 						[sp, #0]
			str 	y,	 					[sp, #4]
			str 	tetrisGridBlockSize, 	[sp, #8]
			str 	tetrisGridBlockSize, 	[sp, #12]
			str 	curColor, 				[sp, #16]

			.unreq	x
			.unreq	y

			bl		drawRect

			pop 	{ curRow - tetrisGridOffset }

			add 	curCol, #1
			cmp 	curCol, tetrisGridCols
			blt 	for_curCol_lessThan_cols_loop

		pop 	{ curCol }
		add 	curRow, #1
		cmp 	curRow, tetrisGridRows
		blt 	for_curRow_lessThan_rows_loop

	pop	{ curRow - tetrisGridOffset }
	
	.unreq 	curRow
	.unreq 	curCol
	.unreq 	curColor
	.unreq	tetrisGrid
	.unreq	tetrisGridRows
	.unreq	tetrisGridCols
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	.unreq	tetrisGridOffset

	pop 	{ lr }
	mov 	pc, lr            // return






// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockPrevX
// 		1 = blockPrevY
// 		2 = blockX
// 		3 = blockY
// 		4 = blockColor
// 		5 = blockTypeAddress
// 		6 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisUpdateGridWithBlock:

	blockPrevX			.req r4
	blockPrevY			.req r5
	blockX				.req r6
	blockY				.req r7
	blockColor			.req r8
	blockTypeAddress	.req r9
	blockTypeOffset		.req r10
	mov		r0, sp

	push 	{ lr }
	push	{ blockPrevX - blockTypeOffset }

	ldmfd	r0, 		{ blockPrevX - blockTypeOffset }

	mov		blockPrevX,	blockX
	mov		blockPrevY,	blockY
	str		blockPrevX,	[r0, #0]
	str		blockPrevY,	[r0, #4]

	i	.req r11
	j	.req r12
	
	push	{ i - j }

	mov	i, #0
	mov j, #0

	for_i_lessThan_4_loop_:

		push 	{ j }

		for_j_lessThan_4_loop_:

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

			// if (blockBitForXY == 0)

				// tetrisClearGridBlock(int x, int y)
				moveq	r0, 	blockX
				moveq	r1,		blockY
				bleq 	tetrisClearGridBlock

			// else

				// tetrisSetGridBlockColor(int x, int y, int color)
				stmnefd	sp!, 	{ blockX, blockY, blockColor }
				blne 	tetrisSetGridBlockColor

			// endif

			.unreq	blockBitForXY
			.unreq 	blockGridData

			pop 	{ blockX - blockColor }

			add 	j, #1
			cmp 	j, #4
			blt 	for_j_lessThan_4_loop_

		pop 	{ j }
		add 	i, #1
		cmp 	i, #4
		blt 	for_i_lessThan_4_loop_
		
		pop		{ i - j }
		
		.unreq	i
		.unreq 	j

	pop		{ blockPrevX - blockTypeOffset }

	.unreq	blockPrevX
	.unreq	blockPrevY
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	pop 	{ lr }
	mov 	pc, lr            // return





// INPUT
//
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = blockPrevX
// 		1 = blockPrevY
// 		2 = blockX
// 		3 = blockY
// 		4 = blockColor
// 		5 = blockTypeAddress
// 		6 = blockTypeOffset
//		--------
tetrisCreateNewBlock:

	blockPrevX			.req r4
	blockPrevY			.req r5
	blockX				.req r6
	blockY				.req r7
	blockColor			.req r8
	blockTypeAddress	.req r9
	blockTypeOffset		.req r10

	ldr		r0, 		=TetrisBlock
	ldmfd	r0,			{ blockPrevX - blockTypeOffset }

	initializeTetrisBlock:

		mov 	blockPrevX, 		#0
		mov 	blockPrevY, 		#0
		mov 	blockX, 			#0				// randomize?
		mov 	blockY,				#0
		ldr 	blockColor,	 		=0x1133FF		// randomize?
		ldr		blockTypeAddress, 	=TetrisBlockB	// randomize?
		mov		blockTypeOffset,	#0				// randomize?

	initializeTetrisBlockEnd:

	stmfd	sp!,		{ blockPrevX - blockTypeOffset }

	.unreq	blockPrevX
	.unreq	blockPrevY
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	mov 	pc, lr            // return
	
	
	
	
	
// INPUT
//		r0 = CC/CCW	(0 == CC, otherwise CCW)
//
//		--------
//		On Stack
//		--------
// 		0 = blockPrevX
// 		1 = blockPrevY
// 		2 = blockX
// 		3 = blockY
// 		4 = blockColor
// 		5 = blockTypeAddress
// 		6 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisRotateBlock:

	rotationDirection	.req r0
	blockPrevX			.req r4
	blockPrevY			.req r5
	blockX				.req r6
	blockY				.req r7
	blockColor			.req r8
	blockTypeAddress	.req r9
	blockTypeOffset		.req r10

	ldmfd	sp, { blockPrevX - blockTypeOffset }







	/* HOW TO ACCESS ROW DATA
	mov		rowBitMask, #0b1111

	and		row4, rowBitMask, blockGridData
	lsr		blockGridData, #4

	and		row3, rowBitMask, blockGridData
	lsr		blockGridData, #4

	and		row2, rowBitMask, blockGridData
	lsr		blockGridData, #4

	and		row1, rowBitMask, blockGridData

	*/






	teq		rotationDirection, 	#0
	beq		rotateLeft
	bne		rotateRight
	
	rotateLeft:
	
		add		blockTypeOffset, 	#2
		cmp		blockTypeOffset, 	#6
		movgt	blockTypeOffset, 	#0		// wrap around
		str		blockTypeOffset, 	[sp, #24]
	
		b 	tetrisRotateBlockEnd
	
	rotateRight:
	
		sub		blockTypeOffset, 	#2
		cmp		blockTypeOffset, 	#0
		movlt	blockTypeOffset, 	#6		// wrap around
		str		blockTypeOffset, 	[sp, #24]
	
		b 	tetrisRotateBlockEnd

tetrisRotateBlockEnd:

	.unreq 	rotationDirection
	.unreq	blockPrevX
	.unreq	blockPrevY
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	mov 	pc, lr            // return
	
	
	
	
	
// INPUT
//		r0 = dx
//		r1 = dy
//
//		--------
//		On Stack
//		--------
// 		0 = blockPrevX
// 		1 = blockPrevY
// 		2 = blockX
// 		3 = blockY
// 		4 = blockColor
// 		5 = blockTypeAddress
// 		6 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisTranslateBlock:

	dx					.req r0
	dy					.req r1
	blockPrevX			.req r4
	blockPrevY			.req r5
	blockX				.req r6
	blockY				.req r7
	blockColor			.req r8
	blockTypeAddress	.req r9
	blockTypeOffset		.req r10
	
	mov	r11, lr
	
	// pop block
	ldmfd	sp!, 	{ blockPrevX - blockTypeOffset }
	
	// update block values
	mov		blockPrevX, blockX
	mov		blockPrevY, blockY
	add		blockX, dx
	add		blockY, dy
	
	str		blockPrevX, [sp, #0]
	str		blockPrevY, [sp, #4]
	str		blockX, [sp, #8]
	str		blockY, [sp, #12]
	
	// push block
	stmfd	sp!, 	{ blockPrevX - blockTypeOffset }
	
	// make blank copy of block
	// in previous position and with black color
	mov	blockX, blockPrevX
	mov	blockY, blockPrevY
	ldr	blockColor, =0x0
	
	// tetrisUpdateGridWithBlock(blankBlock) 
	stmfd	sp!, 	{ blockPrevX - blockTypeOffset }
	bl	tetrisUpdateGridWithBlock
	
	// tetrisUpdateGridWithBlock(currentBlock) 
	ldmfd	sp!, 	{ blockPrevX - blockTypeOffset }
	bl	tetrisUpdateGridWithBlock
	
	//ldmfd	sp!, 	{ blockPrevX - blockTypeOffset }
	//stmfd	sp!, 	{ blockPrevX - blockTypeOffset }
	
	
	
	
	// COLLISION DETECTION
	
	
	

	.unreq	dx
	.unreq	dy
	.unreq	blockPrevX
	.unreq	blockPrevY
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset
	
	mov 	pc, r11            // return	
	
	
	
	

// INPUT
//
// OUTPUT
//
clearScreen:

	push 	{ lr }

	x				.req r4
	y				.req r5
	screenWidth		.req r6
	screenHeight	.req r7
	color			.req r8

	push 	{ x - color }

	// drawRect(int x, int y, int width, int height, int color)
	mov		x, #0
	mov		y, #0
	ldr	 	r0, =FrameBufferInit
	ldr		screenWidth, [r0, #20]
	ldr		screenHeight, [r0, #24]
	ldr		color,	=0x000000			// black

	stmfd	sp!,		{ x - color }
	bl		drawRect

	pop 	{ x - color }

	.unreq	x
	.unreq	y
	.unreq	screenWidth
	.unreq	screenHeight
	.unreq	color

	pop 	{ lr }
	mov 	pc, lr            // return





// INPUT
// 		r0 = x
// 		r1 = y
// 		r2 = Color
// OUTPUT
//
drawPixel:

	push 	{ lr }

	offset		.req r4

	push	{ offset }

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10

	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset
	ldr		r0, =FrameBufferPointer
	ldr		r0, [r0]
	strh	r2, [r0, offset]

	pop 	{ offset }

	.unreq		offset

	pop 	{ lr }
	mov 	pc, lr            // return





// INPUT
//		ON STACK
// 		0 = x
// 		1 = y
// 		2 = width
// 		3 = height
// 		4 = color
// OUTPUT
//
drawRect:

	x		.req r4
	y		.req r5
	width	.req r6
	height	.req r7
	color	.req r8

	ldmfd	sp!, 	{ x - color }

	push 	{ lr }

	add 	width, x
	add 	height, y

	drawRectForLoopX:

		push 	{ y }

		drawRectForLoopY:

			mov 	r0, x
			mov		r1, y
			mov		r2,	color
			bl 		drawPixel
			
			add 	y, #1
			cmp 	y, height
			blt 	drawRectForLoopY

		pop 	{ y }
		add 	x, #1
		cmp 	x, width
		blt 	drawRectForLoopX

	.unreq		x
	.unreq 		y
	.unreq 		width
	.unreq 		height
	.unreq 		color

	pop 	{ lr }
	mov 	pc, lr            // return
	
	
	
	
	
// INPUT
// 		r0 = delay
// OUTPUT
//
startTimer:

	mov r3, r0            	// r3 holds the delay length
	ldr r0, =0x3F003004  	// address of CLO og: 0x3F003004
	ldr r1, [r0]          	// read CLO
	add r1, r3            	// add delay (should just be 12 micros)

	waitLoop:
		ldr r2, [r0]
		cmp r1, r2          	// stop when CLO = r1
		bhi waitLoop

	mov pc, lr            	// return





//##############################################################//
.section .data

.align 4
TetrisGrid:
	.int	40				// tetrisGridRows
	.int	40				// tetrisGridCols
	.int	15				// tetrisGridBlockSize (nxn pixels)
	.space 	40 * 40 * 4		// tetrisGridData (rows x cols)
TetrisGridEnd:


TetrisBlock:
	.int		0			// blockPrevX
	.int		0			// blockPrevY
	.int		0			// blockX
	.int		0			// blockY
	.word		0x00AABB	// blockColor
	.word 		0			// blockTypeAddress
	.int 		0			// blockTypeOffset (0 - 3)
TetrisBlockEnd:


.align 4
TetrisBlockA:
	.hword		0x8888			// 0
	//	1---
	//	1---
	//	1---
	//	1---
	.hword		0xF000			// pi/2
	//	1111
	//	----
	//	----
	//	----
	.hword		0x8888			// pi
	//	1---
	//	1---
	//	1---
	//	1---
	.hword		0xF000			// 3pi/4
	//	1111
	//	----
	//	----
	//	----
TetrisBlockAEnd:


.align 4
TetrisBlockB:
	.hword		0x8E00			// 0
	//	1---
	//	111-
	//	----
	//	----
	.hword		0x44C0			// pi/2
	//	-1--
	//	-1--
	//	11--
	//	----
	.hword		0xE200			// pi
	//	111-
	//	--1-
	//	----
	//	----
	.hword		0xC880			// 3pi/4
	//	11--
	//	1---
	//	1---
	//	----
TetrisBlockBEnd:


.align 4
TetrisBlockC:
	.hword		0x2E00			// 0
	//	--1-
	//	111-
	//	----
	//	----
	.hword		0xC440			// pi/2
	//	11--
	//	-1--
	//	-1--
	//	----
	.hword		0xE800			// pi
	//	111-
	//	1---
	//	----
	//	----
	.hword		0x88C0			// 3pi/4
	//	1---
	//	1---
	//	11--
	//	----

TetrisBlockCEnd:


.align 4
TetrisBlockD:
	.hword		0xCC00			// 0
	//	11--
	//	11--
	//	----
	//	----
	.hword		0xCC00			// pi/2
	//	11--
	//	11--
	//	----
	//	----
	.hword		0xCC00			// pi
	//	11--
	//	11--
	//	----
	//	----
	.hword		0xCC00			// 3pi/4
	//	11--
	//	11--
	//	----
	//	----

TetrisBlockDEnd:

.align 4
font:		.incbin	"font.bin"

.align 4
createdHeader:
    .int    55
    .ascii  "Created by: Nathan Escandor, Charlie Roy, and Pat Sluth" //Length 55

.align 4
scoreHeader:
    .int    6
    .ascii  "Score:" //Length 6

.align 4
startGameHeader:
    .int    10
    .ascii  "Start Game"

.align 4
quitGameHeader:
    .int    9
    .ascii  "Quit Game"

.end
