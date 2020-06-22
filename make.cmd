set CompilerDirectory=%ProgramFiles%\FreeBASIC
REM Classes\ServerState.bas
REM Modules\ProcessDllRequest.bas
set MainFile=Modules\EntryPoint.bas
set Classes=Classes\ArrayStringWriter.bas Classes\ClientContext.bas Classes\ClientRequest.bas Classes\Configuration.bas Classes\HttpGetProcessor.bas Classes\HttpReader.bas Classes\Mime.bas Classes\NetworkStream.bas Classes\NetworkStreamAsyncResult.bas Classes\RequestedFile.bas Classes\SafeHandle.bas Classes\ServerResponse.bas Classes\Station922Uri.bas Classes\WebServer.bas Classes\WebSite.bas Classes\WebSiteContainer.bas
set Modules=Modules\ConsoleColors.bas Modules\ConsoleMain.bas Modules\CreateInstance.bas Modules\FindNewLineIndex.bas Modules\Guids.bas Modules\Http.bas Modules\Network.bas Modules\NetworkClient.bas Modules\NetworkServer.bas Modules\PrintDebugInfo.bas Modules\WebUtils.bas Modules\WindowsServiceMain.bas Modules\WorkerThread.bas Modules\WriteHttpError.bas
set Resources=Resources.RC
set OutputFile=Station922.exe

set IncludeFilesPath=-i Classes -i Interfaces -i Modules -i Headers
set IncludeLibraries=-l crypt32 -l Mswsock
set ExeTypeKind=console

set MaxErrorsCount=-maxerr 1
set MinWarningLevel=-w all
REM set UseThreadSafeRuntime=-mt

REM set EnableShowIncludes=-showincludes
REM set EnableVerbose=-v
REM set EnableRuntimeErrorChecking=-e
REM set EnableFunctionProfiling=-profile

if "%1"=="service" (
	set SERVICE_DEFINED=-d WINDOWS_SERVICE
) else (
	set SERVICE_DEFINED=
	set PERFORMANCE_TESTING_DEFINED=-d PERFORMANCE_TESTING
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

set CompilerParameters=%SERVICE_DEFINED% %PERFORMANCE_TESTING_DEFINED% %GUIDS_WITHOUT_MINGW% %MaxErrorsCount% %UseThreadSafeRuntime% %MinWarningLevel% %EnableFunctionProfiling% %EnableShowIncludes% %EnableVerbose% %EnableRuntimeErrorChecking% %IncludeFilesPath% %IncludeLibraries% %OptimizationLevel% %VectorizationLevel% 

call translator.cmd "%MainFile% %Classes% %Modules% %Resources%" "%ExeTypeKind%" "%OutputFile%" "%CompilerDirectory%" "%CompilerParameters%" %EnableDebug% noprofile %WithoutRuntime%