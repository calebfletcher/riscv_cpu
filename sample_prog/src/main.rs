#![no_std]
#![no_main]

use core::{arch::global_asm, panic::PanicInfo};

global_asm!(include_str!("boot.S"));

#[no_mangle]
pub extern "C" fn kmain() -> ! {
    main();

    #[allow(clippy::empty_loop)]
    loop {}
}

fn main() {
    unsafe { riscv::asm::ebreak() }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    unsafe { riscv::asm::ebreak() }
    loop {}
}
