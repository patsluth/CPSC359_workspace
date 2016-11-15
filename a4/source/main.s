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
		
		
		
		
		
	// temp set blocks
	ldr 		r0, =TetrisGrid
	add r0, #12
	
	ldr		r2, =0xFFABCC
	str		r2, [r0, #60]	// color
	str		r2, [r0, #64]	// color
	str		r2, [r0, #68]	// color
	str		r2, [r0, #180]	// color
	
	ldr		r2, =0x00AABB
	str		r2, [r0, #480]	// color
	str		r2, [r0, #484]	// color
	str		r2, [r0, #600]	// color
	str		r2, [r0, #720]	// color
	
	
	str		r2, [r0, #484]	// color
	
	
	
	
	
	
	
	
	
	
		
	
	// Get width/height
	ldr	 	r0, =FrameBufferInit
	ldr		r9, [r0, #20]
	ldr		r10, [r0, #24]
	
	// Example to clear screen
	mov		r0, sp
	sub		sp, #20						// 5 args
	mov		r1, #0						// x
	str 	r1, [sp, #0]				// x
	mov		r1, #0						// y
	str 	r1, [sp, #4]				// y
	str 	r9, [sp, #8]				// width
	str 	r10, [sp, #12]				// height
	ldr		r2,	=0x000000				// color
	str 	r2, [sp, #16]				// color
	//stmfd 	sp!, { r3, r4, r5, r6, r7 }
	bl		drawRect
	
	add sp, #20
	
	
	
	
	
	
	mainLoop:
	
	
	
		// TODO: pass block into tetrisUpdateGridWithCurrentBlock
		//		 and create an empty block on stack to clear
	
		// Load current block
		ldr		r0, 		=TetrisCurrentBlockTest
		ldr		r1, 		[r0, #0]
		ldr		r2, 		[r0, #4]
		ldr		r3, 		[r0, #8]
		ldr		r4, 		[r0, #12]
		ldr		r5,			[r0, #16]
		ldr		r6, 		[r0, #20]
		ldr		r7, 		[r0, #24]
		
		
		
		push { r0 - r7 }
	
		str		r1, 		[r0, #8]
		str		r2, 		[r0, #12]
		mov		r5,			#0 // black
		str		r5,			[r0, #16]
	
		pop { r0 - r7 }
		
		
		bl tetrisUpdateGridWithCurrentBlock
		
		str		r3, 		[r0, #8]
		str		r4, 		[r0, #12]
		str		r5,			[r0, #16]
	
		
		bl tetrisUpdateGridWithCurrentBlock
		
		bl tetrisRotateBlockTest2
	
	
	
	
	
		
		bl drawTetrisGrid
		
		ldr r0, =0xFFFFF
		bl startTimer
		
		b mainLoop
		
		
		
	
	
	
mainEnd:
	b	mainEnd
	
	
	
	
	

	
	
	
	
	
	
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
	
	ldr 	x, [sp, #0]
	ldr 	y, [sp, #4]
	ldr 	width, [sp, #8]
	ldr 	height, [sp, #12]
	ldr 	color, [sp, #16]
	
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
	
	
	

	
	
	
drawTetrisGrid:

	push 	{ lr }
	
	rows		.req r1
	cols		.req r2
	size		.req r3
	curRow		.req r4
	curCol		.req r5
	color		.req r6
	
	ldr 	r0, =TetrisGrid
	ldr		rows, [r0, #0]
	ldr		cols, [r0, #4]
	ldr		size, [r0, #8]
	add		color, r0, #12
	
	mov		curRow, #0
	mov		curCol, #0
	
	drawTetrisGridLoopX:
		
		push 	{ curCol } 
	
		drawTetrisGridLoopY:
		
		
		
		
			// TODO: clean up
			
			push 	{ rows, cols, size, curRow, curCol, color }
			
			sub		sp, #20						// push 5 args
			
			mov		r0, curRow					// x
			mul 	r0, size
			str 	r0, [sp, #0]				// x
			mov		r0, curCol					// y
			mul 	r0, size
			str 	r0, [sp, #4]				// y
			str 	size, [sp, #8]				// width
			str 	size, [sp, #12]				// height
			
			
			mul		r1, rows, curCol			// calculate tetris grid offset
			add		r1, curRow
			lsl		r1, #2
			ldr		r0, [color, r1]				
			str 	r0, [sp, #16]				// color
			bl		drawRect
			
			add		sp, #20						// pop 5 args
			
			pop 	{ rows, cols, size, curRow, curCol, color }
			
			add 	curCol, #1
			cmp 	curCol, cols
			blt 	drawTetrisGridLoopY
		
		pop 	{ curCol } 
		add 	curRow, #1
		cmp 	curRow, rows
		blt 	drawTetrisGridLoopX
	
	pop 	{ lr }
	mov 	pc, lr            // return
	
	
	
	
tetrisUpdateGridWithCurrentBlock:

	push 	{ lr }
	
	blockPrevX			.req r1
	blockPrevY			.req r2
	blockX				.req r3
	blockY				.req r4
	blockColor			.req r5
	blockAddress		.req r6
	blockAddressOffset	.req r7
	blockGridData		.req r8
	
	push { r0 - r12 }
	
	
	
	
	
	// Load current block
	ldr		r0, 					=TetrisCurrentBlockTest
	ldr		blockPrevX, 			[r0, #0]
	ldr		blockPrevY, 			[r0, #4]
	ldr		blockX, 				[r0, #8]
	ldr		blockY, 				[r0, #12]
	ldr		blockColor,				[r0, #16]
	ldr		blockAddress, 			[r0, #20]
	ldr		blockAddressOffset, 	[r0, #24]
	
	
	
	
	
	teq		blockAddress,			#0
	beq		generateBlock
	bne 	generateBlockEnd
	
	generateBlock:
	
		mov		blockX, 			#0
		mov		blockY, 			#0
		ldr		blockAddress, 		=TetrisBlockA
		str		blockAddress, 		[r0, #20]
		mov		blockAddressOffset,	#0
		str		blockAddressOffset,	[r0, #24]
	
	generateBlockEnd:
	
		mov		blockPrevX,			blockX
		mov		blockPrevY,			blockY
		str		blockPrevX,			[r0, #0]
		str		blockPrevY,			[r0, #4]
		
		ldrh	blockGridData, 		[blockAddress, blockAddressOffset]
	
		// ROTATE
		//add		blockAddressOffset, #2
		//cmp		blockAddressOffset, #6
		//movgt	blockAddressOffset, #0
		//str		blockAddressOffset, 	[r0, #24]
		
		
		// clear previous position
		
	
		i	.req r9
		j	.req r10
	
		mov	i, #0
		mov j, #0
		
		for_i_lessThan_4_loop:
	
			push 	{ j } 
		
			for_j_lessThan_4_loop:
			
			
				push { blockX, blockY }
				
				add blockX, i
				add blockY, j
				
				mov		r11, #30	// TEMP HARDCODED ROWS
				mul		r11, r11, blockY			// calculate tetris grid offset
				add		r11, blockX
				lsl		r11, #2
				// R11 is the block in the tetris grid
				pop { blockX, blockY }
				
				mov		r12, #4
				mul		r12, r12, j
				add		r12, i
				
				//pop { blockX, blockY }
				push { blockGridData }
				
				lsl		blockGridData, r12
				mov		r12, #0b1000000000000000
				and		r12, blockGridData
				teq		r12, #0
				movne	r12, #1
				
				
				// write block
				push { r0, blockColor }
				ldr 		r0, =TetrisGrid
				add 		r0, #12
				ldreq		blockColor, =0x000000	// black
				str			blockColor, [r0, r11]	// color
				//streq		r12, [r0, r11]	// color
				pop { r0, blockColor }
				
				
				
				
				// R7 is the bit corresponding to X,Y at this point
				
				pop { blockGridData }

				add 	j, #1
				cmp 	j, #4
				blt 	for_j_lessThan_4_loop
			
			pop 	{ j } 
			add 	i, #1
			cmp 	i, #4
			blt 	for_i_lessThan_4_loop
			
			.unreq		i
			.unreq 		j
			
	add		blockY, 			#1
	str		blockY, 			[r0, #12]
			
		
			
		
		
		
		
	
		
	
	
	
	
	pop { r0 - r12 }
	
	.unreq			blockPrevX
	.unreq			blockPrevY
	.unreq			blockX
	.unreq 			blockY
	.unreq 			blockColor
	.unreq 			blockAddress
	.unreq 			blockAddressOffset
	.unreq 			blockGridData
	
	pop 	{ lr }
	mov		pc, lr
	
	
	
	
	
	
	
	
	
	
	
	
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
	mov		pc, lr	
	
	
	
	
	
tetrisRotateBlockTest2:

	push 	{ lr }
	
	blockGridData		.req r0
	blockAddress		.req r1
	blockAddressOffset	.req r2
	
	push { blockGridData, blockAddress, blockAddressOffset }


	// Load current block
	ldr		r0, 				=TetrisCurrentBlockTest
	ldr		blockAddressOffset, 				[r0, #24]
	
	
	add		blockAddressOffset, #2
	cmp		blockAddressOffset, #6
	movgt	blockAddressOffset, #0
	
	str		blockAddressOffset,	[r0, #24]
	
	
	
	
	
	// ROTATION (+ pi/2)
	
	
	
	
	
	
	
	// ROTATION (- pi/2)
	
	
	
	
	
	
	
	
	pop { blockGridData, blockAddress, blockAddressOffset }
	
	.unreq 				blockGridData
	.unreq 				blockAddress
	.unreq				blockAddressOffset
	
	pop 	{ lr }
	mov		pc, lr	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
// INPUT
// 		r0 = row
// 		r1 = col
// 		r2 = rows
// OUTPUT
// 		r0 = tetrisGridOffset
//
/*
getTetrisGridOffset:

	row		.req r0
	col		.req r1
	rows	.req r2
	
	push	{ lr, r3 }
	
	mul		r3, rows, col
	add		r3, row
	lsl		r3, #2
	mov		r0, r3
	
	.unreq		row
	.unreq 		col
	.unreq 		rows
	
	pop		{ lr, r3 }
	mov 	pc, lr            			// return
	g
*/
	
	
	
	
	
	
	
	
	
	
	
	
	
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
	mov		pc, lr
	
	
	
	
	

	
	
	
	
	
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
	.space 	30 * 20 * 4		// grid data (rows x cols)
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
	.word		0xFFABCC	// color
	.word 		0			// blockAddress
	.int 		0			// blockAddressOffset (0 - 3)
	
TetrisCurrentBlockTestEnd:




.align 4
TetrisBlockA:
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
TetrisBlockEnd:






.end




