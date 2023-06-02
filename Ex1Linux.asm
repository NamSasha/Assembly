; To assemble to .obj: nasm -elf64  -o  helloworldLinux.o helloworldLinux.asm
; To compile: ld helloworldLinux.o -o helloworldLinux
; To run: ./helloworldLinux

section .data
    msg: db 'Hello, world',0Ah,0Dh,0 ; define 1-byte string, 0Ah,0Dh-addnewline,move to beginning of line
                                    ; 0 string-terminator
    len equ $-msg                   ; string length (subtract address from msg) ($-msg)

section .text
    global _start ;set entry point
_start:
    ; write the message    
    mov eax, 4  ;systemcall (sys_write)
    mov ebx, 1  ;set value of stdout descriptor to 1
    mov ecx, msg ;move address of msg to ecx register
    mov edx, len ; set up how many byte to use for msg
    int 80h ; syscall (interrupt)

    ;exit program
    mov eax, 1 ;systemcall (sys_exit)
    xor ebx, ebx ; set ebx register to 0 (return 0)
    int 80h ;exit program with return code 0