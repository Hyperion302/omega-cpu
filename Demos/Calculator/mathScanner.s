.data
state:	.byte 0,0,0,0
buffer_is_empty:	.byte 0,0,0,0
buffer:	 .byte 0,0,0,0
prevcharacter:	 .byte 0,0,0,0
number:	 .byte 0,0,0,0
gotoLookup:
	.byte 6,0,0,0
	.byte -1,0,0,0
	.byte 7,0,0,0
	.byte -1,0,0,0
	.byte 8,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte 16,0,0,0
	.byte 17,0,0,0
	.byte 18,0,0,0
	.byte 19,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
token_is_empty:	.byte 0,0,0,0
token:
	.byte 0,0,0,0
	.byte 0,0,0,0
pState:	.byte 0,0,0,0
element:
	.byte 0,0,0,0
	.byte 0,0,0,0
a:
	.byte 0,0,0,0
	.byte 0,0,0,0
b:
	.byte 0,0,0,0
	.byte 0,0,0,0
accepted:	.byte 0,0,0,0
.text

#; TODO: Insert nextToken
nextToken:
	LA $r8,buffer_is_empty
	LW $r9,$r8
	BZI $r8,nextToken_doWhile_stateNot1
	ADDI $r9,$r0,0
	SW $r9,$r8
nextToken_doWhile_stateNot1:
	LA $r8,state
	LW $r8,$r8
	LA $r9,nextToken_switch_state
	MULTI $r8,$r8,4
	ADD $r9,$r9,$r8
	JR $r9
nextToken_switch_state:
	J nextToken_case0
	J nextToken_case1
	J nextToken_case2
	J nextToken_case3
	J nextToken_case4
nextToken_case0:
	J nextToken_switchFinished
nextToken_case1:
	LA $r8,buffer
	LW $r9,$r8
	EQI $r10,$r9,48
	BZI $r10,nextToken_else1
#; state = 3;
	LA $r10,state
	ADDI $r11,$r0,3
	SW $r10,$r11
#; number = 0;
	LA $r10,number
	ADDI $r11,$r0,0
	SW $r10,$r11
#; prevcharacter = buffer;
	LA $r10,buffer
	LW $r10,$r10
	LA $r11,prevcharacter
	SW $r11,$r10
#; break;
	J nextToken_switchFinished
nextToken_else1:
	LTI $r10,$r9,49
	GTI $r11,$r9,58
	OR $r10,$r10,$r11
	BZI $r10,nextToken_else2
#; state = 2;
	LA $r10,state
	LW $r11,$r10
	ADDI $r11,$r0,2
	SW $r10,$r11
#; number = buffer - 10;
	LA $r10,buffer
	LW $r11,$r10
	LA $r10,number
	SUBI $r11,$r11,48
	SW $r10,$r11
#; prevcharacter = buffer;
	LA $r10,buffer
	LW $r10,$r10
	LA $r11,prevcharacter
	SW $r11,$r10	
#; buffer = getchar();
	LA $r10,buffer
	INPB $r11,$p1
	SW $r10,$r11
#; break;
	J nextToken_switchFinished
nextToken_else2:
	EQI $r10,$r9,43
	EQI $r11,$r9,45
	OR $r10,$r10,$r11
	EQI $r11,$r9,42
	OR $r10,$r10,$r11
	EQI $r11,$r9,47
	OR $r10,$r10,$r11
	EQI $r11,$r9,40
	OR $r10,$r10,$r11
	EQI $r11,$r9,41
	OR $r10,$r10,$r11
	BZ $r10,nextToken_else3
#; state = 4;
	LA $r10,state
	ADDI $r11,$r0,4
	SW $r10,$r11
#; prevcharacter = buffer;
	LA $r10,buffer
	LW $r10,$r10
	LA $r11,prevcharacter
	SW $r11,$r10
#; buffer = getchar();
	LA $r10,buffer
	INPB $r11,$p1
	SW $r10,$r11
#; break;
	J nextToken_switchFinished
nextToken_else3:
	EQI $r10,$r9,32
	EQI $r11,$r9,9
	OR $r10,$r10,$r11
	BZI $r10,nextToken_else4
#; state = 1;
	LA $r10,state
	ADDI $r11,$r0,1
	SW $r10,$r11
#; buffer = getchar();
	LA $r10,buffer
	INPB $r11,$p1
	SW $r10,$r11
#; break;
	J nextToken_switchFinished
nextToken_else4:
	EQ $r9, 10
	BZ nextToken_else5
#; buffer_is_empty = 1;
	LA $r10,buffer_is_empty
	ADDI $r11,$r0,1
	SW $r10,$r11
#; p[0] = TOKEN_EOL;
	ADDI $r10,$r0,8
	SW $r4,$r10
#; return;
	RET
nextToken_else5:
#; no EOF, return;
	RET
#; Error:
#; buffer_is_empty = 1;
	LA $r10,buffer_is_empty
	ADDI $r11,$r0,1
	SW $r10,$r11
#; p[0] = TOKEN_ERROR;
	ADDI $r10,$r0,7
	SW $r4,$r10
