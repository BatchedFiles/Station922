COMPILERDIRECTORY=%ProgramFiles%\FreeBASIC
FREEBASIC_COMPILER="C:\Program Files\FreeBASIC\fbc.exe"
INCLUDEFILESPATH=-i Classes -i Interfaces -i Modules -i Headers
EXETYPEKIND=console
MAXERRORSCOUNT=-maxerr 1
MINWARNINGLEVEL=-w all
UseThreadSafeRuntime=-mt

ALL_OBJECT_FILES=$(OBJ_DIR)\ArrayStringWriter.o $(OBJ_DIR)\AsyncResult.o $(OBJ_DIR)\ClientContext.o $(OBJ_DIR)\ClientRequest.o $(OBJ_DIR)\Configuration.o $(OBJ_DIR)\HeapBSTR.o $(OBJ_DIR)\HttpGetProcessor.o $(OBJ_DIR)\HttpReader.o $(OBJ_DIR)\Mime.o $(OBJ_DIR)\NetworkStream.o $(OBJ_DIR)\PrivateHeapMemoryAllocator.o $(OBJ_DIR)\RequestedFile.o $(OBJ_DIR)\SafeHandle.o $(OBJ_DIR)\ServerResponse.o $(OBJ_DIR)\Station922Uri.o $(OBJ_DIR)\WebServer.o $(OBJ_DIR)\WebSite.o $(OBJ_DIR)\WebSiteContainer.o $(OBJ_DIR)\CreateInstance.o $(OBJ_DIR)\EntryPoint.o $(OBJ_DIR)\FindNewLineIndex.o $(OBJ_DIR)\Guids.o $(OBJ_DIR)\Http.o $(OBJ_DIR)\Network.o $(OBJ_DIR)\NetworkClient.o $(OBJ_DIR)\NetworkServer.o $(OBJ_DIR)\WebUtils.o $(OBJ_DIR)\WorkerThread.o $(OBJ_DIR)\WriteHttpError.o $(OBJ_DIR)\Resources.obj
ALL_OBJECT_FILES_SERVICE=$(ALL_OBJECT_FILES) $(OBJ_DIR)\WindowsServiceMain.o
ALL_OBJECT_FILES_CONSOLE=$(ALL_OBJECT_FILES) $(OBJ_DIR)\ConsoleColors.o $(OBJ_DIR)\ConsoleMain.o $(OBJ_DIR)\PrintDebugInfo.o

# FreeBASIC   *.bas     -> *.c + зависимости от заголовочников
# GccCompiler *.c       -> *.asm
# Assembler   *.asm     -> *.o
# ResCompiler *.RC      -> *.obj
# Linker      *.o *.obj -> *.exe

CODEGENERATIONBACKEND=gcc
# CODEGENERATIONBACKEND=gas
# CODEGENERATIONBACKEND=lvvm
# CODEGENERATIONBACKEND=studious

# REM set UseThreadSafeRuntime=-mt
# REM set EnableShowIncludes=-showincludes
# REM set EnableVerbose=-v
# REM set EnableRuntimeErrorChecking=-e
# REM set EnableFunctionProfiling=-profile

# set AllCompiledFiles=%~1
# set ExeTypeKind=%~2
# set OutputFileName=%~3
# set Directory=%~4
# set CompilerParameters=%~5
# set DebugFlag=%~6
# set ProfileFlag=%~7
# set WithoutRuntimeLibraryesFlag=%~8

BIN_DEBUG_DIR_64=bin\Debug\x64
BIN_RELEASE_DIR_64=bin\Release\x64
OBJ_DEBUG_DIR_64=obj\Debug\x64
OBJ_RELEASE_DIR_64=obj\Release\x64

BIN_DEBUG_DIR_86=bin\Debug\x86
BIN_RELEASE_DIR_86=bin\Release\x86
OBJ_DEBUG_DIR_86=obj\Debug\x86
OBJ_RELEASE_DIR_86=obj\Release\x86

UuidObjectLibraries=-luuid
GMonitorObjectLibraries=-lgmon
GccObjectLibraries=-lmoldname -lgcc
WinApiObjectLibraries=-ladvapi32 -lcomctl32 -lcomdlg32 -lcrypt32 -lgdi32 -lgdiplus -limm32 -lkernel32 -lmsimg32 -lmsvcrt -lmswsock -lole32 -loleaut32 -lshell32 -lshlwapi -luser32 -lversion -lwinmm -lwinspool -lws2_32
ALL_OBJECT_LIBRARIES=$(WinApiObjectLibraries) $(GMonitorObjectLibraries) $(GccObjectLibraries)

MajorImageVersion=--major-image-version 1
MinorImageVersion=--minor-image-version 0

# цель:             консоль служба
# переменная среды: дебуг   релиз
# переменная среды: рантайм без рантайма
# переменная среды: 86      64
# переменная среды: гсс     ллвм         студио

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)

# GCC_COMPILER="C:\Program Files\FreeBASIC\bin\win64\gcc.exe"
# GCC_ASSEMBLER="C:\Program Files\FreeBASIC\bin\win64\as.exe"
# GCC_LINKER="C:\Program Files\FreeBASIC\bin\win64\ld.exe"
# ARCHIVE_COMPILER="C:\Program Files\FreeBASIC\bin\win64\ar.exe"
# DLL_TOOL="C:\Program Files\FreeBASIC\bin\win64\dlltool.exe"
GCC_COMPILER="C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\gcc.exe"
GCC_ASSEMBLER="C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\as.exe"
GCC_LINKER="C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\ld.exe"
ARCHIVE_COMPILER="C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\ar.exe"
DLL_TOOL="C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\dlltool.exe"
RESOURCE_COMPILER="C:\Program Files\FreeBASIC\bin\win64\GoRC.exe"
COMPILER_LIB_PATH="C:\Program Files\FreeBASIC\lib\win64"
FBEXTRA="C:\Program Files\FreeBASIC\lib\win64\fbextra.x"

