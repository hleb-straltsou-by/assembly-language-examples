.model small
.stack 256

.data 
    MSG1 db 10, 13, "Enter any string: $"
    MSG2 db 10, 13, "Reverse string is: $"
    ENDL db 10, 13, "$"
    LENGTH equ 200
    STRING db LENGTH            ; max count of chars
           db ?                 ; count of chars entered by user
           db LENGTH dup(0)     ; chars entered by user 
           
DISPLAY_READY macro MSG
    mov ah, 09h
    mov dx, offset ENDL
    int 21h
    mov ah, 09h
    mov dx, offset MSG
    int 21h 
endm

DISPLAY_RAW macro MSG
    mov ah, 09h
    mov dx, offset ENDL
    int 21h
    mov ah, 09h
    mov dx, offset MSG+2        ; must end with '$'
    int 21h
endm

INPUT macro BUFF
    mov ah, 0ah
    mov dx, offset BUFF
    int 21h
    
    mov si, offset buff+1       ; number of entered chars
    mov cl, [si]                ; move length to cl
    mov ch, 0                   ; clear ch to use cx
    inc cx                      ; to reach chr(13)
    add si, cx                  ; now si points to chr(13) 
    mov al, "$"
    mov [si], al                ; replaxe chr(13) by '$'  
endm 

.code
start:
    mov ax, @data
    mov ds, ax
    
    DISPLAY_READY MSG1
    INPUT STRING
    DISPLAY_RAW STRING
    DISPLAY_READY MSG2
    DISPLAY_RAW STRING
    
    mov ax, 4c00h
    int 21h
end start 
code ends








