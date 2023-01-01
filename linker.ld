ENTRY(_start);

. = 0x00000000;

SECTIONS {
    .text : {
        *(.text);
    }
    .data : {
        *(.data);
    }
}
