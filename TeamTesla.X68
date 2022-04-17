*-----------------------------------------------------------
* Title      : DISASSEMBLER
* Written by : Ani, Ashlyn, Evan, River
*-----------------------------------------------------------


START       ORG    $1000



START_PRG 
            CLR     D0
            CLR     D1
            CLR     D2
            CLR     D3
            CLR     D4
            CLR     D5         
            LEA     DIRECTIONS,A1   * Loads first address prompt into A1
            MOVE.B  #14,D0          * Move 14 in D0 to prompt user
            TRAP    #15             * Prompt user
            
             
            LEA     PROMPT1,A1      * Loads first address prompt into A1
            MOVE.B  #14,D0          * Move 14 in D0 to prompt user
            TRAP    #15             * Prompt user
   
            MOVE.L  #$900,A1       * NEW
            MOVE.B  #2,D0           * Move 2 into D0
            TRAP    #15             * Read input from user and store it in A1
            
            MOVEA.L A1,A0           * Move our first number recieved into A0
            
            LEA     PROMPT2,A1      * Loads second address prompt into A1
            MOVE.B  #14,D0          * Move 14 in D0 to prompt user
            TRAP    #15             * Prompt user
            
            MOVE.L  #$910,A1       * NEW
            MOVE.B  #2,D0           * Move 2 into D0
            TRAP    #15             * Read input from user and store it in A1
            
            MOVE.B  #0,D4
            MOVE.B  #6,D5
            
*====================================================================
*            Convert Ascii into Hex  (1st and 2nd Address)
*====================================================================
CONVERTHEX1        
            CLR     D1              * Clear regiters to prepare for conversion
            CMP.B   D4,D5           * Check counter in D4 and D5, if counter = 4 we stop
            BEQ     INITHEX2
            
            MOVE.B  (A0)+,D1        * Move our ascii byte into D1
            CMPI.B  #$40,D1         * Compare to 40 (if <40 = number OR if   >40 = character)
            BLT     NUMBER1         * If < then convert as number
            BRA     CHARACTER1      * Always branch to character since we know its not a number
            
NUMBER1     
            SUB.B   #$30,D1         * Subtract 30 from the ascii value to get hex value
            BRA     COMBINE1        * Branch to figure out next number
            
CHARACTER1   
            SUB.B   #$37,D1         * Subtract 37 from the ascii value to get hex value
            
