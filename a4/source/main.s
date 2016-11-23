// CPSC 359, Assignment 4
// By: Nathan Escandor, Charlie Roy, and Patrick Sluth
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


	 bl		clearScreen
	b	StartGame









/*  To-do Charlie:
 *  CPU could not be halted error
 *
 */
MainMenu:                                       
    bl      ClearScreenBlack                    //Clears the screen
    bl      DrawMainMenu                        //draws the base menu
    
    PointerAt   .req    r9                      //r8 holds which button is hovered
    Sample      .req    r10
    
    mov PointerAt, #0                           //initialize to 0, ie Start
MainMenuPrompt:
    bl      sampleSNES                          //check what buttons are pressed
                                                //returned in r0
    mov     sample, r0                          //stores the sample in secure register sample
    
    mvn     r1, #0x100                          //moves 1 to every bit except bit 8
    bic     r0, r1                              //clears every bit of r0 except 8
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     MainMenuAPressed                            //if equal, then A was pressed, so branch
                                                //else fall through
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x10                           //moves 1 to every bit except bit 4
    bic     r0, r1                              //clears every bit except bit 4
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     MainMenuUpPressed                           //if equal, then Up was pressed, so branch
                                                //else fall through
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x20                           //moves 1 to every bit except bit 5
    bic     r0, r1                              //clears every bit except bit 5
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     MainMenuDownPressed                         //if equal, then Down was pressed, so branch
                                                //else fall through
                                                //might need to include some delay here
    ldr     r0, =0x10000
    bl      startTimer    
    b       MainMenuPrompt
    
//if A == pressed
MainMenuAPressed:
    cmp     PointerAt, #0                           //Checks if r9 points to start
    beq     StartGame                               //if it does, start game
    bl      ClearScreenBlack                         //if not, clear screen
    b       mainEnd                                   //then hang

//if up == pressed
MainMenuUpPressed:
    cmp PointerAt, #0                           //see if r9 already point to top element
    beq MainMenuPrompt                          //if so do nothing and re-prompt
    mov PointerAt, #0                           //else make r9 point to start
    bl  SetMainMenuIndicatorStart               //and re draw indicator
    b   MainMenuPrompt                          //And re prompt for input

//if down == pressed
MainMenuDownPressed:
    cmp PointerAt, #1                           //see if r9 already points to the bottom element
    beq MainMenuPrompt                          //if so do nothing and re-prompt
    mov PointerAt, #1                           //else make r9 point to quit
    bl  SetMainMenuIndicatorQuit                //and re draw indicator
    b   MainMenuPrompt                          //and re prompt for input

    .unreq  PointerAt
    .unreq  Sample

StartGame:














  //TODO: Nathan - figure out the warning
  //      "register range not in ascending order"

  //Use this branch to sample from SNES controller.
  //Button bitmask will be returned to r0 in form:
  //  B button pressed (button 1)
  //  r0 = 0xfffe = 1111 1111 1111 1110

  bl    sampleSNES
		
	bl tetrisInitGrid


    bl      DrawBoard
    
    //bl      PauseMenuStart
    
    
	bl	tetrisCreateNewBlock

	mainLoop:
	
		//        ldr     r0, =scoreNumber
		//        ldr     r10, [r0]
		//        add     r10, #1
		//        str     r10, [r0]
		//        bl      UpdateScore
		
		bl	tetrisDrawGrid
		bl	tetrisDrawBlock
		
		applyUserTranslation:
		
			// tetrisTranslateBlock(int dx, int dy)
			mov		r0, #1
			mov		r1, #0
			bl		tetrisTranslateBlock
			
		applyGravityTranslation:
		
			// tetrisTranslateBlock(int dx, int dy)
			mov		r0, #0
			mov		r1, #1
			bl		tetrisTranslateBlock
		
		applyUserRotation:
		
			// tetrisRotateBlock(right)
			mov	r0, #0
			bl	tetrisRotateBlock
		
		
		ldr	r0, =0xFFFFF
		bl 	startTimer
		
		b	mainLoop


mainEnd:
	b	mainEnd


/*
 *Branch here when the start button is pressed to pause
 *Creates the pause menu
 */
PauseMenuStart:
    push    {lr}
    
    bl      DrawPauseMenu                       //draws the pause menu
    
    PointerAt   .req    r9                      //r8 holds which button is hovered
    Sample      .req    r10
    
    mov PointerAt, #0                           //initialize to 0, ie restart
PauseMenuPrompt:
    bl      sampleSNES                          //check what buttons are pressed
                                                //returned in r0
    mov     sample, r0                          //stores the sample in secure register sample
    
    mvn     r1, #0x8                            //moves 1 into every bit except bit 3
    bic     r0, r1                              //clear every bit of r0 except 3
    cmp     r0, #0                              //compares masked sample with 0
    beq     PauseMenuStartPressed               //if equal, Start was pressed, so branch
                                                //else fall through    
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x100                          //moves 1 to every bit except bit 8
    bic     r0, r1                              //clears every bit of r0 except 8
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     PauseMenuAPressed                   //if equal, then A was pressed, so branch
                                                //else fall through
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x10                           //moves 1 to every bit except bit 4
    bic     r0, r1                              //clears every bit except bit 4
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     PauseMenuUpPressed                  //if equal, then Up was pressed, so branch
                                                //else fall through
    mov     r0, sample                          //move sample to r0
    mvn     r1, #0x20                           //moves 1 to every bit except bit 5
    bic     r0, r1                              //clears every bit except bit 5
    cmp     r0, #0                              //compares masked sample (r0) to 0
    beq     PauseMenuDownPressed                //if equal, then Down was pressed, so branch
                                                //else fall through
                                                //might need to include some delay here
    ldr     r0, =10000
    bl      startTimer
    b       PauseMenuPrompt
    
//if Start == pressed
PauseMenuStartPressed:
    bl      DrawBoard                           //redraw the board
    pop     {pc}
