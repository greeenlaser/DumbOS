cmake_minimum_required(VERSION 3.30)

project("DumbOS" LANGUAGES NONE)

# Create bootloader
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/boot.bin
	COMMAND nasm -f bin ${CMAKE_SOURCE_DIR}/src/boot/boot.asm -o ${CMAKE_BINARY_DIR}/boot.bin
	DEPENDS ${CMAKE_SOURCE_DIR}/src/boot/boot.asm
	COMMENT "Building bootloader with NASM"
)

# Create image from bootloader
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/boot.img
	COMMAND cat ${CMAKE_BINARY_DIR}/boot.bin > ${CMAKE_BINARY_DIR}/boot.img
	DEPENDS 
		${CMAKE_BINARY_DIR}/boot.bin
	COMMENT "Building boot image"
)

# Combine bootloaders together
add_custom_target(DumbOS ALL DEPENDS ${CMAKE_BINARY_DIR}/boot.img)