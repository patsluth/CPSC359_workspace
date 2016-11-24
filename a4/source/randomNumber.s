// CPSC 359, random number generator for use with A4 (Tetris)
// By: Nathan Escandor, Charlie Roy, and Patrick Sluth
// November 23, 2016
// Sources:
// https://en.wikipedia.org/wiki/Xorshift
// Marsaglia, G. (2003). Xorshift RNGs. Journal of Statistical Software J. Stat. Soft., 8(14). doi:10.18637/jss.v008.i14 
// http://sciencezero.4hv.org/science/lfsr.htm


//Calling bl randomNumber from main.s returns a random value from 0-6 in r0
//##############################################################//

//##############################################################//
.section .text

.globl randomNumber
randomNumber:
    push    {r4-r7, lr}

    w       .req    r2
    x       .req    r4
    y       .req    r5
    z       .req    r6
    t       .req    r7
    
    ldr     r1, =0x3F003004
    ldr     x, [r1]
    ldr     y, [r1]
    ldr     z, [r1]
    ldr     w, [r1]

top:
    
    mov     t, x
    eor     t, t, lsl #11
    eor     t, t, lsr #8
    mov     x, y
    mov     y, z
    mov     z, w
    eor     w, w, lsr #19
    eor     w, t
    
    mvn    r1, #7
    bic    r0, r2, r1
    
    cmp    r0, #7
    beq    top 

    .unreq  w
    .unreq  x
    .unreq  y
    .unreq  z
    .unreq  t
    
    pop     {r4-r7, pc}
