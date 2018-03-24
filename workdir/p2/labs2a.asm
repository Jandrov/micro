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
	GMATRIX DB 1,0,0,0,1,1,0    ; Generation matrix
			DB 0,1,0,0,1,0,1
			DB 0,0,1,0,0,1,1
			DB 0,0,0,1,1,1,1
	INPUT DB 1,0,1,1  			; 4-bits binary chain
	ROWS DB 4					; Number of rows
	COLS DB 7					; Number of columns
	RESULT DB 7	dup (0)			; Variable where the result is stored
	MODUL DB 2
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
		MOV BP, 0 ; We initialize the loop counter
		
		; NO SE PUEDE MULTIPLICAR POR BP, SINO POR UNA CONSTANTE SOLO DENTRO DEL INDICE DE LA VARIABLE
MULT:	MOV AL, GMATRIX[0][0]
		MUL DL  
		DIV MODUL
		ADD RESULT[BP], AH
		MOV AL, GMATRIX[1][7*BP]
		MUL DL
		DIV MODUL
		ADD RESULT[BP], AH
		MOV AL, GMATRIX[2][7*BP]
		MUL DL
		DIV MODUL
		ADD RESULT[BP], AH
		MOV AL, GMATRIX[3][7*BP]
		MUL DL
		DIV MODUL
		ADD RESULT[BP], AH

		INC BP  ; We increase the loop counter
		CMP BP, WORD PTR COLS
		JNE MULT
		
		MOV AX, SEG RESULT
		MOV DX, OFFSET RESULT

	ENDP PARITY


	; We print the string
	INT 21h
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21h
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


