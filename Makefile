COMPILERDIRECTORY=$(ProgramFiles)\FreeBASIC
FREEBASIC_COMPILER="$(ProgramFiles)\FreeBASIC\fbc.exe"
INCLUDEFILESPATH=-i Classes -i Interfaces -i Modules -i Headers
EXETYPEKIND=console
MAXERRORSCOUNT=-maxerr 1
MINWARNINGLEVEL=-w all

# Все флаги:
# DEBUG 0 | 1
# WINDOWS_SERVICE_FLAG=-d WINDOWS_SERVICE
# GUIDS_WITHOUT_MINGW_FLAG=-d GUIDS_WITHOUT_MINGW
# WITHOUT_RUNTIME_FLAG=-d WITHOUT_RUNTIME
# UNICODE_FLAG=-d UNICODE
# WITHOUT_CRITICAL_SECTIONS_FLAG=-d WITHOUT_CRITICAL_SECTIONS
# PERFORMANCE_TESTING

ifeq ($@,WindowsService)
WINDOWS_SERVICE_FLAG=-d WINDOWS_SERVICE
WINDOWS_SERVICE_SUFFIX=Service
else
WINDOWS_SERVICE_FLAG=
WINDOWS_SERVICE_SUFFIX=Console
endif

PERFORMANCE_TESTING_FLAG=
PERFORMANCE_TESTING_SUFFIX=WoPT

GUIDS_WITHOUT_MINGW_FLAG=-d GUIDS_WITHOUT_MINGW
GUIDS_WITHOUT_MINGW_SUFFIX=WoMingw

WITHOUT_RUNTIME_FLAG=-d WITHOUT_RUNTIME
WITHOUT_RUNTIME_SUFFIX=WoRt

WITHOUT_CRITICAL_SECTIONS_FLAG=-d WITHOUT_CRITICAL_SECTIONS
WITHOUT_CRITICAL_SECTIONS_SUFFIX=WoCr

UNICODE_FLAG=-d UNICODE
UNICODE_SUFFIX=W

FILE_SUFFIX=$(WINDOWS_SERVICE_SUFFIX)$(PERFORMANCE_TESTING_SUFFIX)$(GUIDS_WITHOUT_MINGW_SUFFIX)$(WITHOUT_RUNTIME_SUFFIX)$(WITHOUT_CRITICAL_SECTIONS_SUFFIX)$(UNICODE_SUFFIX)

ALL_OBJECT_FILES=$(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).o $(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).o $(OBJ_DIR)\ClientContext$(FILE_SUFFIX).o $(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).o $(OBJ_DIR)\Configuration$(FILE_SUFFIX).o $(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).o $(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).o $(OBJ_DIR)\HttpReader$(FILE_SUFFIX).o $(OBJ_DIR)\Mime$(FILE_SUFFIX).o $(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).o $(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).o $(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).o $(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).o $(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).o $(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).o $(OBJ_DIR)\WebServer$(FILE_SUFFIX).o $(OBJ_DIR)\WebSite$(FILE_SUFFIX).o $(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).o $(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).o $(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).o $(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).o $(OBJ_DIR)\Guids$(FILE_SUFFIX).o $(OBJ_DIR)\Http$(FILE_SUFFIX).o $(OBJ_DIR)\Network$(FILE_SUFFIX).o $(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).o $(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).o $(OBJ_DIR)\WebUtils$(FILE_SUFFIX).o $(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).o $(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).o $(OBJ_DIR)\Resources$(FILE_SUFFIX).obj

ALL_OBJECT_FILES_CONSOLE=$(ALL_OBJECT_FILES) $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).o $(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).o $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).o

ALL_OBJECT_FILES_SERVICE=$(ALL_OBJECT_FILES) $(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).o

