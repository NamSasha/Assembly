section .data
    num1 db 10 dup(?)
    input1 db 0Ah,"Enter Fibonacci Quantity Number: ",0
    x db 0
    y db 0
section .bss

    digitSpace resb 1000
    digitSpacePos resb 4
    
section .text
    global _start

_start:
    ;print promt1
    mov r12,0
    mov rax, input1
    call _print

    ;print number input1
    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 32
    syscall
    
    
    call _clearmem
    mov rax, num1
    call _strtonum1
    mov r12,[y]
    call _clearmem

    mov r10,0
    mov r8,0
    mov r9,1
    call _fibo

    mov rax, 60
    mov rdi,0 
    syscall
_fibo:
    inc r10
    push rbp
    mov rbp,rsp

        push r8
        mov rax,r8
        call _numtostr
        call _clearmem

        pop r8
        
    mov rsp,rbp
    pop rbp  
    cmp r10,r12
    je _ret
    clc
    
    inc r10
    push rbp
    mov rbp,rsp

        push r9
        mov rax,r9
        call _numtostr
        call _clearmem

        pop r9
        
    mov rsp,rbp
    pop rbp  

    add r8,r9
    add r9,r8


    cmp r10,r12
    jne _fibo
    ret

_strtonum1:
    mov cl,[rax]        ;the same with function1, the key is to iterate through the string
    cmp cl,10            ;compare to 10, 10 is newline in acsii
    je _strtonum2       ;stop and jump when it reach the newline
    mov [x],cl          ;move value cl into var x
    sub dword [x],48    ;sub x by 48 to get the number in ascii table
    add rdx, [x]        ;store value to rdx
    inc rax             ;rax ++
    imul rdx,10         ;multiply rdx by 10
    jne _strtonum1      ;loop

 _strtonum2:             
    mov rax,rdx         ;copy value rdx to rax
    xor rdx,rdx         ;clear rdx
    mov rcx,10          ;set value in rcx to 10
    div rcx             ;divide rax by 10
    mov [y], rax        ;store value from rax to var y
    ret
; the idea of convert is to iterate through a string, get a single charater, convert to number in ascii table, change to real number by add it up

_numtostr:
    mov rcx, digitSpace
    mov rbx,10
    mov [rcx], rbx
    inc rcx
    mov [digitSpacePos],rcx

 _numtostr1:
    mov rdx,0
    mov rbx,10
    div rbx
    push rax
    add rdx, 48

    mov rcx,[digitSpacePos]
    mov [rcx],dl
    inc rcx
    mov [digitSpacePos],rcx

    pop rax
    cmp rax,0
    jne _numtostr1

 _numtostr2:
    mov rcx, [digitSpacePos]

    mov rax,1
    mov rdi,1
    mov rsi,rcx
    mov rdx,1
    syscall

    mov rcx, [digitSpacePos]
    dec rcx
    mov [digitSpacePos],rcx

    cmp rcx, digitSpace
    jge _numtostr2   

    ret    

_print: ; print the label
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

_clearmem:
    mov dword [x],0
    mov dword [y],0
    mov dword [digitSpace],0
    mov dword [digitSpacePos],0
    xor rax,rax
    xor rdx,rdx
    xor rcx,rcx
    xor rbx,rbx

    ret
_ret:
    ret