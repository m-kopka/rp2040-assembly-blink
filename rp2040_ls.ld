ENTRY(main)

MEMORY {

    FLASH(rx) : ORIGIN = 0x10000000, LENGTH = 2048k
    SRAM(rwx) : ORIGIN = 0x20000000, LENGTH = 264k
}

SECTIONS {

    /* 256 bytes of stage 2 bootrom */
    .boot2 : {
        *(.boot2)
    } > FLASH

    .text : {

        *(.vector_table)
        *(.text)
        *(.rodata)
        . = ALIGN(4);

        _la_data = .;   /* start address of .data in FLASH */
    } > FLASH

    .data : {

        _sdata = .;     /* start address of .data in SRAM */
        *(.data*)
        _edata = .;     /* end address of .data in SRAM */
        . = ALIGN(4);

    } > SRAM AT> FLASH

    .bss  : {

        _sbss = .;      /* start address of .bss in SRAM */
        *(.bss*)
        _ebss = .;      /* end address of .data in SRAM */
        . = ALIGN(4);

    } > SRAM
}
