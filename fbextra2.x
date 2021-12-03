/* This linker script snippet is passed to ld as an implicit linker script that
   should augment the linker's default linker script. It's supposed to drop the
   objinfo section (FB compile time information) that may be added to some/all
   objects if objinfo was enabled in fbc, since this information is just bloat
   in the final binary. */

/*
	.bss   uninitialized data
	.data  initialized data
	.rdata readonly data
	.idata import table
	.edata export table
	.rsrc  resources
	.reloc Relocation table (for code instructions with absolute addressing when
	       the module could not be loaded at its preferred base address)
	.text  the text or executable instructions of a program
	
	you should not merge .rsrc, .reloc or .pdata into other sections

*/
SECTIONS
{
	/DISCARD/ :
	{
		*(.fbctinf) *(.comment) *(.note)
	}
	.data :
	{
		*(.data)
	}
	.idata :
	{
		*(.idata)
	}
	.pdata :
	{
		*(.pdata)
	}
	.rdata :
	{
		*(.rdata) *(.xdata)
	}
	.text :
	{
		*(.text)
	}
}