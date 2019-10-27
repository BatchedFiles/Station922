set CompilerDirectory=%ProgramFiles%\FreeBASIC

set MainFile=Modules\EntryPoint.bas
set Classes=Classes\ArrayStringWriter.bas Classes\ClientRequest.bas Classes\Configuration.bas Classes\HttpReader.bas Classes\NetworkStream.bas Classes\RequestedFile.bas Classes\ServerResponse.bas Classes\ServerState.bas Classes\WebServer.bas Classes\WebSite.bas Classes\WebSiteContainer.bas
set Modules=Mime.bas ProcessCgiRequest.bas ProcessConnectRequest.bas ProcessDeleteRequest.bas ProcessDllRequest.bas ProcessGetHeadRequest.bas ProcessOptionsRequest.bas ProcessPostRequest.bas ProcessPutRequest.bas ProcessTraceRequest.bas ProcessWebSocketRequest.bas URI.bas Modules\ConsoleColors.bas Modules\ConsoleMain.bas Modules\FindCrLfIndex.bas Modules\Guids.bas Modules\GuidsWithoutMinGW.bas Modules\Http.bas Modules\InitializeVirtualTables.bas Modules\Network.bas Modules\NetworkClient.bas Modules\NetworkServer.bas Modules\SafeHandle.bas Modules\ThreadProc.bas Modules\WebUtils.bas Modules\WindowsServiceMain.bas Modules\WriteHttpError.bas
set Resources=Resources.rc
set OutputFile=Station922.exe

set IncludeFilesPath=-i Classes -i Interfaces -i Modules -i Headers
set IncludeLibraries=-l crypt32 -l kernel32 -l Mswsock
set ExeTypeKind=console

set MaxErrorsCount=-maxerr 1
set MinWarningLevel=-w all
REM set UseThreadSafeRuntime=-mt

REM set EnableShowIncludes=-showincludes
REM set EnableVerbose=-v
REM set EnableRuntimeErrorChecking=-e
REM set EnableFunctionProfiling=-profile

set PROGRAM_VERSION_MAJOR=1
set PROGRAM_VERSION_MINOR=0
set PROGRAM_VERSION_BUILD=0
set PROGRAM_VERSION_REVISION=%RANDOM%

if "%1"=="service" (
	set SERVICE_DEFINED=-d WINDOWS_SERVICE
) else (
	set SERVICE_DEFINED=
)

if "%2"=="debug" (
	set EnableDebug=debug
	set OptimizationLevel=-O 0
	set VectorizationLevel=-vec 0
) else (
	set EnableDebug=release
	set OptimizationLevel=-O 3
	set VectorizationLevel=-vec 0
)

if "%3"=="withoutruntime" (
	set WithoutRuntime=withoutruntime
) else (
	set WithoutRuntime=runtime
)

set CompilerParameters=%SERVICE_DEFINED% -d PROGRAM_VERSION_MAJOR=%PROGRAM_VERSION_MAJOR% -d PROGRAM_VERSION_MINOR=%PROGRAM_VERSION_MINOR% -d PROGRAM_VERSION_BUILD=%PROGRAM_VERSION_BUILD% -d PROGRAM_VERSION_REVISION=%PROGRAM_VERSION_REVISION% %MaxErrorsCount% %UseThreadSafeRuntime% %IncludeLibraries% %IncludeFilesPath% %OptimizationLevel% %VectorizationLevel% %MinWarningLevel% %EnableFunctionProfiling% %EnableShowIncludes% %EnableVerbose% %EnableRuntimeErrorChecking%

call translator.cmd "%MainFile% %Classes% %Modules% %Resources%" "%ExeTypeKind%" "%OutputFile%" "%CompilerDirectory%" "%CompilerParameters%" %EnableDebug% noprofile %WithoutRuntime%