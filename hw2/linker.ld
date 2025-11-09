SECTIONS
{
  . = 0x10000;
  .text : {
    *(.text._start)
    *(.text)
  }
  
  .rodata : {
    *(.rodata*)
  }
  
  .data : {
    *(.data)
  }

  .bss : {
    __bss_start = .;
    *(.bss)
    __bss_end = .;
  }

  .stack (NOLOAD) : {
    . = ALIGN(16);
    . += 4096;
    __stack_top = .;
  }
}