COMBINE1     
            ADD.B  D1,D2            * Add D1 and D2 together (combines our hex value
            
            CMPI.B  #5,D4           * Compare our counter to 3 if here we dont need to shift our final hex number
            BEQ     INITHEX2        * And we go ahead and branch
            
            LSL.L   #4,D2           * Shift D2 (our hex number) by 8 to make room for rest of hex number conversion
            
            ADD.B   #1,D4           * Add 1 to our counter in D4
            BRA     CONVERTHEX1     * Loop back up
          
            * D1,D2 used. D1 = temp, D2 = holds first starting address
            * D4,D5 = counters
INITHEX2
            MOVE.B  #0,D4
            MOVE.B  #6,D5
            
CONVERTHEX2
            CLR     D1              * Clear regiters to prepare for conversion
            CMP.B   D4,D5           * Check counter in D4 and D5, if counter = 4 we stop
            BEQ     CHECK
            
            MOVE.B  (A1)+,D1        * Move our ascii byte into D1
            CMPI.B  #$40,D1         * Compare to 40 (if <40 = number OR if   >40 = character)
            BLT     NUMBER2         * If < then convert as number
            BRA     CHARACTER2      * Always branch to character since we know its not a number
            
NUMBER2     
            SUB.B   #$30,D1         * Subtract 30 from the ascii value to get hex value
            BRA     COMBINE2        * Branch to figure out next number
            
CHARACTER2   
            SUB.B   #$37,D1         * Subtract 37 from the ascii value to get hex value
            
COMBINE2     
            ADD.B  D1,D3            * Add D1 and D2 together (combines our hex value
            
            CMPI.B  #5,D4           * Compare our counter to 3 if here we dont need to shift our final hex number
            BEQ     CHECK            * And we go ahead and branch
            
            LSL.L   #4,D3           * Shift D2 (our hex number) by 8 to make room for rest of hex number conversion
            
            ADD.B   #1,D4           * Add 1 to our counter in D4
            BRA     CONVERTHEX2     * Loop back up
          
            * D1,D3 used. D1 = temp, D3 = holds ENDING address
            * D4,D5 = counters
            
*-----------------------------------------------------------
* Test to see if we have the correct input passed in by the
* user. If not the user is then repromped.
*-----------------------------------------------------------
CHECK
            CMP.L   D2,D3
            BEQ     INPUT_ERR
            CMP.L   D2,D3           * Make sure starting adress isn't greater than ending
            BLT     INPUT_ERR
            MOVE.B  D2,D6           * Get last byte to check if number even or odd (big divisions are bad)
            MOVE.B  D3,D7
            DIVS.W  #$2,D6          * Divide to see what remainder/modulous is
            SWAP    D6              * Remainder gets stored in upper word so swap swaps it to the lower word
            CMP.B   #$01,D6
            BEQ     INPUT_ERR       * Odd input error
            DIVS.W  #$2,D7
            SWAP    D7
            CMP.B   #$01,D7
            BEQ     INPUT_ERR
            BRA     DONE
            
            
INPUT_ERR                           * Load in input error and print to user
            LEA     BLANK,A1
            MOVE.B  #14,D0
            TRAP    #15

            LEA     ERROR_MSG,A1
            TRAP    #15
            
            LEA     BLANK,A1
            MOVE.B  #14,D0
            TRAP    #15

            
            BRA     START_PRG

                 
*-----------------------------------------------------------
* Initialize the main loop to go through addresess and 
* read mahine codes. 
*----------------------------------------------------------- 
DONE            
            MOVE.L  D2,BEGIN        *put adsresses in variable in order to put in addr register
            MOVE.L  D3,FIN
            MOVEA.L  BEGIN,A2       *Move to address registers
            MOVEA.L  FIN,A3            


*====================================================================
*           Main Loop To Decode Instuctions
*====================================================================
MAIN_LOOP
            CLR.L     D6
            MOVEA.L A2,A4
            CMPA.L  A3,A2           * Check are we done
            BGE     END             
            MOVE.W  (A2),D7         * Get instruction as a word
            CMP.W   #$4E75,D7       * Check if RTS instruction
            BEQ     MATCH_RTS
            
            CMP.W   #$4E71,D7       * Check if NOP instruction
            BEQ     MATCH_NOP
            
            MOVE.B  #7,D3
            LSR.W   D3,D7           * Shift to get 9 bits
            
            CMP.B   #$91,D7
            BEQ     MATCH_MOVEM     * Check if MOVEM instruction
            CMP.B   #$99,D7
            BEQ     MATCH_MOVEM
            
            MOVE.W  (A2),D7
            
            LSR.W   #6,D7           * Shift to get only 10 digits
            CMP.W   #$013A,D7       * Check if it is a JSR instruction
            BEQ     MATCH_JSR
            
            CMP.W   #%1110011011,D7 * Check if rotate right memory 
            BEQ     MATCH_MEMROR
            
            CMP.W   #%1110011111,D7 * Check if rotate left memory
            BEQ     MATCH_MEMROL
            
            
            CMP.W   #$38B,D7        * Check if right logical memory shift (had to break up becasue instruction format difference)
            BEQ     MATCH_MEMLSHIFTR
            
            CMP.W   #$38F,D7        * Check if left logical memory shift
            BEQ     MATCH_MEMLSHIFTL
            
            CMP.W   #%1110000011,D7 * Check if right arithmatic memory shift (had to break up becasue instruction format diff)
            BEQ     MATCH_MEMASHIFTR
            
            CMP.W   #%1110000111,D7 * Check if left arithmatic memory shift
            BEQ     MATCH_MEMASHIFTL
            
            LSR.W   #2,D7           * Shift 2 bits to see 8 bits total
            CMP.W   #$46,D7         * Check if NOT instruction
            BEQ     MATCH_NOT
            
            CMP.W   #$60,D7         * Check if BRA instruction
            BEQ     MATCH_BRA
            
            LSR.W   #4,D7           * Shift more to see 4 bits total and if we match a normal register logical/arithmetic shift
            CMP.B   #$0E,D7
            BEQ     MATCH_SHIFT     * Check if shift instructions
            
            CMP.B   #$7,D7
            BEQ     MATCH_MOVEQ     * Check if MOVEQ instruction
            
            
            CMP.B   #$D,D7
            BEQ     MATCH_ADD       * Check if ADD instruction
            
            CMP.B   #$5,D7
            BEQ     MATCH_ADDQ      * Check if ADDQ instruction
            
            CMP.B   #$9,D7
            BEQ     MATCH_SUB       * Check if SUB instruction
            
            CMP.B   #$C,D7
            BEQ     MATCH_AND       * Check if AND instruction
            
            CMP.B   #$4,D7
            BEQ     MATCH_LEA       * Check if LEA instruction
            
            CMP.B   #$8,D7
            BEQ     MATCH_OR        * Check if OR instruction
            
            CMP.B   #$06,D7         * Check if any of Branch Instructions
            BEQ     MATCH_BCC
            
            LSR.W   #2,D7           * Shift more to see 2 bits total
            CMP.B   #$0,D7
            BEQ     MATCH_MOVE      * Check if MOVE instruction

*-----------------------------------------------------------
* Opcode not found in current memory being read 
* Current memory being read that did not dissemble to 
* readable opcode from specs
*----------------------------------------------------------- 
NOOP 
            MOVE.L  A2,D1
            MOVE.B  #16,D2      
            MOVE.B  #15,D0
            TRAP    #15             * Output current memory address word
    
            LEA     UNKNOWN,A1      * Move constant DATA to A1
            MOVE.B  #14,D0          * Prepare to print string in (A1)
            TRAP    #15             * Display string in (A1)
            
            LEA     SPACE,A1        
            TRAP    #15
            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.W  (A2),D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #2,A2
            
INCREMENT                           * Increment the loop and continue reading opcodes        
            
            LEA     BLANK,A1        * PRINT BLANK LINE to prepare for next line
            MOVE.B  #14,D0
            TRAP    #15
            
            
            ADD.B   #1,D5
            CMP.B   #30,D5          * Check to see if we have printed a full screen of data
            BEQ     ASK_CONTINUE
            
            BRA     MAIN_LOOP            
            

ASK_CONTINUE                        * Ask user if they wish to continue readng file
            CLR     D5
            LEA     ASK,A1
            MOVE.B  #14,D0
            TRAP    #15

USER_INPUT
            MOVE.L  #$920,A1
            MOVE.B  #2,D0  
            TRAP    #15             * Read input from user and store it in A1
            
            MOVE.L  (A1),D5
            CMP.B   #$0D,D5         * Make sure user is pressing enter
            BEQ     USER_INPUT
            
            CLR     D5

            BRA     MAIN_LOOP       * Branch back up to main loop


*====================================================================
*                  Decoding Opcodes and EAs
*====================================================================

*-----------------------------------------------------------
* Test to see if we have a matching RTS op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_RTS
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_RTS,A1
            MOVE.B  #14,D0
            TRAP    #15
            ADDA.L  #$2,A2
            BRA     INCREMENT
            
            
*-----------------------------------------------------------
* Test to see if we have a matching NOP op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_NOP
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_NOP,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ADDA.L  #$2,A2

            BRA     INCREMENT      
 
*-----------------------------------------------------------
* Test to see if we have a matching JSR op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------            
MATCH_JSR
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_JSR,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.W  (A2),D7 
            AND.W   #$0038,D7       * Get only 3 bits for mode
            
            CMP.W   #$0010,D7       * See if (An) mode
            BEQ     EA_JSR_ADDREG

            CMP.W   #$0038,D7       * See if ABS mode
            BEQ     VERIFY_ABS
            
            * Do not match any of the EA's so we go to invalid ea subroutine
            MOVEM.L A2/D7,-(SP)
            JSR     INVALID_EA_T2
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L A4,A2

            BRA     INCREMENT
            
EA_JSR_ADDREG                       * JSR EA that is an address register
            AND.B   #$07,D6         * Get the last three bits for the register number
            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     L_PAREN,A1
            TRAP    #15

            
            CLR     D1 
            LEA     MSG_A,A1
            TRAP    #15
            MOVE.B  D6,D1
            MOVE.B  #10,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ADDA.L  #$2,A2          * Increment address position
            BRA     INCREMENT
            
            
VERIFY_ABS                          * Verify the addressing to make sure  its a mode we know
            MOVE.W  (A2),D7
            AND.W   #$0007,D7
            
            CMP.B   #$00,D7
            BEQ     EA_JSR_ABS
            
            CMP.B   #$01,D7
            BEQ     EA_JSR_ABS

            * Do not match any of the EA's so we go to invalid ea subroutine
            MOVEM.L A2/D7,-(SP)
            JSR     INVALID_EA_T2
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L A4,A2
            BRA     INCREMENT

            
EA_JSR_ABS
            
            BTST.L  #$00,D7         * Check data register to see if long or word
            BNE     EA_JSR_LONG     * Long adressing
            ADDA.L  #$2,A2          * Else word adressing and grab extra word address
            
            MOVE.W  (A2),D1         * Word Addressing for JSR
            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            MOVE.B  #15,D0
            MOVE.B  #16,D2
            TRAP    #15
            
            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
            
EA_JSR_LONG                         * Long Addressing for JSR
            ADDA.L  #$2,A2          * Grab first extra word address
            
            MOVE.W  (A2),D1
            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            MOVE.B  #15,D0
            MOVE.B  #16,D2
            TRAP    #15
            
            ADDA.L  #$2,A2          * Grab second extra word address
            
            MOVE.W  (A2),D1
            
            TRAP    #15
            
            ADDA.L  #$2,A2
            BRA     INCREMENT

*-----------------------------------------------------------
* Test to see if we have a matching Memory Shift ROR op code. 
* If so print out the memory address and the op code.
*-----------------------------------------------------------            
MATCH_MEMROR
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ROR,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * Find Size
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_MEMLAR
            MOVEM.L (SP)+,A2/D7

            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_MEM_SHIFT_ROTATE
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L  A4,A2
            BRA     INCREMENT

*-----------------------------------------------------------
* Test to see if we have a matching Memory Shift ROL op code. 
* If so print out the memory address and the op code.
*-----------------------------------------------------------            
MATCH_MEMROL
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ROL,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * Find Size
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_MEMLAR
            MOVEM.L (SP)+,A2/D7

            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_MEM_SHIFT_ROTATE
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L  A4,A2
            BRA     INCREMENT
       

*-----------------------------------------------------------
* Test to see if we have a matching Memory Shift LSR op code. 
* If so print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_MEMLSHIFTR  
            MOVE.L  A2,D1 
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_LSR,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * Find Size
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_MEMLAR
            MOVEM.L (SP)+,A2/D7
            
            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_MEM_SHIFT_ROTATE
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L  A4,A2
            BRA     INCREMENT
            
*-----------------------------------------------------------
* Test to see if we have a matching Memory Shift LSL op code. 
* If so print out the memory address and the op code.
*-----------------------------------------------------------            
MATCH_MEMLSHIFTL
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_LSL,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * Find Size
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_MEMLAR
            MOVEM.L (SP)+,A2/D7

            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_MEM_SHIFT_ROTATE
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L  A4,A2
            BRA     INCREMENT
            
*-----------------------------------------------------------
* Test to see if we have a matching Memory Shift ASR op code. 
* If so print out the memory address and the op code.
*-----------------------------------------------------------            
MATCH_MEMASHIFTR
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ASR,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * Find Size
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_MEMLAR
            MOVEM.L (SP)+,A2/D7
            
            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_MEM_SHIFT_ROTATE
            MOVEM.L (SP)+,A2/D7

            
            MOVEA.L  A4,A2
            BRA     INCREMENT

*-----------------------------------------------------------
* Test to see if we have a matching Memory Shift ASL op code. 
* If so print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_MEMASHIFTL
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ASL,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * Find Size
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_MEMLAR
            MOVEM.L (SP)+,A2/D7

            *Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_MEM_SHIFT_ROTATE
            MOVEM.L (SP)+,A2/D7
           
            MOVEA.L  A4,A2
            BRA     INCREMENT

*-----------------------------------------------------------
* Test to see if we have a matching NOT op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_NOT
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT NOT
            LEA     MSG_NOT,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.W  (A2),D7
             *TEST GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     SIZE_NOT
            MOVEM.L (SP)+,A2/D7
            
            * PRINT SPACE
            LEA     SPACE,A1        * Byte displacement
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT TEST EA
            MOVEM.L A2/D7,-(SP)
            JSR     T_NOT_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print 
                                        *INVALID_EA
            BEQ     INVAL_EA_NO_RTS
            
            
            MOVEM.L A2/D7,-(SP)
            JSR     NOT_EA
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L A4,A2             *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            

            BRA     INCREMENT       * Branch back up to main loop


SIZE_NOT    * COMPARE SIZE
            LSR.B   #6,D7
            CMP.B   #$0,D7
            BEQ     BYTE
            CMP.B   #$1,D7
            BEQ     WORD
            CMP.B   #$2,D7
            BEQ     LONG

            
T_NOT_EA
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register

            CMP.B   #$0,D7          *mode is Dn
            BEQ     GOOD            *ea valid
            CMP.B   #$1,D7          
            BEQ     INVALID_EA
            CMP.B   #$2,D7             *mode is (An)
            BEQ     GOOD       *(An) 
            CMP.B   #$3,D7
            BEQ     GOOD      *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD      *-(An)
            CMP.B   #$7,D7
            BEQ     T_NOT_IMM_REG     *(xxx).W or (xxx).L or #<data>
            BRA     INVALID_EA
            
T_NOT_IMM_REG 
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7
            LSR.W   D3,D7
            CMP.B   #$0,D7
            BEQ     GOOD  *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD  *long absolute address
            BRA     INVALID_EA  

NOT_EA
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register

            CMP.B   #$0,D7
            BEQ     DATA_R_S 
            CMP.B   #$1,D7
            BEQ     INVALID_EA      *An
            CMP.B   #$2,D7
            BEQ     ADDY_R_SP       *(An)
            CMP.B   #$3,D7
            BEQ     ADDY_R_SPI      *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_SPD      *-(An)
            CMP.B   #$7,D7
            BEQ     NOT_IMM_REG
            BRA     INVALID_EA  
            
NOT_IMM_REG 
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7
            LSR.W   D3,D7
            CMP.B   #$0,D7
            BEQ     W_ADDY  *word absolute address
            CMP.B   #$1,D7
            BEQ     L_ADDY  *long absolute address
            BRA     INVALID_EA    


          
            
*-----------------------------------------------------------
* Test to see if we have a matching BRA op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_BRA
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_BRA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.W  (A2),D7
            CMP.B   #$00,D7         * Compare to see if we have a word displacement or byte
            BEQ     EA_BRA_WORD
            
            LEA     SPACE,A1        * Byte displacement
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
            
EA_BRA_WORD                     * Word Displacement
            ADDA.L  #$2,A2            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     HEX_SIGN,A1 
            TRAP    #15
            
            CLR     D1
            MOVE.W  (A2),D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #$2,A2

            BRA     INCREMENT
           
*-----------------------------------------------------------
* Test to see if we have a matching logical, arthemetic, or rotate
* shift. (Register shift)
*-----------------------------------------------------------
MATCH_SHIFT
            MOVE.W  (A2),D7         * Get full instruction again to figure out the type of shift or rotate
            LSR.W   #3,D7          
            
            AND.W   #$0003,D7
            
            CMP.B   #$03,D7
            BEQ     ROTATE          * Match rotate
            
            CMP.B   #$01,D7
            BEQ     LSHIFT          * Match logical shift
            
            CMP.B   #$00,D7
            BEQ     ASHIFT          * Match arithmetic shift
       
*-----------------------------------------------------------
* We have a rotate instruction.Check to see if left or right.
*-----------------------------------------------------------
ROTATE
            MOVE.W  (A2),D7
            BTST.L  #$8,D7          * Check if left or right direction (8th bit gets tested)
            BNE     RL
            
            MOVE.L  A2,D1           * Must be a right logical shift so dont branch
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ROR,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * TESTING FOR SIZE
            AND     #$00C0,D7
            
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_LAR
            MOVEM.L (SP)+,A2/D7

            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_SHIFT_ROTATE  
            MOVEM.L (SP)+,A2/D7

            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT

* Rotate Left
RL
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ROL,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            
            * TESTING FOR SIZE
            AND     #$00C0,D7
            
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_LAR
            MOVEM.L (SP)+,A2/D7
            
            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_SHIFT_ROTATE  
            MOVEM.L (SP)+,A2/D7

            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
*-----------------------------------------------------------
* We have a logical register shift. Check to see if its 
* left or right.
*-----------------------------------------------------------
LSHIFT
            MOVE.W  (A2),D7
            BTST.L  #$8,D7          * Check if left or right direction (8th bit gets tested)
            BNE     LL
            
            MOVE.L  A2,D1           * Must be a right logical shift so dont branch
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_LSR,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * TESTING FOR SIZE
            AND     #$00C0,D7
            
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_LAR  
            MOVEM.L (SP)+,A2/D7
            
            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_SHIFT_ROTATE  
            MOVEM.L (SP)+,A2/D7
     
            ADDA.L  #$2,A2
            
            BRA     INCREMENT

* Logical Left Shift            
LL
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_LSL,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * TESTING FOR SIZE
            AND     #$00C0,D7

            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_LAR
            MOVEM.L (SP)+,A2/D7
            
            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_SHIFT_ROTATE  
            MOVEM.L (SP)+,A2/D7

            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
            
*-----------------------------------------------------------
* We have a arithmetic register shift. Check to see if its 
* left or right.
*-----------------------------------------------------------    
ASHIFT
            MOVE.W  (A2),D7
            BTST.L  #$8,D7          * Check if left or right direction (8th bit gets tested)
            BNE     AL

            MOVE.L  A2,D1           * Must be a right arithmetic shift so dont branch
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ASR,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * TESTING FOR SIZE
            AND     #$00C0,D7
            
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_LAR
            MOVEM.L (SP)+,A2/D7
            
            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_SHIFT_ROTATE  
            MOVEM.L (SP)+,A2/D7

            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
            
* Arithmetic Left Shift            
AL
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ASL,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * TESTING FOR SIZE
            AND     #$00C0,D7
            
            MOVEM.L A2/D7,-(SP)
            JSR     MATCH_SIZE_LAR
            MOVEM.L (SP)+,A2/D7
            
            * Figure out EA
            MOVEM.L A2/D7,-(SP)
            JSR     EA_SHIFT_ROTATE  
            MOVEM.L (SP)+,A2/D7

            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
*-----------------------------------------------------------
* Test to see if we have a matching MOVEQ op code. If so
* print out the memory address and the op code.
*----------------------------------------------------------- 
MATCH_MOVEQ
            MOVE.W  (A2),D7
            MOVE.L #15,D3
            LSL.W   #7,D7
            LSR.W   D3,D7
            
            CMP.B   #$00,D7
            BNE     NOOP
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT MOVEQ
            LEA     MSG_MOVEQ,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     SPACE,A1        
            MOVE.B  #14,D0
            TRAP    #15
            
            *print data of moveq
            LEA     HASH_SIGN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX SIGN
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            MOVE.W  (A2),D7
            LSL.W   #8,D7
            LSR.W   #8,D7
            MOVE.L  D7,D1
            
            MOVE.L  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            *print Dn
            LSL.W   #4,D7
            MOVE.L  #13,D3
            LSR.W   D3,D7
            MOVE.L  D7,D1
    
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     DATA_R_D    *print Dn
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L A4,A2           *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            
        
            BRA     INCREMENT       * Branch back up to main loop


*-----------------------------------------------------------
* Test to see if we have a matching ADD op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------   
MATCH_ADD
            MOVE.W  (A2),D7
            LSL.W   #7,D7       *shift value in D7 to the left by 7 bits
            MOVE.L  #13,D3
            LSR.W   D3,D7 
            CMP.B   #$3,D7      *check if opcode is $3 if so it is ADDA

            BEQ     MATCH_ADDA
            CMP.B  #$7,D7       *check if opcode is $7 if so it is ADDA
            BEQ     MATCH_ADDA
            
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ADD,A1  *print out ADDA
            MOVE.B  #14,D0
            TRAP    #15
    
           * PRINT SIZE
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     ADD_SIZE_SUB    
            MOVEM.L (SP)+,A2/D7
            
            LEA     SPACE,A1        
            MOVE.B  #14,D0
            TRAP    #15
            
             *TEST GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_SUBTR_PRINT_SRC_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print 
                                        *INVALID_EA
            BEQ     INVAL_EA_NO_RTS
            
            
            * TEST PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_SUBTR_PRINT_DEST_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print 
            BEQ     INVAL_EA_NO_RTS                            *INVALID_EA
 
            *GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     SUBTR_PRINT_SRC_EA  *print out source ea
            MOVEM.L (SP)+,A2/D7
            
             * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     SUBTR_PRINT_DEST_EA *print out dest ea
            MOVEM.L (SP)+,A2/D7


            
            MOVEA.L A4,A2             *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            
            BRA     INCREMENT       * Branch back up to main loop

ADD_SIZE_SUB                           * ADD SIZE SUBROUTINE START
            * SHIFT TO SIZE FIELD
            
            LSL.W   #7,D7
            MOVE.L  #13,D3
            LSR.W   D3,D7
            * RUN COMPARISONS
            CMP.B   #$0,D7
            BEQ     BYTE
            CMP.B   #$1,D7
            BEQ     WORD
            CMP.B   #$2,D7
            BEQ     LONG
            CMP.B   #$4,D7
            BEQ     BYTE
            CMP.B   #$5,D7
            BEQ     WORD
            CMP.B   #$6,D7
            BEQ     LONG
            BRA     EXIT



*-----------------------------------------------------------
* Test to see if we have a matching ADDA op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_ADDA
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ADDA,A1     *print ADDA
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT SIZE
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     ADDA_SIZE_SUB
            MOVEM.L (SP)+,A2/D7
            
            LEA     SPACE,A1        
            MOVE.B  #14,D0
            TRAP    #15
            
            *TEST EA
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_ADDA_PRINT_SRC_EA    *test ea 
            MOVEM.L (SP)+,A2/D7
            

            CMP.B   #$1,D6
            BEQ     INVAL_EA_NO_RTS
            
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     ADDA_P_SRC_EA    *print ea 
            MOVEM.L (SP)+,A2/D7
            
            * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
                
            CLR.L   D7
            MOVE.W  (A2),D7
            
            * PRINT ADDRESS REGISTER
            MOVE.L  #13,D3
            LSL.W   #4,D7
            LSR.W   D3,D7   *get register bits 
            
            LEA     MSG_A,A1    *print An
            MOVE.B  #14,D0
            TRAP    #15
 
            MOVE.L  #16,D2
            MOVE.L  D7,D1       *print register number of An
            MOVE.B  #15,D0
            TRAP    #15

            MOVEA.L A4,A2           *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long

            BRA     INCREMENT       * Branch back up to main loop
ADDA_P_SRC_EA
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register

            CMP.B   #$0,D7
            BEQ     DATA_R_S        *Dn
            CMP.B   #$1,D7
            BEQ     ADDY_R_SNP      *An
            CMP.B   #$2,D7
            BEQ     ADDY_R_SP       *(An)
            CMP.B   #$3,D7
            BEQ     ADDY_R_SPI      *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_SPD      *-(An)
            CMP.B   #$7,D7
            BEQ     AI_M_S      *immediate or absolut addy
            BRA     EXIT

AI_M_S
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7
            LSR.W   D3,D7
            CMP.B   #$0,D7
            BEQ     W_ADDY *absolute addy word
            CMP.B   #$1,D7
            BEQ     L_ADDY *absolute addy long
            CMP.B   #$4,D7
            BEQ     ADDA_IMM_DATA_S *immediate data
            
            BRA     EXIT

             
ADDA_IMM_DATA_S            
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *shift D7 to right 10 to get the opmode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            *check if opmode bits are 3 or 7
            ADDA.L  #$2,A4 
            CMP.B   #$3,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$7,D7
            BEQ     IMM_DATA_SL
            BRA     EXIT
            
            
T_ADDA_PRINT_SRC_EA *test if ADDA EA is valid or not
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register

            CMP.B   #$0,D7          *mode is Dn
            BEQ     GOOD            *ea valid
            CMP.B   #$1,D7          
            BEQ     GOOD
            CMP.B   #$2,D7             *mode is (An)
            BEQ     GOOD       *(An) 
            CMP.B   #$3,D7
            BEQ     GOOD      *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD      *-(An)
            CMP.B   #$7,D7
            BEQ     T_ADDA_IMM_REG_S      *(xxx).W or (xxx).L or #<data>
            BRA     INVALID_EA
            
T_ADDA_IMM_REG_S *EA is source for subtract opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     GOOD  *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD  *long absolute address
            CMP.B   #$4,D7
            BEQ     GOOD 
            
            BRA     INVALID_EA  

ADDA_SIZE_SUB                           * ADDA SIZE SUBROUTINE START
            * SHIFT TO SIZE FIELD
            LSL.W   #7,D7
            MOVE.L  #13,D3
            LSR.W   D3,D7
            * RUN COMPARISONS
            CMP.B   #$3,D7
            BEQ     WORD
            CMP.B   #$7,D7
            BEQ     LONG
            
            BRA     INVALID_EA
            
*-----------------------------------------------------------
* Test to see if we have a matching ADDQ op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_ADDQ
            MOVE.W  (A2),D7
            LSR.B   #7,D7
            CMP.B   #$2,D7  *check if size bits are greater than 2 if so then NOOP
            BGT     NOOP    
            
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ADDQ,A1 *print ADDQ 
            MOVE.B  #14,D0
            TRAP    #15
            
            
            * PRINT SIZE
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     ADDQ_SIZE_SUB
            MOVEM.L (SP)+,A2/D7
            
            LEA     SPACE,A1        
            MOVE.B  #14,D0
            TRAP    #15
            
            * TEST PRINT EFFECTIVE ADDRESS
            MOVEM.L A2/D7,-(SP)
            JSR     T_PRINT_EA_FSIXB
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6                 *if D6 has $1 that means that the test failed and now print INVALID EA    
            BEQ     INVAL_EA_NO_RTS
            
            
            * TODO: PRINT DATA
            * GET DATA
            MOVEM.L A2/D7,-(SP)
            JSR     ADDQ_DATA_SUB
            MOVEM.L (SP)+,A2/D7
            
            * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT EFFECTIVE ADDRESS
            MOVEM.L A2/D7,-(SP)
            JSR     PRINT_EA_FSIXB
            MOVEM.L (SP)+,A2/D7

            MOVEA.L A4,A2           *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            

            BRA     INCREMENT       * Branch back up to main loop


ADDQ_SIZE_SUB             * ADDQ SIZE SUBROUTINE START
            * SHIFT TO SIZE FIELD
            LSR.B   #6,D7
            
            * RUN COMPARISONS
            CMP.B   #$0,D7
            BEQ     BYTE
            CMP.B   #$1,D7
            BEQ     WORD
            CMP.B   #$2,D7
            BEQ     LONG
            BRA     EXIT
            
ADDQ_DATA_SUB
            * PRINT # SYMBOL
            LEA     HASH_SIGN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            * SHIFT TO DATA
            LSL.W   #4,D7
            MOVE.B  #13,D3
            LSR.W   D3,D7
            
            * PRINT DATA
            MOVE.B  #16,D2
            MOVE.W  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
        
            BRA     EXIT

T_PRINT_EA_FSIXB         *test for first 6 bits ea which is destination
            MOVE.W  (A2),D7
            LSL.B   #2,D7   *get rid of destination mode bits
            LSR.B   #5,D7   *move source mode bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     GOOD      
            CMP.B   #$1,D7
            BEQ     GOOD                *An
            CMP.B   #$2,D7
            BEQ     GOOD                *(An)
            CMP.B   #$3,D7
            BEQ     GOOD                *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD                *-(An)
            CMP.B   #$7,D7
            BEQ     T_IMM_REG_FSIXB
            BRA     INVALID_EA 
            
T_IMM_REG_FSIXB     *first 6 bits EA immediate data or address
            CLR.L     D7
            MOVE.W  (A2),D7         *get A2 data back to D7
            LSL.B   #5,D7   *get rid of destination mode bits and source mode bits
            LSR.B   #5,D7   *move source register bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     GOOD    *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD    *long absolute address
            BRA     INVALID_EA

PRINT_EA_FSIXB      *print what first 6 bits EA represent
            LSL.B   #2,D7   *get rid of destination mode bits
            LSR.B   #5,D7   *move source mode bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     DATA_R_S        *Dn
            CMP.B   #$1,D7
            BEQ     ADDY_R_SNP      *An
            CMP.B   #$2,D7
            BEQ     ADDY_R_SP       *(An)
            CMP.B   #$3,D7
            BEQ     ADDY_R_SPI      *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_SPD      *-(An)
            CMP.B   #$7,D7
            BEQ     IMM_REG_FSIXB
            BRA     INVALID_EA  
            
IMM_REG_FSIXB     *first 6 bits EA immediate data or address
            CLR.L     D7
            MOVE.W  (A2),D7         *get A2 data back to D7
            LSL.B   #5,D7   *get rid of destination mode bits and source mode bits
            LSR.B   #5,D7   *move source register bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     W_ADDY  *word absolute address
            CMP.B   #$1,D7
            BEQ     L_ADDY  *long absolute address
            BRA     INVALID_EA  



*-----------------------------------------------------------
* Test to see if we have a matching SUB op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_SUB
            * PRINT LINE NUMBER    
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            MOVE.W (A2),D7
            
            * PRINT SUB
            LEA     MSG_SUB,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  (A2),D7
            
            *GET SIZE SUB
            MOVEM.L A2/D7,-(SP)
            JSR     SUBT_SIZE_SUB
            MOVEM.L (SP)+,A2/D7
            
            * PRINT SPACE
            LEA     SPACE,A1        
            MOVE.B  #14,D0
            TRAP    #15
            
             *TEST GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_SUBTR_PRINT_SRC_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print INVALID EA    
            BEQ     INVAL_EA_NO_RTS     
                   
            * TEST PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_SUBTR_PRINT_DEST_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print INVALID EA    
            BEQ     INVAL_EA_NO_RTS
            
            *GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     SUBTR_PRINT_SRC_EA
            MOVEM.L (SP)+,A2/D7
            
             * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     SUBTR_PRINT_DEST_EA
            MOVEM.L (SP)+,A2/D7

            
            MOVEA.L A4,A2           *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            CLR.L   D7


            BRA     INCREMENT       * Branch back up to main loop

SUBT_SIZE_SUB   *print the size of subtract
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.W  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            CMP.B   #$0,D7
            BEQ     BYTE
            CMP.B   #$1,D7
            BEQ     WORD
            CMP.B   #$2,D7
            BEQ     LONG
            CMP.B   #$4,D7
            BEQ     BYTE
            CMP.B   #$5,D7
            BEQ     WORD
            CMP.B   #$6,D7
            BEQ     LONG
            BRA     EXIT
            *ELSE BRANCH TO INVALID EA

T_SOURCE_SUBTR_EA  
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register

            CMP.B   #$0,D7          *mode is Dn
            BEQ     GOOD
            CMP.B   #$1,D7          
            BEQ     T_SUBTR_ADDY_R_SNP
            CMP.B   #$2,D7             *mode is (An)
            BEQ     GOOD       *(An) 
            CMP.B   #$3,D7
            BEQ     GOOD      *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD      *-(An)
            CMP.B   #$7,D7
            BEQ     T_SUBTR_IMM_REG_S      *(xxx).W or (xxx).L or #<data>
            BRA     INVALID_EA

T_DEST_SUBTR_EA  
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 10 to get the mode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the mode

            CMP.B   #$0,D7          *mode is Dn
            BEQ     GOOD 
            CMP.B   #$1,D7          
            BEQ     T_SUBTR_ADDY_R_SNP
            CMP.B   #$2,D7             *mode is (An)
            BEQ     GOOD      *(An) 
            CMP.B   #$3,D7
            BEQ     GOOD      *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD      *-(An)
            CMP.B   #$7,D7
            BEQ     T_SUBTR_IMM_REG_D      *(xxx).W or (xxx).L
            BRA     INVALID_EA
            
T_SUBTR_PRINT_SRC_EA
            CLR.L   D7
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            
            CMP.B   #$0,D7
            BEQ     T_SOURCE_SUBTR_EA  *DEST ea is DN
            CMP.B   #$1,D7
            BEQ     T_SOURCE_SUBTR_EA  *DEST ea is DN
            CMP.B   #$2,D7
            BEQ     T_SOURCE_SUBTR_EA  *DEST ea is DN
            CMP.B   #$4,D7
            BEQ     GOOD   *SOURCE ea is DN
            CMP.B   #$5,D7
            BEQ     GOOD   *SOURCE ea is DN
            CMP.B   #$6,D7
            BEQ     GOOD  *SOURCE ea is DN
            BRA     INVALID_EA
            
            

T_SUBTR_PRINT_DEST_EA
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            
            CMP.B   #$0,D7
            BEQ     GOOD  *DEST ea is DN
            CMP.B   #$1,D7
            BEQ     GOOD  *DEST ea is DN
            CMP.B   #$2,D7
            BEQ     GOOD  *DEST ea is DN
            CMP.B   #$4,D7
            BEQ     T_DEST_SUBTR_EA   *source ea is DN
            CMP.B   #$5,D7
            BEQ     T_DEST_SUBTR_EA   *source ea is DN
            CMP.B   #$6,D7
            BEQ     T_DEST_SUBTR_EA   *source ea is DN
            BRA     INVALID_EA

T_SUBTR_IMM_REG_S *EA is source for subtract opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     GOOD  *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD  *long absolute address
            CMP.B   #$4,D7
            BEQ     T_SUBTR_IMM_DATA_S 
            
            BRA     INVALID_EA
            
T_SUBTR_IMM_DATA_S
            
            MOVE.W  (A4),D7
            LSL.W   #7,D7
            MOVE.L  #13,D3
            
            LSR.W   D3,D7       * SHIFT TO SIZE FIELD
            CMP.B   #$0,D7
            BEQ     GOOD
            CMP.B   #$1,D7
            BEQ     GOOD
            CMP.B   #$2,D7
            BEQ     GOOD
            CMP.B   #$4,D7
            BEQ     GOOD
            CMP.B   #$5,D7
            BEQ     GOOD
            CMP.B   #$6,D7
            BEQ     GOOD
            *if neither then it is an error
            BRA     INVALID_EA

T_SUBTR_ADDY_R_SNP    *An but cannot be byte for opcode size of subtr
            MOVE.W  (A4),D7
            LSL.W   #7,D7
            
            MOVE.L  #13,D3
            LSR.W   D3,D7
            CMP.B   #$1,D7
            BEQ     GOOD 
            CMP.B   #$2,D7
            BEQ     GOOD
            CMP.B   #$5,D7
            BEQ     GOOD
            CMP.B   #$6,D7
            BEQ     GOOD
            *INVALID EA
            BRA     INVALID_EA

            
T_SUBTR_IMM_REG_D *EA is destination for subtract opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7   *shift D7 to left 13 to get the register
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     GOOD  *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD  *long absolute address
            BRA     INVALID_EA


SOURCE_SUBTR_EA  
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register

            CMP.B   #$0,D7          *mode is Dn
            BEQ     F_SUBTR_DN_SRC 
            CMP.B   #$1,D7          mode is An NOT ALLOWED
            BEQ     SUBTR_ADDY_R_SNP
            CMP.B   #$2,D7             *mode is (An)
            BEQ     ADDY_R_SP       *(An) 
            CMP.B   #$3,D7
            BEQ     ADDY_R_SPI      *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_SPD      *-(An)
            CMP.B   #$7,D7
            BEQ     SUBTR_IMM_REG_S      *(xxx).W or (xxx).L or #<data>
            BRA     INVALID_EA

DEST_SUBTR_EA  
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 10 to get the mode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the mode

            CMP.B   #$0,D7          *mode is Dn
            BEQ     F_SUBTR_DN 
            CMP.B   #$1,D7          
            BEQ     SUBTR_ADDY_R_SNP
            CMP.B   #$2,D7             *mode is (An)
            BEQ     ADDY_R_SP       *(An) 
            CMP.B   #$3,D7
            BEQ     ADDY_R_SPI      *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_SPD      *-(An)
            CMP.B   #$7,D7
            BEQ     SUBTR_IMM_REG_D      *(xxx).W or (xxx).L
            BRA     INVALID_EA

F_SUBTR_DN
            CLR.L   D7
            MOVE.W  (A2),D7
            LSL.W   #4,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            LEA     MSG_D,A1
            MOVE.B  #14,D0
            TRAP    #15
            CLR.L   D1
            MOVE.L  #16,D2
            MOVE.W  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            BRA EXIT      

F_SUBTR_DN_SRC
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7   *get rid of first 6 bits of sub opcode
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            LEA     MSG_D,A1
            MOVE.B  #14,D0
            TRAP    #15
            CLR.L   D1
            MOVE.L  #16,D2
            MOVE.W  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            BRA EXIT              
            
SUBTR_PRINT_SRC_EA
            CLR.L   D7
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            
            CMP.B   #$0,D7
            BEQ     SOURCE_SUBTR_EA  *DEST ea is DN
            CMP.B   #$1,D7
            BEQ     SOURCE_SUBTR_EA  *DEST ea is DN
            CMP.B   #$2,D7
            BEQ     SOURCE_SUBTR_EA  *DEST ea is DN
            CMP.B   #$4,D7
            BEQ     F_SUBTR_DN   *SOURCE ea is DN
            CMP.B   #$5,D7
            BEQ     F_SUBTR_DN   *SOURCE ea is DN
            CMP.B   #$6,D7
            BEQ     F_SUBTR_DN   *SOURCE ea is DN
            BRA     INVALID_EA

SUBTR_PRINT_DEST_EA
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            
            CMP.B   #$0,D7
            BEQ     F_SUBTR_DN  *DEST ea is DN
            CMP.B   #$1,D7
            BEQ     F_SUBTR_DN  *DEST ea is DN
            CMP.B   #$2,D7
            BEQ     F_SUBTR_DN  *DEST ea is DN
            CMP.B   #$4,D7
            BEQ     DEST_SUBTR_EA   *source ea is DN
            CMP.B   #$5,D7
            BEQ     DEST_SUBTR_EA   *source ea is DN
            CMP.B   #$6,D7
            BEQ     DEST_SUBTR_EA   *source ea is DN
            BRA     INVALID_EA
            

SUBTR_IMM_REG_S *EA is source for subtract opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     W_ADDY  *word absolute address
            CMP.B   #$1,D7
            BEQ     L_ADDY  *long absolute address
            CMP.B   #$4,D7
            BEQ     SUBTR_IMM_DATA_S 
            
            BRA     INVALID_EA
            
SUBTR_IMM_DATA_S
            
            MOVE.W  (A4),D7
            LSL.W   #7,D7
            MOVE.L  #13,D3
            
            ADDA.L  #$2,A4      *increment A4 by a word 
            LSR.W   D3,D7       * SHIFT TO SIZE FIELD
            CMP.B   #$0,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$1,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$2,D7
            BEQ     IMM_DATA_SL
            CMP.B   #$4,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$5,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$6,D7
            BEQ     IMM_DATA_SL
            *if neither then it is an error
            BRA     INVALID_EA

SUBTR_ADDY_R_SNP    *An but cannot be byte for opcode size of subtr
            MOVE.W  (A4),D7
            LSL.W   #7,D7
            
            MOVE.L  #13,D3
            LSR.W   D3,D7
            CMP.B   #$1,D7
            BEQ     ADDY_R_SNP 
            CMP.B   #$2,D7
            BEQ     ADDY_R_SNP
            CMP.B   #$5,D7
            BEQ     ADDY_R_SNP 
            CMP.B   #$6,D7
            BEQ     ADDY_R_SNP
            *INVALID EA
            BRA     INVALID_EA

            
SUBTR_IMM_REG_D *EA is destination for subtract opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7   *shift D7 to left 13 to get the register
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     W_ADDY  *word absolute address
            CMP.B   #$1,D7
            BEQ     L_ADDY  *long absolute address
            BRA     INVALID_EA

*-----------------------------------------------------------
* Test to see if we have a matching AND op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_AND
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            MOVE.W (A2),D7
            LSL.W   #4,D7
            MOVE.L  #13,D3
            
            * PRINT AND
            LEA     MSG_AND,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  (A2),D7
            
            *GET SIZE SUB
            MOVEM.L A2/D7,-(SP)
            JSR     AND_SIZE_SUB
            MOVEM.L (SP)+,A2/D7
            
            * PRINT SPACE
            LEA     SPACE,A1        
            MOVE.B  #14,D0
            TRAP    #15
            
             *TEST GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_AND_PRINT_SRC_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print INVALID EA    
            BEQ     INVAL_EA_NO_RTS     
            
            * TEST PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_AND_PRINT_DEST_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print INVALID EA    
            BEQ     INVAL_EA_NO_RTS

            *GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     AND_PRINT_SRC_EA
            MOVEM.L (SP)+,A2/D7
            
             * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     AND_PRINT_DEST_EA
            MOVEM.L (SP)+,A2/D7

            MOVEA.L A4,A2           *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            CLR.L   D7

            BRA     INCREMENT       * Branch back up to main loop
  
*-----------------------------------------------------------
* Test to see if we have a matching LEA op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------    
MATCH_LEA
            
            MOVE.W  (A2),D7
            LSL.W  #7,D7
            
            MOVE.L  #13,D3
            LSR.W   D3,D7
            
            CMP.B   #$7,D7  *if bits 6,7,8 are not all 1 then this is invalid LEA
            BNE     NOOP    
            
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15

            LEA     MSG_LEA,A1      * move constant DATA to A1
            MOVE.B  #14,D0          * prepare to print string in (A1)
            TRAP    #15        
            
            LEA     SPACE,A1        * Byte displacement
            MOVE.B  #14,D0
            TRAP    #15
            
            *TEST GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_LEAS_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print 
                                        *INVALID_EA
            BEQ     INVAL_EA_NO_RTS
            
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     LEA_EAS
            MOVEM.L (SP)+,A2/D7
            
             * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT ADDRESS REGISTER
            MOVE.L  #13,D3
            LSL.W   #4,D7
            LSR.W   D3,D7           *get register bits 
            
            LEA     MSG_A,A1        *print An
            MOVE.B  #14,D0
            TRAP    #15
 
            MOVE.L  #16,D2
            MOVE.L  D7,D1           *print register number of An
            MOVE.B  #15,D0
            TRAP    #15

            MOVEA.L A4,A2           * move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            

            BRA     INCREMENT       * Branch back up to main loop
            
T_LEAS_EA
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7           *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7           *shift D7 to right 13 to get the register

            CMP.B   #$0,D7          *mode is Dn
            BEQ     INVALID_EA      *ea valid
            CMP.B   #$1,D7          
            BEQ     INVALID_EA
            CMP.B   #$2,D7          *mode is (An)
            BEQ     GOOD            *(An) 
            CMP.B   #$3,D7
            BEQ     INVALID_EA      *(An)+
            CMP.B   #$4,D7
            BEQ     INVALID_EA      *-(An)
            CMP.B   #$7,D7
            BEQ     T_LEAS_IMM_REG  *(xxx).W or (xxx).L or #<data>
            BRA     INVALID_EA

T_LEAS_IMM_REG 
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7
            LSR.W   D3,D7
            CMP.B   #$0,D7
            BEQ     GOOD            *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD            *long absolute address
            BRA     INVALID_EA  

LEA_EAS
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7           *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7           *shift D7 to right 13 to get the register

            CMP.B   #$0,D7          *mode is Dn
            BEQ     INVALID_EA      *ea valid
            CMP.B   #$1,D7          
            BEQ     INVALID_EA      *mode is An
            CMP.B   #$2,D7             
            BEQ     ADDY_R_SP       *(An)        
            CMP.B   #$3,D7
            BEQ     INVALID_EA      *(An)+
            CMP.B   #$4,D7
            BEQ     INVALID_EA      *-(An)
            CMP.B   #$7,D7
            BEQ     LEAS_IMM_REG    *(xxx).W or (xxx).L or #<data>
            BRA     INVALID_EA


LEAS_IMM_REG 
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7
            LSR.W   D3,D7
            CMP.B   #$0,D7
            BEQ     W_ADDY          *word absolute address
            CMP.B   #$1,D7
            BEQ     L_ADDY          *long absolute address
            BRA     INVALID_EA         


*-----------------------------------------------------------
* Test to see if we have a matching OR op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_OR
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            MOVE.W (A2),D7
            LSL.W   #4,D7
            MOVE.L  #13,D3
            
            * PRINT OR
            LEA     MSG_OR,A1  
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  (A2),D7
            
            *GET SIZE SUB
            MOVEM.L A2/D7,-(SP)
            JSR     AND_SIZE_SUB    *and same bit pattern as or
            MOVEM.L (SP)+,A2/D7
            
            * PRINT SPACE
            LEA     SPACE,A1  
            MOVE.B  #14,D0
            TRAP    #15
            
             *TEST GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_AND_PRINT_SRC_EA  *OR same bit pattern as AND
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print INVALID EA    

            BEQ     INVAL_EA_NO_RTS     
            
            * TEST PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_AND_PRINT_DEST_EA     *OR same bit pattern as AND
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6              *if D6 has $1 that means that the test failed and now print INVALID EA    
            BEQ     INVAL_EA_NO_RTS

            *GET SOURCE SUB
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     AND_PRINT_SRC_EA        *OR same bit pattern as AND
            MOVEM.L (SP)+,A2/D7
            
             * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     AND_PRINT_DEST_EA       *OR same bit pattern as AND
            MOVEM.L (SP)+,A2/D7

            MOVEA.L A4,A2                   *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2                  * Increase counter by long
            CLR.L   D7

            BRA     INCREMENT               * Branch back up to main loop

*-----------------------------------------------------------
* Test to see if we have a matching Bcc op code. If so
* print out the memory address and the op code.
*6E = BGT, 6F = BLE, 67=BEQ
*-----------------------------------------------------------
MATCH_BCC
            MOVE.W  (A2),D7
            ROR.W   #$8,D7          * Rotate to get condition code. Rotate 2 bytes.
                                    
            CMP.B   #$6E,D7
            BEQ     MATCH_BGT       * Match BGT
            
            CMP.B   #$6F,D7
            BEQ     MATCH_BLE       * Match BGT
            
            CMP.B   #$67,D7
            BEQ     MATCH_BEQ       * Match BEQ
            
            BRA     NOOP            * Othwise its an opcode we do not handle

MATCH_BGT                           * Matching BGT instruction
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT BGT
            LEA     MSG_BGT,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.W  (A2),D7
            CMP.B   #$00,D7         * Compare to see if we have a word displacement or byte
            BEQ     EA_BGT_WORD
            
            * PRINT SPACE
            LEA     SPACE,A1        * Byte displacement
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1     
            TRAP    #15
            
            * PRINT WORD
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
            
EA_BGT_WORD                         * Word displacement
            * PRINT SPACE
            ADDA.L  #$2,A2            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            * PRINT WORD
            CLR     D1
            MOVE.W  (A2),D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #$2,A2

            BRA     INCREMENT

MATCH_BLE                           * Match BLE instruction
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT BLE
            LEA     MSG_BLE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.W  (A2),D7
            CMP.B   #$00,D7         * Compare to see if we have a word displacement or byte
            BEQ     EA_BLE_WORD
            
            * PRINT SPACE
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            * PRINT WORD
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
            
EA_BLE_WORD                         * Word displacement
            * PRINT SPACE    
            ADDA.L  #$2,A2            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            * PRINT WORD
            CLR     D1
            MOVE.W  (A2),D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #$2,A2

            BRA     INCREMENT

MATCH_BEQ                           * Match BEQ instruction
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT BEQ
            LEA     MSG_BEQ,A1
            MOVE.B  #14,D0
            TRAP    #15
                        
            MOVE.W  (A2),D7
            CMP.B   #$00,D7         * Compare to see if we have a word displacement or byte
            BEQ     EA_BEQ_WORD
            
            * PRINT SPACE
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            * PRINT WORD
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #$2,A2
            
            BRA     INCREMENT
            
EA_BEQ_WORD                         * Word displacement
            * PRINT SPACE
            ADDA.L  #$2,A2            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            * PRINT WORD
            CLR     D1
            MOVE.W  (A2),D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #$2,A2

            BRA     INCREMENT

*-----------------------------------------------------------
* Test to see if we have a matching MOVE op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_MOVE
            MOVE.W  (A2),D7
            LSR.B   #6,D7       *shift value in D7 to the right by 6 bits
            CMPI.B  #$1,D7     *check if opcode is $1 if so it is MOVEA
            BEQ     MATCH_MOVEA

            MOVE.W  (A2),D7
            MOVE.W #12,D3
            
            * CHECK FOR NOOP
            LSR.W   D3,D7
            CMP.B   #$00,D7
            BEQ     NOOP
            
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            LEA     MSG_MOVE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT SIZE
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     MOVE_SIZE_SUB
            MOVEM.L (SP)+,A2/D7
            
            LEA     SM_SPACE,A1        * Byte displacement
            MOVE.B  #14,D0
            TRAP    #15
            
            CLR.L   D6
            *TEST MOVE SRC
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_PRINT_SRC_EA
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6
            BEQ     INVAL_EA_NO_RTS
            
            *TEST MOVE DEST
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_MOVE_MODE_DEST
            MOVEM.L (SP)+,A2/D7
            
            CMP.B   #$1,D6
            BEQ     INVAL_EA_NO_RTS
            
            * PRINT SRC MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     PRINT_SRC_EA
            MOVEM.L (SP)+,A2/D7
            
            * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT DEST MODE AND REGISTER
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     MOVE_MODE_DEST
            MOVEM.L (SP)+,A2/D7
               
            MOVEA.L A4,A2           *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long

            BRA     INCREMENT       * Branch back up to main loop
            
MATCH_MOVEA
            MOVE.W  (A2),D7
            MOVE.W #12,D3
            
            * CHECK IF NOOP
            LSR.W   D3,D7
            CMP.B   #$00,D7
            BEQ     NOOP
            CMP.B   #$1,D7
            BEQ     NOOP
            
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT MOVEA
            LEA     MSG_MOVEA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT SIZE
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     MOVEA_SIZE_SUB
            MOVEM.L (SP)+,A2/D7
            
            * PRINT SPACE
            LEA     SPACE,A1        
            MOVE.B  #14,D0
            TRAP    #15
            
            *TEST EA
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     T_ADDA_PRINT_SRC_EA    *test ea 
            MOVEM.L (SP)+,A2/D7
            
            * CHECK FOR INVALIDS
            CMP.B   #$1,D6
            BEQ     INVAL_EA_NO_RTS
            
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     ADDA_P_SRC_EA    *print ea 
            MOVEM.L (SP)+,A2/D7
            
            * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
                
            CLR.L   D7
            MOVE.W  (A2),D7
            
            * PRINT ADDRESS REGISTER
            MOVE.L  #13,D3
            LSL.W   #4,D7
            LSR.W   D3,D7   *get register bits 
            
            LEA     MSG_A,A1    *print An
            MOVE.B  #14,D0
            TRAP    #15
 
            MOVE.L  #16,D2
            MOVE.L  D7,D1       *print register number of An
            MOVE.B  #15,D0
            TRAP    #15

            MOVEA.L A4,A2           *move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            
            BRA     INCREMENT       * Branch back up to main loop

MATCH_MOVEM 
            MOVE.W  (A2),D7
            MOVE.W #12,D3
            
            * CHECK IF NOOP
            LSR.W   D3,D7
            CMP.B   #$00,D7
            BEQ     NOOP
            CMP.B   #$1,D7
            BEQ     NOOP
            
            * PRINT LINE NUMBER
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT MOVEM
            LEA     MSG_MOVEM,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT SIZE
            MOVE.W  (A2),D7
            MOVEM.L A2/D7,-(SP)
            JSR     MOVEM_SIZE_SUB
            MOVEM.L (SP)+,A2/D7
            
            * PRINT SPACE
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15            
            
            * UNFINISHED, PRINT INVALID EA FOR NOW
            LEA     MSG_INV_EA,A1
            MOVE.B  #14,D0
            TRAP    #15
          
            MOVEA.L A4,A2           * move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long

            BRA     INCREMENT       * Branch back up to main loop

*====================================================================
*            Convert Ascii into Hex  (1st and 2nd Address)
*====================================================================

*-----------------------------------------------------------
* Figure out the EA for a memory shift or rotate
*-----------------------------------------------------------
EA_MEM_SHIFT_ROTATE
            MOVE.W  (A2),D7
            AND.W   #$0038,D7     * Get the three bits needed to determine the mode
            CMP.W   #$0010,D7     * See if (An) mode
            BEQ     EA_MEM_ADDREG
            CMP.W   #$0018,D7     * See if post increment mode
            BEQ     EA_MEM_POST
            CMP.W   #$0020,D7     * See if pre decrement mode
            BEQ     EA_MEM_PRE
            CMP.W   #$0038,D7     * See if absolute address mode
            BEQ     EA_MEM_ABS
            
            * Otherwise invalid EA
            MOVEM.L A2/D7,-(SP)
            JSR     INVALID_EA_T2
            MOVEM.L (SP)+,A2/D7
            
            MOVEA.L A4,A2

            BRA     INCREMENT
            
   

EA_MEM_ADDREG                       * EA is an absolute address register
            MOVE.W  (A2),D7
            AND.W   #$0007,D7
            
            * PRINT SPACE
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            TRAP    #15
            
            * PRINT A
            LEA     MSG_A,A1
            TRAP    #15
            
            * PRINT EA
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #10,D2
            MOVE.B  #15,D0
            TRAP    #15  
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVEA.L A2,A4
            ADDA.L  #$2,A4

            BRA EXIT

EA_MEM_POST                         * EA is post increment
            MOVE.W  (A2),D7
            AND.W   #$0007,D7
            
            * PRINT SPACE
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            TRAP    #15
            
            * PRINT A
            LEA     MSG_A,A1
            TRAP    #15
            
            * PRINT EA
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #10,D2
            MOVE.B  #15,D0
            TRAP    #15  
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT PLUS
            LEA     PLUS,A1
            TRAP    #15
            
            MOVEA.L A2,A4
            ADDA.L  #$2,A4
             
            BRA EXIT
            
EA_MEM_PRE                              * EA is pre decrement
            MOVE.W  (A2),D7
            AND.W   #$0007,D7
            
            * PRINT SPACE
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT MINUS
            LEA     MINUS,A1
            TRAP    #15
            
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            TRAP    #15
            
            * PRINT A
            LEA     MSG_A,A1
            TRAP    #15
            
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #10,D2
            MOVE.B  #15,D0
            TRAP    #15  
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVEA.L A2,A4
            ADDA.L  #$2,A4


            BRA EXIT
            

EA_MEM_ABS                          * EA is immediate address
            MOVE.W  (A2),D7
            BTST.L  #$00,D7         *See if word or long addressing
            BNE     EA_MEM_ABS_LONG
            MOVEA.L A2,A4
            
            ADDA.L  #$2,A4          *grab the word
            
            * PRINT SPACE
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            * PRINT WORD
            CLR     D1
            MOVE.W  (A4),D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #2,A4           *increase counter
            
            BRA EXIT
            
EA_MEM_ABS_LONG                     * EA is immediate long addressing
            MOVEA.L A2,A4
            ADDA.L  #$2,A4          *grab the first word
            
            * PRINT SPACE
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15
            
            * PRINT FIRST WORD
            CLR     D1
            MOVE.W  (A4),D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT SECOND WORD
            ADDA.L  #2,A4           *grab the second word
            CLR     D1
            MOVE.W  (A4),D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            ADDA.L  #2,A4           *increase counter

            BRA EXIT
            

*-----------------------------------------------------------
* Figure out EA for register shifts and rotates
*-----------------------------------------------------------
EA_SHIFT_ROTATE
            *Getting EAs
            MOVE.W  (A2),D7       *Find if immediate data or register shift
            BTST.L  #$05,D7
            BNE     REG_SHIFT     *Shifting by a register (1)
                
            *IMMEDIATE DATA SHIFT (all 0s in count register = shift count of 8)
            * PRINT SPACE
            LEA     SPACE,A1      
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT HASH
            LEA     HASH_SIGN,A1
            TRAP    #15
            
            * PRINT HEX
            LEA     HEX_SIGN,A1
            TRAP    #15

            AND.W   #$0E00,D7     *Get shift count
            CMP.W   #$0000,D7     *edge case of shifting by 8
            BEQ     SHIFT_EIGHT
            LSR.W   #8,D7         *Prepare to print out shift count
            LSR.W   #1,D7
            
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #15,D0
            MOVE.B  #10,D2
            TRAP    #15
            
            * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     SHIFT_DEST
               
SHIFT_EIGHT                     * Data register shift by 8
            MOVE.B  #8,D1
            MOVE.B  #15,D0
            MOVE.B  #10,D2
            TRAP    #15
            
            * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     SHIFT_DEST 
            
REG_SHIFT                       * Register shift
            * PRINT D
            LEA     SPACE,A1      
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT D
            LEA     MSG_D,A1
            TRAP    #15
            AND.W   #$0E00,D7
            LSR.W   #8,D7         *Prepare to print out register number
            LSR.W   #1,D7
            
            * PRINT REG
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #15,D0
            MOVE.B  #10,D2
            TRAP    #15
            
            * PRINT COMMA
            LEA     MSG_COMMA,A1
            MOVE.B  #14,D0
            TRAP    #15
          
            
SHIFT_DEST                      * Get shift Dest
            MOVE.W  (A2),D7
            AND.W   #$0007,D7
            
            * PRINT D
            LEA     MSG_D,A1
            TRAP    #15
            
            * PRINT DEST
            CLR     D1
            MOVE.B  D7,D1
            MOVE.B  #15,D0
            MOVE.B  #10,D2
            TRAP    #15
            BRA     EXIT

AND_SIZE_SUB   *print the size of and
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.W  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            CMP.B   #$0,D7
            BEQ     BYTE
            CMP.B   #$1,D7
            BEQ     WORD
            CMP.B   #$2,D7
            BEQ     LONG
            CMP.B   #$4,D7
            BEQ     BYTE
            CMP.B   #$5,D7
            BEQ     WORD
            CMP.B   #$6,D7
            BEQ     LONG
            BRA     EXIT
            *ELSE BRANCH TO INVALID EA

T_SOURCE_AND_EA  
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register

            CMP.B   #$0,D7          *mode is Dn
            BEQ     GOOD
            CMP.B   #$1,D7          
            BEQ     INVALID_EA
            CMP.B   #$2,D7             *mode is (An)
            BEQ     GOOD       *(An) 
            CMP.B   #$3,D7
            BEQ     GOOD      *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD      *-(An)
            CMP.B   #$7,D7
            BEQ     T_AND_IMM_REG_S      *(xxx).W or (xxx).L or #<data>
            BRA     INVALID_EA

T_DEST_AND_EA  
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7   *shift D7 to right 10 to get the mode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the mode

            CMP.B   #$0,D7                  *mode is Dn
            BEQ     GOOD 
            CMP.B   #$1,D7          
            BEQ     INVALID_EA
            CMP.B   #$2,D7                  *mode is (An)
            BEQ     GOOD                    *(An) 
            CMP.B   #$3,D7
            BEQ     GOOD                    *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD                    *-(An)
            CMP.B   #$7,D7
            BEQ     T_AND_IMM_REG_D         *(xxx).W or (xxx).L
            BRA     INVALID_EA
            
T_AND_PRINT_SRC_EA
            CLR.L   D7
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of and opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            
            CMP.B   #$0,D7
            BEQ     T_SOURCE_AND_EA  *DEST ea is DN
            CMP.B   #$1,D7
            BEQ     T_SOURCE_AND_EA  *DEST ea is DN
            CMP.B   #$2,D7
            BEQ     T_SOURCE_AND_EA  *DEST ea is DN
            CMP.B   #$4,D7
            BEQ     GOOD        *SOURCE ea is DN
            CMP.B   #$5,D7
            BEQ     GOOD        *SOURCE ea is DN
            CMP.B   #$6,D7
            BEQ     GOOD        *SOURCE ea is DN
            BRA     INVALID_EA
            
            

T_AND_PRINT_DEST_EA
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            
            CMP.B   #$0,D7
            BEQ     GOOD    *DEST ea is DN
            CMP.B   #$1,D7
            BEQ     GOOD    *DEST ea is DN
            CMP.B   #$2,D7
            BEQ     GOOD    *DEST ea is DN
            CMP.B   #$4,D7
            BEQ     T_DEST_AND_EA   *source ea is DN
            CMP.B   #$5,D7
            BEQ     T_DEST_AND_EA   *source ea is DN
            CMP.B   #$6,D7
            BEQ     T_DEST_AND_EA   *source ea is DN
            BRA     INVALID_EA

T_AND_IMM_REG_S *EA is source for and opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     GOOD    *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD    *long absolute address
            CMP.B   #$4,D7
            BEQ     T_AND_IMM_DATA_S 
            
            BRA     INVALID_EA
            
T_AND_IMM_DATA_S
            
            MOVE.W  (A4),D7
            LSL.W   #7,D7
            MOVE.L  #13,D3
            
            LSR.W   D3,D7       * SHIFT TO SIZE FIELD
            CMP.B   #$0,D7
            BEQ     GOOD
            CMP.B   #$1,D7
            BEQ     GOOD
            CMP.B   #$2,D7
            BEQ     GOOD
            CMP.B   #$4,D7
            BEQ     GOOD
            CMP.B   #$5,D7
            BEQ     GOOD
            CMP.B   #$6,D7
            BEQ     GOOD
            *if neither then it is an error
            BRA     INVALID_EA

T_AND_ADDY_R_SNP    *An but cannot be byte for opcode size of and
            MOVE.W  (A4),D7
            LSL.W   #7,D7
            
            MOVE.L  #13,D3
            LSR.W   D3,D7
            CMP.B   #$1,D7
            BEQ     GOOD 
            CMP.B   #$2,D7
            BEQ     GOOD
            CMP.B   #$5,D7
            BEQ     GOOD
            CMP.B   #$6,D7
            BEQ     GOOD
            *INVALID EA
            BRA     INVALID_EA

            
T_AND_IMM_REG_D *EA is destination for and opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7               *shift D7 to left 13 to get the register
            LSR.W   D3,D7               *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     GOOD                *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD                *long absolute address
            BRA     INVALID_EA


SOURCE_AND_EA  
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7               *shift D7 to right 13 to get the register
            MOVE.L  #13,D3
            LSR.W   D3,D7               *shift D7 to right 13 to get the register

            CMP.B   #$0,D7              *mode is Dn
            BEQ     F_AND_DN 
            CMP.B   #$1,D7              *mode is An NOT ALLOWED
            BEQ     INVALID_EA
            CMP.B   #$2,D7              *mode is (An)
            BEQ     ADDY_R_SP           *(An) 
            CMP.B   #$3,D7
            BEQ     ADDY_R_SPI          *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_SPD          *-(An)
            CMP.B   #$7,D7
            BEQ     AND_IMM_REG_S       *(xxx).W or (xxx).L or #<data>
            BRA     INVALID_EA

DEST_AND_EA  
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #10,D3
            LSL.W   D3,D7               *shift D7 to right 10 to get the mode
            MOVE.L  #13,D3
            LSR.W   D3,D7               *shift D7 to right 13 to get the mode

            CMP.B   #$0,D7              *mode is Dn
            BEQ     F_AND_DN 
            CMP.B   #$1,D7          
            BEQ     INVALID_EA
            CMP.B   #$2,D7              *mode is (An)
            BEQ     ADDY_R_SP           *(An) 
            CMP.B   #$3,D7
            BEQ     ADDY_R_SPI          *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_SPD          *-(An)
            CMP.B   #$7,D7
            BEQ     AND_IMM_REG_D       *(xxx).W or (xxx).L
            BRA     INVALID_EA

F_AND_DN
            CLR.L   D7
            MOVE.W  (A2),D7
            LSL.W   #4,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            LEA     MSG_D,A1
            MOVE.B  #14,D0
            TRAP    #15
            CLR.L   D1
            MOVE.L  #16,D2
            MOVE.W  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            BRA EXIT      
            
            
AND_PRINT_SRC_EA
            CLR.L   D7
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            
            CMP.B   #$0,D7
            BEQ     SOURCE_AND_EA  *DEST ea is DN
            CMP.B   #$1,D7
            BEQ     SOURCE_AND_EA  *DEST ea is DN
            CMP.B   #$2,D7
            BEQ     SOURCE_AND_EA  *DEST ea is DN
            CMP.B   #$4,D7
            BEQ     F_AND_DN   *SOURCE ea is DN
            CMP.B   #$5,D7
            BEQ     F_AND_DN   *SOURCE ea is DN
            CMP.B   #$6,D7
            BEQ     F_AND_DN   *SOURCE ea is DN
            BRA     INVALID_EA

AND_PRINT_DEST_EA
            MOVE.W  (A2),D7
            LSL.W   #7,D7   *get rid of first 6 bits of sub opcode
            MOVE.L  #13,D3
            LSR.W   D3,D7   *shift D7 to right 13 to get the opmode
            
            CMP.B   #$0,D7
            BEQ     F_AND_DN  *DEST ea is DN
            CMP.B   #$1,D7
            BEQ     F_AND_DN  *DEST ea is DN
            CMP.B   #$2,D7
            BEQ     F_AND_DN  *DEST ea is DN
            CMP.B   #$4,D7
            BEQ     DEST_AND_EA   *source ea is DN
            CMP.B   #$5,D7
            BEQ     DEST_AND_EA   *source ea is DN
            CMP.B   #$6,D7
            BEQ     DEST_AND_EA   *source ea is DN
            BRA     INVALID_EA
            

AND_IMM_REG_S *EA is source for and opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7   *shift D7 to right 13 to get the register
            LSR.W   D3,D7   *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     W_ADDY  *word absolute address
            CMP.B   #$1,D7
            BEQ     L_ADDY  *long absolute address
            CMP.B   #$4,D7
            BEQ     AND_IMM_DATA_S 
            
            BRA     INVALID_EA
            
AND_IMM_DATA_S
            
            MOVE.W  (A4),D7
            LSL.W   #7,D7
            MOVE.L  #13,D3
            
            ADDA.L  #$2,A4      *increment A4 by a word 
            LSR.W   D3,D7       * SHIFT TO SIZE FIELD
            CMP.B   #$0,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$1,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$2,D7
            BEQ     IMM_DATA_SL
            CMP.B   #$4,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$5,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$6,D7
            BEQ     IMM_DATA_SL
            *if neither then it is an error
            BRA     INVALID_EA

AND_ADDY_R_SNP    *An but cannot be byte for opcode size of and
            MOVE.W  (A4),D7
            LSL.W   #7,D7
            
            MOVE.L  #13,D3
            LSR.W   D3,D7
            CMP.B   #$1,D7
            BEQ     ADDY_R_SNP 
            CMP.B   #$2,D7
            BEQ     ADDY_R_SNP
            CMP.B   #$5,D7
            BEQ     ADDY_R_SNP 
            CMP.B   #$6,D7
            BEQ     ADDY_R_SNP
            *INVALID EA
            BRA     INVALID_EA

            
AND_IMM_REG_D                           *EA is destination for and opcode
            MOVE.W  (A2),D7
            MOVE.L  #13,D3
            LSL.W   D3,D7               *shift D7 to left 13 to get the register
            LSR.W   D3,D7               *shift D7 to right 13 to get the register
            
            CMP.B   #$0,D7
            BEQ     W_ADDY              *word absolute address
            CMP.B   #$1,D7
            BEQ     L_ADDY              *long absolute address
            BRA     INVALID_EA
 
MOVE_SIZE_SUB                           * MOVE SIZE SUBROUTINE START
            * SHIFT TO SIZE FIELD
            MOVE.L  #12,D3
            LSR.W   D3,D7
            * RUN COMPARISONS
            CMP.B   #$1,D7
            BEQ     BYTE
            CMP.B   #$2,D7
            BEQ     LONG
            CMP.B   #$3,D7
            BEQ     WORD
            BRA     EXIT
            
MOVEA_SIZE_SUB                           * MOVE SIZE SUBROUTINE START
            * SHIFT TO SIZE FIELD
            MOVE.L  #12,D3
            LSR.W   D3,D7
            * RUN COMPARISONS
            CMP.B   #$2,D7
            BEQ     LONG
            CMP.B   #$3,D7
            BEQ     WORD
            BRA     EXIT
            
MOVEM_SIZE_SUB                           * MOVE SIZE SUBROUTINE START
            * SHIFT TO SIZE FIELD
            *MOVE.L  #12,D3
            LSL.B   #1,D7
            LSR.B   #7,D7
            * RUN COMPARISONS
            CMP.B   #$0,D7
            BEQ     WORD
            CMP.B   #$1,D7
            BEQ     LONG
            BRA     EXIT

T_PRINT_SRC_EA                          * MOVE MODE SRC SUBROUTINE START
            LSL.B   #2,D7               *get rid of destination mode bits
            LSR.B   #5,D7               *move source mode bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     GOOD      
            CMP.B   #$1,D7
            BEQ     GOOD                *An
            CMP.B   #$2,D7
            BEQ     GOOD                *(An)
            CMP.B   #$3,D7
            BEQ     GOOD                *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD                *-(An)
            CMP.B   #$7,D7
            BEQ     T_IMM_REG_S
            BRA     INVALID_EA 
 
T_MOVE_MODE_DEST                        * MOVE MODE DEST SUBROUTINE START
            LSR.W   #6,D7
            LSL.B   #5,D7 
            LSR.B   #5,D7               *dest mode now in first 3 bits of D7
            CMP.B   #$0,D7              *mode is Dn
            BEQ     GOOD
            CMP.B  #$1,D7               * mode is An NOT ALLOWED
            BEQ     INVALID_EA
            CMP.B   #$2,D7              *mode is (An)
            BEQ     GOOD                *(An) 
            CMP.B   #$3,D7
            BEQ     GOOD                *(An)+
            CMP.B   #$4,D7
            BEQ     GOOD                *-(An)
            CMP.B   #$7,D7
            BEQ     T_IMM_REG_D         *(xxx).W or (xxx).L or #<data>

            BRA     INVALID_EA  

T_IMM_REG_S     *SOURCE immediate data or address
            CLR.L     D7
            MOVE.W  (A2),D7             *get A2 data back to D7
            LSL.B   #5,D7               *get rid of destination mode bits and source mode bits
            LSR.B   #5,D7               *move source register bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     GOOD                *word absolute address
            CMP.B   #$1,D7
            BEQ     GOOD                *long absolute address
            CMP.B   #$4,D7
            BEQ     T_IMM_DATA_S
            BRA     INVALID_EA  

T_IMM_DATA_S  *SOURCE IMMEDIATE DATA
            *gotta go back to get the size and then get that amt of data
            *by incrementing a A2 by a word and then getting the next byte word or long
            *depending on the size of the move instruction
            
            MOVE.W  (A4),D7
            MOVE.L  #12,D3
            LSR.W   D3,D7       * SHIFT TO SIZE FIELD
            CMP.B   #$1,D7
            BEQ     GOOD
            CMP.B   #$2,D7
            BEQ     GOOD
            CMP.B   #$3,D7
            BEQ     GOOD
            *if neither then it is an error
            BRA     INVALID_EA

T_IMM_REG_D        *DESTINATION immediate data or address
            MOVE.W  (A2),D7         *get A2 data back to D7
            LSL.W   #4,D7   *get rid of size and opcode bits 
            CLR     D3
            MOVE.B  #13,D3
            
            LSR.W   D3,D7   *move destination register bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     GOOD  
            CMP.B   #$1,D7
            BEQ     GOOD
            
            BRA     INVALID_EA

GOOD        RTS
            
     
PRINT_SRC_EA                        * MOVE MODE SRC SUBROUTINE START
            LSL.B   #2,D7           *get rid of destination mode bits
            LSR.B   #5,D7           *move source mode bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     DATA_R_S 
            CMP.B   #$1,D7
            BEQ     ADDY_R_SNP      *An
            CMP.B   #$2,D7
            BEQ     ADDY_R_SP       *(An)
            CMP.B   #$3,D7
            BEQ     ADDY_R_SPI      *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_SPD      *-(An)
            CMP.B   #$7,D7
            BEQ     IMM_REG_S
            BRA     INVALID_EA  
   
MOVE_MODE_DEST                      * MOVE MODE DEST SUBROUTINE START
            LSR.W   #6,D7
            
            LSL.B   #5,D7 
            LSR.B   #5,D7           *dest mode now in first 3 bits of D7
            CMP.B   #$0,D7          *mode is Dn
            BEQ     DATA_R_D
            *CMP.B  #$1,D7          mode is An NOT ALLOWED
            CMP.B   #$2,D7             *mode is (An)
            BEQ     ADDY_R_DP       *(An) 
            CMP.B   #$3,D7
            BEQ     ADDY_R_DPI      *(An)+
            CMP.B   #$4,D7
            BEQ     ADDY_R_DPD      *-(An)
            CMP.B   #$7,D7
            BEQ     IMM_REG_D      *(xxx).W or (xxx).L or #<data>

            BRA     INVALID_EA    

IMM_REG_S     *SOURCE immediate data or address
            CLR.L     D7
            MOVE.W  (A2),D7         *get A2 data back to D7
            LSL.B   #5,D7   *get rid of destination mode bits and source mode bits
            LSR.B   #5,D7   *move source register bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     W_ADDY  *word absolute address
            CMP.B   #$1,D7
            BEQ     L_ADDY  *long absolute address
            CMP.B   #$4,D7
            BEQ     IMM_DATA_S
            BRA     INVALID_EA  

W_ADDY      
            LEA     HEX_SIGN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.W  (A4)+,D7    *increment A2 by a word, to get word of absolute data in A4
            CLR.L   D7          *get rid of opcode
            MOVE.W  (A4),D7     *put next word into D7
            
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            BRA EXIT     
            
L_ADDY
            LEA     HEX_SIGN,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  (A4)+,D7    *increment A2 by a word
            CLR.L   D7
            MOVE.L  (A4),D7     *put next word into D7
            ADDA.L  #$2,A4      *increment a word and then when we call INCREMENT routine
                                *(to be removed) it will increment another word to get the 
                                *address of the next opcode
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            BRA EXIT

IMM_DATA_S  *SOURCE IMMEDIATE DATA
            *gotta go back to get the size and then get that amt of data
            *by incrementing a A2 by a word and then getting the next byte word or long
            *depending on the size of the move instruction
            
            MOVE.W  (A4),D7
            MOVE.L  #12,D3
            ADDA.L  #$2,A4      *increment A4 by a word 
            LSR.W   D3,D7       * SHIFT TO SIZE FIELD
            CMP.B   #$1,D7
            BEQ     IMM_DATA_SW
            CMP.B   #$2,D7
            BEQ     IMM_DATA_SL
            CMP.B   #$3,D7
            BEQ     IMM_DATA_SW
            *if neither then it is an error
            BRA     INVALID_EA


IMM_DATA_SL *long of immediate data
            CLR.L   D1
            LEA     HASH_SIGN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     HEX_SIGN,A1
            TRAP    #15

            MOVE.L  (A4),D1             *move immediate data from A4 to D1
            ADDA.L  #$2,A4              *increment A4 by a word (will be incremented by another word in opcode method
            MOVE.L  #16,D2
            MOVE.B  #15,D0
            TRAP    #15                 *print immediate data
            BRA     EXIT 
            
IMM_DATA_SW *word of immediate data
            CLR.L   D1
            LEA     HASH_SIGN,A1
            MOVE.B  #14,D0
            TRAP    #15
            LEA     HEX_SIGN,A1
            TRAP    #15
            MOVE.W  (A4),D1             *move immediate data from A4 to D1
            MOVE.L  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            BRA     EXIT 
            
IMM_REG_D                               *DESTINATION immediate data or address
            MOVE.W  (A2),D7             *get A2 data back to D7
            LSL.W   #4,D7               *get rid of size and opcode bits 
            CLR     D3
            MOVE.B  #13,D3
            
            LSR.W   D3,D7               *move destination register bits to first 3 bits of D7 
            CMP.B   #$0,D7
            BEQ     W_ADDY
            CMP.B   #$1,D7
            BEQ     L_ADDY
            
            BRA     INVALID_EA

ADDY_R_SNP                              *SOURCE An
            * PRINT A
            LEA     MSG_A,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET SOURCE REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #13,D3              *prepare to move D7 by 13 bits to get source
            LSL.W  D3,D7
            LSR.W  D3,D7
            
            * PRINT SOURCE REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            BRA EXIT
            
ADDY_R_DNP                              *An register in bits 11,10,12 of  D7
            * PRINT A
            LEA     MSG_A,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET SOURCE REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            LSL.W   #4,D7
            MOVE.L  #13,D3              *prepare to move D7 by 13 bits to get source
            LSR.W  D3,D7
            
            * PRINT SOURCE REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            BRA EXIT    



ADDY_R_SP                               *SOURCE (An)
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT A
            LEA     MSG_A,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET SOURCE REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #13,D3              *prepare to move D7 by 13 bits to get source
            LSL.W  D3,D7
            LSR.W  D3,D7
            
            * PRINT SOURCE REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA EXIT     
            
ADDY_R_DP                               *DESTINATION (An)
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15

            * PRINT A
            LEA     MSG_A,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET DESTINATION REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #9,D3
            LSR.W   D3,D7
            LSL.B   #5,D7
            LSR.B   #5,D7
            
            * PRINT DESTINATION REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            BRA EXIT    
            
ADDY_R_SPI                              *SOURCE (An)+
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT A
            LEA     MSG_A,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET SOURCE REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #13,D3              *prepare to move D7 by 13 bits to get source
            LSL.W  D3,D7
            LSR.W  D3,D7
            
            * PRINT SOURCE REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT PLUS
            LEA     PLUS,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA EXIT     
            
ADDY_R_DPI                              *DESTINATION (An)+
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15

            * PRINT A
            LEA     MSG_A,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET DESTINATION REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #9,D3 
            LSR.W   D3,D7
            LSL.B   #5,D7
            LSR.B   #5,D7
            
            * PRINT DESTINATION REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT PLUS
            LEA     PLUS,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA EXIT    

ADDY_R_SPD                              *SOURCE -(An)
            * PRINT MINUS
            LEA     MINUS,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT A
            LEA     MSG_A,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET SOURCE REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #13,D3              *prepare to move D7 by 13 bits to get source
            LSL.W  D3,D7
            LSR.W  D3,D7
            
            * PRINT SOURCE REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA EXIT  
         
ADDY_R_DPD                              *DESTINATION -(An)
            * PRINT MINUS
            LEA     MINUS,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * PRINT LEFT PARENTHESIS
            LEA     L_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15

            * PRINT A
            LEA     MSG_A,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET DESTINATION REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #9,D3
            LSR.W   D3,D7
            LSL.B   #5,D7
            LSR.B   #5,D7
            
            * PRINT DESTINATION REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            
            * PRINT RIGHT PARENTHESIS
            LEA     R_PAREN,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA EXIT  
  
DATA_R_S                                *SOURCE Dn
            * PRINT D
            LEA     MSG_D,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET SOURCE REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #13,D3              *prepare to move D7 by 13 bits to get source register
            LSL.W  D3,D7
            LSR.W  D3,D7
            
            * PRINT SOURCE REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            BRA EXIT                    * MOVE MODE SRC SUBROUTINE END
            
DATA_R_D                                *DESTINATION Dn
            * PRINT D
            LEA     MSG_D,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            * GET REGISTER #
            CLR.L   D7
            MOVE.W  (A2),D7
            MOVE.L  #9,D3
            LSR.W   D3,D7
            LSL.B   #5,D7
            LSR.B   #5,D7
            
            * PRINT REGISTER
            MOVE.L  #16,D2
            MOVE.L  D7,D1
            MOVE.B  #15,D0
            TRAP    #15
            BRA EXIT                    * MOVE MODE DEST SUBROUTINE END
      
* Size matching for logical shifts, arithmetic shifts, and rotates (MEMORY)
MATCH_SIZE_MEMLAR
            BRA     WORD
            
* Size matching for logical shifts, arithmetic shifts, and rotates (REGISTER)
MATCH_SIZE_LAR

            CMP.W   #$0000,D7
            BEQ     BYTE
            
            CMP.W   #$0040,D7
            BEQ     WORD
            
            CMP.W   #$0080,D7
            BEQ     LONG
            
BYTE
            LEA     MSG_BYTE,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     EXIT

WORD
            LEA     MSG_WORD,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     EXIT

LONG
            LEA     MSG_LONG,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     EXIT

* HANDLE INVALID EA SUBROUTINES
INVALID_EA            
            MOVE.B  #$1,D6          
            BRA     EXIT
            
INVALID_EA_T2            
            LEA     SPACE,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     MSG_INV_EA,A1
            TRAP    #15
            
            MOVEA.L A2,A4
            ADDA.L  #$2,A4
            
            BRA     EXIT  
            
INVAL_EA_NO_RTS
           
            LEA     MSG_INV_EA,A1
            TRAP    #15
            
            MOVEA.L A4,A2           * move A3 to A2 since absolute address may have been used
            ADDA.L  #$2,A2          * Increase counter by long
            CLR.L   D7
            BRA     INCREMENT            

EXIT        
            RTS
              
*====================================================================
*            End of Program 
*====================================================================                

END         LEA     NEW_LOAD,A1     * Ask if user wants another memory image read 
            MOVE.B  #14,D0
            TRAP    #15
            
            
            MOVE.B  #5,D0
            TRAP    #15
            
            CMP.B   #$79,D1
            BEQ     PREP_FOR_START
            SIMHALT
                
PREP_FOR_START                      * If another memory location must be read prep to do so
            LEA     BLANK,A1
            MOVE.B  #14,D0
            TRAP    #15

            BRA     START
      
* ----------------ASCII Codes-----------------
CR          EQU     $0D             * ASCII code for Carriage Return
LF          EQU     $0A             * ASCII code for Line Feed

* -------Defined Messages and Variables-------
DIRECTIONS  DC.B    'Please Enter 6-Digit Hex Address Between 000000 & FFFFF0.',CR,LF,0
PROMPT1     DC.B    'Enter Startng Address: ',0
PROMPT2     DC.B    'Enter Ending Address: ',0
ERROR_MSG   DC.B    'Incorrect address input. Please re-enter.',CR,LF,0
ASK         DC.B    'Continue Reading File, Press Enter!',0
MSG_RTS     DC.B    '   RTS',0
MSG_JSR     DC.B    '   JSR',0
UNKNOWN     DC.B    '   DATA',0
MOVEMDATA   DC.B    ' DATA',0
ZERO        DC.B    '0',0
SPACE       DC.B    '   ',0
SM_SPACE    DC.B    '  ',0
T_SPACE     DC.B    ' ',0
MSG_LSL     DC.B    '   LSL',0
MSG_LSR     DC.B    '   LSR',0
MSG_ASL     DC.B    '   ASL',0
MSG_ASR     DC.B    '   ASR',0
MSG_NOT     DC.B    '   NOT',0
MSG_BRA     DC.B    '   BRA',0
MSG_BGT     DC.B    '   BGT',0
MSG_BLE     DC.B    '   BLE',0
MSG_BEQ     DC.B    '   BEQ',0
MSG_ROR     DC.B    '   ROR',0
MSG_ROL     DC.B    '   ROL',0
MSG_NOP     DC.B    '   NOP',0
MSG_MOVEM   DC.B    '   MOVEM',0
MSG_MOVEQ   DC.B    '   MOVEQ',0
MSG_MOVE    DC.B    '   MOVE',0
MSG_BYTE    DC.B    '.B ',0
MSG_WORD    DC.B    '.W ',0
MSG_LONG    DC.B    '.L ',0
MSG_COMMA   DC.B    ',',0
MSG_MOVEA   DC.B    '   MOVEA',0
MSG_ADD     DC.B    '   ADD',0
MSG_ADDA    DC.B    '   ADDA',0
MSG_ADDQ    DC.B    '   ADDQ',0
MSG_SUB     DC.B    '   SUB',0
MSG_LEA     DC.B    '   LEA',0
MSG_AND     DC.B    '   AND',0
MSG_OR      DC.B    '   OR',0
MSG_INV_EA  DC.B    'INVALID EA',0
MSG_D       DC.B    'D',0
MSG_A       DC.B    'A',0
L_PAREN     DC.B    '(',0
R_PAREN     DC.B    ')',0
HEX_SIGN    DC.B    '$',0
HASH_SIGN   DC.B    '#',0
PLUS        DC.B    '+',0
MINUS       DC.B    '-',0
BLANK       DC.B    ' ',CR,LF,0
BEGIN       DS.L    1
FIN         DS.L    1
NEW_LOAD    DC.B    'Another memory image? y or n',0

            END    START 










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
