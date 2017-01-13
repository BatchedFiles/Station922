@echo off
set ProgramFiles=C:\Program Files (x86)
"%ProgramFiles%\FreeBASIC\fbc.exe" -r -lib WebServer.bas Network.bas ThreadProc.bas ReadHeadersResult.bas WebUtils.bas ProcessRequests.bas base64-decode.bas Mime.bas Http.bas WebSite.bas
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "WebServer.asm" -o "WebServer.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "base64-decode.asm" -o "base64-decode.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "Network.asm" -o "Network.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "ThreadProc.asm" -o "ThreadProc.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "ReadHeadersResult.asm" -o "ReadHeadersResult.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "WebUtils.asm" -o "WebUtils.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "ProcessRequests.asm" -o "ProcessRequests.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "Mime.asm" -o "Mime.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "Http.asm" -o "Http.o"
"%ProgramFiles%\FreeBASIC\bin\win32\as.exe" --32 --strip-local-absolute "WebSite.asm" -o "WebSite.o"
"%ProgramFiles%\FreeBASIC\bin\win32\gorc" /ni /nw /o /fo "version.obj" "version.rc"
"%ProgramFiles%\FreeBASIC\bin\win32\ld.exe" -m i386pe -e _EntryPoint@0 -subsystem console -s --stack 1048576,1048576 -L "%programfiles%\freebasic\lib\win32" -L "./" "version.obj" "WebServer.o" "ProcessRequests.o" "WebUtils.o" "Network.o" "ReadHeadersResult.o" "ThreadProc.o" "base64-decode.o" "Mime.o" "Http.o" "WebSite.o" -o "WebServer.exe" -( -lkernel32 -lgdi32 -lmsimg32 -luser32 -lversion -ladvapi32 -limm32 -lshlwapi -lole32 -loleaut32 -lshell32 -lcomctl32 -lws2_32 -lmsvcrt -)