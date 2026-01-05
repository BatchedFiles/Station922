.PHONY: all debug release clean createdirs

all: release debug

# Legends:
# $@ - target name
# $^ - set of dependent files
# $< - name of first dependency
# % - pattern
# $* - variable pattern

FBC ?= fbc.exe
CC ?= gcc.exe
AS ?= as.exe
AR ?= ar.exe
GORC ?= GoRC.exe
LD ?= ld.exe
DLL_TOOL ?= dlltool.exe
LIB_DIR ?=
INC_DIR ?=
LD_SCRIPT ?=

TARGET_TRIPLET ?=

USE_RUNTIME ?= TRUE
USE_CRUNTIME ?= TRUE
USE_LD_LINKER ?= TRUE
FBC_VER ?= _FBC1101
GCC_VER ?= _GCC0930
ifeq ($(USE_RUNTIME),TRUE)
RUNTIME = _RT
else
RUNTIME = _WRT
endif
OUTPUT_FILE_NAME ?= Station922$(FILE_SUFFIX).exe

PARAM_SEP ?= /
PATH_SEP ?= /
MOVE_PATH_SEP ?= \\

MOVE_COMMAND ?= $(ComSpec) $(PARAM_SEP)c move $(PARAM_SEP)y
DELETE_COMMAND ?= $(ComSpec) $(PARAM_SEP)c del $(PARAM_SEP)f $(PARAM_SEP)q
MKDIR_COMMAND ?= $(ComSpec) $(PARAM_SEP)c mkdir
CPREPROCESSOR_COMMAND ?= $(ComSpec) $(PARAM_SEP)c echo no need to fix code

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
BIN_DEBUG_DIR ?= bin$(PATH_SEP)Debug$(PATH_SEP)x64
BIN_RELEASE_DIR ?= bin$(PATH_SEP)Release$(PATH_SEP)x64
OBJ_DEBUG_DIR ?= obj$(PATH_SEP)Debug$(PATH_SEP)x64
OBJ_RELEASE_DIR ?= obj$(PATH_SEP)Release$(PATH_SEP)x64
BIN_DEBUG_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x64
BIN_RELEASE_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x64
OBJ_DEBUG_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x64
OBJ_RELEASE_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x64
MARCH ?= x86-64
else
BIN_DEBUG_DIR ?= bin$(PATH_SEP)Debug$(PATH_SEP)x86
BIN_RELEASE_DIR ?= bin$(PATH_SEP)Release$(PATH_SEP)x86
OBJ_DEBUG_DIR ?= obj$(PATH_SEP)Debug$(PATH_SEP)x86
OBJ_RELEASE_DIR ?= obj$(PATH_SEP)Release$(PATH_SEP)x86
BIN_DEBUG_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x86
BIN_RELEASE_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x86
OBJ_DEBUG_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x86
OBJ_RELEASE_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x86
MARCH ?= i686
endif

