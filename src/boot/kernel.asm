; ===== DumbOS Kernel =====

BITS 16
ORG 0x1000           ; Kernel is loaded at 0x1000

start:
	; Set text color to light gray on black
	mov bl, 0x07

	; Clear the screen before writing text
	mov ah, 0x06    ; Scroll up window
	mov al, 0       ; Number of lines to scroll (0 = clear entire screen)
	mov bh, 0x07    ; Light gray text on black background
	mov cx, 0x0000  ; Upper-left corner (row 0, column 0)
	mov dx, 0x184F  ; Lower-right corner (row 24, column 79)
	int 0x10        ; Call BIOS video interrupt to perform screen clear

	; Move cursor to top left corner
	mov ah, 0x02
	mov bh, 0x00
	mov dh, 1       ; Row 1
	mov dl, 2       ; Column 2
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
	; Move cursor lower, slightly to the right
	mov ah, 0x02
	mov bh, 0x00
	mov dh, 2           ; Row 2
	mov dl, 2           ; Column 2
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