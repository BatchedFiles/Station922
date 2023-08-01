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

TARGET_TRIPLET ?=
MARCH ?= native

FBC_VER ?= FBC1100
GCC_VER ?= GCC0930
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
else
CFLAGS+=-m32
ASFLAGS+=--32
ENTRY_POINT=_EntryPoint@0
LDFLAGS+=-m i386pe --large-address-aware
GORCFLAGS+=
endif

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
CFLAGS_DEBUG+=-g -O0
FLTO ?=

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

OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpReader.bi src$(PATH_SEP)NetworkStream.bi src$(PATH_SEP)INetworkStream.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)TaskExecutor.bi src$(PATH_SEP)TcpListener.bi src$(PATH_SEP)ITcpListener.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)AcceptConnectionAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpReader.bi src$(PATH_SEP)NetworkStream.bi src$(PATH_SEP)INetworkStream.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)TaskExecutor.bi src$(PATH_SEP)TcpListener.bi src$(PATH_SEP)ITcpListener.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).c: src$(PATH_SEP)ArrayStringWriter.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ArrayStringWriter$(FILE_SUFFIX).c: src$(PATH_SEP)ArrayStringWriter.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).c: src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)ContainerOf.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)AsyncResult$(FILE_SUFFIX).c: src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)ContainerOf.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientBuffer$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientBuffer$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientBuffer$(FILE_SUFFIX).c: src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientBuffer$(FILE_SUFFIX).c: src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)HeapBSTR.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).c: src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientRequest$(FILE_SUFFIX).c: src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).c: src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)Http.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ClientUri$(FILE_SUFFIX).c: src$(PATH_SEP)ClientUri.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)Http.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).c: src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ConsoleMain$(FILE_SUFFIX).c: src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)FileStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)FileStream$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)FileStream$(FILE_SUFFIX).c: src$(PATH_SEP)FileStream.bi src$(PATH_SEP)IFileStream.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)FileStream$(FILE_SUFFIX).c: src$(PATH_SEP)FileStream.bi src$(PATH_SEP)IFileStream.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).c: 
$(OBJ_RELEASE_DIR)$(PATH_SEP)Guids$(FILE_SUFFIX).c: 
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).c: src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)ContainerOf.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapBSTR$(FILE_SUFFIX).c: src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)ContainerOf.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).c: src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)IClientSocket.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Logger.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HeapMemoryAllocator$(FILE_SUFFIX).c: src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)IClientSocket.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Logger.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).c: src$(PATH_SEP)Http.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Http$(FILE_SUFFIX).c: src$(PATH_SEP)Http.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpDeleteProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpGetProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)MemoryStream.bi src$(PATH_SEP)IMemoryStream.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpOptionsProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)MemoryStream.bi src$(PATH_SEP)IMemoryStream.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).c: src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpProcessorCollection$(FILE_SUFFIX).c: src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpPutProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpReader$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpReader$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpReader$(FILE_SUFFIX).c: src$(PATH_SEP)HttpReader.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpReader$(FILE_SUFFIX).c: src$(PATH_SEP)HttpReader.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)HeapBSTR.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)MemoryStream.bi src$(PATH_SEP)IMemoryStream.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpTraceProcessor$(FILE_SUFFIX).c: src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)MemoryStream.bi src$(PATH_SEP)IMemoryStream.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpWriter$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpWriter$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)HttpWriter$(FILE_SUFFIX).c: src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HttpWriter.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IFileStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)HttpWriter$(FILE_SUFFIX).c: src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HttpWriter.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IFileStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).c: src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)IniConfiguration$(FILE_SUFFIX).c: src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).c: src$(PATH_SEP)Logger.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Logger$(FILE_SUFFIX).c: src$(PATH_SEP)Logger.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)MemoryStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)MemoryStream$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)MemoryStream$(FILE_SUFFIX).c: src$(PATH_SEP)MemoryStream.bi src$(PATH_SEP)IMemoryStream.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)MemoryStream$(FILE_SUFFIX).c: src$(PATH_SEP)MemoryStream.bi src$(PATH_SEP)IMemoryStream.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).c: src$(PATH_SEP)Mime.bi src$(PATH_SEP)IString.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Mime$(FILE_SUFFIX).c: src$(PATH_SEP)Mime.bi src$(PATH_SEP)IString.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).c: src$(PATH_SEP)Network.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Network$(FILE_SUFFIX).c: src$(PATH_SEP)Network.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)NetworkStream$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)NetworkStream$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)NetworkStream$(FILE_SUFFIX).c: src$(PATH_SEP)NetworkStream.bi src$(PATH_SEP)INetworkStream.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)IClientSocket.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Network.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)NetworkStream$(FILE_SUFFIX).c: src$(PATH_SEP)NetworkStream.bi src$(PATH_SEP)INetworkStream.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)IClientSocket.bi src$(PATH_SEP)ITimeCounter.bi src$(PATH_SEP)Network.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ReadRequestAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj
$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: src$(PATH_SEP)Resources.RH src$(PATH_SEP)app.exe.manifest
$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: src$(PATH_SEP)Resources.RH src$(PATH_SEP)app.exe.manifest
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).c: src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ServerResponse$(FILE_SUFFIX).c: src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).c: src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WindowsServiceMain.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)Station922$(FILE_SUFFIX).c: src$(PATH_SEP)ConsoleMain.bi src$(PATH_SEP)WindowsServiceMain.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)TaskExecutor$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)TaskExecutor$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)TaskExecutor$(FILE_SUFFIX).c: src$(PATH_SEP)TaskExecutor.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)Logger.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)TaskExecutor$(FILE_SUFFIX).c: src$(PATH_SEP)TaskExecutor.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)Logger.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)TcpListener$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)TcpListener$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)TcpListener$(FILE_SUFFIX).c: src$(PATH_SEP)TcpListener.bi src$(PATH_SEP)ITcpListener.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)Network.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)TcpListener$(FILE_SUFFIX).c: src$(PATH_SEP)TcpListener.bi src$(PATH_SEP)ITcpListener.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)AsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)Network.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).c: src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)TaskExecutor.bi src$(PATH_SEP)IAsyncIoTask.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).c: src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)TaskExecutor.bi src$(PATH_SEP)IAsyncIoTask.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).c: src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpReader.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)TaskExecutor.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebServer$(FILE_SUFFIX).c: src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)AcceptConnectionAsyncTask.bi src$(PATH_SEP)IAcceptConnectionAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpReader.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)TaskExecutor.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).c: src$(PATH_SEP)WebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)FileStream.bi src$(PATH_SEP)IFileStream.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)MemoryStream.bi src$(PATH_SEP)IMemoryStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSite$(FILE_SUFFIX).c: src$(PATH_SEP)WebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ArrayStringWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)FileStream.bi src$(PATH_SEP)IFileStream.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)MemoryStream.bi src$(PATH_SEP)IMemoryStream.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).c: src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)ContainerOf.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebSiteCollection$(FILE_SUFFIX).c: src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)ContainerOf.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).c: src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)WebSite.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WebUtils$(FILE_SUFFIX).c: src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)CharacterConstants.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HeapMemoryAllocator.bi src$(PATH_SEP)IHeapMemoryAllocator.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)IniConfiguration.bi src$(PATH_SEP)IIniConfiguration.bi src$(PATH_SEP)Logger.bi src$(PATH_SEP)Network.bi src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)WebSite.bi src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)HttpDeleteProcessor.bi src$(PATH_SEP)IHttpDeleteAsyncProcessor.bi src$(PATH_SEP)HttpGetProcessor.bi src$(PATH_SEP)IHttpGetAsyncProcessor.bi src$(PATH_SEP)HttpOptionsProcessor.bi src$(PATH_SEP)IHttpOptionsAsyncProcessor.bi src$(PATH_SEP)HttpPutProcessor.bi src$(PATH_SEP)IHttpPutAsyncProcessor.bi src$(PATH_SEP)HttpTraceProcessor.bi src$(PATH_SEP)IHttpTraceAsyncProcessor.bi src$(PATH_SEP)WebSiteCollection.bi src$(PATH_SEP)WebServer.bi src$(PATH_SEP)IWebServer.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).c: src$(PATH_SEP)WindowsServiceMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WindowsServiceMain$(FILE_SUFFIX).c: src$(PATH_SEP)WindowsServiceMain.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)HttpWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteErrorAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)WriteErrorAsyncTask.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)HttpWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi
OBJECTFILES_DEBUG+=$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).o
OBJECTFILES_RELEASE+=$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).o
$(OBJ_DEBUG_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)HttpWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WriteResponseAsyncTask$(FILE_SUFFIX).c: src$(PATH_SEP)WriteResponseAsyncTask.bi src$(PATH_SEP)IWriteResponseAsyncIoTask.bi src$(PATH_SEP)IClientRequest.bi src$(PATH_SEP)IClientUri.bi src$(PATH_SEP)IString.bi src$(PATH_SEP)Http.bi src$(PATH_SEP)IHttpReader.bi src$(PATH_SEP)ClientBuffer.bi src$(PATH_SEP)IAsyncResult.bi src$(PATH_SEP)IBaseStream.bi src$(PATH_SEP)IHttpAsyncIoTask.bi src$(PATH_SEP)IAsyncIoTask.bi src$(PATH_SEP)IWebSiteCollection.bi src$(PATH_SEP)IEnumWebSite.bi src$(PATH_SEP)IWebSite.bi src$(PATH_SEP)IAttributedStream.bi src$(PATH_SEP)Mime.bi src$(PATH_SEP)IHttpProcessorCollection.bi src$(PATH_SEP)IEnumHttpProcessor.bi src$(PATH_SEP)IHttpAsyncProcessor.bi src$(PATH_SEP)IHttpWriter.bi src$(PATH_SEP)IServerResponse.bi src$(PATH_SEP)ReadRequestAsyncTask.bi src$(PATH_SEP)IReadRequestAsyncIoTask.bi src$(PATH_SEP)ClientRequest.bi src$(PATH_SEP)ContainerOf.bi src$(PATH_SEP)HeapBSTR.bi src$(PATH_SEP)HttpProcessorCollection.bi src$(PATH_SEP)HttpWriter.bi src$(PATH_SEP)ServerResponse.bi src$(PATH_SEP)WebsiteCollection.bi src$(PATH_SEP)WebUtils.bi src$(PATH_SEP)IThreadPool.bi src$(PATH_SEP)IWriteErrorAsyncIoTask.bi

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

createdirs:
	$(MKDIR_COMMAND) $(BIN_DEBUG_DIR_MOVE)
	$(MKDIR_COMMAND) $(BIN_RELEASE_DIR_MOVE)
	$(MKDIR_COMMAND) $(OBJ_DEBUG_DIR_MOVE)
	$(MKDIR_COMMAND) $(OBJ_RELEASE_DIR_MOVE)

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

