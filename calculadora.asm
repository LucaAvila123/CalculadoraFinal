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
    cmp cx, 0
    je .primeiro_digito
    cmp cx, 1
    je .segundo_digito
    cmp cx, 2
    je .operador
    cmp cx, 3
    je .terceiro_digito
    cmp cx, 4
    je .quarto_digito

.volta_teste:
    inc di
    inc si
    inc cx
    
    ; Aqui você pode adicionar lógica específica para cada tipo de caractere
    ; Por exemplo, verificar se é dígito, operador, etc.
    
    jmp .processar_loop

.fim_processamento:
    call parse_number1
    call parse_number2
    call operacao
    call imprime_resultado

    ret
.primeiro_digito:
    mov al, byte[di]
    mov byte[digito1_numero1], al
    jmp .volta_teste
.segundo_digito:
    mov al, byte[di]
    mov byte[digito2_numero1], al
    jmp .volta_teste
.operador
    mov al, byte[di]
    mov byte[op], al
    jmp .volta_teste
.terceiro_digito
    mov al, byte[di]
    mov byte[op], al
    jmp .volta_teste
.quarto_digito
    mov al, byte[di]
    mov byte[op], al
    jmp .volta_teste

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

parse_number1:
    mov al, [digito1_numero1]
    sub al, 30h
    mov bh, 10
    mul bh
    xor bh, bh
    mov bl, [digito2_numero1]  
    sub bl, 30h                
    add al, bl                 
    mov byte[num1], al                
    xor ax, ax
  
    ret

parse_number2:
    mov al, [digito1_numero2]
    sub al, 30h
    mov bh, 10
    mul bh
    xor bh, bh
    mov bl, [digito2_numero2]  
    sub bl, 30h                
    add al, bl                 
    mov byte[num2],al                 
    xor ax, ax  
    ret 
operacao:
    mov al, [op]
    cmp al, '+'
    je soma
    cmp al, '-'
    je subtracao
    cmp al, '*'
    je multiplicacao
    cmp al, '/'
    je divisao
    ret

soma:
    mov al, [num1]
    mov bl, [num2]
    add al, bl
    mov byte[resultado], al
    ret

subtracao:
    mov al, [num1]
    mov bl, [num2]
    sub al, bl 
    mov byte[resultado], al
    ret  

multiplicacao:
    mov al, [num1]
    mov bl, [num2]
    mul bl
    mov byte[resultado], al
    ret

divisao:
    mov al, [num1]
    mov bl, [num2]
    div bl
    mov byte[resultado], al 
    ret

imprime_resultado:
    mov ah, 0Eh       ; Função "Teletype output" (imprime caractere na tela)
    mov al, byte[resultado]; Caractere a ser impresso (pode ser um registrador, ex.: `mov al, bl`)
    mov bl, 07h       ; Cor (07h = cinza claro, fundo preto)
    int 10h           ; Chama a interrupção do BIOS
    ret

segment data
    entrada times 101 db 0  ; String para armazenar até 100 caracteres + terminador
    variaveis times 100 db 0 ; Array para armazenar caracteres individuais
    num1 db 0
    num2 db 0
    resultado db 0
    digito1_numero1 db 0
    digito2_numero1 db 0
    digito1_numero2 db 0
    digito2_numero2 db 0
    op db 0        ; Operador (+, -, *, /)
    sinal1 db 0 ; Operador primeiro número (-)
    sinal2 db 0 ; Operador segundo número  (-)

segment stack stack
    resb 256
stacktop:
