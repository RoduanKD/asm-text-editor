;;=============================================================================;;
;;                                                                             ;;
;;                          Assembly Text Editor                               ;;
;;                                                                             ;;
;;                                                                             ;;
;;                                                                             ;;
;;              By Roduan Kareem Aldeen & Abdullhafiez Faraj                   ;;
;;                                                                             ;;
;;                                                                             ;;
;;=============================================================================;;
.stack 100h

.data

posX      db 1 dup(0)        ; dh = posX -> controls row
posY      db 1 dup(0)        ; dl = posY -> controls column
matrix    db 80*25 dup(' ')  ; 25 lines of 80 chars each.
curr_line dw ?
curr_char dw ?
color     db 2*16+15
;FOR COLORS USE NEXT TABLE:
;http://stackoverflow.com/questions/29460318/how-to-print-colored-string-in-assembly-language/29478158#29478158

filename db "C:/file.txt",0
handler dw ?
length dw dup(0)

start_menu_str dw '  ',0ah,0dh

dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw '                ====================================================',0ah,0dh
dw '               ||                                                  ||',0ah,0dh                                        
dw '               ||       *     Assembly Text Editor      *          ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||--------------------------------------------------||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh          
dw '               ||        Type in what you want, press ESC          ||',0ah,0dh
dw '               ||               To exit the program.               ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||            Press Enter to start                  ||',0ah,0dh 
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '                ====================================================',0ah,0dh
dw '$',0ah,0dh

.code

;INITIALIZE DATA SEGMENT.
    mov  ax,@data
    mov  ds,ax
  
    call main_menu              ;Print the main menu
    
start_prog:
    call clear_screen
    jmp program
    
program:    ; Initalize the variables

    mov  curr_line, offset matrix
    mov  curr_char, 0

start:
call read_char
    
;;--------------------------------------------------------------------;;
;;                                                                    ;;
;;  Keys Listeners                                                    ;;
;;                                                                    ;;
;;____________________________________________________________________;;

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
    inc  length          ; count the number of chars

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

;ENTER.
moveNewLine:        
    mov si , curr_line
    add si , curr_char
    mov [si] , 0ah
    mov [si+1] , 0dh
    sub si , curr_char
    lea si, si+1
    mov curr_line,si
    mov posX, 0
    mov dl, posX
    mov dh, posY
    inc dh
    mov posY, dh
    add length, 80
    jmp prntCrs

;HOME
moveToBeginning:
    mov curr_char, 0
    mov posX, 0
    mov dl, posX
    jmp prntCrs

prntCrs:                 ; print cursor
    mov  ah, 2h
    int  10h
    jmp  start           ; Go back to the beginning

fin:
    int  20h
    
saveToFile:
;CREATE FILE.
  mov  ah, 3ch
  mov  cx, 0
  mov  dx, offset filename
  int  21h  

;PRESERVE FILE HANDLER RETURNED.
  mov  handler, ax

;WRITE STRING.
  mov  ah, 40h
  mov  bx, handler
  mov  cx, length  ;STRING LENGTH.
  mov  dx, offset matrix
  int  21h

;CLOSE FILE (OR DATA WILL BE LOST).
  mov  ah, 3eh
  mov  bx, handler
  int  21h
  jmp fin  
    
;;--------------------------------------------------------------------;;
;;                                                                    ;;
;;  Clear the sceen                                                   ;;
;;  Just set new text mood for avoiding complexicity                  ;;
;;                                                                    ;;
;;____________________________________________________________________;;

clear_screen proc near
        mov ah,0             ;graphics mode
        mov al,3             ;
        int 10h        
        ret
clear_screen endp

main_menu proc
    mov ah,09h
    mov dh,0
    mov dx, offset start_menu_str
    int 21h
    
    input:      ;wait for ENTER KEY.
        mov  ah, 0
        int  16h
        cmp  al, 27          ; ESC
        je   fin
        cmp  ax, 1C0Dh       ; ENTER.
        je   start_prog
        jmp input
    
main_menu endp

read_char proc
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
    cmp  ax, 1C0Dh       ; ENTER.
    je   moveNewLine
    cmp  ax, 4700h       ; HOME.
    je   moveToBeginning
    cmp  ax, 3F00h       ; F5.
    je   saveToFile
    cmp  al, 32
    jae  any_char
    jmp  start
read_char endp

get_file_location_from_user proc
    ret
get_file_location_from_user endp