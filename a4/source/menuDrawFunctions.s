// CPSC 359, lengthy printing function for use with A4 (Tetris)
// By: Nathan Escandor, Charlie Roy, and Patrick Sluth
// November 22, 2016

/*
 *Functions Included:
 *---------------------------------
 *GLOBAL
 *------
 *drawPauseMenu
 *drawMainMenu
 *WriteSentence
 *setPauseMenuIndicatorRestart
 *setPauseMenuIndicatorQuit
 *setMainMenuIndicatorStart
 *setMainMenuIndicatorQuit
 *
 *drawVictoryScreen
 *drawLossScreen
 *
 *
 *LOCAL
 *------
 *drawMenuButton
 *drawPaused
 *drawTitle
 *DrawChar
 *
 *
 *
 *
 *
 *
 */





//##############################################################//

//##############################################################//
.section .text

/*
 *Draws the pause menu
 */
.globl drawPauseMenu
drawPauseMenu:
    push    {r4, lr}
    
    //Draw background
    ldr     r4, =0x967F                 //color
    ldr     r3, =500                    //height
    ldr     r2, =600                    //width
    mov     r1, #134                    //y
    mov     r0, #208                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    //Draw the border
    ldr     r4, =0x8000                 //color
    mov     r3, #4                      //height
    ldr     r2, =608                    //width
    mov     r1, #130                    //y
    mov     r0, #204                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x8000                 //color
    mov     r3, #4                      //height
    ldr     r2, =608                    //width
    ldr     r1, =634                    //y
    mov     r0, #204                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect  
    ldr     r4, =0x8000                 //color
    ldr     r3, =500                    //height
    mov     r2, #4                      //width
    mov     r1, #134                    //y
    mov     r0, #204                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x8000                 //color
    ldr     r3, =500                    //height
    mov     r2, #4                      //width
    mov     r1, #134                    //y
    ldr     r0, =808                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect 
 
    bl      drawPaused
 
    ldr     r0, =437                    //pass in x
    ldr     r1, =464                    //pass in y
    bl      drawMenuButton              //Draw the Resart Game button

    ldr     r0, =restartGameHeader      //load the StartGame button text
    mov     r1, #0x0                    //set the color
    ldr     r2, =483                    //load the x offset
    ldr     r3, =483                    //load the y offset
    bl      WriteSentence               //write the sentence

    ldr     r0, =437                    //pass in x
    ldr     r1, =545                    //pass in y
    bl      drawMenuButton              //draws the QuitGame button

    ldr     r0, =quitGameHeader         //load the QuitGame button text
    mov     r1, #0x0                    //set the color
    ldr     r2, =491                    //load the x offset
    ldr     r3, =564                    //load the y offset
    bl      WriteSentence               //write the sentence
    
    bl      setPauseMenuIndicatorRestart
    
    pop     {r4, pc}


/*
 *Draws the main menu in it's base state
 */
