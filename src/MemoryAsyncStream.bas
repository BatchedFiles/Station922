#include once "MemoryAsyncStream.bi"
#include once "AsyncResult.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"

Extern GlobalMemoryStreamVirtualTable As Const IMemoryStreamVirtualTable

Type MemoryStream
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IMemoryStreamVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pBuffer As Byte Ptr
	Capacity As LongInt
	Offset As LongInt
	RequestStartIndex As LongInt
	pOuterBuffer As Byte Ptr
	Language As HeapBSTR
	ETag As HeapBSTR
	ZipMode As ZipModes
	ContentType As MimeType
	RequestLength As DWORD
End Type

Private Sub InitializeMemoryStream( _
		ByVal this As MemoryStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_MEMORYSTREAM), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalMemoryStreamVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pBuffer = NULL
	this->pOuterBuffer = NULL
	this->Capacity = 0
	this->Offset = 0
	this->ZipMode = ZipModes.None
	this->Language = NULL
	this->ETag = NULL
	this->ContentType.ContentType = ContentTypes.AnyAny
	this->ContentType.CharsetWeakPtr = NULL
	this->ContentType.Format = MimeFormats.Binary

End Sub

Private Sub UnInitializeMemoryStream( _
		ByVal this As MemoryStream Ptr _
	)

	HeapSysFreeString(this->ETag)
	HeapSysFreeString(this->Language)

	If this->pBuffer Then
		IMalloc_Free(this->pIMemoryAllocator, this->pBuffer)
	End If

End Sub

Private Sub MemoryStreamCreated( _
		ByVal this As MemoryStream Ptr _
	)

End Sub

Private Sub MemoryStreamDestroyed( _
		ByVal this As MemoryStream Ptr _
	)

End Sub

