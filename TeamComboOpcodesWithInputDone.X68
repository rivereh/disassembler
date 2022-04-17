*-----------------------------------------------------------
* Title      :
* Written by :
* Date:
* Description:
*-----------------------------------------------------------  
START       ORG     $2000

*-----------------------------------------------------------
* Initialize loop and places op codes inside the memory
* for testing
*-----------------------------------------------------------
TESTINGCODES
            MOVE.W  #$2000,D2
            MOVE.W  #$2040,D3
            MOVE.W  #$4E75,$2000    *RTS
            MOVE.W  #$4E71,$2002    *NOP
            MOVE.W  #$4E90,$2004   *JSR   (A0)
            MOVE.W  #$E30A,$2006    *LSL.B #$1,D2
            
            MOVE.W  #$E3D1,$2008    *LSL.W (A1)
            MOVE.W  #$E3AA,$200A    *LSL.L D1,D2
            MOVE.W  #$E222,$200C    *ASR.B D1,D2
            MOVE.W  #$E3D9,$200E    *LSL.W (A1)+
            MOVE.W  #$E2D1,$2010    *LSR.W  (A1)
            MOVE.W  #$E22A,$2012    *LSR.B D1,D2
            MOVE.W  #$E1D9,$2014    *ASL.W (A1)+
            MOVE.W  #$E362,$2016    *ASL.W D1,D2
            MOVE.W  #$4601,$2018    *NOT.B D1
            MOVE.W  #$60FE,$201A    *BRA TESTINGCODES
            MOVE.W  #$6E00,$201C    *BGT
            MOVE.W  #$6F00,$201E    *BLE
            MOVE.W  #$6700,$2020    *BEQ
            MOVE.W  #$E7D2,$2022    *ROL.W (A2)
            MOVE.W  #$E6D2,$2024    *ROR.W (A2)
            MOVE.W  #$E91C,$2026    *ROL.B  #$4,D4
            MOVE.W  #$E81C,$2028    *ROR.B  #$4,D4
            MOVE.W  #$1200,$202A    *MOVE.B D0,D1
            MOVE.W  #$D359,$202C    *ADD.W  D1,(A1)+
            MOVE.W  #$70FF,$202E    *MOVEQ  #$FF,D0
            MOVE.W  #$5A03,$2030    *ADDQ.B  #$5,D3
            
            LEA     $2030,A3
            MOVE.W  #$9401,(A3)+    *SUB.B  D1,D2
            MOVE.W  #$41F8,(A3)+    *LEA   $1234,A0 tbc
            MOVE.W  #$1234,(A3)+
            MOVE.W  #$8319,(A3)+    *OR.B   D1,(A1)+  
            MOVE.W  #$C351,(A3)+    *AND.W  D1,(A1)
            MOVE.W  #$3050,(A3)+    *MOVEA.W    (A0),A0
            MOVE.W  #$D4D9,(A3)+    *ADDA.W (A1)+,A2
            MOVE.W  #$FFCA,(A3)+    *RANDOM
            MOVE.L  D2,BEGIN
            MOVE.L  D3,FIN
            MOVEA.L BEGIN,A2
            *MOVEA.L FIN,A3

START_PRG
            MOVE.L  #$2, $400
            MOVE.L  #$4, $410 
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
   
            *SUBA.L  A1,A1           *need to clear A1 to make sure PROMPT1 variable is not changed
            MOVE.B  #2,D0           * Move 2 into D0
            TRAP    #15             * Read input from user and store it in A1
            
            MOVEA.L A1,A0           * Move our first number recieved into A0
            
            LEA     PROMPT2,A1      * Loads second address prompt into A1
            MOVE.B  #14,D0          * Move 14 in D0 to prompt user
            TRAP    #15             * Prompt user
            
            MOVE.B  #2,D0           * Move 2 into D0
            TRAP    #15             * Read input from user and store it in A1
            
            
            MOVE.B  #0,D4
            MOVE.B  #6,D5

* -----------Convert Ascii into Hex  (1st Address)-----------
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
            
*Input Checking
CHECK
            CMP.L   D2,D3
            BLT     START_PRG
                 
*------INIT MEM LOOP-------  
DONE            
            MOVE.L  D2,BEGIN        *put adsresses in variable in order to put in addr register
            MOVE.L  D3,FIN
            MOVEA.L  BEGIN,A2       *Move to address registers
            MOVEA.L  FIN,A3            

            
MAIN_LOOP
            CMPA.L  A3,A2           * Check are we done
            BGE     END             
            MOVE.W  (A2)+,D7
            *MOVE.W  #8,D3
            *LSL.L   D3,D7
            *MOVE.B (A2)+,D7
            CMP.W   #$4E75,D7       * Check if RTS instruction
            BEQ     MATCH_RTS
            
            CMP.W   #$4E71,D7       * Check if NOP instruction
            BEQ     MATCH_NOP
            
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
            BEQ     MATCH_SHIFT
            
            CMP.B   #$7,D7
            BEQ     MATCH_MOVEQ
            
            CMP.B   #$D,D7
            BEQ     MATCH_ADD
            
            CMP.B   #$5,D7
            BEQ     MATCH_ADDQ
            
            CMP.B   #$9,D7
            BEQ     MATCH_SUB
            
            CMP.B   #$C,D7
            BEQ     MATCH_AND
            
            CMP.B   #$4,D7
            BEQ     MATCH_LEA
            
            CMP.B   #$8,D7
            BEQ     MATCH_OR
            
            CMP.B   #$06,D7         * Check if any of Branch Instructions
            BEQ     MATCH_BCC
            
            LSR.W   #2,D7           *shift more to see 2 bits total
            CMP.B   #$0,D7
            BEQ     MATCH_MOVE
            
NOOP                                * NOOP opcode not found in current memory being read
            MOVE.L  A2,D1           * current memory being read that did not dissemble to readable opcode from specs
            MOVE.B  #16,D2      
            MOVE.B  #15,D0
            TRAP    #15             * output current memory address word
    
            LEA     UNKNOWN,A1      * move constant DATA to A1
            MOVE.B  #14,D0          * prepare to print string in (A1)
            TRAP    #15             * display string in (A1)
            
            LEA     SPACE,A1        
            TRAP    #15
    
            MOVE.B  #16,D2          * prepare to print number in D1 in base 16
            CLR.L   D1
            MOVEA.W A2,A4           * move the current address to A4 to be printed
            CLR.L   D5              * D5 to keep track of nibble program is reading   
            MOVE.B  (A4)+,D1        * prepare value at address  A4 to be printed
            MOVE.B  D1,D3
            LSR.B   #4,D3           * get left nibble of first byte
            CMPI.B  #$00,D3         * left nibble == 0?
            BEQ     PRINT0_B1
            MOVE.B  #15,D0      
            TRAP    #15             * print first byte
            ADDI.B  #2,D5           * we have printed one byte (2 nibbles)
            ADDA.L  #$2,A2          * Increase counter by long
    
OUTPUT     
            MOVE.B  (A4),D1         * move second byte to D1 
            MOVE.B  D1,D3       
            LSR.B   #4,D3           * get left most nibble of D1
            CMPI.B  #$00,D3         * is leftmost nibble == 0?
            BEQ     PRINT0_B1
            ADDI.B  #2,D5       
            MOVE.B  #15,D0
            TRAP    #15             * print out second byte
    
            BRA     INCREMENT
    
PRINT0_B1                           * print 0 to output window for first byte, only get here if first byte is 0
            ADDI.B  #1,D5
            LEA     ZERO,A1         * load zero to A1 to be printed
            MOVE.B  #14,D0
            TRAP    #15             * print 0 in A1
            MOVE.B  D1,D3
            LSL.B   #4,D3   
            LSR.B   #4,D3           *get value of right most nibble of byte in D1
            CMPI.B  #$00,D3         *is right most nibble == 0?
            BEQ     PRINT0_B2
            ADDI.B  #1,D5   
            MOVE.B  #15,D0
            TRAP    #15             *print out right most nibble of byte which left most nibble is 0
            CMPI.B  #4,D5           *have we read 4 nibbles? (2 bytes)
            BGE     INCREMENT       *have read 4 nibbles
            BRA     OUTPUT          *havent read 4 nibbles
    
PRINT0_B2                 *print 0 to output window for second byte
            ADDI.B  #1,D5
            LEA     ZERO,A1     *load zero to A1 to be printed
            MOVE.B  #14,D0
            TRAP    #15         *print out 0 for right most nibble
            CMPI.B  #4,D5       * have we read 4 nibbles ? (2 bytes)
            BGE     INCREMENT   *have read 4 nibbles
            BRA     OUTPUT      *have not read 4 nibbles
    
INCREMENT                           * Increment the loop and continue reading opcodes        
            ADDA.L  #$2,A2          * Increase counter by long
            
            LEA     BLANK,A1        * PRINT BLANK LINE to prepare for next line
            MOVE.B  #14,D0
            TRAP    #15

            BRA     MAIN_LOOP       * Branch back up to main loop
            
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
            BRA     INCREMENT

*-----------------------------------------------------------
* Test to see if we have a matching Memory Shift ASL op code. 
* If so print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_MEMASHIFTL
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ASL,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT
            