ALL_OBJECT_FILES_TEST=$(ALL_OBJECT_FILES) $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).o $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).o $(OBJ_DIR)\test$(FILE_SUFFIX).o

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
GccObjectLibraries=-lmoldname -lgcc -lmingw32 -lmingwex -lgcc_eh
WinApiObjectLibraries=-ladvapi32 -lcomctl32 -lcomdlg32 -lcrypt32 -lgdi32 -lgdiplus -limm32 -lkernel32 -lmsimg32 -lmsvcrt -lmswsock -lole32 -loleaut32 -lshell32 -lshlwapi -luser32 -lversion -lwinmm -lwinspool -lws2_32
ALL_OBJECT_LIBRARIES=$(WinApiObjectLibraries) $(GMonitorObjectLibraries) $(GccObjectLibraries)

MajorImageVersion=--major-image-version 1
MinorImageVersion=--minor-image-version 0

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)

# GCC_COMPILER="$(ProgramFiles)\FreeBASIC\bin\win64\gcc.exe"
# GCC_ASSEMBLER="$(ProgramFiles)\FreeBASIC\bin\win64\as.exe"
# GCC_LINKER="$(ProgramFiles)\FreeBASIC\bin\win64\ld.exe"
# ARCHIVE_COMPILER="$(ProgramFiles)\FreeBASIC\bin\win64\ar.exe"
# DLL_TOOL="$(ProgramFiles)\FreeBASIC\bin\win64\dlltool.exe"
GCC_COMPILER="$(ProgramFiles)\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\gcc.exe"
GCC_ASSEMBLER="$(ProgramFiles)\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\as.exe"
GCC_LINKER="$(ProgramFiles)\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\ld.exe"
ARCHIVE_COMPILER="$(ProgramFiles)\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\ar.exe"
DLL_TOOL="$(ProgramFiles)\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin\dlltool.exe"
RESOURCE_COMPILER="$(ProgramFiles)\FreeBASIC\bin\win64\GoRC.exe"
COMPILER_LIB_PATH="$(ProgramFiles)\FreeBASIC\lib\win64"

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

GCC_COMPILER="$(ProgramFiles)\FreeBASIC\bin\win32\gcc.exe"
GCC_ASSEMBLER="$(ProgramFiles)\FreeBASIC\bin\win32\as.exe"
RESOURCE_COMPILER="$(ProgramFiles)\FreeBASIC\bin\win32\GoRC.exe"
GCC_LINKER="$(ProgramFiles)\FreeBASIC\bin\win32\ld.exe"
ARCHIVE_COMPILER="$(ProgramFiles)\FreeBASIC\bin\win32\ar.exe"
DLL_TOOL="$(ProgramFiles)\FreeBASIC\bin\win32\dlltool.exe"
COMPILER_LIB_PATH="$(ProgramFiles)\FreeBASIC\lib\win32"

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

ifeq ($(RUNTIME_DEFINED),runtime)

WITHOUT_RUNTIME_FLAG=
GUIDS_WITHOUT_MINGW_FLAG=
GUIDS_WITHOUT_MINGW_SUFFIX=Mingw
WITHOUT_RUNTIME_SUFFIX=Rt

else

WITHOUT_RUNTIME_FLAG=-d WITHOUT_RUNTIME
GUIDS_WITHOUT_MINGW_FLAG=-d GUIDS_WITHOUT_MINGW
GUIDS_WITHOUT_MINGW_SUFFIX=WoMingw
WITHOUT_RUNTIME_SUFFIX=WoRt

endif

FREEBASIC_PARAMETERS_BASE=-g -r -lib -gen $(CODEGENERATIONBACKEND) $(MAXERRORSCOUNT) $(MINWARNINGLEVEL) $(INCLUDEFILESPATH) $(UNICODE_FLAG) $(WITHOUT_CRITICAL_SECTIONS_FLAG) $(WINDOWS_SERVICE_FLAG) $(WITHOUT_RUNTIME_FLAG) $(GUIDS_WITHOUT_MINGW_FLAG) $(PERFORMANCE_TESTING_FLAG)

# -Werror-implicit-function-declaration
GCC_WARNING=-Werror -Wall -Wno-unused-label -Wno-unused-function -Wno-main
GCC_NOINCLUDE=-nostdlib -nostdinc -mno-stack-arg-probe -fno-stack-check -fno-stack-protector -fno-strict-aliasing -frounding-math -fno-math-errno -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-ident

DEFAULT_STACK_SIZE=--stack 1048576,1048576

ifeq ($(DEBUG),1)

ASSEMBLER_STRIP_FLAG=
LINKER_STRIP_FLAG=
BIN_DIR=$(BIN_DEBUG_DIR)
OBJ_DIR=$(OBJ_DEBUG_DIR)
GCC_COMPILER_PARAMETERS=$(GCC_WARNING) $(GCC_ARCHITECTURE) -masm=intel -S -Og -g
FREEBASIC_PARAMETERS=$(FREEBASIC_PARAMETERS_BASE)

else

ASSEMBLER_STRIP_FLAG=--strip-local-absolute
LINKER_STRIP_FLAG=-s --gc-sections
BIN_DIR=$(BIN_RELEASE_DIR)
OBJ_DIR=$(OBJ_RELEASE_DIR)
GCC_COMPILER_PARAMETERS=$(GCC_WARNING) $(GCC_NOINCLUDE) $(GCC_ARCHITECTURE) -masm=intel -S -Ofast
FREEBASIC_PARAMETERS=$(FREEBASIC_PARAMETERS_BASE)

endif

.PHONY: all clean install uninstall configure WebServer WindowsService test

WebServer: $(BIN_DIR)\WebServer.exe

WindowsService: $(BIN_DIR)\Station922.exe

test: $(BIN_DIR)\test.exe

$(BIN_DIR)\WebServer.exe: $(ALL_OBJECT_FILES_CONSOLE)
	$(GCC_LINKER) -m $(PE_FILE_FORMAT) -subsystem console -e $(ENTRY_POINT) $(DEFAULT_STACK_SIZE) $(LINKER_STRIP_FLAG) -L $(COMPILER_LIB_PATH) -L "." $(ALL_OBJECT_FILES_CONSOLE) -( $(ALL_OBJECT_LIBRARIES) -) -o "$(BIN_DIR)\WebServer.exe"

$(BIN_DIR)\Station922.exe: $(ALL_OBJECT_FILES_SERVICE)
	echo $@
	$(GCC_LINKER) -m $(PE_FILE_FORMAT) -subsystem console -e $(ENTRY_POINT) $(DEFAULT_STACK_SIZE) $(LINKER_STRIP_FLAG) -L $(COMPILER_LIB_PATH) -L "." $(ALL_OBJECT_FILES_SERVICE) -( $(ALL_OBJECT_LIBRARIES) -) -o "$(BIN_DIR)\Station922.exe"

$(BIN_DIR)\test.exe: $(ALL_OBJECT_FILES_TEST)
	$(GCC_LINKER) -m $(PE_FILE_FORMAT) -subsystem console -e $(ENTRY_POINT) $(DEFAULT_STACK_SIZE) $(LINKER_STRIP_FLAG) -L $(COMPILER_LIB_PATH) -L "." $(ALL_OBJECT_FILES_TEST) -( $(ALL_OBJECT_LIBRARIES) -) -o "$(BIN_DIR)\test.exe"


$(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).o: $(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).asm -o $(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).o

$(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).asm: $(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).c -o $(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).asm

$(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).c: Classes\ArrayStringWriter.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ArrayStringWriter.bas"
	move /y Classes\ArrayStringWriter.c $(OBJ_DIR)\ArrayStringWriter$(FILE_SUFFIX).c


$(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).o: $(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).asm -o $(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).o

$(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).asm: $(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).c -o $(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).asm

$(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).c: Classes\AsyncResult.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\AsyncResult.bas"
	move /y Classes\AsyncResult.c $(OBJ_DIR)\AsyncResult$(FILE_SUFFIX).c


$(OBJ_DIR)\ClientContext$(FILE_SUFFIX).o: $(OBJ_DIR)\ClientContext$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ClientContext$(FILE_SUFFIX).asm -o $(OBJ_DIR)\ClientContext$(FILE_SUFFIX).o

$(OBJ_DIR)\ClientContext$(FILE_SUFFIX).asm: $(OBJ_DIR)\ClientContext$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ClientContext$(FILE_SUFFIX).c -o $(OBJ_DIR)\ClientContext$(FILE_SUFFIX).asm

