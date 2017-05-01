
; 8255芯片端口地址 （Port number）分配:
PortA	EQU	90H			; Port A LED灯
PortB	EQU 	92H			; Port B 数码管
PortC	EQU 	94H			; Port 开关输入
CtrlPT	EQU 	96H			; CtrlPT 是接8255


;-----------------------------------------------------------
;	定义数据段                                             |
;-----------------------------------------------------------
		.data					; 定义数据段;

DelayShort	dw	4000			; 短延时参量	
DelayLong	dw	40000			; 长延时参量

; 显示数字
DISCHAR DB 01,02,03,04

; SEGTAB是显示字符0-F，其中有部分数据的段码有错误，请自行修正
SEGTAB          DB 3FH  ;
		DB 06H	;
		DB 5BH	;            a a a
		DB 4FH	;         f         b
		DB 66H	;         f         b
		DB 6DH	;         f         b
		DB 7DH	;            g g g 
		DB 07H	;         e         c
		DB 7FH	;         e         c
		DB 6FH	;         e         c
		DB 77H	;            d d d     h h h
		DB 7CH	; ----------------------------------
		DB 39H	;       b7 b6 b5 b4 b3 b2 b1 b0
		DB 5EH	;       DP  g  f  e  d  c  b  a
		DB 79H	;
		DB 71H	;


;-----------------------------------------------------------
;	  代码                                           |
;-----------------------------------------------------------

		MOV AL,10000000B
		OUT CtrlPT,AL	;给8255送控制字：方式0
		
		
;初始情况，点亮所有二极管，数码管循环显示1，2，3，4
L1: 
		MOV AL,  0FEh
		OUT PortA,AL
		MOV AL,SEGTAB
		OUT PortB,AL
		CALL DELAY			; ？？？ 此处为何需要调研DELAY子程序？是同一根数码管刷新显示，刷新间隔必须要大

		MOV AL, 0FDh
		OUT PortA,AL
		MOV AL,SEGTAB + 1
		OUT PortB,AL
		CALL DELAY			; ？？？Delay程序的延时对演示时的什么方面会产生影响？

		MOV AL, 0FBh 
		OUT PortA,AL
		MOV AL,SEGTAB + 2
		OUT PortB,AL
		CALL DELAY

		MOV AL, 0F7h
		OUT PortA,AL
		MOV AL,SEGTAB + 3
		OUT PortB,AL
		CALL DELAY

		JMP L1
RET
;-----------------------------------------------------------
;修改1
;接受开关的输入，高四位以二进制给发光二极管，低四位给数码管
;开关输入：PortC

CHANGE1:
	 IN AL,PortC
	 NOT AL
	 MOV BL,AL
	 AND AL,0F0H;高四位
	 ADD AL,0EH;第一根管子
	 OUT PortA,AL
	 
	 AND BL,0FH;低四位
	 MOV AL,SEGTAB[BX]
	 OUT PortB,AL
	 JMP CHANGE1
RET
;-----------------------------------------------------------
;修改2
;接受开关的输入，高四位给第一三个数码管，低四位给第二四个数码管,高四位以二进制给发光二极管
;不知道这样写对不对呢？？？

;我的写法
CHANGE2:
	 IN AL,PortC
	 NOT AL
	 MOV BL,AL
	 AND AL,0F0H;高四位
	 ADD AL,0EH;第一根管子
	 OUT PortA,AL
	 
	 AND BL,0F0H;高四位
	 MOV AL,SEGTAB[BX];数码管
	 OUT PortB,AL
	 MOV AL,SEGTAB + 3;数码管
	 OUT PortB,AL
	 
	 AND BL,0FH;低四位
	 MOV AL,SEGTAB + 2;数码管
	 OUT PortB,AL
	 MOV AL,SEGTAB + 4;数码管
	 OUT PortB,AL
	 	 
	 JMP CHANGE2
RET

;答案的写法。。。不停地PUSH POP好烦啊QAQ
CHANGE2: 	     
	     IN AL,PortC
	     NOT AL
	     MOV BL,AL
	     AND AL,0F0H     ;AL装高四位
	     AND BL,0FH	     ;BL装低四位
	     
	     PUSH AX
	     PUSH AX
	     PUSH AX	     ;压三次
	     
	     ADD AL,0EH	     ;让第一个LED灯亮
	     OUT PortA,AL
	     POP AX	     ;回到高四位
	     PUSH AX
	     PUSH BX	     ;低四位PUSH一次
	     MOV BX,AX
	     MOV CX,4	     ;进循环
