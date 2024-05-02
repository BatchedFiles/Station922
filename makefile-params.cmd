if %PROCESSOR_ARCHITECTURE% == AMD64 (
set BinFolder=bin\win64
set LibFolder=lib\win64
) else (
set BinFolder=bin\win32
set LibFolder=lib\win32
)

rem Add mingw64 directory to PATH
set MINGW_W64_DIR=C:\Program Files\mingw64
set PATH=%MINGW_W64_DIR%\bin;%PATH%

rem Add compiler directory to PATH
set FBC_DIR=C:\Program Files (x86)\FreeBASIC-1.10.1-winlibs-gcc-9.3.0
set PATH=%FBC_DIR%\%BinFolder%;%PATH%

rem File Suffixes
set GCC_VER=_GCC0930
set FBC_VER=_FBC1101

set USE_RUNTIME=FALSE
rem WinAPI version
set WINVER=1281
set _WIN32_WINNT=1281

rem Use unicode in WinAPI
set USE_UNICODE=TRUE
set FILE_SUFFIX=%GCC_VER%%FBC_VER%%RUNTIME%

rem Toolchain
set FBC="%FBC_DIR%\fbc64.exe"
set CC="%FBC_DIR%\%BinFolder%\gcc.exe"
set AS="%FBC_DIR%\%BinFolder%\as.exe"
set AR="%FBC_DIR%\%BinFolder%\ar.exe"
set GORC="%FBC_DIR%\%BinFolder%\GoRC.exe"
set LD="%FBC_DIR%\%BinFolder%\ld.exe"
set DLL_TOOL="%FBC_DIR%\%BinFolder%\dlltool.exe"

rem Without quotes:
set LIB_DIR==%FBC_DIR%\%LibFolder%
set INC_DIR=%FBC_DIR%\inc
set SRC_DIR=src

rem Linker script only for GCC x86, GCC x64 and Clang x86
rem Without quotes:
set LD_SCRIPT=%FBC_DIR%\%LibFolder%\fbextra.x

set MARCH=native

rem Only for Clang x86
rem set TARGET_TRIPLET=i686-pc-windows-gnu

rem Only for Clang AMD64
rem set TARGET_TRIPLET=x86_64-w64-pc-windows-msvc
rem set FLTO=-flto

rem Create bin obj folders
rem mingw32-make createdirs

rem Compile
rem mingw32-make all