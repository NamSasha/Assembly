section .data
  prompt1 db 'Enter a message: ',0
  prompt1_len equ $-prompt1
  prompt2 db 'You entered: ',20h,0
  prompt2_len equ $-prompt2
  string_input db 255           ; reseved 255 byte for string_input

section .bss
    string_len resb 1000        ; reseved 1000 byte for string_input length

section .text

    global _main
_main:
    ; write prompt1
    mov eax, 4                  ; call sys to write 
    mov ebx, 1                  ; description for stdout
    mov ecx, prompt1            ; move address to ecx
    mov edx, prompt1_len        ; setup size for prompt1
    int 0x80                    ; interrupt sys

    ; read input
    mov eax, 3                  ; call sys to read
    mov ebx, 0                  ; description for stdin
    mov ecx, string_input       ; move address to ecx
    mov edx, 255                ; setup 255 byte for string_input 
    int 0x80                    ; interrupt sys

    ;get string_input length
    xor eax, eax                ; clear eax
    mov al, [string_len]        ; copy value of length to al register
    sub eax, 1                  ; remove the line feed character


    ; write prompt2
    mov eax, 4                  ; call sys to write
    mov ebx, 1                  ; description for stdout
    mov ecx, prompt2            ; move address to ecx
    mov edx, 15                 ; setup size for prompt2
    int 0x80                    ; interrupt sys

    ; write input
    mov eax, 4                  ; call sys to write
    mov ebx, 1                  ; description for stdout        
    mov ecx, string_input       ; move address to ecx
    mov edx, string_len         ; setup size for string_input
    int 0x80                    ; interrupt sys

    ; exit
    mov eax, 1                  ; call sys to exit
    xor ebx, ebx                ; get exit status (return 0)            
    int 0x80                    ; interrupt sys
