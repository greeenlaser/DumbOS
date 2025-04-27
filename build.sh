#!/bin/bash
set -e

# Set ROOT to the directory of the script
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# Define build directory
BUILD_DIR="$ROOT/build"

# Remove old build directory if it exists
if [ -d "$BUILD_DIR" ]; then
    echo "[Debug] Removing old build folder..."
    rm -rf "$BUILD_DIR"
fi

# Create fresh build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Generate build files
echo "[Debug] Generating build files..."
cmake ..

# Build the project and run it
echo "[Debug] Building project..."
if cmake --build . --config Release; then
    echo "[Success] Build succeeded!"
	echo "[Success] Booting DumbOS..."
	qemu-system-x86_64.exe -drive format=raw,file=boot.bin
else
    echo "[Error] Build failed!"
    exit 1
fi