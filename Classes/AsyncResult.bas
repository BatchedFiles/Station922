#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalMutableAsyncResultVirtualTable As Const IMutableAsyncResultVirtualTable

Type _AsyncResult
	lpVtbl As Const IMutableAsyncResultVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pState As IUnknown Ptr
	callback As AsyncCallback
	OverLap As ASYNCRESULTOVERLAPPED
	BytesTransferred As DWORD
	Completed As Boolean
End Type

Sub InitializeAsyncResult( _
		ByVal this As AsyncResult Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalMutableAsyncResultVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pState = NULL
	this->callback = NULL
	ZeroMemory(@this->OverLap, SizeOf(WSAOVERLAPPED))
	this->BytesTransferred = 0
	this->Completed = False
	
End Sub

Sub UnInitializeAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)
	
	If this->pState <> NULL Then
		IUnknown_Release(this->pState)
	End If
	
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
	
	If IsEqualIID(@IID_IMutableAsyncResult, riid) Then
		*ppv = @this->lpVtbl
	Else
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
	End If
	
	AsyncResultAddRef(this)
	
	Return S_OK
	
End Function

Function AsyncResultAddRef( _
		ByVal this As AsyncResult Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function AsyncResultRelease( _
		ByVal this As AsyncResult Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyAsyncResult(this)
		
	Return 0
	
End Function

Function AsyncResultGetAsyncState( _
		ByVal this As AsyncResult Ptr, _
		ByVal ppState As IUnknown Ptr Ptr _
	)As HRESULT
	
	If this->pState <> NULL Then
		IUnknown_AddRef(this->pState)
	End If
	
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


Function AsyncResultSetAsyncState( _
		ByVal this As AsyncResult Ptr, _
		ByVal pState As IUnknown Ptr _
	)As HRESULT
	
	If this->pState <> NULL Then
		IUnknown_Release(this->pState)
	End If
	
	If pState <> NULL Then
		IUnknown_AddRef(pState)
	End If
	
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
		ByVal ppRecvOverlapped As LPASYNCRESULTOVERLAPPED Ptr _
	)As HRESULT
	
	*ppRecvOverlapped = @this->OverLap
	
	Return S_OK
	
End Function


Function IMutableAsyncResultQueryInterface( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return AsyncResultQueryInterface(ContainerOf(this, AsyncResult, lpVtbl), riid, ppvObject)
End Function

Function IMutableAsyncResultAddRef( _
		ByVal this As IMutableAsyncResult Ptr _
	)As HRESULT
	Return AsyncResultAddRef(ContainerOf(this, AsyncResult, lpVtbl))
End Function

Function IMutableAsyncResultRelease( _
		ByVal this As IMutableAsyncResult Ptr _
	)As HRESULT
	Return AsyncResultRelease(ContainerOf(this, AsyncResult, lpVtbl))
End Function

Function IMutableAsyncResultGetAsyncState( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal ppState As IUnknown Ptr Ptr _
	)As HRESULT
	Return AsyncResultGetAsyncState(ContainerOf(this, AsyncResult, lpVtbl), ppState)
End Function

Function IMutableAsyncResultGetCompleted( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pBytesTransferred As DWORD Ptr, _
		ByVal pCompleted As Boolean Ptr _
	)As HRESULT
	Return AsyncResultGetCompleted(ContainerOf(this, AsyncResult, lpVtbl), pBytesTransferred, pCompleted)
End Function

Function IMutableAsyncResultSetCompleted( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal Completed As Boolean _
	)As HRESULT
	Return AsyncResultSetCompleted(ContainerOf(this, AsyncResult, lpVtbl), BytesTransferred, Completed)
End Function

Function IMutableAsyncResultSetAsyncState( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pState As IUnknown Ptr _
	)As HRESULT
	Return AsyncResultSetAsyncState(ContainerOf(this, AsyncResult, lpVtbl), pState)
End Function

Function IMutableAsyncResultGetAsyncCallback( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pcallback As AsyncCallback Ptr _
	)As HRESULT
	Return AsyncResultGetAsyncCallback(ContainerOf(this, AsyncResult, lpVtbl), pcallback)
End Function

Function IMutableAsyncResultSetAsyncCallback( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal callback As AsyncCallback _
	)As HRESULT
	Return AsyncResultSetAsyncCallback(ContainerOf(this, AsyncResult, lpVtbl), callback)
End Function

Function IMutableAsyncResultGetWsaOverlapped( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal ppRecvOverlapped As LPASYNCRESULTOVERLAPPED Ptr _
	)As HRESULT
	Return AsyncResultGetWsaOverlapped(ContainerOf(this, AsyncResult, lpVtbl), ppRecvOverlapped)
End Function

Dim GlobalMutableAsyncResultVirtualTable As Const IMutableAsyncResultVirtualTable = Type( _
	@IMutableAsyncResultQueryInterface, _
	@IMutableAsyncResultAddRef, _
	@IMutableAsyncResultRelease, _
	@IMutableAsyncResultGetAsyncState, _
	@IMutableAsyncResultGetCompleted, _
	@IMutableAsyncResultSetCompleted, _
	@IMutableAsyncResultSetAsyncState, _
	@IMutableAsyncResultGetAsyncCallback, _
	@IMutableAsyncResultSetAsyncCallback, _
	@IMutableAsyncResultGetWsaOverlapped _
)