$(OBJ_DIR)\ClientContext$(FILE_SUFFIX).c: Classes\ClientContext.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ClientContext.bas"
	move /y Classes\ClientContext.c $(OBJ_DIR)\ClientContext$(FILE_SUFFIX).c


$(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).o: $(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).asm -o $(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).o

$(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).asm: $(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).c -o $(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).asm

$(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).c: Classes\ClientRequest.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ClientRequest.bas"
	move /y Classes\ClientRequest.c $(OBJ_DIR)\ClientRequest$(FILE_SUFFIX).c


$(OBJ_DIR)\Configuration$(FILE_SUFFIX).o: $(OBJ_DIR)\Configuration$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Configuration$(FILE_SUFFIX).asm -o $(OBJ_DIR)\Configuration$(FILE_SUFFIX).o

$(OBJ_DIR)\Configuration$(FILE_SUFFIX).asm: $(OBJ_DIR)\Configuration$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Configuration$(FILE_SUFFIX).c -o $(OBJ_DIR)\Configuration$(FILE_SUFFIX).asm

$(OBJ_DIR)\Configuration$(FILE_SUFFIX).c: Classes\Configuration.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\Configuration.bas"
	move /y Classes\Configuration.c $(OBJ_DIR)\Configuration$(FILE_SUFFIX).c


$(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).o: $(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).asm -o $(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).o

$(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).asm: $(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).c -o $(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).asm

$(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).c: Classes\HeapBSTR.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\HeapBSTR.bas"
	move /y Classes\HeapBSTR.c $(OBJ_DIR)\HeapBSTR$(FILE_SUFFIX).c


$(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).o: $(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).asm -o $(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).o

$(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).asm: $(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).c -o $(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).asm

$(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).c: Classes\HttpGetProcessor.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\HttpGetProcessor.bas"
	move /y Classes\HttpGetProcessor.c $(OBJ_DIR)\HttpGetProcessor$(FILE_SUFFIX).c


$(OBJ_DIR)\HttpReader$(FILE_SUFFIX).o: $(OBJ_DIR)\HttpReader$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\HttpReader$(FILE_SUFFIX).asm -o $(OBJ_DIR)\HttpReader$(FILE_SUFFIX).o

$(OBJ_DIR)\HttpReader$(FILE_SUFFIX).asm: $(OBJ_DIR)\HttpReader$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\HttpReader$(FILE_SUFFIX).c -o $(OBJ_DIR)\HttpReader$(FILE_SUFFIX).asm

$(OBJ_DIR)\HttpReader$(FILE_SUFFIX).c: Classes\HttpReader.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\HttpReader.bas"
	move /y Classes\HttpReader.c $(OBJ_DIR)\HttpReader$(FILE_SUFFIX).c


$(OBJ_DIR)\Mime$(FILE_SUFFIX).o: $(OBJ_DIR)\Mime$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Mime$(FILE_SUFFIX).asm -o $(OBJ_DIR)\Mime$(FILE_SUFFIX).o

$(OBJ_DIR)\Mime$(FILE_SUFFIX).asm: $(OBJ_DIR)\Mime$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Mime$(FILE_SUFFIX).c -o $(OBJ_DIR)\Mime$(FILE_SUFFIX).asm

$(OBJ_DIR)\Mime$(FILE_SUFFIX).c: Classes\Mime.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\Mime.bas"
	move /y Classes\Mime.c $(OBJ_DIR)\Mime$(FILE_SUFFIX).c


$(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).o: $(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).asm -o $(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).o

$(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).asm: $(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).c -o $(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).asm

$(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).c: Classes\NetworkStream.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\NetworkStream.bas"
	move /y Classes\NetworkStream.c $(OBJ_DIR)\NetworkStream$(FILE_SUFFIX).c


$(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).o: $(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).asm -o $(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).o

$(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).asm: $(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).c -o $(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).asm

