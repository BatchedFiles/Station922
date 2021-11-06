#include once "ConsoleLogger.bi"
#include once "ContainerOf.bi"
#include once "ReferenceCounter.bi"

Extern GlobalConsoleLoggerVirtualTable As Const ILoggerVirtualTable

Enum EntryType
	Debug
	Information
	Warning
	Error
	Critical
End Enum

Const MaxEntryes As Integer = 50

Type LogEntry
	Reason As EntryType
	Description As BSTR
	vtData As VARIANT
End Type

Type _ConsoleLogger
	lpVtbl As Const ILoggerVirtualTable Ptr
	RefCounter As ReferenceCounter
	pIMemoryAllocator As IMalloc Ptr
	Entryes(MaxEntryes - 1) As LogEntry
	EntryesCount As Integer
End Type

Sub ConsoleWriteColorStringW( _
		ByVal s As LPCWSTR _
	)
	
	Dim OutHandle As HANDLE = GetStdHandle(STD_OUTPUT_HANDLE)
	
	' SetConsoleTextAttribute(OutHandle, _
		' GetWinAPIForeColor(ForeColor) + GetWinAPIBackColor(BackColor) _
	' )
	
	Dim NumberOfCharsWritten As DWORD = Any
	Dim dwErrorConsole As WINBOOL = WriteConsoleW( _
		OutHandle, _
		s, _
		lstrlenW(s), _
		@NumberOfCharsWritten, _
		0 _
	)
	If dwErrorConsole = 0 Then
		
		Const MaxConsoleCharsCount As Integer = 32000 - 1
		
		Dim OutputCodePage As Integer = GetConsoleOutputCP()
		Dim Buffer As ZString * (MaxConsoleCharsCount + 1) = Any
		Dim BytesCount As Integer = WideCharToMultiByte( _
			OutputCodePage, _
			0, _
			s, _
			-1, _
			@Buffer, _
			MaxConsoleCharsCount, _
			NULL, _
			NULL _
		)
		
		Dim NumberOfBytesWritten As DWORD = Any
		Dim dwErrorFile As WINBOOL = WriteFile( _
			OutHandle, _
			@Buffer, _
			BytesCount - 1, _
			@NumberOfBytesWritten, _
			0 _
		)
		If dwErrorFile = 0 Then
			' Îøèáêà
		End If
		
	End If
	
End Sub

Function ConsoleLoggerWriteEntry( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal Reason As EntryType, _
		ByVal pwszText As WString Ptr, _
		ByVal pvtData As VARIANT Ptr _
	)As HRESULT
	
	' Dim Entry As LogEntry = Any
	' Entry.Reason = Reason
	' Entry.Description = SysAllocString(pwszText)
	' VariantInit(@Entry.vtData)
	' VariantCopy(@Entry.vtData, pvtData)
	
	Select Case Reason
		
		Case EntryType.Debug
			
		Case Else
			
	End Select
	
	Dim vtData As VARIANT = Any
	VariantInit(@vtData)
	
	If pvtData->vt = VT_ERROR Then
		Dim buf As WString * 255 = Any
		_ultow(pvtData->scode, @buf, 16)
		
		vtData.vt = VT_BSTR
		vtData.bstrVal = SysAllocString(buf)
	Else
		VariantChangeType( _
			@vtData, _
			pvtData, _
			0, _
			VT_BSTR _
		)
	End If
	
	ConsoleWriteColorStringW(pwszText)
	ConsoleWriteColorStringW(vtData.bstrVal)
	ConsoleWriteColorStringW(WStr(!"\r\n"))
	
	VariantClear(@vtData)
	
	Return S_OK
	
End Function

Sub InitializeConsoleLogger( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalConsoleLoggerVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	' For i As Integer = 0 To MaxEntryes - 1
		' Entryes(i)
	' Next
	this->EntryesCount = 0
	
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
	
#if __FB_DEBUG__
	Dim hr As HRESULT = ConsoleLoggerWriteEntry( _
		this, _
		EntryType.Debug, _
		pwszText, _
		@vtData _
	)
	
	Return hr
#else
	
	Return S_FALSE
#endif
	
End Function

Function ConsoleLoggerLogInformation( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Dim hr As HRESULT = ConsoleLoggerWriteEntry( _
		this, _
		EntryType.Information, _
		pwszText, _
		@vtData _
	)
	
	Return hr
	
End Function

Function ConsoleLoggerLogWarning( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Dim hr As HRESULT = ConsoleLoggerWriteEntry( _
		this, _
		EntryType.Warning, _
		pwszText, _
		@vtData _
	)
	
	Return hr
	
End Function

Function ConsoleLoggerLogError( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Dim hr As HRESULT = ConsoleLoggerWriteEntry( _
		this, _
		EntryType.Error, _
		pwszText, _
		@vtData _
	)
	
	Return hr
	
End Function

Function ConsoleLoggerLogCritical( _
		ByVal this As ConsoleLogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Dim hr As HRESULT = ConsoleLoggerWriteEntry( _
		this, _
		EntryType.Critical, _
		pwszText, _
		@vtData _
	)
	
	Return hr
	
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
