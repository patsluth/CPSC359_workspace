// CPSC 359, Assignment 4
// By: Nathan Escandor and Patrick Sluth
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
	
		
		// tetrisRotateBlockTest(right)
		mov	r0, #1
		bl	tetrisRotateBlockTest
		
		// tetrisTranslateBlock(int dx, int dy)
		mov	r0, #0
		mov	r1, #1
		//bl	tetrisTranslateBlock
		bl	tetrisUpdateGridWithBlock
		
		bl	tetrisDrawGrid
		
		ldr	r0, =0xFF
		bl 	startTimer
		
		

		b	mainLoop


mainEnd:
	b	mainEnd












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
	tetrisGridData		.req r7
	tetrisGridSize		.req r8
	tetrisGridOffset	.req r9
	
	ldmfd	sp!,				{ x - blockColor }
	
	push	{ tetrisGridData - tetrisGridOffset }
	
	ldr 	tetrisGridData, 	=TetrisGrid
	ldr 	tetrisGridSize, 	[tetrisGridData, #8]
	add 	tetrisGridData, 	#12

	// calculate tetris grid offset for block position
	mul		tetrisGridOffset, 	tetrisGridSize, y
	add		tetrisGridOffset, 	x
	lsl		tetrisGridOffset, 	#2

	// write color to tetrisGridData
	str		blockColor, 		[tetrisGridData, tetrisGridOffset]
	
	pop		{ tetrisGridData - tetrisGridOffset }
	
	.unreq	x
	.unreq	y
	.unreq 	blockColor
	.unreq	tetrisGridData
	.unreq	tetrisGridSize
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
	bl tetrisSetGridBlockColor

	.unreq	x
	.unreq	y
	.unreq 	color

	pop 	{ lr }

	mov 	pc, lr            // return





tetrisDrawGrid:

	push 	{ lr }

	rows					.req r4
	cols					.req r5
	size					.req r6
	curRow					.req r7
	curCol					.req r8
	color					.req r9
	tetrisGridData			.req r10
	tetrisGridOffset		.req r11

	push 	{ rows - tetrisGridOffset }

	ldr 	r0, 			=TetrisGrid
	ldmfd	r0!,			{ rows - size }
	mov		tetrisGridData, r0

	mov		curRow, 		#0
	mov		curCol, 		#0

	for_curRow_lessThan_rows_loop:

		push 	{ curCol }

		for_curCol_lessThan_cols_loop:

			push 	{ rows - color }

			// drawRect(int x, int y, int width, int height, int color)

			// calculate tetris grid offset
			mul		tetrisGridOffset, 	rows, curCol
			add		tetrisGridOffset, 	curRow
			lsl		tetrisGridOffset, 	#2
			ldr		color, 				[tetrisGridData, tetrisGridOffset]

			x		.req r0
			y		.req r1

			mul		x, curRow, size
			mul		y, curCol, size

			// push paramaters to stack
			//stmfd	sp!,		{ r1 - r7 }
			sub		sp, #20
			str 	x, 				[sp, #0]
			str 	y,	 			[sp, #4]
			str 	size, 			[sp, #8]
			str 	size, 			[sp, #12]
			str 	color, 			[sp, #16]

			.unreq	x
			.unreq	y

			bl		drawRect

			pop 	{ rows - color }

			add 	curCol, #1
			cmp 	curCol, cols
			blt 	for_curCol_lessThan_cols_loop

		pop 	{ curCol }
		add 	curRow, #1
		cmp 	curRow, rows
		blt 	for_curRow_lessThan_rows_loop

	pop 	{ rows - tetrisGridOffset }

	.unreq	rows
	.unreq	cols
	.unreq	size
	.unreq 	curRow
	.unreq 	curCol
	.unreq 	color
	.unreq 	tetrisGridData
	.unreq 	tetrisGridOffset

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
tetrisRotateBlockTest:

	rotationDirection	.req r0
	blockPrevX			.req r4
	blockPrevY			.req r5
	blockX				.req r6
	blockY				.req r7
	blockColor			.req r8
	blockTypeAddress	.req r9
	blockTypeOffset		.req r10

	ldmfd	sp, { blockPrevX - blockTypeOffset }

	// ROTATION (+ pi/2)
		//add
	// ROTATION (- pi/2)
		//sub


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
	
		b 	tetrisRotateBlockTestEnd
	
	rotateRight:
	
		sub		blockTypeOffset, 	#2
		cmp		blockTypeOffset, 	#0
		movlt	blockTypeOffset, 	#6		// wrap around
		str		blockTypeOffset, 	[sp, #24]
	
		b 	tetrisRotateBlockTestEnd

tetrisRotateBlockTestEnd:

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
	.int	30				// rows
	.int	20				// cols
	.int	30				// nxn block size (pixels)
	.space 	30 * 20 * 4		// tetrisGridData (rows x cols)
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

.end
