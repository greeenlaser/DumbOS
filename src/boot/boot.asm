; ===== DumbOS Bootloader =====

; Tell assembler this is a boot sector
BITS 16             ; Generate 16-bit real mode code (for BIOS boot)
ORG 0x7C00          ; Load code at memory address 0x7C00

boot_drive: db 0

start:
	; Set up segment registers (basic BIOS bootloader standard)
	cli             ; Temporarily disable interrupts during setup
	xor ax, ax      ; Clear ax register
	mov ds, ax      ; Set DS (Data Segment) to 0
	mov es, ax      ; Set ES (Extra Segment) to 0
	mov ss, ax      ; Set SS (Stack Segment) to 0
	mov sp, 0x7C00  ; Set stack pointer to 0x7C00 (top of bootloader memory)
	mov [boot_drive], dl ; Save BIOS dl
	sti             ; Re-enable interrupts

	; Clear the screen before writing text
	mov ah, 0x06    ; Scroll up window
	mov al, 0       ; Number of lines to scroll (0 = clear entire screen)
	mov bh, 0x07    ; Light gray text on black background
	mov cx, 0x0000  ; Upper-left corner (row 0, column 0)
	mov dx, 0x184F  ; Lower-right corner (row 24, column 79)
	int 0x10        ; Call BIOS video interrupt to perform screen clear

	; Move cursor to top-left corner
	mov ah, 0x02    ; Set cursor position
	mov bh, 0x00    ; Page number
	mov dh, 0x00    ; Row 0 (top row)
	mov dl, 0x00    ; Column 0 (leftmost column)
	int 0x10        ; Call BIOS video interrupt to set cursor

	; Print bootloader startup message
	mov si, startup_message

print_startup_message:
	lodsb
	or al, al
	jz load_kernel

	mov ah, 0x0E
	mov bh, 0x00
	int 0x10
	jmp print_startup_message

load_kernel:
	; Load the kernel from disk
	mov ah, 0x02    ; BIOS read sectors
	mov al, 2       ; Number of sectors to read (adjust based on kernel size)
	mov ch, 0       ; Cylinder 0
	mov cl, 2       ; Sector 2 (start reading after bootloader)
	mov dh, 0       ; Head 0
	mov dl, [boot_drive] ; Restore correct boot drive
	mov bx, 0x1000  ; Load address (0x1000 = 4096 bytes into RAM)
	int 0x13        ; Call BIOS disk interrupt

	jc disk_error   ; If Carry Flag set, jump to disk_error

	mov si, kernel_message
	call print_message

	; Jump to the loaded kernel
	jmp 0x0000:0x1000

disk_error:
	; Move cursor to next line
	mov ah, 0x02
	mov bh, 0x00
	mov dh, 2        ; Row 2 (two lines below)
	mov dl, 0x00     ; Column 0
	int 0x10

	; Print simple disk error message
	mov si, error_message
	call print_message
	jmp hang

print_message:
	lodsb
	or al, al
	jz .done

	mov ah, 0x0E
	int 0x10
	jmp print_message
.done:
	ret

hang:
	cli
	hlt
	jmp hang

startup_message:
	db "Loading DumbOS...", 0

kernel_message:
	db "Kernel loaded!", 0

error_message:
	db "Disk Read Error!", 0

; Fill the rest of the boot sector with zeros
times 510-($-$$) db 0

; Boot signature required by BIOS
dw 0xAA55