.globl  drawMainMenu
drawMainMenu:
    push    {r4, r9-r10, lr}

    // Get width/height
    ldr	 	r0, =FrameBufferInit
    ldr		r9, [r0, #20]
    ldr		r10, [r0, #24]

    //Screen Background
    ldr     r0, =0x967F                 //color
    str     r0, [sp, #-4]!              //push color
    str     r10, [sp, #-4]!             //push height
    str     r9, [sp, #-4]!              //push width
    mov     r0, #0
    str     r0, [sp, #-4]!              //push y
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //blue "T" tetimino
    ldr     r4, =0x297E                 //color
    mov     r3, #200                    //height
    ldr     r2, =600                    //width
    mov     r1, #84                     //y
    mov     r0, #212                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x297E                 //color
    mov     r3, #200                    //height
    mov     r2, #200                    //width
    ldr     r1, =284                    //y
    ldr     r0, =412                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    bl      drawTitle

    ldr     r0, =createdHeader          //load the created by header
    mov     r1, #0x0                    //set the color
    ldr     r2, =370                    //load the x offset
    mov     r3, #68                     //load the y offset
    bl      WriteSentence               //write the sentence

    ldr     r0, =437                    //pass in x
    ldr     r1, =564                    //pass in y
    bl      drawMenuButton              //Draw the StartGame button

    ldr     r0, =startGameHeader        //load the StartGame button text
    mov     r1, #0x0                    //set the color
    ldr     r2, =487                    //load the x offset
    ldr     r3, =583                    //load the y offset
    bl      WriteSentence               //write the sentence
    
    ldr     r0, =437                    //pass in x
    ldr     r1, =645                    //pass in y
    bl      drawMenuButton              //draws the QuitGame button

    ldr     r0, =quitGameHeader         //load the QuitGame button text
    mov     r1, #0x0                    //set the color
    ldr     r2, =491                    //load the x offset
    ldr     r3, =664                    //load the y offset
    bl      WriteSentence               //write the sentence

    bl      setMainMenuIndicatorStart   //draw the innitial location of the indicator    

    pop     {r4, r9-r10, pc}



.globl  WriteSentence
WriteSentence:
    push    {r4-r9, lr}         //saves these registers

    length  .req    r4
    address .req    r5
    color   .req    r6
    yAxis   .req    r7
    xAxis   .req    r8

    mov     address, r0         //moves the address to address
    ldr     length, [address]   //loads the length of the address
    add     address, #4         //moves the address pointer to the beginning of the ascii
    mov     color, r1           //stores the values in stable registers for safekeeping
    mov     xAxis, r2           //moves the x start to xAxis
    mov     yAxis, r3           //moves the y start to yAxis

LoadChar:
    ldrb    r0, [address], #1   //loads a byte from address and increments address 
    mov     r1, color           //loads the color
    mov     r2, yAxis           //loads y
    mov     r3, xAxis           //loads x
    bl      DrawChar            //Draws a char

    add     xAxis, #8           //moves x to location for next character
    sub     length, #1          //decreases length by 1
    cmp     length, #0          //checks if length = 0
    bgt     LoadChar            //if it isn't, load another character and repeat        

    .unreq  length
    .unreq  address
    .unreq  color
    .unreq  xAxis
    .unreq  yAxis

    pop     {r4-r9, pc}         //restores these registers
        
    
/*
 *Sets the pause menu indicator to restart
 */
.globl  setPauseMenuIndicatorRestart
setPauseMenuIndicatorRestart:
    push {r4, lr}

    //Clear the box for the Quit indicator
    ldr     r4, =0xFFFF                 //color
    mov     r3, #20                     //height
    mov     r2, #20                     //width
    ldr     r1, =560                    //y
    ldr     r0, =452                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    //Set the box for the restart indicator
    ldr     r4, =0x0                    //color
    mov     r3, #20                     //height
    mov     r2, #20                     //width
    ldr     r1, =479                    //y
    ldr     r0, =452                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    

    pop {r4, pc}


/*
 *Sets the pause indicator to quit
 */
.globl  setPauseMenuIndicatorQuit
setPauseMenuIndicatorQuit:
    push {r4, lr}

    //Clear the box for the restart indicator
    ldr     r4, =0xFFFF                 //color
    mov     r3, #20                     //height
    mov     r2, #20                     //width
    ldr     r1, =479                    //y
    ldr     r0, =452                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    //Set the box for the Quit indicator
    ldr     r4, =0x0                    //color
    mov     r3, #20                     //height
    mov     r2, #20                     //width
    ldr     r1, =560                    //y
    ldr     r0, =452                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    pop {r4, pc}
    
/*
 *Sets the main menu indicator to Start
 */
.globl  setMainMenuIndicatorStart
setMainMenuIndicatorStart:
    push {r4, lr}

    //Clear the box for the Quit indicator
    ldr     r4, =0xFFFF                 //color
    mov     r3, #20                     //height
    mov     r2, #20                     //width
    ldr     r1, =660                    //y
    ldr     r0, =452                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    //Set the box for the Start indicator
    ldr     r4, =0x0                    //color
    mov     r3, #20                     //height
    mov     r2, #20                     //width
    ldr     r1, =579                    //y
    ldr     r0, =452                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    pop {r4, pc}

/*
 *Sets the main menu indicator to Quit
 */
.globl  setMainMenuIndicatorQuit
setMainMenuIndicatorQuit:
    push {r4, lr}

    //Clear the box for the Start indicator
    ldr     r4, =0xFFFF                 //color
    mov     r3, #20                     //height
    mov     r2, #20                     //width
    ldr     r1, =579                    //y
    ldr     r0, =452                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    //Set the box for the Quit indicator
    ldr     r4, =0x0                    //color
    mov     r3, #20                     //height
    mov     r2, #20                     //width
    ldr     r1, =660                    //y
    ldr     r0, =452                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    pop {r4, pc}


/*
 *Draws a screen and appropriate message for when the player wins
 */
.globl  drawVictoryScreen
drawVictoryScreen:
    push    {r4, lr} 
    
    ldr     r4, =0x3707                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    mov     r0, #87                     //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect    
    ldr     r4, =0x3707                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    mov     r0, #147                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect 
    ldr     r4, =0x3707                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    ldr     r1, =260                    //y
    mov     r0, #117                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect 
 
    //Draws the "O"
    ldr     r4, =0x3707                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    mov     r0, #187                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    mov     r0, #247                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect 
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    mov     r0, #217                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect 
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =320                    //y
    mov     r0, #217                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect 
    
    //Draws the "U"
    ldr     r4, =0x3707                 //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =287                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect 
    ldr     r4, =0x3707                 //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =347                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect 
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =320                    //y
    ldr     r0, =317                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect 
    
    //Draws the "W"
    ldr     r4, =0x3707                 //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =487                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =547                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =607                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =320                    //y
    ldr     r0, =517                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =320                    //y
    ldr     r0, =577                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    //Draws the "I"
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    mov     r1, #200                    //y
    ldr     r0, =647                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    ldr     r1, =320                    //y
    ldr     r0, =647                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    ldr     r0, =677                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    //Draws the "N"
    ldr     r4, =0x3707                 //color
    mov     r3, #150                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =747                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    ldr     r0, =777                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =260                    //y
    ldr     r0, =807                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =290                    //y
    ldr     r0, =837                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #150                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =867                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    //Draws the "!"
    ldr     r4, =0x3707                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =907                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x3707                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =320                    //y
    ldr     r0, =907                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
           
    pop     {r4, pc}

/*
 *Draws a screen and appropriate message for then the player loses
 */
.globl  drawLossScreen
drawLossScreen:
    push    {r4, lr}
    
    
    
    //Draws the "Y"
    ldr     r4, =0xFF27                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    mov     r0, #117                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    mov     r0, #177                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    ldr     r1, =260                    //y
    mov     r0, #147                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect       
    
    //Draws the "O"
    ldr     r4, =0xFF27                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    mov     r0, #217                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    ldr     r0, =277                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    mov     r0, #247                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =320                    //y
    mov     r0, #247                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect

    //Draws the "U"
    ldr     r4, =0xFF27                 //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =317                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =377                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =320                    //y
    ldr     r0, =347                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    
    //Draws the "L"
    ldr     r4, =0xFF27                 //color
    mov     r3, #150                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =517                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                    //height
    mov     r2, #60                     //width
    ldr     r1, =320                    //y
    ldr     r0, =547                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    
    //Draws the "O"
    ldr     r4, =0xFF27                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    ldr     r0, =617                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    ldr     r0, =677                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =647                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =320                    //y
    ldr     r0, =647                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect

    
    //Draws the "S"
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    mov     r1, #200                    //y
    ldr     r0, =717                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #230                    //y
    ldr     r0, =717                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    ldr     r1, =260                    //y
    ldr     r0, =717                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =290                    //y
    ldr     r0, =777                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    ldr     r1, =320                    //y
    ldr     r0, =717                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    
    //Draws the "E"
    ldr     r4, =0xFF27                 //color
    mov     r3, #150                    //height
    mov     r2, #30                     //width
    mov     r1, #200                    //y
    ldr     r0, =817                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #60                     //width
    mov     r1, #200                    //y
    ldr     r0, =847                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #60                     //width
    ldr     r1, =260                    //y
    ldr     r0, =847                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0xFF27                 //color
    mov     r3, #30                     //height
    mov     r2, #60                     //width
    ldr     r1, =320                    //y
    ldr     r0, =847                    //x
    stmfd	sp!,{r0-r4}                 //push all
    bl      drawRect
    
    pop     {r4, pc}

/* 
 * Draws a button on a menu
 * r0 - x start
 * r1 - y start
 */
drawMenuButton:
    push    {r4, r9-r10, lr}

    x       .req    r9
    y       .req    r10

    mov     x, r0                       //moves x to secure register
    mov     y, r1                       //moves y to secure register

    ldr     r4, =0x0                    //color
    mov     r3, #50                     //height
    mov     r2, #150                    //width
    mov     r1, y                       //y
    mov     r0, x                       //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect         

    add     x, #5                       //increment x and y for next rectangle
    add     y, #5
    
    ldr     r4, =0xD7F                  //color
    mov     r3, #40                     //height
    mov     r2, #140                    //width
    mov     r1, y                       //y
    mov     r0, x                       //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    add     x, #5                       //Increment x and y for next rectangle
    add     y, #5
    
    ldr     r4, =0xFFFF                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, y                       //y
    mov     r0, x                       //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect    


    .unreq x
    .unreq y

    pop {r4, r9-r10, pc}





/*
 *Draws the rich text "Paused" title to the screen for the paused menu.
 */
.globl  drawPaused
drawPaused:
    push    {r4, lr}
    
    //Draw the "P"
    ldr     r4, =0x0                    //color
    mov     r3, #150                    //height
    mov     r2, #30                     //width
    mov     r1, #174                    //y
    mov     r0, #228                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #60                     //width
    mov     r1, #174                    //y
    ldr     r0, =258                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #60                     //width
    mov     r1, #234                    //y
    ldr     r0, =258                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #204                    //y
    ldr     r0, =288                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    //Draw the "A"
    ldr     r4, =0x0                    //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #204                    //y
    ldr     r0, =328                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #204                    //y
    ldr     r0, =388                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #174                    //y
    ldr     r0, =358                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #234                    //y
    ldr     r0, =358                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect  
    
    //Draw the "U"
    ldr     r4, =0x0                    //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #174                    //y
    ldr     r0, =428                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #174                    //y
    ldr     r0, =488                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =294                    //y
    ldr     r0, =458                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect      
    
    //Draw the "S"
    ldr     r4, =0x0                    //color
    mov     r3, #150                    //height
    mov     r2, #75                     //width
    mov     r1, #174                    //y
    ldr     r0, =528                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x967F                 //color
    mov     r3, #30                     //height
    mov     r2, #45                     //width
    ldr     r1, =264                    //y
    ldr     r0, =528                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x967F                 //color
    mov     r3, #30                     //height
    mov     r2, #45                     //width
    mov     r1, #204                    //y
    ldr     r0, =558                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
 
    
    //Draw the "E"
    ldr     r4, =0x0                    //color
    mov     r3, #150                    //height
    mov     r2, #75                     //width
    mov     r1, #174                    //y
    ldr     r0, =613                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x967F                 //color
    mov     r3, #30                     //height
    mov     r2, #45                     //width
    ldr     r1, =264                    //y
    ldr     r0, =643                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x967F                 //color
    mov     r3, #30                     //height
    mov     r2, #45                     //width
    mov     r1, #204                    //y
    ldr     r0, =643                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    
    //Draw the "D"
    ldr     r4, =0x0                    //color
    mov     r3, #150                    //height
    mov     r2, #30                     //width
    mov     r1, #174                    //y
    ldr     r0, =698                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #174                    //y
    ldr     r0, =728                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    ldr     r1, =294                    //y
    ldr     r0, =728                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #204                    //y
    ldr     r0, =758                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    pop     {r4, pc}
    
/*
 *Draws the title "Tetris" in rich text for the main menu.
 */
.globl  drawTitle
drawTitle:
    push {r4, lr}
    
    //Draw the "T"
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    mov     r1, #109                    //y
    mov     r0, #227                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #139                    //y
    ldr     r0, =257                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect

    
    //Draw the "E"
    ldr     r4, =0x0                    //color
    mov     r3, #150                    //height
    mov     r2, #75                     //width
    mov     r1, #109                    //y
    ldr     r0, =327                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x297E                 //color
    mov     r3, #30                     //height
    mov     r2, #45                     //width
    mov     r1, #139                    //y
    ldr     r0, =357                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x297E                    //color
    mov     r3, #30                     //height
    mov     r2, #45                     //width
    mov     r1, #199                    //y
    ldr     r0, =357                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
         
    
    //Draw the "T"
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    mov     r1, #109                    //y
    ldr     r0, =412                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #120                    //height
    mov     r2, #30                     //width
    mov     r1, #139                    //y
    ldr     r0, =442                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect


    //Draw the "R"
    ldr     r4, =0x0                    //color
    mov     r3, #90                     //height
    mov     r2, #90                     //width
    mov     r1, #109                    //y
    ldr     r0, =512                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x297E                 //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #139                    //y
    ldr     r0, =542                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #60                     //height
    mov     r2, #30                     //width
    mov     r1, #199                    //y
    ldr     r0, =512                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #199                    //y
    ldr     r0, =542                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #30                     //width
    mov     r1, #229                    //y
    ldr     r0, =572                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    
    //Draw the "I"
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    mov     r1, #109                    //y
    ldr     r0, =612                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #30                     //height
    mov     r2, #90                     //width
    mov     r1, #229                    //y
    ldr     r0, =612                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x0                    //color
    mov     r3, #90                     //height
    mov     r2, #30                     //width
    mov     r1, #139                    //y
    ldr     r0, =642                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    
    
    //Draw the "S"
    ldr     r4, =0x0                    //color
    mov     r3, #150                    //height
    mov     r2, #80                     //width
    mov     r1, #109                    //y
    ldr     r0, =712                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x297E                 //color
    mov     r3, #30                     //height
    mov     r2, #50                     //width
    mov     r1, #139                    //y
    ldr     r0, =742                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
    ldr     r4, =0x297E                 //color
    mov     r3, #30                     //height
    mov     r2, #50                     //width
    mov     r1, #199                    //y
    ldr     r0, =712                    //x
    stmfd   sp!,{r0-r4}                 //push all
    bl      drawRect
        
    pop {r4, pc}

/*Writes a single character to the screen
 *  r0  -   Ascii for character to be printed
 *  r1  -   The color to draw the character
 *  r2  -   The x axis starting point
 *  r3  -   The y axis starting point
 */
DrawChar:
	push	{r4-r9, lr}

	chAdr	.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask	.req	r8
    color   .req    r9

    mov     color,  r1
	ldr		chAdr,	=font		// load the address of the font map
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)
	mov		py,		r2			// init the Y coordinate (pixel coordinate)

charLoop$:
	mov		px,		r3   		// init the X coordinate
	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$
	mov		r0,		px
	mov		r1,		py
	mov		r2,		color		// red
	bl		drawPixel			// draw pixel at (px, py)

noPixel$:
	add		px,		#1			// increment x coordinate by 1
	lsl		mask,	#1			// shift bitmask left by 1
	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$
	add		py,		#1			// increment y coordinate by 1
	tst		chAdr,	#0xF
	bne		charLoop$			// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask
    .unreq  color

	pop		{r4-r9, pc}





.section .data

.align 4
font:		.incbin	"font.bin"

.align 4
createdHeader:
    .int    55
    .ascii  "Created by: Nathan Escandor, Charlie Roy, and Pat Sluth" //Length 55
    
.align 4
startGameHeader:
    .int    10
    .ascii  "Start Game"

.align 4
quitGameHeader:
    .int    9
    .ascii  "Quit Game"

.align 4
restartGameHeader:
    .int    12
    .ascii  "Restart Game" //Length 12


.end
