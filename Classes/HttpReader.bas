#include once "HttpReader.bi"
#include once "ContainerOf.bi"
#include once "ReferenceCounter.bi"
#include once "StringConstants.bi"

Extern GlobalHttpReaderVirtualTable As Const IHttpReaderVirtualTable

Const MAX_CRITICAL_SECTION_SPIN_COUNT As DWORD = 4000

Const MEMORYPAGE_SIZE As Integer = 4096

Const RAWBUFFER_CAPACITY As Integer = (4 * MEMORYPAGE_SIZE) \ SizeOf(UByte) - (2 * SizeOf(Integer)) \ SizeOf(UByte)

Type RawBuffer
	Bytes(0 To RAWBUFFER_CAPACITY - 1) As UByte
	cbUsed As Integer
	cbLength As Integer
End Type

Const LINESBUFFER_CAPACITY As Integer = (8 * MEMORYPAGE_SIZE) \ SizeOf(WString) - (2 * SizeOf(Integer)) \ SizeOf(WString) - SizeOf(WString)

Type LinesBuffer
	wszLine As WString * (LINESBUFFER_CAPACITY + 1)
	Start As Integer
	Length As Integer
End Type

Type _HttpReader
	lpVtbl As Const IHttpReaderVirtualTable Ptr
	RefCounter As ReferenceCounter
	pILogger As ILogger Ptr
	pIMemoryAllocator As IMalloc Ptr
	crSection As CRITICAL_SECTION
	pIStream As IBaseStream Ptr
	pReadedData As RawBuffer Ptr
	pLines As LinesBuffer Ptr
	IsAllBytesReaded As Boolean
End Type