$(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).c: Classes\PrivateHeapMemoryAllocator.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\PrivateHeapMemoryAllocator.bas"
	move /y Classes\PrivateHeapMemoryAllocator.c $(OBJ_DIR)\PrivateHeapMemoryAllocator$(FILE_SUFFIX).c


$(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).o: $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).asm -o $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).o

$(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).asm: $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).c -o $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).asm

$(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).c: Classes\PrivateHeapMemoryAllocatorClassFactory.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\PrivateHeapMemoryAllocatorClassFactory.bas"
	move /y Classes\PrivateHeapMemoryAllocatorClassFactory.c $(OBJ_DIR)\PrivateHeapMemoryAllocatorClassFactory$(FILE_SUFFIX).c


$(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).o: $(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).asm -o $(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).o

$(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).asm: $(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).c -o $(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).asm

$(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).c: Classes\RequestedFile.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\RequestedFile.bas"
	move /y Classes\RequestedFile.c $(OBJ_DIR)\RequestedFile$(FILE_SUFFIX).c


$(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).o: $(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).asm -o $(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).o

$(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).asm: $(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).c -o $(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).asm

$(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).c: Classes\SafeHandle.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\SafeHandle.bas"
	move /y Classes\SafeHandle.c $(OBJ_DIR)\SafeHandle$(FILE_SUFFIX).c


$(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).o: $(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).asm -o $(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).o

$(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).asm: $(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).c -o $(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).asm

$(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).c: Classes\ServerResponse.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ServerResponse.bas"
	move /y Classes\ServerResponse.c $(OBJ_DIR)\ServerResponse$(FILE_SUFFIX).c


$(OBJ_DIR)\ServerState$(FILE_SUFFIX).o: $(OBJ_DIR)\ServerState$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ServerState$(FILE_SUFFIX).asm -o $(OBJ_DIR)\ServerState$(FILE_SUFFIX).o

$(OBJ_DIR)\ServerState$(FILE_SUFFIX).asm: $(OBJ_DIR)\ServerState$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ServerState$(FILE_SUFFIX).c -o $(OBJ_DIR)\ServerState$(FILE_SUFFIX).asm

$(OBJ_DIR)\ServerState$(FILE_SUFFIX).c: Classes\ServerState.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\ServerState.bas"
	move /y Classes\ServerState.c $(OBJ_DIR)\ServerState$(FILE_SUFFIX).c


$(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).o: $(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).asm -o $(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).o

$(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).asm: $(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).c -o $(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).asm

$(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).c: Classes\Station922Uri.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\Station922Uri.bas"
	move /y Classes\Station922Uri.c $(OBJ_DIR)\Station922Uri$(FILE_SUFFIX).c


$(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).o: $(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).asm -o $(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).o

$(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).asm: $(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).c -o $(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).asm

$(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).c: Classes\StopWatcher.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\StopWatcher.bas"
	move /y Classes\StopWatcher.c $(OBJ_DIR)\StopWatcher$(FILE_SUFFIX).c


$(OBJ_DIR)\WebServer$(FILE_SUFFIX).o: $(OBJ_DIR)\WebServer$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WebServer$(FILE_SUFFIX).asm -o $(OBJ_DIR)\WebServer$(FILE_SUFFIX).o

$(OBJ_DIR)\WebServer$(FILE_SUFFIX).asm: $(OBJ_DIR)\WebServer$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WebServer$(FILE_SUFFIX).c -o $(OBJ_DIR)\WebServer$(FILE_SUFFIX).asm

$(OBJ_DIR)\WebServer$(FILE_SUFFIX).c: Classes\WebServer.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\WebServer.bas"
	move /y Classes\WebServer.c $(OBJ_DIR)\WebServer$(FILE_SUFFIX).c


$(OBJ_DIR)\WebSite$(FILE_SUFFIX).o: $(OBJ_DIR)\WebSite$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WebSite$(FILE_SUFFIX).asm -o $(OBJ_DIR)\WebSite$(FILE_SUFFIX).o

$(OBJ_DIR)\WebSite$(FILE_SUFFIX).asm: $(OBJ_DIR)\WebSite$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WebSite$(FILE_SUFFIX).c -o $(OBJ_DIR)\WebSite$(FILE_SUFFIX).asm

