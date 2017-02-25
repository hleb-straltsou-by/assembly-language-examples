.model small 

data segment
    length equ 200
    string db length, length dup ('$')
data ends

code segment
assume cs:code,ds:data
     
start:
    mov ax, data
    mov ds, ax
    
    call input_string
        
    call output_string
        
    mov ax, 4c00h
    int 21h
    
input_string proc
    push ax
    push dx  
    
    mov ah, 0ah
    lea dx, string
    int 21h
    
    mov string+1, 0ah
       
    pop dx
    pop ax
    ret
input_string endp

output_string proc
    mov ah,9
    lea dx,string+1
    int 21h
    ret
output_string endp
    
code ends
end start 







