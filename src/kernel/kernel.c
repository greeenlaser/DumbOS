// Copyright (C) 2025 Greenlaser
// This program comes with ABSOLUTELY NO WARRANTY.
// This is free software, and you are welcome to redistribute it under certain conditions.
// Read LICENSE.md for more information.

//dumbOS
#include "kernel/utils.h"

volatile unsigned short* vga = (volatile unsigned short*)0xB8000;
int cursor = 160;

void _start()
{
	//manually draw a single x
	vga[cursor / 2] = (0x07 << 8) | 'Y';

	while (1)
	{
		__asm__ __volatile__("hlt");
	}
}