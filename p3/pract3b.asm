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


_computeMatches ENDP


PUBLIC _computeSemiMatches
_computeSemiMatches PROC FAR 


    ret
_computeSemiMatches ENDP


; END OF CODE SEGMENT
_TEXT ENDS
END

