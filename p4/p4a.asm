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

	JMP STATUS
	; /I as parameter

	JMP INSTALLER
	; /U as parameter

	JMP UNINSTALLER

	; GLOBAL VARIABLES
	CODE_NUMBER DB 11  ; Codification number. We are team 8, so it is 8+3=11
	FLAG DW 0 				

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
		MOV DS:[BX][SI], AL
		INC SI
		JMP ENCRYPT

	DECRYPT:
		MOV AL, DS:[BX][SI]
		CMP AL, '$'
		JE PRINT
		SUB AL, CODE_NUMBER
		MOV DS:[BX][SI], AL
		INC SI
		JMP DECRYPT

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
		MOV AX, OFFSET CAESAR
		MOV BX, CS
		CLI
		MOV ES:[ 55H*4 ], AX
		MOV ES:[ 55H*4+2 ], BX
		STI
		MOV DX, OFFSET INSTALLER
		INT 27H ; TERMINATE AND STAY RESIDENT
		; PSP, VARIABLES, CAESAR ROUTINE.
	INSTALLER ENDP

	UNINSTALLER PROC ; UNINSTALL CAESAR OF INT 55H
		PUSH AX BX CX DS ES
		MOV CX, 0
		MOV DS, CX 						; SEGMENT OF INTERRUPT VECTORS
		MOV ES, DS:[ 55H*4+2 ] 			; READ CAESAR SEGMENT
		MOV BX, ES:[ 2CH ] 				; READ SEGMENT OF ENVIRONMENT FROM CAESAR’S PSP. 
		MOV AH, 49H 
		INT 21H 						; RELEASE CAESAR SEGMENT (ES)
		MOV ES, BX
		INT 21H 						; RELEASE SEGMENT OF ENVIRONMENT VARIABLES OF CAESAR
		; SET VECTOR OF INTERRUPT 55H TO ZERO
		CLI
		MOV DS:[ 55H*4 ], CX 			; CX = 0
		MOV DS:[ 55H*4+2 ], CX
		STI
		POP ES DS CX BX AX
		RET
	UNINSTALLER ENDP


	STATUS:
		; it shall show the installation status of the driver (installed/uninstalled), the team number and the names of the programmers

		
	; NOT SURE IF IT IS NECESSARY
	MOV AX, 4C00h
	INT 21h

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


