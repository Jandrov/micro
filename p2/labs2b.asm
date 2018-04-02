;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 2
; FILE: labs2b.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	
    ; Variables to do the matrix product
    GMATRIX DB 1,0,0,0			; Generation matrix (by columns)
			DB 0,1,0,0
			DB 0,0,1,0
			DB 0,0,0,1
			DB 1,1,0,1
			DB 1,0,1,1
			DB 0,1,1,1
    ; We store the matrix by columns because it is more efficient when we want to access memory
    ; to do the product. We learnt that last semester in Computer Architecture.
    
    ROWS DB 4					; Number of rows
	COLS DW 7					; Number of columns
    BASE DB 2                   ; We work in binary (base=2)

    ; Variable to save the result of the product
	RESULT DB 7	dup (0)			; Variable where the result is stored


    ; Variables to read and save the input from keyboard
    KEYBOARD DB 5 dup(?) 
    WRITTEN DW 0 
	INPUT DB 0,0,0,0  			; 4-bits binary chain
	
    ; Variables to print the result in the required format
    ; This can be a little messy, didnt find a way to make it cleaner.
    ; To understand it, it may be useful to know:
    ; 34 is " in ASCII
    ; 32 is ' ' in ASCII
    ; 13, 10 is a sequence that basically indicates end of line in ASCII

    TOPRINT1 DB "Input: "
    TOPRINT2 DB 34, ?, 32, ?, 32, ?, 32, ?, 34, 13, 10
    TOPRINT3 DB "Output: "
    TOPRINT4 DB 34, ?, 32, ?, 32, ?, 32, ?, 32, ?, 32, ?, 32, ?, 34, 13, 10
    TOPRINT5 DB "Computation: ", 13, 10
    TOPRINT6 DB "      | P1 | P2 | D1 | P4 | D2 | D3 | D4", 13, 10, 13, 10
    TOPRINT7 DB "Word  "
    TOPRINT8 DB "| ?  | ?  |    | ?  |    |    |    ", 13, 10, '$'

    ; Variable used to print an error message
    ERRORSTRING DB "The number must be between 0 and 15. Try again.",13,10, '$'

DATOS ENDS
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
	DB 40h DUP (0) ; initialization example, 64 bytes set to 0
PILA ENDS


;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC
	; INITIALIZE THE SEGMENT REGISTERS
	MOV AX, DATOS
	MOV DS, AX
	
	; PROGRAM START

    ; Interruption to read from keyboard
    MOV AH, 0Ah
    MOV DX, OFFSET KEYBOARD
    MOV KEYBOARD[0],  3 ; It is very important to store here the number of characters we want to read as maximum.
                        ; In this case it is 3 because we want at most 2 digits and the "enter" character.
	INT 21h

    MOV AL, KEYBOARD[1] ; The second byte of the variable used in the interruption stores the real number of read bytes.
                        ; As the procedure differs if there is only a digit or there are two, this is important
    MOV AH , 0
    MOV WRITTEN, AX     ; We store it in a 16 bit register to be able to make some comparisons with other 16-bit registers


; FIRST ERROR CONTROL: If no data was read, we print the error message and the program ends.

    CMP WRITTEN, 0
    JNZ CONT1
    JMP ERROR

; In this loop, we are reading the input ASCII codes of the characters and also converting them into decimal numbers 
; before writing them into INPUT variable.
; Actually, INPUT is used as an auxiliar variable here

CONT1:
    MOV DI, 0

READ:             
    MOV AL, KEYBOARD[DI+2]
    SUB AL, 48
    MOV INPUT[DI], AL    
 
    INC DI
    CMP DI, WRITTEN
    JNZ READ

    ; Now, it is neccesarry to convert the whole number to a decimal base number.
    ; Remember before now we were working with its digits separately


    CMP WRITTEN, 1
    JNZ TWOCHARACTERS

    ; If there is only a digit, one instruction is enough
    MOV AL, INPUT[0]
    JMP JOINT

TWOCHARACTERS:
    MOV AL, INPUT[0]
    MOV AH, 0
    MOV BX, 10
    MUL BX
    MOV BL, INPUT[1]
    ADD AL, BL

