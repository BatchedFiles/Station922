#include once "ConsoleLogger.bi"
#include once "ContainerOf.bi"
#include once "ReferenceCounter.bi"

Extern GlobalConsoleLoggerVirtualTable As Const ILoggerVirtualTable

Type _ConsoleLogger
	Dim lpVtbl As Const ILoggerVirtualTable Ptr
	Dim RefCounter As ReferenceCounter
	Dim pIMemoryAllocator As IMalloc Ptr
End Type

Sub InitializeConsoleLogger( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalConsoleLoggerVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
End Sub

Sub UnInitializeConsoleLogger( _
		ByVal this As ConsoleLogger Ptr _
	)
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateConsoleLogger( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ConsoleLogger Ptr
	
	Dim this As ConsoleLogger Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ConsoleLogger) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeConsoleLogger(this, pIMemoryAllocator)
	
	Return this
	
End Function

Sub DestroyConsoleLogger( _
		ByVal this As ConsoleLogger Ptr _
	)
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeConsoleLogger(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ConsoleLoggerQueryInterface( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_ILogger, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ConsoleLoggerAddRef(this)
	
	Return S_OK
	
End Function

Function ConsoleLoggerAddRef( _
		ByVal this As ConsoleLogger Ptr _
	)As ULONG
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function ConsoleLoggerRelease( _
		ByVal this As ConsoleLogger Ptr _
	)As ULONG
	
	ReferenceCounterDecrement(@this->RefCounter)
	
	If this->RefCounter.Counter = 0 Then
		
		DestroyConsoleLogger(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function ConsoleLoggerLogDebug( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Return S_OK
	
End Function

Function ConsoleLoggerLogInformation( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Return S_OK
	
End Function

Function ConsoleLoggerLogWarning( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Return S_OK
	
End Function

Function ConsoleLoggerLogError( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Return S_OK
	
End Function

Function ConsoleLoggerLogCritical( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Return S_OK
	
End Function


Function ILoggerQueryInterface( _
		ByVal this As ILogger Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ConsoleLoggerQueryInterface(ContainerOf(this, ConsoleLogger, lpVtbl), riid, ppvObject)
End Function

Function ILoggerAddRef( _
		ByVal this As ILogger Ptr _
	)As ULONG
	Return ConsoleLoggerAddRef(ContainerOf(this, ConsoleLogger, lpVtbl))
End Function

Function ILoggerRelease( _
		ByVal this As ILogger Ptr _
	)As ULONG
	Return ConsoleLoggerRelease(ContainerOf(this, ConsoleLogger, lpVtbl))
End Function

Function ILoggerLogDebug( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	Return ConsoleLoggerLogDebug(ContainerOf(this, ConsoleLogger, lpVtbl), pwszText, vtData)
End Function

Function ILoggerLogInformation( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	Return ConsoleLoggerLogInformation(ContainerOf(this, ConsoleLogger, lpVtbl), pwszText, vtData)
End Function

Function ILoggerLogWarning( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	Return ConsoleLoggerLogWarning(ContainerOf(this, ConsoleLogger, lpVtbl), pwszText, vtData)
End Function

Function ILoggerLogError( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	Return ConsoleLoggerLogError(ContainerOf(this, ConsoleLogger, lpVtbl), pwszText, vtData)
End Function

Function ILoggerLogCritical( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	Return ConsoleLoggerLogCritical(ContainerOf(this, ConsoleLogger, lpVtbl), pwszText, vtData)
End Function

Dim GlobalConsoleLoggerVirtualTable As Const ILoggerVirtualTable = Type( _
	@ILoggerQueryInterface, _
	@ILoggerAddRef, _
	@ILoggerRelease, _
	@ILoggerLogDebug, _
	@ILoggerLogInformation, _
	@ILoggerLogWarning, _
	@ILoggerLogError, _
	@ILoggerLogCritical _
)
