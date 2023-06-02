global _main                ; declare main() method
extern _printf  
extern _scanf

    section  .data
        prompt1: db "Enter a string:",0  ; text message
                                        ; 0 terminates the line
        prompt2: db "You entered: ",0   
        format: db "%s",0 ; format string for scanf
    section .bss
        string: resb 1000 ; reseved 1000byte for string


    section .text
_main:                         ; the entry point! void main()
    push ebp                   ; stores the value of the current base pointer onto the stack
    mov ebp,esp                ; copies the current stack pointer to the base pointer  (EBP)

        ;input prompt1
        push prompt1           ; save prompt1 to the stack
        call _printf           ; display value on the stack
        add  esp, 4            ; clear the stack

        ;input string
        push string            ; save string to the stack
        push format            ; save format type to the stack
        call _scanf            ; reading values from scanf to stack
        add esp,8              ; clear stack with 8byte

        ;input prompt2 
        push prompt2           ; save prompt2 to the stack
        call _printf           ; display the value on the stack
        add esp, 4             ; clear the stack

        ;print the input from user
        push string            ; save string to the stack
        call _printf           ; display the value on the stack
        add esp, 4             ; clear the stack   

    mov esp,ebp                ; move base pointer to current position
    pop ebp                    ; remove ebp from the stack
    ret                      ; return
