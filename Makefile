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
LD_SCRIPT ?=
FLTO ?=

TARGET_TRIPLET ?=
MARCH ?= native

USE_RUNTIME ?= TRUE
FBC_VER ?= _FBC1101
GCC_VER ?= _GCC0930
ifeq ($(USE_RUNTIME),TRUE)
RUNTIME = _RT
else
RUNTIME = _WRT
endif
OUTPUT_FILE_NAME=Station922$(FILE_SUFFIX).exe

PATH_SEP ?= /
MOVE_PATH_SEP ?= \\

MOVE_COMMAND ?= cmd.exe /c move /y
DELETE_COMMAND ?= cmd.exe /c del /f /q
MKDIR_COMMAND ?= cmd.exe /c mkdir
SCRIPT_COMMAND ?= cscript.exe //nologo fix-emitted-code.vbs

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
BIN_DEBUG_DIR ?= bin$(PATH_SEP)Debug$(PATH_SEP)x64
BIN_RELEASE_DIR ?= bin$(PATH_SEP)Release$(PATH_SEP)x64
OBJ_DEBUG_DIR ?= obj$(PATH_SEP)Debug$(PATH_SEP)x64
OBJ_RELEASE_DIR ?= obj$(PATH_SEP)Release$(PATH_SEP)x64
BIN_DEBUG_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x64
BIN_RELEASE_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x64
OBJ_DEBUG_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x64
OBJ_RELEASE_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x64
else
BIN_DEBUG_DIR ?= bin$(PATH_SEP)Debug$(PATH_SEP)x86
BIN_RELEASE_DIR ?= bin$(PATH_SEP)Release$(PATH_SEP)x86
OBJ_DEBUG_DIR ?= obj$(PATH_SEP)Debug$(PATH_SEP)x86
OBJ_RELEASE_DIR ?= obj$(PATH_SEP)Release$(PATH_SEP)x86
BIN_DEBUG_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x86
BIN_RELEASE_DIR_MOVE ?= bin$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x86
OBJ_DEBUG_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Debug$(MOVE_PATH_SEP)x86
OBJ_RELEASE_DIR_MOVE ?= obj$(MOVE_PATH_SEP)Release$(MOVE_PATH_SEP)x86
endif

FBCFLAGS+=-gen gcc
ifeq ($(USE_UNICODE),TRUE)
FBCFLAGS+=-d UNICODE
FBCFLAGS+=-d _UNICODE
endif
FBCFLAGS+=-d WINVER=$(WINVER)
FBCFLAGS+=-d _WIN32_WINNT=$(_WIN32_WINNT)
ifeq ($(USE_RUNTIME),TRUE)
FBCFLAGS+=-m Station922
else
FBCFLAGS+=-d WITHOUT_RUNTIME
endif
FBCFLAGS+=-w error -maxerr 1
FBCFLAGS+=-i src
ifneq ($(INC_DIR),)
FBCFLAGS+=-i "$(INC_DIR)"
endif
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
CFLAGS+=-Wall -Werror -Wextra
CFLAGS+=-Wno-unused-label -Wno-unused-function
CFLAGS+=-Wno-unused-parameter -Wno-unused-variable
CFLAGS+=-Wno-dollar-in-identifier-extension
CFLAGS+=-Wno-language-extension-token
CFLAGS+=-Wno-parentheses-equality
CFLAGS_DEBUG+=-g -O0
release: CFLAGS+=$(CFLAGS_RELEASE)
release: CFLAGS+=-fno-math-errno -fno-exceptions
release: CFLAGS+=-fno-unwind-tables -fno-asynchronous-unwind-tables
release: CFLAGS+=-O3 -fno-ident -fdata-sections -ffunction-sections
ifneq ($(FLTO),)
release: CFLAGS+=$(FLTO)
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
GORCFLAGS+=/machine X64
endif
GORCFLAGS+=/ni /o /d FROM_MAKEFILE
GORCFLAGS_DEBUG=/d DEBUG
debug: GORCFLAGS+=$(GORCFLAGS_DEBUG)

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
ifeq ($(USE_RUNTIME),FALSE)
LDFLAGS+=-e EntryPoint
endif
LDFLAGS+=-m i386pep
else
ifeq ($(USE_RUNTIME),FALSE)
LDFLAGS+=-e _EntryPoint@0
endif
LDFLAGS+=-m i386pe
LDFLAGS+=--large-address-aware
endif
LDFLAGS+=-subsystem console
LDFLAGS+=--no-seh --nxcompat
LDFLAGS+=-L .
LDFLAGS+=-L "$(LIB_DIR)"
ifneq ($(LD_SCRIPT),)
LDFLAGS+=-T "$(LD_SCRIPT)"
endif
release: LDFLAGS+=-s --gc-sections
debug: LDFLAGS+=$(LDFLAGS_DEBUG)
debug: LDLIBS+=$(LDLIBS_DEBUG)

