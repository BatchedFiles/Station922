#include once "HttpReader.bi"
#include once "ContainerOf.bi"
#include once "ReferenceCounter.bi"
#include once "StringConstants.bi"

Extern GlobalHttpReaderVirtualTable As Const IHttpReaderVirtualTable

Const MEMORYPAGE_SIZE As Integer = 4096

Const RAWBUFFER_CAPACITY As Integer = (4 * MEMORYPAGE_SIZE) \ SizeOf(UByte) - (2 * SizeOf(Integer)) \ SizeOf(UByte) - 1

Type RawBuffer
	cbUsed As Integer
	cbLength As Integer
	Bytes(RAWBUFFER_CAPACITY) As UByte
End Type

Const LINESBUFFER_CAPACITY As Integer = (8 * MEMORYPAGE_SIZE) \ SizeOf(WString) - (2 * SizeOf(Integer)) \ SizeOf(WString) - 1

Type LinesBuffer
	Start As Integer
	Length As Integer
	wszLine As WString * (LINESBUFFER_CAPACITY + 1)
End Type

Type _HttpReader
	lpVtbl As Const IHttpReaderVirtualTable Ptr
	RefCounter As ReferenceCounter
	pILogger As ILogger Ptr
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseStream Ptr
	ReadedData As RawBuffer
	Lines As LinesBuffer
	IsAllBytesReaded As Boolean
End Type

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

Function FindCrLfIndexW( _
		ByVal Buffer As WString Ptr, _
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
		CP_UTF8, _
		dwFlags, _
		@lpRaw->Bytes(0), _
		lpRaw->cbUsed, _
		@lpLines->wszLine[0], _
		LINESBUFFER_CAPACITY _
	)
	
	lpLines->Start = 0
	lpLines->Length = CharsLength
	lpLines->wszLine[CharsLength] = 0
	
	If CharsLength = 0 Then
		Return HTTPREADER_E_INSUFFICIENT_BUFFER
	End If
	
	Return S_OK
	
End Function

Function GetLine( _
		ByVal lpLines As LinesBuffer Ptr, _
		ByVal ppLine As WString Ptr Ptr _
	)As Integer
	
	Dim CrLfIndex As Integer = Any
	Dim cbUsedChars As Integer = lpLines->Length - lpLines->Start
	FindCrLfIndexW( _
		@lpLines->wszLine[lpLines->Start], _
		cbUsedChars, _
		@CrLfIndex _
	)
	
	Dim CrlfOrdinal As Integer = lpLines->Start + CrLfIndex
	lpLines->wszLine[CrlfOrdinal] = 0
	
	*ppLine = @lpLines->wszLine[lpLines->Start]
	
	Dim NewStartIndex As Integer = lpLines->Start + CrLfIndex + NewLineStringLength
	lpLines->Start = NewStartIndex
	
	Return CrLfIndex
	' TODO ѕроверить, начинаетс€ ли строка за CrLf с пробела
	' ≈сли начинаетс€ Ч сдвинуть до начала непробела
	
End Function

