.MODEL small
.STACK 100h

.CODE
BEGIN:
mov ax, @data
mov ds, ax
mov es, ax       
xor ax, ax

lea dx, MSG1
call OUTPUT_STRING

lea dx, str1_
call INPUT_STRING

lea dx, MSG2
call OUTPUT_STRING

lea dx, str2_
call INPUT_STRING

xor cx, cx
mov cl, str1l       ; put to cx count of chars in main string
sub cl, str2l       ; substract from cx count of chars in substring
inc cl              ; increase counter
cld                 ; clear direction flag
lea di, str2        ; put to di address of substring
lea si, str1        ; to to si address of main string
xor ax, ax

CHECK_STRING:       ; repeated for length of str1 - length of str2 
call SEARCH_SUBSTRING
inc si
loop CHECK_STRING

lea dx, MSG3
call OUTPUT_STRING
lea dx, str1
call OUTPUT_STRING 

END:
mov ax, 4c00h
int 21h

; **** Procedures ****

; Procedure for input string
; address of buffer, where string will be stored, must be saved in dx
INPUT_STRING proc
push ax
mov ah, 0ah
int 21h
pop ax
ret
INPUT_STRING endp

; Procedure for output string
; address of buffer, which will be used for output, must be saved in dx
OUTPUT_STRING proc
push ax
mov ah, 09h
int 21h
pop ax 
ret
OUTPUT_STRING endp

; Procedure for searching entry point of substring, which address is stored in di,
; in main string, which address is stored in si.
; if entry point of substring is found then will be called DELETE procedure for
; found char
SEARCH_SUBSTRING proc
push cx
push di
push si
mov bx, si
mov cl, str2l
repe cmpsb              ; comparing bytes from addresses di and si
je _EQ
jne _NEQ
_EQ:
                        ; di points str2, si points end of substring 
call DELETE
inc al
_NEQ:
pop si
pop di
pop cx
ret
SEARCH_SUBSTRING endp

DELETE proc
push bx
push di
push si
mov di, bx 
xor cx, cx
mov cl, str1l
repe movsb              ; send byte from di to si
pop si
pop di
pop bx
ret
DELETE endp

.DATA
MSG1 DB "Enter string: $"
MSG2 DB 0Ah, 0Dh, "Enter substring to delete: $"
MSG3 DB 0Ah, 0Dh, "String after removing substring: $"
LENGTH equ 200
str1_ DB LENGTH
str1l DB '$'
str1 DB LENGTH dup('$')

str2_ DB LENGTH
str2l DB '$'
str2 DB LENGTH dup('$')

end BEGIN

