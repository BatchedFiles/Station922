#include once "HttpReader.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"

Extern GlobalHttpReaderVirtualTable As Const IHttpReaderVirtualTable

Const MEMORYPAGE_SIZE As Integer = 4096

#if __FB_DEBUG__
Const RAWBUFFER_MEMORYPAGE_COUNT As Integer = 2
#else
Const RAWBUFFER_MEMORYPAGE_COUNT As Integer = 4
#endif

Const RAWBUFFER_CAPACITY As Integer = (RAWBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) \ SizeOf(UByte) - (2 * SizeOf(Integer)) \ SizeOf(UByte)

Type RawBuffer
	cbLength As Integer
	cbUsed As Integer
	Bytes(0 To RAWBUFFER_CAPACITY - 1) As UByte
End Type

Const LINESBUFFER_MEMORYPAGE_COUNT As Integer = RAWBUFFER_MEMORYPAGE_COUNT * 2

Const LINESBUFFER_CAPACITY As Integer = (LINESBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) \ SizeOf(WString) - (2 * SizeOf(Integer)) \ SizeOf(WString) - SizeOf(WString)

Type LinesBuffer
	Length As Integer
	Start As Integer
	wszLine As WString * (LINESBUFFER_CAPACITY + 1)
End Type

Type _HttpReader
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHttpReaderVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseStream Ptr
	pReadedData As RawBuffer Ptr
	pLines As LinesBuffer Ptr
	IsAllBytesReaded As Boolean
End Type

Sub InitializeRawBuffer( _
		ByVal pBufer As RawBuffer Ptr _
	)
	
	' No Need ZeroMemory pBufer.Bytes
	pBufer->cbLength = 0
	pBufer->cbUsed = 0
	
End Sub

Function RawBufferGetFreeSpaceLength( _
		ByVal pBufer As RawBuffer Ptr _
	)As Integer
	
	Dim FreeSpace As Integer = RAWBUFFER_CAPACITY - pBufer->cbLength
	
	Return FreeSpace
	
End Function

