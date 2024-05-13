#include once "HttpAsyncReader.bi"
#include once "Http.bi"
#include once "HeapBSTR.bi"
#include once "IObjectPool.bi"

Extern GlobalHttpReaderVirtualTable As Const IHttpAsyncReaderVirtualTable

Const DoubleNewLineStringA = Str(!"\r\n\r\n")
Const NewLineStringA = Str(!"\r\n")

Const MEMORYPAGE_SIZE = 4096

Const RAWBUFFER_MEMORYPAGE_COUNT = 4

Const OBJECT_POOL_CAPACITY = 1
Const HTTPREADER_POOL_ID = 0

#if __FB_DEBUG__
Const RAWBUFFER_CAPACITY = (RAWBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) - (4 * SizeOf(Integer)) - SizeOf(ZString) * 16
#else
Const RAWBUFFER_CAPACITY = (RAWBUFFER_MEMORYPAGE_COUNT * MEMORYPAGE_SIZE) - (4 * SizeOf(Integer))
#endif

Type ClientRequestBuffer
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	cbLength As Integer
	EndOfHeaders As Integer
	StartLine As Integer
	Padding1 As Integer
	Bytes(0 To RAWBUFFER_CAPACITY - 1) As UByte
End Type

Type HttpReader
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHttpAsyncReaderVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseAsyncStream Ptr
	pClientBuffer As ClientRequestBuffer Ptr
	SkippedBytes As LongInt
	IsAllBytesReaded As Boolean
End Type

Enum PoolItemStatuses
	ItemUsed = -1
	ItemFree = 0
End Enum

Type ObjectPoolItem
	pItem As HttpReader Ptr
	ItemStatus As PoolItemStatuses
End Type

Type ObjectPool
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	Capacity As Integer
	Length As Integer
	Items(0 To (OBJECT_POOL_CAPACITY - 1)) As ObjectPoolItem
End Type

Private Sub InitializeClientRequestBuffer( _
		ByVal this As ClientRequestBuffer Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_CLIENTREQUESTBUFFER), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->cbLength = 0
	this->EndOfHeaders = 0

	' No Need ZeroMemory StartLine
	' No Need ZeroMemory this.Bytes

End Sub

Private Function ClientRequestBufferGetFreeSpaceLength( _
		ByVal this As ClientRequestBuffer Ptr _
	)As Integer

	Dim FreeSpace As Integer = RAWBUFFER_CAPACITY - this->cbLength

	Return FreeSpace

End Function

Private Function FindStringA( _
		ByVal buffer As UByte Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pStr As UByte Ptr, _
		ByVal Length As Integer _
	)As UByte Ptr

	Dim BytesCount As Integer = Length * SizeOf(UByte)

	For i As Integer = 0 To BufferLength - Length
		Dim pDestination As UByte Ptr = @buffer[i]
		Dim Finded As Long = memcmp( _
			pDestination, _
			pStr, _
			BytesCount _
		)
		If Finded = 0 Then
			Return pDestination
		End If
	Next

	Return NULL

End Function

