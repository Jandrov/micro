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
	GMATRIX DB 1,0,0,0			; Generation matrix (by columns)
			DB 0,1,0,0
			DB 0,0,1,0
			DB 0,0,0,1
			DB 1,1,0,1
			DB 1,0,1,1
			DB 0,1,1,1
    KEYBOARD DB 4 ?
	INPUT DB 1,0,1,1  			; 4-bits binary chain
	ROWS DB 4					; Number of rows
	COLS DW 7					; Number of columns
    MODUL DB 2
	TOTAL DW ?
	RESULT DB 7	dup (0)			; Variable where the result is stored


    TOPRINT1 DB "Input: "
    TOPRINT2 DB 34, ?, 32, ?, 32, ?, 32, ?, 34, 13, 10
    TOPRINT3 DB "Output: "
    TOPRINT4 DB 34, ?, 32, ?, 32, ?, 32, ?, 32, ?, 32, ?, 32, ?, 34, 13, 10
    TOPRINT5 DB "Computation: ", 13, 10
    TOPRINT6 DB "      | P1 | P2 | D1 | P4 | D2 | D3 | D4", 13, 10, 13, 10
    TOPRINT7 DB "Word  "
    TOPRINT8 DB "| ?  | ?  |    | ?  |    |    |    ", 13, 10, '$'
  

    SENTINEL DB '$'
	
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
    MOV DX[0]; 2
	INT 21h

    ; Converting ASCII characters to decimal

    MOV CL, KEYBOARD[1]

    

    
	; We load the 4-bits binary chain into DX:BX
    ; This is the way we have to pass arguments to parity function	
    MOV DX, WORD PTR INPUT
	MOV BX, WORD PTR INPUT[2]

	; We implement the function to compute the parity bits in an automatic way
	PARITY PROC

		MOV DI, 0 ; We initialize the index and loop counter
		MOV AX, COLS
		MUL ROWS
		MOV TOTAL, AX
MULT:	MOV CX, 0
		MOV AX, 0
		MOV AL, GMATRIX[DI][0]
		MUL DL  
		ADD CX, AX
		MOV AL, GMATRIX[DI][1]
		MUL DH
		ADD CX, AX
		MOV AL, GMATRIX[DI][2]
		MUL BL
		ADD CX, AX
		MOV AL, GMATRIX[DI][3]
		MUL BH
		ADD AX, CX
		DIV MODUL
		MOV RESULT[DI], AH

		INC DI
		CMP DI, COLS
		JNE MULT
		
		MOV AX, SEG RESULT
		MOV DX, OFFSET RESULT

	ENDP PARITY

    ;; Printing result with the correct format
    MOV DI, 1     
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

        MOV DI, 1     
    MOV AL, RESULT[4]
    ADD AL, 48
    MOV TOPRINT4[1], AL
    MOV AL, RESULT[5]
    ADD AL, 48
    MOV TOPRINT4[3], AL
    MOV AL, RESULT[0]
    ADD AL, 48
    MOV TOPRINT4[5], AL
    MOV AL, RESULT[6]
    ADD AL, 48
    MOV TOPRINT4[7], AL
    MOV AL, RESULT[1]
    ADD AL, 48
    MOV TOPRINT4[9], AL
    MOV AL, RESULT[2]
    ADD AL, 48
    MOV TOPRINT4[11], AL
    MOV AL, RESULT[3]
    ADD AL, 48
    MOV TOPRINT4[13], AL


    ; First row of the table , WORD

    MOV AL, RESULT[0]
    ADD AL, 48
    MOV TOPRINT8[13], AL
    MOV AL, RESULT[1]
    ADD AL, 48
    MOV TOPRINT8[23], AL
    MOV AL, RESULT[2]
    ADD AL, 48
    MOV TOPRINT8[28], AL
    MOV AL, RESULT[3]
    ADD AL, 48
    MOV TOPRINT8[33], AL


    MOV AX, 0900h
    MOV DX, OFFSET TOPRINT1
	INT 21h

    
    ; Second row of the table , P1

    MOV WORD PTR TOPRINT7, "P1"
    MOV TOPRINT7[2], 32
    MOV TOPRINT7[3], 32

    MOV TOPRINT8[7], 32
    MOV TOPRINT8[17], 32
    MOV TOPRINT8[28], 32

    MOV AL, RESULT[4]
    ADD AL, 48
    MOV TOPRINT8[2], AL
    MOV AL, RESULT[0]
    ADD AL, 48
    MOV TOPRINT8[13], AL
    MOV AL, RESULT[1]
    ADD AL, 48
    MOV TOPRINT8[23], AL

    MOV AX, 0900h
    MOV DX, OFFSET TOPRINT7
	INT 21h

    ; Third row of the table , P2
    
    MOV TOPRINT7[1], "2"

    MOV TOPRINT8[2], 32
    MOV TOPRINT8[23], 32

    MOV AL, RESULT[5]
    ADD AL, 48
    MOV TOPRINT8[7], AL
    MOV AL, RESULT[2]
    ADD AL, 48
    MOV TOPRINT8[28], AL

    MOV AX, 0900h
    MOV DX, OFFSET TOPRINT7
	INT 21h


    ; Fourth row of the table , P4

    MOV TOPRINT7[1], "4"

    MOV TOPRINT8[7], 32
    MOV TOPRINT8[13], 32

    
    MOV AL, RESULT[6]
    ADD AL, 48
    MOV TOPRINT8[17], AL
    MOV AL, RESULT[1]
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


