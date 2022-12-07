.PHONY: all debug release clean

FILE_SUFFIX=_$(GCC_VER)_$(FBC_VER)_-Rt

ifeq ($(CODE_EMITTER),gcc)
FBCFLAGS+=-gen gcc
else
FBCFLAGS+=-gen gcc
endif

PATH_SEP ?= /
MOVE_PATH_SEP ?= \\

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
CFLAGS+=-m64
ASFLAGS+=--64
ENTRY_POINT_PARAM=-e ENTRYPOINT
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
ENTRY_POINT_PARAM=-e _ENTRYPOINT@0
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

MOVE_COMMAND ?= cmd.exe /c move /y
DELETE_COMMAND ?= cmd.exe /c del /f /q

FBC ?= fbc.exe
FBCFLAGS+=-d UNICODE -d WITHOUT_RUNTIME -w error -maxerr 1 -i src -r -s console -O 0
FBCFLAGS_DEBUG+=-g

CC ?= gcc.exe
C_EXT ?= c
EXTRA_CFLAGS+=-S
MARCH ?= native
CFLAGS+=-march=$(MARCH)
CFLAGS+=-nostdlib -nostdinc -Wall -Werror -Wno-main
CFLAGS+=-Wno-unused-label -Wno-unused-function -Wno-unused-variable
CFLAGS+=-Werror-implicit-function-declaration
CFLAGS_DEBUG+=-g -O0

AS ?= as.exe
ASM_EXT ?= asm
O_EXT ?= o
ASFLAGS+=
ASFLAGS_DEBUG+=

AR ?= ar.exe

GORC ?= GoRC.exe
OBJ_EXT ?= obj
GORCFLAGS+=/ni /o /d FROM_MAKEFILE
GORCFLAGS_DEBUG=/d DEBUG

LD ?= ld.exe
LDFLAGS+=--major-image-version 1 --minor-image-version 0
LDFLAGS+=-subsystem console
LDFLAGS+=--stack 1048576,1048576 --no-seh --nxcompat
LDFLAGS+=$(ENTRY_POINT_PARAM)
LDFLAGS+=-L $(LIB_DIR) -T "src$(PATH_SEP)fbextra.x"
LDLIBS+=-ladvapi32 -lkernel32 -lmsvcrt -lmswsock -lole32 -loleaut32
LDLIBS+=-lshell32 -lshlwapi -luuid -lws2_32
LDLIBS_DEBUG+=-lgcc -lmingw32 -lmingwex -lmoldname -lgcc_eh


all: release debug

include dependencies.mk

release: CFLAGS+=$(CFLAGS_RELEASE) -fstrict-aliasing -frounding-math
release: CFLAGS+=-fno-math-errno -fno-exceptions -fomit-frame-pointer
release: CFLAGS+=-mno-stack-arg-probe -fno-stack-check -fno-stack-protector
release: CFLAGS+=-fno-unwind-tables -fno-asynchronous-unwind-tables
release: CFLAGS+=-Ofast -fno-ident -fdata-sections -ffunction-sections
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

.PRECIOUS: $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(ASM_EXT)
.PRECIOUS: $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(ASM_EXT)
.PRECIOUS: $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(C_EXT)
.PRECIOUS: $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(C_EXT)

clean:
	$(DELETE_COMMAND) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)*.$(C_EXT)
	$(DELETE_COMMAND) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)*.$(C_EXT)
	$(DELETE_COMMAND) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)*.$(ASM_EXT)
	$(DELETE_COMMAND) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)*.$(ASM_EXT)
	$(DELETE_COMMAND) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)*.$(O_EXT)
	$(DELETE_COMMAND) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)*.$(O_EXT)
	$(DELETE_COMMAND) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)*.$(OBJ_EXT)
	$(DELETE_COMMAND) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)*.$(OBJ_EXT)
	$(DELETE_COMMAND) $(BIN_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)$(OUTPUT_FILE_NAME)
	$(DELETE_COMMAND) $(BIN_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)$(OUTPUT_FILE_NAME)

$(BIN_RELEASE_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME): $(OBJECTFILES_RELEASE)
	$(LD) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_DEBUG_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME):   $(OBJECTFILES_DEBUG)
	$(LD) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(O_EXT): $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(ASM_EXT)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(O_EXT): $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(ASM_EXT)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(ASM_EXT): $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(C_EXT)
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) -o $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(ASM_EXT): $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(C_EXT)
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) -o $@ $<

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(C_EXT): src$(PATH_SEP)%.bas
	$(FBC) $(FBCFLAGS) $<
	$(MOVE_COMMAND) src$(MOVE_PATH_SEP)$*.$(C_EXT) $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)$*$(FILE_SUFFIX).$(C_EXT)

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(C_EXT): src$(PATH_SEP)%.bas
	$(FBC) $(FBCFLAGS) $<
	$(MOVE_COMMAND) src$(MOVE_PATH_SEP)$*.$(C_EXT) $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)$*$(FILE_SUFFIX).$(C_EXT)

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(OBJ_EXT): src$(PATH_SEP)%.RC
	$(GORC) $(GORCFLAGS) /fo $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).$(OBJ_EXT): src$(PATH_SEP)%.RC
	$(GORC) $(GORCFLAGS) /fo $@ $<
