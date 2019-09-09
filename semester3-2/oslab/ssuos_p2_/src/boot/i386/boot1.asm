org	0x9000  

[BITS 16]  

		cli		; Clear Interrupt Flag

		mov     ax, 0xb800 ; 비디오 메모리 저장
        mov     es, ax ; es에 비디오 메모리 주소 넣음
        mov     ax, 0x00 ; 0으로 초기화
        mov     bx, 0 ; 0으로 초기화
        mov     cx, 80*25*2 ;비디오 크기를 80*25로 지정
CLS:
        mov     [es:bx], ax ; es에 순차적으로 ax값 저장 
        add     bx, 1 ; bx 값을 1 증가
        loop    CLS 
 
Initialize_PIC:
		;ICW1 - 두 개의 PIC를 초기화 
		mov		al, 0x11 ;al에 0x11 저장
		out		0x20, al ; 0x20번지에서 al 출력
		out		0xa0, al ; 0xa0번지에서 a1 출력

		;ICW2 - 발생된 인터럽트 번호에 얼마를 더할지 결정
		mov		al, 0x20 ;al에 0x20 저장
		out		0x21, al ;0x21번지에서 al저장
		mov		al, 0x28 ;al에 0x28 저장
		out		0xa1, al ; 0xal번지에서 al 출력

		;ICW3 - 마스터/슬레이브 연결 핀 정보 전달
		mov		al, 0x04 ;al에 0x04 넣음
		out		0x21, al ;0x21번지에서 al 출력
		mov		al, 0x02 ;al에 0x02 sjgdma

		out		0xa1, al ; 0xa1번지에서 al 출력

		;ICW4 - 기타 옵션 
		mov		al, 0x01 ;al에 1 저장
		out		0x21, al ; 0x21번지에서 al 출력
		out		0xa1, al ; 0xa1번지에서 a1 출력

		mov		al, 0xFF ;al에 0xFF 넣음
		;out		0x21, al
		out		0xa1, al ; 0xa1번지에서 al 출력

Initialize_Serial_port: ;시리얼 포트 초기화
		xor		ax, ax ; 0으로 초기화
		xor		dx, dx ; 0으로 초기화, 포트 초기 설정
		mov		al, 0xe3 ; line setting을 의미
		int		0x14

READY_TO_PRINT: ;
		xor		si, si
		xor		bh, bh
PRINT_TO_SERIAL: ;
		mov		al, [msgRMode+si] ;al에 msgRMode_si 값을 저장
		mov		ah, 0x01 ; ah에 1을 저장
		int		0x14 ; 데이터 전송 인터럽트
		add		si, 1 ;si값 1 증가
		cmp		al, 0 ; 만약 al이 0이면
		jne		PRINT_TO_SERIAL ; PRINT_TO_SERIAL로 이동
PRINT_NEW_LINE: ;
		mov		al, 0x0a ;al에 10을 저장
		mov		ah, 0x01 ; ah에 1을 저장
		int		0x14 ; 데이터 전송 인터럽트
		mov		al, 0x0d ; al에 13저장
		mov		ah, 0x01 ; ah에 1저장
		int		0x14 ; 데이터 전송 인터럽트

; OS assignment 2
; add your code here
; print current date to boch display




Activate_A20Gate:
		mov		ax,	0x2401 
		int		0x15 ;인터럽트 발생

;Detecting_Memory:
;		mov		ax, 0xe801
;		int		0x15

PROTECTED:
        xor		ax, ax  ; 서로 같은값이면 0, 다른값이면 1
        mov		ds, ax  ; ds에 ax값 저장            

		call	SETUP_GDT ; SETUP_GDE 부름

        mov		eax, cr0  ;cr0의 최하위 비트가 1이면 32비트, 0이면 16비트
        or		eax, 1	; 1로 셋팅하여 32비트로 바꿈  
        mov		cr0, eax  

		jmp		$+2 ;32비트로 변경하면서 16비트에 남아있던 명령어들을 지움
		nop
		nop
		jmp		CODEDESCRIPTOR:ENTRY32 