$(OBJ_DIR)\WebSite$(FILE_SUFFIX).c: Classes\WebSite.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\WebSite.bas"
	move /y Classes\WebSite.c $(OBJ_DIR)\WebSite$(FILE_SUFFIX).c


$(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).o: $(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).asm -o $(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).o

$(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).asm: $(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).c -o $(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).asm

$(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).c: Classes\WebSiteContainer.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Classes\WebSiteContainer.bas"
	move /y Classes\WebSiteContainer.c $(OBJ_DIR)\WebSiteContainer$(FILE_SUFFIX).c


$(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).o: $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).asm -o $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).o

$(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).asm: $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).c -o $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).asm

$(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).c: Modules\ConsoleColors.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\ConsoleColors.bas"
	move /y Modules\ConsoleColors.c $(OBJ_DIR)\ConsoleColors$(FILE_SUFFIX).c


$(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).o: $(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).asm -o $(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).o

$(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).asm: $(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).c -o $(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).asm

$(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).c: Modules\ConsoleMain.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\ConsoleMain.bas"
	move /y Modules\ConsoleMain.c $(OBJ_DIR)\ConsoleMain$(FILE_SUFFIX).c


$(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).o: $(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).asm -o $(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).o

$(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).asm: $(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).c -o $(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).asm

$(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).c: Modules\CreateInstance.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\CreateInstance.bas"
	move /y Modules\CreateInstance.c $(OBJ_DIR)\CreateInstance$(FILE_SUFFIX).c


$(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).o: $(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).asm -o $(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).o

$(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).asm: $(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).c -o $(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).asm

$(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).c: Modules\EntryPoint.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\EntryPoint.bas"
	move /y Modules\EntryPoint.c $(OBJ_DIR)\EntryPoint$(FILE_SUFFIX).c


$(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).o: $(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).asm -o $(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).o

$(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).asm: $(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).c -o $(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).asm

$(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).c: Modules\FindNewLineIndex.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\FindNewLineIndex.bas"
	move /y Modules\FindNewLineIndex.c $(OBJ_DIR)\FindNewLineIndex$(FILE_SUFFIX).c


$(OBJ_DIR)\Guids$(FILE_SUFFIX).o: $(OBJ_DIR)\Guids$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Guids$(FILE_SUFFIX).asm -o $(OBJ_DIR)\Guids$(FILE_SUFFIX).o

$(OBJ_DIR)\Guids$(FILE_SUFFIX).asm: $(OBJ_DIR)\Guids$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Guids$(FILE_SUFFIX).c -o $(OBJ_DIR)\Guids$(FILE_SUFFIX).asm

$(OBJ_DIR)\Guids$(FILE_SUFFIX).c: Modules\Guids.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\Guids.bas"
	move /y Modules\Guids.c $(OBJ_DIR)\Guids$(FILE_SUFFIX).c


$(OBJ_DIR)\Http$(FILE_SUFFIX).o: $(OBJ_DIR)\Http$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Http$(FILE_SUFFIX).asm -o $(OBJ_DIR)\Http$(FILE_SUFFIX).o

$(OBJ_DIR)\Http$(FILE_SUFFIX).asm: $(OBJ_DIR)\Http$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Http$(FILE_SUFFIX).c -o $(OBJ_DIR)\Http$(FILE_SUFFIX).asm

$(OBJ_DIR)\Http$(FILE_SUFFIX).c: Modules\Http.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\Http.bas"
	move /y Modules\Http.c $(OBJ_DIR)\Http$(FILE_SUFFIX).c


$(OBJ_DIR)\Network$(FILE_SUFFIX).o: $(OBJ_DIR)\Network$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\Network$(FILE_SUFFIX).asm -o $(OBJ_DIR)\Network$(FILE_SUFFIX).o

$(OBJ_DIR)\Network$(FILE_SUFFIX).asm: $(OBJ_DIR)\Network$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\Network$(FILE_SUFFIX).c -o $(OBJ_DIR)\Network$(FILE_SUFFIX).asm

