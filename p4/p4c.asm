;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 4
; FILE: p4c.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************


; DATA SEGMENT DEFINITION
DATOS SEGMENT
	; Functionality variables
	COD_DEC DB 0  	; It is 0 if we want to ENCRYPT the strings we type
			   		; Its value is 1 if we want to DECRYPT the strings we type
    MESSAGE DB 100 dup (?)

	; Variables to print
	CLEAR_SCREEN 	DB 	1BH, "[2","J$"
	ERRORCODE DB  "The driver you are trying to use is not correctly installed.", 13, 10, "Please, try running P4A.COM /I before", 13, 10, '$'
	MODESTRING DB "The current mode is: " , '$'
	CODSTRING DB "COD", 13, 10 , '$'
	DECSTRING DB "DEC", 13, 10 , '$'
	STATEMENT DB  "Please, write a message or a command: ", 13, 10, '$'
	PRINTMESSAGE DB "The message you introduced is: ", '$'
	CODMESSAGE DB "The encoded message is: ", '$'
	DECMESSAGE DB "The decoded message is: ", '$'
    
    LINEJUMP DB 13, 10, '$'

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
	; First assembly instruction must be after the 256 bytes of PSP, so this is 
	; necessary to generate a .COM file
	ORG 256


; BEGINNING OF THE MAIN PROCEDURE



INICIO PROC
	; INITIALIZE THE SEGMENT REGISTERS
	MOV AX, DATOS
	MOV DS, AX

	; We have to check if our driver is correcly installed
	MOV AH, 0
	CALL CHECK_DRIVER
	CMP AH, 1
	JE DRIVER_OK
	

ERROR:
	
	; If the driver isnt well installed, we print an advise and the program finishes
	; Printing an ERRORCODE
	MOV DX, OFFSET ERRORCODE
	MOV AH, 9
	INT 21h

	JMP JEND

DRIVER_OK:
	
	; We set up all the RTC configuration in this function
	CALL RTC_CONFIG

	; CLEARS THE SCREEN
	MOV AH, 9	
	MOV DX, OFFSET CLEAR_SCREEN
	INT 21h


KEYBOARD_LOOP:

	; Printing the current mode
	MOV DX, OFFSET MODESTRING
	INT 21h

	CMP COD_DEC, 0
	JNE DEC_PRINT
 
	MOV DX, OFFSET CODSTRING
	INT 21h

	JMP SCANF

DEC_PRINT:

	MOV DX, OFFSET DECSTRING
	INT 21h

SCANF: 

	; PRINTS THE MESSAGE REQUEST
	MOV DX, OFFSET STATEMENT		
	INT 21h

	; STORES THE MESSAGE IN MEMORY
	MOV AH, 0Ah		
	MOV DX, OFFSET MESSAGE
	MOV MESSAGE[0], 90		
	INT 21h

	; Check out if the MESSAGE'S lenght is not null
	MOV BH, 0
	MOV BL, MESSAGE[1]
	CMP BL, 0
	JE KEYBOARD_LOOP
	 

	; In order to print the message correctly, we have to write the $ right after the last character
	MOV MESSAGE[BX+2], '$'

	; First of all, we check out if the given string is one of our commands

	; Quit comparison
	CMP MESSAGE[2], 'q'
	JNE COD_CMP
	CMP MESSAGE[3], 'u'
	JNE COD_CMP
	CMP MESSAGE[4], 'i'
	JNE COD_CMP
	CMP MESSAGE[5], 't'
	JNE COD_CMP

	; In this case the QUIT command has been written. The program ends

	JMP JEND

COD_CMP:

	CMP MESSAGE[2], 'c'
	JNE DEC_CMP
	CMP MESSAGE[3], 'o'
	JNE DEC_CMP
	CMP MESSAGE[4], 'd'
	JNE DEC_CMP


	; In this case the COD command has been written. We change the mode-flag

	MOV COD_DEC, 0

	; Printing a line jump 
	MOV AH, 9	
	MOV DX, OFFSET LINEJUMP
	INT 21h

	JMP KEYBOARD_LOOP