SETUP_GDT:
		lgdt	[GDT_DESC] ;GDT를 등록
		ret

[BITS 32]  

ENTRY32: ;세그먼트 레지스터 초기화
		mov		ax, 0x10 ;ax에 0x10 넣음
		mov		ds, ax ; dx에 0x10 넣음
		mov		es, ax ; es에 0x10 넣음
		mov		fs, ax ; fs에 0x10 넣음
		mov		gs, ax ; gs에 0x10 넣음

		mov		ss, ax
  		mov		esp, 0xFFFE ;스택을 0x00000000 ~ 0x0000FFFF 영역에서 생성
		mov		ebp, 0xFFFE	

		mov		edi, 80*2 ;edi에 80*2 저장
		lea		esi, [msgPMode] ; esi에 msgPMode 저장
		call	PRINT ;프린트 호출

		;IDT TABLE
	    cld
		mov		ax,	IDTDESCRIPTOR 
		mov		es, ax ;es에 IDT디스크립터저장
		xor		eax, eax ;서로다른 값이면 1, 같으면 0
		xor		ecx, ecx ;서로다른 값이면 1, 같으면 0
		mov		ax, 256 ;ax에 256저장
		mov		edi, 0
 
IDT_LOOP:
		lea		esi, [IDT_IGNORE] ;IDT_IGNORE를 esi에 저장
		mov		cx, 8 ; cx에 8을 넣음
		rep		movsb 
		dec		ax ; ax값 1씩 감소
		jnz		IDT_LOOP ; 

		lidt	[IDTR]

		sti
		jmp	CODEDESCRIPTOR:0x10000 ;코드 스크립터 기점으로 이동

PRINT:
		push	eax ; 스택에 저장
		push	ebx ; 스택에 저장
		push	edx ; 스택에 저장
		push	es ; 스택에 저장
		mov		ax, VIDEODESCRIPTOR
		mov		es, ax ;es에 비디오메모리 영역 주소저장
PRINT_LOOP:
		or		al, al ;al이 0인 경우  
		jz		PRINT_END ;PRINT_END로 이동
		mov		al, byte[esi] 
		mov		byte [es:edi], al
		inc		edi ;edi값을 하나 증가시킨다
		mov		byte [es:edi], 0x07 ;문자속성은 0x07

OUT_TO_SERIAL:
		mov		bl, al ;bl에 al 저장
		mov		dx, 0x3fd ; dx에 Data-Line status register 저장
CHECK_LINE_STATUS:
		in		al, dx ;dx를 al에 저장
		and		al, 0x20 ; al과 0x20을 비교한다
		cmp		al, 0 ; 만약 서로 다르면
		jz		CHECK_LINE_STATUS ; CHECK_LINE_STATUS로 돌아간다
		mov		dx, 0x3f8 ; 0x3f8(포트번호)을 dx에 넣고
		mov		al, bl ; bl값을 al에 넣는다
		out		dx, al ; ax의 데이터 출력

		inc		esi ; esi값 1증가
		inc		edi ; edi값 1증가
		jmp		PRINT_LOOP ; PRINT_LOOP 기점으로 이동
PRINT_END:
LINE_FEED:
		mov		dx, 0x3fd ;dx를 0x3fd로 설정
		in		al, dx ;dx값을 al에 입력
		and		al, 0x20 ;al이 0x20인지 비교
		cmp		al, 0 ;만약 다르다면
		jz		LINE_FEED ;LINE_FEED로 이동
		mov		dx, 0x3f8 ; dx에 0x3f8(포트번호 넣음)
		mov		al, 0x0a ; al을 10으로 초기화(개행)
		out		dx, al ; al을 출력