GCC_ARCHITECTURE=-m64 -march=x86-64
TARGET_ASSEMBLER_ARCH=--64
ENTRY_POINT=EntryPoint
PE_FILE_FORMAT=i386pep

BIN_DEBUG_DIR=$(BIN_DEBUG_DIR_64)
BIN_RELEASE_DIR=$(BIN_RELEASE_DIR_64)
OBJ_DEBUG_DIR=$(OBJ_DEBUG_DIR_64)
OBJ_RELEASE_DIR=$(OBJ_RELEASE_DIR_64)

ResourceCompilerBitFlag=/machine X64

else

GCC_COMPILER="C:\Program Files\FreeBASIC\bin\win32\gcc.exe"
GCC_ASSEMBLER="C:\Program Files\FreeBASIC\bin\win32\as.exe"
RESOURCE_COMPILER="C:\Program Files\FreeBASIC\bin\win32\GoRC.exe"
GCC_LINKER="C:\Program Files\FreeBASIC\bin\win32\ld.exe"
ARCHIVE_COMPILER="C:\Program Files\FreeBASIC\bin\win32\ar.exe"
DLL_TOOL="C:\Program Files\FreeBASIC\bin\win32\dlltool.exe"
COMPILER_LIB_PATH="C:\Program Files\FreeBASIC\lib\win32"
FBEXTRA="C:\Program Files\FreeBASIC\lib\win32\fbextra.x"

GCC_ARCHITECTURE=
TARGET_ASSEMBLER_ARCH=--32
ENTRY_POINT=_EntryPoint@0
PE_FILE_FORMAT=i386pe

BIN_DEBUG_DIR=$(BIN_DEBUG_DIR_86)
BIN_RELEASE_DIR=$(BIN_RELEASE_DIR_86)
OBJ_DEBUG_DIR=$(OBJ_DEBUG_DIR_86)
OBJ_RELEASE_DIR=$(OBJ_RELEASE_DIR_86)

ResourceCompilerBitFlag=/nw

endif

# %FreeBasicCompilerFilePath% %WITHOUT_RUNTIME_DEFINED% -x %CompilerOutputFileName% -s %Win32Subsystem% %CompilerExeTypeKind% %CompilerDebugFlag% %CompilerProfileFlag% %AllCompiledFiles%

# CompilerParameters=%PERFORMANCE_TESTING_DEFINED% %GUIDS_WITHOUT_MINGW%  %UseThreadSafeRuntime% %EnableFunctionProfiling% %EnableShowIncludes% %EnableVerbose% %EnableRuntimeErrorChecking% %IncludeLibraries%

# if "%3"=="withoutruntime" (
	# set WithoutRuntime=withoutruntime
	# set GUIDS_WITHOUT_MINGW=-d GUIDS_WITHOUT_MINGW=1
# ) else (
	# set WithoutRuntime=runtime
	# set GUIDS_WITHOUT_MINGW=
# )

# ifeq ($(SERVICE_DEFINED),service)
# WINDOWS_SERVICE_DEFINED=-d WINDOWS_SERVICE
# else
# WINDOWS_SERVICE_DEFINED=
# endif

ifeq ($(RUNTIME_DEFINED),runtime)
WITHOUT_RUNTIME_DEFINED=
else
WITHOUT_RUNTIME_DEFINED=-d GUIDS_WITHOUT_MINGW -d WITHOUT_RUNTIME
endif

FREEBASIC_PARAMETERS_BASE=-r -gen $(CODEGENERATIONBACKEND) $(MAXERRORSCOUNT) $(MINWARNINGLEVEL) $(INCLUDEFILESPATH) -d UNICODE -d WITHOUT_CRITICAL_SECTIONS $(WINDOWS_SERVICE_DEFINED) $(WITHOUT_RUNTIME_DEFINED)

GCC_WARNING=-Werror -Wall -Wno-unused-label -Wno-unused-function -Wno-main
GCC_NOINCLUDE=-nostdlib -nostdinc -mno-stack-arg-probe -fno-stack-check -fno-stack-protector -fno-strict-aliasing -frounding-math -fno-math-errno -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-ident

DEFAULT_STACK_SIZE=--stack 1048576,1048576

ifeq ($(DEBUGFLAG),debug)

GCC_OPTIMIZATIONS=-Og
ASSEMBLER_STRIP_FLAG=
LINKER_STRIP_FLAG=
BIN_DIR=$(BIN_DEBUG_DIR)
OBJ_DIR=$(OBJ_DEBUG_DIR)
GCC_COMPILER_PARAMETERS=$(GCC_WARNING) $(GCC_NOINCLUDE) $(GCC_ARCHITECTURE) -masm=intel -S -Og -g
FREEBASIC_PARAMETERS=$(FREEBASIC_PARAMETERS_BASE) -g
else

GCC_OPTIMIZATIONS=-Ofast
ASSEMBLER_STRIP_FLAG=--strip-local-absolute
LINKER_STRIP_FLAG=-s
BIN_DIR=$(BIN_RELEASE_DIR)
OBJ_DIR=$(OBJ_RELEASE_DIR)
GCC_COMPILER_PARAMETERS=$(GCC_WARNING) $(GCC_NOINCLUDE) $(GCC_ARCHITECTURE) -masm=intel -S -Ofast
FREEBASIC_PARAMETERS=$(FREEBASIC_PARAMETERS_BASE) -g

endif

.PHONY: all clean install uninstall configure

# all: дебуг-ехе релиз-ехе дебуг-служба релиз-служба

