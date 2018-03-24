;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 1
; FILE: labs1c.asm
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
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC
	; INITIALIZE THE SEGMENT REGISTERS
	; We set these instruction in order to write/read on/from the given addresses to check that our calculations are OK.
	MOV AX, 0h
	MOV DS, AX
	MOV BX, 0211h
	MOV DI, 1010h
	
	; PROGRAM START
	
	
	; The idea of the program is easy, we wanted to write on the memory addresses we had previously calculated by hand
	; and then read from the given ones. If the read bytes are equal to the written ones, both addresses should be the same.
	
	
	MOV AX, 0CAFEh
	MOV DS:[6344h], AX	; We write CAFEh at 06344h and 06345h. (direct addressing)
	
	MOV DX, 0FABAh
	MOV DS:[5321h], DX  ; We write FABAh at 05321h and 05322h. (direct addressing)
	
	MOV AL, 0BBh
	MOV DS:[6120h], AL  ; We write BBh at 06120h. (direct addressing)
	
	MOV AX, 0511h
	MOV DS, AX
	
						; Address 1, expected physical address = 06344h
	MOV AX, DS:[1234h]  ; Expected AX <= CAFEh, because we had stored CAFEh on 06344h
						; Address 2, expected physical address = 05321h
	MOV AX, DS:[BX]  	; Expected AX <= FABAh, because we had stored FABAh on 05321h
						; Address 3, expected physical address = 06120h
	MOV AL, DS:[DI]		; Expected [DI] <= BBh
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21H
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO

; IMPORTANT COMMENT:
; There is a problem in this exercise. The program is simple, and it should work without problems, but 
; there is always a moment where DosBox crashes.
; We believe this is due to an incorrect access to memory.
; Using TD to check where does the program exactly crashes we concluded there is no problem with the 
; first direction (06344h), but if we try to access the second one (05321h) the program stops.
; Checking the 8086 Memory Map, we can see that the segment from 0 till 005FFh is always reserved to DOS
; and the segment between 12K to 40K (where these directions belong) can also be taken by DOS.
; To avoid all of these kind of problems we should only work in the user-destinated area of memory.













