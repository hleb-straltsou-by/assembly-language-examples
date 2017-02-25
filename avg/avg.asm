name "avg"   ; output file name (max 8 chars for DOS compatibility)

.model small    ; define model of memory
.stack 100h     ; define size of stack
.data
len equ 10      ; count of elements in array, len equil to 10
array db 4,1,7,2,9,3,6,7,0,8
.code
start:
    mov     ax, @data        ; copy to ax adress of the begging of data segment
    mov     ds, ax           ; copy to ds
    xor     ax, ax           ; ax = 0
    xor     si, si           ; si = 0
    mov     cx, len          ; cx = len
cycl: 
    add     al, array[si]    ; add to al current element of array
    inc     si               ; go to next element in array
    loop    cycl
    
    mov     bl, len          ; bl = len  
    div     bl               ; getting avg   
       
    mov     ax, 4c00h
    int     21h        
end start






