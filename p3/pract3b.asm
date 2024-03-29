;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 2
; FILE: pract3b.asm
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************

; CODE SEGMENT DEFINITION
_TEXT SEGMENT BYTE PUBLIC 'CODE'
ASSUME CS: _TEXT

PUBLIC _computeMatches
_computeMatches PROC FAR 

    
    PUSH BP         ; We push BP because we want the main program stack to be accesed correctly after these function.
                    ; Without that value, the main program would lose the reference.
    MOV BP, SP      ; Now, we initialice BP as SP (which points to the last pushed element in the stack)
                    ; We do that to access the arguments of the function in an easier way:
                    ;   * All the passed arguments can be accesed like this: [BP + X],  being X an integer which 
                    ;     correct values depends on the number and the size of the arguments.
                    ; These also allows us to have some local variables under BP (BP - X), but they aren't needed in this function

    ; IMPORTANT: It is necessary to save the register values that the calling program had and restore them at the end of the procedure.
    ; If we dont do that, we might modifiy something the program doesnt expect to be modified.

    PUSH BX CX DX DI ES DS ; It is necessary to push de ES/DS register because of the LES/LEA instruction, that modifies it.
                        ; We dont store Ax because we are supposed to write the return value on it.


    ; The arguments of this function are:
    ;                  * unsigned char* secretNum
    ;                  * unsigned char* attemptDigits
    ;
    ; The return direction gaps takes 4 bytes (2 bytes from segment and another 2 from offset).
    ; The BP gap takes another 2 bytes

    ; The current stack state is similar to this:   SEG attemptDigits      BP+12
    ;                                               OFFSET attemptDigits   BP+10
    ;                                               SEG secretNum          BP+8
    ;                                               OFFSET secretNum       BP+6
    ;                                               SEG return@            BP+4
    ;                                               OFFSET return@         BP+2
    ;                                               BP                     BP
    ;                                               ...


    ; Loading arguments

    LES BX, [BP + 6]            ; We store secretNum direction in ES/BX
    LDS CX, [BP + 10]           ; We store attemptDigits direction in DS/CX

       
    MOV AX, 0                   ; We initialice the number of coincidences to 0
    MOV DI, 0                   ; We will iterate using DI

LOOPING: 

    MOV BX, [BP+6]    
    MOV DH, ES:[BX][DI]         ; Loading in DH the secretNum digit indicated by DI
    MOV BX, CX
    MOV DL, DS:[BX][DI]         ; Loading in DL the attempDigits digit indicated by DI
    CMP DH, DL                  ; We compare their ASCII codes
    JE COINCIDENCE              ; If they are equal, we jump

BACKSTEP:    
    
    INC DI                      ; We increment DI
    CMP DI, 4                   ; Stop condition: The 4 digits have already been compared. 
    JNE LOOPING                 ; Restart the loop

    JMP ENDING                  ; End of loop

COINCIDENCE:
    
    ADD AX, 1                   ; If a coincidence has happened, we increment the value of AX (which is also where the return value must be stored)
    JMP BACKSTEP                ; The loop must go on until the Stop Condition is True


ENDING: 

    ; Restoring
    POP DS ES DI DX CX BX 
    POP BP

    ret
_computeMatches ENDP


PUBLIC _computeSemiMatches
_computeSemiMatches PROC FAR 
    
    PUSH BP         ; We push BP because we want the main program stack to be accesed correctly after these function.
                    ; Without that value, the main program would lose the reference.
    MOV BP, SP      ; Now, we initialice BP as SP (which points to the last pushed element in the stack)
                    ; We do that to access the arguments of the function in an easier way:
                    ;   * All the passed arguments can be accesed like this: [BP + X],  being X an integer which 
                    ;     correct values depends on the number and the size of the arguments.
                    ; These also allows us to have some local variables under BP (BP - X), but they aren't needed in this function

    ; IMPORTANT: It is necessary to save the register values that the calling program had and restore them at the end of the procedure.
    ; If we dont do that, we might modifiy something the program doesnt expect to be modified.

    PUSH BX CX DX DI SI ES DS ; It is necessary to push de ES/DS register because of the LES/LDS instruction, that modifies it.
                              ; We dont store AX because we are supposed to write the return value on it.


    ; The arguments of this function are:
    ;                  * unsigned char* secretNum
    ;                  * unsigned char* attemptDigits
    ;
    ; The return direction gaps takes 4 bytes (2 bytes from segment and another 2 from offset).
    ; The BP gap takes another 2 bytes

    ; The current stack state is similar to this:   SEG attemptDigits      BP+12
    ;                                               OFFSET attemptDigits   BP+10
    ;                                               SEG secretNum          BP+8
    ;                                               OFFSET secretNum       BP+6
    ;                                               SEG return@            BP+4
    ;                                               OFFSET return@         BP+2
    ;                                               BP                     BP
    ;                                               ...


    ; Loading arguments

    LES CX, [BP + 6]            ; We store secretNum direction in ES/CX
    LDS BX, [BP + 10]           ; We store attemptDigits direction in DS/BX

       
    MOV AX, 0                   ; We initialice the number of semimatches to 0
    MOV DI, 0                   ; We will iterate in secretNum using DI
    MOV SI, 0                   ; We will iterate in atemptDigits using SI

EXTERNAL: 
    MOV BX, [BP + 10]
    MOV DL, DS:[BX][SI]         ; Loading in DL the attempDigits digit indicated by SI

INCREMENT:    
    CMP SI, DI                  ; Comparing both indexes because matches are not considered as semimatches
    JNE INTERNAL                
    INC DI                      ; If they are equal, we increment attemptDigits' index
    CMP DI, 4                   ; This would be true after comparing last digit of secretNum with third digit of attemptDigits
    JE FINISH                   ; In this case, the iteration has finished

INTERNAL:    
    MOV BX, CX
    MOV DH, ES:[BX][DI]         ; Loading in DH the secretNum digit indicated by DI
    
    CMP DH, DL                  ; We compare their ASCII codes
    JE SEMIMATCH                ; If they are equal, we jump

CHECKS:    
    
    INC DI                      ; We increment DI (internal loop index)
    CMP DI, 4                   ; Stop condition: The 4 digits have already been compared. 
    JNE INCREMENT               ; Restart the internal loop
    MOV DI, 0                   ; We reset attemptDigits' index to restart the external loop
    INC SI                      ; We increment SI (external loop index)
    CMP SI, 4                   ; Stop condition
    JNE EXTERNAL                ; Restart the external loop

    JMP FINISH                  ; End of loop

SEMIMATCH:
    
    ADD AX, 1                   ; If a coincidence has happened, we increment the value of AX (which is also where the return value must be stored)
    JMP CHECKS                  ; The loop must go on until the Stop Condition is True


FINISH: 

    ; Restoring
    POP DS ES SI DI DX CX BX 
    POP BP

    ret
_computeSemiMatches ENDP


; END OF CODE SEGMENT
_TEXT ENDS
END

