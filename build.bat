@echo off
REM Octobus Mincraft - Windows build
REM 필요: Arm GNU Toolchain (arm-none-eabi-gcc 가 PATH 에 있어야 함), Python 3 + Pillow (pip install pillow)
setlocal enabledelayedexpansion
set CF=-Os -Wall -ffreestanding -fno-builtin -nostdlib -fno-strict-aliasing -mcpu=arm946e-s
if not exist build\o9 mkdir build\o9

echo [1/4] BMP -^> C 데이터 변환
python tools\make_assets.py gfx src\arm9 || goto :err
if exist unifont.otf python tools\make_lang.py lang\strings.txt src\arm9 unifont.otf

echo [2/4] ARM9 (게임 본체)
set OBJS=
for %%f in (assets entity fat fire gen gfx2d lang main player render save ui util world) do (
  arm-none-eabi-gcc %CF% -mthumb -c src\arm9\%%f.c -o build\o9\%%f.o || goto :err
  set OBJS=!OBJS! build\o9\%%f.o
)
arm-none-eabi-gcc %CF% -mthumb src\arm9\crt0.s src\arm9\dldi.s !OBJS! -nostartfiles -T src\arm9\arm9.ld -lgcc -o build\arm9.elf || goto :err
arm-none-eabi-objcopy -O binary build\arm9.elf build\arm9.bin || goto :err

echo [3/4] ARM7 (버튼/터치)
arm-none-eabi-gcc -O2 -Wall -ffreestanding -fno-builtin -nostdlib -mcpu=arm7tdmi -mthumb src\arm7\crt0.s src\arm7\main.c -nostartfiles -T src\arm7\arm7.ld -lgcc -o build\arm7.elf || goto :err
arm-none-eabi-objcopy -O binary build\arm7.elf build\arm7.bin || goto :err

echo [4/4] .nds 만들기
python tools\mknds.py build\arm9.bin build\arm7.bin OctobusMincraft.nds --icon build\icon.png --title "Octobus Mincraft;Octobus Entertainment;DS Lite" || goto :err
echo 완료: OctobusMincraft.nds
goto :eof
:err
echo 빌드 실패
exit /b 1