FBCFLAGS+=-gen gcc
ifeq ($(USE_UNICODE),TRUE)
FBCFLAGS+=-d UNICODE
FBCFLAGS+=-d _UNICODE
endif
ifneq ($(WINVER),)
FBCFLAGS+=-d WINVER=$(WINVER)
endif
ifneq ($(_WIN32_WINNT),)
FBCFLAGS+=-d _WIN32_WINNT=$(_WIN32_WINNT)
endif
FBCFLAGS+=-m Station922
ifeq ($(USE_RUNTIME),TRUE)
else
FBCFLAGS+=-d WITHOUT_RUNTIME
endif
FBCFLAGS+=-w error -maxerr 1
ifneq ($(INC_DIR),)
FBCFLAGS+=-i "$(INC_DIR)"
endif
FBCFLAGS+=-i src
FBCFLAGS+=-r
FBCFLAGS+=-s console
FBCFLAGS+=-O 0
FBCFLAGS_DEBUG+=-g
debug: FBCFLAGS+=$(FBCFLAGS_DEBUG)

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
CFLAGS+=-m64
else
CFLAGS+=-m32
endif
CFLAGS+=-march=$(MARCH)
CFLAGS+=-pipe
CFLAGS+=-Wall -Werror -Wextra -pedantic
CFLAGS+=-Wno-unused-label -Wno-unused-function
CFLAGS+=-Wno-unused-parameter -Wno-unused-variable
CFLAGS+=-Wno-dollar-in-identifier-extension
CFLAGS+=-Wno-language-extension-token
CFLAGS+=-Wno-parentheses-equality
CFLAGS+=-Wno-builtin-declaration-mismatch
CFLAGS_DEBUG+=-g -O0
release: CFLAGS+=$(CFLAGS_RELEASE)
release: CFLAGS+=-fno-math-errno -fno-exceptions
release: CFLAGS+=-fno-unwind-tables -fno-asynchronous-unwind-tables
release: CFLAGS+=-O3 -fno-ident -fdata-sections -ffunction-sections
ifneq ($(FLTO),)
release: CFLAGS+=-flto
endif
debug: CFLAGS+=$(CFLAGS_DEBUG)

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
ASFLAGS+=--64
else
ASFLAGS+=--32
endif
ASFLAGS_DEBUG+=
release: ASFLAGS+=--strip-local-absolute
debug: ASFLAGS+=$(ASFLAGS_DEBUG)

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
GORCFLAGS+=$(PARAM_SEP)machine X64
endif
GORCFLAGS+=$(PARAM_SEP)ni
GORCFLAGS+=$(PARAM_SEP)o
ifneq ($(WINVER),)
GORCFLAGS+=$(PARAM_SEP)d WINVER=$(WINVER)
endif
ifneq ($(_WIN32_WINNT),)
GORCFLAGS+=$(PARAM_SEP)d _WIN32_WINNT=$(_WIN32_WINNT)
endif
GORCFLAGS_DEBUG=$(PARAM_SEP)d DEBUG
debug: GORCFLAGS+=$(GORCFLAGS_DEBUG)

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
else
ifeq ($(USE_LD_LINKER),TRUE)
LDFLAGS+=--large-address-aware
else
LDFLAGS+=-Wl,--large-address-aware
endif
endif
ifeq ($(USE_LD_LINKER),TRUE)
LDFLAGS+=--subsystem console
else
LDFLAGS+=-Wl,--subsystem,console
endif
ifeq ($(USE_LD_LINKER),TRUE)
LDFLAGS+=--no-seh --nxcompat
else
LDFLAGS+=-Wl,--no-seh -Wl,--nxcompat
endif
ifeq ($(USE_RUNTIME),TRUE)
ifeq ($(USE_LD_LINKER),TRUE)
LDFLAGS+=--stack 2097152,2097152
else
LDFLAGS+=-Wl,--stack 2097152,2097152
endif
endif
ifeq ($(USE_LD_LINKER),TRUE)
LDFLAGS+=-nostdlib
else
LDFLAGS+=-pipe -nostdlib
endif
LDFLAGS+=-L .
LDFLAGS+=-L "$(LIB_DIR)"
ifneq ($(LD_SCRIPT),)
LDFLAGS+=-T "$(LD_SCRIPT)"
endif
ifeq ($(USE_LD_LINKER),TRUE)
release: LDFLAGS+=-s --gc-sections
else
release: LDFLAGS+=-s -Wl,--gc-sections
endif
ifneq ($(FLTO),)
release: LDFLAGS+=-flto
endif
debug: LDFLAGS+=$(LDFLAGS_DEBUG)
debug: LDLIBS+=$(LDLIBS_DEBUG)

LDLIBSBEGIN+=$(OBJ_CRT_START)
ifeq ($(USE_LD_LINKER),TRUE)
LDLIBS+=--start-group
else
LDLIBS+=-Wl,--start-group
endif
LDLIBS+=$(LIBS_OS)
ifeq ($(USE_LD_LINKER),TRUE)
LDLIBS+=--end-group
else
LDLIBS+=-Wl,--end-group
endif
LDLIBSEND+=$(OBJ_CRT_END)
LDLIBS_DEBUG+=$(LIBS_GCC)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).o

DEPENDENCIES_1=src$(PATH_SEP)AcceptConnectionAsyncTask.bas src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)TcpAsyncListener.bi src$(PATH_SEP)ITcpAsyncListener.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).c: $(DEPENDENCIES_1)
$(OBJ_RELEASE_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).c: $(DEPENDENCIES_1)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).o

