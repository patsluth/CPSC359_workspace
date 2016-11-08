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
		ldr r0, =FrameBufferInit
		ldr	r9, [r0, #20]
		ldr	r10, [r0, #24]

		// Example to clear screen
		ldr r0, =Rect
		mov r1, #0
		str r1, [r0, #0]
		mov r1, #0
		str r1, [r0, #4]
		mov r1, r9
		str r1, [r0, #8]
		mov r1, r10
		str r1, [r0, #12]
		ldr		r1,	=0x000000				// Color
		bl		drawRect
	
	
	
	
	
	
	
	
	
		ldr r0, =Rect
		mov r1, #0
		str r1, [r0, #0]
		mov r1, #0
		str r1, [r0, #4]
		mov r1, #100
		str r1, [r0, #8]
		mov r1, #100
		str r1, [r0, #12]
		ldr		r1,	=0x99FF00				// Color
		bl		drawRect
	
	
	
	
	
	
		ldr r0, =Rect
		mov r1, #100
		str r1, [r0, #0]
		mov r1, #100
		str r1, [r0, #4]
		mov r1, #400
		str r1, [r0, #8]
		mov r1, #400
		str r1, [r0, #12]
		ldr		r1,	=0xFFCC00				// Color
		bl		drawRect
	
	
	
	
	
		ldr r0, =Rect
		mov r1, #500
		str r1, [r0, #0]
		mov r1, #0
		str r1, [r0, #4]
		mov r1, #500
		str r1, [r0, #8]
		mov r1, #250
		str r1, [r0, #12]
		ldr		r1,	=0xFFCCFF				// Color
		bl		drawRect
		
		b mainLoop
	
	
	
	
	
	
	
	
mainEnd:
	b mainEnd
	
	
	
	
	
// INPUT
// 		r0 = Rect:
// 		r1 = Color
// OUTPUT
//
drawRect:

	push 	{ lr }

	positionX	.req r3
	positionY	.req r4
	sizeWidth	.req r5
	sizeHeight	.req r6
	color		.req r7
	push 	{ positionX, positionY, sizeWidth, sizeHeight, color }
	
	ldr 	positionX, [r0, #0]
	ldr 	positionY, [r0, #4]
	ldr 	sizeWidth, [r0, #8]
	ldr 	sizeHeight, [r0, #12]
	mov 	color, r1
	
	add 	sizeWidth, positionX
	add 	sizeHeight, positionY
	
	forLoopX:
		
		push 	{ positionY } 
	
		forLoopY:
		
			mov 	r0, positionX	
			mov		r1, positionY			
			mov		r2,	color				
			bl 		drawPixel
			
			add 	positionY, #1
			cmp 	positionY, sizeHeight
			blt 	forLoopY
		
		pop 	{ positionY } 
		add 	positionX, #1
		cmp 	positionX, sizeWidth
		blt 	forLoopX

	pop 	{ positionX, positionY, sizeWidth, sizeHeight, color }
	.unreq		positionX
	.unreq 		positionY
	.unreq 		sizeWidth
	.unreq 		sizeHeight
	.unreq 		color
	
	pop 	{ lr }
	mov 	pc, lr            // return
	
	
	
	
	
// INPUT
// 		r0 = positionX
// 		r1 = positionY
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




