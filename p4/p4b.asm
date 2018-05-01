;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 4
; FILE: p4b.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	

	CLEAR_SCREEN 	DB 	1BH,"[2","J$"
    STATEMENT DB "Please, write the message you want to encode: ", 13, 10, "$"

    ERRORCODE DB "Our driver is not correctly installed", 13, 10 , '$'
    PRINT1 DB "The message you are encoding is: ", '$'
    PRINT2 DB "The encoded message is: ", '$'
    PRINT3 DB "The decoded message is: ", '$'
    MESSAGE DB 100 dup (?)
    LINEJUMP DB 13,10, '$'

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
	MOV AX, 0
	MOV ES, AX


	; We have to check if our driver is correcly installed
	MOV CL, 0
	CALL CHECK_DRIVER
	CMP CL, 1
	JE DRIVER_OK



ERROR:

	; Printing an ERRORCODE
	MOV DX, OFFSET ERRORCODE
	MOV AH, 9
	INT 21H

	JMP JEND

DRIVER_OK:

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

	; Check out if the MESSAGE'S lenght is not null
	MOV BH, 0
	MOV BL, MESSAGE[1]
	CMP BL, 0
	JE JEND
	 
	; In order to print the message correctly, we have to write the $ right after the last character
	MOV MESSAGE[BX+2], '$'


	; PRINTS THE MESSAGE WRITTEN BY THE USER
	MOV AH,9	
	MOV DX, OFFSET PRINT1
	INT 21H
	
	MOV DX, OFFSET MESSAGE[2]
	INT 21H

	; Printing a line jump 
	MOV DX, OFFSET LINEJUMP
	INT 21H


	; CASE 1: ENCRYPTION
	MOV DX, OFFSET PRINT2
	INT 21H

	; We push DS in order to keep it: We might need it later
	push DS

	; We use message[2] because the first two bytes of the read message are the maximum size and the real size.
	; We dont want to codify them
	MOV DX, OFFSET MESSAGE[2]
	MOV BX, SEG MESSAGE
	MOV DS, BX
	
	; Calling of the interruption
	; 12h => ENCRYPTION
	MOV AH, 12h
	INT 55h

	; Restoring DS
	pop DS

	; Printing a line jump 
	MOV AH, 9h
	MOV DX, OFFSET LINEJUMP
	INT 21H


	; CASE 2: DECRYPTION
	MOV DX, OFFSET PRINT3
	INT 21H

	; We push DS in order to keep it: We might need it later
	push DS
	
	MOV DX, OFFSET MESSAGE[2]
	MOV AH, 13h

	; Calling of the interruption
	; 13h => DECRYPTION
	INT 55h

	POP DS

	
	; PROGRAM END
JEND:
    MOV AX, 4C00h
	INT 21h
INICIO ENDP


; This function writes on CL
; After the execution:
; CL = 0 if there isnt any driver at 55h
; CL = 1 if the installed driver is ours.
; CL = 2 if there is a driver, but it is not ours.
CHECK_DRIVER PROC NEAR

	PUSH DI SI AX

	; We have to check if there is a driver in 55h
	; If so, we would like to know if it is our driver
	MOV DI, ES:[ 55h*4 ]
	MOV SI, ES:[ 55h*4 +2 ]
	; We check if there are 0s in the interruption vector
	CMP DI, 0 	 
	JNE DRIVER_EXISTS
	CMP SI, 0
	JNE DRIVER_EXISTS
		
	; If we have reached this point it means there is no driver installed at all.
	MOV CL, 0		
	JMP END_CHECK

DRIVER_EXISTS:

	MOV CL, 0
	MOV AH, 08h
	INT 55h
	; If the interruption with AH = 08h changes CL from 0 to 1, then it should be our interruption.
	CMP CL, 1
	JE END_CHECK

	; The other possible case is: there is a driver, but it isnt the one we want.
	MOV CL, 2

END_CHECK:
	POP AX SI DI
	RET

CHECK_DRIVER ENDP


; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY FOR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


