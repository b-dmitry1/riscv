@echo off

riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -mcmodel=medany -O0 -nostartfiles -Tmyriscv.ld program.s
riscv64-unknown-elf-objcopy -O symbolsrec a.out program.bin
riscv64-unknown-elf-objdump -d a.out >a.asm

if exist program.hex del program.hex
for /f "usebackq tokens=1-9,* delims=	" %%a in ("a.asm") do (
   if not [%%b] == [] echo %%b >>program.hex
)


pause
