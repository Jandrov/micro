;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 2
; FILE: dec2ASCII.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	INPUT DW 65534	; Variable to store the number to convert 
	STRING DB 6 dup (?) ; Variable to store the ASCII of the number
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

	MOV BX, INPUT

	; We implement the function to convert a 16-bit number to ASCII code
	CONVERTER PROC

		MOV AX, BX  ; We load the number to convert into AX
		MOV DX, 0 	; It is important to initialize DX to 0 
		MOV CX, 10000
		IDIV CX
		ADD AX, 30h
		MOV STRING, AL ; We write the ASCII code of the first digit

		MOV AX, DX  ; We load the remainder into AX to compute the next division
		MOV DX, 0 	; It is important to initialize DX to 0 
		MOV CX, 1000
		IDIV CX
		ADD AX, 30h
		MOV STRING[1], AL ; We write the ASCII code of the second digit

		MOV AX, DX  ; We load the remainder into AX to compute the next division
		MOV DX, 0 	; It is important to initialize DX to 0 
		MOV CX, 100
		IDIV CX
		ADD AX, 30h
		MOV STRING[2], AL ; We write the ASCII code of the third digit

		MOV AX, DX  ; We load the remainder into AX to compute the next division
		MOV DX, 0 	; It is important to initialize DX to 0 
		MOV CX, 10
		IDIV CX
		ADD AX, 30h
		MOV STRING[3], AL ; We write the ASCII code of the fourth digit

		ADD DX, 30h
		MOV STRING[4], DL; We write the ASCII code of the last digit

		MOV STRING[5], '$' ; We write the sentinel

		MOV AH, 09h
		MOV DX, OFFSET STRING

	ENDP CONVERTER


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