Function FindDoubleCrLfIndexA( _
		ByVal Buffer As UByte Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	Const DoubleNewLineStringA = Str(!"\r\n\r\n")
	
	For i As Integer = 0 To BufferLength - Len(DoubleNewLineStringA)
		
		Dim Destination As UByte Ptr = @Buffer[i]
		Dim Finded As BOOL = RtlEqualMemory( _
			Destination, _
			@DoubleNewLineStringA, _
			Len(DoubleNewLineStringA) * SizeOf(ZString) _
		)
		
		If Finded Then
			*pFindIndex = i
			Return True
		End If
		
	Next
	
	*pFindIndex = 0
	Return False
	
End Function

Sub InitializeLinesBuffer( _
		ByVal pLines As LinesBuffer Ptr _
	)
	
	' No need ZeroMemory pLines.wszLine
	pLines->Length = 0
	pLines->Start = 0
	pLines->wszLine[0] = 0
	
End Sub

Function FindCrLfIndexW( _
		ByVal Buffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	Const NewLineStringW = WStr(!"\r\n")
	
	For i As Integer = 0 To BufferLength - Len(NewLineStringW)
		
		Dim Destination As WString Ptr = @Buffer[i]
		Dim Finded As BOOL = RtlEqualMemory( _
			Destination, _
			@NewLineStringW, _
			Len(NewLineStringW) * SizeOf(WString) _
		)
		
		If Finded Then
			*pFindIndex = i
			Return True
		End If
		
	Next
	
	*pFindIndex = 0
	Return False
	
End Function

Function LinesBufferGetLine( _
		ByVal lpLines As LinesBuffer Ptr, _
		ByVal ppLine As WString Ptr Ptr _
	)As Integer
	
	Dim Index As Integer = lpLines->Start
	Dim cbUsedChars As Integer = lpLines->Length - Index
	Dim lpBuffer As WString Ptr = @lpLines->wszLine[Index]
	Dim CrLfIndex As Integer = Any
	FindCrLfIndexW( _
		lpBuffer, _
		cbUsedChars, _
		@CrLfIndex _
	)
	
	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — объединить обе строки
	
	Dim CrlfOrdinal As Integer = Index + CrLfIndex
	lpLines->wszLine[CrlfOrdinal] = 0
	
	*ppLine = @lpLines->wszLine[Index]
	
	Const NewLineStringW = WStr(!"\r\n")
	Dim NewStartIndex As Integer = Index + CrLfIndex + Len(NewLineStringW)
	lpLines->Start = NewStartIndex
	
	Return CrLfIndex
	
End Function

Function ConvertBytesToWString( _
		ByVal lpLines As LinesBuffer Ptr, _
		ByVal lpRaw As RawBuffer Ptr _
	)As HRESULT
	
	Const dwFlags As DWORD = 0
	
	Dim CharsLength As Integer = MultiByteToWideChar( _
		CP_ACP, _
		dwFlags, _
		@lpRaw->Bytes(0), _
		lpRaw->cbUsed, _
		@lpLines->wszLine[0], _
		LINESBUFFER_CAPACITY _
	)
	If CharsLength = 0 Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	lpLines->Start = 0
	lpLines->Length = CharsLength
	lpLines->wszLine[CharsLength] = 0
	
	Return S_OK
	
End Function

/'
Function HttpReaderReadAllBytes( _
		ByVal this As HttpReader Ptr _
	)As HRESULT
	
	Dim DoubleCrLfIndex As Integer = Any
	
	Do
		Dim cbFreeSpace As Integer = RawBufferGetFreeSpaceLength(this->pReadedData)
		Dim FreeSpaceIndex As Integer = this->pReadedData->cbLength
		Dim lpFreeSpace As Any Ptr = @this->pReadedData->Bytes(FreeSpaceIndex)
		Dim cbReceived As DWORD = Any
		Dim hrRead As HRESULT = IBaseStream_Read( _
			this->pIStream, _
			lpFreeSpace, _
			cbFreeSpace, _
			@cbReceived _
		)
		If FAILED(hrRead) Then
			Return HTTPREADER_E_SOCKETERROR
		End If
		
		Select Case hrRead
			
			Case S_FALSE
				Return HTTPREADER_E_CLIENTCLOSEDCONNECTION
				
		End Select
		
		this->pReadedData->cbLength += cbReceived
		
		If this->pReadedData->cbLength >= RAWBUFFER_CAPACITY Then
			Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
		End If
		
		Dim pStartBytes As UByte Ptr = @this->pReadedData->Bytes(0)
		Dim Length As Integer = this->pReadedData->cbLength
		Dim Finded As Boolean = FindDoubleCrLfIndexA( _
			pStartBytes, _
			Length, _
			@DoubleCrLfIndex _
		)
		
		If Finded Then
			Exit Do
		End If
		
	Loop
	
	Const NewLineStringW = WStr(!"\r\n")
	Dim cbNewUsed As Integer = DoubleCrLfIndex + 2 * Len(NewLineStringW)
	this->pReadedData->cbUsed = cbNewUsed
	
	this->IsAllBytesReaded = True
	
	Return S_OK
	
End Function
'/

Sub InitializeHttpReader( _
		ByVal this As HttpReader Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pReadedData As RawBuffer Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("HttpReaderReader"), 16)
	#endif
	this->lpVtbl = @GlobalHttpReaderVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIStream = NULL
	
	InitializeRawBuffer(pReadedData)
	this->pReadedData = pReadedData
	
	' InitializeLinesBuffer(pLines)
	this->pLines = NULL
	
	this->IsAllBytesReaded = False
	
End Sub

Sub UnInitializeHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	If this->pLines <> NULL Then
		IMalloc_Free(this->pIMemoryAllocator, this->pLines)
	End If
	
	IMalloc_Free(this->pIMemoryAllocator, this->pReadedData)
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateHttpReader( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpReader Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(HttpReader)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"HttpReader creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim pReadedData As RawBuffer Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(RawBuffer) _
	)
	
	If pReadedData <> NULL Then
		
		Dim this As HttpReader Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(HttpReader) _
		)
		
		If this <> NULL Then
			InitializeHttpReader( _
				this, _
				pIMemoryAllocator, _
				pReadedData _
			)
			
			#if __FB_DEBUG__
			Scope
				Dim vtEmpty As VARIANT = Any
				VariantInit(@vtEmpty)
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr("HttpReader created"), _
					@vtEmpty _
				)
			End Scope
			#endif
			
			Return this
		End If
		
		IMalloc_Free(pIMemoryAllocator, pReadedData)
	End If
	
	Return NULL
	
End Function