$(OBJ_DIR)\Network$(FILE_SUFFIX).c: Modules\Network.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\Network.bas"
	move /y Modules\Network.c $(OBJ_DIR)\Network$(FILE_SUFFIX).c


$(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).o: $(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).asm -o $(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).o

$(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).asm: $(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).c -o $(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).asm

$(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).c: Modules\NetworkClient.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\NetworkClient.bas"
	move /y Modules\NetworkClient.c $(OBJ_DIR)\NetworkClient$(FILE_SUFFIX).c


$(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).o: $(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).asm -o $(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).o

$(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).asm: $(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).c -o $(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).asm

$(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).c: Modules\NetworkServer.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\NetworkServer.bas"
	move /y Modules\NetworkServer.c $(OBJ_DIR)\NetworkServer$(FILE_SUFFIX).c


$(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).o: $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).asm -o $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).o

$(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).asm: $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).c -o $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).asm

$(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).c: Modules\PrintDebugInfo.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\PrintDebugInfo.bas"
	move /y Modules\PrintDebugInfo.c $(OBJ_DIR)\PrintDebugInfo$(FILE_SUFFIX).c


$(OBJ_DIR)\WebUtils$(FILE_SUFFIX).o: $(OBJ_DIR)\WebUtils$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WebUtils$(FILE_SUFFIX).asm -o $(OBJ_DIR)\WebUtils$(FILE_SUFFIX).o

$(OBJ_DIR)\WebUtils$(FILE_SUFFIX).asm: $(OBJ_DIR)\WebUtils$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WebUtils$(FILE_SUFFIX).c -o $(OBJ_DIR)\WebUtils$(FILE_SUFFIX).asm

$(OBJ_DIR)\WebUtils$(FILE_SUFFIX).c: Modules\WebUtils.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\WebUtils.bas"
	move /y Modules\WebUtils.c $(OBJ_DIR)\WebUtils$(FILE_SUFFIX).c


$(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).o: $(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).asm -o $(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).o

$(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).asm: $(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).c -o $(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).asm

$(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).c: Modules\WindowsServiceMain.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\WindowsServiceMain.bas"
	move /y Modules\WindowsServiceMain.c $(OBJ_DIR)\WindowsServiceMain$(FILE_SUFFIX).c


$(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).o: $(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).asm -o $(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).o

$(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).asm: $(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).c -o $(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).asm

$(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).c: Modules\WorkerThread.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\WorkerThread.bas"
	move /y Modules\WorkerThread.c $(OBJ_DIR)\WorkerThread$(FILE_SUFFIX).c


$(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).o: $(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).asm -o $(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).o

$(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).asm: $(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).c -o $(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).asm

$(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).c: Modules\WriteHttpError.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "Modules\WriteHttpError.bas"
	move /y Modules\WriteHttpError.c $(OBJ_DIR)\WriteHttpError$(FILE_SUFFIX).c


$(OBJ_DIR)\Resources$(FILE_SUFFIX).obj: Resources.RC
	$(RESOURCE_COMPILER) /ni $(ResourceCompilerBitFlag) /o /fo $(OBJ_DIR)\Resources$(FILE_SUFFIX).obj Resources.RC


$(OBJ_DIR)\test$(FILE_SUFFIX).o: $(OBJ_DIR)\test$(FILE_SUFFIX).asm
	$(GCC_ASSEMBLER) $(TARGET_ASSEMBLER_ARCH) $(ASSEMBLER_STRIP_FLAG) $(OBJ_DIR)\test$(FILE_SUFFIX).asm -o $(OBJ_DIR)\test$(FILE_SUFFIX).o

$(OBJ_DIR)\test$(FILE_SUFFIX).asm: $(OBJ_DIR)\test$(FILE_SUFFIX).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS) $(OBJ_DIR)\test$(FILE_SUFFIX).c -o $(OBJ_DIR)\test$(FILE_SUFFIX).asm

$(OBJ_DIR)\test$(FILE_SUFFIX).c: test\test.bas
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS) "test\test.bas"
	move /y test\test.c $(OBJ_DIR)\test$(FILE_SUFFIX).c

include dependencies.make

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