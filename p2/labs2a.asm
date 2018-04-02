;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 2
; FILE: labs2a.asm
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
    
	INPUT DB 1,0,1,1  			; 4-bits binary chain
	ROWS DB 4					; Number of rows
	COLS DW 7					; Number of columns
    BASE DB 2					; We work in binary (base=2)

    ; Variable to save the result of the product
	RESULT DB 7	dup (0)			; Variable where the result is stored in the function


    ; Variables to print the result in the required format
    TOPRINT1 DB "Input: "
    TOPRINT2 DB 34, ?, 32, ?, 32, ?, 32, ?, 34, 13, 10
    TOPRINT3 DB "Output: "
    TOPRINT4 DB 34, ?, 32, ?, 32, ?, 32, ?, 32, ?, 32, ?, 32, ?, 34, 13, 10
    TOPRINT5 DB "Computation: ", 13, 10
    TOPRINT6 DB "      | P1 | P2 | D1 | P4 | D2 | D3 | D4", 13, 10, 13, 10
    TOPRINT7 DB "Word  "
    TOPRINT8 DB "| ?  | ?  |    | ?  |    |    |    ", 13, 10, '$'
	
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

	; We load the 4-bits binary chain into DX:BX
	MOV DX, WORD PTR INPUT
	MOV BX, WORD PTR INPUT[2]

	; We implement the function to compute the parity bits in an automatic way
	PARITY PROC

		MOV DI, 0 ; We initialize the RESULT index and also the loop counter
MULT:	MOV CX, 0 ; We initialize the accumulator of the products
		; These 3 lines are to compute the column we are multiplying
		MOV AX, DI
		MUL ROWS
		MOV BP, AX
		
		MOV SI, 0  				; We initialize the index inside the column
		MOV AL, GMATRIX[BP][SI] ; We load the matrix element (using BASED-INDEX ADDRESSING)
		MUL DL  				; First bit of the vector is stored in DL
		ADD CX, AX 				; The result of the mult is stored in AX, so we add it to the accumulator 
		INC SI  				; We increase the index inside the column

		; We repeat the structure of the previous process
		MOV AL, GMATRIX[BP][SI]
		MUL DH  				; Second bit of the vector is stored in DH
		ADD CX, AX
		INC SI
		MOV AL, GMATRIX[BP][SI]
		MUL BL  				; Third bit of the vector is stored in BL
		ADD CX, AX
		INC SI
		MOV AL, GMATRIX[BP][SI]
		MUL BH  				; Fourth bit of the vector is stored in BH

		; We store the last accumulation into AX in order to calculate the modul base 2 (we want binary bits)
		ADD AX, CX
		DIV BASE
		MOV RESULT[DI], AH 		; We store the result into RESULT variable

		INC DI 					; We increase the loop counter
		CMP DI, COLS 			; We have to do as many iterations as the number of columns
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
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21h
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY FOR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


