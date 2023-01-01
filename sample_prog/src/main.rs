#![no_std]
#![no_main]

use core::{arch::global_asm, panic::PanicInfo};

global_asm!(include_str!("boot.S"));

const UART_TX_ADDR: *mut u8 = 0x82000000 as *mut u8;

#[no_mangle]
pub extern "C" fn kmain() -> ! {
    main();

    #[allow(clippy::empty_loop)]
    loop {}
}

fn main() {
    for byte in "hello world".as_bytes() {
        unsafe {
            UART_TX_ADDR.write_volatile(*byte);
        }
    }
    unsafe { riscv::asm::ebreak() }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    unsafe { riscv::asm::ebreak() }
    loop {}
}
