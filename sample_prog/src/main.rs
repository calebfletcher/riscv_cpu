#![no_std]
#![no_main]

use core::{arch::global_asm, panic::PanicInfo};

global_asm!(include_str!("boot.S"));

const UART_ADDR: *mut u32 = 0x1000_1000 as _;

#[no_mangle]
pub extern "C" fn kmain() -> ! {
    main();

    #[allow(clippy::empty_loop)]
    loop {}
}

fn main() {
    unsafe {
        UART_ADDR.add(1).write_volatile(0x00);
        UART_ADDR.add(3).write_volatile(0x80);
        UART_ADDR.add(0).write_volatile(0x03);
        UART_ADDR.add(1).write_volatile(0x00);
        UART_ADDR.add(3).write_volatile(0x03);
        UART_ADDR.add(2).write_volatile(0xC7);
        UART_ADDR.add(4).write_volatile(0x0B);
        UART_ADDR.add(1).write_volatile(0x01);
    }

    for byte in "hello world".as_bytes() {
        unsafe {
            UART_ADDR.write_volatile(*byte as u32);
        }
    }
    unsafe { riscv::asm::ebreak() }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    unsafe { riscv::asm::ebreak() }
    loop {}
}
