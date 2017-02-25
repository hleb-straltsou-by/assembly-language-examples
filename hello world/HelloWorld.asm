name "hello"                        ; output file name (max 8 chars for DOS compatibility)   

.model tiny
.code
start:
        mov     ah, 9h	            ; show string on the display
        mov     dx, hello           ; put address of hello to register dx
        int     21h	                ; return control to DOS    
    
        mov     ax, 4c00h           ; to close the program put value 4c00h(4C - number of 
                                    ; DOS function, 00 - return code) to register ax
        int     21h
hello:  db 'Hello, world!$'         ; db reserved place for data
end start





