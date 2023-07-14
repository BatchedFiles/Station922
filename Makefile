.PHONY: all debug release clean createdirs

all: release debug

FBC ?= fbc.exe
CC ?= gcc.exe
AS ?= as.exe
AR ?= ar.exe
GORC ?= GoRC.exe
LD ?= ld.exe
DLL_TOOL ?= dlltool.exe
LIB_DIR ?=
INC_DIR ?=
FBC_VER ?= FBC1090
GCC_VER ?= GCC0930
MARCH ?= native
# for clang:
TARGET_TRIPLET ?=
FLTO ?=
# for GCC
LD_SCRIPT ?=

FILE_SUFFIX=_$(GCC_VER)_$(FBC_VER)

OUTPUT_FILE_NAME=Station922$(FILE_SUFFIX).exe

PATH_SEP ?= /
MOVE_PATH_SEP ?= \\
MOVE_COMMAND ?= cmd.exe /c move /y
DELETE_COMMAND ?= cmd.exe /c del /f /q
MKDIR_COMMAND ?= cmd.exe /c mkdir
SCRIPT_COMMAND ?= cscript.exe //nologo replace.vbs

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
FBCFLAGS+=-i src
ifneq ($(INC_DIR),)
FBCFLAGS+=-i $(INC_DIR)
endif
FBCFLAGS+=-r
FBCFLAGS+=-s console
FBCFLAGS+=-O 0
FBCFLAGS_DEBUG+=-g

CFLAGS+=-march=$(MARCH)
ifneq ($(TARGET_TRIPLET),)
CFLAGS+=--target=$(TARGET_TRIPLET)
endif
CFLAGS+=-pipe
CFLAGS+=-Wall -Werror -Wextra -pedantic
CFLAGS+=-Wno-unused-label -Wno-unused-function -Wno-unused-parameter -Wno-unused-variable
CFLAGS+=-Wno-dollar-in-identifier-extension -Wno-language-extension-token
CFLAGS_DEBUG+=-g -O0 -fno-inline

ASFLAGS+=
ASFLAGS_DEBUG+=

GORCFLAGS+=/ni /o /d FROM_MAKEFILE
GORCFLAGS_DEBUG=/d DEBUG

LDFLAGS+=-subsystem console
LDFLAGS+=--no-seh --nxcompat
LDFLAGS+=-e $(ENTRY_POINT)
LDFLAGS+=-L $(LIB_DIR)
ifneq ($(LD_SCRIPT),)
LDFLAGS+=-T $(LD_SCRIPT)
endif
LDLIBS+=-ladvapi32 -lkernel32 -lmsvcrt -lmswsock -lcrypt32 -loleaut32
LDLIBS+=-lole32 -lshell32 -lshlwapi -lws2_32 -luser32
LDLIBS_DEBUG+=-lgcc -lmingw32 -lmingwex -lmoldname -lgcc_eh -lucrt -lucrtbase

# Object files are loaded from a file "dependencies.mk"
include dependencies.mk

release: CFLAGS+=$(CFLAGS_RELEASE)
release: CFLAGS+=-fno-math-errno -fno-exceptions
release: CFLAGS+=-fno-unwind-tables -fno-asynchronous-unwind-tables
release: CFLAGS+=-O3 -fno-ident -fdata-sections -ffunction-sections
ifneq ($(FLTO),)
release: CFLAGS+=$(FLTO)
endif
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

createdirs:
	$(MKDIR_COMMAND) $(BIN_DEBUG_DIR_MOVE)
	$(MKDIR_COMMAND) $(BIN_RELEASE_DIR_MOVE)
	$(MKDIR_COMMAND) $(OBJ_DEBUG_DIR_MOVE)
	$(MKDIR_COMMAND) $(OBJ_RELEASE_DIR_MOVE)
