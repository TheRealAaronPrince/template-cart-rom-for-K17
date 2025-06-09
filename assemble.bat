@echo off
del "cart.k17"
vasm6502_oldstyle -Fbin -dotdir -autoexp start.asm -o "cart.k17"
if not exist "cart.k17" (
pause
)