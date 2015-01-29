SECTIONS {
.text 0x1500: { *(.text) }
.data : { *(.data) } 
.bss :  { *(.bss)  *(COMMON) } 
.kama 0xa000: { * (.kama) } 
}
