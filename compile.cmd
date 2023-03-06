set FBC_DIR=C:\Programming\FreeBASIC-1.09.0-win64-gcc-9.3.0
set FBC_32="%FBC_DIR%\fbc32.exe"
set FBC_64="%FBC_DIR%\fbc64.exe"
set OPTIONS=-O 3 -gen gcc -Wc -ffunction-sections,-fdata-sections -Wl --gc-sections

%FBC_32% -m Station922 -l crypt32 -x Station922_x86.exe %OPTIONS% src\*.bas src\*.RC
%FBC_64% -m Station922 -l crypt32 -x Station922_x64.exe %OPTIONS% src\*.bas src\*.RC