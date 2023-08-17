title Build Station922
set MINGW_W64_DIR=C:\Program Files\mingw64
set PATH=%MINGW_W64_DIR%\bin;%PATH%

set FBC_DIR=C:\Program Files (x86)\FreeBASIC-1.10.0-winlibs-gcc-9.3.0
set FBC="%FBC_DIR%\fbc64.exe"
set CC="%FBC_DIR%\bin\win64\gcc.exe"
set AS="%FBC_DIR%\bin\win64\as.exe"
set LD="%FBC_DIR%\bin\win64\ld.exe"
set AR="%FBC_DIR%\bin\win64\ar.exe"
set GORC="%FBC_DIR%\bin\win64\GoRC.exe"
set DLL_TOOL="%FBC_DIR%\bin\win64\dlltool.exe"
set LIB_DIR=%FBC_DIR%\lib\win64
set LD_SCRIPT=%FBC_DIR%\lib\win64\fbextra.x
set GCC_DEBUGGER="%MINGW_W64_DIR%\bin\gdb.exe"
set PROCESSOR_ARCHITECTURE=AMD64
set MARCH=native
set FBC_VER=_FBC-1.09.0
set GCC_VER=_GCC-09.3.0

mingw32-make.exe createdirs
mingw32-make.exe all