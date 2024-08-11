MEMORY
{
	rom (rx)  : ORIGIN = 0x00000000, LENGTH = 128K
	ram (rwx) : ORIGIN = 0x00020000, LENGTH = 64K
}

SECTIONS 
{	
	. = ORIGIN(rom);
	.text : 
	{ 
		KEEP(*(.isr_vector .isr_vector.*)) 
		. = ALIGN(2);
		*(.text .text.* .gnu.linkonce.t.*) 		  
		*(.glue_7t)
		*(.glue_7)						
		*(.rodata .rodata* .gnu.linkonce.r.*)								  
		. = ALIGN(4);
	} > rom
	
	.ARM.extab : 
	{
		*(.ARM.extab* .gnu.linkonce.armextab.*)
	} > rom

	__exidx_start = .;
	.ARM.exidx :
	{
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
	} > rom
	__exidx_end = .;

	. = ALIGN(4); 
	_etext = .;
	_sidata = .; 

	.data :
	{
		PROVIDE (_sdata = .); 
		*(.data .data.*) 
		*(.sdata)
	        . = ALIGN(4);
        	PROVIDE (__ctors_begin = .);
	        KEEP (*(SORT(.ctors*)))
        	KEEP (*(.ctors))
	        PROVIDE (__ctors_end = .);
        	PROVIDE (__preinit_array_start = .);
	        KEEP (*(SORT(.preinit_array.*)))
        	KEEP (*(.preinit_array))
	        PROVIDE (__preinit_array_end = .);
        	PROVIDE (__init_array_start = .);
	        KEEP (*(SORT(.init_array.*)))
        	KEEP (*(.init_array))
	        PROVIDE (__init_array_end = .);
		. = ALIGN(4); 
		PROVIDE (_edata = .);
	} >ram AT >rom

	.bss (NOLOAD) : 
	{
		PROVIDE(_sbss = .); 
		*(.bss .bss.*) 
		*(COMMON) 
		. = ALIGN(4); 
		PROVIDE(_ebss = .); 
	} > ram

	.stack (NOLOAD):
	{
		. = ALIGN(8);
		*(.stack .stack.*)
		. = ALIGN(4); 
		PROVIDE(_end_stack = .); 
	} > ram

	.heap (NOLOAD):
	{
		*(.heap .heap.*)
	} > ram
	
	. = ALIGN(4); 
	_end = . ;
}
PROVIDE(_estack = ORIGIN(ram) + LENGTH(ram));
PROVIDE(_data_load = LOADADDR(.data));
