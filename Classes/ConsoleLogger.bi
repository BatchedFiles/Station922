#ifndef CONSOLELOGGER_BI
#define CONSOLELOGGER_BI

#include once "ILogger.bi"

Extern CLSID_CONSOLELOGGER Alias "CLSID_CONSOLELOGGER" As Const CLSID

Type ConsoleLogger As _ConsoleLogger

Type LPConsoleLogger As _ConsoleLogger Ptr

Declare Function CreateConsoleLogger( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As ConsoleLogger Ptr

Declare Sub DestroyConsoleLogger( _
	ByVal this As ConsoleLogger Ptr _
)

Declare Function ConsoleLoggerQueryInterface( _
	ByVal this As ConsoleLogger Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function ConsoleLoggerAddRef( _
	ByVal this As ConsoleLogger Ptr _
)As ULONG

Declare Function ConsoleLoggerRelease( _
	ByVal this As ConsoleLogger Ptr _
)As ULONG

Declare Function ConsoleLoggerLogDebug( _
	ByVal this As ConsoleLogger Ptr, _
	ByVal pwszText As WString Ptr, _
	ByVal vtData As VARIANT _
)As HRESULT

Declare Function ConsoleLoggerLogInformation( _
	ByVal this As ConsoleLogger Ptr, _
	ByVal pwszText As WString Ptr, _
	ByVal vtData As VARIANT _
)As HRESULT

Declare Function ConsoleLoggerLogWarning( _
	ByVal this As ConsoleLogger Ptr, _
	ByVal pwszText As WString Ptr, _
	ByVal vtData As VARIANT _
)As HRESULT

Declare Function ConsoleLoggerLogError( _
	ByVal this As ConsoleLogger Ptr, _
	ByVal pwszText As WString Ptr, _
	ByVal vtData As VARIANT _
)As HRESULT

Declare Function ConsoleLoggerLogCritical( _
	ByVal this As ConsoleLogger Ptr, _
	ByVal pwszText As WString Ptr, _
	ByVal vtData As VARIANT _
)As HRESULT

#endif
