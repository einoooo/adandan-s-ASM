//串操作指令大全！

----------------------------------------------------------
//将内存中10个非压缩的BCD码按顺序送显示器显示
//point1:BCD转ASCII码
//point2:送显示分三步：
//point3:LODSB使用：将SI指向的内容装入AX

LEA SI,BUFFER
MOV CX,10
CLD

MOV AH,02H;显示器设置

SENDING:LODSB
OR AL,30H;把BCD码转ASCII码的方法，30H=00110000B
MOV DL,AL;显示
INT 21H;显示完成
DEC CX
JNZ SENDING

HLT

----------------------------------------------------------
//将字符'##'装入以AREA为首地址的100个字节中
//point1：REP使用
//point2:STOSW使用：将AX指向的内容装入DI
//point3:SI是源操作数，DI是目标操作数

LEA DI,AREA
MOV AX,'##'
MOV CX 100
CLD

REP STOSW;循环只有一句话的时候用REP,有一段的时候用LOOP,标志都是CX.REP

HLT

----------------------------------------------------------
//比较两个字符串，找出其中第一个不相等的字符地址。若完全相同则转到MAT进行处理。
//两个字符串首地址分别为ST1和ST2，长度都为20
//point1:两个字符串，一个当SI,一个当DI
//point2:
//point3:

LEA SI,ST1
LEA DI,ST2
CLD
MOV CX,20

REPE CMPSB
JCXZ WE
DEC SI
DEC DI
HLT

WE: 
MOV SI,O
MOV DI,0
HLT