Function HttpReaderReadAllBytes( _
		ByVal this As HttpReader Ptr _
	)As HRESULT
	
	Dim DoubleCrLfIndex As Integer = Any
	
	Do
		Dim cbFreeSpace As Integer = RAWBUFFER_CAPACITY - this->ReadedData.cbLength
		Dim cbReceived As DWORD = Any
		Dim hrRead As HRESULT = IBaseStream_Read( _
			this->pIStream, _
			@this->ReadedData.Bytes(this->ReadedData.cbLength), _
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
		
		this->ReadedData.cbLength += cbReceived
		
		If this->ReadedData.cbLength >= RAWBUFFER_CAPACITY Then
			Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
		End If
		
		Dim Finded As Boolean = FindDoubleCrLfIndexA( _
			@this->ReadedData.Bytes(0), _
			this->ReadedData.cbLength, _
			@DoubleCrLfIndex _
		)
		
		If Finded Then
			Exit Do
		End If
		
	Loop
	
	Dim cbNewUsed As Integer = DoubleCrLfIndex + 2 * NewLineStringLength
	this->ReadedData.cbUsed = cbNewUsed
	
	this->IsAllBytesReaded = True
	
	Return S_OK
	
End Function

Sub InitializeHttpReader( _
		ByVal this As HttpReader Ptr, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalHttpReaderVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIStream = NULL
	this->ReadedData.cbUsed = 0
	this->ReadedData.cbLength = 0
	this->ReadedData.Bytes(RAWBUFFER_CAPACITY) = 0
	this->Lines.Start = 0
	this->Lines.Length = 0
	this->Lines.wszLine[0] = 0
	this->IsAllBytesReaded = False
	
End Sub

Sub UnInitializeHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	IMalloc_Release(this->pIMemoryAllocator)
	ILogger_Release(this->pILogger)
	
End Sub

Function CreateHttpReader( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpReader Ptr
	
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = SizeOf(HttpReader)
	ILogger_LogDebug(pILogger, WStr(!"HttpReader creating\t"), vtAllocatedBytes)
	
	Dim this As HttpReader Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpReader) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeHttpReader(this, pILogger, pIMemoryAllocator)
	
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(pILogger, WStr("HttpReader created"), vtEmpty)
	
	Return this
	
End Function

Sub DestroyHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	' DebugPrintWString(WStr("HttpReader destroying"))
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("HttpReader destroying"), vtEmpty)
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpReader(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	ILogger_LogDebug(pILogger, WStr("HttpReader destroyed"), vtEmpty)
	
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
	
	ReferenceCounterDecrement(@this->RefCounter)
	
	If this->RefCounter.Counter = 0 Then
		
		DestroyHttpReader(this)
		
		Return 0
	End If
	
	Return 1
	
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
		
		Dim hrConvertBytes As HRESULT = ConvertBytesToWString(@this->Lines, @this->ReadedData)
		If FAILED(hrConvertBytes) Then
			*pLineLength = 0
			*ppLine = NULL
			Return hrConvertBytes
		End If
		
	End If
	
	Dim pCurrentLine As WString Ptr = Any
	Dim LineLength As Integer = GetLine( _
		@this->Lines, _
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
		
		Dim cbFreeSpace As Integer = RAWBUFFER_CAPACITY - this->ReadedData.cbLength
		Dim hrBeginRead As HRESULT = IBaseStream_BeginRead( _
			this->pIStream, _
			@this->ReadedData.Bytes(this->ReadedData.cbLength), _
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
	
	this->ReadedData.cbLength += cbReceived
	
	If this->ReadedData.cbLength >= RAWBUFFER_CAPACITY Then
		*pLineLength = 0
		*ppLine = NULL
		Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
	End If
	
	Dim DoubleCrLfIndex As Integer = Any
	Dim Finded As Boolean = FindDoubleCrLfIndexA( _
		@this->ReadedData.Bytes(0), _
		this->ReadedData.cbLength, _
		@DoubleCrLfIndex _
	)
	If Finded = False Then
		*pLineLength = 0
		*ppLine = NULL
		Return TEXTREADER_S_IO_PENDING
	End If
	
	Dim cbNewUsed As Integer = DoubleCrLfIndex + 2 * NewLineStringLength
	this->ReadedData.cbUsed = cbNewUsed
	
	this->IsAllBytesReaded = True
	
	Dim hrConvertBytes As HRESULT = ConvertBytesToWString(@this->Lines, @this->ReadedData)
	If FAILED(hrConvertBytes) Then
		*pLineLength = 0
		*ppLine = NULL
		Return hrConvertBytes
	End If
	
	Dim pCurrentLine As WString Ptr = Any
	Dim LineLength As Integer = GetLine( _
		@this->Lines, _
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
	
	this->Lines.Start = 0
	this->Lines.Length = 0
	this->Lines.wszLine[0] = 0
	
	Dim cbPreloadedBytes As Integer = this->ReadedData.cbLength - this->ReadedData.cbUsed
	
	If cbPreloadedBytes > 0 Then
		RtlMoveMemory( _
			@this->ReadedData.Bytes(0), _
			@this->ReadedData.Bytes(this->ReadedData.cbUsed), _
			cbPreloadedBytes _
		)
		this->ReadedData.cbUsed = 0
		this->ReadedData.cbLength = cbPreloadedBytes
	Else
		this->ReadedData.cbUsed = 0
		this->ReadedData.cbLength = 0
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
	
	Dim cbPreloadedBytes As Integer = this->ReadedData.cbLength - this->ReadedData.cbUsed
	
	*pPreloadedBytesLength = cbPreloadedBytes
	*ppPreloadedBytes = @this->ReadedData.Bytes(this->ReadedData.cbUsed)
	
	Return S_OK
	
End Function

Function HttpReaderGetRequestedBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	*pRequestedBytesLength = this->ReadedData.cbLength
	*ppRequestedBytes = @this->ReadedData.Bytes(0)
	
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