DEPENDENCIES_2=src$(PATH_SEP)ArrayStringWriter.bas src$(PATH_SEP)ArrayStringWriter.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).c: $(DEPENDENCIES_2)
$(OBJ_RELEASE_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).c: $(DEPENDENCIES_2)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).o

DEPENDENCIES_3=src$(PATH_SEP)AsyncResult.bas src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IAsyncResult.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).c: $(DEPENDENCIES_3)
$(OBJ_RELEASE_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).c: $(DEPENDENCIES_3)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).o

DEPENDENCIES_4=src$(PATH_SEP)ClientRequest.bas src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)HeapBSTR.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).c: $(DEPENDENCIES_4)
$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).c: $(DEPENDENCIES_4)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).o

DEPENDENCIES_5=src$(PATH_SEP)ClientUri.bas src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)Http.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).c: $(DEPENDENCIES_5)
$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).c: $(DEPENDENCIES_5)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).o

DEPENDENCIES_6=src$(PATH_SEP)ConsoleMain.bas src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).c: $(DEPENDENCIES_6)
$(OBJ_RELEASE_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).c: $(DEPENDENCIES_6)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)FileAsyncStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)FileAsyncStream$(FILE_SUFFIX).o

DEPENDENCIES_7=src$(PATH_SEP)FileAsyncStream.bas src$(PATH_SEP)FileAsyncStream.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)FileAsyncStream$(FILE_SUFFIX).c: $(DEPENDENCIES_7)
$(OBJ_RELEASE_DIR)$(PATH_SEP)FileAsyncStream$(FILE_SUFFIX).c: $(DEPENDENCIES_7)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).o

DEPENDENCIES_8=src$(PATH_SEP)Guids.bas

$(OBJ_DEBUG_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).c: $(DEPENDENCIES_8)
$(OBJ_RELEASE_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).c: $(DEPENDENCIES_8)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).o

DEPENDENCIES_9=src$(PATH_SEP)HeapBSTR.bas src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IString.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).c: $(DEPENDENCIES_9)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).c: $(DEPENDENCIES_9)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).o

DEPENDENCIES_10=src$(PATH_SEP)HeapMemoryAllocator.bas src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Logger.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).c: $(DEPENDENCIES_10)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).c: $(DEPENDENCIES_10)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).o

DEPENDENCIES_11=src$(PATH_SEP)Http.bas src$(PATH_SEP)Http.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).c: $(DEPENDENCIES_11)
$(OBJ_RELEASE_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).c: $(DEPENDENCIES_11)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpAsyncReader$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpAsyncReader$(FILE_SUFFIX).o

DEPENDENCIES_12=src$(PATH_SEP)HttpAsyncReader.bas src$(PATH_SEP)HttpAsyncReader.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)HeapBSTR.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpAsyncReader$(FILE_SUFFIX).c: $(DEPENDENCIES_12)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpAsyncReader$(FILE_SUFFIX).c: $(DEPENDENCIES_12)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpAsyncWriter$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpAsyncWriter$(FILE_SUFFIX).o

DEPENDENCIES_13=src$(PATH_SEP)HttpAsyncWriter.bas src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpAsyncWriter$(FILE_SUFFIX).c: $(DEPENDENCIES_13)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpAsyncWriter$(FILE_SUFFIX).c: $(DEPENDENCIES_13)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).o

DEPENDENCIES_14=src$(PATH_SEP)HttpDeleteProcessor.bas src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_14)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_14)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).o

DEPENDENCIES_15=src$(PATH_SEP)HttpGetProcessor.bas src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_15)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_15)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).o

DEPENDENCIES_16=src$(PATH_SEP)HttpOptionsProcessor.bas src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_16)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_16)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).o

DEPENDENCIES_17=src$(PATH_SEP)HttpProcessorCollection.bas src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)HeapBSTR.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).c: $(DEPENDENCIES_17)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).c: $(DEPENDENCIES_17)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).o

DEPENDENCIES_18=src$(PATH_SEP)HttpPutProcessor.bas src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_18)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_18)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).o

