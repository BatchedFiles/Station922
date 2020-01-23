set CompilerDirectory=%ProgramFiles%\FreeBASIC

REM set MainFile=Modules\EntryPoint.bas
set Classes=Classes\ArrayStringWriter.bas Classes\ClientRequest.bas Classes\Configuration.bas Classes\HttpReader.bas Classes\Mime.bas Classes\NetworkStream.bas Classes\RequestedFile.bas Classes\SafeHandle.bas Classes\ServerResponse.bas Classes\ServerState.bas Classes\Station922Uri.bas Classes\WebServer.bas Classes\WebSite.bas Classes\WebSiteContainer.bas Classes\WorkerThreadContext.bas
set Modules=ProcessCgiRequest.bas ProcessConnectRequest.bas ProcessDeleteRequest.bas ProcessDllRequest.bas ProcessGetHeadRequest.bas ProcessOptionsRequest.bas ProcessPostRequest.bas ProcessPutRequest.bas ProcessTraceRequest.bas ProcessWebSocketRequest.bas Modules\ConsoleColors.bas Modules\ConsoleMain.bas Modules\CreateInstance.bas Modules\FindNewLineIndex.bas Modules\Guids.bas Modules\Http.bas Modules\InitializeVirtualTables.bas Modules\Network.bas Modules\NetworkClient.bas Modules\NetworkServer.bas Modules\PrintDebugInfo.bas Modules\ThreadProc.bas Modules\WebUtils.bas Modules\WindowsServiceMain.bas Modules\WriteHttpError.bas
set Resources=Resources.rc
set OutputFile=Station922.exe

set IncludeFilesPath=-i Classes -i Interfaces -i Modules -i Headers
set IncludeLibraries=-l crypt32 -l Mswsock
set ExeTypeKind=console

set MaxErrorsCount=-maxerr 1
set MinWarningLevel=-w all
REM set UseThreadSafeRuntime=-mt

set EnableShowIncludes=-showincludes
set EnableVerbose=-v
REM set EnableRuntimeErrorChecking=-e
REM set EnableFunctionProfiling=-profile

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
	set GUIDS_WITHOUT_MINGW=-d GUIDS_WITHOUT_MINGW=1
) else (
	set WithoutRuntime=runtime
	set GUIDS_WITHOUT_MINGW=
)

set CompilerParameters=%SERVICE_DEFINED% %MaxErrorsCount% %UseThreadSafeRuntime% %IncludeLibraries% %GUIDS_WITHOUT_MINGW% %OptimizationLevel% %VectorizationLevel% %MinWarningLevel% %EnableFunctionProfiling% %EnableShowIncludes% %EnableVerbose% %EnableRuntimeErrorChecking% %IncludeFilesPath%

call translator.cmd "%MainFile% %Classes% %Modules% %Resources%" "%ExeTypeKind%" "%OutputFile%" "%CompilerDirectory%" "%CompilerParameters%" %EnableDebug% noprofile %WithoutRuntime%