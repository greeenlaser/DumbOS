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

	; Print os title message
	mov si, os_title

print_os_title:
	lodsb
	or al, al
	jz after_os_title
	cmp al, 0x0A
	jne .print_char

	; Handle new line, move cursor down
	mov ah, 0x03
	int 0x10
	inc dh
	mov dl, 2
	mov ah, 0x02
	int 0x10
	jmp print_os_title

.print_char:
	mov ah, 0x0E
	mov bh, 0x00
	int 0x10
	jmp print_os_title

after_os_title:
	mov ah, 0x03
	int 0x10
	inc dh
	mov dl, 2
	mov ah, 0x02
	int 0x10

	mov si, kernel_version_message

print_kernel_version:
	lodsb
	or al, al
	jz hang
	mov ah, 0x0E
	mov bh, 0x00
	int 0x10
	jmp print_kernel_version

hang:
	cli
	hlt
	jmp hang

kernel_version_message:
	db "DumbOS Kernel v0.1", 0

os_title:
    db " /$$$$$$$                          /$$        /$$$$$$   /$$$$$$ ", 0x0A
    db "| $$__  $$                        | $$       /$$__  $$ /$$__  $$", 0x0A
    db "| $$  \ $$ /$$   /$$ /$$$$$$/$$$$ | $$$$$$$ | $$  \ $$| $$  \__/", 0x0A
    db "| $$  | $$| $$  | $$| $$_  $$_  $$| $$__  $$| $$  | $$|  $$$$$$ ", 0x0A
    db "| $$  | $$| $$  | $$| $$ \ $$ \ $$| $$  \ $$| $$  | $$ \____  $$", 0x0A
    db "| $$  | $$| $$  | $$| $$ | $$ | $$| $$  | $$| $$  | $$ /$$  \ $$", 0x0A
    db "| $$$$$$$/|  $$$$$$/| $$ | $$ | $$| $$$$$$$/|  $$$$$$/|  $$$$$$/", 0x0A
    db "|_______/  \______/ |__/ |__/ |__/|_______/  \______/  \______/ ", 0x0A
    db 0

; Pad to next 512 bytes
times ((($-$$)+511)/512*512)-($-$$) db 0