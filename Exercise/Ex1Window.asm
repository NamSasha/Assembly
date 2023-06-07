
; To assemble to .obj: nasm -f win32 helloworldWindow.asm
; To compile to .exe:  gcc helloworldWindow.obj -o helloworld.exe
; ------------------------------------------------------------------

        global    _main                ; declare main() method
        extern    _printf              ; link to external library

        section  .data
        message: db   "Hello World",0Dh,0Ah,0  ; text message
                    ; 0Dh carriage return
                    ; 0Ah newline
                    ; 0 terminates the line

        ; code is put in the .text section
        section .text
_main:                            ; the entry point! void main()
        push    message           ; save message to the stack
        call    _printf           ; display the first value on the stack
        add     esp, 4            ; clear the stack
        ret                       ; return