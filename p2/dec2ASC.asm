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
    RESULT DB 10 dup (?)  	; String to store the result
    DIVISOR DW 10000 		; Divisor each iteration 
    STEP DW 10 				; Value to divide DIVISOR by in each iteration
    FLAG DB 0 				; Tells us if we have found a digit that is not zero
    ASCII DB 48 			; Value of the ASCII code of digit 0
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
	
	MOV BX, 2351 		; Example number

	; We call the implemented function
	CALL CONVERTER


	; We print the string
    MOV DX, AX
    MOV AX, 0900h
    INT 21h
	
	; PROGRAM END
	MOV AX, 4C00h
	INT 21h
INICIO ENDP

; We implement the function to convert a 16-bit number to ASCII code
CONVERTER PROC
	MOV DI, 0   ; We initialize the string index to 0
	JMP BODY 	; The loop starts in BODY

FOUND:	
	MOV FLAG, -1  ; It means that we have already found a digit that is not zero

STORE:	
	ADD AL, ASCII  			; In order to print, it is very important to convert correctly to ASCII code. 
                			; Decimal digits start on the 48 ASCII: "0" is 48, "1" is 49, "2" is 50 and so on...
                			; That is the reason why adding 48 solves the problem

	MOV RESULT[DI], AL  	; We write the ASCII code of the first digit in RESULT variable
                    		; Standard ASCII codes are 8-bit long 
    INC DI 					; We increase the string index
    JMP COUNTER


FIRST_ZEROS: 	
	CMP AL, 0    ; Check if the digit is zero or not. If it is not, we change the flag and store the digit
	JNE FOUND

COUNTER:
	MOV BX, DX   	; We have to store the remainder, which is in DX
	MOV DX, 0 		; It is important to initialize DX to 0
	; The next three lines mean: DIVISOR = DIVISOR/STEP
	MOV AX, DIVISOR 
	IDIV STEP
	MOV DIVISOR, AX
	CMP DIVISOR, 0 	; Check if we have finished the loop (we won't be able to divide by 0)
	JE ONE_ZERO

BODY:
	MOV AX, BX   ; We load the number to convert into AX  
	MOV DX, 0 	 ; It is important to initialize DX to 0 
	IDIV DIVISOR ; Even though DIVISOR is a 16 bit operand, we can assume the quotient will always be an 8-bit number.
                 ; Thats because the statement of the exercise specifies this function receives a 16-bit number
                 ; The biggest 16-bit number is 65535, so the quotient will never be bigger than 6.
                 ; Then, reading from AL is enough, as AH would be 0. This is also the reason why we choose 10000 as the
                 ; first value of DIVISOR.

    CMP FLAG, 0  ; Check if we haven't found a digit yet
	JE FIRST_ZEROS      
	JMP STORE

ZERO:
	; Next two lines are to store a 0 digit into the first byte of RESULT
	MOV AL, ASCII  		
	MOV RESULT[DI], AL
	INC DI 					; We increase the string index
	JMP FINISH

ONE_ZERO:
	CMP FLAG, 0  ; Check if we haven't found a digit yet (it would mean that the number is just a 0)
	JE ZERO

FINISH:
	MOV RESULT[DI], '$' ; We write the sentinel. It is needed to know when a string ends. 
                        ; It is really important, without the sentinel the interruption 09 would print more than we expect.

    ; We return the memory address of the first position of the result
	MOV AX, OFFSET RESULT
	MOV DX, SEG RESULT

	RET

CONVERTER ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO


