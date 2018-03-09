;**************************************************************************
; ASSEMBLY CODE STRUCTURE EXAMPLE. MBS 2018
;
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
;**************************************************************************

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
ASSUME CS: CODE, ES: EXTRA, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC
	; INITIALIZE THE SEGMENT REGISTERS
	MOV AX, 0511h
	MOV DS, AX
	MOV BX, 0211h
	MOV DI, 1010h
	
	; PROGRAM START
	TEST1 DW 0CAFEh
	MOV AX, TEST1
	MOV DS:[1234H], AX
	MOV DS:[BX], AX
	MOV AX, 0FFh
	MOV DS:[DI], AX
	;Direccion 1, expected value = 06344h
	MOV AL, DS:[1234h]  ; Expected AL <= ??FEh, because we had stored FEh on 06344h
	;Direccion 2, expected value = 05321h
	MOV AX, DS:[BX]  ; Expected AX <= CAFEh, because we had stored CAFEh on 05321h
	;Direccion 3, expected value = 06120h
	MOV DS:[DI], AL  ; Expected [DI] <= FEh , because FFh is overwritten
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21H
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO

;IMPORTANT COMMENT:
;This program doesnt work in a proper way because it is accessing to a memory segment reserved to BIOS.
