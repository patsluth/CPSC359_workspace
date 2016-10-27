.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    mov     sp, #0x8000
	
	bl		EnableJTAG


	// *** Set Line 47 to Output ***

	// load the address of Function Select Register 5
	ldr		r0, =0x3F200010

	// load the value of Function Select Register 5
	ldr		r1, [r0]

	// clear bits 21-23 (for Line 47)
	mov		r2, #0b111
	bic		r1, r2, lsl #21
	
	// set bits 21-23 (for line 47) to 001 (Output function)
	mov		r2, #0b001
	orr		r1, r2, lsl #21

	// write back to Function Select Register 5
	str		r1, [r0]


	// *** Initialize loop-invariant values ***

	// load the address of Set Register 1
	ldr		r4, =0x3F200020

	// load the address of Clear Register 1
	ldr		r5, =0x3F20002C

	// store 1 << 15 in r6
	mov		r6, #0x00008000


	// *** Blink ACT LED on and off infinitely ***

blinkLoop:
	// Set line 47 to turn ACT LED on (write 1 << 15 to Set Register 1)
	str		r6, [r4]
	
	// delay ~1sec
	mov		r0, #0x1C0000
	bl		delay

	// Clear line 47 to turn ACT LED off (write 1 << 15 to Clear Register 1)
	str		r6, [r5]

	// delay ~1sec
	mov		r0, #0x1C0000
	bl		delay

	// loop
	b		blinkLoop


    
haltLoop$:
	b		haltLoop$


/* Delay Function
 *	r0 - number of loop iterations
 * Returns: nothing
 */
delay:
	subs		r0, #1
	bne		delay
	bx		lr

.section .data


