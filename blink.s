.syntax unified
.cpu cortex-m0plus
.thumb

.equ RESETS_BASE,          0x4000c000   // Reset controller registers base
.equ IO_BANK0_GPIO25_CTRL, 0x400140cc   // GPIO25 control including function select and overrides
.equ SIO_BASE,             0xd0000000   // Single-cycle block registers base

//---- SECOND STAGE FLASH BOOT -----------------------------------------------------------------------------------------------------------------------------------

// section .boot2 contains assembled, padded and checksummed stage 2 bootloader

.section .boot2, "ax"
.word 0x4b32b500, 0x60582021, 0x21026898, 0x60984388
.word 0x611860d8, 0x4b2e6158, 0x60992100, 0x61592102
.word 0x22f02101, 0x492b5099, 0x21016019, 0x20356099
.word 0xf844f000, 0x42902202, 0x2106d014, 0xf0006619
.word 0x6e19f834, 0x66192101, 0x66182000, 0xf000661a
.word 0x6e19f82c, 0x6e196e19, 0xf0002005, 0x2101f82f
.word 0xd1f94208, 0x60992100, 0x6019491b, 0x60592100
.word 0x481b491a, 0x21016001, 0x21eb6099, 0x21a06619
.word 0xf0006619, 0x2100f812, 0x49166099, 0x60014814
.word 0x60992101, 0x2800bc01, 0x4700d000, 0x49134812
.word 0xc8036008, 0x8808f380, 0xb5034708, 0x20046a99
.word 0xd0fb4201, 0x42012001, 0xbd03d1f8, 0x6618b502
.word 0xf7ff6618, 0x6e18fff2, 0xbd026e18, 0x40020000
.word 0x18000000, 0x00070000, 0x005f0300, 0x00002221
.word 0x180000f4, 0xa0002022, 0x10000100, 0xe000ed08
.word 0x00000000, 0x00000000, 0x00000000, 0x7a4eb274

//---- VECTOR TABLE ----------------------------------------------------------------------------------------------------------------------------------------------

.section .vector_table, "ax"
_vector_table:
.word 0         // stack init value (unused)
.word main      // entry point

//----------------------------------------------------------------------------------------------------------------------------------------------------------------

.type main, %function
.global main
main:

    // clear RESETS_IO_BANK0 bit
    ldr r1, =RESETS_BASE
    movs r0, 0x20
    ldr r2, [r1, #0x00]
    bics r2, r2, r0
    str r2, [r1, #0x00]
1:
    // wait for RESET_DONE flag to set
    ldr r2, [r1, #0x08]
    ands r2, r2, r0
    beq 1b

    // set GPIO25 function to SIO
    ldr r1, =IO_BANK0_GPIO25_CTRL
    movs r0, #5
    str r0, [r1, #0x00]

    // set GPIO25 output enable
    ldr r1, =SIO_BASE
    movs r0, #1
    lsls r0, r0, #25
    str r0, [r1, #0x24]

loop:
    // set bit 25 in SIO_GPIO_OUT_XOR register to flip state of GPI025
    str r0, [r1, #0x1c]

    // busy wait
    ldr r3, =2000000
1:
    subs r3, r3, #1
    bne 1b

    b loop