name "number"                        ; output file name (max 8 chars for DOS compatibility)   

use16			    
org 100h		   

begin:
    ; input of first number
    mov di, input_first_number_message
    call PRINT_STRING
    call PRINT_ENDLINE
    call INPUT_NUMBER
    mov cx, ax
    
    ;input of second number
    mov di, input_second_number_message
    call PRINT_STRING
    call PRINT_ENDLINE
    call INPUT_NUMBER
    mov bx, ax
    
    ; ALGORITHM
    
    ; AND operation
    mov ax, cx
    and ax, bx
    call PRINT_ENDLINE
    mov di, and_result_message
    call PRINT_STRING
    call PRINT_NUMBER   
    
    ; OR operation
    mov ax, cx
    or ax, bx
    call PRINT_ENDLINE
    mov di, or_result_message
    call PRINT_STRING
    call PRINT_NUMBER    
    
    ; XOR operation
    mov ax, cx
    xor ax, bx
    call PRINT_ENDLINE
    mov di, xor_result_message
    call PRINT_STRING
    call PRINT_NUMBER    
    
    ; NOT operation
    mov ax, cx;
    not ax
    call PRINT_ENDLINE 
    mov di, not_result_message
    call PRINT_STRING
    call PRINT_NUMBER
    call PRINT_ENDLINE     
        
    call EXIT

; **** PROCEDURES ****

; Procedure for input number through the console
; output: ax - will contain input value 
INPUT_NUMBER:
    mov di, input_number_message
    call PRINT_STRING		   
    call INPUT_DECIMAL_WORD
    call PRINT_ENDLINE		   
    jc INPUT_NUMBER_ERROR
    ret  	    
INPUT_NUMBER_ERROR:
    mov di, error_message
    call PRINT_STRING		    
    jmp INPUT_NUMBER	    	    

EXIT:
    mov di, press_any_key_message
    call PRINT_STRING		    
    mov ah,8		    
    int 21h

    mov ax,4C00h	    
    int 21h		   

INPUT_DECIMAL_WORD:
    push dx		    
    mov al, 6                           ;put to al max size of input number digits - 1, last - $		    
    call INPUT_STRING	    
    call STRING_TO_DECIMAL_WORD   
    pop dx		    
    ret

STRING_TO_DECIMAL_WORD:
    push cx		   
    push dx
    push bx
    push si
    push di
                                        
    mov si,dx		                    ;put to si address of string
    mov di,10                           ;put to di multiplier according radix(10)               		    
    mov cx,ax 	                        ;put to cx length of string = cycle counter
    jcxz INPUT_ERROR	                ;if length of string = 0, call error function
    xor ax,ax		    
    xor bx,bx		    

INPUT_LOOP:
    mov bl,[si]                         ;put to bl next symbol of string    	    
    inc si		    
    cmp bl,'0'		                    ;if ascii code of symbol less than code of'0'
    jl INPUT_ERROR	                    ;call error function
    cmp bl,'9'		                    ;if ascii code of symbol greater than code of'9'
    jg INPUT_ERROR	                    ;call error function
    sub bl,'0'		                    ;transforming symbol-digit into digit
    mul di		                        ;ax = ax*10
    jc INPUT_ERROR	                    ;if result if greater that 16 bits - call error function
    add ax,bx		                    ;add digits to result 
    jc INPUT_ERROR	                    ;if ax is overflow - call error function
    loop INPUT_LOOP	    
    jmp INPUT_END	                    ;successful input of number

INPUT_ERROR:
    xor ax,ax		                    ;set CF = 1 (error flag)
    stc 		    

INPUT_END:
    pop di		   
    pop si
    pop bx
    pop dx
    pop cx
    ret

; Procedure for input of string
; Input: al - max length of string (without symbol CR)
; Output: al - length of input string (without symbol CR)
;         dx - address of string that ends with CR(0dh)
INPUT_STRING:                           
    push cx		    
    mov cx,ax		   
    mov ah,0Ah		    
    mov [buffer],al	                    ;put to 1st byte max_length of string
    mov byte[buffer+1],0                ;2nd byte = 0 - actual length of input string
    mov dx,buffer	                    ;move to dx address of buffer
    int 21h		    
    mov al,[buffer+1]                   ;put to al size of input string	    
    add dx,2		                    ;forward value in dx to actual value of string without metadata
    mov ah,ch		                    ;reestablish value of ah
    pop cx		    
    ret

; Procedure of output of string througth the console
; input: di - address of string
PRINT_STRING:
    push ax
    mov ah,9		    
    xchg dx,di		    
    int 21h		    
    xchg dx,di		    
    pop ax
    ret

; Procedure for output endline through the console
PRINT_ENDLINE:
    push di
    mov di,endline	    
    call PRINT_STRING	
    pop di
    ret

; Procedure for output number through the console
PRINT_NUMBER:
    push di
    mov di,buffer	   
    push di		   
    call DECIMAL_WORD_TO_STRING  
    mov byte[di],'$'	    
    pop di		    
    call PRINT_STRING	   
    pop di
    ret

; Procedure for transforming decimal word (number) through the console   
DECIMAL_WORD_TO_STRING:                
    push ax
    push cx
    push dx
    push bx
    xor cx,cx		    
    mov bx,10		                      ;put to bx divider according radix(10)

NUMBER_TO_STRING_LOOP1:		              ;cycle for getting fission residues
    xor dx,dx		    
    div bx		                          ;ax = ax/bx, fission residue in dx
    add dl,'0'		                      ;transforming digit into symbol according ascii code
    push dx		    
    inc cx		    
    test ax,ax		                      ;checking ax, if needs modifies flag ZF 
    jnz NUMBER_TO_STRING_LOOP1	          ;if ZF = 0 continue

NUMBER_TO_STRING_LOOP2:		              ;cycle for extracting symbols from stack
    pop dx		                          ;put to dx symbol from stack
    mov [di],dl 	                      ;saving symbol if buffer
    inc di		                          ;incrementing address of buffer
    loop NUMBER_TO_STRING_LOOP2	    

    pop bx
    pop dx
    pop cx
    pop ax
    ret
    
input_number_message  db 'input number: $'
error_message  db 'ERROR!',13,10,'$'
and_result_message db 'Result of AND operation between input numbers: $'
or_result_message db 'Result of OR operation between input numbers: $'
xor_result_message db 'Result of XOR operation between input numbers: $'
not_result_message db 'Result of NOT operation on first number: $'
input_first_number_message db 'Input first number$' 
input_second_number_message db 'Input second number$'
press_any_key_message	 db 'Press any key...$'
endline  db 13,10,'$'
buffer	 rb 9
string_number db 5 dup(?),'$'
string_end = $-1  
    
