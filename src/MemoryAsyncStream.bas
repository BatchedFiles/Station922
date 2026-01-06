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
		ByVal self As MemoryStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_MEMORYSTREAM), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalMemoryStreamVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->pBuffer = NULL
	self->pOuterBuffer = NULL
	self->Capacity = 0
	self->Offset = 0
	self->ZipMode = ZipModes.None
	self->Language = NULL
	self->ETag = NULL
	self->ContentType.ContentType = ContentTypes.AnyAny
	self->ContentType.CharsetWeakPtr = NULL
	self->ContentType.Format = MimeFormats.Binary

End Sub

Private Sub UnInitializeMemoryStream( _
		ByVal self As MemoryStream Ptr _
	)

	HeapSysFreeString(self->ETag)
	HeapSysFreeString(self->Language)

	If self->pBuffer Then
		IMalloc_Free(self->pIMemoryAllocator, self->pBuffer)
	End If

End Sub

Private Sub DestroyMemoryStream( _
		ByVal self As MemoryStream Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeMemoryStream(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function MemoryStreamAddRef( _
		ByVal self As MemoryStream Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function MemoryStreamRelease( _
		ByVal self As MemoryStream Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyMemoryStream(self)

	Return 0

End Function

Private Function MemoryStreamQueryInterface( _
		ByVal self As MemoryStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IMemoryStream, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IAttributedAsyncStream, riid) Then
			*ppv = @self->lpVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @self->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If

	MemoryStreamAddRef(self)

	Return S_OK

End Function

Public Function CreateMemoryStream( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As MemoryStream Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(MemoryStream) _
	)

	If self Then
		InitializeMemoryStream(self, pIMemoryAllocator)

		Dim hrQueryInterface As HRESULT = MemoryStreamQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyMemoryStream(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function MemoryStreamBeginGetSlice( _
		ByVal self As MemoryStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim VirtualStartIndex As LongInt = StartIndex + self->Offset

	If VirtualStartIndex >= self->Capacity Then
		*ppIAsyncResult = NULL
		Return E_OUTOFMEMORY
	End If

	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Scope
		Dim hrCreateAsyncResult As HRESULT = CreateAsyncResult( _
			self->pIMemoryAllocator, _
			@IID_IAsyncResult, _
			@pINewAsyncResult _
		)
		If FAILED(hrCreateAsyncResult) Then
			*ppIAsyncResult = NULL
			Return hrCreateAsyncResult
		End If
	End Scope

	self->RequestStartIndex = StartIndex
	self->RequestLength = Length

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
		ByVal self As MemoryStream Ptr, _
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
			If self->pOuterBuffer = NULL Then
				pMem = self->pBuffer
			Else
				pMem = self->pOuterBuffer
			End If

			Dim VirtualIndex As LongInt = self->RequestStartIndex + self->Offset
			pBufferSlice->pSlice = @pMem[VirtualIndex]
			pBufferSlice->Length = CInt(dwBytesTransferred)
		End Scope

		If dwBytesTransferred = 0 Then
			Return S_FALSE
		End If

		If dwBytesTransferred <= self->Capacity Then
			Return S_FALSE
		End If

	End If

	Return S_OK

End Function

Private Function MemoryStreamGetContentType( _
		ByVal self As MemoryStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT

	CopyMemory(ppType, @self->ContentType, SizeOf(MimeType))

	Return S_OK

End Function

Private Function MemoryStreamGetEncoding( _
		ByVal self As MemoryStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT

	*pZipMode = self->ZipMode

	Return S_OK

End Function

Private Function MemoryStreamGetLanguage( _
		ByVal self As MemoryStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString(self->Language)
	*ppLanguage = self->Language

	Return S_OK

End Function

Private Function MemoryStreamGetLastFileModifiedDate( _
		ByVal self As MemoryStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT

	ZeroMemory(ppDate, SizeOf(FILETIME))

	Return S_OK

End Function

Private Function MemoryStreamGetETag( _
		ByVal self As MemoryStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT

	HeapSysAddRefString(self->ETag)
	*ppETag = self->ETag

	Return S_OK

End Function

Private Function MemoryStreamGetLength( _
		ByVal self As MemoryStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT

	Dim VirtualLength As LongInt = self->Capacity - self->Offset

	*pLength = VirtualLength

	Return S_OK

End Function

Private Function MemoryStreamGetPreloadedBytes( _
		ByVal self As MemoryStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT

	*ppPreloadedBytes = self->pOuterBuffer
	*pPreloadedBytesLength = self->Capacity

	Return S_OK

End Function

Private Function MemoryStreamSetContentType( _
		ByVal self As MemoryStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT

	CopyMemory(@self->ContentType, pType, SizeOf(MimeType))

	Return S_OK

End Function

Private Function MemoryStreamAllocBuffer( _
		ByVal self As MemoryStream Ptr, _
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
	self->pBuffer = IMalloc_Alloc( _
		self->pIMemoryAllocator, _
		CULngInt(BufferLength) _
	)
	If self->pBuffer = NULL Then
		*ppBuffer = NULL
		Return E_OUTOFMEMORY
	End If

	#if __FB_DEBUG__
		CopyMemory( _
			self->pBuffer, _
			@Str(RTTI_ID_MEMORYBODY), _
			Len(RTTI_ID_MEMORYBODY) _
		)
	#endif

	self->Capacity = BufferLength
	self->Offset = Offset

	*ppBuffer = @self->pBuffer[Offset]

	Return S_OK

End Function

Private Function MemoryStreamSetBuffer( _
		ByVal self As MemoryStream Ptr, _
		ByVal pBuffer As Any Ptr, _
		ByVal Length As LongInt _
	)As HRESULT

	self->pOuterBuffer = pBuffer
	self->Capacity = Length
	self->Offset = 0

	Return S_OK

End Function


Private Function IMemoryStreamQueryInterface( _
		ByVal self As IMemoryStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return MemoryStreamQueryInterface(CONTAINING_RECORD(self, MemoryStream, lpVtbl), riid, ppvObject)
End Function

Private Function IMemoryStreamAddRef( _
		ByVal self As IMemoryStream Ptr _
	)As ULONG
	Return MemoryStreamAddRef(CONTAINING_RECORD(self, MemoryStream, lpVtbl))
End Function

Private Function IMemoryStreamRelease( _
		ByVal self As IMemoryStream Ptr _
	)As ULONG
	Return MemoryStreamRelease(CONTAINING_RECORD(self, MemoryStream, lpVtbl))
End Function

Private Function IMemoryStreamGetContentType( _
		ByVal self As IMemoryStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	Return MemoryStreamGetContentType(CONTAINING_RECORD(self, MemoryStream, lpVtbl), ppType)
End Function

Private Function IMemoryStreamGetEncoding( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return MemoryStreamGetEncoding(CONTAINING_RECORD(self, MemoryStream, lpVtbl), pZipMode)
End Function

Private Function IMemoryStreamGetLanguage( _
		ByVal self As IMemoryStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	Return MemoryStreamGetLanguage(CONTAINING_RECORD(self, MemoryStream, lpVtbl), ppLanguage)
End Function

Private Function IMemoryStreamGetETag( _
		ByVal self As IMemoryStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	Return MemoryStreamGetETag(CONTAINING_RECORD(self, MemoryStream, lpVtbl), ppETag)
End Function

Private Function IMemoryStreamGetLastFileModifiedDate( _
		ByVal self As IMemoryStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	Return MemoryStreamGetLastFileModifiedDate(CONTAINING_RECORD(self, MemoryStream, lpVtbl), ppDate)
End Function

Private Function IMemoryStreamGetLength( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As ULONG
	Return MemoryStreamGetLength(CONTAINING_RECORD(self, MemoryStream, lpVtbl), pLength)
End Function

Private Function IMemoryStreamGetPreloadedBytes( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As ULONG
	Return MemoryStreamGetPreloadedBytes(CONTAINING_RECORD(self, MemoryStream, lpVtbl), pPreloadedBytesLength, ppPreloadedBytes)
End Function

Private Function IMemoryStreamBeginGetSlice( _
		ByVal self As IMemoryStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return MemoryStreamBeginGetSlice(CONTAINING_RECORD(self, MemoryStream, lpVtbl), StartIndex, Length, pcb, StateObject, ppIAsyncResult)
End Function

Private Function IMemoryStreamEndGetSlice( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return MemoryStreamEndGetSlice(CONTAINING_RECORD(self, MemoryStream, lpVtbl), pIAsyncResult, pBufferSlice)
End Function

Private Function IMemoryStreamSetContentType( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	Return MemoryStreamSetContentType(CONTAINING_RECORD(self, MemoryStream, lpVtbl), pType)
End Function

Private Function IMemoryStreamAllocBuffer( _
		ByVal self As IMemoryStream Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT
	Return MemoryStreamAllocBuffer(CONTAINING_RECORD(self, MemoryStream, lpVtbl), Length, ppBuffer)
End Function

Private Function IMemoryStreamSetBuffer( _
		ByVal self As IMemoryStream Ptr, _
		ByVal pBuffer As Any Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	Return MemoryStreamSetBuffer(CONTAINING_RECORD(self, MemoryStream, lpVtbl), pBuffer, Length)
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
