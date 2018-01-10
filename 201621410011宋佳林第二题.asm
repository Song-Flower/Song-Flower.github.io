assume cs:code

data segment

    db "Beginner's All-purpose Symbolic Instruction Code.",0

data ends

code segment

start:
	mov ax,cs
	mov ds,ax    
	mov si,offset show_str 
	mov ax,0
	mov es,ax             
	mov di,200h       
    mov cx,offset show_str_end-offset show_str 
    
	cld              
    rep movsb      

    mov ax,0           
    mov es,ax          
    mov word ptr es:[4*0],200h    
    mov word ptr es:[4*0+2],0   
    
    mov ax,data
    mov ds,ax          
    mov si,0 
	mov dh,12      
    mov dl,14      
    mov cl,2       

    int 0      

    mov ax,4c00h
    int 21h	

show_str:

    push si        
    push di
    push ax
    push dx
    push cx
    push es
	
	call change
	
	
    mov ax,0b800h
    mov es,ax          
    mov al,0a0h         
    mul dh             
    mov di,ax           
    mov al,2            
    mul dl           
    add di,ax

begin_show:

    mov al,[si]        
    cmp al,0          
    je show_str_ret 
    mov es:[di],al    
    inc si            
    inc di            
    mov es:[di],cl      
    inc di                 
    jmp begin_show  

show_str_ret:

    pop es         
    pop cx
    pop dx
    pop ax
    pop di
    pop si
    iret     

change:
	mov al,[si]
	cmp al,0
	je ok
	cmp al,'a'
	jb  plusi
    cmp al,'z'
	ja  plusi
    and byte ptr [si],11011111b
	jmp short change
	
plusi:
	inc si
	jmp short change
	
ok:	
	mov si,0
	ret	

show_str_end:
    nop 
   
code ends
end start    