;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 4
; FILE: p4a.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************



;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
	ASSUME CS: CODE
	; First assembly instruction must be after the 256 bytes of PSP, so this is 
	; necessary to generate a .COM file
	ORG 256


; BEGINNING OF THE MAIN PROCEDURE
INICIO: 
	; Check input parameters
	MOV CL, DS:[80h]   	; Load the size of the parameters in the command line
	; No parameters
	CMP CL, 0
	JNE NEXT
	CALL STATUS
	JMP FINAL

NEXT:
	; If there is a parameter, it must be 3 bytes long (space + / + I or space + / + U)
	CMP CL, 3
	JNE ERROR
	MOV CX, DS:[82h]
	CMP CL, '/'
	JNE ERROR
	; /I as parameter
	CMP CH, 'I'
	JE AUXINSJUMP
	; /U as parameter
	CMP CH, 'U'
	JNE ERROR
	CALL UNINSTALLER
	JMP FINAL

AUXINSJUMP:

	CALL INSTALLER
	JMP FINAL

	; Reaching here means input parameters are wrong
ERROR:
	; Shows this message when there has been an error introducing the parameters
	MOV AH, 09h
	MOV DX, OFFSET ERRORSTRING
	INT 21H
	JMP FINAL

	; Print variables for Installation/Uninstallation
	ERRORSTRING DB "ERROR", 13, 10, "You can only execute this program following one of these modes: ", 13, 10
				DB "1. No parameters -> Shows status", 13, 10, "2. /I -> Install the driver", 13, 10, "3. /U -> Uninstall the driver", 13, 10, '$'
	COINCIDENCEPRINT DB "The driver you are trying to install is already installed", 13, 10, '$'
	CONFLICT DB "There is another driver at 55h. Do you want to overwrite it? (write y/n)", 13, 10, '$'
	ANSWER DB 3 dup(0)
	; Print variables for Status Case
	STATUSPRINT1 DB "The driver is currently INSTALLED", 13, 10, '$'
	STATUSPRINT2 DB "The driver is currently UNINSTALLED", 13, 10, '$'
	AUTHORS DB "AUTHORS:", 13, 10, "Emilio Cuesta", 13, 10, "Alejandro Sanchez", 13, 10 ,"GROUP 2351, TEAM 8", 13, 10,'$'	
	
	; Variables for Caesar Cypher
	CODE_NUMBER DB 11  	; Codification number. We are team 8, so it is 8+3=11
	MAX_VALUE DB 126 	; Maximum ASCII value we accept (~), in decimal
	MIN_VALUE DB 32 	; Minimum ASCII value we accept (space), in decimal
	;PREV_55h DW ?, ? 	; Variable to store the routine which was previously installed in 55h of the interrumpt vector

	; Variables for RTC
	FLAG_PRINT DB 0		; 0 -> No print character by character. 1 -> Print character by character
	COUNTER DB 2 		; Used to simulate 1 Hz frequency because we can only configure RTC's frequency to 2 Hz minimum
	INDEX DW 0 			; Index to print the string character by character

	
	RTC_ROUTINE PROC FAR 	; RTC ROUTINE
		PUSHF
		PUSH BX AX SI DX

		STI
		; Read register C 
		MOV AL, 0Ch
		OUT 70h, AL
		IN AL, 71h
		CMP FLAG_PRINT, 1
		JNE RTC_ROUTINE_FIN
		; Decrease the counter which is used to simulate a 1 Hz frequency
		DEC COUNTER
		JNZ RTC_ROUTINE_FIN
		; Restart the counter
		MOV COUNTER, 2
		; Print character by character until finding '$'
		MOV SI, INDEX
		MOV BX, DX
		MOV AH, 02h
		MOV DL, DS:[BX][SI]
		CMP DL, '$'
		JE PRINT_END
		INT 21h
		; Increase the index
		INC SI
		MOV INDEX, SI
		JMP RTC_ROUTINE_FIN

	PRINT_END:
		MOV INDEX, 0
		MOV FLAG_PRINT, 0

	RTC_ROUTINE_FIN:
		; Send EOI to the slave PIC
		MOV AL, 20h
		OUT 0A0h, AL
		; Send EOI to the master PIC
		OUT 20h, AL

		POP DX SI AX BX
		POPF
		IRET
	RTC_ROUTINE ENDP

	CAESAR PROC FAR ; INTERRUPT SERVICE ROUTINE
		PUSHF
		; SAVE MODIFIED REGISTERS
		PUSH SI BX
		; ROUTINE INSTRUCTIONS
		; We know the string is pointed by DS:DX
		MOV SI, 0 		; Initialize the index
		MOV BX, DX

		; We have to check AH
		CMP AH, 12h 	; Encrypt and print
		JE ENCRYPT
		CMP AH, 13h 	; Decrypt and print
		JE DECRYPT
		CMP AH, 08h     ; This is an extra feature that will be used to tell us if the interruption is installed or not
		JE DRIVER_PRESENCE
		CMP AH, 07h     ; This is an extra feature that will be used to tell us if RTC is printing or not
		JE PRINT_MODE
		JMP FIN

	DRIVER_PRESENCE:

		MOV AH, 1		; If the interruption is installed, AH will be modified and store a one.

		JMP FIN 

	PRINT_MODE:

		MOV AH, FLAG_PRINT		; If RTC is printing character by character, AH will be modified and store the FLAG_PRINT (1 if we are printing, 0 if not).

		JMP FIN 

	ENCRYPT:
		MOV AL, DS:[BX][SI]
		CMP AL, '$'
		JE PRINT
		ADD AL, CODE_NUMBER
		MOV AH, AL
		SUB AH, MAX_VALUE
		JG OVERFLOW
	BACK_ENC:
		MOV DS:[BX][SI], AL
		INC SI
		JMP ENCRYPT

	DECRYPT:
		MOV AL, DS:[BX][SI]
		CMP AL, '$'
		JE PRINT
		SUB AL, CODE_NUMBER
		MOV AH, AL
		SUB AH, MIN_VALUE
		JL UNDERFLOW
	BACK_DEC:
		MOV DS:[BX][SI], AL
		INC SI
		JMP DECRYPT

	OVERFLOW:
		ADD AH, MIN_VALUE
		DEC AH
		MOV AL, AH
		JMP BACK_ENC

	UNDERFLOW:
		ADD AH, MAX_VALUE
		INC AH
		MOV AL, AH
		JMP BACK_DEC

	PRINT:
		
		MOV AH, 09h
		INT 21h 			; Print the string after processing it. Offset is already in DX
		MOV FLAG_PRINT, 1 	; Tell the RTC that it must print character by character the string

		; RESTORE MODIFIED REGISTERS
	FIN:
		POP BX SI
		POPF
		IRET
	CAESAR ENDP

	INSTALLER PROC
		MOV AX, 0
		MOV ES, AX
		
		; We have to check if there was a different driver already installed in that position
		CALL CHECK_DRIVER

		; If there are no drivers, we dont have any problems for the installation
		CMP AH, 0
		JE INSTALL

		; If there is a different driver, we ask the user what to do with it
		CMP AH, 2
		JE OTHER_DRIVER

		; In any other case, we assume the installed driver is ours, therefore there is no need to reinstall it
		MOV AH, 09h
		MOV DX, OFFSET COINCIDENCEPRINT
		INT 21h
		
	ERROREND:
		STI
		RET 

	OTHER_DRIVER:

		PUSH BX DX AX

		MOV DX, OFFSET CONFLICT
		MOV AH, 9 
		INT 21h	

		; Reading answer from keyboard
		MOV AH, 0Ah		
		MOV DX, OFFSET ANSWER
		MOV ANSWER[0], 2		
		INT 21h

		; Check out if the MESSAGE'S lenght is not null
		MOV BL, ANSWER[1]
		CMP BL, 0
		JE ERROREND

		POP AX DX BX

		; Answer check
		CMP ANSWER[2], 'y'
		;JE STORE_PREV
		JE INSTALL

		JMP ERROREND

	; STORE_PREV:
	; 	CLI
	; 	MOV CX, ES:[ 55h*4 ]
	; 	MOV PREV_55h, CX
	; 	MOV CX, ES:[ 55h*4+2 ]
	; 	MOV PREV_55h+2, CX
	; 	STI

	INSTALL:

		CLI

		MOV ES:[ 55h*4 ], OFFSET CAESAR
		MOV ES:[ 55h*4+2 ], CS

		; Install RTC 
		MOV ES:[ 70h*4 ], OFFSET RTC_ROUTINE
		MOV ES:[ 70h*4+2 ], CS

		STI
		MOV DX, OFFSET INSTALLER
		INT 27H ; TERMINATE AND STAY RESIDENT
		; PSP, VARIABLES, CAESAR ROUTINE.
	INSTALLER ENDP


	UNINSTALLER PROC ; UNINSTALL CAESAR OF INT 55H
		PUSH AX BX CX DS ES SI
		MOV CX, 0
		MOV DS, CX 						; SEGMENT OF INTERRUPT VECTORS
 
		MOV AH, 0
		CALL CHECK_DRIVER

		; If there are no drivers to unistall, we dont do anything
		CMP AH, 0 	 
		JE UNSEND
		; If there is a different driver, we dont unistall it.
		; If we needed to, we can call INSTALL and we will be offered to overwrite the previous installation
		CMP AH, 2
		JE UNSEND

		; Otherwise, our driver is installed and we want to uninstall it

	UNINSTALL:
		MOV SI, DS:[ 55h*4+2 ] 			; READ CAESAR SEGMENT	
		MOV ES, SI
		MOV BX, ES:[ 2Ch ] 				; READ SEGMENT OF ENVIRONMENT FROM CAESAR’S PSP. 
		MOV AH, 49h 
		INT 21h 						; RELEASE CAESAR SEGMENT (ES)
		MOV ES, BX
		INT 21h 						; RELEASE SEGMENT OF ENVIRONMENT VARIABLES OF CAESAR
		
		; SET VECTOR OF INTERRUPT 55h AND 70h TO ZEROS 

		;;;;;;;;;;;(OR THE DRIVER PREVIOUSLY INSTALLED)

		CLI
		
		; RTC
		MOV DS:[ 70h*4 ], CX
		MOV DS:[ 70h*4+2 ], CX
		MOV DS:[ 55h*4 ], CX   			; CX = 0, DS = 0
		MOV DS:[ 55h*4+2 ], CX
		

		; MOV CX, PREV_55h
		; MOV DS:[ 70h*4 ], CX
		; MOV CX, PREV_55h+2
		; MOV DS:[ 70h*4+2 ], CX
		; MOV CX, PREV_55h
		; MOV DS:[ 55h*4 ], CX
		; MOV CX, PREV_55h+2
		; MOV DS:[ 55h*4+2 ], CX
		STI

	UNSEND:

		POP SI ES DS CX BX AX
		RET
	UNINSTALLER ENDP


	STATUS PROC
		; AH is already 0
		CALL CHECK_DRIVER

		CMP AH, 1
		; If AH is 1, our driver is correcly installed. (Check CHECK_DRIVER PROC)
		JE INST

		; In any other case, it is not correcly installed
		MOV DX, OFFSET STATUSPRINT2
		MOV AH, 9 
		INT 21h	
		JMP AUTH

	INST: 

		MOV DX, OFFSET STATUSPRINT1
		MOV AH, 9 
		INT 21h	

	AUTH: 

		MOV DX, OFFSET AUTHORS
		INT 21h
		RET

	STATUS ENDP
	
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

	FINAL:	
		; END THE PROGRAM
		MOV AX, 4C00h
		INT 21h

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. 
END INICIO


