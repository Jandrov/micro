;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 2
; FILE: dec2ASCII.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************

; DATA SEGMENT DEFINITION
DATOS SEGMENT
	DIVISOR DW 10000
    STRING DB 10 dup (?)
DATOS ENDS
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
	DB 40h DUP (0) ; initialization example, 64 bytes set to 0
PILA ENDS

; Extra Segment is not needed in this exercise

;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC
	; INITIALIZE THE SEGMENT REGISTERS
	MOV AX, DATOS
	MOV DS, AX
	
	; PROGRAM START
	
	MOV BX, 60579 		; Example number

	; We implement the function to convert a 16-bit number to ASCII code
	CONVERTER PROC



		MOV AX, BX  ; We load the number to convert into AX  
		MOV DX, 0 	; It is important to initialize DX to 0 
		MOV CX, 10000
		IDIV CX     ; Even though 10000 is a 16 bit operand, we can assume the quotient will always be an 8-bit number.
                    ; Thats because the statement of the exercise specifies this function receives a 16-bit number
                    ; The biggest 16-bit number is 65535, so the quotient will never be bigger than 6.
                    ; Then, reading from AL is enough, as AH would be 0. This is also the reason why we choose 10000 as the divisor.
                
        ADD AL, 48  ; In order to print, it is very important to convert correctly to ASCII code. 
                    ; Decimal digits start on the 48 ASCII: "0" is 48, "1" is 49, "2" is 50 and so on...
                    ; Thats the reason why adding 48 solves the problem
 
		MOV STRING, AL  ; We write the ASCII code of the first digit in STRING variable
                        ; Standard ASCII codes are 8-bit long 
                   

		MOV AX, DX  ; We load the remainder into AX to compute the next division.
                    ; Keep in mind that the remainder can only be <= than 5537, 
                    ; so all the reasoning exposed above can be applied here again.
		
        MOV DX, 0 	; It is important to initialize DX to 0 
		MOV CX, 1000
		IDIV CX

        ADD AL, 48 
		MOV STRING[1], AL ; We write the ASCII code of the second digit


        ; We apply the same method as before.
		MOV AX, DX  ; We load the remainder into AX to compute the next division                
		MOV DX, 0 	
		MOV CX, 100
		IDIV CX
        ADD AL, 48
		MOV STRING[2], AL ; We write the ASCII code of the third digit


        ; Once again, we apply the same method.
		MOV AX, DX  ; We load the remainder into AX to compute the next division
		MOV DX, 0 	
		MOV CX, 10
		IDIV CX
        ADD AL, 48
		MOV STRING[3], AL ; We write the ASCII code of the fourth digit

        ; In this case, as we jus divided by 10, the remainder will be the last digit
        ; As the remainder is stored in DL (10 is 8-bit operand), we can just work with that register 
        ADD DL, 48
		MOV STRING[4], DL; We write the ASCII code of the last digit

		MOV STRING[5], '$' ; We write the sentinel. It is needed to know when a string ends. 
                           ; Its really important, without the sentinel the interruption 09 would print more than we expect.

		MOV AH, 09h
		MOV DX, OFFSET STRING

	ENDP CONVERTER


	; We print the string
	INT 21h
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21h
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


