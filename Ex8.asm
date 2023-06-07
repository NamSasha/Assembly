section .data

    len1 db 100 dup(?)
    len2 db 100 dup(?) 
    input1 db 100 dup(?)
    input2 db 100 dup(?)
    prompt1 db 0Ah,"Enter the first Integer: ",0
    prompt2 db 0Ah,"Enter the second Interger: ",0
    output1 db 0Ah,"The sum is: ",0
    space db 0Ah,0Dh,0

section .bss
    Sum resb 4
    
section .text
    global _start

_start:

    ;print prompt1
    mov r8,0
    mov rax, prompt1
    call _print

    ;get num input1
    mov rax, 0
    mov rdi, 0
    mov rsi, input1
    mov rdx, 32
    syscall
    
    ;cal len num1
    call _clearmem
    lea rsi,input1
    call _len
    mov [len1],rbx
    call _clearmem

    ;print prompt2
    mov r8,0
    mov rax, prompt2
    call _print

    ;get num input2
    mov rax, 0
    mov rdi, 0
    mov rsi, input2
    mov rdx, 32
    syscall

    ;cal len num2
    call _clearmem
    lea rsi,input2
    call _len
    mov [len2],rbx
    call _clearmem

    ;prefix number
    mov r9,[len1]
    mov r10,[len2]
    call _prefix
    call _clearmem

    ;calculate sum
    lea rsi,input1
    sub rsi,r12
    lea rdi,input2
    lea rax,Sum
    call _initialpointer
    call _clearmem

    ;print prompt output
    mov rax, output1
    call _print

    ;print Sum
    call _clearmem
    lea rax,Sum
    lea r8,Sum
    add r8,[len1]
    add r8,1
    call _checkfirstnumber
    call _clearmem

    mov rax, space
    call _print

    ;system exit
    mov rax,60
    mov rdi,0 
    syscall

; the reason I didnt push r9 and get counter to shift bit at _num2prefix is later I will get the pointer base on num1
_prefix: ;compare length of num1 and num2
    cmp r9,r10
    lea rsi,input1
    lea rdi,input2
    jg _num1greater
    jl _num2greater
    je _ret
 _num1greater: ;get len1-len2 
    sub r9,r10
    jmp _prefixnum2
  _prefixnum2:    ; the idea is add '0' to the first byte of num2
    dec rdi
    mov byte [rdi],48
    dec r9
    cmp r9,0
    jne _prefixnum2
    je _ret
 _num2greater: ; get len2-len1
    push r10
    sub r10,r9
    jmp _prefixnum1
  _prefixnum1: ; the idea is add '0' to the first byte of num2
    inc r12  ;counter to shift bit to the right 
    dec rsi
    mov byte [rsi],48
    dec r10
    cmp r10,0
    jne _prefixnum1
    pop r10
    mov [len1],r10
    mov [len2],r10
    
    je _ret

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


_initialpointer: ;get pointer to the end of both number
    mov r8,rsi
    add rax,[len1]
    add rsi,[len1]
    add rdi,[len2]
    dec rsi
    dec rdi
    jmp _calculate
 _calculate: ;load and pre-processing the single character, convert to number
    cmp rsi, r8
    jl _ret
    mov cl,[rsi]
    mov dl,[rdi]
    sub cl,"0"
    sub dl,"0"
    add cl,bl
    xor rbx,rbx
    dec rsi
    dec rdi
    jmp _add

 _add: ;add 2 single digit
    add cl,dl
    cmp cl,10
    jge _greaterthan10
    mov byte [rax],cl
    dec rax
    jmp _calculate

 _greaterthan10: ;if the sum of 2 single digit >10, sub it by 10 and leave 1 to the next bit
    sub cl,10
    mov byte [rax],cl
    dec rax
    inc rbx ; leave 1 to the next bit
    cmp rsi, r8
    jl _endbyte
    jmp _calculate

 _endbyte: ;we have the Sum to start at bit '0', so when we end with greater than 10 process, simply add 1 to the left bit
    mov byte [rax],1
    ret

_checkfirstnumber: ;if the sum didnt use the first '0' bit, just delete it by increase the pointer at Sum
    mov dl,[rax]
    cmp dl,0
    je _inc
    jmp _printSum

 _inc: ;increase pointer at Sum 
    inc rax
    jmp _printSum    

 _printSum: ;print single bit of variable Sum
    cmp rax,r8
    jge _ret
    
    mov dl,[rax]
    add dl,48
    mov byte [rax],dl
    push rax
    mov rsi,rax
    mov rax,1
    mov rdi,1
    mov rdx,1
    syscall
    pop rax
    inc rax
    jmp _printSum

_len: ;routine to cal length
    inc rbx
    inc rsi
    mov cl,[rsi]
    cmp cl,10
    jne _len
    ret

_ret:
    ret

_clearmem:
    xor rax,rax
    xor rbx,rbx
    xor rcx,rcx
    xor rdx,rdx
    xor rsi,rsi
    xor rdi,rdi
    xor r8,r8
    ret