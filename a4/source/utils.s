// CPSC 359, lengthy printing function for use with A4 (Tetris)
// By: Nathan Escandor, Charlie Roy, and Patrick Sluth
// November 22, 2016

//##############################################################//

//##############################################################//
.section .text

// INPUT
//
// OUTPUT
//
.globl clearScreen
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
	ldr		color,	=0x000000	// black

	stmfd	sp!,		{ x - color }
	bl		drawRect

	pop 	{ x - color }

	.unreq	x
	.unreq	y
	.unreq	screenWidth
	.unreq	screenHeight
	.unreq	color

	pop 	{ lr }
	mov 	pc, lr				// return





// INPUT
// 		r0 = x
// 		r1 = y
// 		r2 = Color
// OUTPUT
//
.globl drawPixel
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
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
// 		2 = width
// 		3 = height
// 		4 = color
//		--------
// OUTPUT
//		r0 = boolean (0 == no collision)
//
.globl drawRect
drawRect:

	x		.req r4
	y		.req r5
	width	.req r6
	height	.req r7
	color	.req r8
	
	mov		r0, 	sp
	push 	{ lr }
	push 	{ x - color }

	ldmfd	r0, 	{ x - color }

	add 	width, 	x
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

	pop		 	{ x - color }
	
	.unreq		x
	.unreq 		y
	.unreq 		width
	.unreq 		height
	.unreq 		color

	pop 	{ lr }
	add		sp, #20			// delete function arguments
	mov pc, lr            	// return
	
	
	
	

// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
// 		2 = cols
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = offset
//		--------
//
.globl positionToArrayOffset
positionToArrayOffset:

	x			.req r0
	y			.req r1
	cols		.req r2
	offset		.req r3
	
	ldmfd	sp!, 	{ x - cols }
	
	// calculate 1D offset for 2D array
	mul		offset,	cols, y
	add		offset,	x
	
	stmfd	sp!, 	{ offset }
	
	.unreq 	x
	.unreq 	y
	.unreq	cols
	.unreq	offset
	
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
// 		r0 = delay
// OUTPUT
//
.globl startTimer
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
    
    
    
    
    
    
.section .data
.end