//if A == pressed
PauseMenuAPressed:
    cmp     PointerAt, #0                       //Checks if r9 points to restart
    mov     r1, #0                              //resets the score to 0
    ldr     r0, =scoreNumber
    str     r1, [r0]
    beq     StartGame                               //if it does, start game
    b       MainMenu                                  //else quit was hovered so go to main menu

//if up == pressed
PauseMenuUpPressed:
    cmp     PointerAt, #0                           //see if r9 already point to top element
    beq     PauseMenuPrompt                          //if so do nothing and re-prompt
    mov     PointerAt, #0                           //else make r9 point to restart
    bl      SetPauseMenuIndicatorRestart               //and re draw indicator
    b       PauseMenuPrompt                          //And re prompt for input

//if down == pressed
PauseMenuDownPressed:
    cmp     PointerAt, #1                           //see if r9 already points to the bottom element
    beq     PauseMenuPrompt                          //if so do nothing and re-prompt
    mov     PointerAt, #1                           //else make r9 point to quit
    bl      SetPauseMenuIndicatorQuit                //and re draw indicator
    b       PauseMenuPrompt                          //and re prompt for input


    .unreq  PointerAt
    .unreq  Sample
    
    pop     {pc}
    
/*
 *Draws the pause menu
 */    
DrawPauseMenu:
    push    {lr}
    
    ldr     r0, =0x967F                 //color
    str     r0, [sp, #-4]!              //push color
    ldr     r0, =500
    str     r0, [sp, #-4]!              //push height
    ldr     r0, =600
    str     r0, [sp, #-4]!              //push width
    mov     r0, #134
    str     r0, [sp, #-4]!              //push y
    mov     r0, #208
    str     r0, [sp, #-4]!              //push x
    bl      drawRect    

    ldr     r0, =0x8000                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #4
    str     r0, [sp, #-4]!              //push height
    ldr     r0, =608
    str     r0, [sp, #-4]!              //push width
    mov     r0, #130
    str     r0, [sp, #-4]!              //push y
    mov     r0, #204
    str     r0, [sp, #-4]!              //push x
    bl      drawRect   
    
    ldr     r0, =0x8000                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #4
    str     r0, [sp, #-4]!              //push height
    ldr     r0, =608
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =634
    str     r0, [sp, #-4]!              //push y
    mov     r0, #204
    str     r0, [sp, #-4]!              //push x
    bl      drawRect 
    
    ldr     r0, =0x8000                 //color
    str     r0, [sp, #-4]!              //push color
    ldr     r0, =500
    str     r0, [sp, #-4]!              //push height
    mov     r0, #4
    str     r0, [sp, #-4]!              //push width
    mov     r0, #134
    str     r0, [sp, #-4]!              //push y
    mov     r0, #204
    str     r0, [sp, #-4]!              //push x
    bl      drawRect 
    
    ldr     r0, =0x8000                 //color
    str     r0, [sp, #-4]!              //push color
    ldr     r0, =500
    str     r0, [sp, #-4]!              //push height
    mov     r0, #4
    str     r0, [sp, #-4]!              //push width
    mov     r0, #134
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =808
    str     r0, [sp, #-4]!              //push x
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
    
    bl      SetPauseMenuIndicatorRestart
    
    pop     {pc}

/*
 *Sets the pause menu indicator to restart
 */
SetPauseMenuIndicatorRestart:
    push {lr}

    //Clear the box for the Quit indicator
    ldr     r0, =0xFFFF                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =560
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //Set the box for the restart indicator
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =479
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    pop {pc}

/*
 *Sets the pause indicator to quit
 */
SetPauseMenuIndicatorQuit:
    push {lr}

    //Clear the box for the restart indicator
    ldr     r0, =0xFFFF                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =479
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //Set the box for the Quit indicator
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =560
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    pop {pc}
    
/*
 *Draws the gameboard peripherals
 *
 */    
DrawBoard:

    push    {lr}
    
    bl      ClearScreenBlack
    
    ldr     r0, =0xE000                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #4
    str     r0, [sp, #-4]!              //push height
    ldr     r0, =648
    str     r0, [sp, #-4]!              //push width
    mov     r0, #76
    str     r0, [sp, #-4]!              //push y
    mov     r0, #188
    str     r0, [sp, #-4]!              //push x
    bl      drawRect    
    
    ldr     r0, =0xE000                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #4
    str     r0, [sp, #-4]!              //push height
    ldr     r0, =648
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =688
    str     r0, [sp, #-4]!              //push y
    mov     r0, #188
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    ldr     r0, =0xE000                 //color
    str     r0, [sp, #-4]!              //push color
    ldr     r0, =608
    str     r0, [sp, #-4]!              //push height
    mov     r0, #4
    str     r0, [sp, #-4]!              //push width
    mov     r0, #80
    str     r0, [sp, #-4]!              //push y
    mov     r0, #188
    str     r0, [sp, #-4]!              //push x
    bl      drawRect  
    
    ldr     r0, =0xE000                 //color
    str     r0, [sp, #-4]!              //push color
    ldr     r0, =608
    str     r0, [sp, #-4]!              //push height
    mov     r0, #4
    str     r0, [sp, #-4]!              //push width
    mov     r0, #80
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =512
    str     r0, [sp, #-4]!              //push x
    bl      drawRect  
    
    ldr     r0, =0xE000                 //color
    str     r0, [sp, #-4]!              //push color
    ldr     r0, =608
    str     r0, [sp, #-4]!              //push height
    mov     r0, #4
    str     r0, [sp, #-4]!              //push width
    mov     r0, #80
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =832
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    
    ldr     r0, =scoreHeader            //load the score header
    ldr     r1, =0x34A0                 //set the color
    ldr     r2, =617                    //load the x offset
    mov     r3, #230                    //load the y offset
    bl      WriteSentence               //write the sentence
    
    ldr     r0, =0x34A0                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #54
    str     r0, [sp, #-4]!              //push height
    mov     r0, #54
    str     r0, [sp, #-4]!              //push width
    mov     r0, #211
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =663
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    
    ldr     r0, =0xADB5                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #50
    str     r0, [sp, #-4]!              //push height
    mov     r0, #50
    str     r0, [sp, #-4]!              //push width
    mov     r0, #213
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =665
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    
    ldr     r0, =QueueHeader            //load the queue header
    ldr     r1, =0x618                  //load the color
    ldr     r2, =574                    //load the x offset
    ldr     r3, =586                    //load the y offset
    bl      WriteSentence               //write the sentence
    
    ldr     r0, =0x618                  //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #136
    str     r0, [sp, #-4]!              //push height
    mov     r0, #136
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =528
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =644
    str     r0, [sp, #-4]!              //push x
    bl      drawRect    
    
    
    ldr     r0, =0xADB5                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #132
    str     r0, [sp, #-4]!              //push height
    mov     r0, #132
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =530
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =646
    str     r0, [sp, #-4]!              //push x
    bl      drawRect    
    
    bl      UpdateScore
    
    pop {pc}


/*
 *Updates the printed value for the score
 *
 */
UpdateScore:
    push {lr}
    //clears the score board
    ldr     r0, =0xADB5                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #24
    str     r0, [sp, #-4]!              //push width
    mov     r0, #228
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =678
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    
    //prints the int stored in the score section
    ldr     r0, =scoreNumber            //loads the address of scoreNumber
    ldr     r1, [r0]                    //loads the int stored there
    cmp     r1, #99                     //compares it with 99
    bgt     threeDigitScore             //if it's greater, the score is 3 digits, so branch
    cmp     r1, #9                      //compares it with 9
    bgt     twoDigitScore               //if its greater, the score is 2 digits, so branch
                                        //else fall through
oneDigitScore:                          //the score must be 1 digit at this point
    ldr     r0, =scoreText              //load the address of score text
    add     r1, #48                     //convert the score to an ascii value    
    strb     r1, [r0, #6]               //store the value at the new offset
    b       PrintScore                  //print it out
    
twoDigitScore:
    ldr     r0, =scoreText              //loads the address of score text
    mov     r2, #0                      //initializes r2 to 0
twoDigitScoreLoop:
    cmp     r1, #10                      //compares the score to 10
    blt     twoDigitScoreLoopDone       //if r1 <10, the loop is over
    sub     r1, #10                     //subtracts 10 from r1
    add     r2, #1                      //increases the counter by 1
    b       twoDigitScoreLoop           //else fall through and repeat
twoDigitScoreLoopDone:
    add     r1, #48                     //converting the values to ascii
    add     r2, #48                     
    strb    r2, [r0, #5]                //stores the 10's value at the right location
    strb    r1, [r0, #6]                //stores the 1's value at the right location
     
    b       PrintScore                  //print the score out    
    
threeDigitScore:                        //game ends at 150 score so there is a 1 in 100's index
    sub     r1, #100                    //subtract 100 from the score
    ldr     r0, =scoreText              //loads the address of the score text
    mov     r2, #49                      //initialize r2 to ascii 1 so it can be stored
    strb    r2, [r0, #4]                //store the 1 at the 100's index
    b       twoDigitScore               //now treat remaining score as 2 digits

PrintScore:
    ldr     r0, =scoreText              //load the queue header    
    mov     r1, #0                      //load the color
    ldr     r2, =678                    //load the x offset
    mov     r3, #230                     //load the y offset
    bl      WriteSentence               //write the sentence
    
    pop {pc}

/*
 *Draws the Title
 */
DrawTitle:
    push {lr}
    
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #100
    str     r0, [sp, #-4]!              //push width
    mov     r0, #94
    str     r0, [sp, #-4]!   
	//	-1--           //push y
    mov     r0, #222
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #150
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, #124
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =257
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    pop {pc}
    
/*
 *Sets the main menu indicator to Start
 */
SetMainMenuIndicatorStart:
    push {lr}

    //Clear the box for the Quit indicator
    ldr     r0, =0xFFFF                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =660
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //Set the box for the Start indicator
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =579
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    pop {pc}

/*
 *Sets the main menu indicator to Quit
 */
SetMainMenuIndicatorQuit:
    push {lr}

    //Clear the box for the Start indicator
    ldr     r0, =0xFFFF                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =579
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!   
	//	-1--           //push x
    bl      drawRect

    //Set the box for the Quit indicator
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #20
    str     r0, [sp, #-4]!              //push height
    mov     r0, #20
    str     r0, [sp, #-4]!              //push width
    ldr     r0, =660
    str     r0, [sp, #-4]!              //push y
    ldr     r0, =452
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    pop {pc}
    
/*
 *Sets the entire screen to black
 */
ClearScreenBlack:
    push {r9-r10, lr}

    // Get width/height
    ldr	 	r0, =FrameBufferInit
    ldr		r9, [r0, #20]
    ldr		r10, [r0, #24]

    //Clear screen
    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    str     r10, [sp, #-4]!             //push height
    str     r9, [sp, #-4]!              //push width
    mov     r0, #0
    str     r0, [sp, #-4]!              //push y
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    pop     {r9-r10, pc}

/*
 *Draws the main menu in it's base state
 */
DrawMainMenu:
    push {r9-r10, lr}

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

    //blue rectangle
    ldr     r0, =0x297E                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #200
    str     r0, [sp, #-4]!              //push height
    mov     r0, #600
    str     r0, [sp, #-4]!              //push width
    mov     r0, #84
    str     r0, [sp, #-4]!              //push y
    mov     r0, #212
    str     r0, [sp, #-4]!              //push x
    bl      drawRect
    //blue rectangle 2
    ldr     r0, =0x297E                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #200
	//	-1--
    str     r0, [sp, #-4]!              //push height
    mov     r0, #200
    str     r0, [sp, #-4]!              //push width
    mov     r0, #284
    str     r0, [sp, #-4]!              //push y
    mov     r0, #412
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    //DrawTitle
    bl      DrawTitle

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

    bl      SetMainMenuIndicatorStart   //draw the innitial location of the indicator    

    pop     {r9-r10, pc}

/* 
 * Draws a button on the start menu
 * r0 - x start
 * r1 - y start
 */
drawMenuButton:
    push    {r9-r10, lr}

    x       .req    r9
    y       .req    r10

    mov     x, r0                       //moves x to secure register
    mov     y, r1                       //moves y to secure register

    ldr     r0, =0x0                    //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #50
    str     r0, [sp, #-4]!              //push height
    mov     r0, #150
    str     r0, [sp, #-4]!              //push width
    mov     r0, y
    str     r0, [sp, #-4]!              //push y
    mov     r0, x
    str     r0, [sp, #-4]!              //push x
    bl      drawRect                    

    add     x, #5                       //increment x and y for next rectangle
    add     y, #5

    ldr     r0, =0xD7F                  //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #40
    str     r0, [sp, #-4]!              //push height
    mov     r0, #140
    str     r0, [sp, #-4]!              //push width
    mov     r0, y
    str     r0, [sp, #-4]!              //push y
    mov     r0, x
    str     r0, [sp, #-4]!     
	//	-1--         //push x
    bl      drawRect

    add     x, #5                       //Increment x and y for next rectangle
    add     y, #5

    ldr     r0, =0xFFFF                 //color
    str     r0, [sp, #-4]!              //push color
    mov     r0, #30
    str     r0, [sp, #-4]!              //push height
    mov     r0, #30
    str     r0, [sp, #-4]!              //push width
    mov     r0, y
    str     r0, [sp, #-4]!              //push y
    mov     r0, x
    str     r0, [sp, #-4]!              //push x
    bl      drawRect

    .unreq x
    .unreq y

    pop {r9-r10, pc}

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

	//	-1--
charLoop$:
	mov		px,		r3   		// init the X coordinate
	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$
	mov		r0,		px
	mov		r1,		py
	//	-1--
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
	
	
	
	
	
// INPUT
//
// OUTPUT
//
tetrisInitGrid:

	tetrisGrid			.req r0
	tetrisGridData		.req r1
	tetrisGridEnd		.req r2
	emptyBlockColor		.req r3
	
	ldr 	tetrisGrid, 			=TetrisGrid
	add 	tetrisGridData, 		tetrisGrid, #12
	ldr 	tetrisGridEnd, 			=TetrisGridEnd
	
	ldr		emptyBlockColor,		=0x000000	// black

	forEach_block_in_tetrisGrid_loop:
	
		str		emptyBlockColor, [tetrisGridData, #0]
		add 	tetrisGridData, #4
		
		cmp		tetrisGridData, tetrisGridEnd
		bge		forEach_block_in_tetrisGrid_loopEnd
		blt		forEach_block_in_tetrisGrid_loop
		
	forEach_block_in_tetrisGrid_loopEnd:
	
	.unreq 	tetrisGrid
	.unreq 	tetrisGridData
	.unreq 	tetrisGridEnd
	.unreq	emptyBlockColor

	mov 	pc, lr            // return
		
		
		
		
		
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
// 		2 = color
//		--------
// OUTPUT
//
tetrisSetGridBlockColor:

	x					.req r0
	y					.req r1
	blockColor			.req r2
	tetrisGrid			.req r3
	tetrisGridCols		.req r4
	tetrisGridRows		.req r5
	tetrisGridBlockSize	.req r6
	tetrisGridData		.req r7
	tetrisGridOffset	.req r8
	
	pop		{ x - blockColor }
	push 	{ lr }
	push	{ tetrisGridCols - tetrisGridOffset }
	
	ldr 	tetrisGrid, 			=TetrisGrid
	ldmfd	tetrisGrid,				{ tetrisGridCols - tetrisGridBlockSize }
	add 	tetrisGridData, 		tetrisGrid, #12
	
	push	{ blockColor }

	// int tetrisGridOffset = positionToArrayOffset(int x, int y, int cols)
	stmfd	sp!, 	{ x, y, tetrisGridCols }
	bl 		positionToArrayOffset
	pop 	{ tetrisGridOffset }
	lsl		tetrisGridOffset, #2
	
	pop	{ blockColor }

	// write color to tetrisGridData
	str		blockColor, 		[tetrisGridData, tetrisGridOffset]
	
	pop		{ tetrisGridCols - tetrisGridOffset }
	pop 	{ lr }
	
	.unreq	x
	.unreq	y
	.unreq 	blockColor
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	.unreq	tetrisGridOffset

	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = blockColor
//		--------
//
tetrisGetGridBlockColor:

	x					.req r1
	y					.req r2
	tetrisGrid			.req r3
	tetrisGridCols		.req r4
	tetrisGridRows		.req r5
	tetrisGridBlockSize	.req r6
	tetrisGridData		.req r7
	tetrisGridOffset	.req r8
	blockColor			.req r9
	
	pop		{ x - y }
	push 	{ lr }
	push	{ tetrisGridCols - blockColor }
	
	ldr 	tetrisGrid, 			=TetrisGrid
	ldmfd	tetrisGrid,				{ tetrisGridCols - tetrisGridBlockSize }
	add 	tetrisGridData, 		tetrisGrid, #12
	
	// default value, so we can use the grid bitmask to check for grid bounds
	ldr		blockColor, 		=0xFFFFFF
		
	//********************************
	//*****check for valid input******
	//********************************
	cmp		x, #0
	blt		tetrisGetGridBlockColorEnd
	cmp		x, tetrisGridCols
	bge		tetrisGetGridBlockColorEnd
	//********************************
	cmp		y, #0
	blt		tetrisGetGridBlockColorEnd
	cmp		y, tetrisGridRows
	bge		tetrisGetGridBlockColorEnd
	//********************************
	
	tetrisGetGridBlockColor_validInput:

		// int tetrisGridOffset = positionToArrayOffset(int x, int y, int cols)
		stmfd	sp!, 	{ x, y, tetrisGridCols }
		bl 		positionToArrayOffset
		pop 	{ tetrisGridOffset }
		lsl		tetrisGridOffset, #2
			
		ldr		blockColor, 		[tetrisGridData, tetrisGridOffset]
	
tetrisGetGridBlockColorEnd:
	
	mov		r0, blockColor
	pop		{ tetrisGridCols - blockColor }
	pop 	{ lr }
	push	{ r0 }
	
	.unreq	x
	.unreq	y
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	.unreq	tetrisGridOffset
	.unreq 	blockColor

	mov 	pc, lr				// return





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
	ldr 	color, 	=0x000000
	stmfd	sp!,	{ x - color }
	bl 		tetrisSetGridBlockColor

	.unreq	x
	.unreq	y
	.unreq 	color

	pop 	{ lr }

	mov 	pc, lr				// return





// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = bitmask
//		--------
//
tetrisGetGridBitmaskForBlock:

	bitmask				.req r0
	blockGridData		.req r3
	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	mov		r0, sp
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r0, { blockX - blockTypeOffset }

	i	.req r11
	j	.req r12
	
	push	{ i - j }

	mov		bitmask, #0
	mov		i, #0
	mov 	j, #0

	tetrisGetGridBitmaskForBlock_for_i_lessThan_4_loop:

		push 	{ j }

		tetrisGetGridBitmaskForBlock_for_j_lessThan_4_loop:

			push 	{ blockX - blockY }

			add 	blockX, i
			add 	blockY, j
			
			push	{ bitmask, i - j }
			
			// tetrisGetGridBlockColor(int x, int y)
			push	{ blockX - blockY }
			bl 		tetrisGetGridBlockColor
			pop		{ r3 }
			pop		{ bitmask, i - j }
			teq		r3, #0
			
			beq		poop
			
				mov	r1, #4
				mul	r1, j, r1
				add	r1, i
				ldr	r2, =0b1000000000000000
				lsr	r2, r1
				orr	bitmask, bitmask, r2
			
			poop:

			pop 	{ blockX - blockY }

			add 	j, #1
			cmp 	j, #4
			blt 	tetrisGetGridBitmaskForBlock_for_j_lessThan_4_loop

		pop 	{ j }
		add 	i, #1
		cmp 	i, #4
		blt 	tetrisGetGridBitmaskForBlock_for_i_lessThan_4_loop
	
	pop		{ i - j }
		
	.unreq	i
	.unreq 	j

	pop		{ blockX - blockTypeOffset }
	pop 	{ lr }
	push	{ bitmask }

	.unreq	bitmask
	.unreq	blockGridData
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	mov 	pc, lr				// return





// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//	
tetrisDrawGrid:

	curCol				.req r4
	curRow				.req r5
	curColor			.req r6
	tetrisGrid			.req r7
	tetrisGridCols		.req r8
	tetrisGridRows		.req r9
	tetrisGridBlockSize	.req r10
	tetrisGridData		.req r11
	tetrisGridOffset	.req r12
	
	mov		r0, sp

	push	{ lr }  
	push	{ curCol - tetrisGridOffset }
	
	ldr 	tetrisGrid, 	=TetrisGrid
	ldmfd	tetrisGrid, 	{ tetrisGridCols - tetrisGridBlockSize }
	add 	tetrisGridData, tetrisGrid, #12
	
	mov		r7, r0
	
	mov		curCol, 		#0
	mov		curRow, 		#0
	mov		curColor, 		#0

	for_curCol_lessThan_cols_loop:

		push 	{ curRow }

		for_curRow_lessThan_rows_loop:

			push 	{ curCol - tetrisGridOffset }
			
			
			
			
			
			
			nop
			nop
			ldmfd	r7, 	{ r6 - r12 }
			stmfd	sp!,	{ r6 - r12 }
			
			mov		r0, curCol
			mov		r1, curRow
			bl tetrisBlockBitForGridPoint
			
			mov		r0, curCol
			mov		r1, curRow
			bl	tetrisBlockContainsPoint
			ldmfd	sp!, 	{ r6 - r12 }
			
			pop 	{ curCol - tetrisGridOffset }
			push 	{ curCol - tetrisGridOffset }
			
			
			// IF r0 != 0, then this point is in the current block
			teq		r0, #0
			//bne		skippy
			

			// drawRect(int x, int y, int width, int height, int color)
			
			// int offset = positionToArrayOffset(int x, int y, int cols)
			stmfd	sp!, 	{ curCol, curRow, tetrisGridCols }
			bl 		positionToArrayOffset
			pop 	{ tetrisGridOffset }
			lsl		tetrisGridOffset, #2
		
			ldr		curColor, 				[tetrisGridData, tetrisGridOffset]

			nop











			x		.req r0
			y		.req r1
			width	.req r2
			height	.req r3
		
			push	{ x - height }
			
		
			// tetrisGetRectForGridPosition(int x, int y)
			stmfd	sp!, 	{ curCol, curRow }
			bl 		tetrisGetRectForGridPosition
			ldmfd	sp!, 	{ x - height  }
			
			nop
			
			// drawRect(int x, int y, int width, int height, int color)

			// push paramaters to stack
			add x, #192
			add y, #80
			stmfd	sp!,	{ x - height, curColor }
			
			

			bl		drawRect
			
			pop		{ x - height }
			
			.unreq	x
			.unreq	y
			.unreq	width
			.unreq	height
			
			
			
			
			

			skippy:

			pop 	{ curCol - tetrisGridOffset }

			add 	curRow, #1
			cmp 	curRow, tetrisGridRows
			blt 	for_curRow_lessThan_rows_loop

		pop 	{ curRow }
		add 	curCol, #1
		cmp 	curCol, tetrisGridCols
		blt 	for_curCol_lessThan_cols_loop

	pop	{ curCol - tetrisGridOffset }
	
	.unreq 	curCol
	.unreq 	curRow
	.unreq 	curColor
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	.unreq	tetrisGridData
	.unreq	tetrisGridOffset

	pop 	{ lr }
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = x
// 		1 = y
// 		2 = width
// 		3 = height
//		--------
//
tetrisGetRectForGridPosition:

	x					.req r0
	y					.req r1
	width				.req r2
	height				.req r3
	tetrisGrid			.req r4
	tetrisGridCols		.req r5
	tetrisGridRows		.req r6
	tetrisGridBlockSize	.req r7

	ldmfd	sp!, 		{ x, y }
	push	{ tetrisGrid - tetrisGridBlockSize }
	
	ldr 	tetrisGrid, 	=TetrisGrid
	ldmfd	tetrisGrid, 	{ tetrisGridCols - tetrisGridBlockSize }
	
	// calulate return values
	mov		width,	tetrisGridBlockSize
	mov		height,	tetrisGridBlockSize
	mul		x, width
	mul		y, height
	
	pop		{ tetrisGrid - tetrisGridBlockSize }
	
	stmfd	sp!, 		{ x, y, width, height }
	
	.unreq 	x
	.unreq 	y
	.unreq	width
	.unreq	height
	.unreq	tetrisGrid
	.unreq	tetrisGridCols
	.unreq	tetrisGridRows
	.unreq	tetrisGridBlockSize
	
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		1 = blockX
// 		2 = blockY
// 		3 = blockColor
// 		4 = blockTypeAddress
// 		5 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisDrawBlock:

	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	mov		r0, sp
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r0, 		{ blockX - blockTypeOffset }

	i	.req r11
	j	.req r12
	
	push	{ i - j }

	mov		i, #0
	mov 	j, #0

	for_i_lessThan_4_loop:

		push 	{ j }

		for_j_lessThan_4_loop:

			push 	{ blockX - blockColor }

			blockBitForXY	.req r1
			blockGridData	.req r2
	
			ldrh	blockGridData, [blockTypeAddress, blockTypeOffset]

			add 	blockX, i
			add 	blockY, j

			// calculate bit corresponding to block position
			mov		blockBitForXY, 	#4
			mul		blockBitForXY, 	blockBitForXY, j
			add		blockBitForXY, 	i
			lsl		blockGridData, 	blockBitForXY
			mov		blockBitForXY, 	#0b1000000000000000
			and		blockBitForXY, 	blockGridData
			teq		blockBitForXY,	#0
			
			push	{ blockColor }
			moveq	blockColor, #0//black
			beq		blockHasNoData
			
			// if (blockBitForXY != 0)
			blockHasData:
			
				x		.req r0
				y		.req r1
				width	.req r2
				height	.req r3
			
				push	{ x - height }
				
				nop
			
				// tetrisGetRectForGridPosition(int x, int y)
				stmfd	sp!, 	{ blockX, blockY  }
				bl 		tetrisGetRectForGridPosition
				ldmfd	sp!, 	{ x - height  }
				
				nop
				
				// drawRect(int x, int y, int width, int height, int color)

				// push paramaters to stack
				// TODO: draws faster when commented out?
				add x, #192
				add y, #80
				stmfd	sp!,	{ x - height, blockColor }
				bl		drawRect
				
				pop		{ x - height }
				
				.unreq	x
				.unreq	y
				.unreq	width
				.unreq	height
			
			blockHasNoData:
			
			
			
			pop	{ blockColor }
			
			
			
			
			
			
			
			
			
			// if (blockBitForXY == 0)

				// tetrisClearGridBlock(int x, int y)
				//moveq	r0, 	blockX
				//moveq	r1,		blockY
				//bleq 	tetrisClearGridBlock

			// else

				// tetrisSetGridBlockColor(int x, int y, int color)
				//stmnefd	sp!, 	{ blockX, blockY, blockColor }
				//blne 	tetrisSetGridBlockColor

			// endif

			.unreq	blockBitForXY
			.unreq 	blockGridData

			pop 	{ blockX - blockColor }

			add 	j, #1
			cmp 	j, #4
			blt 	for_j_lessThan_4_loop

		pop 	{ j }
		add 	i, #1
		cmp 	i, #4
		blt 	for_i_lessThan_4_loop
	
	pop		{ i - j }
		
	.unreq	i
	.unreq 	j

	pop		{ blockX - blockTypeOffset }

	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	pop 	{ lr }
	mov 	pc, lr				// return





// INPUT
//
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
//
tetrisCreateNewBlock:

	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	ldr		r0, 	=TetrisBlock
	ldmfd	r0,		{ blockX - blockTypeOffset }

	initializeTetrisBlock:

		mov 	blockX, 			#0				// randomize?
		mov 	blockY,				#0
		ldr 	blockColor,	 		=0x9999FF		// randomize?
		ldr		blockTypeAddress, 	=TetrisBlockC	// randomize?
		mov		blockTypeOffset,	#0				// randomize?

	initializeTetrisBlockEnd:

	stmfd	sp!,		{ blockX - blockTypeOffset }

	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		r0 = x
//		r1 = y
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//		r0 = bit value at position relative to the blocks local space
//
tetrisBlockContainsPoint:

	x					.req r0
	y					.req r1
	returnVal			.req r2
	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	mov		r3, 		sp
	mov		returnVal, 	#1
	push	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r3,			{ blockX - blockTypeOffset }
	//push	{ blockX - blockTypeOffset }
	
	// if (x > blockX && x < blockX + blockWidth)
		cmp		x, 			blockX
		movlt	returnVal,	#0
		blt		tetrisBlockDoesNotContainPoint
	
		add		blockX,		#4
		cmp		x, 			blockX
		movge	returnVal,	#0
		bge		tetrisBlockDoesNotContainPoint
	// endif
	
	// if (y > blockY && y < blockY + blockHeight)
		cmp		y, 			blockY
		movlt	returnVal,	#0
		blt		tetrisBlockDoesNotContainPoint
		
		add		blockY, #4
		cmp		y, 			blockY
		movge	returnVal,	#0
		bge		tetrisBlockDoesNotContainPoint
	// endif
	
	tetrisBlockDoesContainPoint:

		
		nop
		//pop		{ blockX - blockTypeOffset }
		
		/*
		
		sub	x, 		blockX
		sub	y, 		blockY
		push	{ r11 - r12 }
		
		mov	r11, #4
		mov	r12, #1
		
		nop
		
		// int offset = positionToArrayOffset(int x, int y, int cols)
		stmfd	sp!, 	{ x, y, r11, r12 }
		bl positionToArrayOffset
		ldmfd	sp!, 	{ returnVal }
		nop
		
		
		
		ldrh	r0, 	[blockTypeAddress, blockTypeOffset]
		mov		r1, 	#0b1000000000000000
		lsr		r1, 	returnVal
		
		and		r1, 	r0
		cmp		r1, 	#0
		movne	r1, 	#1
		mov		r0, 	r1
		
		nop
		
		
		
		
		
		
		
		
		
		pop		{ r11 - r12 }
		
		
		*/
		
		
		
		
		
		
		
		
		
		
		
		mov		r0, #1

	tetrisBlockDoesNotContainPoint:

		mov		r0, #0

tetrisBlockContainsPointEnd:

	pop		{ blockX - blockTypeOffset }
	mov		r0, returnVal

	.unreq	x
	.unreq	y
	.unreq	returnVal
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	pop		{ lr }
	mov 	pc, lr				// return
	
	
	
	
	
	
	
	
	
	
// INPUT
//		r0 = x
//		r1 = y
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//		r0 = bit value at position relative to the blocks local space
//
tetrisBlockBitForGridPoint:

	
	mov 	pc, lr				// return
	
	
	
	
	

	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = boolean (0 == false)
//		--------
//
tetrisCheckBlockGridCollisions:

	gridBitMask			.req r0
	blockGridData		.req r1
	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	mov		r0, 			sp
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r0, 			{ blockX - blockTypeOffset }
	
	push	{ blockX - blockTypeOffset }
	bl 		tetrisGetGridBitmaskForBlock
	pop		{ gridBitMask }
	pop		{ blockX - blockTypeOffset }
	
	nop
	
	ldrh	blockGridData, 	[blockTypeAddress, blockTypeOffset]
	and		gridBitMask, 	gridBitMask, blockGridData
	cmp		gridBitMask, 	#0
	movne	gridBitMask, 	#1
	
	pop		{ blockX - blockTypeOffset }
	pop		{ lr }
	push	{ gridBitMask }
	
	.unreq 	gridBitMask
	.unreq 	blockGridData		
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset
	
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisOnBlockCollision:

	blockGridData		.req r3
	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	pop		{ blockX - blockTypeOffset }
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	
	ldrh		r3, [blockTypeAddress, blockTypeOffset]
	nop
	
	bl 		writeBlockToGrid
	
	// delete current block and generate new one
	pop		{ blockX - blockTypeOffset }
	bl		tetrisCreateNewBlock
	pop		{ blockX - blockTypeOffset }
	pop 	{ lr }
	push	{ blockX - blockTypeOffset }
	
	.unreq 	blockGridData		
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		--------
//		On Stack
//		--------
// 		1 = blockX
// 		2 = blockY
// 		3 = blockColor
// 		4 = blockTypeAddress
// 		5 = blockTypeOffset
//		--------
// OUTPUT
//	
writeBlockToGrid:

	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	mov		r0, 		sp
	push 	{ lr }
	push	{ blockX - blockTypeOffset }
	ldmfd	r0, 		{ blockX - blockTypeOffset }

	i	.req r11
	j	.req r12
	
	push	{ i - j }

	mov		i, #0
	mov 	j, #0

	writeBlockToGrid_for_i_lessThan_4_loop:

		push 	{ j }

		writeBlockToGrid_for_j_lessThan_4_loop:

			push 	{ blockX - blockColor }

			blockBitForXY	.req r1
			blockGridData	.req r2
	
			ldrh	blockGridData, [blockTypeAddress, blockTypeOffset]

			add 	blockX, i
			add 	blockY, j

			// calculate bit corresponding to block position
			mov		blockBitForXY, 	#4
			mul		blockBitForXY, 	blockBitForXY, j
			add		blockBitForXY, 	i
			lsl		blockGridData, 	blockBitForXY
			mov		blockBitForXY, 	#0b1000000000000000
			and		blockBitForXY, 	blockGridData
			teq		blockBitForXY,	#0
			beq		writeBlockToGrid_blockHasNoData
			
			// if (blockBitForXY != 0)
			writeBlockToGrid_blockHasData:
			
				// tetrisSetGridBlockColor(int x, int y, int color)
				stmfd	sp!, 	{ blockX - blockColor }
				bl	 	tetrisSetGridBlockColor
			
			writeBlockToGrid_blockHasNoData:

				.unreq	blockBitForXY
				.unreq 	blockGridData

			pop 	{ blockX - blockColor }

			add 	j, #1
			cmp 	j, #4
			blt 	writeBlockToGrid_for_j_lessThan_4_loop

		pop 	{ j }
		add 	i, #1
		cmp 	i, #4
		blt 	writeBlockToGrid_for_i_lessThan_4_loop
	
	pop		{ i - j }
		
	.unreq	i
	.unreq 	j

	pop		{ blockX - blockTypeOffset }

	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset

	pop 	{ lr }
	mov 	pc, lr				// return
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
// INPUT
//		r0 = CC/CCW	(0 == CC, otherwise CCW)
//
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//
tetrisRotateBlock:

	rotationDirection	.req r0
	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	pop		{ blockX - blockTypeOffset }
	push	{ lr }
	
	// copy block in current state
	push 	{ blockX - blockTypeOffset }
	
	// update block values
	//
	teq		rotationDirection, 	#0
	beq		handleRotateLeft
	bne		handleRotateRight
	
	handleRotateLeft:
	
		add		blockTypeOffset, 	#2
		cmp		blockTypeOffset, 	#6
		movgt	blockTypeOffset, 	#0		// wrap around
	
		b 	handleRotateEnd
	
	handleRotateRight:
	
		sub		blockTypeOffset, 	#2
		cmp		blockTypeOffset, 	#0
		movlt	blockTypeOffset, 	#6		// wrap around
	
		b 	handleRotateEnd
		
	handleRotateEnd:
		push 	{ blockX - blockTypeOffset }
	
	// didCollide = tetrisCheckBlockGridCollisions(block)
	bl		tetrisCheckBlockGridCollisions
	pop		{ r0 }
	teq		r0, #0
	bne		onRotationCollision
	beq		onNoRotationCollision
	
	onRotationCollision:
		
		pop		{ blockX - blockTypeOffset }	// delete updated block
		pop		{ blockX - blockTypeOffset }	// pop previous block copy
		pop		{ lr }
		push	{ blockX - blockTypeOffset }	// push previous block copy
		b 		tetrisRotateBlockEnd
		
	onNoRotationCollision:
	
		pop		{ blockX - blockTypeOffset }	// pop updated block
		addeq	sp, #20							// delete previous block copy
		pop		{ lr }
		push	{ blockX - blockTypeOffset }	// push updated bloc
		b 		tetrisRotateBlockEnd
	
tetrisRotateBlockEnd:

	.unreq 	rotationDirection
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset
	
	mov 	pc, lr				// return
	
	
	
	
	
// INPUT
//		r0 = dx
//		r1 = dy
//
//		--------
//		On Stack
//		--------
// 		0 = blockX
// 		1 = blockY
// 		2 = blockColor
// 		3 = blockTypeAddress
// 		4 = blockTypeOffset
//		--------
// OUTPUT
//		--------
//		On Stack
//		--------
// 		0 = didCollide
//		--------
//
tetrisTranslateBlock:

	dx					.req r0
	dy					.req r1
	blockX				.req r4
	blockY				.req r5
	blockColor			.req r6
	blockTypeAddress	.req r7
	blockTypeOffset		.req r8
	
	pop		{ blockX - blockTypeOffset }
	push	{ lr }
	
	// copy block in current state
	push 	{ blockX - blockTypeOffset }
	
	// update block values
	add		blockX, dx
	add		blockY, dy
	push 	{ dx, dy }
	push 	{ blockX - blockTypeOffset }
	
	// didCollide = tetrisCheckBlockGridCollisions(block)
	bl		tetrisCheckBlockGridCollisions
	didCollide			.req r3
	pop		{ didCollide }
	pop 	{ blockX - blockTypeOffset }
	pop		{ dx, dy }
	push 	{ blockX - blockTypeOffset }
	teq		didCollide, #0
	.unreq	didCollide
	bne		onTranslationCollision
	beq		onNoTranslationCollision
	
	onTranslationCollision:
		
		pop		{ blockX - blockTypeOffset }	// delete updated block
		pop		{ blockX - blockTypeOffset }	// pop previous block copy
		teq		dy, #0
		beq		onTranslationCollision_Horizontal
		bne		onTranslationCollision_Vertical
		
		// we only need to create a new block on vertical collisions,
		// because horizontal collisions still allow the block to move
		// downwards 
		
		onTranslationCollision_Horizontal:
		
			pop		{ lr }
			push	{ blockX - blockTypeOffset }	// push previous block
			
			b 		tetrisTranslateBlockEnd
		
		onTranslationCollision_Vertical:
		
			push	{ blockX - blockTypeOffset }	// push previous block copy
			bl		tetrisOnBlockCollision
			pop		{ blockX - blockTypeOffset }	// pop new block
			pop		{ lr }
			push	{ blockX - blockTypeOffset }	// push new block
			
			b 		tetrisTranslateBlockEnd
		
	onNoTranslationCollision:
	
		pop		{ blockX - blockTypeOffset }	// pop updated block
		addeq	sp, #20							// delete previous block copy
		pop		{ lr }
		push	{ blockX - blockTypeOffset }	// push updated block
		b 		tetrisTranslateBlockEnd
		
tetrisTranslateBlockEnd:

	.unreq	dx
	.unreq	dy
	.unreq	blockX
	.unreq	blockY
	.unreq 	blockColor
	.unreq	blockTypeAddress
	.unreq	blockTypeOffset
	
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
	.int	10				// tetrisGridCols
	.int	19				// tetrisGridRows
	.int	32				// tetrisGridBlockSize (n x n pixels)
	.space 	10 * 19 * 4		// tetrisGridData (cols x rows)
TetrisGridEnd:


TetrisBlock:
	.int		0			// blockX
	.int		0			// blockY
	.word		0xFFFFFF	// blockColor
	.word 		0			// blockTypeAddress
	.int 		0			// blockTypeOffset (0 - 3)
TetrisBlockEnd:


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
	//	----u
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

.align 4
font:		.incbin	"font.bin"

.align 4
createdHeader:
    .int    55
    .ascii  "Created by: Nathan Escandor, Charlie Roy, and Pat Sluth" //Length 55

.align 4
scoreHeader:
    .int    5
    .ascii  "Score" //Length 5
    
.align 4
scoreText:
    .int    3
    .ascii  "000"
    
    
.align 4
scoreNumber:
    .int    0
    
QueueHeader:
    .int    8
    .ascii  "Upcoming" //Length 8

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



