;******************************************************************************* 
; CALCULA EL PRODUCTO DEL FACTORIAL DE DOS NUMEROS QUE SE 
; ENCUENTRAN EN LAS POSICIONES DE MEMORIA 0 Y 1 DEL SEGMENTO DE 
; DATOS. EL VALOR DE CADA NUMERO DEBE SER INFERIOR A 9. EL RESULTADO 
; SE ALMACENA EN DOS PALABRAS DEL SEGMENTO EXTRA, EN LA PRIMERA 
; PALABRA EL MENOS SIGNIFICATIVO Y EN LA SEGUNDA EL MAS 
; SIGNIFICATIVO. SE UTILIZA UNA RUTINA PARA CALCULAR EL FACTORIAL. 
;*******************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

DATO_1  DB     2
DATO_2  DB     3

DATOS ENDS 


; DEFINICION DEL SEGMENTO DE PILA 

PILA    SEGMENT STACK "STACK" 
    DB   40H DUP (0) 
PILA ENDS 


; DEFINICION DEL SEGMENTO EXTRA 

EXTRA     SEGMENT 
    RESULT    DW 0,0                 ; 2 PALABRAS ( 4 BYTES ) 
EXTRA ENDS 


; DEFINICION DEL SEGMENTO DE CODIGO 

CODE    SEGMENT 
    ASSUME CS:CODE, DS:DATOS, ES: EXTRA, SS:PILA 

FACT_DATO_1  DW       0 

; COMIENZO DEL PROCEDIMIENTO PRINCIPAL 

START PROC 
    ;INICIALIZA LOS REGISTROS DE SEGMENTO CON SUS VALORES 
    MOV AX, DATOS 
    MOV DS, AX 

    MOV AX, PILA 
    MOV SS, AX 

    MOV AX, EXTRA 
    MOV ES, AX 

    ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO 
    MOV SP, 64 

    ; FIN DE LAS INICIALIZACIONES 

    ;COMIENZO DEL PROGRAMA 
    MOV CL, DATO_1 
    CALL FACTOR 
    MOV FACT_DATO_1, AX       ; ALMACENA EL RESULTADO 
    MOV CL, DATO_2 
    CALL FACTOR 
    MOV BX, FACT_DATO_1 
    MUL BX                    ; EN AX ESTA EL RESULTADO DEL FACTORIAL DEL SEGUNDO 

    ; ALMACENA EL RESULTADO 
    MOV RESULT, AX 
    MOV RESULT+2, DX 

    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H 

START ENDP 
;_______________________________________________________________ 
; SUBRUTINA PARA CALCULAR EL FACTORIAL DE UN NUMERO 
; ENTRADA CL=NUMERO 
; SALIDA AX=RESULTADO, DX=0 YA QUE CL<=9 
;_______________________________________________________________ 

FACTOR PROC NEAR 
    MOV AX, 1 
    XOR CH,CH 
    CMP CX, 0 
    JE FIN 
IR: 
    MUL CX 
    DEC CX 
    JNE IR 
FIN: 
    RET 
FACTOR ENDP 

; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END START 

