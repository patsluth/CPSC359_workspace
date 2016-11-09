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
	
	
	
	mainLoop:
	
	
	
		// Get width/height
		ldr	 	r0, =FrameBufferInit
		ldr		r9, [r0, #20]
		ldr		r10, [r0, #24]
		
		
		
		// Example to clear screen
		mov 	r3, #0						// x
		mov 	r4, #0						// y
		mov 	r5, r9						// width
		mov 	r6, r10						// height
		ldr		r7,	=0x000000				// color
		stmfd 	sp!, { r3, r4, r5, r6, r7 }
		
		bl		drawRect
		
		
		
		mov 	r3, #0						// x
		mov 	r4, #100					// y
		mov 	r5, #100					// width
		mov 	r6, #100					// height
		ldr		r7,	=0x99FF00				// color
		stmfd 	sp!, { r3, r4, r5, r6, r7 }
		
		bl		drawRect
		
		
		
		mov 	r3, #100					// x
		mov 	r4, #100					// y
		mov 	r5, #400					// width
		mov 	r6, #400					// height
		ldr		r7,	=0xFFCC00				// color
		stmfd 	sp!, { r3, r4, r5, r6, r7 }
		
		bl		drawRect
		
		
		
		mov 	r3, #500					// x
		mov 	r4, #0						// y
		mov 	r5, #500					// width
		mov 	r6, #250					// height
		ldr		r7,	=0xFFCCFF				// color
		stmfd 	sp!, { r3, r4, r5, r6, r7 }
		
		bl		drawRect
		
		
		
		b mainLoop
	
	
	
	
	
	
	
	
mainEnd:
	b	mainEnd
	
	
	
	
	

	
	
	
	
	
	
// INPUT
// 		r3 = x
// 		r4 = y
// 		r5 = width
// 		r6 = height
// 		r7 = color
// OUTPUT
//
drawRect:

	x		.req r3
	y		.req r4
	width	.req r5
	height	.req r6
	color	.req r7
	
	ldmfd sp!, { x, y, width, height, color }
	
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

.globl Rect
Rect: 
	.int 0, 0, 0, 0
RectEnd:

.end




