ORG 0x0
V0: WORD $default, 0X180
V1: WORD $int1,    0X180
V2: WORD $default, 0X180
V3: WORD $int3,    0x180
V4: WORD $default, 0X180
V5: WORD $default, 0X180
V6: WORD $default, 0X180
V7: WORD $default, 0X180

ORG 0x050
X: WORD 0x0011 ; ячейка с Х

max: WORD 0x0011		; 17, максимальное значение Х
min: WORD 0xFFED 		; -19, минимальное значение Х

A: WORD ? ; ячейка для ВУ-3

default:    IRET 		; Обработка прерывания по умолчанию


START:  	DI

    		CLA
    		OUT 0x1 	; Запрет прерываний для неиспользуемых ВУ
   			OUT 0x5
    		OUT 0xB
    		OUT 0xD
    		OUT 0x11
    		OUT 0x15
    		OUT 0x19
    		OUT 0x1D

			LD #0x9 	; Загрузка в аккумулятор MR (1000|0001=1001)
    		OUT 3 		; Разрешение прерываний для 1 ВУ
    		LD #0xB 	; Загрузка в аккумулятор MR (1000|0011=1011)
    		OUT 7 		; Разрешение прерываний для 3 ВУ

;Главный цикл
main:   	DI 		   	; Запрет прерываний чтобы обеспечить атомарность операции
   			LD X
    		DEC
   			CALL check
    		ST X
    		NOP
    		EI
    		JUMP main

int1: 		DI			; Обработка прерывания на ВУ-1
  			LD X
  			NOP
    		ASL         ;2x
			ASL         ;4x
			ASL	        ;8x
			SUB X       ;7x
			NEG         ;-7x
			SUB #0x9    ;-7x - 9
			NOP
    		OUT 2
    		EI
    		IRET
int3:		DI			;Обработка прерывания на ВУ-3
    		IN 7
    		ST A
    		ASL
    		ADD A
    		ADD X
			CALL check
    		ST X
   			NOP
    		EI
    		IRET

check:  					;проверка ОДЗ
check_min:	CMP min 	
    		BPL check_max   
   			JUMP ld_max 	;загрузка максимального числа
check_max: 	CMP max 		
    		BMI return  	
ld_max:		LD max  		
return:		RET  			;Возвращение в основную программу