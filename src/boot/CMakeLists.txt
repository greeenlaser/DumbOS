cmake_minimum_required(VERSION 3.30)

project("DumbOS" LANGUAGES NONE)

# Create bootloader
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/boot.bin
	COMMAND nasm -f bin ${CMAKE_SOURCE_DIR}/src/boot/boot.asm -o ${CMAKE_BINARY_DIR}/boot.bin
	DEPENDS ${CMAKE_SOURCE_DIR}/src/boot/boot.asm
	COMMENT "Building bootloader with NASM"
)

# Create kernel
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/kernel.bin
	COMMAND nasm -f bin ${CMAKE_SOURCE_DIR}/src/boot/kernel.asm -o ${CMAKE_BINARY_DIR}/kernel.bin
	DEPENDS ${CMAKE_SOURCE_DIR}/src/boot/kernel.asm
	COMMENT "Building kernel with NASM"
)

# Create image from bootloader and kernel
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/boot.img
	COMMAND dd if=/dev/zero of=${CMAKE_BINARY_DIR}/boot.img bs=512 count=2880
	COMMAND dd if=${CMAKE_BINARY_DIR}/boot.bin of=${CMAKE_BINARY_DIR}/boot.img conv=notrunc
	COMMAND dd if=${CMAKE_BINARY_DIR}/kernel.bin of=${CMAKE_BINARY_DIR}/boot.img seek=1 conv=notrunc
	DEPENDS 
		${CMAKE_BINARY_DIR}/boot.bin
		${CMAKE_BINARY_DIR}/kernel.bin
	COMMENT "Building image from bootloader and kernel"
)

# Dummy for attaching boot image
add_custom_target(DumbOS ALL DEPENDS ${CMAKE_BINARY_DIR}/boot.img)