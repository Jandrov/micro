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
	JE STATUS

	; If there is a parameter, it must be 3 bytes long (space + / + I or space + / + U)
	CMP CL, 3
	JNE ERROR
	MOV CX, DS:[82h]
	CMP CL, '/'
	JNE ERROR
	; /I as parameter
	CMP CH, 'I'
	JE INSTALLER
	; /U as parameter
	CMP CH, 'U'
	JNE ERROR
	CALL UNINSTALLER
	JMP FINAL

	; Reaching here means input parameters are wrong
ERROR:
	; Shows this message when there has been an error introducing the parameters
	JMP FINAL

STATUS:
	; it shall show the installation status of the driver (installed/uninstalled), the team number and the names of the programmers
	JMP FINAL

	; GLOBAL VARIABLES
	CODE_NUMBER DB 11  	; Codification number. We are team 8, so it is 8+3=11
	MAX_VALUE DB 126 	; Maximum ASCII value we accept (~), in decimal
	MIN_VALUE DB 32 	; Minimum ASCII value we accept (space), in decimal

	CAESAR PROC FAR ; INTERRUPT SERVICE ROUTINE
		; SAVE MODIFIED REGISTERS
		PUSH SI BX AX
		; ROUTINE INSTRUCTIONS
		; We know the string is pointed by DS:DX
		MOV SI, 0 		; Initialize the index
		MOV BX, DX
		; We have to check AH
		CMP AH, 12h 	; Encrypt and print
		JE ENCRYPT
		CMP AH, 13h 	; Decrypt and print
		JE DECRYPT
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
		INT 21h 		; Print the string after processing it. Offset is already in DX
		; RESTORE MODIFIED REGISTERS
	FIN:
		POP AX BX SI
		IRET
	CAESAR ENDP

	INSTALLER PROC
		MOV AX, 0
		MOV ES, AX
		MOV BX, OFFSET CAESAR
		MOV AX, CS
		CLI
		; We have to check if there was a different driver already installed in that position
		MOV DI, ES:[ 55h*4 ]
		MOV SI, ES:[ 55h*4 +2 ]
		; We first check if there was no driver installed at all
		CMP DI, 0 	 
		JNE OUR_DRIVER
		CMP SI, 0
		JNE DRIVER_EXISTS

	INSTALL:
		MOV ES:[ 55h*4 ], BX
		MOV ES:[ 55h*4+2 ], AX
		STI
		MOV DX, OFFSET INSTALLER
		INT 27H ; TERMINATE AND STAY RESIDENT
		; PSP, VARIABLES, CAESAR ROUTINE.
	INSTALLER ENDP


	UNINSTALLER PROC ; UNINSTALL CAESAR OF INT 55H
		PUSH AX BX CX DS ES DI SI
		MOV CX, 0
		MOV DS, CX 						; SEGMENT OF INTERRUPT VECTORS
		MOV SI, DS:[ 55h*4+2 ] 			; READ CAESAR SEGMENT
		MOV DI, DS:[ 55h*4 ]			; READ CAESAR OFFSET
		; We first check if there was no driver installed at all
		CMP DI, 0 	 
		JE NO_DRIVER

	UNINSTALL:
		MOV ES, SI
		MOV BX, ES:[ 2Ch ] 				; READ SEGMENT OF ENVIRONMENT FROM CAESAR’S PSP. 
		MOV AH, 49h 
		INT 21h 						; RELEASE CAESAR SEGMENT (ES)
		MOV ES, BX
		INT 21h 						; RELEASE SEGMENT OF ENVIRONMENT VARIABLES OF CAESAR
		; SET VECTOR OF INTERRUPT 55H TO ZERO
		CLI
		MOV DS:[ 55H*4 ], CX 			; CX = 0
		MOV DS:[ 55H*4+2 ], CX
		STI
		POP SI DI ES DS CX BX AX
		RET
	UNINSTALLER ENDP

	OUR_DRIVER:
		; We check if the driver that was installed is exactly our driver
		CMP DI, BX
		JNE DRIVER_EXISTS
		CMP SI, AX
		JNE DRIVER_EXISTS
		; AQUI SE IMPRIMIRIA EL MENSAJE DE QUE YA ESTA INSTALADA NUESTRO DRIVER
		JMP FINAL

	DRIVER_EXISTS:

		; Aqui imprimimos pregunta para ver si instalar o no encima de la otra
		JMP INSTALL

		JMP FINAL

	NO_DRIVER:
		CMP SI, 0
		JNE UNINSTALL
		; AQUI SE IMPRIMIRIA EL MENSAJE DE QUE NO HAY INSTALADO NADA ASI QUE NO DESINSTALAMOS
	
	

	FINAL:	
		; NOT SURE IF IT IS NECESSARY
		MOV AX, 4C00h
		INT 21h

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


