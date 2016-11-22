// CPSC 359, lengthy printing function for use with A4 (Tetris)
// By: Nathan Escandor, Charlie Roy, and Patrick Sluth
// November 22, 2016

//Calling bl drawPaused from main.s prints a rich "Paused" for the paused menu
//##############################################################//

//##############################################################//
.section .text

.globl drawPaused
drawPaused:
    push    {lr}
    
    //Draw the "P"
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #150
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    mov     r0, #213
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #60
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    mov     r0, #243
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #60
    str     r0, [sp, #-4]!              //push width
    mov     r0, #214
    str     r0, [sp, #-4]!              //push y
    mov     r0, #243
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #184
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =273
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    
    //Draw the "A"
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #120
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #184
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =313
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #120
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #184
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =373
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =343
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #214
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =343
    str     r0, [sp, #-4]!              //push x
    bl      drawRect    
    
    //Draw the "U"
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #120
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =413
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #120
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =473
    str     r0, [sp, #-4]!              //push x
    bl      drawRect    
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =274
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =443
    str     r0, [sp, #-4]!              //push x
    bl      drawRect    
    
    //Draw the "S"
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #150
    str     r0, [sp, #-4]!              //push height
    mov     r0, #90
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =513
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x967F                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #60
    str     r0, [sp, #-4]!              //push width
    mov     r0, #244
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =513
    str     r0, [sp, #-4]!              //push x
    bl      drawRect       
    ldr     r0, =0x967F                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #60
    str     r0, [sp, #-4]!              //push width
    mov     r0, #184
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =543
    str     r0, [sp, #-4]!              //push x
    bl      drawRect  
    
    //Draw the "E"
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #150
    str     r0, [sp, #-4]!              //push height
    mov     r0, #90
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =613
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x967F                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #60
    str     r0, [sp, #-4]!              //push width
    mov     r0, #244
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =643
    str     r0, [sp, #-4]!              //push x
    bl      drawRect       
    ldr     r0, =0x967F                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #60
    str     r0, [sp, #-4]!              //push width
    mov     r0, #184
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =643
    str     r0, [sp, #-4]!              //push x
    bl      drawRect     
    
    //Draw the "D"
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #150
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =713
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #154
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =743
    str     r0, [sp, #-4]!              //push x
    bl      drawRect    
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =274
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =743
    str     r0, [sp, #-4]!              //push x
    bl      drawRect     
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #90
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #184
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =773
    str     r0, [sp, #-4]!              //push x
    bl      drawRect     

    pop     {pc}
    
.section .data
.end
