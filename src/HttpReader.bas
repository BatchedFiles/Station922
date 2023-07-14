#include once "HttpReader.bi"
#include once "ContainerOf.bi"
#include once "Http.bi"
#include once "HeapBSTR.bi"

Extern GlobalHttpReaderVirtualTable As Const IHttpReaderVirtualTable

Const DoubleNewLineStringA = Str(!"\r\n\r\n")

Type _HttpReader
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpReaderVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseStream Ptr
	pClientBuffer As ClientRequestBuffer Ptr
	SkippedBytes As LongInt
	IsAllBytesReaded As Boolean
End Type

Function GetPreloadedBytesLength( _
		ByVal pClientBuffer As ClientRequestBuffer Ptr _
	)As Integer
	
	Dim cbPreloadedBytes As Integer = pClientBuffer->cbLength - pClientBuffer->EndOfHeaders
	
	Return cbPreloadedBytes
	
End Function

Sub InitializeHttpReader( _
		ByVal this As HttpReader Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_HTTPREADER), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalHttpReaderVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIStream = NULL
	this->pClientBuffer = NULL
	this->SkippedBytes = 0
	this->IsAllBytesReaded = False
	
End Sub

Sub UnInitializeHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
End Sub

Sub HttpReaderCreated( _
		ByVal this As HttpReader Ptr _
	)
	
End Sub

