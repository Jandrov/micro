;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 1
; FILE: labs1b.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	COUNTER DB ?   ;We put "DB" because we want a single byte variable. ? indicates "non-initialized"
	GRAB DW 0CAFEh ;The 0 is needed to succeed on compilation
	TABLE100 DB 100 dup (?)  ;We want 100 bytes, so we write 100 db, dup is used to initialize to ? all of them at once.
	ERROR1 DB "Incorrect data. Try again" ;Each character is stored as an ASCII code, that are 1 byte long.
DATOS ENDS
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
	DB 40h DUP (0) ; initialization example, 64 bytes set to 0
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
	
	; PROGRAM START
	
	;FIRST INSTRUCTION
	MOV AL, ERROR1[5] 		;As we only need to move a byte(1 character), we can only use AH or AL instead of the whole AX register
							;Character addressing in a string (byte array) starts from 0, so the 6th one is in the 5th memory address.
	MOV TABLE100[53h], AL   ;As 53 > 15, we need to add an h at the end to know we are using hexadecimal system.
							;We are using direct addressing in here. As we are only moving a single byte, no pointers are needed
	
	;SECOND INSTRUCTION
	MOV AX, GRAB            		;GRAB is a word long, needs all the register AX
	MOV WORD PTR TABLE100[22h], AX  ;In this case, we want to write 2 bytes and we only have the direction of the first one. 
								    ;If we didn't use a word pointer, we would lose data from GRAB.
	
	;THIRD INSTRUCTION
	MOV COUNTER, AH 		;AX contains GRAB from the last instruction.
							;The most significative byte is in the higher part (AH) due to the endianess of 8086 processor.
	
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21h
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


