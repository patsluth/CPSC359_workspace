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
	
	
	
	
	
	mainLoop:
	
	
	
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
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		bl drawTetrisGrid
		
		// b mainLoop
		
		
		
	
	
	
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
			
			push { rows, cols, size, curRow, curCol, color }
			
			sub		sp, #20						// 5 args
			
			mov		r0, curRow					// x
			mul 	r0, size
			str 	r0, [sp, #0]				// x
			
			mov		r0, curCol					// y
			mul 	r0, size
			str 	r0, [sp, #4]				// y
			
			
			str 	size, [sp, #8]				// width
			str 	size, [sp, #12]				// height
			
			
			
			
			
			
			// calculate color array offset
			mul		r1, rows, curCol
			add		r1, curRow
			lsl		r1, #2
			
			ldr		r0, [color, r1]
			str 	r0, [sp, #16]			// color
			
			bl		drawRect
			
			add		sp, #20
			
			
			
			
			
			
			
			
			pop { rows, cols, size, curRow, curCol, color }
			
			add 	curCol, #1
			cmp 	curCol, cols
			blt 	drawTetrisGridLoopY
		
		pop 	{ curCol } 
		add 	curRow, #1
		cmp 	curRow, rows
		blt 	drawTetrisGridLoopX
	
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
	mov		pc, lr
	
	
	
	
		
//##############################################################//
.section .data

.align 4
TetrisGrid:
	.int	30				// rows
	.int	20				// cols
	.int	30				// nxn block size (pixels)
	.space 	30 * 20 * 4		// grid data (rows x cols)
TetrisGridEnd:

.end