Sub DestroyHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpReader destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpReader(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HttpReader destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function HttpReaderQueryInterface( _
		ByVal this As HttpReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHttpReader, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_ITextReader, riid) Then
			*ppv = @this->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	HttpReaderAddRef(this)
	
	Return S_OK
	
End Function

Function HttpReaderAddRef( _
		ByVal this As HttpReader Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function HttpReaderRelease( _
		ByVal this As HttpReader Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyHttpReader(this)
	
	Return 0
	
End Function

Function HttpReaderReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT
	
	If this->IsAllBytesReaded = False Then
		/'
		Dim hrReadAllBytes As HRESULT = HttpReaderReadAllBytes(this)
		If FAILED(hrReadAllBytes) Then
			*pLineLength = 0
			*ppLine = NULL
			Return hrReadAllBytes
		End If
		
		Dim hrConvertBytes As HRESULT = ConvertBytesToWString( _
			this->pLines, _
			this->pReadedData _
		)
		If FAILED(hrConvertBytes) Then
			*pLineLength = 0
			*ppLine = NULL
			Return hrConvertBytes
		End If
		'/
		
		*ppLine = NULL
		Return E_FAIL
	End If
	
	Dim pCurrentLine As WString Ptr = Any
	Dim LineLength As Integer = LinesBufferGetLine( _
		this->pLines, _
		@pCurrentLine  _
	)
	
	Dim bstrLine As HeapBSTR = Any
	If LineLength <> 0 Then
		bstrLine = HeapSysAllocStringLen( _
			this->pIMemoryAllocator, _
			pCurrentLine, _
			LineLength _
		)
	Else
		bstrLine = NULL
		If this->pLines <> NULL Then
			IMalloc_Free( _
				this->pIMemoryAllocator, _
				this->pLines _
			)
			this->pLines = NULL
		End If
	End If
	
	*ppLine = bstrLine
	
	Return S_OK
	
End Function

Function HttpReaderBeginReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	If this->IsAllBytesReaded = False Then
		
		Dim cbFreeSpace As Integer = RawBufferGetFreeSpaceLength(this->pReadedData)
		Dim FreeSpaceIndex As Integer = this->pReadedData->cbLength
		Dim lpFreeSpace As Any Ptr = @this->pReadedData->Bytes(FreeSpaceIndex)
		Dim hrBeginRead As HRESULT = IBaseStream_BeginRead( _
			this->pIStream, _
			lpFreeSpace, _
			cbFreeSpace, _
			callback, _
			StateObject, _
			ppIAsyncResult _
		)
		If FAILED(hrBeginRead) Then
			Return hrBeginRead
		End If
		
	End If
	
	Return TEXTREADER_S_IO_PENDING
	
End Function

Function HttpReaderEndReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT
	
	Dim cbReceived As DWORD = Any
	
	Scope
		Dim hrRead As HRESULT = IBaseStream_EndRead( _
			this->pIStream, _
			pIAsyncResult, _
			@cbReceived _
		)
		If FAILED(hrRead) Then
			*ppLine = NULL
			Return hrRead
		End If
		
		Select Case hrRead
			
			Case BASESTREAM_S_IO_PENDING
				*ppLine = NULL
				Return TEXTREADER_S_IO_PENDING
				
			Case S_FALSE
				*ppLine = NULL
				Return S_FALSE
				
		End Select
	End Scope
	
	Dim cbNewLength As Integer = this->pReadedData->cbLength + cbReceived
	
	If cbNewLength >= RAWBUFFER_CAPACITY Then
		*ppLine = NULL
		Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
	End If
	
	this->pReadedData->cbLength = cbNewLength
	
	Dim pStartBytes As UByte Ptr = @this->pReadedData->Bytes(0)
	Dim DoubleCrLfIndex As Integer = Any
	Dim Finded As Boolean = FindDoubleCrLfIndexA( _
		pStartBytes, _
		cbNewLength, _
		@DoubleCrLfIndex _
	)
	If Finded = False Then
		*ppLine = NULL
		Return TEXTREADER_S_IO_PENDING
	End If
	
	Const NewLineStringW = WStr(!"\r\n")
	Dim cbNewUsed As Integer = DoubleCrLfIndex + 2 * Len(NewLineStringW)
	this->pReadedData->cbUsed = cbNewUsed
	
	this->IsAllBytesReaded = True
	
	#if __FB_DEBUG__
	Scope
		Dim psa As SAFEARRAY Ptr = SafeArrayCreateVector( _
			VT_UI1, _
			0, _
			SizeOf(RawBuffer) _
		)
		Dim bytes As UByte Ptr = Any
		SafeArrayAccessData(psa, @bytes)
		CopyMemory(bytes, pStartBytes, SizeOf(RawBuffer))
		SafeArrayUnaccessData(psa)
		
		Dim vtArrayBytes As VARIANT = Any
		vtArrayBytes.vt = VT_ARRAY Or VT_UI1
		vtArrayBytes.parray = psa
		LogWriteEntry( _
			LogEntryType.Debug, _
			NULL, _
			@vtArrayBytes _
		)
		
		SafeArrayDestroy(psa)
	End Scope
	#endif
	
	Scope
		If this->pLines <> NULL Then
			IMalloc_Free( _
				this->pIMemoryAllocator, _
				this->pLines _
			)
		End If
		
		Dim pLines As LinesBuffer Ptr = IMalloc_Alloc( _
			this->pIMemoryAllocator, _
			SizeOf(LinesBuffer) _
		)
		If pLines = NULL Then
			*ppLine = NULL
			Return E_OUTOFMEMORY
		End If
		
		InitializeLinesBuffer(pLines)
		this->pLines = pLines
		
		Dim hrConvertBytes As HRESULT = ConvertBytesToWString( _
			this->pLines, _
			this->pReadedData _
		)
		If FAILED(hrConvertBytes) Then
			*ppLine = NULL
			Return hrConvertBytes
		End If
	End Scope
	
	Dim pCurrentLine As WString Ptr = Any
	Dim LineLength As Integer = LinesBufferGetLine( _
		this->pLines, _
		@pCurrentLine  _
	)
	
	Dim bstrLine As HeapBSTR = HeapSysAllocStringLen( _
		this->pIMemoryAllocator, _
		pCurrentLine, _
		LineLength _
	)
	
	*ppLine = bstrLine
	
	Return S_OK
	
End Function

Function HttpReaderClear( _
		ByVal this As HttpReader Ptr _
	)As HRESULT
	
	this->IsAllBytesReaded = False
	
	Dim cbPreloadedBytes As Integer = this->pReadedData->cbLength - this->pReadedData->cbUsed
	
	If cbPreloadedBytes > 0 Then
		Dim Index As Integer = this->pReadedData->cbUsed
		Dim Destination As UByte Ptr = @this->pReadedData->Bytes(0)
		Dim Source As UByte Ptr = @this->pReadedData->Bytes(Index)
		MoveMemory( _
			Destination, _
			Source, _
			cbPreloadedBytes _
		)
		this->pReadedData->cbUsed = 0
		this->pReadedData->cbLength = cbPreloadedBytes
	Else
		this->pReadedData->cbUsed = 0
		this->pReadedData->cbLength = 0
	End If
	
	Return S_OK
	
End Function

' Function HttpReaderGetBaseStream( _
		' ByVal this As HttpReader Ptr, _
		' ByVal ppResult As IBaseStream Ptr Ptr _
	' )As HRESULT
	
	' If this->pIStream = NULL Then
		' *ppResult = NULL
		' Return S_FALSE
	' End If
	
	' IBaseStream_AddRef(this->pIStream)
	' *ppResult = this->pIStream
	
	' Return S_OK
	
' End Function

Function HttpReaderSetBaseStream( _
		ByVal this As HttpReader Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pIStream <> NULL Then
		IBaseStream_AddRef(pIStream)
	End If
	
	this->pIStream = pIStream
	
	Return S_OK
	
End Function

Function HttpReaderGetPreloadedBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	Dim cbPreloadedBytes As Integer = this->pReadedData->cbLength - this->pReadedData->cbUsed
	Dim PreloadedIndex As Integer = this->pReadedData->cbUsed
	Dim pBytes As UByte Ptr = @this->pReadedData->Bytes(PreloadedIndex)
	
	*pPreloadedBytesLength = cbPreloadedBytes
	*ppPreloadedBytes = pBytes
	
	Return S_OK
	
End Function

Function HttpReaderGetRequestedBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	Dim Length As Integer = this->pReadedData->cbLength
	Dim pBytes As UByte Ptr = @this->pReadedData->Bytes(0)
	
	*pRequestedBytesLength = Length
	*ppRequestedBytes = pBytes
	
	Return S_OK
	
End Function

' Function HttpReaderIsCompleted( _
		' ByVal this As HttpReader Ptr, _
		' ByVal pCompleted As Boolean Ptr _
	' )As HRESULT
	
	' *pCompleted = this->IsAllBytesReaded
	
	' Return S_OK
	
' End Function

Function IHttpReaderQueryInterface( _
		ByVal this As IHttpReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HttpReaderQueryInterface(ContainerOf(this, HttpReader, lpVtbl), riid, ppvObject)
End Function

Function IHttpReaderAddRef( _
		ByVal this As IHttpReader Ptr _
	)As ULONG
	Return HttpReaderAddRef(ContainerOf(this, HttpReader, lpVtbl))
End Function

Function IHttpReaderRelease( _
		ByVal this As IHttpReader Ptr _
	)As ULONG
	Return HttpReaderRelease(ContainerOf(this, HttpReader, lpVtbl))
End Function

Function IHttpReaderReadLine( _
		ByVal this As IHttpReader Ptr, _
		ByVal pLine As HeapBSTR Ptr _
	)As HRESULT
	Return HttpReaderReadLine(ContainerOf(this, HttpReader, lpVtbl), pLine)
End Function

Function IHttpReaderBeginReadLine( _
		ByVal this As IHttpReader Ptr, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpReaderBeginReadLine(ContainerOf(this, HttpReader, lpVtbl), callback, StateObject, ppIAsyncResult)
End Function

Function IHttpReaderEndReadLine( _
		ByVal this As IHttpReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT
	Return HttpReaderEndReadLine(ContainerOf(this, HttpReader, lpVtbl), pIAsyncResult, ppLine)
End Function

Function IHttpReaderClear( _
		ByVal this As IHttpReader Ptr _
	)As HRESULT
	Return HttpReaderClear(ContainerOf(this, HttpReader, lpVtbl))
End Function

' Function IHttpReaderGetBaseStream( _
		' ByVal this As IHttpReader Ptr, _
		' ByVal ppResult As IBaseStream Ptr Ptr _
	' )As HRESULT
	' Return HttpReaderGetBaseStream(ContainerOf(this, HttpReader, lpVtbl), ppResult)
' End Function

Function IHttpReaderSetBaseStream( _
		ByVal this As IHttpReader Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	Return HttpReaderSetBaseStream(ContainerOf(this, HttpReader, lpVtbl), pIStream)
End Function

Function IHttpReaderGetPreloadedBytes( _
		ByVal this As IHttpReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return HttpReaderGetPreloadedBytes(ContainerOf(this, HttpReader, lpVtbl), pPreloadedBytesLength, ppPreloadedBytes)
End Function

Function IHttpReaderGetRequestedBytes( _
		ByVal this As IHttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return HttpReaderGetRequestedBytes(ContainerOf(this, HttpReader, lpVtbl), pRequestedBytesLength, ppRequestedBytes)
End Function

' Function IHttpReaderIsCompleted( _
		' ByVal this As IHttpReader Ptr, _
		' ByVal pCompleted As Boolean Ptr _
	' )As HRESULT
	' Return HttpReaderIsCompleted(ContainerOf(this, HttpReader, lpVtbl), pCompleted)
' End Function

Dim GlobalHttpReaderVirtualTable As Const IHttpReaderVirtualTable = Type( _
	@IHttpReaderQueryInterface, _
	@IHttpReaderAddRef, _
	@IHttpReaderRelease, _
	NULL, _ /' IHttpReaderPeek '/
	NULL, _ /' IHttpReaderReadChar '/
	NULL, _ /' IHttpReaderReadCharArray '/ 
	@IHttpReaderReadLine, _
	NULL, _ /' IHttpReaderReadToEnd '/
	@IHttpReaderBeginReadLine, _
	@IHttpReaderEndReadLine, _
	NULL, _ /' BeginReadToEnd '/
	NULL, _ /' EndReadToEnd '/
	@IHttpReaderClear, _
	NULL, _ /'@IHttpReaderGetBaseStream '/
	@IHttpReaderSetBaseStream, _
	@IHttpReaderGetPreloadedBytes, _
	@IHttpReaderGetRequestedBytes, _
	NULL _ /' @IHttpReaderIsCompleted'/
)