S1:	     SHR BX,1	     ;BX移位4次
	     LOOP S1
	     MOV AL,SEGTAB[BX]
	     POP BX	     ;BX POP回低四位
	     OUT PortB,AL    ;输出到第一个数码管
	     CALL DELAY		
	     
	     POP AX
	     ADD AL,0DH
	     OUT PortA,AL     ;让第二个LED灯亮
	     MOV AL,SEGTAB[BX]
	     OUT PortB,AL
	     CALL DELAY		
	     
	     POP AX
	     ADD AL,0BH
	     OUT PortA,AL
	     POP AX
	     
	     
	     PUSH AX
	     PUSH BX
	     MOV BX,AX
	     MOV CX,4
S2:	     SHR BX,1
	     LOOP S2
	     MOV AL,SEGTAB[BX]
	     POP BX
	     OUT PortB,AL
	     CALL DELAY

	     POP AX
	     ADD AL,07H
	     OUT PortA,AL
	     MOV AL,SEGTAB[BX]
	     OUT PortB,AL
	     CALL DELAY

	     JMP CHANGE2
RET

;--------------------------------------------
;                DELAY写法                 
;                                        
;--------------------------------------------

DELAY1 	PROC
    	PUSH CX
    	MOV CX,DelayLong	;
D0: 	LOOP D0
    	POP CX
    	RET
DELAY1 	ENDP


;---------------------------------------------------------------------------------------
;书上例题:四位数码管，自动滚动显示0000-9999
;A-0E0H,B-0E1H,C-0E2H,控制端口-0E3H

;七段数码管定义见前

START:
MOV AL,80H
OUT 0E3H,AL;初始化8255
MOV BX,0

;进制转换：从0000-0001-0002-----9999的假象
;SI指向outbuff的表头，不仅可以读取，也可以修改
;连除
;搞清楚除法的时候用的原理，余数和商分别放在哪
NEXT:
LEA SI,OUTBUFF
MOV AX,BX;初始值BX给AX
MOV DX,0
MOV CX,1000
DIV CX
MOV [SI],AL      ;除以1000，第一位给SI
INC SI
MOV AX,DX
MOV CL,100
DIV CL
MOV [SI],AL      ;余数除以100，第一位给SI
INC SI
MOV AL,AH
MOV AH,0
MOV CL,10
DIV CL
MOV [SI],AL      ;除以10，第一位给SI
INC SI
MOV [SI],AL      ;最后一位给SI

;
AGAIN:
MOV CH,08H
LEA SI OUTBUFF

;送显的段
;（SI指第一位）一管1st->(SI指第二位)二管1st->(SI指第三位)三管1st->(SI指第四位)四管1st->AGAIN，SI重新指1
;...............很多很多次
;（SI指第一位）一管100th->(SI指第二位)二管100th->(SI指第三位)三管100th->(SI指第四位)四管100th->NEXT，重新计算SI
;...............100*10000次过去了
;QAQ好努力啊！

LEDDISP:
MOV AL,[SI]      ;要显示的值（1-10）给AL
MOV AH,0
LEA DI,LEDTAB    ;数码管的首地址给DI
ADD DI,AX
MOV AL,[DI]      ;利用指针+偏移位置得到当前应该显示的东西
OUT 0E1H,AL      ;然后送给端口A0-A7（即是数码管的端口）
MOV AL,CH        ;取需要亮起来的是第几根／选位码
OUT 0E2H,AL      ;然后送控制端口C0-C3（即是选通的端口）
CALL DELAY
INC SI           ;SI是指针，位置加一
ROR CH,1         ;CH从00001000开始移位,向右方向移动，依次变为 00000100-00000010-00000001-10000000（可以看出移位计算的便捷性）
CMP CH,80H       ;然后和80H比较，就出循环
JNZ LEDDISP      ;不等于0就跳转（等于0就算显示完了一轮4次，进入下一轮，每一轮4个管子一起显示一个数，每个数刷新一百遍）

DEC COUNT        ;延时的作用，COUNT在前面定的是100，100次大循环之后跳出来
JNZ AGAIN
MOV COUNT,100
INC BX           ;这个时候就完成了某个数的显示，BX就是NEXT里面的初始值
CMP BX,10000     ;一共要显示0000-9999共一万个数
JZ EXIT
JMP NEXT 

;退出部分
EXIT:
MOV AH,4CH
INT 21H

;延时子程序       ;注意保护寄存器就可以了，因为程序里ABCD都被用了，而延时的时候又必须要用到寄存器，所以PUSH POP一下
DELAY PROC NEAR
PUSH BX
PUSH CX
MOV BX,10
DEL1: MOV CX,0
DEL2:LOOP DEL2
DEC BX
JNZ DEL1
POP CX
POP BX
RET
DELAY END