DEC_CMP: 
	
	CMP MESSAGE[2], 'd'
	JNE STRING_MODE
	CMP MESSAGE[3], 'e'
	JNE STRING_MODE
	CMP MESSAGE[4], 'c'
	JNE STRING_MODE

	; In this case the DEC command has been written. We change the mode-flag

	MOV COD_DEC, 1

	; Printing a line jump 
	MOV AH, 9	
	MOV DX, OFFSET LINEJUMP
	INT 21h

	JMP KEYBOARD_LOOP

STRING_MODE:

	; PRINTS THE MESSAGE WRITTEN BY THE USER
	MOV AH,9	
	MOV DX, OFFSET PRINTMESSAGE
	INT 21h
	
	MOV DX, OFFSET MESSAGE[2]
	INT 21h

	; Printing a line jump 
	MOV DX, OFFSET LINEJUMP
	INT 21h

	
	CMP COD_DEC, 0
	JNE DEC_MODE

	; CASE 1: ENCRYPTION

	MOV DX, OFFSET CODMESSAGE
	INT 21h

	; 12h => ENCRYPTION
	MOV AH, 12h
	JMP INT_CALL


	; CASE 2: DECRYPTION

DEC_MODE:

	MOV DX, OFFSET DECMESSAGE
	INT 21h

	; 13h => DECRYPTION
	MOV AH, 13h

INT_CALL:

	; We push DS in order to keep it: We might need it later
	PUSH DS

	; We use message[2] because the first two bytes of the read message are the maximum size and the real size.
	; We dont want to codify them
	MOV DX, OFFSET MESSAGE[2]
	MOV BX, SEG MESSAGE
	MOV DS, BX
	
	; Calling of the interruption
	INT 55h

	; Restoring DS
	POP DS

	; Printing a line jump 
	MOV AH, 9h
	MOV DX, OFFSET LINEJUMP
	INT 21h


	; Active wait. We wait until the RTC interruptions end up printing the encoded/decoded string

WAITING:
	MOV DX, OFFSET MESSAGE[2]
	MOV BX, SEG MESSAGE
	MOV DS, BX
	
	MOV AH, 07h
	INT 55h
	CMP AH, 1
	JE WAITING

	; After the interruption, the user will be asked for another string once and again until it writes the QUIT command 
	JMP KEYBOARD_LOOP
	
	; PROGRAM END
JEND:
    MOV AX, 4C00h
	INT 21h
INICIO ENDP


; This function writes on AH
; After the execution:
; AH = 0 if there isnt any driver at 55h
; AH = 1 if the installed driver is ours.
; AH = 2 if there is a driver, but it is not ours.
CHECK_DRIVER PROC NEAR

	PUSH DI SI ES

	MOV AX, 0
	MOV ES, AX

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
	MOV AH, 0		
	JMP END_CHECK

DRIVER_EXISTS:

	MOV AH, 08h
	INT 55h
	; If the interruption with AH = 08h changes AH to 1, then it should be our interruption.
	CMP AH, 1
	JE END_CHECK

	; The other possible case is: there is a driver, but it isnt the one we want.
	MOV AH, 2

END_CHECK:
	POP ES SI DI
	RET

CHECK_DRIVER ENDP

RTC_CONFIG PROC NEAR
	PUSH AX

	; Enable RTC on slave PIC
	IN AL, 0A1h 		; Read IMR of PIC-1 (Slave)
	AND AL, 11111110b 
	OUT 0A1h, AL 		; Write IMR of PIC-1 (Slave)

	MOV AL, 0Ah
	; Set the frequency
	OUT 70h, AL 		; Enable 0Ah register
	MOV AL, 00101111b 	; DV=010b, RS=1111b (15 == 2 Hz)
	OUT 71h, AL 		; Write 0Ah register
	; Active interrupt
	MOV AL, 0Bh
	OUT 70h, AL 		; Enable 0Bh register
	IN AL, 71h 			; Read the 0Bh register
	MOV AH, AL
	OR AH, 01000000b 	; Set the PIE bit
	MOV AL, 0Bh
	OUT 70h, AL 		; Enable the 0Bh register
	MOV AL, AH
	OUT 71h, AL 		; Write the 0Bh register
	POP AX
	RET
RTC_CONFIG ENDP


; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. 
END INICIO


