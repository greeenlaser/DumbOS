; ===== DumbOS Kernel =====

BITS 32
ORG 0x1000           ; Kernel is loaded at 0x1000

start:
	; Set up VGA text mode (direct memory access at 0x88000)
	mov edi, 0xB8000

    ; Push two rows down and two chars right
    add edi, 160     ; 1 row down (160 bytes)

	; Draw OS title in ASCII art
	call print_os_title

	; Move cursor down 1 line and 2 columns after ASCII art
	add edi, 160
	add edi, 4

after_os_title:
	; Print version
	mov esi, kernel_version_message
	mov ah, 0x07
	call print_string

	; Move to next line
	add edi, 160
	sub edi, 38      ; 19 chars * 2 bytes

	; Print type
	mov esi, kernel_type_message
	mov ah, 0x07
	call print_string

	; Move down two more rows
    add edi, 320
    sub edi, 36      ; 18 chars * 2 bytes

	; Print success
	mov esi, kernel_success_message
	mov ah, 0x0A
	call print_string

	call update_cursor

update_cursor:
	mov eax, edi
	sub eax, 0xB8000
	shr eax, 1

	; Save cursor position
	mov cx, ax

	; Send low byte
	mov dx, 0x3D4
	mov al, 0x0F
	out dx, al
	mov dx, 0x3D5
	mov al, cl
	out dx, al

	; Send high byte
	mov dx, 0x3D4
	mov al, 0x0E
	out dx, al
	mov dx, 0x3D5
	mov al, ch
	out dx, al

	ret

print_os_title:
    mov esi, ascii_line1
    mov ah, 0x07
    call print_string

    mov esi, ascii_line2
    mov ah, 0x07
    call print_string

    mov esi, ascii_line3
    mov ah, 0x07
    call print_string

    mov esi, ascii_line4
    mov ah, 0x07
    call print_string

    mov esi, ascii_line5
    mov ah, 0x07
    call print_string

    mov esi, ascii_line6
    mov ah, 0x07
    call print_string

    mov esi, ascii_line7
    mov ah, 0x07
    call print_string

    mov esi, ascii_line8
    mov ah, 0x07
    call print_string

    ret

print_string:
	lodsb
	or al, al
	jz .done
	mov [edi], ax
	add edi, 2
	jmp print_string
.done:
	ret

halt:
	cli
	hlt
	jmp halt

kernel_version_message:
    db "Kernel version: 0.1", 0

kernel_type_message:
    db "Kernel type: 32bit", 0

kernel_success_message:
    db "Successfully loaded DumbOS!", 0

ascii_line1:
    db "   /$$$$$$$                          /$$        /$$$$$$   /$$$$$$               ", 0
ascii_line2:
    db "  | $$__  $$                        | $$       /$$__  $$ /$$__  $$              ", 0
ascii_line3:
    db "  | $$  \ $$ /$$   /$$ /$$$$$$/$$$$ | $$$$$$$ | $$  \ $$| $$  \__/              ", 0
ascii_line4:
    db "  | $$  | $$| $$  | $$| $$_  $$_  $$| $$__  $$| $$  | $$|  $$$$$$               ", 0
ascii_line5:
    db "  | $$  | $$| $$  | $$| $$ \ $$ \ $$| $$  \ $$| $$  | $$ \____  $$              ", 0
ascii_line6:
    db "  | $$  | $$| $$  | $$| $$ | $$ | $$| $$  | $$| $$  | $$ /$$  \ $$              ", 0
ascii_line7:
    db "  | $$$$$$$/|  $$$$$$/| $$ | $$ | $$| $$$$$$$/|  $$$$$$/|  $$$$$$/              ", 0
ascii_line8:
    db "  |_______/  \______/ |__/ |__/ |__/|_______/  \______/  \______/               ", 0

; Pad to next 512 bytes
times ((($-$$)+511)/512*512)-($-$$) db 0