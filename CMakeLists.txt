cmake_minimum_required(VERSION 3.30)

project(DumbOS LANGUAGES C ASM NONE)

# Source folders
set(BOOT_SRC_DIR "${CMAKE_SOURCE_DIR}/src/boot")
set(KERNEL_SRC_DIR "${CMAKE_SOURCE_DIR}/src/kernel")

# Include folders
set(INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include")

include_directories(${INCLUDE_DIR})

# Create boot as binary file
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/boot.bin
	COMMAND nasm -f bin 
		${BOOT_SRC_DIR}/boot.asm
		-o ${CMAKE_BINARY_DIR}/boot.bin
	DEPENDS
		${BOOT_SRC_DIR}/boot.asm
	COMMENT "Building boot.asm as binary file"
)

# Create boot2 as object file
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/boot2.o
	COMMAND nasm -f elf32
		${BOOT_SRC_DIR}/boot2.asm
		-o ${CMAKE_BINARY_DIR}/boot2.o
	DEPENDS 
		${BOOT_SRC_DIR}/boot2.asm
	COMMENT "Building boot2.asm as object file"
)

# Build kernel.c as object file
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/kernel.o
	COMMAND i686-elf-gcc -m32
		-ffreestanding
		-fno-builtin
		-nostdlib
		-nostartfiles
		-I${INCLUDE_DIR}
		-c ${KERNEL_SRC_DIR}/kernel.c
		-o ${CMAKE_BINARY_DIR}/kernel.o
	DEPENDS
		${KERNEL_SRC_DIR}/kernel.c
	COMMENT "Building kernel.c as object file"
)

# Build utils.c as object file
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/utils.o
	COMMAND i686-elf-gcc
		-m32
		-ffreestanding
		-fno-builtin
		-nostdlib
		-nostartfiles
		-I${INCLUDE_DIR}
		-c ${KERNEL_SRC_DIR}/utils.c
		-o ${CMAKE_BINARY_DIR}/utils.o
	DEPENDS
		${KERNEL_SRC_DIR}/utils.c
	COMMENT "Building utils.c as object file"
)

# Link boot2 with kernel.c into kernel.bin
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/kernel.bin
	COMMAND i686-elf-ld -Ttext 0x1000 
		${CMAKE_BINARY_DIR}/boot2.o
		${CMAKE_BINARY_DIR}/kernel.o
		${CMAKE_BINARY_DIR}/utils.o
		-o ${CMAKE_BINARY_DIR}/kernel.bin --oformat binary
	DEPENDS
		${CMAKE_BINARY_DIR}/boot2.o
		${CMAKE_BINARY_DIR}/kernel.o
		${CMAKE_BINARY_DIR}/utils.o
	COMMENT "Linking boot2.o, kernel.o and utils.o into kernel.bin"
)

# Create boot image
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/boot.img
	COMMAND dd if=/dev/zero of=${CMAKE_BINARY_DIR}/boot.img bs=512 count=2880
	COMMAND dd if=${CMAKE_BINARY_DIR}/boot.bin of=${CMAKE_BINARY_DIR}/boot.img conv=notrunc
	COMMAND dd if=${CMAKE_BINARY_DIR}/kernel.bin of=${CMAKE_BINARY_DIR}/boot.img seek=1 conv=notrunc
	DEPENDS 
		${CMAKE_BINARY_DIR}/boot.bin
		${CMAKE_BINARY_DIR}/kernel.bin
	COMMENT "Building boot image from boot.bin and kernel.bin"
)

# Dummy for attaching boot image
add_custom_target(DumbOS ALL DEPENDS ${CMAKE_BINARY_DIR}/boot.img)