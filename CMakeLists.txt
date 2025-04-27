cmake_minimum_required(VERSION 3.30)

project("DumbOS" LANGUAGES NONE)

set(BOOT_DIR "${CMAKE_SOURCE_DIR}/src/boot")
# set(KERNEL_DIR "${CMAKE_SOURCE_DIR}/src/kernel")

# Include bootloader build system
add_subdirectory("${BOOT_DIR}")

# Include kernel build system
# add_subdirectory("${KERNEL_DIR%}")