Function CreateHttpReader( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As HttpReader Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpReader) _
	)
	
	If this Then
		InitializeHttpReader(this, pIMemoryAllocator)
		HttpReaderCreated(this)
		
		Dim hrQueryInterface As HRESULT = HttpReaderQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHttpReader(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub HttpReaderDestroyed( _
		ByVal this As HttpReader Ptr _
	)
	
End Sub

Sub DestroyHttpReader( _
		ByVal this As HttpReader Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeHttpReader(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	HttpReaderDestroyed(this)
	
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
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function HttpReaderRelease( _
		ByVal this As HttpReader Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
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
	
	Dim bstrLine As HeapBSTR = ClientRequestBufferGetLine( _
		this->pClientBuffer, _
		this->pIMemoryAllocator _
	)
	If bstrLine = NULL Then
		*ppLine = NULL
		Return E_OUTOFMEMORY
	End If
	
	*ppLine = bstrLine
	Return S_OK
	
End Function

Function HttpReaderBeginReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	If this->IsAllBytesReaded = False Then
		
		Dim cbFreeSpace As Integer = ClientRequestBufferGetFreeSpaceLength( _
			this->pClientBuffer _
		)
		If cbFreeSpace = 0 Then
			*ppIAsyncResult = NULL
			Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
		End If
		
		Dim FreeSpaceIndex As Integer = this->pClientBuffer->cbLength
		Dim lpFreeSpace As Any Ptr = @this->pClientBuffer->Bytes(FreeSpaceIndex)
		Dim hrBeginRead As HRESULT = IBaseStream_BeginRead( _
			this->pIStream, _
			lpFreeSpace, _
			cbFreeSpace, _
			StateObject, _
			ppIAsyncResult _
		)
		If FAILED(hrBeginRead) Then
			Return hrBeginRead
		End If
		
	End If
	
	Return HTTPREADER_S_IO_PENDING
	
End Function

Sub HttpReaderPrintClientBuffer( _
		ByVal this As HttpReader Ptr _
	)
	
End Sub

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
		
		If hrRead = S_FALSE Then
			*ppLine = NULL
			Return S_FALSE
		End If
		
	End Scope
	
	Dim SkippedBytes As LongInt = min(this->SkippedBytes, CLngInt(cbReceived))
	
	If this->SkippedBytes Then
		Dim cbMovedBytes As Integer = RAWBUFFER_CAPACITY - CInt(SkippedBytes)
		If cbMovedBytes Then
			memmove( _
				@this->pClientBuffer->Bytes(0), _
				@this->pClientBuffer->Bytes(SkippedBytes), _
				cbMovedBytes _
			)
		End If
		
		this->SkippedBytes -= SkippedBytes
		
		If this->SkippedBytes Then
			*ppLine = NULL
			Return HTTPREADER_S_IO_PENDING
		End If
	End If
	
	Dim cbNewLength As Integer = this->pClientBuffer->cbLength + cbReceived - SkippedBytes
	
	If cbNewLength > RAWBUFFER_CAPACITY Then
		*ppLine = NULL
		Return HTTPREADER_E_INTERNALBUFFEROVERFLOW
	End If
	
	this->pClientBuffer->cbLength = cbNewLength
	
	Dim DoubleCrLfIndex As Integer = Any
	Dim Finded As Boolean = ClientRequestBufferFindDoubleCrLfIndexA( _
		this->pClientBuffer, _
		@DoubleCrLfIndex _
	)
	If Finded = False Then
		*ppLine = NULL
		Return HTTPREADER_S_IO_PENDING
	End If
	
	HttpReaderPrintClientBuffer(this)
	
	Dim NewEndOfHeaders As Integer = DoubleCrLfIndex + Len(DoubleNewLineStringA)
	this->pClientBuffer->EndOfHeaders = NewEndOfHeaders
	this->pClientBuffer->StartLine = 0
	this->IsAllBytesReaded = True
	
	Dim bstrLine As HeapBSTR = ClientRequestBufferGetLine( _
		this->pClientBuffer, _
		this->pIMemoryAllocator _
	)
	If bstrLine = NULL Then
		*ppLine = NULL
		Return E_OUTOFMEMORY
	End If
	
	*ppLine = bstrLine
	Return S_OK
	
End Function

Function HttpReaderClear( _
		ByVal this As HttpReader Ptr _
	)As HRESULT
	
	this->IsAllBytesReaded = False
	
	ClientRequestBufferClear(this->pClientBuffer)
	
	Return S_OK
	
End Function

Function HttpReaderSetBaseStream( _
		ByVal this As HttpReader Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pIStream Then
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
	
	Dim cbPreloadedBytes As Integer = GetPreloadedBytesLength(this->pClientBuffer)
	Dim PreloadedIndex As Integer = this->pClientBuffer->EndOfHeaders
	Dim pBytes As UByte Ptr = @this->pClientBuffer->Bytes(PreloadedIndex)
	
	*pPreloadedBytesLength = cbPreloadedBytes
	*ppPreloadedBytes = pBytes
	
	Return S_OK
	
End Function

Function HttpReaderGetRequestedBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	Dim Length As Integer = this->pClientBuffer->cbLength
	Dim pBytes As UByte Ptr = @this->pClientBuffer->Bytes(0)
	
	*pRequestedBytesLength = Length
	*ppRequestedBytes = pBytes
	
	Return S_OK
	
End Function

Function HttpReaderSetClientBuffer( _
		ByVal this As HttpReader Ptr, _
		ByVal pBuffer As ClientRequestBuffer Ptr _
	)As HRESULT
	
	this->pClientBuffer = pBuffer
	
	Return S_OK
	
End Function

Function HttpReaderSkipBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	
	Dim cbPreloadedBytes As Integer = GetPreloadedBytesLength(this->pClientBuffer)
	this->SkippedBytes = Length - CLngInt(cbPreloadedBytes)
	
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
		ByVal pLine As HeapBSTR Ptr _
	)As HRESULT
	Return HttpReaderReadLine(ContainerOf(this, HttpReader, lpVtbl), pLine)
End Function

Function IHttpReaderBeginReadLine( _
		ByVal this As IHttpReader Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpReaderBeginReadLine(ContainerOf(this, HttpReader, lpVtbl), StateObject, ppIAsyncResult)
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

Function IHttpReaderSetClientBuffer( _
		ByVal this As IHttpReader Ptr, _
		ByVal pBuffer As ClientRequestBuffer Ptr _
	)As HRESULT
	Return HttpReaderSetClientBuffer(ContainerOf(this, HttpReader, lpVtbl), pBuffer)
End Function

Function IHttpReaderSkipBytes( _
		ByVal this As IHttpReader Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	Return HttpReaderSkipBytes(ContainerOf(this, HttpReader, lpVtbl), Length)
End Function

Dim GlobalHttpReaderVirtualTable As Const IHttpReaderVirtualTable = Type( _
	@IHttpReaderQueryInterface, _
	@IHttpReaderAddRef, _
	@IHttpReaderRelease, _
	@IHttpReaderReadLine, _
	@IHttpReaderBeginReadLine, _
	@IHttpReaderEndReadLine, _
	@IHttpReaderClear, _
	@IHttpReaderSetBaseStream, _
	@IHttpReaderGetPreloadedBytes, _
	@IHttpReaderGetRequestedBytes, _
	@IHttpReaderSetClientBuffer, _
	@IHttpReaderSkipBytes _
)
