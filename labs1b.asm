;**************************************************************************
; ASSEMBLY CODE STRUCTURE EXAMPLE. MBS 2018
;
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	COUNTER DB ?
	GRAB DW 0CAFEh
	TABLE100 DB 100 dup (?)
	ERROR1 DB "Incorrect data. Try again"
DATOS ENDS
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) ; initialization example, 64 bytes set to 0
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
	RESULT DW 0,0 ; initialization example. 2 WORDS (4 BYTES)
EXTRA ENDS
;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC
	; INITIALIZE THE SEGMENT REGISTERS
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, EXTRA
	MOV ES, AX
	;
	; PROGRAM START
	NEAR DW ERROR1
	;; falta acabar
	
	
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO