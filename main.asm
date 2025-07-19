ORG 0 
;Global varibale declaratios  
 VTH DATA 40H  
 VTL DATA 41H 
 T2H DATA 42H 
 T2L DATA 43H 
 ATTH DATA 44H 
 ATTL DATA 45H 
 TEMP DATA 46H  
;variable used for setting delays   
 TH_VALUE DATA 47H   
 TL_VALUE DATA 48H 
 TMOD_VALUE DATA 49H 
 LOOP_VALUE DATA 4AH 
;Bits for choosing delay   
    BIT1 EQU 20h.0 
    BIT2 EQU 20h.1 
    SETB BIT1 
    CLR BIT2 
MOV P3,#0H ;clearing port 3 and 1 
MOV P1,#0H 
;jumping to the start of the code 
JMP START 
MODE0: 
 MOV R2, P1 ;save port 1 value in R2 
 MOV R3,#4 ;initializing a and v values 
 MOV R4,#3 
 MOV A,R2 ;moving port1 value in A 
 MOV B,R3 ;velocity in B 
 MUL AB 
 MOV VTH,B ; "v_0t" high bytes 
 MOV VTL,A ; "v_0t" low bytes 
 CLR C 
 MOV A, R2 ;moving port1 value in A 
 MOV B,A ;moving port1 value in B 
 MUL AB
 MOV T2H,B ;T^2 high byte 
 MOV T2L,A ;T^2 low byte 
 MOV A,B 
 RRC A ;RR high byte of T^2(div by 2) 
 MOV R7,A ;HIGH BYTE OF T^2/2 in R7 
 MOV A,T2L 
 RRC A ;RR high byte of T^2(div by 2) 
 MOV R6,A ;NO OVERFLOW CAN COME TILL HERE 
 MOV A,R6 ;LOW BYTE OF T^2/2 IN R6 
 MOV B,#2 
 MUL AB   ;NO OVERFLOW CAN COME TILL HERE 
 MOV TEMP,B 
 MOV ATTL,A ;(T^2/2)x2 low byte 
 MOV A,R7 ;reading high byte of T^2/2 
 MOV B,#2  
 MUL AB 
 ADD A,TEMP 
 MOV ATTH,A ;(T^2/2) x2 HIGH byte 
 MOV A,B 
 CJNE A,#0H,OVERFLOW 
 CLR C 
 MOV A,ATTL  
 ADD A,R6 
 MOV ATTL,A  ;UPDATE ATTL-->(T^2/2) x3 low byte[the 
actual value nedded for ATTL] 
 MOV A,ATTH 
 ADDC A,R7 
 JC OVERFLOW 
 MOV ATTH,A  ;UPDATE ATTH--> (T^2/2) x3 high 
byte[the actual value nedded for ATTh] 
 MOV A,VTL  
 ADD A,ATTL ;adding low bytes of the final results 
 MOV P0,A 
 MOV A,VTH 
 ADDC A,ATTH ;adding high bytes of the final results 
 JC OVERFLOW 
 MOV P2,A 
 CLR P3.2 
 DELAY_MD0: 
 MOV LOOP_VALUE,#255 
 MOV TMOD_VALUE,#01H 
 LID0: 
 MOV TH_VALUE,#0E3H 
 MOV TL_VALUE,#0C3H 
 CALL DELAY 
 DJNZ LOOP_VALUE,LID0 
 JMP START 
 OVERFLOW: 
 MOV P0,#0 
 MOV P2,#0 
 SETB P3.2 
 JMP START 
START: 
    MOV C, P3.0 ; mode selection logic 
    ANL C, P3.1 
    JC MODE3 
    MOV C, P3.0 
    ORL C, P3.1 
    JNC MODE0 
    MOV C, P3.0 
    ANL C, BIT1 
    JC MODE1 
 MODE2: ; led blinking frequency wrt port1 
CLR P3.2 
 MOV R1,#01H ; from lsb to msb 
 MOV R4,#80H ; from msb to lsb 
 MOV R3,#8 ;loop counter 
 BLINKING: 
 MOV A,R1 
 MOV P2,A 
 RL A 
 MOV R1,A ;update R1 for next iteration 
 MOV A,R4 
 MOV P0,A 
 RR A 
 MOV R4,A ;update R4 for next iteration 
 DELAY_MD2: 
 MOV R6,P1 
 MOV A,R6 
 MOV B,#0FFH 
 MUL AB 
 MOV LOOP_VALUE,#50 
 MOV TMOD_VALUE,#01H 
 MOV TH_VALUE,B ;setting the frequency wrt P1 
 MOV TL_VALUE,A 
 LID2: 
 JB P3.0,START ;check if mode has been changed 
 JNB P3.1,START 
 CALL DELAY 
 DJNZ LOOP_VALUE,LID2 
 DJNZ R3, BLINKING 
 JMP START 
 MODE1: 
 CLR P3.2 
 CLR C 
 MOV DPTR,#200H 
    MOV R1,P1 
 MOV A,#40 
 SUBB A,R1 ;P1 value in R1 
 JC START  
    MOV A,R1 ;P1 value in R1 
 JZ ZERO 
 MOV B,#2 
 MUL AB 
 MOV R7,A 
 MOVC A,@A+DPTR 
 MOV R3,A ;high byte in R3 
    INC DPTR ; for the low byte  
 MOV A,R7 ;again read the number for which volume is 
req 
 MOVC A,@A+DPTR ;read the low byte of the volume 
 MOV R4,A ;low byte of the volume 
 MOV P0,R3 ; displaying the low and high bytes 
 MOV P2,R4 
 DELAY_MD1: 
 MOV LOOP_VALUE,#255 
 LID1: ;LOOP IN DELAY THIS LOOP RUNS DELAY 
FUNCTION FOR 255 TIMES TO PRODUCE  1.2S DELAY 
 MOV TMOD_VALUE,#01H 
 MOV TH_VALUE,#0EFH 
 MOV TL_VALUE,#0EH 
 CALL DELAY 
 DJNZ LOOP_VALUE,LID1 
 JMP START 
 ZERO: 
 MOV P0,#0
 MOV P2,#0 
 JMP DELAY_MD1 
 JMP START 
 MODE3: 
 CLR P3.2 
 MOV TMOD_VALUE,#01H 
 MOV TH_VALUE,#09DH 
 MOV TL_VALUE,#0DFH 
 MOV P0,#0 
 MOV P2,#0 
 MOV A,P1 
 MOV B,#2 
 DIV AB 
 MOV A,B 
 CJNE A,#0,ODD 
 EVENN: 
 MOV P0,#0 
 MOV P2,#0 
 MOV R1,#80H 
 MOV R2,#80H 
 MOV R3,#8 
 MOV R4,#01H 
 MOV R5,#01H 
 LIE:  ;LOOP IN EVEN 
 MOV A,P1 
 MOV B,#2 
 DIV AB 
 MOV A,B 
 CJNE A,#0,ODD 
 MOV P0,R4 
 MOV A,R5 
 RL A 
 MOV R5,A 
 ORL A,R4 
 MOV R4,A 
 JNB P3.0,OOR ; IF MODE IS CHANGED SO JUMP TO 
START IS REQUIRED 
 JNB P3.1,OOR 
 MOV P2, R1 
    MOV A, R2 
    RR A 
    MOV R2, A 
    ORL A, R1 
    MOV R1, A 
 JNB P3.0,OOR 
 DELAY_MD31: 
 MOV A,P1 
    SUBB A,#127 
 JNC HSPEED 
 MOV LOOP_VALUE,#35 
 JMP LID31 
 HSPEED: 
 MOV LOOP_VALUE,#5 
 LID31: 
 CALL DELAY 
 DJNZ LOOP_VALUE,LID31 
 DJNZ R3,LIE 
 OOR:JMP START 
 CALL DELAY 
 DJNZ LOOP_VALUE,LID31 
 DJNZ R3,LIE 
 JMP START
 ODD: 
 MOV P0,#0 
 MOV P2,#0 
 MOV R1, #01H 
    MOV R2, #01H 
    MOV R3, #8 
 MOV R4,#80H 
 MOV R5,#80H 
    MOV P2, #0 
    LIO: 
 MOV A,P1 
 MOV B,#2 
 DIV AB 
 MOV A,B 
 JZ EVENN 
    MOV P2, R1 
    MOV A, R2 
    RL A 
    MOV R2, A 
    ORL A, R1 
    MOV R1, A 
 JNB P3.0,OOR 
 MOV P0, R4 
    MOV A, R5 
    RR A 
    MOV R5, A 
    ORL A, R4 
    MOV R4, A 
 JNB P3.0,OOR 
 JNB P3.1,OOR  
 DELAY_MD32: 
 MOV A,P1 
    SUBB A,#127 
 JNC H2SPEED 
 MOV LOOP_VALUE,#35 
 JMP LID32 
 H2SPEED: 
 MOV LOOP_VALUE,#5 
 LID32: 
 CALL DELAY 
 DJNZ LOOP_VALUE,LID32 
    DJNZ R3, LIO 
 JMP START  
 DELAY: 
 MOV TMOD,TMOD_VALUE 
 MOV TH0,TH_VALUE 
 MOV TL0,TL_VALUE 
 SETB TR0 
 JNB TF0,$ 
    CLR TR0 
 CLR TF0 
 RET 
 ORG 200H 
  DW 
0,1,8,27,64,125,216,343,512,729,1000,1331,1728,2197,2744,337
 5,4096,54913,5832,689,8000,9261,10648,12167,13824,15625,17
 576,19683,21952,24389,27000,29791,32768,35937,39304,42875,
 46656,50653,54872,59319,64000 
 
END