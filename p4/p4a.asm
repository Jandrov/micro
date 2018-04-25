;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 4
; FILE: p4a.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************


;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
	DB 40h DUP (0) ; initialization example, 64 bytes set to 0
PILA ENDS


;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
	ASSUME CS: CODE, SS: PILA
	; First assembly instruction must be after the 256 bytes of PSP, so this is 
	; necessary to generate a .COM file
	ORG 256

; BEGINNING OF THE MAIN PROCEDURE
INICIO: 
	JMP INSTALLER

	; GLOBAL VARIABLES
	TABLE DB ''ABCDF ''		;; por ahora no se usan
	FLAG DW 0 				

	CAESAR PROC FAR ; INTERRUPT SERVICE ROUTINE
		; SAVE MODIFIED REGISTERS
		PUSH ...
		; ROUTINE INSTRUCTIONS
		...
		; RESTORE MODIFIED REGISTERS
		POP ...
		IRET
	CAESAR ENDP

	...

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
	UNSTALLER ENDP


; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


