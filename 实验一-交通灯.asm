;-----------------------------------------------------------
;实验一交通灯示例程序                                         |
;                                                             |
;功能：模拟交通灯的转换                                        |
;74LS244带有8位拨位开关，地址为80H or 82H or 84H or 86H    |
;74LS273带有8个发光二极管，地址为88H or 8AH or 8CH or 8EH  |
;                                                          |
;-----------------------------------------------------------
		DOSSEG
		.MODEL	TINY		; 设定8086汇编程序使用Small model
		.8086				; 设定采用8086汇编指令集
;-----------------------------------------------------------
;	符号定义                                               |
;-----------------------------------------------------------
;
PortIn	EQU	80h	;定义输入端口号
PortOut	EQU	88h	;定义输出端口号
;-----------------------------------------------------------
;	定义代码段                                             |
;-----------------------------------------------------------
		.code						; Code segment definition
		.startup					; 定义汇编程序执行入口点

;以下开始放置用户指令代码
;

;--------------------------------------------
;                                           |
;	State machine style control system  |
;                                           |
;--------------------------------------------


;
;	State11      全是红灯
;
MOV AL,36H;NS红EW红
MOV DX,PortOut;
OUT DX,AL;
CALL Delay1;
;
;	State12      南北绿灯     
;
Main:
MOV AL,33H;NS绿EW红
MOV DX,PortOut;
OUT DX,AL;
CALL Delay1;
;
;	State13      南北绿闪
;
MOV CX,6;
LOOP1:MOV AL,33H;NS绿EW红
      MOV DX,PortOut;
      OUT DX,AL;
      CALL Delay2;
      MOV AL,37H;NS不亮EW红
      MOV DX,PortOut;
      OUT DX,AL;
      CALL Delay2;
LOOP2:DEC CX;
      JNZ LOOP1;
;
;	State14	   南北黄灯	
;
MOV AL,35H;NS黄EW红
MOV DX,PortOut;
OUT DX,AL;
CALL Delay3;

;
;	State15    东西绿灯
;
MOV AL,1EH;NS红EW绿
MOV DX,PortOut;
OUT DX,AL;
CALL Delay1;

;
;	State16     东西绿闪
;
MOV CX,6;
LOOP3: MOV AL,1EH;NS红EW绿
       MOV DX,PortOut;
       OUT DX,AL;
       CALL Delay2;
       MOV AL,3EH;NS红EW不亮
       MOV DX,PortOut;
       OUT DX,AL;
       CALL Delay2;

LOOP4: DEC CX;
       JNZ LOOP3;

;
;	State17    东西黄灯
;
MOV AL,2EH;NS红EW黄
MOV DX,PortOut;
OUT DX,AL;
CALL Delay3;
;
;	State18
;
JMP MAIN;
;

;--------------------------------------------
;                                           |
; Delay system running for a while          |
; CX : contains time para.                  |
;                                           |
;--------------------------------------------

DELAY1 	PROC
    	PUSH CX
    	MOV CX,DelayLong	;
D0: 	LOOP D0
    	POP CX
    	RET
DELAY1 	ENDP

;--------------------------------------------
;                                           |
; Delay system running for a while          |
;                                           |
;--------------------------------------------

DELAY2 	PROC
    	PUSH CX
    	MOV CX,DelayShort
D1: 	LOOP D1
    	POP CX
    	RET
DELAY2 	ENDP

;--------------------------------------------
;                                           |
; Delay system running for yellow          |
;                                           |
;--------------------------------------------

DELAY3 	PROC
    	PUSH CX
    	MOV CX,DelayYellow
D1: 	LOOP D1
    	POP CX
    	RET
DELAY3 	ENDP



;-----------------------------------------------------------
;	定义堆栈段                                             |
;-----------------------------------------------------------
		.stack 100h				; 定义256字节容量的堆栈

;-----------------------------------------------------------
;	定义数据段                                             |
;-----------------------------------------------------------
		.data					; 定义数据段
DelayShort	dw	4000			; 短延时参量	
DelayLong	dw	40000			; 长延时参量
DelayYellow	dw	20000			; 长延时参量


		END	Main				;指示汇编程序结束编译
