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
    STRING DB 10 dup (?)
    DIVISOR DW 10000
    STEP DB 10
    FLAG DB 0
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
	
	MOV BX, 579 		; Example number

	; We implement the function to convert a 16-bit number to ASCII code
	CONVERTER PROC
		MOV DI, 0   ; We initialize the string index to 0
		MOV CX, BX
		JMP BODY

FOUND:	MOV FLAG, -1  ; It means that we have already found a digit that is not zero

STORE:	INC DI 		 ; We increase the string index
		ADD AL, 48  ; In order to print, it is very important to convert correctly to ASCII code. 
                    ; Decimal digits start on the 48 ASCII: "0" is 48, "1" is 49, "2" is 50 and so on...
                    ; That is the reason why adding 48 solves the problem
 
		MOV STRING[DI], AL  ; We write the ASCII code of the first digit in STRING variable
                        	; Standard ASCII codes are 8-bit long 
        JMP COUNTER


ZERO: 	CMP AL, 0    ; Check if the digit is zero or not. If it is not, we change the flag and store the digit
		JNE FOUND

COUNTER:
		JE FINISH
		MOV CX, DX   ; We have to store the remainder, which is in DX
		MOV DX, 0
		MOV AX, DIVISOR
		IDIV STEP
		MOV DIVISOR, AX
		CMP DIVISOR, 1
		JE FINISH

BODY:
		MOV AX, CX   ; We load the number to convert into AX  
		MOV DX, 0 	 ; It is important to initialize DX to 0 
		IDIV DIVISOR ; Even though 10000 is a 16 bit operand, we can assume the quotient will always be an 8-bit number.
                     ; Thats because the statement of the exercise specifies this function receives a 16-bit number
                     ; The biggest 16-bit number is 65535, so the quotient will never be bigger than 6.
                     ; Then, reading from AL is enough, as AH would be 0. This is also the reason why we choose 10000 as the
                     ; divisor.

        CMP FLAG, 0  ; Check if we haven't found a digit yet
  		JE ZERO      
  		JMP STORE
                   

		


FINISH:
		MOV STRING[DI], '$' ; We write the sentinel. It is needed to know when a string ends. 
                           ; It is really important, without the sentinel the interruption 09 would print more than we expect.

		MOV AX, OFFSET STRING
		MOV DX, SEG STRING

	ENDP CONVERTER


	; We print the string
    MOV DX, AX
    MOV AX, 0900h
    INT 21h
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21h
	INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