JOINT: 
    ; AL contains the decimal number from now on. 
    ; Error comparisons



    ; ERROR CONTROL 2: Checking out if the given number is inside the  establoshed bounds

    CMP AL, 15 ; We first check if it is bigger than 15
    JG ERRORAUX

    CMP AL, 0   ; Then, if it is lower than 0
    JL ERRORAUX

    JMP CONT2

ERRORAUX: ; If any of the conditions above were True, the error message is printed and the program ends
    JMP ERROR

CONT2: 

    ; After getting the number in decimal, we want to get its binary digits separated; as in exercise 2
    ; To do that, we use the division method explained in the given PDF.

    MOV DL, BASE
    MOV DI, 3

    MOV WORD PTR INPUT, 0
    MOV WORD PTR INPUT[2], 0

ITERATION: 
    MOV AH, 0
    DIV DL
    ; The remainder is stored in AH and its the binary digit we want in each iteration
    ; The quotient is stored in AL, it is useful to the next operation and to check the break condition
    MOV INPUT[DI], AH
    DEC DI
    CMP AL, 0
    JNZ ITERATION


	; We load the 4-bits binary chain into DX:BX
    ; This is the way we have to pass arguments to parity procedure
    MOV DX, WORD PTR INPUT
	MOV BX, WORD PTR INPUT[2]

	; We implement the function to compute the parity bits in an automatic way
    PARITY PROC

        MOV DI, 0 ; We initialize the RESULT index and also the loop counter
