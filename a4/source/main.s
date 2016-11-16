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
	
	//bl		clearScreen
	
	
	
	
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
		
		
		
	
	
	
	
	
	
	
	
	
	
	
	
	mainLoop:
	
	
	
		
		
		
		
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #0
		mov		r1, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #0
		mov		r1, #1
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #0
		mov		r1, #2
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #0
		mov		r1, #3
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #1
		mov		r1, #0
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #1
		mov		r1, #1
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #1
		mov		r1, #2
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #1
		mov		r1, #3
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #2
		mov		r1, #0
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #2
		mov		r1, #1
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #2
		mov		r1, #2
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #2
		mov		r1, #3
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #3
		mov		r1, #0
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #3
		mov		r1, #1
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #3
		mov		r1, #2
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		// tetrisClearGridBlock(int x, int y)
		mov		r0, #3
		mov		r1, #3
		mov		r2, #0
		stmfd	sp!,		{ r0 - r1 }
		bl tetrisClearGridBlock
		
		
		
		
		
		
		
		// Load current block
		ldr		r0, 		=TetrisCurrentBlockTest
		ldmfd	r0,			{ r1 - r7 }
		
		teq		r6,			#0
		beq		initializeBlock_
		bne 	initializeBlockEnd_
		
		initializeBlock_:
		
			mov		r3, 			#0
			mov		r4, 			#0
			ldr		r6, 		=TetrisBlockB
			str		r6, 		[r0, #20]
			mov		r7,	#0
			str		r7,	[r0, #24]
			
		initializeBlockEnd_:
		
	
		
		
			
		
		// tetrisRotateBlockTest2(BLOCK)
		stmfd	sp!,		{ r1 - r7 }
		bl 		tetrisUpdateGridWithBlock
		bl 		tetrisRotateBlockTest2
		
		ldr		r0, 		=TetrisCurrentBlockTest
		ldr		r1, 		[sp, #24]
		str		r1, 		[r0, #24]
		
	
	
		// dx
		// dy
		bl tetrisTranslateBlockTest
	
	
	
		
		bl tetrisDrawGrid
		
		ldr r0, =0xFF
		bl startTimer
		
		b mainLoop
		
		
		
	
	
	
mainEnd:
	b	mainEnd
	
	
	









// INPUT
//		ON STACK
// 		0 = x
// 		1 = y
// 		2 = color
// OUTPUT
//
tetrisSetGridBlockColor:

	x					.req r4
	y					.req r5
	blockColor			.req r6
	tetrisGridData		.req r7
	tetrisGridSize		.req r8
	tetrisGridOffset	.req r9
	
	mov		r0, sp
	
	push 	{ lr }
	push	{ x - tetrisGridOffset }
	
	// load variables from stack
	ldmfd	r0,					{ x - blockColor }
	
	ldr 	tetrisGridData, 	=TetrisGrid
	ldr 	tetrisGridSize, 	[tetrisGridData, #8]
	add 	tetrisGridData, 	#12
	
	// calculate tetris grid offset for block position
	mul		tetrisGridOffset, 	tetrisGridSize, y			
	add		tetrisGridOffset, 	x
	lsl		tetrisGridOffset, 	#2

	// write color to tetrisGridData
	str		blockColor, 		[tetrisGridData, tetrisGridOffset]
	
	pop		{ x - tetrisGridOffset }
	
	.unreq	x
	.unreq	y
	.unreq 	blockColor
	.unreq	tetrisGridData
	.unreq	tetrisGridSize
	.unreq	tetrisGridOffset
	
	pop 	{ lr }
	add		sp, #12
	
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
	
	rows				.req r4
	cols				.req r5
	size				.req r6
	curRow				.req r7
	curCol				.req r8
	color				.req r9
	tetrisGridData		.req r10
	tetrisGridOffset	.req r11
	
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
//		ON STACK
//
//		(Block)
// 		0 = prevX
// 		1 = prevY
// 		2 = x
// 		3 = y
// 		4 = blockColor
// 		5 = blockAddress
// 		6 = blockAddressOffset
// OUTPUT
//		
tetrisUpdateGridWithBlock:

	blockPrevX			.req r4
	blockPrevY			.req r5
	blockX				.req r6
	blockY				.req r7
	blockColor			.req r8
	blockAddress		.req r9
	blockAddressOffset	.req r10
	
	mov		r0, sp
	
	push 	{ lr }
	push	{ blockPrevX - blockAddressOffset }
	
	// load variables from stack
	ldmfd	r0, 		{ blockPrevX - blockAddressOffset }
	
	mov		blockPrevX,	blockX
	mov		blockPrevY,	blockY
	// TODO: why isnt this working?
	//stmfd	r0, 		{ blockPrevX - blockPrevY }
	str		blockPrevX,	[r0, #0]
	str		blockPrevY,	[r0, #4]
	
	// TODO: clear previous position
	

	i	.req r11
	j	.req r12

	mov	i, #0
	mov j, #0
	
	for_i_lessThan_4_loop_:

		push 	{ j } 
	
		for_j_lessThan_4_loop_:
		
			push 	{ blockX - blockColor }
			
			blockBitForXY	.req r1
			blockGridData	.req r2

			ldrh	blockGridData, [blockAddress, blockAddressOffset]
		
			add 	blockX, i
			add 	blockY, j
			
			// calculate bit corresponding to block position
			mov		blockBitForXY, 	#4
			mul		blockBitForXY, 	blockBitForXY, j
			add		blockBitForXY, 	i
			lsl		blockGridData, 	blockBitForXY
			mov		blockBitForXY, 	#0b1000000000000000
			and		blockBitForXY, 	blockGridData
			teq		blockBitForXY, 	#0
			movne	blockBitForXY, 	#1
			// clear grid block if block bit isn't set
			ldreq	blockColor, 	=0x000000		
			
			// tetrisSetGridBlockColor(int x, int y, int color)
			stmfd	sp!,			{ blockX, blockY, blockColor }		
			bl 		tetrisSetGridBlockColor
		
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
		
		.unreq	i
		.unreq 	j
		
	pop		{ blockPrevX - blockAddressOffset }
	
	.unreq	blockPrevX
	.unreq	blockPrevY
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockAddress
	.unreq	blockAddressOffset
	
	pop 	{ lr }
	mov 	pc, lr            // return






	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
tetrisRotateBlockTest:

	push 	{ lr }
	
	blockGridData		.req r0
	rowBitMask			.req r1
	row1				.req r2
	row2				.req r3
	row3				.req r4
	row4				.req r5
	
	push { blockGridData, rowBitMask, row1, row2, row3, row4 }
	
	
	ldr		r0, 				=TetrisCurrentBlock
	ldrh	blockGridData, 		[r0, #20]
	
	mov		rowBitMask, #0b1111
	
	and		row4, rowBitMask, blockGridData
	lsr		blockGridData, #4
	
	and		row3, rowBitMask, blockGridData
	lsr		blockGridData, #4
	
	and		row2, rowBitMask, blockGridData
	lsr		blockGridData, #4
	
	and		row1, rowBitMask, blockGridData
	
	
	
	
	
	
	
	
	// ROTATION (+ pi/2)
	
	
	
	
	
	
	
	// ROTATION (- pi/2)
	
	
	
	
	
	
	
	
	pop { blockGridData, rowBitMask, row1, row2, row3, row4 }
	
	.unreq 				blockGridData
	.unreq 				rowBitMask
	.unreq				row1
	.unreq				row2
	.unreq				row3
	.unreq 				row4
	
	pop 	{ lr }
	mov 	pc, lr            // return	





// INPUT
//		r0 = CC/CCW
//
//		ON STACK
//
//		(Block)
// 		0 = prevX
// 		1 = prevY
// 		2 = x
// 		3 = y
// 		4 = blockColor
// 		6 = blockAddressOffset
// OUTPUT
//		
tetrisRotateBlockTest2:

	prevX				.req r4
	prevY				.req r5
	x					.req r6
	y					.req r7
	blockColor			.req r8
	blockAddress		.req r9
	blockAddressOffset	.req r10
	
	mov		r0, sp
	
	push 	{ lr }
	push	{ prevX - blockAddressOffset }
	
	// load variables from stack
	ldmfd	r0, { prevX - blockAddressOffset }
	
	// ROTATION (+ pi/2)
		//add
	// ROTATION (- pi/2)
		//sub
	
	add		blockAddressOffset, #2
	cmp		blockAddressOffset, #6
	movgt	blockAddressOffset, #0				// wrap around
	
	str		blockAddressOffset, [r0, #24]		// write back
	
	pop		{ prevX - blockAddressOffset }
	
	.unreq	prevX
	.unreq	prevY
	.unreq	x
	.unreq	y
	.unreq 	blockColor
	.unreq	blockAddress
	.unreq	blockAddressOffset
	
	pop 	{ lr }
	mov 	pc, lr            // return



	
	
	

// INPUT
//		r0 = dx
//		r1 = dy
//
//		ON STACK
//
//		(Block)
// 		0 = prevX
// 		1 = prevY
// 		2 = x
// 		3 = y
// 		4 = blockColor
// 		5 = blockAddress
// 		6 = blockAddressOffset
// OUTPUT
//	
tetrisTranslateBlockTest:

	dx					.req r0
	dy					.req r1
	blockPrevX			.req r4
	blockPrevY			.req r5
	blockX				.req r6
	blockY				.req r7
	blockColor			.req r8
	blockAddress		.req r9
	blockAddressOffset	.req r10
	
	mov		r0, sp
	
	push 	{ lr }
	push	{ blockPrevX - blockAddressOffset }
	
	// load variables from stack
	ldmfd	r0, { blockPrevX - blockAddressOffset }
	
	// COLLISION DETECTION
	
	
	pop		{ blockPrevX - blockAddressOffset }
	
	.unreq	dx
	.unreq	dy
	.unreq	blockPrevX
	.unreq	blockPrevY
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockAddress
	.unreq	blockAddressOffset
	
	pop 	{ lr }
	mov 	pc, lr            // return	
	
	
	
	
	
	
	
	
	
	
	
	
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

	x		.req r3
	y		.req r4
	width	.req r5
	height	.req r6
	color	.req r7
	
	// load variables from stack
	ldr 	x, [sp, #0]
	ldr 	y, [sp, #4]
	ldr 	width, [sp, #8]
	ldr 	height, [sp, #12]
	ldr 	color, [sp, #16]
	add		sp, #20
	
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


.align 4
TetrisCurrentBlock:
	.int		0			// prevX
	.int		0			// prevY
	.int		0			// x
	.int		0			// y
	.word		0xFFABCC	// color
	.space 		2			// blockGridData (16 bits, max block size is 4 x 4)
	// 	EX BLOCK (check if block exists by comparing blockGridData to 0
	
TetrisCurrentBlockEnd:


.align 4
TetrisCurrentBlockTest:
	.int		0			// prevX
	.int		0			// prevY
	.int		0			// x
	.int		0			// y
	.word		0x00AABB	// color
	.word 		0			// blockAddress
	.int 		0			// blockAddressOffset (0 - 3)
	
TetrisCurrentBlockTestEnd:


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




