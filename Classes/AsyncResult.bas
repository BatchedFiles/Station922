#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalAsyncResultVirtualTable As Const IAsyncResultVirtualTable

Type _AsyncResult
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	OverLap As ASYNCRESULTOVERLAPPED
	lpVtbl As Const IAsyncResultVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pState As Any Ptr
	callback As AsyncCallback
	BytesTransferred As DWORD
	Completed As Boolean
End Type

Sub InitializeAsyncResult( _
		ByVal this As AsyncResult Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("AsyncResultResul"), 16)
	#endif
	this->lpVtbl = @GlobalAsyncResultVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pState = NULL
	this->callback = NULL
	ZeroMemory(@this->OverLap, SizeOf(ASYNCRESULTOVERLAPPED))
	this->BytesTransferred = 0
	this->Completed = False
	
End Sub

Sub UnInitializeAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateAsyncResult( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As AsyncResult Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(AsyncResult)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"AsyncResult creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As AsyncResult Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(AsyncResult) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeAsyncResult(this, pIMemoryAllocator)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("AsyncResult created"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Return this
	
End Function

Sub DestroyAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("AsyncResult destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeAsyncResult(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("AsyncResult destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub


Function AsyncResultQueryInterface( _
		ByVal this As AsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IAsyncResult, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	AsyncResultAddRef(this)
	
	Return S_OK
	
End Function

Function AsyncResultAddRef( _
		ByVal this As AsyncResult Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function AsyncResultRelease( _
		ByVal this As AsyncResult Ptr _
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
	
	DestroyAsyncResult(this)
		
	Return 0
	
End Function

Function AsyncResultGetAsyncStateWeakPtr( _
		ByVal this As AsyncResult Ptr, _
		ByVal ppState As Any Ptr Ptr _
	)As HRESULT
	
	*ppState = this->pState
	
	Return S_OK
	
End Function

Function AsyncResultGetCompleted( _
		ByVal this As AsyncResult Ptr, _
		ByVal pBytesTransferred As DWORD Ptr, _
		ByVal pCompleted As Boolean Ptr _
	)As HRESULT
	
	*pBytesTransferred = this->BytesTransferred
	*pCompleted = this->Completed
	
	Return S_OK
	
End Function

Function AsyncResultSetCompleted( _
		ByVal this As AsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal Completed As Boolean _
	)As HRESULT
	
	this->BytesTransferred = BytesTransferred
	this->Completed = Completed
	
	Return S_OK
	
End Function


Function AsyncResultSetAsyncStateWeakPtr( _
		ByVal this As AsyncResult Ptr, _
		ByVal pState As Any Ptr _
	)As HRESULT
	
	this->pState = pState
	
	Return S_OK
	
End Function

Function AsyncResultGetAsyncCallback( _
		ByVal this As AsyncResult Ptr, _
		ByVal pcallback As AsyncCallback Ptr _
	)As HRESULT
	
	*pcallback = this->callback
	
	Return S_OK
	
End Function

Function AsyncResultSetAsyncCallback( _
		ByVal this As AsyncResult Ptr, _
		ByVal callback As AsyncCallback _
	)As HRESULT
	
	this->callback = callback
	
	Return S_OK
	
End Function

Function AsyncResultGetWsaOverlapped( _
		ByVal this As AsyncResult Ptr, _
		ByVal ppRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr Ptr _
	)As HRESULT
	
	*ppRecvOverlapped = @this->OverLap
	
	Return S_OK
	
End Function


Function IAsyncResultQueryInterface( _
		ByVal this As IAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return AsyncResultQueryInterface(ContainerOf(this, AsyncResult, lpVtbl), riid, ppvObject)
End Function

Function IAsyncResultAddRef( _
		ByVal this As IAsyncResult Ptr _
	)As HRESULT
	Return AsyncResultAddRef(ContainerOf(this, AsyncResult, lpVtbl))
End Function

Function IAsyncResultRelease( _
		ByVal this As IAsyncResult Ptr _
	)As HRESULT
	Return AsyncResultRelease(ContainerOf(this, AsyncResult, lpVtbl))
End Function

Function IAsyncResultGetAsyncStateWeakPtr( _
		ByVal this As IAsyncResult Ptr, _
		ByVal ppState As Any Ptr Ptr _
	)As HRESULT
	Return AsyncResultGetAsyncStateWeakPtr(ContainerOf(this, AsyncResult, lpVtbl), ppState)
End Function

Function IAsyncResultGetCompleted( _
		ByVal this As IAsyncResult Ptr, _
		ByVal pBytesTransferred As DWORD Ptr, _
		ByVal pCompleted As Boolean Ptr _
	)As HRESULT
	Return AsyncResultGetCompleted(ContainerOf(this, AsyncResult, lpVtbl), pBytesTransferred, pCompleted)
End Function

Function IAsyncResultSetCompleted( _
		ByVal this As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal Completed As Boolean _
	)As HRESULT
	Return AsyncResultSetCompleted(ContainerOf(this, AsyncResult, lpVtbl), BytesTransferred, Completed)
End Function

Function IAsyncResultSetAsyncStateWeakPtr( _
		ByVal this As IAsyncResult Ptr, _
		ByVal pState As Any Ptr _
	)As HRESULT
	Return AsyncResultSetAsyncStateWeakPtr(ContainerOf(this, AsyncResult, lpVtbl), pState)
End Function

Function IAsyncResultGetAsyncCallback( _
		ByVal this As IAsyncResult Ptr, _
		ByVal pcallback As AsyncCallback Ptr _
	)As HRESULT
	Return AsyncResultGetAsyncCallback(ContainerOf(this, AsyncResult, lpVtbl), pcallback)
End Function

Function IAsyncResultSetAsyncCallback( _
		ByVal this As IAsyncResult Ptr, _
		ByVal callback As AsyncCallback _
	)As HRESULT
	Return AsyncResultSetAsyncCallback(ContainerOf(this, AsyncResult, lpVtbl), callback)
End Function

Function IAsyncResultGetWsaOverlapped( _
		ByVal this As IAsyncResult Ptr, _
		ByVal ppRecvOverlapped As ASYNCRESULTOVERLAPPED Ptr Ptr _
	)As HRESULT
	Return AsyncResultGetWsaOverlapped(ContainerOf(this, AsyncResult, lpVtbl), ppRecvOverlapped)
End Function

Dim GlobalAsyncResultVirtualTable As Const IAsyncResultVirtualTable = Type( _
	@IAsyncResultQueryInterface, _
	@IAsyncResultAddRef, _
	@IAsyncResultRelease, _
	@IAsyncResultGetAsyncStateWeakPtr, _
	@IAsyncResultGetCompleted, _
	@IAsyncResultSetCompleted, _
	@IAsyncResultSetAsyncStateWeakPtr, _
	@IAsyncResultGetAsyncCallback, _
	@IAsyncResultSetAsyncCallback, _
	@IAsyncResultGetWsaOverlapped _
)
