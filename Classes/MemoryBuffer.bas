#include once "MemoryBuffer.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"

Extern GlobalMemoryBufferVirtualTable As Const IMemoryBufferVirtualTable

Type _MemoryBuffer
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IMemoryBufferVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pBuffer As Byte Ptr
	Capacity As LongInt
	Offset As LongInt
	ZipMode As ZipModes
	Language As HeapBSTR
	ETag As HeapBSTR
	ContentType As MimeType
End Type

Sub InitializeMemoryBuffer( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("Memory____Buffer"), 16)
	#endif
	this->lpVtbl = @GlobalMemoryBufferVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pBuffer = NULL
	this->Capacity = 0
	this->Offset = 0
	this->ZipMode = ZipModes.None
	this->Language = NULL
	this->ETag = NULL
	this->ContentType.ContentType = ContentTypes.AnyAny
	this->ContentType.Charset = DocumentCharsets.ASCII
	this->ContentType.IsTextFormat = False
	
End Sub

Sub UnInitializeMemoryBuffer( _
		ByVal this As MemoryBuffer Ptr _
	)
	
	HeapSysFreeString(this->ETag)
	HeapSysFreeString(this->Language)
	
	If this->pBuffer <> NULL Then
		IMalloc_Free(this->pIMemoryAllocator, this->pBuffer)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateMemoryBuffer( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As MemoryBuffer Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(MemoryBuffer)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"MemoryBuffer creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As MemoryBuffer Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(MemoryBuffer) _
	)
	
	If this <> NULL Then
		
		InitializeMemoryBuffer( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("MemoryBuffer created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyMemoryBuffer( _
		ByVal this As MemoryBuffer Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("MemoryBuffer destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeMemoryBuffer(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("MemoryBuffer destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function MemoryBufferQueryInterface( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IMemoryBuffer, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IBuffer, riid) Then
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
	
	MemoryBufferAddRef(this)
	
	Return S_OK
	
End Function

Function MemoryBufferAddRef( _
		ByVal this As MemoryBuffer Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function MemoryBufferRelease( _
		ByVal this As MemoryBuffer Ptr _
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
	
	DestroyMemoryBuffer(this)
	
	Return 0
	
End Function

Function MemoryBufferGetContentType( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	
	memcpy(ppType, @this->ContentType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function MemoryBufferGetEncoding( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	*pZipMode = this->ZipMode
	
	Return S_OK
	
End Function

Function MemoryBufferGetLanguage( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->Language)
	*ppLanguage = this->Language
	
	Return S_OK
	
End Function

Function MemoryBufferGetLastFileModifiedDate( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	
	ZeroMemory(ppDate, SizeOf(FILETIME))
	
	Return S_OK
	
End Function

Function MemoryBufferGetETag( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->ETag)
	*ppETag = this->ETag
	
	Return S_OK
	
End Function

Function MemoryBufferGetLength( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	*pLength = this->Capacity
	
	Return S_OK
	
End Function

Function MemoryBufferSetByteRange( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	
	this->Capacity = max(this->Capacity, Length)
	this->Offset = Offset
	
	Return S_OK
	
End Function

Function MemoryBufferGetSlice( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	Dim VirtualIndex As LongInt = StartIndex + this->Offset
	
	If VirtualIndex > this->Capacity Then
		Return E_OUTOFMEMORY
	End If
	
	pBufferSlice->pSlice = @this->pBuffer[VirtualIndex]
	pBufferSlice->Length = this->Capacity - StartIndex
	
	If pBufferSlice->Length <= this->Capacity Then
		Return S_FALSE
	End If
	
	Return S_OK
	
End Function

Function MemoryBufferSetContentType( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	
	memcpy(@this->ContentType, pType, SizeOf(MimeType))
	
	Return S_OK
	
End Function

Function MemoryBufferAllocBuffer( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT
	
	this->pBuffer = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		Length _
	)
	If this->pBuffer = NULL Then
		*ppBuffer = NULL
		Return E_OUTOFMEMORY
	End If
	
	this->Capacity = Length
	*ppBuffer = this->pBuffer
	
	Return S_OK
	
End Function


Function IMemoryBufferQueryInterface( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return MemoryBufferQueryInterface(ContainerOf(this, MemoryBuffer, lpVtbl), riid, ppvObject)
End Function

Function IMemoryBufferAddRef( _
		ByVal this As IMemoryBuffer Ptr _
	)As ULONG
	Return MemoryBufferAddRef(ContainerOf(this, MemoryBuffer, lpVtbl))
End Function

Function IMemoryBufferRelease( _
		ByVal this As IMemoryBuffer Ptr _
	)As ULONG
	Return MemoryBufferRelease(ContainerOf(this, MemoryBuffer, lpVtbl))
End Function

Function IMemoryBufferGetContentType( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppType As MimeType Ptr _
	)As HRESULT
	Return MemoryBufferGetContentType(ContainerOf(this, MemoryBuffer, lpVtbl), ppType)
End Function

Function IMemoryBufferGetEncoding( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return MemoryBufferGetEncoding(ContainerOf(this, MemoryBuffer, lpVtbl), pZipMode)
End Function

Function IMemoryBufferGetLanguage( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppLanguage As HeapBSTR Ptr _
	)As HRESULT
	Return MemoryBufferGetLanguage(ContainerOf(this, MemoryBuffer, lpVtbl), ppLanguage)
End Function

Function IMemoryBufferGetETag( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppETag As HeapBSTR Ptr _
	)As HRESULT
	Return MemoryBufferGetETag(ContainerOf(this, MemoryBuffer, lpVtbl), ppETag)
End Function

Function IMemoryBufferGetLastFileModifiedDate( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal ppDate As FILETIME Ptr _
	)As HRESULT
	Return MemoryBufferGetLastFileModifiedDate(ContainerOf(this, MemoryBuffer, lpVtbl), ppDate)
End Function

Function IMemoryBufferGetLength( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As ULONG
	Return MemoryBufferGetLength(ContainerOf(this, MemoryBuffer, lpVtbl), pLength)
End Function

Function IMemoryBufferSetByteRange( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal Offset As LongInt, _
		ByVal Length As LongInt _
	)As HRESULT
	Return MemoryBufferSetByteRange(ContainerOf(this, MemoryBuffer, lpVtbl), Offset, Length)
End Function

Function IMemoryBufferGetSlice( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return MemoryBufferGetSlice(ContainerOf(this, MemoryBuffer, lpVtbl), StartIndex, Length, pBufferSlice)
End Function

Function IMemoryBufferSetContentType( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pType As MimeType Ptr _
	)As HRESULT
	Return MemoryBufferSetContentType(ContainerOf(this, MemoryBuffer, lpVtbl), pType)
End Function

Function IMemoryBufferAllocBuffer( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal Length As LongInt, _
		ByVal ppBuffer As Any Ptr Ptr _
	)As HRESULT
	Return MemoryBufferAllocBuffer(ContainerOf(this, MemoryBuffer, lpVtbl), Length, ppBuffer)
End Function

Dim GlobalMemoryBufferVirtualTable As Const IMemoryBufferVirtualTable = Type( _
	@IMemoryBufferQueryInterface, _
	@IMemoryBufferAddRef, _
	@IMemoryBufferRelease, _
	@IMemoryBufferGetContentType, _
	@IMemoryBufferGetEncoding, _
	@IMemoryBufferGetLanguage, _
	@IMemoryBufferGetETag, _
	@IMemoryBufferGetLastFileModifiedDate, _
	@IMemoryBufferGetLength, _
	@IMemoryBufferSetByteRange, _
	@IMemoryBufferGetSlice, _
	@IMemoryBufferSetContentType, _
	@IMemoryBufferAllocBuffer _
)
