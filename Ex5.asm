section .data
    stringS db 100 dup(?)
    stringC db 10 dup(?)
    prompt1 db 0Ah,"Enter the string S: ",0
    prompt2 db 0Ah,"Enter the string C: ",0
    prompt3 db 0Ah,"Appearance: ",0
    prompt4 db 0Ah,"Location: ",0
section .bss
    digitSpace resb 100
    digitSpacePos resb 4

section .text
    global _start

_start: ;get input, matching 2 string, print output
   ;system call for input
    mov rax, prompt1
    call _print

    mov rax, 0
    mov rdi, 0
    mov rsi, stringS
    mov rdx, 100
    syscall

    mov rax, prompt2
    call _print

    mov rax, 0
    mov rdi, 0
    mov rsi, stringC
    mov rdx, 10
    syscall


    ;get pointer and print location
    mov rax, prompt4
    call _print

    call _clearmem
    lea rdi, [stringS]
    lea rsi, [stringC]
    xor r8,r8
    call _match

    ;print appereance
    mov rax, prompt3
    call _print

    call _clearmem
    mov rax,r10
    call _numtostr


    ;system exit
    mov rax, 60
    mov rdi, 0
    syscall

_match: ;compare case1 for matching characters    
    mov dl, [rdi]
    mov cl, [rsi]
    cmp cl,dl
    je _inc
    jne _loop2

 _inc: ;increaase pointer and counter
    inc r8
    inc r9
    inc rdi
    inc rsi
    mov dl, [rdi]
    mov cl, [rsi]
    jmp _checkconditionrdi
 _checkconditionrdi:;check the end of StringS 
    cmp dl,0
    je _ret
    jne _checkconditionrsi
 _checkconditionrsi:;check the end of StringC
    cmp cl,10
    je _subrsi
    jne _match1
 _subrsi:;decrese counter StringC and print out the location
    sub r9,r8
        push rbp
        mov rbp,rsp

        push rcx
        push rsi
        push rdi
        
        call _clearmem
        mov rax,r9
        call _numtostr

        pop rdi
        pop rsi
        pop rcx

        mov rsp,rbp
        pop rbp     


    add r9,r8

    inc r10
    sub rsi,r8
    xor r8,r8
    jmp _match
 _match1:;compare case2
    mov dl, [rdi]
    mov cl, [rsi]
    cmp cl,dl
    je _inc
    jne _subloop

 _subloop:;decrase pointer case2
    sub rsi,r8
    xor r8,r8
    jmp _match

 _loop2:;increase pointer StringS
    inc r9
    inc rdi
    mov dl, [rdi]
    cmp dl,0
    je _ret
    jne _match

 _ret:;return with condition
    cmp cl,dl
    je _add1
    ret
 _add1: ;add counter case3 and exit
    inc r10
    sub r9,r8
    
        push rbp
        mov rbp,rsp

        push rcx
        push rsi
        push rdi
        
        call _clearmem
        mov rax,r9
        call _numtostr

        pop rdi
        pop rsi
        pop rcx

        mov rsp,rbp
        pop rbp    

    ret


_numtostr: ;convert from number to string
    mov rcx, digitSpace         
    mov rbx,10
    mov [rcx], rbx ;Store 10 in position digitSpace[0]
    inc rcx         ; move to next position (+1)
    mov [digitSpacePos],rcx ;store the position to to digitspacePos 

 _numtostr1: ; the function to divide the number. The remainder store in rdx, the value store in rax 
    mov rdx,0           ; example 123. divide by 10: 123/10 --> get 12 and remainder 3
    mov rbx,10          ; loop it 3 times we get 321 backwards.
    div rbx
    push rax        ; store the remainder to the stack
    add rdx, 48     ; add 48 to convert to string in ascii table

    ;Store the remainder in digitSpace
    mov rcx,[digitSpacePos]
    mov [rcx],dl ;store value in dl into DigitSpace
    inc rcx
    mov [digitSpacePos],rcx ;update the current position

    pop rax
    cmp rax,0
    jne _numtostr1 ;loop

 ; Print the digits in reverse order 
 _numtostr2:
    mov rcx, [digitSpacePos]

    mov rax,1
    mov rdi,1
    mov rsi,rcx ;print the digit in digitSpace
    mov rdx,1
    syscall

    mov rcx, [digitSpacePos] ; iteratate backwards
    dec rcx ; we printing the revese order so we get the memory location backward
    mov [digitSpacePos],rcx

    cmp rcx, digitSpace
    jge _numtostr2   

    ret

_clearmem:;clear memory for next function
    mov dword [digitSpace],0
    mov dword [digitSpacePos],0
    xor rax,rax
    xor rdx,rdx
    xor rcx,rcx
    xor rbx,rbx
    
    ret

_print:;printout some label
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