$(BIN_DIR)\WebServer.exe: $(ALL_OBJECT_FILES_CONSOLE)
	$(GCC_LINKER) -m $(PE_FILE_FORMAT) -subsystem console -e $(ENTRY_POINT) $(DEFAULT_STACK_SIZE) $(LINKER_STRIP_FLAG) -L $(COMPILER_LIB_PATH) -L "." $(FBEXTRA) $(ALL_OBJECT_FILES_CONSOLE) -( $(ALL_OBJECT_LIBRARIES) -) -o "$(BIN_DIR)\WebServer.exe"

$(BIN_DIR)\Station922.exe: WINDOWS_SERVICE_DEFINED=-d WINDOWS_SERVICE

$(BIN_DIR)\Station922.exe: $(ALL_OBJECT_FILES_SERVICE)
	$(GCC_LINKER) -m $(PE_FILE_FORMAT) -subsystem console -e $(ENTRY_POINT) $(DEFAULT_STACK_SIZE) $(LINKER_STRIP_FLAG) -L $(COMPILER_LIB_PATH) -L "." $(FBEXTRA) $(ALL_OBJECT_FILES_SERVICE) -( $(ALL_OBJECT_LIBRARIES) -) -o "$(BIN_DIR)\Station922.exe"


$(OBJ_DIR)\ArrayStringWriter.o: $(OBJ_DIR)\ArrayStringWriter.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ArrayStringWriter.asm -o $(OBJ_DIR)\ArrayStringWriter.o

$(OBJ_DIR)\ArrayStringWriter.asm: $(OBJ_DIR)\ArrayStringWriter.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ArrayStringWriter.c -o $(OBJ_DIR)\ArrayStringWriter.asm

$(OBJ_DIR)\ArrayStringWriter.c: Classes\ArrayStringWriter.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ArrayStringWriter.bas"
	move /y Classes\ArrayStringWriter.c $(OBJ_DIR)\ArrayStringWriter.c


$(OBJ_DIR)\AsyncResult.o: $(OBJ_DIR)\AsyncResult.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\AsyncResult.asm -o $(OBJ_DIR)\AsyncResult.o

$(OBJ_DIR)\AsyncResult.asm: $(OBJ_DIR)\AsyncResult.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\AsyncResult.c -o $(OBJ_DIR)\AsyncResult.asm

$(OBJ_DIR)\AsyncResult.c: Classes\AsyncResult.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\AsyncResult.bas"
	move /y Classes\AsyncResult.c $(OBJ_DIR)\AsyncResult.c


$(OBJ_DIR)\ClientContext.o: $(OBJ_DIR)\ClientContext.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ClientContext.asm -o $(OBJ_DIR)\ClientContext.o

$(OBJ_DIR)\ClientContext.asm: $(OBJ_DIR)\ClientContext.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ClientContext.c -o $(OBJ_DIR)\ClientContext.asm

$(OBJ_DIR)\ClientContext.c: Classes\ClientContext.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ClientContext.bas"
	move /y Classes\ClientContext.c $(OBJ_DIR)\ClientContext.c


$(OBJ_DIR)\ClientRequest.o: $(OBJ_DIR)\ClientRequest.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ClientRequest.asm -o $(OBJ_DIR)\ClientRequest.o

$(OBJ_DIR)\ClientRequest.asm: $(OBJ_DIR)\ClientRequest.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ClientRequest.c -o $(OBJ_DIR)\ClientRequest.asm

$(OBJ_DIR)\ClientRequest.c: Classes\ClientRequest.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ClientRequest.bas"
	move /y Classes\ClientRequest.c $(OBJ_DIR)\ClientRequest.c


$(OBJ_DIR)\Configuration.o: $(OBJ_DIR)\Configuration.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Configuration.asm -o $(OBJ_DIR)\Configuration.o

$(OBJ_DIR)\Configuration.asm: $(OBJ_DIR)\Configuration.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Configuration.c -o $(OBJ_DIR)\Configuration.asm

$(OBJ_DIR)\Configuration.c: Classes\Configuration.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\Configuration.bas"
	move /y Classes\Configuration.c $(OBJ_DIR)\Configuration.c


$(OBJ_DIR)\HeapBSTR.o: $(OBJ_DIR)\HeapBSTR.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\HeapBSTR.asm -o $(OBJ_DIR)\HeapBSTR.o

$(OBJ_DIR)\HeapBSTR.asm: $(OBJ_DIR)\HeapBSTR.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\HeapBSTR.c -o $(OBJ_DIR)\HeapBSTR.asm

$(OBJ_DIR)\HeapBSTR.c: Classes\HeapBSTR.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\HeapBSTR.bas"
	move /y Classes\HeapBSTR.c $(OBJ_DIR)\HeapBSTR.c


$(OBJ_DIR)\HttpGetProcessor.o: $(OBJ_DIR)\HttpGetProcessor.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\HttpGetProcessor.asm -o $(OBJ_DIR)\HttpGetProcessor.o

$(OBJ_DIR)\HttpGetProcessor.asm: $(OBJ_DIR)\HttpGetProcessor.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\HttpGetProcessor.c -o $(OBJ_DIR)\HttpGetProcessor.asm

$(OBJ_DIR)\HttpGetProcessor.c: Classes\HttpGetProcessor.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\HttpGetProcessor.bas"
	move /y Classes\HttpGetProcessor.c $(OBJ_DIR)\HttpGetProcessor.c


$(OBJ_DIR)\HttpReader.o: $(OBJ_DIR)\HttpReader.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\HttpReader.asm -o $(OBJ_DIR)\HttpReader.o

$(OBJ_DIR)\HttpReader.asm: $(OBJ_DIR)\HttpReader.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\HttpReader.c -o $(OBJ_DIR)\HttpReader.asm

