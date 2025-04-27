; Tell assembler this is a boot sector
BITS 16             ; Generate 16-bit real mode code (for BIOS boot)
ORG 0x7C00          ; Load code at memory address 0x7C00

start:
	; Set up segment registers (basic BIOS bootloader standard)
	cli             ; Temporarily disable interrupts during setup
	xor ax, ax      ; Clear ax register
	mov ds, ax      ; Set DS (Data Segment) to 0
	mov es, ax      ; Set ES (Extra Segment) to 0
	mov ss, ax      ; Set SS (Stack Segment) to 0
	mov sp, 0x7C00  ; Set stack pointer to 0x7C00 (top of bootloader memory)
	sti             ; Re-enable interrupts

	; Clear the screen before writing message
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

	; Load the address of the message into SI
	mov si, message

print_loop:
	lodsb           ; Load [SI] into AL and increment SI
	or al, al       ; Check if AL == 0 (end of string)
	jz hang         ; If zero, jump to hang
	mov ah, 0x0E    ; BIOS teletype output function
	int 0x10        ; Call BIOS interrupt
	jmp print_loop  ; Repeat for next character

hang:
	hlt             ; Halt CPU
	jmp hang        ; Infinite loop to prevent going past boot sector

message db 'Hello, World!', 0

; Fill the rest of the boot sector with zeros
times 510-($-$$) db 0

; Boot signature required by BIOS
dw 0xAA55
					