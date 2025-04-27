cmake_minimum_required(VERSION 3.30)

project("DumbOS" LANGUAGES ASM_MASM)

enable_language(ASM_MASM)

set(PROJ_SRC "${CMAKE_SOURCE_DIR}/src")

file(GLOB_RECURSE ASM_SRC "${PROJ_SRC}/*.asm")

# Assemble .asm into .bin
add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/boot.bin
	COMMAND nasm -f bin ${CMAKE_SOURCE_DIR}/src/boot.asm -o ${CMAKE_BINARY_DIR}/boot.bin
	DEPENDS ${CMAKE_SOURCE_DIR}/src/boot.asm
	COMMENT "Building bootloader with NASM"
)

# Create a dummy target to make it part of the build system
add_custom_target(DumbOS ALL DEPENDS ${CMAKE_BINARY_DIR}/boot.bin)