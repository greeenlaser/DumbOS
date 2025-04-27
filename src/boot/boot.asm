; ===== DumbOS Bootloader =====

; Tell assembler this is a boot sector
BITS 16             ; Generate 16-bit real mode code (for BIOS boot)
ORG 0x7C00          ; Load code at memory address 0x7C00

boot_drive: db 0

start:
	; Set up segment registers (basic BIOS bootloader standard)
	cli
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00
	mov [boot_drive], dl ; Save BIOS dl
	sti

	; Clear the screen before writing text
	mov ah, 0x06
	mov al, 0
	mov bh, 0x07    ; Light gray text on black background
	mov cx, 0x0000  ; Upper-left corner (row 0, column 0)
	mov dx, 0x184F  ; Lower-right corner (row 24, column 79)
	int 0x10

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

	; Set up GDT
	cli
	lgdt [gdt_descriptor]

	; Enter protected mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	; Far jump to flush the pipeline and switch CS
	jmp 0x08:protected_mode_entry

; ==============================
; 16-bit Print functions
; ==============================

print_message:
	lodsb
	or al, al
	jz .done
	mov ah, 0x0E
	mov bh, 0
	int 0x10
	jmp print_message
.done:
	ret

disk_error:
	mov si, error_message
	call print_message
	cli
	hlt

; ==============================
; GDT (Global Descriptior Table)
; ==============================

gdt_start:
	; Null descriptor
	dq 0x0000000000000000

	; Code Segment descriptor (base=0, limit=4GB, 0x9A = executable, readable)
	dq 0x00CF9A000000FFFF

	; Data Segment descriptor (base=0, limit=4GB, 0x92 = writable data)
	dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1 ; Limit (16-bit)
	dd gdt_start     ; Base address (32-bit)

; ==============================
; 32-bit Entry point
; ==============================

[BITS 32]

protected_mode_entry:
	mov ax, 0x10     ; Data segment selector (second entry)
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	; Jump to loaded 32-bit kernel
	jmp 0x1000

; ==============================
; Strings
; ==============================

error_message:
	db "Disk read error!", 0

; ==============================
; Boot signature
; ==============================

times 510-($-$$) db 0
dw 0xAA55