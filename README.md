# Song-Flower.github.io

# +0宝典之汇编语言考试代码（附解析） #

##  第一题 ##
	;结构体定义
	;char year[4] // 年
	; 空格(1 Byte)
	;int income (4 Bytes)// 收入
	; 空格
	;empoyer num (2 Bytes) // 雇员数
	; 空格
	;人均收入 (2 Bytes)
	; 空格
	
	; 要求：将data段的数据拷贝进table段数据，并结构化如上述格式，然后计算21年的人均收入
	
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
	    db    21 dup ('year summ ne ?? ')
	table    ends
	
	display    segment
	    db    21 dup ('year summ ne ?? ')
	display    ends
	
	
	; 弄个栈，没什么用
	; 就用来有时候腾出个寄存器来用
	stack segment
	 dw 16 dup(0)
	stack ends
	
	code segment
	
	start:
	
	; 设置data段，以及ds:bx指向data段的第一个单元，即ds:[bx]的内容就是data段第一个单元的内容
	mov ax, data
	mov ds, ax
	
	; 设置table段
	mov ax, table
	mov es, ax
	
	; 设置堆栈段
	mov ax, stack
	mov ss, ax
	mov sp, 16
	
	; 初始化三个变址寄存器
	mov bx, 0 
	mov si, 0 
	mov di, 0
	
	; 准备复制，需要用到循环，21次
	mov cx, 21
	
	s_start:
	 ; 年
	 mov ax, ds:[bx+0] ; 这里写个0是为了下面的对照，清晰点
	 mov es:[si+0], ax
	 mov ax, ds:[bx+2]
	 mov es:[si+2], ax
	
	 ; 空格
	 mov al, 32
	 mov es:[si+4], al
	
	 ; 收入
	 mov ax, ds:[bx+84]
	 mov es:[si+5], ax
	 mov ax, ds:[bx+86]
	 mov es:[si+7], ax
	
	 ; 空格
	 mov al, 32
	 mov es:[si+9], al
	
	 ; 雇员数，小心处理
	 mov ax, ds:[di+168]
	 mov es:[si+0ah], ax
	
	 ; 空格
	 mov al, 32
	 mov es:[si+0ch], al
	
	 ; 算人均收入，这里小心高低位
	 mov ax, ds:[bx+84]
	 mov dx, ds:[bx+86]
	 push cx    ; 临时用一下cx，因为不可以 div ds:[bx+168]
	 mov cx, ds:[di+168] 
	 div cx
	 pop cx
	 mov es:[si+0dh], ax
	
	 ; 空格
	 mov al, 32
	 mov es:[si+0fh], al
	
	 add si, 16
	 add bx, 4
	 add di, 2   ; 这里记住要加上２
	 loop s_start
	
	 ; 上面已经将数据排列好放在table段里，table 段在es:[0] 开始
	 ; 下面就是要读这些数据，并计算好行列，显示在屏幕上 
	 ; 结构化的数据按字节排列如下：
	 ; 0123 年(字符) 4 空格(字符) 5678 收入(数据) 9 空格 A B 雇员数(数据) C 空格 D E 人均收入(数据) F 空格
	 ; 总共21年
	 ; 其中收入、雇员数、人均收入是需要转字符格式的
	
	 mov ax, display
	 mov ds, ax
	
	 mov si, 0
	 mov di, 0
	 mov bx, 0
	 mov cx, 21
	
	 loop_display:
	  push cx
	
	  ; #### 年
	  mov si, 0
	  mov ax, es:[di]
	  mov ds:[si], ax
	  mov ax, es:[di + 2]
	  mov ds:[si+2], ax  
	  mov ax, 0
	  mov ds:[si+4], ax  ; 原来的显示错误，mov ds:[si+5], ax ， 错一个字节都不行。。。
	  ; 显示年
	  mov dl, 20   ; 第20列
	  call dis
	
	  ; #### 收入
	  mov  ax, es:[di+5]  ; 低16位
	  mov  dx, es:[di+7]  ; 高16位 
	  mov si, 0
	  call dwtoc   ; ds:si 指向字符串首地址
	  ; 显示收入 
	  mov dl, 28   ; 第28列
	  call dis
	
	  ; #### 雇员数
	  mov ax, es:[di+0Ah]
	  mov si, 0
	  call dtoc
	  ; 显示雇员数
	  mov dl, 36   ; 第36列
	  call dis
	
	  ; ####人均收入
	  mov ax, es:[di+0Dh]
	  mov si, 0
	  call dtoc
	  ; 显示人均收入
	  mov dl, 44   ; 第44列
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
	
	; 子程序dis
	; 功能：封装一些相同的操作
	; 参数：(dl) 为列数
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
	
	; 子程序：dtoc
	; 功能：将word型数据转变成表示十进制的字符串，字符串以0结尾
	; 参数：(ax) = word 型数据
	;  ds:si 指向字符串首地址
	; 返回：无
	dtoc:
	 ; 先把一个0放进堆栈，在后面s2从堆栈中取出的时候，可以根据cx为0跳转
	 mov cx, 0
	 push cx
	 s1_dtoc:
	  mov dx, 0
	  mov cx, 10
	  div cx
	
	  mov cx, dx  ; dx余数
	  add cx, 30h
	  push cx   ; 保存在堆栈
	
	  mov cx, ax  ; ax为商，当商为0的时候，各位的值就已经得到了，就可以跳出循环
	  jcxz ok1_dtoc
	
	  jmp short s1_dtoc
	 
	 ok1_dtoc:
	  mov ch, 0
	  s2_dtoc:
	   ; 从堆栈中取出
	   pop cx
	   mov ds:[si], cl
	   jcxz ok2_dtoc
	   inc si
	   jmp short s2_dtoc
	
	  ok2_dtoc:
	   ret
	
	; 名称：show_str
	; 功能：指定位置，用指定颜色，显示一个用0结束的字符串
	; 参数：(dh) =  行号(0--24)，(dl) = 列号(0--79)
	;  (cl) = 颜色，ds:si 指向字符串的首地址
	; 返回：无
	show_str:
	  push ax
	  push bx
	  push cx
	  push dx
	  push es
	
	  ; 计算好字串开始显示的地址Y = 160*（行数-1） + 列数*2-2， B800 : Y
	  ; 循环将参数里的字串写进显卡内存，并检测到0就返回
	  
	  ; bx = 160*（行数-1）
	  sub dh, 1h
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
	
	; 子程序：dwtoc
	; 功能：将dword型数据转变成表示十进制的字符串，字符串以0结尾
	; 参数：(ax) = dword 型数据的低16位
	;  (dx) = dword型数据的高16位
	;  ds:si 指向字符串首地址
	; 返回：无
	dwtoc:
	 mov cx, 0
	 push cx
	
	 s_dwtoc:
	  mov cx, 10 ; 除数
	  call divdw ; 余数在cx中
	
	  add cx, 30h
	  push cx  ; 保存余数的ASCII形式
	
	  ; 判断是否商为0，如果高低16位都为0，则返回
	  mov cx, dx
	  jcxz ok_dxz;
	  
	  ; 高位不为0，则直接跳回，继续执行运算
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


	
	 
## 第二题 ##
	assume cs:code,ds:data
	data segment
	  db  'Beginners All-purpose Symbolic Instruction Code.',0
	data ends
	code segment
	begin:mov ax,data
	      mov ds,ax
	      mov si,0
	      call letterc
	      mov ah,4ch
	      int 21h
	;名称：letterc
	;功能：将以0结尾的字符串中的小写字母转变成大写字母
	;参数：ds:[si]指向字符串首地址
	letterc:push ax
	             s:mov al,[si]
	        mov ah,0
	 mov cx,ax
	 jcxz return
	 cmp al,61h
	 jb next
	 cmp al,91h
	 ja next
	 and al,11011111b
	 mov [si],al
	   next:inc si
	        jmp short s
	
	 return:pop ax
	        ret
	code ends
	end begin
