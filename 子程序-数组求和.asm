------------------------------------------------------------------------------------
;数组求和,通过固定单元传递ARRAY1，将SI指向ARRAY1
;注意用SI在子函数中用法：WORD PTR [SI]，以及SI每次移动两格
;在子程序内部可以像主程序一样操纵寄存器;CX是寄存器传递,如果循环有嵌套的话,需要用堆栈压吐

MAIN PROC FAR
START:
MOV AX,DATA
MOV DS,AX
MOV AX,STACK
MOV SS,AX
MOV SP,TOP

LEA SI,ARRAY1
MOV CX,LENGTH ARRAY1
CALL SUM;

MOV AH,4CH
INT 21H;返回DOS,功能由4CH这个功能码决定
RET
MAIN ENDP

SUM PROC NEAR
MOV AX,0

S1:
ADD AX,WORD PTR[SI]
INC SI
INC SI
LOOP S1

MOV WORD PTR[SI],AX
RET
SUM ENDP
------------------------------------------------------------------------------------
;十进制数组求和
;堆栈传递数据，先在一开始定义堆栈指针，然后遇到有用的数据就push一下，不用pop取数据，而是直接用堆栈指针+相对位置取数据，注意一个数据是两格
;在子程序的开头要ASSUME堆栈
;十进制加法怎么做呢？


MAIN PROC FAR
START:
MOV AX,MSTACK
MOV SS,AX
MOV SP OFFSET TOP;要先送堆栈，再定义堆栈指针
MOV AX,OFFSET ARRAY1
PUSH AX
MOV AX,SIZE ARRAY1
PUSH AX             ;array首地址和长度进堆栈
CALL FAR PTR SUM
RET
MAIN ENDP


PCODE SEGMENT
ASSUME CS:PCODE,DS:MDATA,SS:MSTACK
SUM PROC FAR

PUSH BX
PUSH CX
PUSH BP
MOV BP,SP       ;栈顶指针给BP
PUSHF           ;flag进栈
MOV CX,[BP+10]  ;往上数第5次push的东西放到cx中（即是长度）
MOV BX,[BP+12]  ;往上数第6次，是首地址
MOV AX,0        ;清零

NEXT:           ;关于如何完成十进制加法这一点还不是很会
ADD AL,[BX]
DAA
MOV DL,AL
MOV AL,0
ADC AL,AH
DAA
MOV AH,AL
MOV AL,DL
INC BX
LOOP NEXT

MOV [BX],AX
POPF
POP BP
POP CX
POP BX
RET 4           ;还有主程序中push的4个字节需要作废（不然会影响下一次的堆栈使用）

SUM ENDP
PCODE ENDS












