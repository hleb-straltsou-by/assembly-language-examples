.model tiny
.386 
.code    
org     100h
start:  
jmp install_handler
 
text db 50 dup(0)  
buf db 60 dup(0)
text_size dw ?
endl db 13,10 
timer db 0 
result_txt db "/result.txt",0 
text_pref db "///////////////////",13,10 
new_cycle_of_search db 1 
error db "Error! There is no input word for searching in command line arguments$",13,10

handler   proc          ; procedure of interruption handling of timer 
    pusha			  	; put all RONs to stack	
    push 0B800h			; put begining of the video buffer to stack
    pop es				
    push cs
    pop ds   
     
    cmp timer, 91
    jge main
    inc timer
    jmp not_found

main: 
    
    mov new_cycle_of_search, 1
    mov timer, 0      
    xor bx, bx
    
pre_found:
    xor di, di
    mov al, text[di]       
        
find_firt_letter:
    cmp es:[bx], al
    je check_word 
    cmp bx, 0FA0h
    je not_found
    inc bx
    jmp find_firt_letter
    
check_word:					 ; after finding first corresponding letter compare left symbols
    add bx,2
    inc di
    cmp di, text_size
    je found 
    mov al, text[di]     
    cmp es:[bx], al
    jne pre_found   
    jmp check_word   
    
found:         
    lea dx, result_txt        ; way to open file
    mov ah, 3Dh               ; function for open file 
    mov al, 01b               ; flag for writing
    int 21h
     
    mov si, bx
    push bx
    
    mov bx,ax
             
    mov ah, 42h               ; offset utpf for
    xor cx, cx  
    xor dx, dx
    mov al, 2
    int 21h      
    
    xor di, di
    sub si, text_size
    sub si, text_size
    sub si, 6
    mov cx, text_size
    add cx, 6
copy_loop: 				      ; copy finding fragment to the file 
    mov al, es:[si]
    mov buf[di], al
    inc di
    add si, 2
    loop copy_loop 
    
    cmp new_cycle_of_search, 1
    jne skip_pref
    mov new_cycle_of_search, 0
    
    mov ah, 40h                        ; output of string into file
    lea dx, text_pref  
    mov cx, 50                         ; count of bytes in string
    int 21h     

skip_pref:          
    mov ah, 40h                        ; output string into file
    lea dx, buf  
    mov cx, text_size
    add cx, 6
    int 21h 
       
    mov ah, 40h                        ; output string into file
    lea dx, endl  
    mov cx, 2
    int 21h         
                    
    mov ah,3Eh                         ; function of closing the file
    int 21h
    
    pop bx
    jmp pre_found
    
not_found:  
    popa
    db 0EAh                             ; begining of command code JMP FAR
    old_9h dd ?                         ; calling of old handler 
    iret
handler endp                            ; end of handler procedure 

install_handler:   
  
    lea di, text         
    call parseCommandLineArgs     
    
    xor cx, cx
    mov ah, 3Ch                                  ; creating of file
    lea dx, result_txt
    int 21h
     
    mov ah,3Eh                                   ; funciton of closing the file
    int 21h
    
    mov ah, 35h 								 ; get address of handler
    mov al, 08h                                  ; interruption for timer, 08 - number of handler vector 
    int 21h                                         
        
    mov word ptr old_9h, bx                      ; saving offset of handler
    mov word ptr old_9h+2, es                    ; saving of segment of handler
    
    mov ah, 25h 							     ; set address of handler
    mov al, 08h									 ; 08h set number of handler vector
    mov dx,offset handler                        ; write offset of out handler
    int 21h 
    
    mov ah, 31h                                  ; function of DOS to left programs resident  
    mov al, 00h                                  ; returning code
    mov dx,(install_handler - start + 10Fh)/16   ; size of resident part of program in paragraphs
    int 21h     
    

    
parseCommandLineArgs PROC                               ; procedure for parsing command line
    xor cx,cx          
    mov si, 80h
    mov cl, es:[si]                              ; count of symbols in command line 
    cmp cx, 0
    je error_line_exit
    
    inc si
cycle:       
    mov al, es:[si] 
    cmp al, ' '
    je next_step 
    cmp al, 13
    je next_step
    mov [di], al   
    inc di 
    inc text_size
next_step:
    inc si 
    loop cycle
    
    cmp text_size, 0
    je error_line_exit
    cmp text_size, 50
    jge error_line_exit
    ret  
    
error_line_exit:
    mov ah, 09h  
    lea dx, error
    int 21h
    mov ah, 4ch
    int 21h
endp
    
end start