section .data
    display db ":0", 0
    windowTitle db "Clock Widget", 0
    msg db "Current time: ", 0
    msgLen equ $ - msg
    timeStr db 20 dup(0)

section .bss
    dpy resq 1
    win resq 1
    gc resq 1

section .text
    extern XOpenDisplay, XCreateSimpleWindow, XMapWindow, XStoreName
    extern XCreateGC, XDrawString, XFlush, XNextEvent, XDestroyWindow
    extern XCloseDisplay, time, localtime, strftime
    extern exit
    global main

main:
    ; Abre a conexão com o X11
    mov rdi, display
    call XOpenDisplay
    mov [dpy], rax

    ; Cria uma janela simples
    mov rsi, 0                  ; border width
    mov rdx, 200                ; height
    mov rcx, 300                ; width
    mov r8, 0                   ; y
    mov r9, 0                   ; x
    mov rdi, [dpy]              ; display
    mov rsi, 0                  ; window parent
    call XCreateSimpleWindow
    mov [win], rax

    ; Define o título da janela
    mov rdi, [win]
    mov rsi, windowTitle
    call XStoreName

    ; Mapeia a janela
    mov rdi, [win]
    call XMapWindow

    ; Cria um contexto gráfico
    mov rdi, [win]
    mov rsi, [dpy]
    call XCreateGC
    mov [gc], rax

main_loop:
    ; Captura o tempo atual
    call time
    mov rdi, rax               ; argumento para localtime
    call localtime

    ; Formata a string
    lea rdi, timeStr
    mov rsi, 20                ; tamanho da string
    mov rdx, msg               ; mensagem
    call strftime

    ; Desenha a string na janela
    mov rdi, [win]             ; janela
    mov rsi, [gc]              ; contexto gráfico
    mov rdx, 10                ; y position
    mov rcx, 10                ; x position
    mov r8, msgLen             ; tamanho da mensagem
    call XDrawString

    ; Atualiza a janela
    mov rdi, [dpy]
    call XFlush

    ; Espera por eventos (loop infinito por enquanto)
    jmp main_loop

cleanup:
    mov rdi, [win]
    call XDestroyWindow
    mov rdi, [dpy]
    call XCloseDisplay
    ret