DEPENDENCIES_19=src$(PATH_SEP)HttpTraceProcessor.bas src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_19)
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).c: $(DEPENDENCIES_19)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).o

DEPENDENCIES_20=src$(PATH_SEP)IniConfiguration.bas src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).c: $(DEPENDENCIES_20)
$(OBJ_RELEASE_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).c: $(DEPENDENCIES_20)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).o

DEPENDENCIES_21=src$(PATH_SEP)Logger.bas src$(PATH_SEP)Logger.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).c: $(DEPENDENCIES_21)
$(OBJ_RELEASE_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).c: $(DEPENDENCIES_21)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)MemoryAsyncStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)MemoryAsyncStream$(FILE_SUFFIX).o

DEPENDENCIES_22=src$(PATH_SEP)MemoryAsyncStream.bas src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)MemoryAsyncStream$(FILE_SUFFIX).c: $(DEPENDENCIES_22)
$(OBJ_RELEASE_DIR)$(PATH_SEP)MemoryAsyncStream$(FILE_SUFFIX).c: $(DEPENDENCIES_22)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).o

DEPENDENCIES_23=src$(PATH_SEP)Mime.bas src$(PATH_SEP)Mime.bi src$(PATH_SEP)IString.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).c: $(DEPENDENCIES_23)
$(OBJ_RELEASE_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).c: $(DEPENDENCIES_23)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)mini-runtime$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)mini-runtime$(FILE_SUFFIX).o

DEPENDENCIES_24=src$(PATH_SEP)mini-runtime.bas src$(PATH_SEP)mini-runtime.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)mini-runtime$(FILE_SUFFIX).c: $(DEPENDENCIES_24)
$(OBJ_RELEASE_DIR)$(PATH_SEP)mini-runtime$(FILE_SUFFIX).c: $(DEPENDENCIES_24)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).o

DEPENDENCIES_25=src$(PATH_SEP)Network.bas src$(PATH_SEP)Network.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).c: $(DEPENDENCIES_25)
$(OBJ_RELEASE_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).c: $(DEPENDENCIES_25)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)NetworkAsyncStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)NetworkAsyncStream$(FILE_SUFFIX).o

DEPENDENCIES_26=src$(PATH_SEP)NetworkAsyncStream.bas src$(PATH_SEP)NetworkAsyncStream.bi src$(PATH_SEP)INetworkAsyncStream.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Network.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)NetworkAsyncStream$(FILE_SUFFIX).c: $(DEPENDENCIES_26)
$(OBJ_RELEASE_DIR)$(PATH_SEP)NetworkAsyncStream$(FILE_SUFFIX).c: $(DEPENDENCIES_26)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).o

DEPENDENCIES_27=src$(PATH_SEP)ReadRequestAsyncTask.bas src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).c: $(DEPENDENCIES_27)
$(OBJ_RELEASE_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).c: $(DEPENDENCIES_27)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).o

DEPENDENCIES_28=src$(PATH_SEP)ServerResponse.bas src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)Resources.RH src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).c: $(DEPENDENCIES_28)
$(OBJ_RELEASE_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).c: $(DEPENDENCIES_28)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).o

DEPENDENCIES_29=src$(PATH_SEP)Station922.bas src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WindowsServiceMain.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).c: $(DEPENDENCIES_29)
$(OBJ_RELEASE_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).c: $(DEPENDENCIES_29)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)TcpAsyncListener$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)TcpAsyncListener$(FILE_SUFFIX).o

DEPENDENCIES_30=src$(PATH_SEP)TcpAsyncListener.bas src$(PATH_SEP)TcpAsyncListener.bi src$(PATH_SEP)ITcpAsyncListener.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)Network.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)TcpAsyncListener$(FILE_SUFFIX).c: $(DEPENDENCIES_30)
$(OBJ_RELEASE_DIR)$(PATH_SEP)TcpAsyncListener$(FILE_SUFFIX).c: $(DEPENDENCIES_30)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).o

DEPENDENCIES_31=src$(PATH_SEP)ThreadPool.bas src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).c: $(DEPENDENCIES_31)
$(OBJ_RELEASE_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).c: $(DEPENDENCIES_31)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).o

