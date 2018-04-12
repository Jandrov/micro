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
ASSUME CS: _TEXT

PUBLIC _checkSecretNumber
_checkSecretNumber PROC FAR 

    PUSH BP         ; We push BP because we want the main program stack to be accesed correctly after these function.
                    ; Without that value, the main program would lose the reference.
    MOV BP, SP      ; Now, we initialice BP as SP (which points to the last pushed element in the stack)
                    ; We do that to access the arguments of the function in an easier way:
                    ;   * All the passed arguments can be accesed like this: [BP + X],  being X an integer which 
                    ;     correct values depends on the number and the size of the arguments.
                    ; These also allows us to have some local variables under BP (BP - X), but they aren't needed in this function


    ; IMPORTANT: It is necessary to save the register values that the calling program had and restore them at the end of the procedure.
    ; If we dont do that, we might modifiy something the program doesnt expect to be modified.

    PUSH DX BX ES  ; It is necessary to push de ES register because of the following LES instruction, that modifies it.
                   ; We don't push AX because the program expect the return value tu be stored there

    ; The argument of this function is a reference to a pointer (number). Thats 2 bytes for the segment and 2 bytes for the offset. 4 bytes in total
    ; Using LEA/LES is really useful to read this kind of parameters.
    ; The return direction gaps takes 4 bytes (2 bytes from segment and another 2 from offset).
    ; The BP gap takes another 2 bytes

    ; The current stack state is similar to this:   SEG number        BP+8
    ;                                               OFFSET number     BP+6
    ;                                               SEG return@       BP+4
    ;                                               OFFSET return@    BP+2
    ;                                               BP                BP
    ;                                               ...


    ; As we see in the schema, to get the argument direction we shall access BP + 6  
    LES BX, [BP + 6]
    
    ; We store in AX the first two ASCII characters and in DX the next ones.
    MOV AX, ES:[BX]     ; That is, AH = Argument[1], AL= Argument[0]
    MOV DX, ES:[BX+2]   ; That is, DH = Argument[3], DL= Argument[1]
        
    ; We compare all the possible combination bewteen digits
    ; It doesnt mind if we compare ASCII codes or the numbers directly
    ; It is easier to do it in ASCII, to avoid the conversion code.
    
    CMP AL, AH  ; Argument[0] vs Argument[1]  
    JE REPET     
    CMP AL, DL  ; Argument[0] vs Argument[2]
    JE REPET
    CMP AL, DH  ; Argument[0] vs Argument[3]
    JE REPET
    CMP AH, DL  ; Argument[1] vs Argument[2]
    JE REPET
    CMP AH, DH  ; Argument[1] vs Argument[3]
    JE REPET    
    CMP DL, DH  ; Argument[2] vs Argument[3]
    JE REPET

    ; If any of this comparations are truth, there are repeated digits.
    ; In this case, we do AX=1 and return (see REPE tag)
    ; If not, the number is OK to play the game: we do AX=0 and return.

    MOV AX, 00h
    JMP ENDING

REPET:

    MOV AX, 01h


ENDING: 
    
    ; RESTORE OF VALUES: As we said before, restoring these values is really important. 
    ; We Pop from the stack in reverse order to do the correct assignments
    ; After this instructions, these registers' values should be the same as just before the CALL instruction
    POP ES BX DX 

    ; We also pop BP, that was stored the first one.
    POP BP

    ret

_checkSecretNumber ENDP


PUBLIC _fillUpAttempt
_fillUpAttempt PROC FAR 

    PUSH BP         ; We push BP because we want the main program stack to be accesed correctly after these function.
                    ; Without that value, the main program would lose the reference.
    MOV BP, SP      ; Now, we initialice BP as SP (which points to the last pushed element in the stack)
                    ; We do that to access the arguments of the function in an easier way:
                    ;   * All the passed arguments can be accesed like this: [BP + X],  being X an integer which 
                    ;     correct values depends on the number and the size of the arguments.
                    ; These also allows us to have some local variables under BP (BP - X), but they aren't needed in this function

    
    ; IMPORTANT: It is necessary to save the register values that the calling program had and restore them at the end of the procedure.
    ; If we dont do that, we might modifiy something the program doesnt expect to be modified.

    PUSH AX BX CX DX ES ; It is necessary to push de ES register because of the LES instruction, that modifies it.
                        ; Now we do store AX, the function is void and the main doesnt expect to get a return value on AX.

    ; We'll use  CX to get the attempt number,
    ; and DX and AX to operate and get the digits separated.
    ; The argument of this function is a number from 0 to 9999 in int format. Therefore, it takes 2 bytes long (+1 stack position)
    ; The return will be done by changing the second argument ( 4 char => 4 bytes)



    ; The argument of this function are:
    ;                  * attempt = An unsigned int. 2 bytes
    ;                  * attemptDigits = A reference to a pointer. Thats 2 bytes for the segment and 2 bytes for the offset. 4 bytes in total.
    ;
    ; The return direction gaps takes 4 bytes (2 bytes from segment and another 2 from offset).
    ; The BP gap takes another 2 bytes

    ; The current stack state is similar to this:   SEG attemptDigits      BP+10
    ;                                               OFFSET attemptDigits   BP+8
    ;                                               attempt                BP+6
    ;                                               SEG return@            BP+4
    ;                                               OFFSET return@         BP+2
    ;                                               BP                     BP
    ;                                               ...



    
    ; We'll use  CX to get the attempt number,
    ; and DX and AX to operate and get the digits separated.
    ; The argument of this function is a number from 0 to 9999 in int format. Therefore, it takes 2 bytes long (+1 stack position)
    ; The return will be done by changing the memory content the second argument points to ( 4 char => 4 bytes)
    ; As the attemptDigits is a char*, we will need to change to ASCII first
    ; The return direction gap takes +2 positions (2 bytes from segment and another 2 from offset)

    ; Attempt is stored in CX
    MOV CX, [ BP + 6 ]

    ; Getting the direction to access to attemptDigits and store the digits

    LES BX, [BP + 8]

    ;Now, we have to divide it to get the real digits. Then, we will get their ASCII code (return is char* type).

    MOV AX, CX           ; We load the number to convert into AX
	MOV DX, 0 	         ; It is important to initialize DX to 0s  
    MOV CX, 1000         ; Divide by a 16 bit operand
	IDIV CX              ; Quotient is stored in AX, Remainder in DX
    ADD AL, 48           ; Conversion to ASCII
    MOV ES:[BX] , AL     ; Actually, we know the whole quotient will be stored in AL as the number is as maximum 9999
                

    MOV AX, DX           ; We store in AX the previous remainder
	MOV DX, 0 	         ; It is important to initialize DX to 0
    MOV CL, 100  
	IDIV CL              ; Quotient is stored in AL, Remainder in AH
    ADD AL, 48           ; Conversion to ASCII
    MOV ES:[BX + 1] , AL ; Writing return in memory
   


    MOV AL, AH           ; We load the number to convert into AX
    MOV AH, 0h       
	MOV DX, 0 	         ; It is important to initialize DX to 0
    MOV CL, 10           ; Conversion to ASCII
	IDIV CL              ; Quotient is stored in AL, Remainder in AH
                         ; The remainder now is the last digit

    ADD AL, 48           ; Conversion to ASCII
    MOV ES:[BX + 2] , AL ; Writing return in memory
    ADD AH, 48           ; Conversion to ASCII
    MOV ES:[BX + 3] , AH ; Writing return in memory
 

    ; Restoring
    POP ES DX CX BX AX
    POP BP

    ret

_fillUpAttempt ENDP


; END OF CODE SEGMENT
_TEXT ENDS
END

