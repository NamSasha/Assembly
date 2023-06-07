section .data
    prompt1 db 0Ah,"Enter the string S: ",0
    stringS db 256 dup(?)
    prompt2 db 0Ah,"Reverse order: ",0
    stringR db 256 dup(?)
    space db 0Ah,0Dh,0
section .text
    global _start

_start:
    mov rax, prompt1
    call _print

    mov rax, 0
    mov rdi, 0
    mov rsi, stringS
    mov rdx, 100
    syscall

    mov rax,stringS
    lea rsi,stringS
    lea rdi, stringR
    call _IterateStringS
   
    mov rax, prompt2
    call _print

    mov rax,stringR
    call _print

    mov rax,space
    call _print

    ;system exit
    mov rax, 60
    mov rdi,0 
    syscall

_print:
    push rax  ;store rax to the stack
    mov rbx,0 ; innitial rbx to count length
_printLoop:
    inc rax ; increase memory location by 1 
    inc rbx ; ++ rbx
    mov cl,[rax] ; take only 1 charater from the current location by moving down from 64bit to 8bit
    cmp cl,0 ; compare and end loop when it reach the '/0' terminator 
    jne _printLoop

    ; print out the string
    mov rax,1 
    mov rdi,1
    pop rsi ; the reason using pop rsi because I had store rax to the stack
    mov rdx, rbx ; the length of the string
    syscall

    ret

_IterateStringS:
    mov rbx,0
    inc rbx
    inc rsi
    mov cl, [rsi]
    cmp cl,10 ;10 in new line when user input string
    jne _IterateStringS
    je _reverse
_reverse:
    dec rsi
    mov cl,[rsi]
    mov [rdi],cl
    inc rdi
    cmp rsi,rax
    jne _reverse
    ret
