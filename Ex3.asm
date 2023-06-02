section .data
    num1 db 32 dup(?) 
    num2 db 32 dup(?) 
    input1 db 0Ah,"Enter the first Integer: ",0
    input2 db 0Ah,"Enter the second Interger: ",0
    output1 db 0Ah,"The sum is: ",0
    x db 0
    y db 0
section .bss
    digitSpace resb 100 ; to store the string
    digitSpacePos resb 4 ; to store the location of the string's character


section .text
    global _start

_start:
    ;print promt1
    mov r8,0
    mov rax, input1
    call _print

    ;print number input1
    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 32
    syscall
    
    ;convert input to number and add to r8
    call _clearmem
    mov rax, num1
    call _strtonum1
    add r8, [y]

    ;print prompt2
    mov rax, input2
    call _print

    ;print number input2
    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 32
    syscall

    ;conver input to number and add to r8
    call _clearmem
    mov rax, num2
    call _strtonum1
    add r8, [y]

    ;print prompt3
    mov rax, output1
    call _print

    ;convert sum from number to string and print sum 
    mov rax, r8
    call _numtostr

    ;system exit
    mov rax, 60
    mov rdi,0 
    syscall

    ;function1: print out string
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

    ret