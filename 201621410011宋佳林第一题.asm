assume ds:data, es:table, cs:code, ss:stack

data    segment
    db    '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982', '1983' 
    db    '1984', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992' 
    db    '1993', '1994', '1995'

    dd    16, 22, 382, 1356, 2390, 8000, 16000, 24486, 50065, 97479, 140417, 197514 
    dd    345980, 590827, 803530, 1183000, 1843000, 2759000, 3753000, 4649000, 5937000

    dw    3, 7, 9, 13, 28, 38, 130, 220, 476, 778, 1001, 1442, 2258, 2793, 4037, 5635, 8226 
    dw    11542, 14430, 15257, 17800 
data    ends

table    segment 
    db    21 dup ('year sume ne ?? ') 
table    ends

tit segment
    db "YEAR               SUME               NE",0
tit ends

display    segment
    db    21 dup ('year sume ne ?? ') 
display    ends

stack segment
 dw 16 dup(0)
stack ends

code segment

start:

	mov ax,data
	mov ds,ax

	mov ax,table
	mov es,ax

	mov ax,stack
	mov ss,ax
	mov sp,16

	mov bx,0 
	mov si,0 
	mov di,0

	mov cx,21

s_start:

	mov ax, ds:[bx+0]
	mov es:[si+0], ax
	mov ax, ds:[bx+2]
	mov es:[si+2], ax


	mov al, 32
	mov es:[si+4], al


	mov ax,ds:[bx+84]
	mov es:[si+5],ax
	mov ax,ds:[bx+86]
	mov es:[si+7],ax


	mov al, 32
	mov es:[si+9], al


	mov ax, ds:[di+168]
	mov es:[si+0ah], ax


	mov al, 32
	mov es:[si+0ch], al


	mov ax,ds:[bx+84]
	mov dx,ds:[bx+86]
	push cx   
	mov cx,ds:[di+168] 
	div cx
	pop cx
	mov es:[si+0dh],ax

	mov al,32
	mov es:[si+0fh], al

	add si,16
	add bx,4
	add di,2  

loop s_start

show_tit:

		push ax
		push bx
		push cx
		push dx
		push si
		push di
		push ds
		push es
		
		mov ax,0b800h
		mov es,ax
		mov si,0
		mov ax,tit
		mov ds,ax
		mov dh,0
		mov dl,0
		mov al,0a0h         
		mul dh             
		mov di,ax           
		mov al,2            
		mul dl           
		add di,ax
		begin_show:
		    mov cl,02h
			mov al,ds:[si]        
			cmp al,0          
			je play 
			mov es:[di],al    
			inc si            
			inc di            
			mov es:[di],cl      
			inc di                 
			jmp begin_show

	play:
		pop es 
		pop ds
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax



	mov ax,display
	mov ds,ax

	mov si,0
	mov di,0
	mov bx,0
	mov cx,21

loop_display:
	  push cx

	
	  mov si, 0
	  mov ax, es:[di]
	  mov ds:[si], ax
	  mov ax, es:[di + 2]
	  mov ds:[si+2], ax  
	  mov ax, 0
	  mov ds:[si+4], ax 
	
	  mov dl,1 
	  call dis

	
	  mov  ax, es:[di+5] 
	  mov  dx, es:[di+7]   
	  mov si, 0
	  call dwtoc   
	 
	  mov dl,20 
	  call dis

	 
	  mov ax, es:[di+0Ah]
	  mov si, 0
	  call dtoc
	  
	  mov dl,39
	  call dis

	  add di, 16
	  pop cx
	  sub cx, 1
	  jcxz end_main
	  jmp near ptr loop_display

end_main:
	 mov ah, 01h
	 int 21h

	 mov ax, 4c00h
	 int 21h

dis:
	 push ax
	 push bx
	 push cx
	 push dx
	 push di
	 push si
	  mov ax, di
	  mov dh, 16
	  div dh
	  mov dh, al
	  add dh, 2   ; dh = di/16+2
	  mov si, 0
	  mov cl, 2
	  call show_str

	 pop si
	 pop di
	 pop dx
	 pop cx
	 pop bx
	 pop ax
	 ret

dtoc:

 mov cx, 0
 push cx
 s1_dtoc:
  mov dx, 0
  mov cx, 10
  div cx

  mov cx, dx 
  add cx, 30h
  push cx   

  mov cx, ax
  jcxz ok1_dtoc

  jmp short s1_dtoc
 
 ok1_dtoc:
  mov ch, 0
  s2_dtoc: 

   pop cx
   mov ds:[si], cl
   jcxz ok2_dtoc
   inc si
   jmp short s2_dtoc

  ok2_dtoc:
   ret

show_str:
  push ax
  push bx
  push cx
  push dx
  push es

  add dh,1
  mov al, 160
  mul dh
  mov bx, ax ; bx 为根据行数算出来的偏移值

  ; ax = 列数*2-2
  mov al, 2
  mul dl
  sub ax, 2 ; 根据列数算出来的偏移值 
  add bx, ax ; 行数和列数的和存在bx中了

  mov ax, 0b800h
  mov es, ax
  
  mov dl, cl ; 保存字体颜色属性
  mov ch, 0

 s_show_str:
  mov  cl, ds:[si]
  mov  es:[bx], cl
  jcxz ok_show_str

  mov es:[bx+1], dl

  inc si
  add bx, 2
  jmp short  s_show_str

 ok_show_str:
  pop es
  pop dx
  pop cx
  pop bx
  pop ax

  ret

dwtoc:
 mov cx, 0
 push cx

 s_dwtoc:
  mov cx, 10
  call divdw 

  add cx, 30h
  push cx 

  mov cx, dx
  jcxz ok_dxz;

  jmp short s_dwtoc

 ; 商的高位为0
 ok_dxz:
  mov cx, ax
  jcxz ok_axz
  jmp short s_dwtoc

 ; 商的低位为0
 ok_axz:
  ; 赋值到 ds:[si]
  mov dx, si ; 保存si，si为字符串的首地址
  loop_dtoc:
   pop cx
   mov ds:[si], cl
   jcxz end_dwtoc
   inc si
   jmp short loop_dtoc

  mov si, dx
 
 end_dwtoc:
 mov ax, 0
 mov ds:[si], ax
 mov si, dx
 ret

; 子程序：divdw
; 要求：进行不会除法溢出的除法运算，被除数为dword，除数为word，结果为dword
; 参数：(ax) = 被除数dword型的低16位
;  (dx) = 被除数dword型的高16位
;  (cx) = 除数
;
; 返回：(dx) = 结果的高16位
;  (ax) = 结果的低16位
;  (cx) = 余数
divdw:
 mov bx, ax ; 缓存ax——被除数的低16位
 mov ax, dx ; ax = H， 被除数的高16位
 mov dx, 0
 div cx  ; ax 为商，dx为余数 = rem(H/N) * 65536
 
 push ax  ; 结果的商，也就是最后要放在dx中的

 mov ax, bx ; dx为 rem(H/N) * 65536, 为高16位，ax为低16位，再进行一次除法运算
 div cx  ; ax 为商——最后结果的低１６位，dx为余数——为最后结果，应赋给cx

 mov cx, dx
 pop dx

 ret

code ends

end start