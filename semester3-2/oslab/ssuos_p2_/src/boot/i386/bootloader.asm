org	0x7c00   

[BITS 16]

START:   
jmp		BOOT1_LOAD ;BOOT1_LOAD로 점프

BOOT1_LOAD:
mov     ax, 0x0900 
mov     es, ax
mov     bx, 0x0

mov     ah, 2	;0x13 인터럽트 호출 시 ah에 저장된 값에 따라 수행된 결과가 다름
mov     al, 0x4		; al 읽을 섹터 수를 지정 1~128 사이의 값을 지정 가능
mov     ch, 0	;실린더 번호 cl의 상위 2비트까지 사용가능하여 표현
mov     cl, 2	;읽기 시작할 섹터의 번호 1~18 사이의 값, 1에는 부트로더가 있으니 2이상부터
mov     dh, 0	;읽기 시작할 헤드 번호 1~15 값
mov     dl, 0x80 ;드라이브 번호. 0x00 - 플로피; 0x80 - 첫번째하드, 0x81 - 두번째하드

int     0x13	;0x13 인터럽트 호출
jc      BOOT1_LOAD ;Carry 플래그 발생 시 다시 시도

mov ah,0x0f ;현 비디오상태를 가져온다
int 0x10 ;인터럽트 발생
push ax ;현재의 비디오상태를 저장
mov dh,0x00 ; [0]초기 상태 저장
push dx ;데이터들을 저장

MAIN_PAGE: ;사용자는 이곳에서 커널선택 화면을 볼수있다
mov ah,0x00 
mov al,0x10 
int 0x10 ;비디오 상태 설정
mov ax,ds
mov es,ax
mov cx,0x0b ;문자열 길이
mov al,0x00 ;쓰기모드
mov bh,0x00 ;페이지번호
mov bl,0x09 ;글자속성
mov ah,0x13
lea bp,[ssuos_1] ;ssuos_1 문자열 
mov dh,0x00 ;x좌표 0
mov dl,0x00 ;y좌표 0
int 0x10 ; 문자열 출력
lea bp,[ssuos_2] ;ssuos_2 문자열
mov dh,0x00 ;x좌표 0
mov dl,0x0c ;y좌표 13
int 0x10 ; 문자열 출력
lea bp,[ssuos_3] ;ssuos_3 문자열
mov dh,0x01 ;x좌표 1
mov dl,0x00 ;y좌표 0
int 0x10 ; 문자열 출력
pop dx ;데이터 저장
mov cx,0x03 ; 문자열 갯수
mov dl,0x00
lea bp,[select] ;[0]위치  
int 0x10 ; [0]위치 출력
jmp MOVE_SELECT ;사용자 출력위치로



USER_SELECT: ; [0]가 유저가 선택하는 방향으로 이동하게 되는 화면
mov ah,0x00 
mov al,0x10 
int 0x10 ;비디오 상태 설정
mov ax,ds
mov es,ax
mov cx,0x0b ;문자열 길이
mov al,0x00 ;쓰기모드
mov bh,0x00 ;페이지번호
mov bl,0x09 ;글자속성
mov ah,0x13
lea bp,[ssuos_1] ;ssuos_1 문자열 
mov dh,0x00 ;x좌표 0
mov dl,0x00 ;y좌표 0
int 0x10 ; 문자열 출력
lea bp,[ssuos_2] ;ssuos_2 문자열
mov dh,0x00 ;x좌표 0
mov dl,0x0c ;y좌표 13
int 0x10 ; 문자열 출력
lea bp,[ssuos_3] ;ssuos_3 문자열
mov dh,0x01 ;x좌표 1
mov dl,0x00 ;y좌표 0
int 0x10 ; 문자열 출력
pop dx ;데이터 저장
mov cx,0x03 ; 문자열 갯수
lea bp,[select] ;[0]위치  
int 0x10 ; [0]위치 출력


MOVE_SELECT: 
mov ah,0x10 
int 0x16 ;키보드 입력 대기
cmp ah,0x48 ;위 방향키가 입력
je UP ; UP레이블로 이동
cmp ah,0x50 ;아래 방향키가 입력
je DOWN ;DOWN레이블로 이동
cmp ah,0x4b ;왼쪽 방향키 입력
je LEFT ; LEFT레이블로 이동
cmp ah,0x4d ;오른쪽 방향키 입력
je RIGHT ; RIGHT레이블로 이동
cmp ah,0x1c ;엔터키가 입력 
je SELECT_END ; SELECT_END 레이블로 이동
jne MOVE_SELECT ; 그외에 경우에는 다시 키보드를 입력 받음

UP: ;위 방향키가 입력
cmp dh,0 ;y축이 0이면
je STOP_UP ;STOP_UP으로 이동 
dec dh ;dh(쓸 위치의 row)를 감소시켜 [o]에 위치를 조정
push dx ; 데이터 저장
jmp USER_SELECT ;USER_SELECT로 이동하여 화면을 [0] 위치에 맞게 함