ifeq ($(USE_RUNTIME),TRUE)
LDLIBSBEGIN+="$(LIB_DIR)\crt2.o"
LDLIBSBEGIN+="$(LIB_DIR)\crtbegin.o"
LDLIBSBEGIN+="$(LIB_DIR)\fbrt0.o"
endif
LDLIBS+=--start-group
LDLIBS+=-ladvapi32 -lcomctl32 -lcomdlg32 -lcrypt32
LDLIBS+=-lgdi32 -lgdiplus -lkernel32 -lmswsock
LDLIBS+=-lole32 -loleaut32 -lshell32 -lshlwapi
LDLIBS+=-lwsock32 -lws2_32 -luser32
LDLIBS+=-lmsvcrt
ifeq ($(USE_RUNTIME),TRUE)
LDLIBS+=-lfbmt
LDLIBS+=-luuid
endif
LDLIBS_DEBUG+=-lgcc -lmingw32 -lmingwex -lmoldname -lgcc_eh
ifeq ($(USE_RUNTIME),TRUE)
LDLIBS+=-lgcc -lmingw32 -lmingwex -lmoldname -lgcc_eh
endif
LDLIBS+=--end-group
ifeq ($(USE_RUNTIME),TRUE)
LDLIBSEND+="$(LIB_DIR)\crtend.o"
endif

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)TcpAsyncListener.bi src$(PATH_SEP)ITcpAsyncListener.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)TcpAsyncListener.bi src$(PATH_SEP)ITcpAsyncListener.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).c: src$(PATH_SEP)ArrayStringWriter.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).c: src$(PATH_SEP)ArrayStringWriter.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).c: src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IAsyncResult.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).c: src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IAsyncResult.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).c: src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IObjectPool.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).c: src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IObjectPool.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).c: src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)Http.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).c: src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)Http.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).c: src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).c: src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)FileAsyncStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)FileAsyncStream$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)FileAsyncStream$(FILE_SUFFIX).c: src$(PATH_SEP)FileAsyncStream.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)FileAsyncStream$(FILE_SUFFIX).c: src$(PATH_SEP)FileAsyncStream.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).c: 
$(OBJ_RELEASE_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).c: 

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).c: src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IString.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).c: src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IString.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).c: src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)HttpAsyncReader.bi src$(PATH_SEP)IObjectPool.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)NetworkAsyncStream.bi src$(PATH_SEP)INetworkAsyncStream.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).c: src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)HttpAsyncReader.bi src$(PATH_SEP)IObjectPool.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)NetworkAsyncStream.bi src$(PATH_SEP)INetworkAsyncStream.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).c: src$(PATH_SEP)Http.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).c: src$(PATH_SEP)Http.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpAsyncReader$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpAsyncReader$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpAsyncReader$(FILE_SUFFIX).c: src$(PATH_SEP)HttpAsyncReader.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IObjectPool.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpAsyncReader$(FILE_SUFFIX).c: src$(PATH_SEP)HttpAsyncReader.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IObjectPool.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpAsyncWriter$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpAsyncWriter$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpAsyncWriter$(FILE_SUFFIX).c: src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpAsyncWriter$(FILE_SUFFIX).c: src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).c: src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).c: src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)HeapBSTR.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).c: src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).c: src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).c: src$(PATH_SEP)Logger.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).c: src$(PATH_SEP)Logger.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)MemoryAsyncStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)MemoryAsyncStream$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)MemoryAsyncStream$(FILE_SUFFIX).c: src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)MemoryAsyncStream$(FILE_SUFFIX).c: src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).c: src$(PATH_SEP)Mime.bi src$(PATH_SEP)IString.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).c: src$(PATH_SEP)Mime.bi src$(PATH_SEP)IString.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).c: src$(PATH_SEP)Network.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).c: src$(PATH_SEP)Network.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)NetworkAsyncStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)NetworkAsyncStream$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)NetworkAsyncStream$(FILE_SUFFIX).c: src$(PATH_SEP)NetworkAsyncStream.bi src$(PATH_SEP)INetworkAsyncStream.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IObjectPool.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Network.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)NetworkAsyncStream$(FILE_SUFFIX).c: src$(PATH_SEP)NetworkAsyncStream.bi src$(PATH_SEP)INetworkAsyncStream.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IObjectPool.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Network.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj

$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: src$(PATH_SEP)manifest.xml src$(PATH_SEP)Resources.RC src$(PATH_SEP)Resources.RH
$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: src$(PATH_SEP)manifest.xml src$(PATH_SEP)Resources.RC src$(PATH_SEP)Resources.RH

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).c: src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)Resources.RH src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).c: src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)Resources.RH src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).c: src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WindowsServiceMain.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).c: src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WindowsServiceMain.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)TcpAsyncListener$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)TcpAsyncListener$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)TcpAsyncListener$(FILE_SUFFIX).c: src$(PATH_SEP)TcpAsyncListener.bi src$(PATH_SEP)ITcpAsyncListener.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)Network.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)TcpAsyncListener$(FILE_SUFFIX).c: src$(PATH_SEP)TcpAsyncListener.bi src$(PATH_SEP)ITcpAsyncListener.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)Network.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).c: src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).c: src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).c: src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpAsyncReader.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)NetworkAsyncStream.bi src$(PATH_SEP)INetworkAsyncStream.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).c: src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpAsyncReader.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)NetworkAsyncStream.bi src$(PATH_SEP)INetworkAsyncStream.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).c: src$(PATH_SEP)WebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)FileAsyncStream.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).c: src$(PATH_SEP)WebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)FileAsyncStream.bi src$(PATH_SEP)IFileAsyncStream.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)MemoryAsyncStream.bi src$(PATH_SEP)IMemoryAsyncStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).c: src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).c: src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)HeapBSTR.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).c: src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)WebSite.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).c: src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)WebSite.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).c: src$(PATH_SEP)WindowsServiceMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).c: src$(PATH_SEP)WindowsServiceMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).o

$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpAsyncReader.bi src$(PATH_SEP)IBaseAsyncStream.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedAsyncStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)HttpAsyncWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi


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

