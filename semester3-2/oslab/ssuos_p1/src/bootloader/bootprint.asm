org 0x7C00
[BITS 16]


START:   
mov		ax, 0xb800
mov		es, ax
mov		ax, 0x00
mov		bx, 0
mov		di, ax
mov		cx, 80*25*2

CLS:
mov		[es:bx], ax
add		bx, 1
loop 	CLS


mov ax,ds
mov es,ax

lea bp,[msg]
mov cx,0x18 ;문자열 길이
mov al,0x00 ;쓰기모드
mov bh,0x00 ;페이지번호
mov bl,0x07 ;글자속성
mov dh, 0x00 ;x좌표 0
mov dl, 0x00 ;y좌표 0
mov ah,0x13 ;문자열 출력 함수
int 0x10 ;문자열 출력

msg db "Hello, Hyungkeun's World", 0 ;출력할 문자열
