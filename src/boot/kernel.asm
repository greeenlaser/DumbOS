; ===== DumbOS Kernel =====

BITS 16
ORG 0x1000           ; Kernel is loaded at 0x1000

start:
	; Set text color to light gray on black
	mov bl, 0x07

	; Move cursor to row 2, column 5
	mov ah, 0x02
	mov bh, 0x00
	mov dh, 2        ; Row 2
	mov dl, 5        ; Column 5
	int 0x10

	; Print kernel version message
	mov si, kernel_version_message

print_kernel_version:
	lodsb
	or al, al
	jz print_kernel_ready
	mov ah, 0x0E
	mov bh, 0x00
	int 0x10
	jmp print_kernel_version

print_kernel_ready:
	; Move cursor to row 4, column 5
	mov ah, 0x02
	mov bh, 0x00
	mov dh, 4           ; Row 4
	mov dl, 5           ; Column 5
	int 0x10

	mov bl, 0x02        ; Green text on black background

	; Print kernel ready message
	mov si, kernel_ready_message

print_ready_loop:
	lodsb
	or al, al
	jz hang
	mov ah, 0x0E
	mov bh, 0x00
	int 0x10
	jmp print_ready_loop

hang:
	cli
	hlt
	jmp hang

kernel_version_message:
	db "DumbOS Kernel v0.1", 0

kernel_ready_message:
	db "Kernel ready!", 0

; Pad to next 512 bytes
times ((($-$$)+511)/512*512)-($-$$) db 0