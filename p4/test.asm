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
	

    TESTTEST DB "$$$////IIIIIUUUU"

    ; Variable used to print an error message

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
	mov AL, TESTTEST[0]
	cmp AL, '$'
	jne FALLO
	jmp ACIERTO

FALLO: 
	mov DX, 0FFFFh
	jmp JEND

ACIERTO:
	
	mov DX, 0000h

	
	; PROGRAM END
JEND:
    MOV AX, 4C00h
	INT 21h
INICIO ENDP

; We implement the function to compute the parity bits in an automatic way


; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY FOR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