DEPENDENCIES_32=src$(PATH_SEP)WebServer.bas src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpAsyncReader.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)NetworkAsyncStream.bi src$(PATH_SEP)INetworkAsyncStream.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).c: $(DEPENDENCIES_32)
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).c: $(DEPENDENCIES_32)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).o

DEPENDENCIES_33=src$(PATH_SEP)WebSite.bas src$(PATH_SEP)WebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)FileAsyncStream.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).c: $(DEPENDENCIES_33)
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).c: $(DEPENDENCIES_33)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).o

DEPENDENCIES_34=src$(PATH_SEP)WebSiteCollection.bas src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)HeapBSTR.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).c: $(DEPENDENCIES_34)
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).c: $(DEPENDENCIES_34)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).o

DEPENDENCIES_35=src$(PATH_SEP)WebUtils.bas src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)WebSite.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).c: $(DEPENDENCIES_35)
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).c: $(DEPENDENCIES_35)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).o

DEPENDENCIES_36=src$(PATH_SEP)WindowsServiceMain.bas src$(PATH_SEP)WindowsServiceMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).c: $(DEPENDENCIES_36)
$(OBJ_RELEASE_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).c: $(DEPENDENCIES_36)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).o

DEPENDENCIES_37=src$(PATH_SEP)WriteErrorAsyncTask.bas src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).c: $(DEPENDENCIES_37)
$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).c: $(DEPENDENCIES_37)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).o

DEPENDENCIES_38=src$(PATH_SEP)WriteResponseAsyncTask.bas src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi

$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).c: $(DEPENDENCIES_38)
$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).c: $(DEPENDENCIES_38)

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj

DEPENDENCIES_39=src$(PATH_SEP)Resources.RC src$(PATH_SEP)Resources.RH src$(PATH_SEP)manifest.xml

$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: $(DEPENDENCIES_39)
$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: $(DEPENDENCIES_39)

release: $(BIN_RELEASE_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME)

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

createdirs:
	$(MKDIR_COMMAND) $(BIN_DEBUG_DIR_MOVE)
	$(MKDIR_COMMAND) $(BIN_RELEASE_DIR_MOVE)
	$(MKDIR_COMMAND) $(OBJ_DEBUG_DIR_MOVE)
	$(MKDIR_COMMAND) $(OBJ_RELEASE_DIR_MOVE)

$(BIN_RELEASE_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME): $(OBJECTFILES_RELEASE)
	$(LD) $(LDFLAGS) $(LDLIBSBEGIN) $^ $(LDLIBS) $(LDLIBSEND) -o $@

$(BIN_DEBUG_DIR)$(PATH_SEP)$(OUTPUT_FILE_NAME): $(OBJECTFILES_DEBUG)
	$(LD) $(LDFLAGS) $(LDLIBSBEGIN) $^ $(LDLIBS) $(LDLIBSEND) -o $@

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).o: $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).o: $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm: $(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) -o $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).asm: $(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) -o $@ $<

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).obj: src$(PATH_SEP)%.RC
	$(GORC) $(GORCFLAGS) $(PARAM_SEP)fo $@ $<

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).obj: src$(PATH_SEP)%.RC
	$(GORC) $(GORCFLAGS) $(PARAM_SEP)fo $@ $<

$(OBJ_RELEASE_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c: src$(PATH_SEP)%.bas
	$(FBC) $(FBCFLAGS) $<
	$(CPREPROCESSOR_COMMAND) -release src$(MOVE_PATH_SEP)$*.c
	$(MOVE_COMMAND) src$(MOVE_PATH_SEP)$*.c $(OBJ_RELEASE_DIR_MOVE)$(MOVE_PATH_SEP)$*$(FILE_SUFFIX).c

$(OBJ_DEBUG_DIR)$(PATH_SEP)%$(FILE_SUFFIX).c: src$(PATH_SEP)%.bas
	$(FBC) $(FBCFLAGS) $<
	$(CPREPROCESSOR_COMMAND) -debug src$(MOVE_PATH_SEP)$*.c
	$(MOVE_COMMAND) src$(MOVE_PATH_SEP)$*.c $(OBJ_DEBUG_DIR_MOVE)$(MOVE_PATH_SEP)$*$(FILE_SUFFIX).c