$(OBJ_DIR)\HttpReader.c: Classes\HttpReader.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\HttpReader.bas"
	move /y Classes\HttpReader.c $(OBJ_DIR)\HttpReader.c


$(OBJ_DIR)\Mime.o: $(OBJ_DIR)\Mime.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Mime.asm -o $(OBJ_DIR)\Mime.o

$(OBJ_DIR)\Mime.asm: $(OBJ_DIR)\Mime.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Mime.c -o $(OBJ_DIR)\Mime.asm

$(OBJ_DIR)\Mime.c: Classes\Mime.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\Mime.bas"
	move /y Classes\Mime.c $(OBJ_DIR)\Mime.c


$(OBJ_DIR)\NetworkStream.o: $(OBJ_DIR)\NetworkStream.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\NetworkStream.asm -o $(OBJ_DIR)\NetworkStream.o

$(OBJ_DIR)\NetworkStream.asm: $(OBJ_DIR)\NetworkStream.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\NetworkStream.c -o $(OBJ_DIR)\NetworkStream.asm

$(OBJ_DIR)\NetworkStream.c: Classes\NetworkStream.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\NetworkStream.bas"
	move /y Classes\NetworkStream.c $(OBJ_DIR)\NetworkStream.c


$(OBJ_DIR)\PrivateHeapMemoryAllocator.o: $(OBJ_DIR)\PrivateHeapMemoryAllocator.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\PrivateHeapMemoryAllocator.asm -o $(OBJ_DIR)\PrivateHeapMemoryAllocator.o

$(OBJ_DIR)\PrivateHeapMemoryAllocator.asm: $(OBJ_DIR)\PrivateHeapMemoryAllocator.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\PrivateHeapMemoryAllocator.c -o $(OBJ_DIR)\PrivateHeapMemoryAllocator.asm

$(OBJ_DIR)\PrivateHeapMemoryAllocator.c: Classes\PrivateHeapMemoryAllocator.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\PrivateHeapMemoryAllocator.bas"
	move /y Classes\PrivateHeapMemoryAllocator.c $(OBJ_DIR)\PrivateHeapMemoryAllocator.c


