.PHONY: all debug release clean

all: release debug

FBC ?= fbc.exe
CC ?= gcc.exe
AS ?= as.exe
AR ?= ar.exe
GORC ?= GoRC.exe
LD ?= ld.exe
FBC_VER ?= FBC-1.09.0
GCC_VER ?= GCC-09.3.0
MARCH ?= native

FILE_SUFFIX=_$(GCC_VER)_$(FBC_VER)

OUTPUT_FILE_NAME=Station922$(FILE_SUFFIX).exe

PATH_SEP ?= /
MOVE_PATH_SEP ?= \\
MOVE_COMMAND ?= cmd.exe /c move /y
DELETE_COMMAND ?= cmd.exe /c del /f /q
SCRIPT_COMMAND ?= cscript.exe //nologo replace.vbs

# Object files

OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientBuffer$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)FileStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpReader$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpWriter$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)MemoryStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)NetworkStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)TcpListener$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientBuffer$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)FileStream$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpReader$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpWriter$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)MemoryStream$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)NetworkStream$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)TcpListener$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj

ifeq ($(CODE_EMITTER),gcc)
FBCFLAGS+=-gen gcc
else
FBCFLAGS+=-gen gcc
endif

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
CFLAGS+=-m64
ASFLAGS+=--64
ENTRY_POINT=EntryPoint
LDFLAGS+=-m i386pep
GORCFLAGS+=/machine X64
BIN_DEBUG_DIR ?= bin$(PATH_SEP)Debug$(PATH_SEP)x64
BIN_RELEASE_DIR ?= bin$(PATH_SEP)Release$(PATH_SEP)x64
OBJ_DEBUG_DIR ?= obj$(PATH_SEP)Debug$(PATH_SEP)x64
OBJ_RELEASE_DIR ?= obj$(PATH_SEP)Release$(PATH_SEP)x64
BIN_DEBUG_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x64
BIN_RELEASE_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x64
OBJ_DEBUG_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x64
OBJ_RELEASE_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x64
else
CFLAGS+=-m32
ASFLAGS+=--32
ENTRY_POINT=_EntryPoint@0
LDFLAGS+=-m i386pe --large-address-aware
GORCFLAGS+=
BIN_DEBUG_DIR ?= bin$(PATH_SEP)Debug$(PATH_SEP)x86
BIN_RELEASE_DIR ?= bin$(PATH_SEP)Release$(PATH_SEP)x86
OBJ_DEBUG_DIR ?= obj$(PATH_SEP)Debug$(PATH_SEP)x86
OBJ_RELEASE_DIR ?= obj$(PATH_SEP)Release$(PATH_SEP)x86
BIN_DEBUG_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x86
BIN_RELEASE_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x86
OBJ_DEBUG_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x86
OBJ_RELEASE_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x86
endif

FBCFLAGS+=-d UNICODE -d WITHOUT_RUNTIME
FBCFLAGS+=-w error -maxerr 1
# FBCFLAGS+=-i src
FBCFLAGS+=-i src -i C:\Programming\FreeBASIC-1.09.0-win64-gcc-9.3.0\inc
FBCFLAGS+=-r
FBCFLAGS+=-s console
FBCFLAGS+=-O 0
FBCFLAGS_DEBUG+=-g

CFLAGS+=-march=$(MARCH)
CFLAGS+=-pipe
CFLAGS+=-Wall -Werror -Wextra -pedantic
CFLAGS+=-Wno-unused-label -Wno-unused-function -Wno-unused-parameter -Wno-unused-variable
CFLAGS+=-Wno-dollar-in-identifier-extension
CFLAGS_DEBUG+=-g -O0

ASFLAGS+=
ASFLAGS_DEBUG+=

GORCFLAGS+=/ni /o /d FROM_MAKEFILE
GORCFLAGS_DEBUG=/d DEBUG

LDFLAGS+=--major-image-version 1 --minor-image-version 0
LDFLAGS+=-subsystem console
LDFLAGS+=--no-seh --nxcompat
LDFLAGS+=-e $(ENTRY_POINT)
LDFLAGS+=-L $(LIB_DIR)
LDLIBS+=-ladvapi32 -lkernel32 -lmsvcrt -lmswsock -lcrypt32 -loleaut32
LDLIBS+=-lole32 -lshell32 -lshlwapi -lws2_32
LDLIBS_DEBUG+=-lgcc -lmingw32 -lmingwex -lmoldname -lgcc_eh -lucrt -lucrtbase

include dependencies.mk

release: CFLAGS+=$(CFLAGS_RELEASE)
release: CFLAGS+=-fno-math-errno -fno-exceptions
release: CFLAGS+=-fno-unwind-tables -fno-asynchronous-unwind-tables
release: CFLAGS+=-O3 -fno-ident -fdata-sections -ffunction-sections
release: ASFLAGS+=--strip-local-absolute
release: LDFLAGS+=-s --gc-sections
release: $(BIN_RELEASE_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME)

debug: FBCFLAGS+=$(FBCFLAGS_DEBUG)
debug: CFLAGS+=$(CFLAGS_DEBUG)
debug: ASFLAGS+=$(ASFLAGS_DEBUG)
debug: GORCFLAGS+=$(GORCFLAGS_DEBUG)
debug: LDFLAGS+=$(LDFLAGS_DEBUG)
debug: LDLIBS+=$(LDLIBS_DEBUG)
debug: $(BIN_DEBUG_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME)

.PRECIOUS: $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm
.PRECIOUS: $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm
.PRECIOUS: $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c
.PRECIOUS: $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c

clean:
	$(DELETE_COMMAND) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)*$(FILE_SUFFIX).c
	$(DELETE_COMMAND) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)*$(FILE_SUFFIX).c
	$(DELETE_COMMAND) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)*$(FILE_SUFFIX).asm
	$(DELETE_COMMAND) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)*$(FILE_SUFFIX).asm
	$(DELETE_COMMAND) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)*$(FILE_SUFFIX).o
	$(DELETE_COMMAND) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)*$(FILE_SUFFIX).o
	$(DELETE_COMMAND) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)*$(FILE_SUFFIX).obj
	$(DELETE_COMMAND) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)*$(FILE_SUFFIX).obj
	$(DELETE_COMMAND) $(BIN_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)$(OUTPUT_FILE_NAME)
	$(DELETE_COMMAND) $(BIN_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)$(OUTPUT_FILE_NAME)

$(BIN_RELEASE_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME): $(OBJECTFILES_RELEASE)
	$(LD) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_DEBUG_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME):   $(OBJECTFILES_DEBUG)
	$(LD) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).o: $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).o: $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm: $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) -o $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm: $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) -o $@ $<

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c: src$(PATH_SEP)%.bas
	$(FBC) $(FBCFLAGS) $<
	$(SCRIPT_COMMAND) /release src$(MOVE_PATH_SEP)$*.c
	$(MOVE_COMMAND) src$(MOVE_PATH_SEP)$*.c $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)$*$(FILE_SUFFIX).c

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c: src$(PATH_SEP)%.bas
	$(FBC) $(FBCFLAGS) $<
	$(SCRIPT_COMMAND) /debug src$(MOVE_PATH_SEP)$*.c
	$(MOVE_COMMAND) src$(MOVE_PATH_SEP)$*.c $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)$*$(FILE_SUFFIX).c

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).obj: src$(PATH_SEP)%.RC
	$(GORC) $(GORCFLAGS) /fo $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).obj: src$(PATH_SEP)%.RC
	$(GORC) $(GORCFLAGS) /fo $@ $<