#; return;
	RET
nextToken_case2:
	LA $r9,buffer
	LW $r9,$r9
	LTI $r10,$r9,48
	GTI $r11,$r9,57
	OR $r10,$r10,$r11
	BNZ $r10,nextToken_else6
#; number = number * 10 + (buffer - '0');
#; number * 10
	LA $r10,number
	LW $r11,$r10
	MULTI $r11,$r11,10
	SW $r10,$r11
#; (buffer - '0')
	LA $r10,buffer
	LW $r10,$r10
	SUBI $r10,$r10,48
#; number = ... + (...);
	LA $r11,number
	LW $r12,$r11
	ADD $r10,$r10,$r12
	SW $r11,$r10
#; prevcharacter = buffer;
	LA $r10,buffer
	LW $r10,$r10
	LA $r11,prevcharacter
	SW $r11,$r10
#; buffer = getchar();
	LA $r10,buffer
	INPB $r11,$p1
	SW $r10,$r11
#; break;
	J nextToken_switchFinished
nextToken_else6:
#; p[0] = TOKEN_NUMBER;
	ADDI $r10,$r0,0
	SW $r4,$r10
#; p[1] = number;
	LA $r10,number
	LW $r10,$r10
	ADDI $r11,$r4,4
	SW $r11,$r10
#; return;
	RET
#; break; (Why? we just returned!)
	J nextToken_switchFinished
nextToken_case3:
#; state = 1;
	LA $r10,state
	ADDI $r11,$r0,1
	SW $r10,$r11
#; p[0] = TOKEN_NUMBER;
	ADDI $r10,$r0,0
	SW $r4,$r10
#; p[1] = 0;
	SW $r4,$r0
#; return;
	RET
#; break;
	J nextToken_switchFinished
nextToken_case4:
#; state = 1;
	LA $r10,state
	ADDI $r11,$r0,1
	SW $r10,$r11
#; switch statement turned to if statement:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,43
	BZI $r10,nextToken_else7
#; p[0] = TOKEN_PLUS;
	ADDI $r10,$r0,1
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else7:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,45
	BZI $r10,nextToken_else8
#; p[0] = TOKEN_MINUS;
	ADDI $r10,$r0,2
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else8:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,47
	BZI $r10,nextToken_else9
#; p[0] = TOKEN_DIV;
	ADDI $r10,$r0,4
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else9:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,42
	BZI $r10,nextToken_else10
#; p[0] = TOKEN_MULT;
	ADDI $r10,$r0,3
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else10:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,40
	BZI $r10,nextToken_else11
#; p[0] = TOKEN_LEFTP;
	ADDI $r10,$r0,5
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else11:
#; p[0] = TOKEN_RIGHTP;
	ADDI $r10,$r0,6
	SW $r4,$r10
nextToken_switch2Finished:
#; p[1] = 0;
	ADDI $r10,$r4,4
	SW $r10,$r0
#; return;
	RET
#; break;
	J nextToken_switchFinished
nextToken_switchFinished:
	LA $r8,state
	LW $r8,$r8
	EQI $r8,$r8,1
	BZI $r8,nextToken_doWhile_stateNot1
#; TODO: Insert reset_stack
push:
	SUBI $r29,$r29,4
	SW $r29,$r4
	SUBI $r29,$r29,4
	SW $r29,$r5
pop:
	LW $r8,$r29
	SW $r8,$r4
	ADDI $r29,$r29,4
	LW $r8,$r29
	SW $r8,$r5
	ADDI $r29,$r29,4
#; TODO: Insert read_in_error
main:
#; Initialize state
	LA $r8,state
	ADDI $r9,$r0,1
	SW $r8,$r9
#; Initialize buffer_is_empty
	LA $r8,buffer_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; TODO: While 
doWhile_nAccepted:
#; if token_is_empty
	LA $r8,token_is_empty
	LW $r9,$r8
	BZI $r9 token_not_empty
#;TODO: Fill in arguments
	CALL nextToken
	SW $r8,$r0
token_not_empty:	
#; Switch Statement
	LA $r8,switch_sState
	LW $r9,$r27
	MULTI $r9,$r9,4
	ADD $r8,$r8,$r9
switch_sState:
	J case0
	J case1
	J case2
	J case3
	J case4
	J case5
	J case6
	J case7
	J case8
	J case9
	J case10
	J case11
	J case12
	J case13
	J case14
	J case15
	J case16
	J case17
case0:
	J switch_sState_finished
case2:
case4:
case10:
case11:
case12:
case13:
	J switch_sState_finished
case3:
#; continue only, no break
	J switch_sState_finished
case6:
	J switch_sState_finished
case8:
	J switch_sState_finished
case1:
	J switch_sState_finished
case7:
	J switch_sState_finished
case9:
#;Error
case5:
case14:
case9:
#; continue only, no break
	J switch_sState_finished
case15:
	J switch_sState_finished
case18:
	J switch_sState_finished
case19:
	J switch_sState_finished
case16:
	J switch_sState_finished
case17:

switch_sState_finished: ADD $r0,$r0,$r0
