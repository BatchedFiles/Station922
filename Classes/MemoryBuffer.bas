#include once "MemoryBuffer.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalMemoryBufferVirtualTable As Const IMemoryBufferVirtualTable

Type _MemoryBuffer
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IMemoryBufferVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	Capacity As LongInt
	pBuffer As Byte Ptr
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
	this->Capacity = 0
	this->pBuffer = NULL
	
End Sub

Sub UnInitializeMemoryBuffer( _
		ByVal this As MemoryBuffer Ptr _
	)
	
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

Function MemoryBufferGetCapacity( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal pCapacity As LongInt Ptr _
	)As HRESULT
	
	*pCapacity = this->Capacity
	
	Return S_OK
	
End Function

Function MemoryBufferGetLength( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As HRESULT
	
	*pLength = this->Capacity
	
	Return S_OK
	
End Function

Function MemoryBufferGetSlice( _
		ByVal this As MemoryBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	
	If StartIndex > this->Capacity Then
		Return E_OUTOFMEMORY
	End If
	
	pBufferSlice->pSlice = @this->pBuffer[StartIndex]
	pBufferSlice->Length = this->Capacity - StartIndex
	
	If pBufferSlice->Length <= this->Capacity Then
		Return S_FALSE
	End If
	
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

Function IMemoryBufferGetCapacity( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pCapacity As LongInt Ptr _
	)As ULONG
	Return MemoryBufferGetCapacity(ContainerOf(this, MemoryBuffer, lpVtbl), pCapacity)
End Function

Function IMemoryBufferGetLength( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal pLength As LongInt Ptr _
	)As ULONG
	Return MemoryBufferGetLength(ContainerOf(this, MemoryBuffer, lpVtbl), pLength)
End Function

Function IMemoryBufferGetSlice( _
		ByVal this As IMemoryBuffer Ptr, _
		ByVal StartIndex As LongInt, _
		ByVal Length As DWORD, _
		ByVal pBufferSlice As BufferSlice Ptr _
	)As HRESULT
	Return MemoryBufferGetSlice(ContainerOf(this, MemoryBuffer, lpVtbl), StartIndex, Length, pBufferSlice)
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
	@IMemoryBufferGetCapacity, _
	@IMemoryBufferGetLength, _
	@IMemoryBufferGetSlice, _
	@IMemoryBufferAllocBuffer _
)