/'
Function FindCrLfIndexA( _
		ByVal Buffer As ZString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	For i As Integer = 0 To BufferLength - NewLineStringLength
		
		If Buffer[i + 0] = 13 AndAlso Buffer[i + 1] = 10 Then
			*pFindIndex = i
			Return True
		End If
		
	Next
	
	*pFindIndex = 0
	
	Return False
	
End Function
'/

Function FindCrLfIndexW( _
		ByVal Buffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	For i As Integer = 0 To BufferLength - NewLineStringLength
		
		If Buffer[i + 0] = 13 Then
			If Buffer[i + 1] = 10 Then
				*pFindIndex = i
				Return True
			End If
		End If
		
	Next
	
	*pFindIndex = 0
	
	Return False
	
End Function

Function FindDoubleCrLfIndexA( _
		ByVal Buffer As ZString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean
	
	For i As Integer = 0 To BufferLength - NewLineStringLength * 2
		
		If Buffer[i + 0] = 13 Then
			If Buffer[i + 1] = 10  Then
				If Buffer[i + 2] = 13 Then
					If Buffer[i + 3] = 10 Then
						
						*pFindIndex = i
						Return True
						
					End If
				End If
			End If
		End If
		
	Next
	
	*pFindIndex = 0
	Return False
	
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

Function GetLine( _
		ByVal lpLines As LinesBuffer Ptr, _
		ByVal ppLine As WString Ptr Ptr _
	)As Integer
	
	Dim cbUsedChars As Integer = lpLines->Length - lpLines->Start
	Dim Index As Integer = lpLines->Start
	Dim lpBuffer As WString Ptr = @lpLines->wszLine[Index]
	Dim CrLfIndex As Integer = Any
	FindCrLfIndexW( _
		lpBuffer, _
		cbUsedChars, _
		@CrLfIndex _
	)
	
	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — объединить обе строки
	
	Dim CrlfOrdinal As Integer = lpLines->Start + CrLfIndex
	lpLines->wszLine[CrlfOrdinal] = 0
	
	*ppLine = @lpLines->wszLine[lpLines->Start]
	
	Dim NewStartIndex As Integer = lpLines->Start + CrLfIndex + NewLineStringLength
	lpLines->Start = NewStartIndex
	
	Return CrLfIndex
	
End Function

Function HttpReaderReadAllBytes( _
		ByVal this As HttpReader Ptr _
	)As HRESULT
	
	Dim DoubleCrLfIndex As Integer = Any
	
	Do
		Dim cbFreeSpace As Integer = RAWBUFFER_CAPACITY - this->pReadedData->cbLength
		Dim Index As Integer = this->pReadedData->cbLength
		Dim lpBuffer As Any Ptr = @this->pReadedData->Bytes(Index)
		Dim cbReceived As DWORD = Any
		Dim hrRead As HRESULT = IBaseStream_Read( _
			this->pIStream, _
			lpBuffer, _
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
		
		Dim Finded As Boolean = FindDoubleCrLfIndexA( _
			@this->pReadedData->Bytes(0), _
			this->pReadedData->cbLength, _
			@DoubleCrLfIndex _
		)
		
		If Finded Then
			Exit Do
		End If
		
	Loop
	
	Dim cbNewUsed As Integer = DoubleCrLfIndex + 2 * NewLineStringLength
	this->pReadedData->cbUsed = cbNewUsed
	
	this->IsAllBytesReaded = True
	
	Return S_OK
	
End Function

Sub InitializeHttpReader( _
		ByVal this As HttpReader Ptr, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pReadedData As RawBuffer Ptr, _
		ByVal pLines As LinesBuffer Ptr _
	)
	
	this->lpVtbl = @GlobalHttpReaderVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	InitializeCriticalSectionAndSpinCount( _
		@this->crSection, _
		MAX_CRITICAL_SECTION_SPIN_COUNT _
	)
	this->pIStream = NULL
	this->pReadedData = pReadedData
	this->pReadedData->cbUsed = 0
	this->pReadedData->cbLength = 0
	this->pReadedData->Bytes(RAWBUFFER_CAPACITY) = 0
	this->pLines = pLines
	this->pLines->Start = 0
	this->pLines->Length = 0
	this->pLines->wszLine[0] = 0
	this->IsAllBytesReaded = False
	
End Sub

Sub UnInitializeHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	IMalloc_Free(this->pIMemoryAllocator, this->pLines)
	IMalloc_Free(this->pIMemoryAllocator, this->pReadedData)
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	DeleteCriticalSection(@this->crSection)
	ReferenceCounterUnInitialize(@this->RefCounter)
	IMalloc_Release(this->pIMemoryAllocator)
	ILogger_Release(this->pILogger)
	
End Sub

Function CreateHttpReader( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpReader Ptr
	
#if __FB_DEBUG__
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = SizeOf(HttpReader)
	ILogger_LogDebug(pILogger, WStr(!"HttpReader creating\t"), vtAllocatedBytes)
#endif
	
	Dim pReadedData As RawBuffer Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(RawBuffer) _
	)
	
	If pReadedData <> NULL Then
		
		Dim pLines As LinesBuffer Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(LinesBuffer) _
		)
		
		If pLines <> NULL Then
			
			Dim this As HttpReader Ptr = IMalloc_Alloc( _
				pIMemoryAllocator, _
				SizeOf(HttpReader) _
			)
			
			If this <> NULL Then
				InitializeHttpReader( _
					this, _
					pILogger, _
					pIMemoryAllocator, _
					pReadedData, _
					pLines _
				)
				
#if __FB_DEBUG__
				Dim vtEmpty As VARIANT = Any
				vtEmpty.vt = VT_EMPTY
				ILogger_LogDebug(pILogger, WStr("HttpReader created"), vtEmpty)
#endif
				Return this
			End If
			
			IMalloc_Free(pIMemoryAllocator, pLines)
		End If
		
		IMalloc_Free(pIMemoryAllocator, pReadedData)
	End If
	
	Return NULL
	
End Function

Sub DestroyHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
#if __FB_DEBUG__
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("HttpReader destroying"), vtEmpty)
#endif
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpReader(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
#if __FB_DEBUG__
	ILogger_LogDebug(pILogger, WStr("HttpReader destroyed"), vtEmpty)
#endif
	
	IMalloc_Release(pIMemoryAllocator)
	ILogger_Release(pILogger)
	
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
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function HttpReaderRelease( _
		ByVal this As HttpReader Ptr _
	)As ULONG
	
	If ReferenceCounterDecrement(@this->RefCounter) Then
		Return 1
	End If
	
	DestroyHttpReader(this)
	
	Return 0
	
End Function

Function HttpReaderReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal pLineLength As Integer Ptr, _
		ByVal ppLine As WString Ptr Ptr _
	)As HRESULT
	
	If this->IsAllBytesReaded = False Then
		
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
		
	End If
	
	Dim pCurrentLine As WString Ptr = Any
	Dim LineLength As Integer = GetLine( _
		this->pLines, _
		@pCurrentLine  _
	)
	
	*pLineLength = LineLength
	*ppLine = pCurrentLine
	
	Return S_OK
	
End Function

Function HttpReaderBeginReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal callback As AsyncCallback, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	If this->IsAllBytesReaded = False Then
		
		Dim cbFreeSpace As Integer = RAWBUFFER_CAPACITY - this->pReadedData->cbLength
		Dim Index As Integer = this->pReadedData->cbLength
		Dim lpBuffer As Any Ptr = @this->pReadedData->Bytes(Index)
		Dim hrBeginRead As HRESULT = IBaseStream_BeginRead( _
			this->pIStream, _
			lpBuffer, _
			cbFreeSpace, _
			callback, _
			StateObject, _
			ppIAsyncResult _
		)
		If FAILED(hrBeginRead) Then
			Return HTTPREADER_E_SOCKETERROR
		End If
		
		If hrBeginRead = BASESTREAM_S_IO_PENDING Then
			Return TEXTREADER_S_IO_PENDING
		End If
		
	End If
	
	Return S_OK
	
End Function

Function HttpReaderEndReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pLineLength As Integer Ptr, _
		ByVal ppLine As WString Ptr Ptr _
	)As HRESULT
	
	Dim cbReceived As DWORD = Any
	Dim hrRead As HRESULT = IBaseStream_EndRead( _
		this->pIStream, _
		pIAsyncResult, _
		@cbReceived _
	)
	If FAILED(hrRead) Then
		*pLineLength = 0
		*ppLine = NULL
		Return HTTPREADER_E_SOCKETERROR
	End If
	
	Select Case hrRead
		
		Case BASESTREAM_S_IO_PENDING
			*pLineLength = 0
			*ppLine = NULL
			Return TEXTREADER_S_IO_PENDING
			
		Case S_FALSE
			*pLineLength = 0
			*ppLine = NULL
			Return S_FALSE
			
	End Select
	
	this->pReadedData->cbLength += cbReceived
	
	If this->pReadedData->cbLength >= RAWBUFFER_CAPACITY Then
		*pLineLength = 0
		*ppLine = NULL
		Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
	End If
	
	Dim DoubleCrLfIndex As Integer = Any
	Dim Finded As Boolean = FindDoubleCrLfIndexA( _
		@this->pReadedData->Bytes(0), _
		this->pReadedData->cbLength, _
		@DoubleCrLfIndex _
	)
	If Finded = False Then
		*pLineLength = 0
		*ppLine = NULL
		Return TEXTREADER_S_IO_PENDING
	End If
	
	Dim cbNewUsed As Integer = DoubleCrLfIndex + 2 * NewLineStringLength
	this->pReadedData->cbUsed = cbNewUsed
	
	this->IsAllBytesReaded = True
	
	Dim hrConvertBytes As HRESULT = ConvertBytesToWString( _
		this->pLines, _
		this->pReadedData _
	)
	If FAILED(hrConvertBytes) Then
		*pLineLength = 0
		*ppLine = NULL
		Return hrConvertBytes
	End If
	
	Dim pCurrentLine As WString Ptr = Any
	Dim LineLength As Integer = GetLine( _
		this->pLines, _
		@pCurrentLine  _
	)
	
	*pLineLength = LineLength
	*ppLine = pCurrentLine
	
	Return S_OK
	
End Function

Function HttpReaderClear( _
		ByVal this As HttpReader Ptr _
	)As HRESULT
	
	this->IsAllBytesReaded = False
	
	this->pLines->Start = 0
	this->pLines->Length = 0
	this->pLines->wszLine[0] = 0
	
	Dim cbPreloadedBytes As Integer = this->pReadedData->cbLength - this->pReadedData->cbUsed
	
	If cbPreloadedBytes > 0 Then
		Dim Index As Integer = this->pReadedData->cbUsed
		RtlMoveMemory( _
			@this->pReadedData->Bytes(0), _
			@this->pReadedData->Bytes(Index), _
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

Function HttpReaderGetBaseStream( _
		ByVal this As HttpReader Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream = NULL Then
		*ppResult = NULL
		Return S_FALSE
	End If
	
	IBaseStream_AddRef(this->pIStream)
	*ppResult = this->pIStream
	
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
	
	Dim cbPreloadedBytes As Integer = this->pReadedData->cbLength - this->pReadedData->cbUsed
	
	*pPreloadedBytesLength = cbPreloadedBytes
	Dim Index As Integer = this->pReadedData->cbUsed
	*ppPreloadedBytes = @this->pReadedData->Bytes(Index)
	
	Return S_OK
	
End Function

Function HttpReaderGetRequestedBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	*pRequestedBytesLength = this->pReadedData->cbLength
	*ppRequestedBytes = @this->pReadedData->Bytes(0)
	
	Return S_OK
	
End Function

Function HttpReaderIsCompleted( _
		ByVal this As HttpReader Ptr, _
		ByVal pCompleted As Boolean Ptr _
	)As HRESULT
	
	*pCompleted = this->IsAllBytesReaded
	
	Return S_OK
	
End Function


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
		ByVal pLineLength As Integer Ptr, _
		ByVal pLine As WString Ptr Ptr _
	)As HRESULT
	Return HttpReaderReadLine(ContainerOf(this, HttpReader, lpVtbl), pLineLength, pLine)
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
		ByVal pLineLength As Integer Ptr, _
		ByVal ppLine As WString Ptr Ptr _
	)As HRESULT
	Return HttpReaderEndReadLine(ContainerOf(this, HttpReader, lpVtbl), pIAsyncResult, pLineLength, ppLine)
End Function

Function IHttpReaderClear( _
		ByVal this As IHttpReader Ptr _
	)As HRESULT
	Return HttpReaderClear(ContainerOf(this, HttpReader, lpVtbl))
End Function

Function IHttpReaderGetBaseStream( _
		ByVal this As IHttpReader Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	Return HttpReaderGetBaseStream(ContainerOf(this, HttpReader, lpVtbl), ppResult)
End Function

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

Function IHttpReaderIsCompleted( _
		ByVal this As IHttpReader Ptr, _
		ByVal pCompleted As Boolean Ptr _
	)As HRESULT
	Return HttpReaderIsCompleted(ContainerOf(this, HttpReader, lpVtbl), pCompleted)
End Function

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
	@IHttpReaderGetBaseStream, _
	@IHttpReaderSetBaseStream, _
	@IHttpReaderGetPreloadedBytes, _
	@IHttpReaderGetRequestedBytes, _
	@IHttpReaderIsCompleted _
)
