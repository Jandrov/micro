;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 2
; FILE: pract3a.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************


; CODE SEGMENT DEFINITION
_TEXT SEGMENT BYTE PUBLIC 'CODE'
ASSUME CS: CODE

PUBLIC _checkSecretNumber
_checkSecretNumber PROC FAR 

    PUSH BP         ; Using BP in order to address the stack (only the arguments we passed to the function)
    MOV BP, SP      ; Initializing BP next to the lower argument passed (Actually, this is the gap for the return)

    PUSH DX; We save the register values (we dont want to change them just because the main function may have something stores into them)

    ; The argument of this function is a number from 0 to 9999 in char* format. Therefore, it takes 4 bytes long (+2 positions)
    ; The return direction gap takes +2 positions (2 bytes from segment and another 2 from offset)

    ; First 2 digits (2 bytes) of the secretNumber 
    MOV AX, [ BP + 8 ]
    ; 3rd and 4th digit of the secretNumber
    MOV DX, [ BP + 6 ]

    
    ; We compare all the possible combination bewteen digits
    ; It doesnt mind if we compare ASCII codes or the numbers directly
    ; It is easier to them in ASCII, to void the conversion code.
    
    CMP AH, AL
    JE REP
    CMP AH, DH
    JE REP
    CMP AH, DL
    JE REP 
    CMP AL, DH
    JE REP
    CMP AL, DL
    JE REP    
    CMP DX, DL
    JE REP

    MOV AX, 00h
    JMP ENDING

REP:

    MOV AX, 01h


ENDING: 
    
    POP DX
    ; If return is supposed to be in AX we should do pop into AX ?
    POP BP

    ret

_checkSecretNumber ENDP


PUBLIC _fillUpAttempt
_fillUpAttempt PROC FAR 

    PUSH BP         ; Using BP in order to address the stack (only the arguments we passed to the function)
    MOV BP, SP      ; Initializing BP next to the lower argument passed (Actually, this is the gap for the return)

    PUSH CX DX; We save the register values (we dont want to change them just because the main function may have something stores into them)

    ; We'll use  CX to get the attempt number
    ; DX:AX will be used to return the digit
    ; The argument of this function is a number from 0 to 9999 in int format. Therefore, it takes 2 bytes long (+1 positions)
    ; The return will be done by changing the second argument ( 4 char => 4 byte)
    ; The return direction gap takes +2 positions (2 bytes from segment and another 2 from offset)

    ; Attempt is stored in CX
    MOV CX, [ BP + 6 ]
    
    ;Now, we have to divide it to get its digits. Then, we will get their ASCII code (return is char* type).

    MOV AX, CX   ; We load the number to convert into AX  
	MOV DX, 0 	 ; It is important to initialize DX to 0
    MOV CL, 1000 ; Divide by a 16 bit operand
	IDIV CL      ;
    MOV   ,AX   ; We store in memory 
            

    MOV AX, DX   ; We store in AX the remainder
	MOV DX, 0 	 ; It is important to initialize DX to 0
    MOV CL, 100 
	IDIV CL          

    MOV AX, CX   ; We load the number to convert into AX  
	MOV DX, 0 	 ; It is important to initialize DX to 0
    MOV CL, 10 
	IDIV CL          
       

ENDING: 
    
    POP DX CX
    POP BP

    ret

_fillUpAttempt ENDP


; END OF CODE SEGMENT
_TEXT ENDS
END