*-----------------------------------------------------------
* Test to see if we have a matching NOT op code. If so
* print out the memory address and the op code.
*-----------------------------------------------------------
MATCH_NOT
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_NOT,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT
            
            
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
            BRA     INCREMENT
                    
            
*-----------------------------------------------------------
* Test to see if we have a matching logical, arthemetic, or rotate
* shift. (Register shift)
*-----------------------------------------------------------
MATCH_SHIFT
            MOVE.W  (A2),D7         *Get full instruction again to figure out the type of shift or rotate
            LSR.W   #3,D7          
            
            AND.W   #$0003,D7
            
            CMP.B   #$03,D7
            BEQ     ROTATE
            
            CMP.B   #$01,D7
            BEQ     LSHIFT
            
            CMP.B   #$00,D7
            BEQ     ASHIFT
            *BTST.L  #$03,D7
            *BEQ     ASHIFT
            *BRA     LSHIFT
            
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
            BRA     INCREMENT

MATCH_MOVEQ
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_MOVEQ,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT
            
MATCH_ADD
            MOVE.W  (A2),D7
            LSR.B   #6,D7       *shift value in D7 to the right by 6 bits
            CMPI.B  #$3,D7     *check if opcode is $3 if so it is ADDA
            BEQ     MATCH_ADDA
            CMPI.B   #$7,D7     *check if opcode is $7 if so it is ADDA
            BEQ     MATCH_ADDA
            
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ADD,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT

MATCH_ADDA
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ADDA,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT
MATCH_ADDQ
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_ADDQ,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT

MATCH_SUB
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_SUB,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT
MATCH_LEA
*looking to branch based on the first 3 bits. if 0 then get next 2 bytes, if 1 then get next 4 bytes 
*rn A2 and A3 are holding sensitive data 
*
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_LEA,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            
            BRA     INCREMENT

MATCH_AND  
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_AND,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT
MATCH_OR
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_OR,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT            
*-----------------------------------------------------------
* Test to see if we have a matching Bcc op code. If so
* print out the memory address and the op code.
*6E = BGT, 6F = BLE, 67=BEQ
*-----------------------------------------------------------
MATCH_BCC
            MOVE.W  (A2),D7
            ROR.W   #$8,D7          * Rotate to get condition code. Rotate 2 bytes.
                                    * MAKE SURE TO ROTATE BACK IN SEPERATE BRANCHES
            CMP.B   #$6E,D7
            BEQ     MATCH_BGT
            
            CMP.B   #$6F,D7
            BEQ     MATCH_BLE
            
            CMP.B   #$67,D7
            BEQ     MATCH_BEQ

MATCH_BGT
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_BGT,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT 

MATCH_BLE
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_BLE,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT 

MATCH_BEQ
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_BEQ,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT 

MATCH_MOVE
            MOVE.W  (A2),D7
            LSR.B   #6,D7       *shift value in D7 to the right by 6 bits
            CMPI.B  #$1,D7     *check if opcode is $1 if so it is MOVEA
            BEQ     MATCH_MOVEA

            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_MOVE,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT

MATCH_MOVEA
            MOVE.L  A2,D1
            MOVE.B  #16,D2
            MOVE.B  #15,D0
            TRAP    #15
            
            LEA     MSG_MOVEA,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INCREMENT
            


END            SIMHALT
            
            
* ----------------ASCII Codes-----------------
CR          EQU     $0D             * ASCII code for Carriage Return
LF          EQU     $0A             * ASCII code for Line Feed

* -------Defined Messages and Variables-------
DIRECTIONS  DC.B    'Please Enter 6-Digit Hex Address Between 000000 & FFFFF0.',CR,LF,0
PROMPT1     DC.B    'Enter Startng Address: ',0
PROMPT2     DC.B    'Enter Ending Address: ',0
MSG_RTS     DC.B    '   RTS',0
MSG_JSR     DC.B    '   JSR',0
UNKNOWN     DC.B    '   DATA',0
ZERO        DC.B    '0',0
SPACE       DC.B    '   ',0
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
MSG_MOVEQ   DC.B    '   MOVEQ',0
MSG_MOVE    DC.B    '   MOVE',0
MSG_MOVEA   DC.B    '   MOVEA',0
MSG_ADD     DC.B    '   ADD',0
MSG_ADDA    DC.B    '   ADDA',0
MSG_ADDQ    DC.B    '   ADDQ',0
MSG_SUB     DC.B    '   SUB',0
MSG_LEA     DC.B    '   LEA',0
MSG_AND     DC.B    '   AND',0
MSG_OR      DC.B    '   OR',0
BLANK       DC.B    ' ',CR,LF,0
BEGIN       DS.L    1
FIN         DS.L    1


            END    START 














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
