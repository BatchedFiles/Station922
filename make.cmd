set IncludeFilesPath=-i Classes -i Interfaces -i Modules
set IncludeLibraries=-l crypt32 -l Mswsock
set MaxErrorsCount=-maxerr 1
set OptimizationLevel=-O 0
set MinWarningLevel=-w all
REM set AddDebugInfo=-g
REM set EnableFunctionProfiling=-profile
REM set WriteOutOnlyAsm=-r
REM set CreateStaticLibrary=-lib
REM set ShowIncludes=-showincludes
if "%1"=="service" (
	set SERVICE_DEFINED=-d service
	set MainFile=Modules\WebServerService.bas
	set Win32Subsystem=-s console
	set OutputFileName=-x Station922.exe
) else (
	set SERVICE_DEFINED=
	set MainFile=Modules\Main.bas
	set OutputFileName=-x WebServer.exe
)
if "%2"=="withoutruntime" (
	set WITHOUT_RUNTIME_DEFINED=-d withoutruntime
	set WriteOutOnlyAsm=-r
	set CreateStaticLibrary=-lib
) else (
	set WITHOUT_RUNTIME_DEFINED=
	set UseThreadSafeRuntime=-mt
)
"%ProgramFiles%\FreeBASIC\fbc.exe" %MaxErrorsCount% %UseThreadSafeRuntime% %OutputFileName% %IncludeLibraries% %IncludeFilesPath% %SERVICE_DEFINED% %WITHOUT_RUNTIME_DEFINED% %OptimizationLevel% %Win32Subsystem% %MinWarningLevel% %AddDebugInfo% %EnableFunctionProfiling% %WriteOutOnlyAsm% %CreateStaticLibrary% %ShowIncludes% %MainFile% Mime.bas ProcessCgiRequest.bas ProcessConnectRequest.bas ProcessDeleteRequest.bas ProcessDllRequest.bas ProcessGetHeadRequest.bas ProcessOptionsRequest.bas ProcessPostRequest.bas ProcessPutRequest.bas ProcessTraceRequest.bas ProcessWebSocketRequest.bas URI.bas Modules\ConsoleColors.bas Modules\Http.bas Modules\InitializeVirtualTables.bas Modules\Network.bas Modules\NetworkClient.bas Modules\NetworkServer.bas Modules\SafeHandle.bas Modules\ThreadProc.bas Modules\WebUtils.bas Modules\WriteHttpError.bas Classes\ArrayStringWriter.bas Classes\ClientRequest.bas Classes\Configuration.bas Classes\HttpReader.bas Classes\NetworkStream.bas Classes\RequestedFile.bas Classes\ServerResponse.bas Classes\ServerState.bas Classes\WebServer.bas Classes\WebSite.bas Classes\WebSiteContainer.bas Resources.rc >_out.txt