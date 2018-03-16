;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 1
; FILE: labs1a.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
DATOS ENDS
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
	DB 40h DUP (0) ; initialization example, 64 bytes set to 0
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
EXTRA ENDS
;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC
	; INITIALIZE THE SEGMENT REGISTERS
	MOV AX, 4000h
	MOV DS, AX
	MOV AX, 6000h
	MOV ES, AX
	;
	; PROGRAM START
	MOV AX, 13h 		; Load 0013h in AX, so 00h in AH and 13h in AL (immediate addressing)
	MOV BX, 0BAh		; Load 00BAh in BX, so 00h in BH and BAh in BL. Zero is needed because if it is not written, BAh is not correctly recognized (immediate addresing)
	MOV CX, 3412h		; Load 3412h in CX (immediate addressing)
	MOV DX, CX			; Load the content of CX (NOT THE CONTENT OF THE DIRECTION POINTED BY CX) in AX	(register addressing)
	MOV AX, ES:[5246h]	; Load in AL the content of the memory address 65246H and in AH the content of the memory address 65247H (direct addressing)
						; Notice that we've initialized ES = 6000h, so we access to the correct memory address just adding the offset
						; We dont work with 20 bits addresses, the bus is 16 bit-sized so it wouldn't be logical
						; Another solution could be this one (2 instructions):
						; MOV AL, [5246H]
						; MOV AH, [5247H]
						; We can use just one instruction because the addresses are side by side
	MOV DS:[0004h], CH	; Load in the memory address 40004H the content of CH (direct addressing)
						; Notice that we've initialized DS = 4000h. We must specify DS because this is TASM
	MOV AX, [DI]		; Load in AX the content of the memory address pointed by DI (register indirect addressing)
	MOV AX, [BP+8]		; Load in AX the content of the memory address pointed by BP + 8 bytes (based addressing)
	
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21h
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO