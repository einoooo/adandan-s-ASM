;//在一串起始地址为XX的10数里找最大数，放入YY里
;//LEA和MOV处理串数据时候的两种同义表达
;//LOOP和DEC+JNZ处理循环时代两种同义表达
;//因为这里AX要用，所以用BX代替SI+AX？
;//

---------------------------------------------

---------------------------------------------
BEGIN:
PUSH DS
MOV AX,0
PUSH AX
MOV AX,DATA 
MOV DS,AX;  前面看清楚了：处理的是DS不是DX

MOV AX,XX;这里送的只是首个数据进AX
MOV BX,OFFSET XX;  BX指向地址时候的用法，和LEA BX,XX同义
MOV CX,9

COMPARE:
INC BX
CMP AX,[BX]
JS SMALLER
MOV YY,AX
LOOP COMPARE;这里用LOOP和DEC CX;JNZ COMPARE的效果是一样的。LOOP里面自带将CX减一的功能
MOV AH,4CH;最后要加中断
INT 21H

SMALLER:
MOV YY,[BX]
MOV AX,[BX]
JMP COMPARE
MOV AH,4CH
INT 21H