Private Sub DestroyMemoryStream( _
		ByVal this As MemoryStream Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeMemoryStream(this)

	IMalloc_Free(pIMemoryAllocator, this)

	MemoryStreamDestroyed(this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function MemoryStreamAddRef( _
		ByVal this As MemoryStream Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function MemoryStreamRelease( _
		ByVal this As MemoryStream Ptr _
	)As ULONG

	this->ReferenceCounter -= 1

	If this->ReferenceCounter Then
		Return 1
	End If

	DestroyMemoryStream(this)

	Return 0

End Function

Private Function MemoryStreamQueryInterface( _
		ByVal this As MemoryStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IMemoryStream, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAttributedAsyncStream, riid) Then
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

	MemoryStreamAddRef(this)

	Return S_OK

End Function

Public Function CreateMemoryStream( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim this As MemoryStream Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(MemoryStream) _
	)

	If this Then
		InitializeMemoryStream(this, pIMemoryAllocator)
		MemoryStreamCreated(this)

		Dim hrQueryInterface As HRESULT = MemoryStreamQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyMemoryStream(this)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function MemoryStreamBeginGetSlice( _
		ByVal this As MemoryStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim VirtualStartIndex As LongInt = StartIndex + this->Offset

	If VirtualStartIndex >= this->Capacity Then
		*ppIAsyncResult = NULL
		Return E_OUTOFMEMORY
	End If

	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Scope
		Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
			this->pIMemoryAllocator, _
			@IID_IAsyncResult, _
			@pINewAsyncResult _
		)
		If FAILED(hrCreateAsyncResult) Then
			*ppIAsyncResult = NULL
			Return hrCreateAsyncResult
		End If
	End Scope

	this->RequestStartIndex = StartIndex
	this->RequestLength = Length

	IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, pcb, StateObject)

	*ppIAsyncResult = pINewAsyncResult

	Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
	Dim hrStatus As HRESULT = IThreadPool_PostPacket( _
		pIPool, _
		Length, _
		Cast(ULONG_PTR, StateObject), _
		pINewAsyncResult _
	)
	If FAILED(hrStatus) Then
		IAsyncResult_Release(pINewAsyncResult)
		*ppIAsyncResult = NULL
		Return hrStatus
	End If

	Return ATTRIBUTEDSTREAM_S_IO_PENDING

End Function

Private Function MemoryStreamEndGetSlice( _
		ByVal this As MemoryStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT

	Dim dwBytesTransferred As DWORD = Any
	Dim Completed As Boolean = Any
	Dim dwError As DWORD = Any
	IAsyncResult_GetCompleted( _
		pIAsyncResult, _
		@dwBytesTransferred, _
		@Completed, _
		@dwError _
	)
	If dwError Then
		Return HRESULT_FROM_WIN32(dwError)
	End If

	If Completed Then
		Scope
			Dim pMem As Byte Ptr = Any
			If this->pOuterBuffer = NULL Then
				pMem = this->pBuffer
			Else
				pMem = this->pOuterBuffer
			End If

			Dim VirtualIndex As LongInt = this->RequestStartIndex + this->Offset
			pBufferSlice->pSlice = @pMem[VirtualIndex]
			pBufferSlice->Length = CInt(dwBytesTransferred)
		End Scope

		If dwBytesTransferred = 0 Then
			Return S_FALSE
		End If

		If dwBytesTransferred <= this->Capacity Then
			Return S_FALSE
		End If

	End If

	Return S_OK

End Function

Private Function MemoryStreamGetContentType( _
		ByVal this As MemoryStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT

	CopyMemory(ppType, @this->ContentType, SizeOf(MimeType))

	Return S_OK

End Function

Private Function MemoryStreamGetEncoding( _
		ByVal this As MemoryStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	*pZipMode = this->ZipMode

	Return S_OK

End Function

Private Function MemoryStreamGetLanguage( _
		ByVal this As MemoryStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString(this->Language)
	*ppLanguage = this->Language

	Return S_OK

End Function

Private Function MemoryStreamGetLastFileModifiedDate( _
		ByVal this As MemoryStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT

	ZeroMemory(ppDate, SizeOf(FILETIME))

	Return S_OK

End Function

Private Function MemoryStreamGetETag( _
		ByVal this As MemoryStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString(this->ETag)
	*ppETag = this->ETag

	Return S_OK

End Function

Private Function MemoryStreamGetLength( _
		ByVal this As MemoryStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	Dim VirtualLength As LongInt = this->Capacity - this->Offset

	*pLength = VirtualLength

	Return S_OK

End Function

Private Function MemoryStreamGetPreloadedBytes( _
		ByVal this As MemoryStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

	*ppPreloadedBytes = this->pOuterBuffer
	*pPreloadedBytesLength = this->Capacity

	Return S_OK

End Function

Private Function MemoryStreamSetContentType( _
		ByVal this As MemoryStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT

	CopyMemory(@this->ContentType, pType, SizeOf(MimeType))

	Return S_OK

End Function

Private Function MemoryStreamAllocBuffer( _
		ByVal this As MemoryStream Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT

	Dim Offset As LongInt = Any
	#if __FB_DEBUG__
		Offset = Len(RTTI_ID_MEMORYBODY)
	#else
		Offset = 0
	#endif

	Dim BufferLength As LongInt = Length + Offset
	this->pBuffer = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		CULngInt(BufferLength) _
	)
	If this->pBuffer = NULL Then
		*ppBuffer = NULL
		Return E_OUTOFMEMORY
	End If

	#if __FB_DEBUG__
		CopyMemory( _
			this->pBuffer, _
			@Str(RTTI_ID_MEMORYBODY), _
			Len(RTTI_ID_MEMORYBODY) _
		)
	#endif

	this->Capacity = BufferLength
	this->Offset = Offset

	*ppBuffer = @this->pBuffer[Offset]

	Return S_OK

End Function

Private Function MemoryStreamSetBuffer( _
		ByVal this As MemoryStream Ptr, _
		ByVal pBuffer As Any Ptr, _
		ByVal Length As LongInt _
	)As HRESULT

	this->pOuterBuffer = pBuffer
	this->Capacity = Length
	this->Offset = 0

	Return S_OK

End Function


Private Function IMemoryStreamQueryInterface( _
		ByVal this As IMemoryStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return MemoryStreamQueryInterface(CONTAINING_RECORD(this, MemoryStream, lpVtbl), riid, ppvObject)
End Function

Private Function IMemoryStreamAddRef( _
		ByVal this As IMemoryStream Ptr _
	)As ULONG
	Return MemoryStreamAddRef(CONTAINING_RECORD(this, MemoryStream, lpVtbl))
End Function

Private Function IMemoryStreamRelease( _
		ByVal this As IMemoryStream Ptr _
	)As ULONG
	Return MemoryStreamRelease(CONTAINING_RECORD(this, MemoryStream, lpVtbl))
End Function

Private Function IMemoryStreamGetContentType( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	Return MemoryStreamGetContentType(CONTAINING_RECORD(this, MemoryStream, lpVtbl), ppType)
End Function

Private Function IMemoryStreamGetEncoding( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return MemoryStreamGetEncoding(CONTAINING_RECORD(this, MemoryStream, lpVtbl), pZipMode)
End Function

Private Function IMemoryStreamGetLanguage( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	Return MemoryStreamGetLanguage(CONTAINING_RECORD(this, MemoryStream, lpVtbl), ppLanguage)
End Function

Private Function IMemoryStreamGetETag( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	Return MemoryStreamGetETag(CONTAINING_RECORD(this, MemoryStream, lpVtbl), ppETag)
End Function

Private Function IMemoryStreamGetLastFileModifiedDate( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	Return MemoryStreamGetLastFileModifiedDate(CONTAINING_RECORD(this, MemoryStream, lpVtbl), ppDate)
End Function

Private Function IMemoryStreamGetLength( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As ULONG
	Return MemoryStreamGetLength(CONTAINING_RECORD(this, MemoryStream, lpVtbl), pLength)
End Function

Private Function IMemoryStreamGetPreloadedBytes( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As ULONG
	Return MemoryStreamGetPreloadedBytes(CONTAINING_RECORD(this, MemoryStream, lpVtbl), pPreloadedBytesLength, ppPreloadedBytes)
End Function

Private Function IMemoryStreamBeginGetSlice( _
		ByVal this As IMemoryStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return MemoryStreamBeginGetSlice(CONTAINING_RECORD(this, MemoryStream, lpVtbl), StartIndex, Length, pcb, StateObject, ppIAsyncResult)
End Function

Private Function IMemoryStreamEndGetSlice( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return MemoryStreamEndGetSlice(CONTAINING_RECORD(this, MemoryStream, lpVtbl), pIAsyncResult, pBufferSlice)
End Function

Private Function IMemoryStreamSetContentType( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	Return MemoryStreamSetContentType(CONTAINING_RECORD(this, MemoryStream, lpVtbl), pType)
End Function

Private Function IMemoryStreamAllocBuffer( _
		ByVal this As IMemoryStream Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT
	Return MemoryStreamAllocBuffer(CONTAINING_RECORD(this, MemoryStream, lpVtbl), Length, ppBuffer)
End Function

Private Function IMemoryStreamSetBuffer( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pBuffer As Any Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	Return MemoryStreamSetBuffer(CONTAINING_RECORD(this, MemoryStream, lpVtbl), pBuffer, Length)
End Function

Dim GlobalMemoryStreamVirtualTable As Const IMemoryStreamVirtualTable = Type( _
	@IMemoryStreamQueryInterface, _
	@IMemoryStreamAddRef, _
	@IMemoryStreamRelease, _
	@IMemoryStreamBeginGetSlice, _
	@IMemoryStreamEndGetSlice, _
	@IMemoryStreamGetContentType, _
	@IMemoryStreamGetEncoding, _
	@IMemoryStreamGetLanguage, _
	@IMemoryStreamGetETag, _
	@IMemoryStreamGetLastFileModifiedDate, _
	@IMemoryStreamGetLength, _
	@IMemoryStreamGetPreloadedBytes, _
	@IMemoryStreamSetContentType, _
	@IMemoryStreamAllocBuffer, _
	@IMemoryStreamSetBuffer _
)
