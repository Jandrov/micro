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
	

	CLEAR_SCREEN 	DB 	1BH,"[2","J$"
    STATEMENT DB "Please, write the message you want to encode: ", 13, 10, "$"

    PRINT1 DB "The message you are encoding is: ", '$'
    MESSAGE DB 100 dup (?)


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


	; CLEARS THE SCREEN
	MOV AH,9	
	MOV DX, OFFSET CLEAR_SCREEN
	INT 21H

	; PRINTS THE MESSAGE REQUEST
	MOV DX, OFFSET STATEMENT		
	INT 21H

	; STORES THE MESSAGE IN MEMORY
	MOV AH,0AH			
	MOV DX, OFFSET MESSAGE
	MOV MESSAGE[0], 90		
	INT 21H

	MOV BH, 0
	MOV BL, MESSAGE[1]
	CMP BL, 0
	JE JEND
	 

	MOV MESSAGE[BX+2], '$'


	; PRINTS THE READ MESSAGE
	MOV AH,9	
	MOV DX, OFFSET PRINT1
	INT 21H

	MOV AH,9	
	MOV DX, OFFSET MESSAGE[2]
	INT 21H


	; We push DS in order to keep it for later
	push DS
	
	; We use message[2] because the first two bytes of the read message are the maximum size and the real size.
	; We dont want to codify them
	MOV BX, SEG MESSAGE
	MOV DS, BX
	
	; CASE 1: ENCRYPTION	
	MOV AH, 12h
	INT 55h

	; CASE 2: DECRYPTION
	MOV AH, 13h
	INT 55h

	; Restoring DS
	pop DS
	
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