$(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.o: $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.asm -o $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.o

$(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.asm: $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.c -o $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.asm

$(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.c: Classes\PrivateHeapMemoryAllocatorClassFactory.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\PrivateHeapMemoryAllocatorClassFactory.bas"
	move /y Classes\PrivateHeapMemoryAllocatorClassFactory.c $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory.c


$(OBJ_DIR)\RequestedFile.o: $(OBJ_DIR)\RequestedFile.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\RequestedFile.asm -o $(OBJ_DIR)\RequestedFile.o

$(OBJ_DIR)\RequestedFile.asm: $(OBJ_DIR)\RequestedFile.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\RequestedFile.c -o $(OBJ_DIR)\RequestedFile.asm

$(OBJ_DIR)\RequestedFile.c: Classes\RequestedFile.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\RequestedFile.bas"
	move /y Classes\RequestedFile.c $(OBJ_DIR)\RequestedFile.c


$(OBJ_DIR)\SafeHandle.o: $(OBJ_DIR)\SafeHandle.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\SafeHandle.asm -o $(OBJ_DIR)\SafeHandle.o

$(OBJ_DIR)\SafeHandle.asm: $(OBJ_DIR)\SafeHandle.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\SafeHandle.c -o $(OBJ_DIR)\SafeHandle.asm

$(OBJ_DIR)\SafeHandle.c: Classes\SafeHandle.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\SafeHandle.bas"
	move /y Classes\SafeHandle.c $(OBJ_DIR)\SafeHandle.c


$(OBJ_DIR)\ServerResponse.o: $(OBJ_DIR)\ServerResponse.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ServerResponse.asm -o $(OBJ_DIR)\ServerResponse.o

$(OBJ_DIR)\ServerResponse.asm: $(OBJ_DIR)\ServerResponse.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ServerResponse.c -o $(OBJ_DIR)\ServerResponse.asm

$(OBJ_DIR)\ServerResponse.c: Classes\ServerResponse.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ServerResponse.bas"
	move /y Classes\ServerResponse.c $(OBJ_DIR)\ServerResponse.c


$(OBJ_DIR)\ServerState.o: $(OBJ_DIR)\ServerState.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ServerState.asm -o $(OBJ_DIR)\ServerState.o

$(OBJ_DIR)\ServerState.asm: $(OBJ_DIR)\ServerState.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ServerState.c -o $(OBJ_DIR)\ServerState.asm

$(OBJ_DIR)\ServerState.c: Classes\ServerState.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ServerState.bas"
	move /y Classes\ServerState.c $(OBJ_DIR)\ServerState.c


$(OBJ_DIR)\Station922Uri.o: $(OBJ_DIR)\Station922Uri.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Station922Uri.asm -o $(OBJ_DIR)\Station922Uri.o

$(OBJ_DIR)\Station922Uri.asm: $(OBJ_DIR)\Station922Uri.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Station922Uri.c -o $(OBJ_DIR)\Station922Uri.asm

$(OBJ_DIR)\Station922Uri.c: Classes\Station922Uri.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\Station922Uri.bas"
	move /y Classes\Station922Uri.c $(OBJ_DIR)\Station922Uri.c


$(OBJ_DIR)\StopWatcher.o: $(OBJ_DIR)\StopWatcher.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\StopWatcher.asm -o $(OBJ_DIR)\StopWatcher.o

$(OBJ_DIR)\StopWatcher.asm: $(OBJ_DIR)\StopWatcher.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\StopWatcher.c -o $(OBJ_DIR)\StopWatcher.asm

$(OBJ_DIR)\StopWatcher.c: Classes\StopWatcher.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\StopWatcher.bas"
	move /y Classes\StopWatcher.c $(OBJ_DIR)\StopWatcher.c


$(OBJ_DIR)\WebServer.o: $(OBJ_DIR)\WebServer.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WebServer.asm -o $(OBJ_DIR)\WebServer.o

$(OBJ_DIR)\WebServer.asm: $(OBJ_DIR)\WebServer.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WebServer.c -o $(OBJ_DIR)\WebServer.asm

$(OBJ_DIR)\WebServer.c: Classes\WebServer.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\WebServer.bas"
	move /y Classes\WebServer.c $(OBJ_DIR)\WebServer.c


$(OBJ_DIR)\WebSite.o: $(OBJ_DIR)\WebSite.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WebSite.asm -o $(OBJ_DIR)\WebSite.o

$(OBJ_DIR)\WebSite.asm: $(OBJ_DIR)\WebSite.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WebSite.c -o $(OBJ_DIR)\WebSite.asm

$(OBJ_DIR)\WebSite.c: Classes\WebSite.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\WebSite.bas"
	move /y Classes\WebSite.c $(OBJ_DIR)\WebSite.c


$(OBJ_DIR)\WebSiteContainer.o: $(OBJ_DIR)\WebSiteContainer.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WebSiteContainer.asm -o $(OBJ_DIR)\WebSiteContainer.o

$(OBJ_DIR)\WebSiteContainer.asm: $(OBJ_DIR)\WebSiteContainer.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WebSiteContainer.c -o $(OBJ_DIR)\WebSiteContainer.asm

$(OBJ_DIR)\WebSiteContainer.c: Classes\WebSiteContainer.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\WebSiteContainer.bas"
	move /y Classes\WebSiteContainer.c $(OBJ_DIR)\WebSiteContainer.c


$(OBJ_DIR)\ConsoleColors.o: $(OBJ_DIR)\ConsoleColors.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ConsoleColors.asm -o $(OBJ_DIR)\ConsoleColors.o

$(OBJ_DIR)\ConsoleColors.asm: $(OBJ_DIR)\ConsoleColors.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ConsoleColors.c -o $(OBJ_DIR)\ConsoleColors.asm

$(OBJ_DIR)\ConsoleColors.c: Modules\ConsoleColors.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\ConsoleColors.bas"
	move /y Modules\ConsoleColors.c $(OBJ_DIR)\ConsoleColors.c


$(OBJ_DIR)\ConsoleMain.o: $(OBJ_DIR)\ConsoleMain.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ConsoleMain.asm -o $(OBJ_DIR)\ConsoleMain.o

$(OBJ_DIR)\ConsoleMain.asm: $(OBJ_DIR)\ConsoleMain.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ConsoleMain.c -o $(OBJ_DIR)\ConsoleMain.asm

$(OBJ_DIR)\ConsoleMain.c: Modules\ConsoleMain.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\ConsoleMain.bas"
	move /y Modules\ConsoleMain.c $(OBJ_DIR)\ConsoleMain.c


$(OBJ_DIR)\CreateInstance.o: $(OBJ_DIR)\CreateInstance.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\CreateInstance.asm -o $(OBJ_DIR)\CreateInstance.o

$(OBJ_DIR)\CreateInstance.asm: $(OBJ_DIR)\CreateInstance.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\CreateInstance.c -o $(OBJ_DIR)\CreateInstance.asm

$(OBJ_DIR)\CreateInstance.c: Modules\CreateInstance.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\CreateInstance.bas"
	move /y Modules\CreateInstance.c $(OBJ_DIR)\CreateInstance.c


$(OBJ_DIR)\EntryPoint.o: $(OBJ_DIR)\EntryPoint.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\EntryPoint.asm -o $(OBJ_DIR)\EntryPoint.o

$(OBJ_DIR)\EntryPoint.asm: $(OBJ_DIR)\EntryPoint.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\EntryPoint.c -o $(OBJ_DIR)\EntryPoint.asm

$(OBJ_DIR)\EntryPoint.c: Modules\EntryPoint.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\EntryPoint.bas"
	move /y Modules\EntryPoint.c $(OBJ_DIR)\EntryPoint.c


$(OBJ_DIR)\FindNewLineIndex.o: $(OBJ_DIR)\FindNewLineIndex.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\FindNewLineIndex.asm -o $(OBJ_DIR)\FindNewLineIndex.o

$(OBJ_DIR)\FindNewLineIndex.asm: $(OBJ_DIR)\FindNewLineIndex.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\FindNewLineIndex.c -o $(OBJ_DIR)\FindNewLineIndex.asm

$(OBJ_DIR)\FindNewLineIndex.c: Modules\FindNewLineIndex.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\FindNewLineIndex.bas"
	move /y Modules\FindNewLineIndex.c $(OBJ_DIR)\FindNewLineIndex.c


$(OBJ_DIR)\Guids.o: $(OBJ_DIR)\Guids.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Guids.asm -o $(OBJ_DIR)\Guids.o

$(OBJ_DIR)\Guids.asm: $(OBJ_DIR)\Guids.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Guids.c -o $(OBJ_DIR)\Guids.asm

$(OBJ_DIR)\Guids.c: Modules\Guids.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\Guids.bas"
	move /y Modules\Guids.c $(OBJ_DIR)\Guids.c


$(OBJ_DIR)\Http.o: $(OBJ_DIR)\Http.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Http.asm -o $(OBJ_DIR)\Http.o

$(OBJ_DIR)\Http.asm: $(OBJ_DIR)\Http.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Http.c -o $(OBJ_DIR)\Http.asm

$(OBJ_DIR)\Http.c: Modules\Http.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\Http.bas"
	move /y Modules\Http.c $(OBJ_DIR)\Http.c


$(OBJ_DIR)\Network.o: $(OBJ_DIR)\Network.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Network.asm -o $(OBJ_DIR)\Network.o

$(OBJ_DIR)\Network.asm: $(OBJ_DIR)\Network.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Network.c -o $(OBJ_DIR)\Network.asm

$(OBJ_DIR)\Network.c: Modules\Network.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\Network.bas"
	move /y Modules\Network.c $(OBJ_DIR)\Network.c


$(OBJ_DIR)\NetworkClient.o: $(OBJ_DIR)\NetworkClient.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\NetworkClient.asm -o $(OBJ_DIR)\NetworkClient.o

$(OBJ_DIR)\NetworkClient.asm: $(OBJ_DIR)\NetworkClient.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\NetworkClient.c -o $(OBJ_DIR)\NetworkClient.asm

$(OBJ_DIR)\NetworkClient.c: Modules\NetworkClient.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\NetworkClient.bas"
	move /y Modules\NetworkClient.c $(OBJ_DIR)\NetworkClient.c


$(OBJ_DIR)\NetworkServer.o: $(OBJ_DIR)\NetworkServer.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\NetworkServer.asm -o $(OBJ_DIR)\NetworkServer.o

$(OBJ_DIR)\NetworkServer.asm: $(OBJ_DIR)\NetworkServer.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\NetworkServer.c -o $(OBJ_DIR)\NetworkServer.asm

$(OBJ_DIR)\NetworkServer.c: Modules\NetworkServer.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\NetworkServer.bas"
	move /y Modules\NetworkServer.c $(OBJ_DIR)\NetworkServer.c


$(OBJ_DIR)\PrintDebugInfo.o: $(OBJ_DIR)\PrintDebugInfo.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\PrintDebugInfo.asm -o $(OBJ_DIR)\PrintDebugInfo.o

$(OBJ_DIR)\PrintDebugInfo.asm: $(OBJ_DIR)\PrintDebugInfo.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\PrintDebugInfo.c -o $(OBJ_DIR)\PrintDebugInfo.asm

$(OBJ_DIR)\PrintDebugInfo.c: Modules\PrintDebugInfo.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\PrintDebugInfo.bas"
	move /y Modules\PrintDebugInfo.c $(OBJ_DIR)\PrintDebugInfo.c


$(OBJ_DIR)\WebUtils.o: $(OBJ_DIR)\WebUtils.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WebUtils.asm -o $(OBJ_DIR)\WebUtils.o

$(OBJ_DIR)\WebUtils.asm: $(OBJ_DIR)\WebUtils.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WebUtils.c -o $(OBJ_DIR)\WebUtils.asm

$(OBJ_DIR)\WebUtils.c: Modules\WebUtils.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\WebUtils.bas"
	move /y Modules\WebUtils.c $(OBJ_DIR)\WebUtils.c


$(OBJ_DIR)\WindowsServiceMain.o: $(OBJ_DIR)\WindowsServiceMain.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WindowsServiceMain.asm -o $(OBJ_DIR)\WindowsServiceMain.o

$(OBJ_DIR)\WindowsServiceMain.asm: $(OBJ_DIR)\WindowsServiceMain.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WindowsServiceMain.c -o $(OBJ_DIR)\WindowsServiceMain.asm

$(OBJ_DIR)\WindowsServiceMain.c: Modules\WindowsServiceMain.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\WindowsServiceMain.bas"
	move /y Modules\WindowsServiceMain.c $(OBJ_DIR)\WindowsServiceMain.c


$(OBJ_DIR)\WorkerThread.o: $(OBJ_DIR)\WorkerThread.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WorkerThread.asm -o $(OBJ_DIR)\WorkerThread.o

$(OBJ_DIR)\WorkerThread.asm: $(OBJ_DIR)\WorkerThread.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WorkerThread.c -o $(OBJ_DIR)\WorkerThread.asm

$(OBJ_DIR)\WorkerThread.c: Modules\WorkerThread.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\WorkerThread.bas"
	move /y Modules\WorkerThread.c $(OBJ_DIR)\WorkerThread.c


$(OBJ_DIR)\WriteHttpError.o: $(OBJ_DIR)\WriteHttpError.asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WriteHttpError.asm -o $(OBJ_DIR)\WriteHttpError.o

$(OBJ_DIR)\WriteHttpError.asm: $(OBJ_DIR)\WriteHttpError.c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WriteHttpError.c -o $(OBJ_DIR)\WriteHttpError.asm

$(OBJ_DIR)\WriteHttpError.c: Modules\WriteHttpError.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\WriteHttpError.bas"
	move /y Modules\WriteHttpError.c $(OBJ_DIR)\WriteHttpError.c

$(OBJ_DIR)\Resources.obj: Resources.RC
	$(RESOURCE_COMPILER) /ni $(ResourceCompilerBitFlag) /o /fo $(OBJ_DIR)\Resources.obj Resources.RC

Classes\ArrayStringWriter.bas: Classes\ArrayStringWriter.bi Headers\ContainerOf.bi Headers\IntegerToWString.bi Modules\PrintDebugInfo.bi Headers\StringConstants.bi
Classes\ArrayStringWriter.bi: Interfaces\IArrayStringWriter.bi

Classes\AsyncResult.bas: Classes\AsyncResult.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi
Classes\AsyncResult.bi: Interfaces\IMutableAsyncResult.bi

Classes\ClientContext.bas: Classes\ClientContext.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi
Classes\ClientContext.bi: Interfaces\IClientContext.bi

Classes\ClientRequest.bas: Classes\ClientRequest.bi Interfaces\IStringable.bi Headers\CharacterConstants.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi Headers\HttpConst.bi Modules\WebUtils.bi
Classes\ClientRequest.bi: Interfaces\IClientRequest.bi

Classes\Configuration.bas: Classes\Configuration.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi
Classes\Configuration.bi: Interfaces\IConfiguration.bi

Classes\HeapBSTR.bas: Classes\HeapBSTR.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi
Classes\HeapBSTR.bi: Interfaces\IHeapBSTR.bi

Classes\HttpGetProcessor.bas: Classes\HttpGetProcessor.bi Classes\ArrayStringWriter.bi Classes\AsyncResult.bi Headers\ContainerOf.bi Headers\CharacterConstants.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi Headers\HttpConst.bi Classes\Mime.bi Classes\SafeHandle.bi Headers\StringConstants.bi Modules\WebUtils.bi
Classes\HttpGetProcessor.bi: Interfaces\IRequestProcessor.bi

Classes\HttpReader.bas: Classes\HttpReader.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi Modules\FindNewLineIndex.bi Headers\StringConstants.bi
Classes\HttpReader.bi: Interfaces\IHttpReader.bi

Classes\Mime.bas: Classes\Mime.bi
Classes\Mime.bi:

Classes\Monitor.bas: Classes\Monitor.bi
Classes\Monitor.bi:

Classes\NetworkStream.bas: Classes\NetworkStream.bi Classes\AsyncResult.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi Modules\Network.bi
Classes\NetworkStream.bi: Interfaces\INetworkStream.bi

Classes\PrivateHeapMemoryAllocator.bas: Classes\PrivateHeapMemoryAllocator.bi Headers\ContainerOf.bi Modules\PrintDebugInfo.bi
Classes\PrivateHeapMemoryAllocator.bi: Interfaces\IPrivateHeapMemoryAllocator.bi

Classes\PrivateHeapMemoryAllocatorClassFactory.bas: Classes\PrivateHeapMemoryAllocatorClassFactory.bi Classes\ObjectsCounter.bi
Classes\PrivateHeapMemoryAllocatorClassFactory.bi:

Classes\RequestedFile.bas: Classes\RequestedFile.bi Headers\ContainerOf.bi Headers\HttpConst.bi Modules\PrintDebugInfo.bi
Classes\RequestedFile.bi: Interfaces\IRequestedFile.bi Interfaces\ISendable.bi

Classes\SafeHandle.bas: Classes\SafeHandle.bi
Classes\SafeHandle.bi:

Classes\ServerResponse.bas: Classes\ServerResponse.bi Classes\ArrayStringWriter.bi Headers\CharacterConstants.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Headers\HttpConst.bi Interfaces\IStringable.bi Modules\PrintDebugInfo.bi Resources.RH Headers\StringConstants.bi Modules\WebUtils.bi
Classes\ServerResponse.bi: Interfaces\IServerResponse.bi

Classes\ServerState.bas: Classes\ServerState.bi Modules\WebUtils.bi
Classes\ServerState.bi: Interfaces\IBaseStream.bi Interfaces\IClientRequest.bi Interfaces\IServerResponse.bi Interfaces\IServerState.bi Interfaces\IWebSite.bi

Classes\Station922Uri.bas: Classes\Station922Uri.bi Headers\CharacterConstants.bi
Classes\Station922Uri.bi:

Classes\StopWatcher.bas: Classes\StopWatcher.bi
Classes\StopWatcher.bi:

Classes\WebServer.bas: Classes\WebServer.bi Classes\ClientContext.bi Classes\ClientRequest.bi Classes\Configuration.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Modules\PrintDebugInfo.bi Headers\IniConst.bi Modules\Network.bi Modules\NetworkServer.bi Classes\NetworkStream.bi Classes\ServerResponse.bi Classes\WebSiteContainer.bi Modules\WorkerThread.bi Modules\WriteHttpError.bi
Classes\WebServer.bi: Interfaces\IRunnable.bi

Classes\WebSite.bas: Classes\WebSite.bi Headers\CharacterConstants.bi Headers\ContainerOf.bi Interfaces\IMutableWebSite.bi Modules\PrintDebugInfo.bi Classes\RequestedFile.bi
Classes\WebSite.bi: Interfaces\IMutableWebSite.bi

Classes\WebSiteContainer.bas: Classes\WebSiteContainer.bi Headers\ContainerOf.bi Modules\CreateInstance.bi Headers\HttpConst.bi Interfaces\IConfiguration.bi Interfaces\IMutableWebSite.bi Headers\IniConst.bi Modules\PrintDebugInfo.bi Headers\StringConstants.bi
Classes\WebSiteContainer.bi: Interfaces\IWebSiteContainer.bi

Headers\CharacterConstants.bi:
Headers\ContainerOf.bi:
Headers\HttpConst.bi:
Headers\IniConst.bi:
Headers\IntegerToWString.bi:
Headers\StringConstants.bi:

Interfaces\IArrayStringWriter.bi: Interfaces\ITextWriter.bi
Interfaces\IAsyncResult.bi:
Interfaces\IBaseStream.bi: Interfaces\IAsyncResult.bi
Interfaces\IClientContext.bi: Interfaces\IClientRequest.bi Interfaces\IHttpReader.bi Interfaces\INetworkStream.bi Interfaces\IRequestedFile.bi Interfaces\IRequestProcessor.bi Interfaces\IServerResponse.bi
Interfaces\IClientRequest.bi: Modules\Http.bi Interfaces\IHttpReader.bi Classes\Station922Uri.bi
Interfaces\IClientUri.bi:
Interfaces\IConfiguration.bi:
Interfaces\IFileStream.bi: Interfaces\IBaseStream.bi
Interfaces\IHeapBSTR.bi:
Interfaces\IHttpReader.bi: Interfaces\IBaseStream.bi Interfaces\ITextReader.bi
Interfaces\IMutableAsyncResult.bi: Interfaces\IAsyncResult.bi
Interfaces\IMutableWebSite.bi: Interfaces\IWebSite.bi
Interfaces\INetworkStream.bi: Interfaces\IBaseStream.bi
Interfaces\IPauseable.bi: Interfaces\IRunnable.bi
Interfaces\IPrivateHeapMemoryAllocator.bi:
Interfaces\IPrivateHeapMemoryAllocatorClassFactory.bi:
Interfaces\IRequestedFile.bi: Modules\Http.bi
Interfaces\IRequestProcessor.bi: Interfaces\IAsyncResult.bi Interfaces\IClientRequest.bi Interfaces\INetworkStream.bi Interfaces\IServerResponse.bi Interfaces\IWebSite.bi
Interfaces\IRunnable.bi:
Interfaces\ISendable.bi: Interfaces\INetworkStream.bi
Interfaces\IServerResponse.bi: Modules\Http.bi Classes\Mime.bi
Interfaces\IServerState.bi: Modules\Http.bi
Interfaces\IStopWatcher.bi:
Interfaces\IStreamReader.bi: Interfaces\ITextReader.bi
Interfaces\IStreamWriter.bi: Interfaces\ITextWriter.bi
Interfaces\IStringable.bi:
Interfaces\ITextReader.bi:
Interfaces\ITextWriter.bi:
Interfaces\IWebSite.bi: Interfaces\IRequestedFile.bi
Interfaces\IWebSiteContainer.bi: Interfaces\IWebSite.bi

Modules\ConsoleColors.bas: Modules\ConsoleColors.bi
Modules\ConsoleColors.bi:

Modules\ConsoleMain.bas: Modules\ConsoleMain.bi Modules\CreateInstance.bi Classes\WebServer.bi
Modules\ConsoleMain.bi:

Modules\CreateInstance.bas: Modules\CreateInstance.bi Classes\ArrayStringWriter.bi Classes\AsyncResult.bi Classes\ClientContext.bi Classes\ClientRequest.bi Classes\Configuration.bi Classes\HttpGetProcessor.bi Classes\HttpReader.bi Classes\NetworkStream.bi Classes\PrivateHeapMemoryAllocator.bi Classes\RequestedFile.bi Classes\ServerResponse.bi Classes\WebServer.bi Classes\WebSite.bi Classes\WebSiteContainer.bi
Modules\CreateInstance.bi:

Modules\EntryPoint.bas: Modules\EntryPoint.bi Modules\Http.bi Modules\WindowsServiceMain.bi Modules\ConsoleMain.bi
Modules\EntryPoint.bi:

Modules\FindNewLineIndex.bas: Modules\FindNewLineIndex.bi Headers\StringConstants.bi
Modules\FindNewLineIndex.bi:

Modules\Guids.bas: Modules\Guids.bi
Modules\Guids.bi:

Modules\Http.bas: Modules\Http.bi
Modules\Http.bi:

Modules\Network.bas: Modules\Network.bi
Modules\Network.bi:

Modules\NetworkClient.bas: Modules\NetworkClient.bi
Modules\NetworkClient.bi: Modules\Network.bi

Modules\NetworkServer.bas: Modules\NetworkServer.bi
Modules\NetworkServer.bi: Modules\Network.bi

Modules\PrintDebugInfo.bas: Modules\PrintDebugInfo.bi Modules\ConsoleColors.bi Headers\IntegerToWString.bi Headers\StringConstants.bi
Modules\PrintDebugInfo.bi: Classes\HttpReader.bi

Modules\WebUtils.bas: Modules\WebUtils.bi Headers\CharacterConstants.bi Modules\CreateInstance.bi Headers\HttpConst.bi Classes\Configuration.bi Headers\IniConst.bi Headers\IntegerToWString.bi Interfaces\IStringable.bi Modules\PrintDebugInfo.bi Headers\StringConstants.bi Classes\Station922Uri.bi Modules\WriteHttpError.bi
Modules\WebUtils.bi: Interfaces\IClientRequest.bi Interfaces\IServerResponse.bi Interfaces\ITextWriter.bi Interfaces\IWebSite.bi Classes\Mime.bi

Modules\WindowsServiceMain.bas: Modules\WindowsServiceMain.bi Modules\CreateInstance.bi Classes\WebServer.bi
Modules\WindowsServiceMain.bi: 

Modules\WorkerThread.bas: Modules\WorkerThread.bi Classes\AsyncResult.bi Modules\CreateInstance.bi Classes\HttpGetProcessor.bi Interfaces\IClientContext.bi Interfaces\IRequestProcessor.bi Modules\PrintDebugInfo.bi Classes\RequestedFile.bi Modules\WriteHttpError.bi
Modules\WorkerThread.bi: Interfaces\IWebSiteContainer.bi

Modules\WriteHttpError.bas: Modules\WriteHttpError.bi Classes\ArrayStringWriter.bi Modules\CreateInstance.bi Headers\HttpConst.bi Modules\WebUtils.bi
Modules\WriteHttpError.bi: Interfaces\IBaseStream.bi Interfaces\IClientRequest.bi Interfaces\IServerResponse.bi Interfaces\IWebSite.bi

Resources.RC: Resources.RH
Resources.RH:

clean:
	echo del %AllFileWithExtensionC% %AllFileWithExtensionAsm% %AllObjectFiles%

configure:
	mkdir "$(BIN_DEBUG_DIR_64)"
	mkdir "$(BIN_RELEASE_DIR_64)"
	mkdir "$(OBJ_DEBUG_DIR_64)"
	mkdir "$(OBJ_RELEASE_DIR_64)"
	mkdir "$(BIN_DEBUG_DIR_86)"
	mkdir "$(BIN_RELEASE_DIR_86)"
	mkdir "$(OBJ_DEBUG_DIR_86)"
	mkdir "$(OBJ_RELEASE_DIR_86)"