DOWN: ;아래 방향키가 입력
cmp dh,1 ;y축이 1이면
je STOP_DOWN ; STOP_DOWN 레이블로 이동
cmp dl,0x0c ; x축이 13이면
je STOP_DOWN_2 ; STOP_DOWN2 레이블로 이동
inc dh ; dh(쓸 위치의 row)를 증가시켜 [o]의 위치를 조정
push dx ; 데이터 저장
jmp USER_SELECT ; USER_SELECT로 이동하여 화면을 [0] 위치에 맞게 함

RIGHT: ;오른쪽 방향키 입력
cmp dl,0x0c ;x축이 13이면
je STOP_RIGHT ; STOP_RIGHT 레이블로 이동
add dl,0x0c ;13만큼 움직임
push dx ; 데이터 저장
jmp USER_SELECT ; USER_SELECT로 이동하여 화면을 [0] 위치에 맞게 함

LEFT: ;왼쪽 방향키 입력
mov dl,0 ; x축을 0으로
push dx ; 데이터 저장
jmp USER_SELECT ; USER_SELECT로 이동

STOP_UP: ;더이상 윗방향을 못갈경우
push dx ; 데이터 저장
jmp USER_SELECT ; USER_SELECT로 이동

STOP_DOWN: ;더이상 아래방향으로 못갈경우
push dx ; 데이터 저장
jmp USER_SELECT ; USER_SELECT로 이동

STOP_DOWN_2: ; 더이상 아래방향으로 못갈경우 (ssuos_2)
cmp dh,0x00 ;y축이 0이면
mov dl,0x0c ;x축을 13으로 
push dx ; 데이터 저장
jmp USER_SELECT ; USER_SELECT로 이동

STOP_RIGHT: ; 오른쪽방향으로 더 못갈 경우
push dx ; 데이터저장
jmp USER_SELECT ; USER_SELECT로 이동


SELECT_END: ;enter키가 입력된 경우
pop ax ;초기에 저장해둔 비디오 상태를 가져옴
mov ah,0x00
int 0x10 ; 비디오 상태 복구
cmp dh,0 ;현재 [o]의 위치가 ssuos_1
je SELECT_SSUOS1 ; 커널1로 이동
cmp dl,0x0c ;현재 [o]의 위치가 ssuos_2
je SELECT_SSUOS2 ; 커널2로 이동
cmp dh,1 ;현재 [o]의 위치가 ssuos_3
je SELECT_SSUOS3 ; 커널3으로 이동
jne USER_SELECT ; 그 외에 경우 USER_SELECT로 이동

SELECT_SSUOS1: ;커널1 선택
cmp dl,0 ;x축이 0이면 
je KERNEL_LOAD ; 커널1로 이동

SELECT_SSUOS2: ;커널2 선택
cmp dh,0 ;y축이 0이면
je KERNEL2_LOAD ; 커널2로 이동

SELECT_SSUOS3: ;커널3 선택
cmp dl,0 ;x축이 0이면
je KERNEL3_LOAD ; 커널3로 이동


KERNEL2_LOAD: ;커널2
mov	ax, 0x1000
mov es, ax
mov bx, 0x0

mov ah,2 ;드라이브로부터 섹터를 읽어들임
mov al,0x3f ;섹터의 개수
mov ch,0x09 ;실린더 넘버
mov cl,0x2f ;섹터 넘버
mov dh,0x0e ;헤더 넘버
mov dl,0x80 ;첫번째하드

int 0x13 ;바이오스 부팅
jc KERNEL2_LOAD ;커널2 작동

jmp 0x0900:0x0000 ;boot1.asm작동


KERNEL3_LOAD: ;커널3
mov	ax, 0x1000
mov es, ax
mov bx, 0x0

mov ah,2 ;드라이브로부터 섹터를 읽어들임
mov al,0x3f ;섹터의 개수
mov ch,0x0e;실린더 넘버
mov cl,0x07;섹터 넘버
mov dh,0x0e;헤더 넘버
mov dl,0x80;첫번째하드

int 0x13 ;바이오스 부팅
jc KERNEL3_LOAD ;커널3 작동

jmp 0x0900:0x0000 ;boot1.asm작동


KERNEL_LOAD:
mov     ax, 0x1000	
mov     es, ax		
mov     bx, 0x0		

mov		ah, 2
mov     al, 0x3f	
mov     ch, 0		
mov     cl, 0x6	
mov     dh, 0     
mov     dl, 0x80  

int     0x13
jc      KERNEL_LOAD

jmp		0x0900:0x0000

select db "[O]",0
ssuos_1 db "[ ] SSUOS_1",0
ssuos_2 db "[ ] SSUOS_2",0
ssuos_3 db "[ ] SSUOS_3",0
ssuos_4 db "[ ] SSUOS_4",0
partition_num : resw 1

times   446-($-$$) db 0x00

PTE:
partition1 db 0x80, 0x00, 0x00, 0x00, 0x83, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x3f, 0x0, 0x00, 0x00
partition2 db 0x80, 0x00, 0x00, 0x00, 0x83, 0x00, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x3f, 0x0, 0x00, 0x00
partition3 db 0x80, 0x00, 0x00, 0x00, 0x83, 0x00, 0x00, 0x00, 0x98, 0x3a, 0x00, 0x00, 0x3f, 0x0, 0x00, 0x00
partition4 db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
times 	510-($-$$) db 0x00
dw	0xaa55
