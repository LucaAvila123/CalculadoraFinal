segment code
..start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    mov sp, stacktop
    
main:
    call inserir_digito
    call sair

imprimir_string:
    ; Função para imprimir a string em entrada
    ; Entrada: SI = endereço da string
    push si
    mov si, entrada
    
.loop:
    lodsb           ; Carrega byte de [SI] em AL e incrementa SI
    or al, al       ; Verifica se é o terminador nulo
    jz .fim        ; Se for, termina
    
    ; Imprime o caractere
    mov ah, 0Eh
    mov bl, 07h
    int 10h
    
    jmp .loop
    
.fim:
    pop si
    ret

processar_entrada:
    ; Processa a string entrada caractere por caractere
    mov si, entrada      ; Ponteiro para o início da string
    mov di, variaveis    ; Ponteiro para o array de variáveis
    xor cx, cx           ; Contador de caracteres processados

.processar_loop:
    mov al, [si]        ; Carrega o próximo caractere
    or al, al           ; Verifica se é o terminador nulo
    jz .fim_processamento
    
    ; Armazena o caractere na posição atual do array de variáveis
    mov [di], al
    inc di
    inc si
    inc cx
    
    ; Aqui você pode adicionar lógica específica para cada tipo de caractere
    ; Por exemplo, verificar se é dígito, operador, etc.
    
    jmp .processar_loop

.fim_processamento:
    ; Chama sete funções de dígitos por serem o máximo de dígitos que serão usados

    ret

erro:
    ; irá resetar o processo
    mov si, 0
    jmp inserir_digito.input_loop

inserir_digito:
    mov si, 0          ; Inicializa o índice da string
    
.input_loop:
    mov ah, 00h        ; Função para ler tecla
    int 16h

    cmp al, 's'        ; Verifica se é 's' para sair
    je .fim
    cmp al, 0Dh        ; Verifica se é enter
    je trata_string
    cmp al, 08h        ; Verifica se é backspace
    je .backspace

    call .armazena
    jmp .input_loop   
    
.armazena:
    ; Armazena o caractere na string
    mov [entrada + si], al
    inc si
    
    ; Exibe o caractere na tela
    mov ah, 0Eh
    mov bl, 07h
    int 10h
    
    ; Verifica se atingiu o tamanho máximo
    cmp si, 100
    jae .fim           ; Se sim, termina
    
    ret
    
.backspace:
    ; Verifica se há caracteres para apagar
    cmp si, 0
    je .input_loop
    
    ; Apaga o último caractere
    dec si
    mov byte [entrada + si], 0
    
    ; Move o cursor para trás e apaga o caractere na tela
    mov ah, 0Eh
    mov al, 08h        ; Backspace
    int 10h
    mov al, ' '        ; Espaço
    int 10h
    mov al, 08h        ; Backspace novamente
    int 10h
    
    jmp .input_loop
    
.fim:
    ret

trata_string:
    ; Adiciona terminador nulo à string
    mov byte [entrada + si], 0
    
    ; Pula uma linha antes de imprimir
    mov ah, 0Eh
    mov al, 0Dh        ; Carriage Return
    int 10h
    mov al, 0Ah        ; Line Feed
    int 10h
    
    ; Imprime a string
    call imprimir_string
    
    ; Pula outra linha após imprimir
    mov ah, 0Eh
    mov al, 0Dh        ; Carriage Return
    int 10h
    mov al, 0Ah        ; Line Feed
    int 10h
    ;Aqui vai funcionar a calculadora
    call processar_entrada   
    ; Volta para capturar mais entrada
    mov si, 0
    jmp inserir_digito.input_loop

sair:
    ; Resultado da função de sair sendo chamada
    mov ax, 4C00h
    int 21h

segment data
    entrada times 101 db 0  ; String para armazenar até 100 caracteres + terminador
    variaveis times 100 db 0 ; Array para armazenar caracteres individuais
    num1 dw 0
    num2 dw 0
    digito1_numero1 db 0
    digito2_numero1 db 0
    digito1_numero2 db 0
    digito2_numero2 db 0
    op db 0        ; Operador (+, -, *, /)
    negativo1 db 0 ; Operador primeiro número (-)
    negativo2 db 0 ; Operador segundo número  (-)

segment stack stack
    resb 256
stacktop:
