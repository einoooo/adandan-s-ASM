
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
SEGTAB          DB 3FH	; 7-Segment Tube, 共阴极类型的7段数码管示意图
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
	     AND AL,0F0H;高四位
	     AND BL,0FH;低四位
	     
	     PUSH AX
	     PUSH AX
	     PUSH AX
	     
	     ADD AL,0EH
	     OUT PortA,AL
	     POP AX
	     PUSH AX
	     PUSH BX
	     MOV BX,AX
	     MOV CX,4
S1:	     SHR BX,1
	     LOOP S1
	     MOV AL,SEGTAB[BX]
	     POP BX
	     OUT PortB,AL
	     CALL DELAY		
	     
	     POP AX
	     ADD AL,0DH
	     OUT PortA,AL
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