CARRIAGE_RETURN:
		mov		dx, 0x3fd ;dx를 0x3fd로 저장
		in		al, dx ;dx값을 al에 입력
		and		al, 0x20 ;al이 0x20인지 비교
		cmp		al, 0 ; 만약 다르다면
		jz		CARRIAGE_RETURN ; CARRIAGE_RETURN을 돌아감
		mov		dx, 0x3f8 ; dx에 0x3f8(포트번호 넣음)
		mov		al, 0x0d ;0x0d를 넣음
		out		dx, al ; al을 출력

		pop		es ; 스택에서 es값 가져옴
		pop		edx ; 스택에서 edx값 가져옴
		pop		ebx ; 스택에서 ebx값 가져옴
		pop		eax ; 스택에서 eax값 가져옴
		ret

GDT_DESC:
        dw GDT_END - GDT - 1    ; GDT의 limit
        dd GDT                 ; GDT의 베이스 주소(address)
GDT:
		NULLDESCRIPTOR equ 0x00 ;NULL 디스크립터
			dw 0 ;비트를 0으로 초기화
			dw 0 ;비트를 0으로 초기화
			db 0 ;비트를 0으로 초기화
			db 0 ;비트를 0으로 초기화
			db 0 ;비트를 0으로 초기화
			db 0 ;비트를 0으로 초기화
		CODEDESCRIPTOR  equ 0x08 ;코드 디스크립터
			dw 0xffff ;비트를 0xffff로 초기화            
			dw 0x0000 ;비트를 0으로 초기화             
			db 0x00 ;비트를 0으로 초기화               
			db 0x9a ;비트를 0x9a으로 초기화                   
			db 0xcf ;비트를 0xcf으로 초기화              
			db 0x00 ;비트를 0으로 초기화               
		DATADESCRIPTOR  equ 0x10 ;데이터 디스크립터
			dw 0xffff ;0xffff로 초기화             
			dw 0x0000 ;0으로 초기화                 
			db 0x00 ;0으로 초기화               
			db 0x92 ;0x92으로 초기화               
			db 0xcf ;0xcf으로 초기화              
			db 0x00 ;0으로 초기화               
		VIDEODESCRIPTOR equ 0x18 ;비디오 디스크립터
			dw 0xffff ;0xffff로 초기화               
			dw 0x8000 ;0x8000로 초기화, 비디오메모리주소             
			db 0x0b ;0xffff로 초기화                   
			db 0x92 ;0xffff로 초기화                  
			db 0x40 ;0xffff로 초기화                       
			;db 0xcf                    
			db 0x00 ;0xffff로 초기화                    
		IDTDESCRIPTOR	equ 0x20 ;IDT 디스크립터
			dw 0xffff ;0xffff로 초기화
			dw 0x0000 ;0x0000로 초기화
			db 0x02 ; 0x02로 초기화
			db 0x92 ; 0x92로 초기화
			db 0xcf ; 0xcf로 초기화
			db 0x00 ; 0으로 초기화
GDT_END:
IDTR:
		dw 256*8-1
		dd 0x00020000
IDT_IGNORE:
		dw ISR_IGNORE ;ISR_IGNORE 데이터로 초기화
		dw CODEDESCRIPTOR ; CODEDESCRIPTOR분기에서의 데이터로 초기화
		db 0 ; 0으로 초기화
		db 0x8E ; 0x8E로 초기화
		dw 0x0000
ISR_IGNORE:
		push	gs ;gs를 스택에 추가
		push	fs ;fs를 스택에 추가
		push	es ;es를 스택에 추가
		push	ds ;ds를 스택에 추가
		pushad
		pushfd
		cli
		nop
		sti
		popfd
		popad
		pop		ds ;ds를 스택에서 가져옴
		pop		es ;es를 스택에서 가져옴
		pop		fs ;fs를 스택에서 가져옴
		pop		gs ;gs를 스택에서 가져옴
		iret



msgRMode db "Real Mode", 0 ; 리얼모드 문자열 출력
msgPMode db "Protected Mode", 0 ; 보호모드 문자열 출력

 
times 	2048-($-$$) db 0x00