MULT:   MOV CX, 0 ; We initialize the accumulator of the products
        ; These 3 lines are to compute the column we are multiplying
        MOV AX, DI
        MUL ROWS
        MOV BP, AX
        
        MOV SI, 0               ; We initialize the index inside the column
        MOV AL, GMATRIX[BP][SI] ; We load the matrix element (using BASED-INDEX ADDRESSING)
        MUL DL                  ; First bit of the vector is stored in DL
        ADD CX, AX              ; The result of the mult is stored in AX, so we add it to the accumulator 
        INC SI                  ; We increase the index inside the column

        ; We repeat the structure of the previous process
        MOV AL, GMATRIX[BP][SI]
        MUL DH                  ; Second bit of the vector is stored in DH
        ADD CX, AX
        INC SI
        MOV AL, GMATRIX[BP][SI]
        MUL BL                  ; Third bit of the vector is stored in BL
        ADD CX, AX
        INC SI
        MOV AL, GMATRIX[BP][SI]
        MUL BH                  ; Fourth bit of the vector is stored in BH

        ; We store the last accumulation into AX in order to calculate the modul base 2 (we want binary bits)
        ADD AX, CX
        DIV BASE
        MOV RESULT[DI], AH      ; We store the result into RESULT variable

        INC DI                  ; We increase the loop counter
        CMP DI, COLS            ; We have to do as many iterations as the number of columns
        JNE MULT
        
        ; We return the memory address of the first position of the result
        MOV AX, OFFSET RESULT
        MOV DX, SEG RESULT

    ENDP PARITY

    ; Despite it is not necessary because we could access directly to RESULT variable, we will try to do it
    ; using the function return (SEGMENT:OFFSET in DX:AX)
    ; These assignments are done to know where the return of the function (RESULT) is

    MOV BX, AX
    MOV ES, DX
 
    ; Printing result with the correct format
    ; As said above, this is a little mess.
    ; Basically, we are writing the data we need in the memory positions we want inside some "standard" text strings. 
    
    ; First print: INPUT + OUTPUT + COMPUTATION + TABLEHEADER + FIRST ROW (WORD)

    ; Filling INPUT DATA  
    MOV AL, INPUT[0]
    ADD AL, 48
    MOV TOPRINT2[1], AL
    MOV AL, INPUT[1]
    ADD AL, 48
    MOV TOPRINT2[3], AL
    MOV AL, INPUT[2]
    ADD AL, 48
    MOV TOPRINT2[5], AL
    MOV AL, INPUT[3]
    ADD AL, 48
    MOV TOPRINT2[7], AL
    
    ; Filling OUTPUT DATA
    MOV AL, ES:[BX+4]  ; Here we could access RESULT directly, but we prefer 
    ADD AL, 48
    MOV TOPRINT4[1], AL
    MOV AL, ES:[BX+5]
    ADD AL, 48
    MOV TOPRINT4[3], AL
    MOV AL, ES:[BX]
    ADD AL, 48
    MOV TOPRINT4[5], AL
    MOV AL, ES:[BX+6]
    ADD AL, 48
    MOV TOPRINT4[7], AL
    MOV AL, ES:[BX+1]
    ADD AL, 48
    MOV TOPRINT4[9], AL
    MOV AL, ES:[BX+2]
    ADD AL, 48
    MOV TOPRINT4[11], AL
    MOV AL, ES:[BX+3]
    ADD AL, 48
    MOV TOPRINT4[13], AL

    ; Computation and header are static ASCII chains for us so they dont need any special assignment 

    ; First row of the table , WORD (This value was assigned by default, for the next rows we will have to change it) 
    
    ; Only the needed bytes are written. 
    ; Despite 13, 23, 28 or 33 seem to by random numbers, they are result of counting bytes in the string to write in the correct position.

    MOV AL, ES:[BX]
    ADD AL, 48
    MOV TOPRINT8[13], AL
    MOV AL, ES:[BX+1]
    ADD AL, 48
    MOV TOPRINT8[23], AL
    MOV AL, ES:[BX+2]
    ADD AL, 48
    MOV TOPRINT8[28], AL
    MOV AL, ES:[BX+3]
    ADD AL, 48
    MOV TOPRINT8[33], AL

    MOV AX, 0900h
    MOV DX, OFFSET TOPRINT1
	INT 21h

    
    ; Second row of the table , P1

    ; We write the word we want now
    ; As the desired output is P1, we shall write it backwards to have the characters sorted in memory.
    MOV WORD PTR TOPRINT7, "1P"
    MOV TOPRINT7[2], 32
    MOV TOPRINT7[3], 32

    ; This lines write blankspaces where we dont want data to appear
    MOV TOPRINT8[7], 32
    MOV TOPRINT8[17], 32
    MOV TOPRINT8[28], 32

    MOV AL, ES:[BX+4]
    ADD AL, 48
    MOV TOPRINT8[2], AL
    MOV AL, ES:[BX]
    ADD AL, 48
    MOV TOPRINT8[13], AL
    MOV AL, ES:[BX+1]
    ADD AL, 48
    MOV TOPRINT8[23], AL

    MOV AX, 0900h
    MOV DX, OFFSET TOPRINT7
	INT 21h

    ; Third row of the table , P2

    ; Now we only need to write the 2 over the 1 in the P1 written before    
    MOV TOPRINT7[1], "2"

    ; This lines write blankspaces where we dont want data to appear
    MOV TOPRINT8[2], 32
    MOV TOPRINT8[23], 32

    MOV AL, ES:[BX+5]
    ADD AL, 48
    MOV TOPRINT8[7], AL
    MOV AL, ES:[BX+2]
    ADD AL, 48
    MOV TOPRINT8[28], AL

    MOV AX, 0900h
    MOV DX, OFFSET TOPRINT7
	INT 21h


    ; Fourth row of the table , P4

    ; Now we only need to write the 4 over the 2 in the P2 written before
    MOV TOPRINT7[1], "4"

    ; This lines write blankspaces where we dont want data to appear
    MOV TOPRINT8[7], 32
    MOV TOPRINT8[13], 32

    
    MOV AL, ES:[BX+6]
    ADD AL, 48
    MOV TOPRINT8[17], AL
    MOV AL, ES:[BX+1]
    ADD AL, 48
    MOV TOPRINT8[23], AL


    MOV AX, 0900h
    MOV DX, OFFSET TOPRINT7
	INT 21h
    
    ; If this section was reached, the program run successfully.

    JMP JEND


; This section prints an error message on screen. If the program runs OK, this lines will be skipped
ERROR: 
    
    MOV AX, 0900h
    MOV DX, OFFSET ERRORSTRING
	INT 21h
    JMP JEND    

	
	; PROGRAM END
JEND:
    MOV AX, 4C00h
	INT 21h
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY FOR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


