#include once "MemoryStream.bi"
#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"

Extern GlobalMemoryStreamVirtualTable As Const IMemoryStreamVirtualTable

Extern ThreadPoolCompletionPort As HANDLE

Type _MemoryStream
	#if __FB_DEBUG__
		IdString As ZString * 16
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
	RequestLength As DWORD
	ContentType As MimeType
End Type

Sub InitializeMemoryStream( _
		ByVal this As MemoryStream Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_MEMORYSTREAM), _
			Len(MemoryStream.IdString) _
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
	this->ContentType.Charset = DocumentCharsets.ASCII
	this->ContentType.IsTextFormat = False
	
End Sub

Sub UnInitializeMemoryStream( _
		ByVal this As MemoryStream Ptr _
	)
	
	HeapSysFreeString(this->ETag)
	HeapSysFreeString(this->Language)
	
	If this->pBuffer Then
		IMalloc_Free(this->pIMemoryAllocator, this->pBuffer)
	End If
	
End Sub

Function CreateMemoryStream( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As MemoryStream Ptr
	
	Dim this As MemoryStream Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(MemoryStream) _
	)
	
	If this Then
		
		InitializeMemoryStream( _
			this, _
			pIMemoryAllocator _
		)
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyMemoryStream( _
		ByVal this As MemoryStream Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeMemoryStream(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function MemoryStreamQueryInterface( _
		ByVal this As MemoryStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IMemoryStream, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAttributedStream, riid) Then
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

Function MemoryStreamAddRef( _
		ByVal this As MemoryStream Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function MemoryStreamRelease( _
		ByVal this As MemoryStream Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyMemoryStream(this)
	
	Return 0
	
End Function

Function MemoryStreamBeginGetSlice( _
		ByVal this As MemoryStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim VirtualStartIndex As LongInt = StartIndex + this->Offset
	
	If VirtualStartIndex >= this->Capacity Then
		*ppIAsyncResult = NULL
		Return E_OUTOFMEMORY
	End If
	
	Dim pINewAsyncResult As IAsyncResult Ptr = Any
	Scope
		Dim hrCreateAsyncResult As HRESULT = CreateInstance( _
			this->pIMemoryAllocator, _
			@CLSID_ASYNCRESULT, _
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
	
	Dim pOverlap As OVERLAPPED Ptr = Any
	IAsyncResult_GetWsaOverlapped(pINewAsyncResult, @pOverlap)
	
	IAsyncResult_SetAsyncStateWeakPtr(pINewAsyncResult, StateObject)
	
	*ppIAsyncResult = pINewAsyncResult
	
	Dim resStatus As BOOL = PostQueuedCompletionStatus( _
		ThreadPoolCompletionPort, _
		Length, _
		Cast(ULONG_PTR, StateObject), _
		pOverlap _
	)
	If resStatus = 0 Then
		Dim dwError As DWORD = GetLastError()
		IAsyncResult_Release(pINewAsyncResult)
		*ppIAsyncResult = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return ATTRIBUTEDSTREAM_S_IO_PENDING
	
End Function

Function MemoryStreamEndGetSlice( _
		ByVal this As MemoryStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	Dim dwBytesTransferred As DWORD = Any
	Dim Completed As Boolean = Any
	IAsyncResult_GetCompleted( _
		pIAsyncResult, _
		@dwBytesTransferred, _
		@Completed _
	)
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

Function MemoryStreamGetContentType( _
		ByVal this As MemoryStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	CopyMemory(ppType, @this->ContentType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function MemoryStreamGetEncoding( _
		ByVal this As MemoryStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	*pZipMode = this->ZipMode
	
	Return S_OK
	
End Function

Function MemoryStreamGetLanguage( _
		ByVal this As MemoryStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Language)
	*ppLanguage = this->Language
	
	Return S_OK
	
End Function

Function MemoryStreamGetLastFileModifiedDate( _
		ByVal this As MemoryStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	ZeroMemory(ppDate, SizeOf(FILETIME))
	
	Return S_OK
	
End Function

Function MemoryStreamGetETag( _
		ByVal this As MemoryStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->ETag)
	*ppETag = this->ETag
	
	Return S_OK
	
End Function

Function MemoryStreamGetLength( _
		ByVal this As MemoryStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	Dim VirtualLength As LongInt = this->Capacity - this->Offset
	
	*pLength = VirtualLength
	
	Return S_OK
	
End Function

Function MemoryStreamSetContentType( _
		ByVal this As MemoryStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	CopyMemory(@this->ContentType, pType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function MemoryStreamAllocBuffer( _
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
	this->OffSet = Offset
	
	*ppBuffer = @this->pBuffer[Offset]
	
	Return S_OK
	
End Function

Function MemoryStreamSetBuffer( _
		ByVal this As MemoryStream Ptr, _
		ByVal pBuffer As Any Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	
	this->pOuterBuffer = pBuffer
	this->Capacity = Length 
	this->OffSet = 0
	
	Return S_OK
	
End Function


Function IMemoryStreamQueryInterface( _
		ByVal this As IMemoryStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return MemoryStreamQueryInterface(ContainerOf(this, MemoryStream, lpVtbl), riid, ppvObject)
End Function

Function IMemoryStreamAddRef( _
		ByVal this As IMemoryStream Ptr _
	)As ULONG
	Return MemoryStreamAddRef(ContainerOf(this, MemoryStream, lpVtbl))
End Function

Function IMemoryStreamRelease( _
		ByVal this As IMemoryStream Ptr _
	)As ULONG
	Return MemoryStreamRelease(ContainerOf(this, MemoryStream, lpVtbl))
End Function

Function IMemoryStreamGetContentType( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	Return MemoryStreamGetContentType(ContainerOf(this, MemoryStream, lpVtbl), ppType)
End Function

Function IMemoryStreamGetEncoding( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return MemoryStreamGetEncoding(ContainerOf(this, MemoryStream, lpVtbl), pZipMode)
End Function

Function IMemoryStreamGetLanguage( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	Return MemoryStreamGetLanguage(ContainerOf(this, MemoryStream, lpVtbl), ppLanguage)
End Function

Function IMemoryStreamGetETag( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	Return MemoryStreamGetETag(ContainerOf(this, MemoryStream, lpVtbl), ppETag)
End Function

Function IMemoryStreamGetLastFileModifiedDate( _
		ByVal this As IMemoryStream Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	Return MemoryStreamGetLastFileModifiedDate(ContainerOf(this, MemoryStream, lpVtbl), ppDate)
End Function

Function IMemoryStreamGetLength( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pLength As LongInt Ptr _
	)As ULONG
	Return MemoryStreamGetLength(ContainerOf(this, MemoryStream, lpVtbl), pLength)
End Function

Function IMemoryStreamBeginGetSlice( _
		ByVal this As IMemoryStream Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return MemoryStreamBeginGetSlice(ContainerOf(this, MemoryStream, lpVtbl), StartIndex, Length, StateObject, ppIAsyncResult)
End Function

Function IMemoryStreamEndGetSlice( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return MemoryStreamEndGetSlice(ContainerOf(this, MemoryStream, lpVtbl), pIAsyncResult, pBufferSlice)
End Function

Function IMemoryStreamSetContentType( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	Return MemoryStreamSetContentType(ContainerOf(this, MemoryStream, lpVtbl), pType)
End Function

Function IMemoryStreamAllocBuffer( _
		ByVal this As IMemoryStream Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT
	Return MemoryStreamAllocBuffer(ContainerOf(this, MemoryStream, lpVtbl), Length, ppBuffer)
End Function

Function IMemoryStreamSetBuffer( _
		ByVal this As IMemoryStream Ptr, _
		ByVal pBuffer As Any Ptr, _
		ByVal Length As LongInt _
	)As HRESULT
	Return MemoryStreamSetBuffer(ContainerOf(this, MemoryStream, lpVtbl), pBuffer, Length)
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
	@IMemoryStreamSetContentType, _
	@IMemoryStreamAllocBuffer, _
	@IMemoryStreamSetBuffer _
)