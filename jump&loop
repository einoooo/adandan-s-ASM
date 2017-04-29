//以TABLE为首地址，数组长度为COUNT的数组中存放了若干个8bit带符号数
//统计这些数组中正负零数的个数，PLUS存储正数个数，ZERO存储零数个数，MINUS存储复数个数

XOR AX,AX
MOV PLUS,AX
MOV ZERO,AX
MOV MINUS,AX
LEA SI,TABLE;串操作指令SI
MOV CX,COUNT;如果没有已知的COUNT的话用
CLD;标志位DX清零

CHECK:LODSB;串操作指令LODSB/LODSW是块装入指令，其具体操作是把SI指向的存储单元读入累加器,LODSB就读入AL,LODSW就读入AX中,然后SI自动增加或减小1或2.其常常是对数组或字符串中的元素逐个进行处理。
OR AL,AL
JS NEGATIVE;JS:SF=1.负转移
JZ NONE;JZ:ZF=1.零转移
INC PLUS
JUMP NEXT

NEGATIVE:
INC MINUS
JMP NEXT

NONE:
INC ZERO

NEXT:
LOOP CHECK

HLT
