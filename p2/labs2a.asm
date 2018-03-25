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
	GMATRIX DB 1,0,0,0			; Generation matrix (by columns)
			DB 0,1,0,0
			DB 0,0,1,0
			DB 0,0,0,1
			DB 1,1,0,1
			DB 1,0,1,1
			DB 0,1,1,1
	INPUT DB 1,0,1,1  			; 4-bits binary chain
	ROWS DB 4					; Number of rows
	COLS DW 7					; Number of columns
	RESULT DB 7	dup (0)			; Variable where the result is stored
	MODUL DB 2
	TOTAL DW ?
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


	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21h
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


