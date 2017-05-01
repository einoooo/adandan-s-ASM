;------------------------------------------------------------------------
;端口定义
;8253芯片端口地址 （Port Address):
L8253T0			EQU	100h		;计数器0
						
L8253T1			EQU 	102h		;计数器1
						
L8253T2			EQU 	104h		;计数器2 
						
L8253CS			EQU 	106h		;控制字
						 
;
; 8255芯片端口地址 （Port Address):
L8255PA			EQU	121h		;低四位A0-A3给数码管选位，高四位A4-A7给LED
						
L8255PB			EQU 	123h		;7段数码管
						
L8255PC			EQU 	125h		;开关输入
						
L8255CS			EQU 	127h		;控制字
					
;  中断矢量号定义
IRQNum			EQU	20h			; 中断矢量号,要根据学号计算得到后更新此定义。

Patch_Proteus	EQU		IN AL, 0	;	Simulation Patch for Proteus, please ignore this line

;------------------------------------------------------------------------
;	定义数据段                                             |

		.data					; 定义数据段;

DelayShort	dw	40				; 短延时参量	
DelayLong	dw	4000			; 长延时参量


; SEGTAB是显示字符0-F，其中有部分数据的段码有错误，请自行修正
SEGTAB  DB 3FH	; 7-Segment Tube, 共阴极类型的7段数码管示意图
		DB 06H	;
		DB 5BH	;            a a a
		DB 4FH	;         f         b
		DB 66H	;         f         b
		DB 6DH	;         f         b
		DB 7DH	;            g g g 
		DB 07H	;         e         c
		DB 7FH	;         e         c
		DB 6FH	;         e         c
	        DB 77H	;           d d d     h h h
		DB 7CH	; ----------------------------------
		DB 39H	;       b7 b6 b5 b4 b3 b2 b1 b0
		DB 5EH	;       DP  g  f  e  d  c  b  a
		DB 79H	;
		DB 71H	;


;------------------------------------------------------------------------
;主程序
START:								; 代码需要修改，否则无法编译通过
									; 以下的代码可以根据实际需要选用

		CALL INIT8255				; 初始化8255 
		CALL INIT8253				; 初始化8253
Display_Again:
		CALL DISPLAY8255			; 驱动四位七段数码管显示
		CALL AccessPC				; Poll PC0, Modify PC6
		JMP  Display_Again			; 
		
;		MOV  BL, IRQNum				; 取得中断矢量号
;		CALL INT_INIT				; 初始化中断向量表
;		STI							; 开中断

;------------------------------------------------------------
;初始化8255,也是一个控制字81H
INIT8255 PROC
		MOV DX, L8255CS
		MOV AL, 81H  
		OUT DX, AL
		RET
INIT8255 ENDP
;------------------------------------------------------------
;初始化8253,控制字和计数初值
INIT8253 PROC   
		MOV DX, L8253CS
		MOV AL, 00110110B
		OUT DX,AL
				
		MOV DX, L8253T0
		MOV AL,0FH
		OUT DX,AL
		MOV AL,27H
		OUT DX,AL
		
		MOV DX, L8253CS
		MOV AL, 01010110B
		OUT DX,AL
		MOV DX, L8253T1
		MOV AL,64H
		OUT DX,AL
		
		RET
INIT8253 ENDP

;------------------------------------------------------------
;这里好像是一个取数的程序
AccessPC PROC
		MOV DX,L8255PC
		IN AL,DX
		PUSH AX
		AND AL,01H   ;取最低一位
		JZ RSTPC6;跳到复位
		POP AX
		OR AL,40H;直接置位
		JMP PCOUT
RSTPC6:		POP AX
	        AND AL,0AFH
PCOUT:		OUT DX,AL;输出PC6
		RET
AccessPC	ENDP
------------------------------------------------------------
;8255显示,已经会咯
DISPLAY8255 PROC	
;	点亮第一个七段管
		MOV DX, L8255PA		; 选位
		MOV AL, 0FEh		; 11111110
		OUT DX, AL		
		MOV AL, SEGTAB+0	; 输出
		MOV DX, L8255PB		;
		OUT DX, AL		
		CALL DELAY		

;	点亮第二个七段管
		MOV DX, L8255PA		; 
		MOV AL, 0FDh		; 111111101
		OUT DX, AL			
		MOV AL, SEGTAB+0	; 
		MOV DX, L8255PB		
		OUT DX, AL			
		CALL DELAY			

;	点亮第三个七段管
		MOV DX, L8255PA		; 
		MOV AL, 0FBh		; 11111011
		OUT DX, AL		
		MOV AL, SEGTAB+6	
		MOV DX, L8255PB		
		OUT DX, AL			
		CALL DELAY			

;	点亮第四个七段管
		MOV DX, L8255PA		; 
		MOV AL, 0F7h		; 11110111
		OUT DX, AL			
		MOV AL, SEGTAB+1	
		MOV DX, L8255PB		
		OUT DX, AL			
		CALL DELAY			

		RET
	
DISPLAY8255 ENDP

;-------------------------------------------------------------
;很常见的DELAY程序辣
DELAY 	PROC
    	PUSH CX
    	MOV CX, DelayShort
D1: 	LOOP D1
    	POP CX
    	RET
DELAY 	ENDP

;-------------------------------------------------------------
中断
INT_INIT	PROC FAR			; 此部分程序有删节，需要修改
		CLI						; Disable interrupt
		MOV AX, 0
		MOV ES, AX				; 准备操作中断向量表

; 提示：可参考使用SET、OFFSET运算子获取标号的段地址值和段内偏移量
		
INT_INIT	ENDP

;--------------------------------------------------------------	
		
MYIRQ 	PROC FAR				; 此部分程序有删节，需要修改
; Put your code here

								; 中断返回
MYIRQ 	ENDP

	END						; 指示汇编程序结束编译
