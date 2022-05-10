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

Const RAWBUFFER_CAPACITY As Integer = (RAWBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) \ SizeOf(UByte) - (4 * SizeOf(Integer)) \ SizeOf(UByte)

Const DoubleNewLineStringA = Str(!"\r\n\r\n")
Const NewLineStringA = Str(!"\r\n")

Type RawBuffer
	cbLength As Integer
	EndOfHeaders As Integer
	StartLine As Integer
	Padding As Integer
	Bytes(0 To RAWBUFFER_CAPACITY - 1) As UByte
End Type

Sub InitializeRawBuffer( _
		ByVal pBufer As RawBuffer Ptr _
	)
	
	' No Need ZeroMemory pBufer.Bytes
	pBufer->cbLength = 0
	pBufer->EndOfHeaders = 0
	
End Sub

Function RawBufferGetFreeSpaceLength( _
		ByVal pBufer As RawBuffer Ptr _
	)As Integer
	
	Dim FreeSpace As Integer = RAWBUFFER_CAPACITY - pBufer->cbLength
	
	Return FreeSpace
	
End Function

Function RawBufferFindDoubleCrLfIndexA( _
		ByVal pBufer As RawBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	For i As Integer = 0 To pBufer->cbLength - Len(DoubleNewLineStringA)
		
		Dim Destination As UByte Ptr = @pBufer->Bytes(i)
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

Function RawBufferFindCrLfIndexA( _
		ByVal pBufer As RawBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	For i As Integer = pBufer->StartLine To pBufer->EndOfHeaders - Len(NewLineStringA)
		
		Dim Destination As UByte Ptr = @pBufer->Bytes(i)
		Dim Finded As BOOL = RtlEqualMemory( _
			Destination, _
			@NewLineStringA, _
			Len(NewLineStringA) * SizeOf(ZString) _
		)
		
		If Finded Then
			Dim FindIndex As Integer = i - pBufer->StartLine
			*pFindIndex = FindIndex
			Return True
		End If
		
	Next
	
	*pFindIndex = 0
	Return False
	
End Function

Function RawBufferGetLine( _
		ByVal pBufer As RawBuffer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HeapBSTR
	
	Dim CrLfIndex As Integer = Any
	Dim Finded As Boolean = RawBufferFindCrLfIndexA( _
		pBufer, _
		@CrLfIndex _
	)
	If Finded = False Then
		Return NULL
	End If
	
	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — объединить обе строки
	
	Dim LineLength As Integer = CrLfIndex
	
	If LineLength = 0 Then
		Return NULL
	End If
	
	Dim StartLineIndex As Integer = pBufer->StartLine
	
	Dim bstrLine As HeapBSTR = HeapSysAllocZStringLen( _
		pIMemoryAllocator, _
		@pBufer->Bytes(StartLineIndex), _
		LineLength _
	)
	
	Dim NewStartIndex As Integer = StartLineIndex + LineLength + Len(NewLineStringA)
	pBufer->StartLine = NewStartIndex
	
	Return bstrLine
	
End Function

Type _HttpReader
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHttpReaderVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseStream Ptr
	pReadedData As RawBuffer Ptr
	IsAllBytesReaded As Boolean
End Type

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
	this->IsAllBytesReaded = False
	
End Sub

Sub UnInitializeHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
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
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
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
		*ppLine = NULL
		Return E_FAIL
	End If
	
	Dim bstrLine As HeapBSTR = RawBufferGetLine( _
		this->pReadedData, _
		this->pIMemoryAllocator _
	)
	
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
	
	Return HTTPREADER_S_IO_PENDING
	
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
				Return HTTPREADER_S_IO_PENDING
				
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
	
	Dim DoubleCrLfIndex As Integer = Any
	Dim Finded As Boolean = RawBufferFindDoubleCrLfIndexA( _
		this->pReadedData, _
		@DoubleCrLfIndex _
	)
	If Finded = False Then
		*ppLine = NULL
		Return HTTPREADER_S_IO_PENDING
	End If
	
	#if __FB_DEBUG__
	Scope
		Dim psa As SAFEARRAY Ptr = SafeArrayCreateVector( _
			VT_UI1, _
			0, _
			SizeOf(RawBuffer) _
		)
		Dim bytes As UByte Ptr = Any
		SafeArrayAccessData(psa, @bytes)
		CopyMemory(bytes, this->pReadedData, SizeOf(RawBuffer))
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
	
	Dim NewEndOfHeaders As Integer = DoubleCrLfIndex + Len(DoubleNewLineStringA)
	this->pReadedData->EndOfHeaders = NewEndOfHeaders
	this->pReadedData->StartLine = 0
	this->IsAllBytesReaded = True
	
	Dim bstrLine As HeapBSTR = RawBufferGetLine( _
		this->pReadedData, _
		this->pIMemoryAllocator _
	)
	
	*ppLine = bstrLine
	
	Return S_OK
	
End Function

Function HttpReaderClear( _
		ByVal this As HttpReader Ptr _
	)As HRESULT
	
	this->IsAllBytesReaded = False
	
	Dim cbPreloadedBytes As Integer = this->pReadedData->cbLength - this->pReadedData->EndOfHeaders
	
	If cbPreloadedBytes > 0 Then
		Dim Index As Integer = this->pReadedData->EndOfHeaders
		Dim Destination As UByte Ptr = @this->pReadedData->Bytes(0)
		Dim Source As UByte Ptr = @this->pReadedData->Bytes(Index)
		MoveMemory( _
			Destination, _
			Source, _
			cbPreloadedBytes _
		)
		this->pReadedData->EndOfHeaders = 0
		this->pReadedData->cbLength = cbPreloadedBytes
	Else
		this->pReadedData->EndOfHeaders = 0
		this->pReadedData->cbLength = 0
	End If
	
	Return S_OK
	
End Function

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
	
	Dim cbPreloadedBytes As Integer = this->pReadedData->cbLength - this->pReadedData->EndOfHeaders
	Dim PreloadedIndex As Integer = this->pReadedData->EndOfHeaders
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
