       .8086
DATA   segment
STRING db "Hello, World!", 13, 10, "$"
DATA   ends

CODE   segment
       assume cs:CODE, ds:DATA
START:
       MOV AX, seg DATA
       MOV DS, AX
       MOV AH, 9   ; DOS function to display string
       MOV DX, offset STRING ; Load effective address of message
       INT 21h     ; invoke DOS function
       MOV AH, 4Ch ; DOS function to exit program
       INT 21h     ; invoke DOS function
CODE   ends

STACK  segment stack
       assume  ss:STACK
       dw      64 dup(?)
STACK  ends

       end     START
