; Atividade Final

segment code
..start:
    
main:
    mov byte[negativo1], '-' ; Move AL para [negativo1]
    mov bl, [negativo1]
    cmp bl, '+'
    je imprimir

    call sair
sair:
    ; Resultado da função de sair sendo chamada
    mov    ax, 4C00h
    int     21h

imprimir:
    ; Imprime o valor de negativo1
    mov ah, 0Eh
    mov al, '+'
    mov bl, 07h
    int 10h
    call sair

segment .data
    num1 dw 0
    num2 dw 0
    op   db 0  ; Operador (+, -, *, /)
    digito1 db 0
    digito2 db 0
    negativo1 db '+',0 ; Operador primeiro número (-)
    negativo2 db 43,0 ; Operador segundo número
