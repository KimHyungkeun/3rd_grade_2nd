org	0x7c00   

[BITS 16]

START:   
jmp		BOOT1_LOAD ;BOOT1_LOAD로 점프

BOOT1_LOAD:
mov     ax, 0x0900 
mov     es, ax
mov     bx, 0x0

mov     ah, 2	;0x13 인터럽트 호출 시 ah에 저장된 값에 따라 수행된튼 결과가 다름
mov     al, 0x4		; al 읽을 섹터 수를 지정 1~128 사이의 값을 지정 가능
mov     ch, 0	;실린더 번호 cl의 상위 2비트까지 사용가능하여 표현
mov     cl, 2	;읽기 시작할 섹터의 번호 1~18 사이의 값, 1에는 부트로더가 있으니 2이상부터
mov     dh, 0	;읽기 시작할 헤드 번호 1~15 값
mov     dl, 0x80 ;드라이브 번호. 0x00 - 플로피; 0x80 - 첫번째하드, 0x81 - 두번째하드

int     0x13	;0x13 인터럽트 호출
jc      BOOT1_LOAD ;Carry 플래그 발생 시 다시 시도

mov ah,0x0f
int 0x10
push ax
mov dh,0x00
push dx

USER_SELECT:
mov ah,0x00
mov al,0x10
int 0x10
mov ax,ds
mov es,ax
mov cx,0x0b
mov al,0x00
mov bh,0x00
mov bl,0x09
mov ah,0x13
lea bp,[ssuos_1]
mov dh,0x00 ;x좌표
mov dl,0x00 ;y좌표
int 0x10
lea bp,[ssuos_2]
mov dh,0x00
mov dl,0x0c
int 0x10
lea bp,[ssuos_3]
mov dh,0x01
mov dl,0x00
int 0x10
pop dx
mov cx,0x03
;mov dl,0
lea bp,[select]
int 0x10




MOVE_SELECT:
mov ah,0x10
int 0x16 ;키보드 입력을 기다림
cmp ah,0x48 ;위 방향키가 입력된 경우
je UP ; UP함수로 이동
cmp ah,0x50 ;아래 방향키가 입력된 경우
je DOWN ;DOWN함수로 이동
cmp ah,0x4b
je LEFT
cmp ah,0x4d
je RIGHT
cmp ah,0x1c ;엔터키가 입력된 경우 
je SELECT_END ; SELECT_END 함수로 이동
jne MOVE_SELECT ;그외에 경우에는 다시 키보드를 입력 받음

UP: ;위 방향키가 입력된 경우
cmp dh,0
je STOP_UP
dec dh ;dh(쓸 위치의 row)를 감소시켜 [o]에 위치를 조정
push dx 
jmp USER_SELECT ; DRAW_SELECT로 이동하여 화면을 [o] 위치에 맞게 다시 화면 출력

DOWN: ;아래 방향키가 입력된 경우
cmp dh,1
je STOP_DOWN
cmp dl,0x0c
je STOP_DOWN_2
inc dh ;dh(쓸 위치의 row)를 증가시켜 [o]의 위치를 조정
push dx
jmp USER_SELECT ; DRAW_SELECT로 이동하여 화면을 [o] 위치에 맞게 다시 화면 출력

RIGHT:
cmp dl,0x0c
je STOP_RIGHT
add dl,0x0c
push dx
jmp USER_SELECT

LEFT:
mov dl,0
push dx
jmp USER_SELECT

STOP_UP:
push dx
jmp USER_SELECT

STOP_DOWN:
push dx
jmp USER_SELECT

STOP_DOWN_2:
cmp dh,0x00
mov dl,0x0c
push dx
jmp USER_SELECT

STOP_RIGHT:
push dx
jmp USER_SELECT


SELECT_END: ;enter키가 입력된 경우
pop ax ;초기에 저장해둔 비디오 상태를 가져옴
mov ah,0x00
int 0x10 ; 비디오 상태 복구
cmp dh,0 ;현재 [o]의 위치가 1번째 라인인 경우
je SELECT_SSUOS1 ;기본 커널로 이동
cmp dl,0x0c ;현재 [o]의 위치가 2번째 라인인 경우
je SELECT_SSUOS2 ;KERENL_2으로 이동
cmp dh,1 ;현재 [o]의 위치가 3번째 라인인 경우
je SELECT_SSUOS3 ;KERENL_3으로 이동
jne USER_SELECT ; 그 외에 경우 USER_SELECT로 이동

SELECT_SSUOS1:
cmp dl,0
je KERNEL_LOAD

SELECT_SSUOS2:
cmp dh,0
je KERNEL_2

SELECT_SSUOS3:
cmp dl,0
je KERNEL_3


KERNEL_2: ;불러올 커널에 따른 CHS 값 설정(커널2)
mov	ax, 0x1000
mov es, ax
mov bx, 0x0

mov ah,2
mov al,0x3f ;sector의 개수
mov ch,0x09;Cylinder number
mov cl,0x2f;Sector number
mov dh,0x0e;Head number
mov dl,0x80;drive number 80은 하드디스크

int 0x13
jc KERNEL_2

jmp 0x0900:0x0000


KERNEL_3: ;불러올 커널에 따른 CHS 값 설정(커널3)
mov	ax, 0x1000
mov es, ax
mov bx, 0x0

mov ah,2
mov al,0x3f ;sector의 개수
mov ch,0x0e;Cylinder number
mov cl,0x07;Sector number
mov dh,0x0e;Head number
mov dl,0x80;drive number 80은 하드디스크

int 0x13
jc KERNEL_3

jmp 0x0900:0x0000


KERNEL_LOAD:
mov     ax, 0x1000	
mov     es, ax		
mov     bx, 0x0		

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
