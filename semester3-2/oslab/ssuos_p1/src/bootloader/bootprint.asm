org 0x7c00
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



;mov ah, 0x07 ;글자색 흰색
;mov al, 'H'
;mov [es:0000],ax ; H 출력
;mov al, 'e'
;mov [es:0002],ax ; e 출력
;mov al, 'l'
;mov [es:0004],ax ; l 출력
;mov al, 'l'
;mov [es:0006],ax ; l 출력
;mov al, 'o'
;mov [es:0008],ax ; o 출력
;mov al, ','
;mov [es:0010],ax ; , 출력
;mov al, ' '
;mov [es:0012],ax ; 공백 출력
;mov al, 'H'
;mov [es:0014],ax ; H 출력
;mov al, 'y'
;mov [es:0016],ax ; y 출력
;mov al, 'u'
;mov [es:0018],ax ; u 출력
;mov al, 'n'
;mov [es:0020],ax ; n 출력
;mov al, 'g'
;mov [es:0022],ax ; g 출력
;mov al, 'k'
;mov [es:0024],ax ; k 출력
;mov al, 'e'
;mov [es:0026],ax ; e 출력
;mov al, 'u'
;mov [es:0028],ax ; u 출력
;mov al, 'n'
;mov [es:0030],ax ; n 출력
;mov al, 39
;mov [es:0032],ax ; ' 출력
;mov al, 's'
;mov [es:0034],ax ; s 출력
;mov al, ' '
;mov [es:0036],ax ; 공백 출력
;mov al, 'W'
;mov [es:0038],ax ; W 출력
;mov al, 'o'
;mov [es:0040],ax ; o 출력
;mov al, 'r'
;mov [es:0042],ax ; r 출력
;mov al, 'l'
;mov [es:0044],ax ; l 출력
;mov al, 'd'
;mov [es:0046],ax ; d 출력

mov ax,0
mov ds, ax
mov si, msg
call HelloWorld

jmp $

msg db "Hello, Hyungkeun's World", 0

HelloWorld:
	pusha
	mov ax,0xb800
	mov es,ax
	mov ah, 0x07
	mov di, 0
	.loop:
		mov al, [ds:si]
		cmp al, 0
		je .endFunc

		mov [es:di], ax
		add si,1
		add di,2
		jmp .loop
.endFunc:
	popa
	ret

times 510-($-$$) db 0x00
dw 0xaa55



















