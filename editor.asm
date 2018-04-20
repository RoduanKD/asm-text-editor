.model tiny
.code

org 100h

program:    

    mov  curr_line, offset matrix
    mov  curr_char, 0

start:
;CAPTURE KEY.
    mov  ah, 0
    int  16h  

;EVALUATE KEY.    
    cmp  al, 27          ; ESC
    je   fin
    cmp  ax, 4800h       ; UP.
    je   moveUp
    cmp  ax, 4B00h       ; LEFT.
    je   moveLeft
    cmp  ax, 4D00H       ; RIGHT.
    je   moveRight
    cmp  ax, 5000h       ; DOWN.
    je   moveDown
    cmp  al, 32
    jae  any_char
    jmp  start   

;DISPLAY LETTER, DIGIT OR ANY OTHER ACCEPTABLE CHAR.
any_char:
    mov  ah, 9
    mov  bh, 0
    mov  bl, color                            
    mov  cx, 1           ; how many times display char.
    int  10h             ; display char in al.
;UPDATE CHAR IN MATRIX.    
    mov  si, curr_line   ; si points to the beginning of the line.
    add  si, curr_char   ; si points to the char in the line.
    mov  [ si ], al      ; the char is in the matrix.   

;!!! EXTREMELY IMPORTANT : PREVIOUS BLOCK DISPLAYS ONE
;CHAR, AND NEXT BLOCK MOVES CURSOR TO THE RIGHT. THAT'S
;THE NORMAL BEHAVIOR FOR ALL EDITORS. DO NOT MOVE THESE
;TWO BLOCKS, THEY MUST BE THIS WAY. IF IT'S NECESSARY
;TO MOVE THEM, ADD A JUMP FROM ONE BLOCK TO THE OTHER.

;RIGHT.
moveRight:
    inc  curr_char       ; update current char.
    mov  dl, posX
    mov  dh, posY
    inc  dl              ; posX ++
    mov  posX, dl
    jmp  prntCrs

;LEFT.
moveLeft:
    dec  curr_char       ; update current char.
    mov  dl, posX
    mov  dh, posY
    dec  dl              ; posX --
    mov  posX, dl
    jmp  prntCrs

;UP.
moveUp: 
    sub  curr_line, 80   ; update current line.
    mov  dl, posX
    mov  dh, posY
    dec  dh              ; posY -- 
    mov  posY, dh
    jmp  prntCrs         ; print cursor

;DOWN.
moveDown:   
    add  curr_line, 80   ; update current line.
    mov  dl, posX
    mov  dh, posY
    inc  dh              ; posY ++
    mov  posY, dh
    jmp  prntCrs        

prntCrs:                 ; print cursor
    mov  ah, 2h
    int  10h
    jmp  start

fin:
    int  20h 

posX      db 1 dup(0)        ; dh = posX -> controls row
posY      db 1 dup(0)        ; dl = posY -> controls column
matrix    db 80*25 dup(' ')  ; 25 lines of 80 chars each.
curr_line dw ?
curr_char dw ?
color     db 2*16+15
;FOR COLORS USE NEXT TABLE:
;http://stackoverflow.com/questions/29460318/how-to-print-colored-string-in-assembly-language/29478158#29478158

end program