Private Function ClientRequestBufferFindDoubleCrLfIndexA( _
		ByVal this As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean

	Dim pDoubleCrLf As UByte Ptr = FindStringA( _
		@this->Bytes(0), _
		this->cbLength, _
		@DoubleNewLineStringA, _
		Len(DoubleNewLineStringA) _
	)
	If pDoubleCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If

	Dim FindIndex As Integer = pDoubleCrLf - @this->Bytes(0)
	*pFindIndex = FindIndex

	Return True

End Function

Private Function ClientRequestBufferFindCrLfIndexA( _
		ByVal this As ClientRequestBuffer Ptr, _
		ByVal pFindIndex As Integer Ptr _
	)As Boolean

	Dim pCrLf As UByte Ptr = FindStringA( _
		@this->Bytes(this->StartLine), _
		this->EndOfHeaders, _
		@NewLineStringA, _
		Len(NewLineStringA) _
	)
	If pCrLf = NULL Then
		*pFindIndex = 0
		Return False
	End If

	Dim FindIndex As Integer = pCrLf - @this->Bytes(this->StartLine)
	*pFindIndex = FindIndex

	Return True

End Function

Private Function ClientRequestBufferGetLine( _
		ByVal this As ClientRequestBuffer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HeapBSTR

	Dim CrLfIndex As Integer = Any
	Dim Finded As Boolean = ClientRequestBufferFindCrLfIndexA( _
		this, _
		@CrLfIndex _
	)
	If Finded = False Then
		Return NULL
	End If

	' TODO Проверить, начинается ли строка за CrLf с пробела
	' Если начинается — объединить обе строки

	Dim LineLength As Integer = CrLfIndex
	Dim StartLineIndex As Integer = this->StartLine

	Dim bstrLine As HeapBSTR = CreateHeapZStringLen( _
		pIMemoryAllocator, _
		@this->Bytes(StartLineIndex), _
		LineLength _
	)
	If bstrLine = NULL Then
		Return NULL
	End If

	Dim NewStartIndex As Integer = StartLineIndex + LineLength + Len(NewLineStringA)
	this->StartLine = NewStartIndex

	Return bstrLine

End Function

Private Sub ClientRequestBufferClear( _
		ByVal this As ClientRequestBuffer Ptr _
	)

	this->cbLength = 0
	this->EndOfHeaders = 0

End Sub

Private Function GetPreloadedBytesLength( _
		ByVal pClientBuffer As ClientRequestBuffer Ptr _
	)As Integer

	Dim cbPreloadedBytes As Integer = pClientBuffer->cbLength - pClientBuffer->EndOfHeaders

	Return cbPreloadedBytes

End Function

Private Sub InitializeHttpReader( _
		ByVal this As HttpReader Ptr, _
		ByVal pClientBuffer As ClientRequestBuffer Ptr _
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
	this->pIStream = NULL
	InitializeClientRequestBuffer(pClientBuffer)
	this->pClientBuffer = pClientBuffer
	this->SkippedBytes = 0
	this->IsAllBytesReaded = False

End Sub

Private Sub UnInitializeHttpReader( _
		ByVal this As HttpReader Ptr _
	)

	If this->pIStream Then
		IBaseAsyncStream_Release(this->pIStream)
		' Pointer must be zeroed to avoid double free memory
		this->pIStream = NULL
	End If

End Sub

Private Sub DestroyHttpReader( _
		ByVal this As HttpReader Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeHttpReader(this)

	IMalloc_Free(pIMemoryAllocator, this->pClientBuffer)
	IMalloc_Free(pIMemoryAllocator, this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Sub HttpReaderResetState( _
		ByVal this As HttpReader Ptr _
	)

	IMalloc_Release(this->pIMemoryAllocator)
	' Pointer must be zeroed to avoid double free memory
	this->pIStream = NULL

	InitializeClientRequestBuffer(this->pClientBuffer)

End Sub

Private Sub HttpReaderReturnToPool( _
		ByVal this As HttpReader Ptr _
	)

	Dim pool As ObjectPool Ptr = Any
	Scope
		Dim pPool As IObjectPool Ptr = Any
		Dim hrQueryInterface As HRESULT = IMalloc_QueryInterface( _
			this->pIMemoryAllocator, _
			@IID_IObjectPool, _
			@pPool _
		)
		If FAILED(hrQueryInterface) Then
			Exit Sub
		End If

		IObjectPool_GetPool(pPool, HTTPREADER_POOL_ID, @pool)

		IObjectPool_Release(pPool)
	End Scope

	For i As Integer = 0 To OBJECT_POOL_CAPACITY - 1
		If pool->Items(i).ItemStatus = PoolItemStatuses.ItemUsed Then
			Dim this As HttpReader Ptr = pool->Items(i).pItem

			UnInitializeHttpReader(this)
			HttpReaderResetState(this)

			pool->Length -= 1
			pool->Items(i).ItemStatus = PoolItemStatuses.ItemFree

			Exit Sub
		End If
	Next

End Sub

Private Function HttpReaderAddRef( _
		ByVal this As HttpReader Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function HttpReaderRelease( _
		ByVal this As HttpReader Ptr _
	)As ULONG

	this->ReferenceCounter -= 1

	If this->ReferenceCounter Then
		Return 1
	End If

	' Do not delete object
	' Only mark that object is free and return to pool
	HttpReaderReturnToPool(this)

	Return 0

End Function

Private Function HttpReaderQueryInterface( _
		ByVal this As HttpReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IHttpAsyncReader, riid) Then
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

Private Function CreateHttpReader_Internal( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As HttpReader Ptr

	Dim this As HttpReader Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(HttpReader) _
	)

	If this Then
		Dim pClientBuffer As ClientRequestBuffer Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(ClientRequestBuffer) _
		)

		If pClientBuffer Then
			InitializeHttpReader(this, pClientBuffer)
			Return this
		End If

		IMalloc_Free(pIMemoryAllocator, this)
	End If

	Return NULL

End Function

Public Function CreateHttpReader( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim pool As ObjectPool Ptr = Any
	Scope
		Dim pPool As IObjectPool Ptr = Any
		Dim hrQueryInterface As HRESULT = IMalloc_QueryInterface( _
			pIMemoryAllocator, _
			@IID_IObjectPool, _
			@pPool _
		)
		If FAILED(hrQueryInterface) Then
			Return hrQueryInterface
		End If

		IObjectPool_GetPool(pPool, HTTPREADER_POOL_ID, @pool)

		IObjectPool_Release(pPool)
	End Scope

	For i As Integer = 0 To OBJECT_POOL_CAPACITY - 1
		If pool->Items(i).ItemStatus = PoolItemStatuses.ItemFree Then
			pool->Items(i).ItemStatus = PoolItemStatuses.ItemUsed
			pool->Length += 1

			Dim this As HttpReader Ptr = pool->Items(i).pItem

			Dim hrQueryInterface As HRESULT = HttpReaderQueryInterface( _
				this, _
				riid, _
				ppv _
			)
			If FAILED(hrQueryInterface) Then
				pool->Length -= 1
				pool->Items(i).ItemStatus = PoolItemStatuses.ItemFree
				*ppv = NULL
				Return hrQueryInterface
			End If

			IMalloc_AddRef(pIMemoryAllocator)
			this->pIMemoryAllocator = pIMemoryAllocator

			Return S_OK
		End If
	Next

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function HttpReaderReadLine( _
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

Private Function HttpReaderBeginReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
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
		Dim hrBeginRead As HRESULT = IBaseAsyncStream_BeginRead( _
			this->pIStream, _
			lpFreeSpace, _
			cbFreeSpace, _
			pcb, _
			StateObject, _
			ppIAsyncResult _
		)
		If FAILED(hrBeginRead) Then
			Return hrBeginRead
		End If

	End If

	Return HTTPREADER_S_IO_PENDING

End Function

Private Sub HttpReaderPrintClientBuffer( _
		ByVal this As HttpReader Ptr _
	)

End Sub

Private Function HttpReaderEndReadLine( _
		ByVal this As HttpReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT

	Dim cbReceived As DWORD = Any

	Scope
		Dim hrRead As HRESULT = IBaseAsyncStream_EndRead( _
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

Private Function HttpReaderClear( _
		ByVal this As HttpReader Ptr _
	)As HRESULT

	this->IsAllBytesReaded = False

	ClientRequestBufferClear(this->pClientBuffer)

	Return S_OK

End Function

Private Function HttpReaderSetBaseStream( _
		ByVal this As HttpReader Ptr, _
		ByVal pIStream As IBaseAsyncStream Ptr _
	)As HRESULT

	If this->pIStream Then
		IBaseAsyncStream_Release(this->pIStream)
	End If

	If pIStream Then
		IBaseAsyncStream_AddRef(pIStream)
	End If

	this->pIStream = pIStream

	Return S_OK

End Function

Private Function HttpReaderGetPreloadedBytes( _
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

Private Function HttpReaderGetRequestedBytes( _
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

Private Function HttpReaderSkipBytes( _
		ByVal this As HttpReader Ptr, _
		ByVal Length As LongInt _
	)As HRESULT

	Dim cbPreloadedBytes As Integer = GetPreloadedBytesLength(this->pClientBuffer)
	this->SkippedBytes = Length - CLngInt(cbPreloadedBytes)

	Return S_OK

End Function


Public Function CreateHttpReaderPool( _
		pMalloc As IMalloc Ptr _
	)As HRESULT

	Const RTTI_ID_OBJECTPOOL = !"\001Pool____Reader\001"

	Dim pool As ObjectPool Ptr = IMalloc_Alloc( _
		pMalloc, _
		SizeOf(ObjectPool) _
	)
	If pool = NULL Then
		Return E_OUTOFMEMORY
	End If

	#if __FB_DEBUG__
		CopyMemory( _
			@pool->RttiClassName(0), _
			@Str(RTTI_ID_OBJECTPOOL), _
			UBound(pool->RttiClassName) - LBound(pool->RttiClassName) + 1 _
		)
	#endif

	pool->Capacity = OBJECT_POOL_CAPACITY
	pool->Length = 0

	For i As Integer = 0 To OBJECT_POOL_CAPACITY - 1
		pool->Items(i).pItem = CreateHttpReader_Internal(pMalloc)

		If pool->Items(i).pItem = NULL Then
			Return E_OUTOFMEMORY
		End If

		pool->Items(i).ItemStatus = PoolItemStatuses.ItemFree
	Next

	Scope
		Dim pPool As IObjectPool Ptr = Any
		Dim hrQueryInterface As HRESULT = IMalloc_QueryInterface( _
			pMalloc, _
			@IID_IObjectPool, _
			@pPool _
		)
		If FAILED(hrQueryInterface) Then
			Return hrQueryInterface
		End If

		IObjectPool_SetPool(pPool, HTTPREADER_POOL_ID, pool)

		IObjectPool_Release(pPool)
	End Scope

	Return S_OK

End Function

Public Sub DeleteHttpReaderPool( _
		pMalloc As IMalloc Ptr _
	)

End Sub


Private Function IHttpAsyncReaderQueryInterface( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HttpReaderQueryInterface(CONTAINING_RECORD(this, HttpReader, lpVtbl), riid, ppvObject)
End Function

Private Function IHttpAsyncReaderAddRef( _
		ByVal this As IHttpAsyncReader Ptr _
	)As ULONG
	Return HttpReaderAddRef(CONTAINING_RECORD(this, HttpReader, lpVtbl))
End Function

Private Function IHttpAsyncReaderRelease( _
		ByVal this As IHttpAsyncReader Ptr _
	)As ULONG
	Return HttpReaderRelease(CONTAINING_RECORD(this, HttpReader, lpVtbl))
End Function

Private Function IHttpAsyncReaderReadLine( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pLine As HeapBSTR Ptr _
	)As HRESULT
	Return HttpReaderReadLine(CONTAINING_RECORD(this, HttpReader, lpVtbl), pLine)
End Function

Private Function IHttpAsyncReaderBeginReadLine( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return HttpReaderBeginReadLine(CONTAINING_RECORD(this, HttpReader, lpVtbl), pcb, StateObject, ppIAsyncResult)
End Function

Private Function IHttpAsyncReaderEndReadLine( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal ppLine As HeapBSTR Ptr _
	)As HRESULT
	Return HttpReaderEndReadLine(CONTAINING_RECORD(this, HttpReader, lpVtbl), pIAsyncResult, ppLine)
End Function

Private Function IHttpAsyncReaderClear( _
		ByVal this As IHttpAsyncReader Ptr _
	)As HRESULT
	Return HttpReaderClear(CONTAINING_RECORD(this, HttpReader, lpVtbl))
End Function

Private Function IHttpAsyncReaderSetBaseStream( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pIStream As IBaseAsyncStream Ptr _
	)As HRESULT
	Return HttpReaderSetBaseStream(CONTAINING_RECORD(this, HttpReader, lpVtbl), pIStream)
End Function

Private Function IHttpAsyncReaderGetPreloadedBytes( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return HttpReaderGetPreloadedBytes(CONTAINING_RECORD(this, HttpReader, lpVtbl), pPreloadedBytesLength, ppPreloadedBytes)
End Function

Private Function IHttpAsyncReaderGetRequestedBytes( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	Return HttpReaderGetRequestedBytes(CONTAINING_RECORD(this, HttpReader, lpVtbl), pRequestedBytesLength, ppRequestedBytes)
End Function

Private Function IHttpAsyncReaderSkipBytes( _
		ByVal this As IHttpAsyncReader Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	Return HttpReaderSkipBytes(CONTAINING_RECORD(this, HttpReader, lpVtbl), Length)
End Function

Dim GlobalHttpReaderVirtualTable As Const IHttpAsyncReaderVirtualTable = Type( _
	@IHttpAsyncReaderQueryInterface, _
	@IHttpAsyncReaderAddRef, _
	@IHttpAsyncReaderRelease, _
	@IHttpAsyncReaderReadLine, _
	@IHttpAsyncReaderBeginReadLine, _
	@IHttpAsyncReaderEndReadLine, _
	@IHttpAsyncReaderClear, _
	@IHttpAsyncReaderSetBaseStream, _
	@IHttpAsyncReaderGetPreloadedBytes, _
	@IHttpAsyncReaderGetRequestedBytes, _
	@IHttpAsyncReaderSkipBytes _
)
