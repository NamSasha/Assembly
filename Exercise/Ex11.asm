section .data
    num1 db 100 dup(?) 
    num2 db 100 dup(?) 
    negative db "-",0
    prompt1 db 0Ah,"Choose operator: ",0Dh,0Ah,'1.Addition',0Dh,0Ah,'2.Subtraction',0Dh,0Ah,'3.Multiplication',0Dh,0Ah,'4.Division',0Ah,0
    input db 0
    input1 db 0Ah,"Enter the first Integer: ",0
    input2 db 0Ah,"Enter the second Interger: ",0
    output1 db 0Ah,"The result is: ",0
    output2 db 0Ah,"The remainder is: ",0

    x db 0
    y db 0

section .bss
    digitSpace resb 100 ; to store the string
    digitSpacePos resb 4 ; to store the location of the string's character

section .text
    global _start

_start:
    ;printprompt1
    mov rax,prompt1
    call _print

    ;get input choose operand
    mov rax,0
    mov rdi,0
    mov rsi,input
    mov rdx,10
    syscall

    ;printpromptinput1
    mov rax,input1
    call _print

    ;get num1
    mov rax,0
    mov rdi,0
    mov rsi,num1
    mov rdx,32
    syscall

    ;printpromptinput2
    call _clearmem
    mov rax,input2
    call _print

    ;get num2
    mov rax,0
    mov rdi,0
    mov rsi,num2
    mov rdx,32
    syscall

    ;substract '0' to convert to number and compare
    call _clearmem
    mov rax,input
    mov cl, [rax]
    sub cl, '0'
    cmp cl,1
    je _add
    clc

    mov rax,input
    mov cl, [rax]
    sub cl, '0'
    cmp cl,2
    je _sub
    clc

    mov rax,input
    mov cl, [rax]
    sub cl, '0'
    cmp cl,3
    je _mul
    clc

    mov rax,input
    mov cl, [rax]
    sub cl, '0'
    cmp cl,4
    je _div
    clc

 _add:
    call _clearmem
    mov rax, num1
    call _strtonum1
    add r8,[y]

    call _clearmem
    mov rax, num2
    call _strtonum1
    add r8,[y]
    ; store result in r8
    ;print result prompt
    mov rax,output1
    call _print

    mov rax, r8
    call _numtostr

    mov rax,60
    mov rdi,0
    syscall
 _sub:
    call _clearmem
    mov rax, num1
    call _strtonum1
    add r8,[y]

    call _clearmem
    mov rax, num2
    call _strtonum1
    cmp r8,[y] ;cmp if num1 is greater or smaller than num2
    jl _swap
    sub r8,[y]  ;store result in r8
    
    ;print result prompt
    mov rax,output1
    call _print

    ;print result
    mov rax, r8
    call _numtostr

    mov rax,60
    mov rdi,0
    syscall

  _swap:;if num2 is greater than num1, swap num1 and num2
    mov rax,[y]
    sub rax,r8; store result in rax

    push rax ;push result to stack
    mov rax,output1;print result prompt
    call _print
    mov rax,negative ;print the negative sign
    call _print
    pop rax ; get result back to rax and print
    call _numtostr

    mov rax,60
    mov rdi,0
    syscall

 _mul:
    call _clearmem
    mov rax, num1
    call _strtonum1
    add r8,[y]

    call _clearmem
    mov rax, num2
    call _strtonum1
    mov rax,r8
    mov r8,[y]
    imul r8
    mov r8,rax
    
    ;print result prompt
    mov rax,output1
    call _print
    ;print result
    call _clearmem
    mov rax, r8
    call _numtostr

    mov rax,60
    mov rdi,0
    syscall
 _div: ;the value when we div is store in rax, the remainder is store at rdx

    call _clearmem
    mov rax, num1
    call _strtonum1
    add r8, [y]

    call _clearmem
    mov rax, num2
    call _strtonum1
    mov rax, r8
    mov r8,[y]
    div r8
    push rdx
    mov r8,rax

    ;print result prompt
    mov rax,output1
    call _print
    ;print result
    call _clearmem
    mov rax, r8
    call _numtostr
    ;print remainder prompt
    mov rax,output2
    call _print
    ;print remainder
    pop rdx
    mov rax,rdx
    call _numtostr

    mov rax,60
    mov rdi,0
    syscall

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

; function2: convert string to num   
_strtonum1:
    mov cl,[rax]        ;the same with function1, the key is to iterate through the string
    cmp cl,10          ;compare to 10, 10 is newline in acsii
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

;convert num to string
_numtostr: ;convert number to string
    mov rcx, digitSpace         
    mov rbx,10
    mov [rcx], rbx ;Store 10 in position digitSpace[0]
    inc rcx         ; move to next position (+1)
    mov [digitSpacePos],rcx ;store the position to to digitspacePos 

 _numtostr1:             ; the function to divide the number. The remainder store in rdx, the value store in rax 
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

; clear memory
_clearmem:
    mov dword [x],0
    mov dword [y],0
    mov dword [digitSpace],0
    mov dword [digitSpacePos],0
    xor rax,rax
    xor rdx,rdx
    xor rcx,rcx
    xor rbx,rbx
    xor rsi,rsi
    xor rdi,rdi
    ret    