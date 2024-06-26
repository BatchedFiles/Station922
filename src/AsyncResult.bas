#include once "AsyncResult.bi"

Extern GlobalAsyncResultVirtualTable As Const IAsyncResultVirtualTable

Type AsyncResult
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IAsyncResultVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pState As Any Ptr
	OverLap As OVERLAPPED
	pBuffers As Any Ptr
	pcb As AsyncCallback
	BytesTransferred As DWORD
	dwError As DWORD
	Completed As Boolean
End Type

Public Function GetAsyncResultFromOverlappedWeakPtr( _
		ByVal pOverLap As OVERLAPPED Ptr _
	)As IAsyncResult Ptr

	Dim this As AsyncResult Ptr = CONTAINING_RECORD(pOverLap, AsyncResult, OverLap)

	Dim pResult As IAsyncResult Ptr = CPtr(IAsyncResult Ptr, @this->lpVtbl)

	Return pResult

End Function

Private Sub InitializeAsyncResult( _
		ByVal this As AsyncResult Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_ASYNCRESULT), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalAsyncResultVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pState = NULL
	ZeroMemory(@this->OverLap, SizeOf(OVERLAPPED))
	this->pBuffers = NULL
	this->pcb = NULL
	this->BytesTransferred = 0
	this->Completed = False

End Sub

Private Sub UnInitializeAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)

	If this->pBuffers Then
		IMalloc_Free(this->pIMemoryAllocator, this->pBuffers)
	End If

End Sub

Private Sub AsyncResultCreated( _
		ByVal this As AsyncResult Ptr _
	)

End Sub

Private Sub AsyncResultDestroyed( _
		ByVal this As AsyncResult Ptr _
	)

End Sub

Private Sub DestroyAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeAsyncResult(this)

	IMalloc_Free(pIMemoryAllocator, this)

	AsyncResultDestroyed(this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function AsyncResultAddRef( _
		ByVal this As AsyncResult Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function AsyncResultRelease( _
		ByVal this As AsyncResult Ptr _
	)As ULONG

	this->ReferenceCounter -= 1

	If this->ReferenceCounter Then
		Return 1
	End If

	DestroyAsyncResult(this)

	Return 0

End Function

Private Function AsyncResultQueryInterface( _
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

Public Function CreateAsyncResult( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim this As AsyncResult Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(AsyncResult) _
	)

	If this Then
		InitializeAsyncResult(this, pIMemoryAllocator)
		AsyncResultCreated(this)

		Dim hrQueryInterface As HRESULT = AsyncResultQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyAsyncResult(this)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function AsyncResultGetAsyncStateWeakPtr( _
		ByVal this As AsyncResult Ptr, _
		ByVal ppState As Any Ptr Ptr _
	)As HRESULT

	*ppState = this->pState

	Return S_OK

End Function

Private Function AsyncResultSetAsyncStateWeakPtr( _
		ByVal this As AsyncResult Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal pState As Any Ptr _
	)As HRESULT

	this->pcb = pcb
	this->pState = pState

	Return S_OK

End Function

Private Function AsyncResultGetCompleted( _
		ByVal this As AsyncResult Ptr, _
		ByVal pBytesTransferred As DWORD Ptr, _
		ByVal pCompleted As Boolean Ptr, _
		ByVal pdwError As DWORD Ptr _
	)As HRESULT

	*pBytesTransferred = this->BytesTransferred
	*pCompleted = this->Completed
	*pdwError = this->dwError

	Return S_OK

End Function

Private Function AsyncResultSetCompleted( _
		ByVal this As AsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal Completed As Boolean, _
		ByVal dwError As DWORD _
	)As HRESULT

	this->BytesTransferred = BytesTransferred
	this->Completed = Completed
	this->dwError = dwError

	Return S_OK

End Function

Private Function AsyncResultGetWsaOverlapped( _
		ByVal this As AsyncResult Ptr, _
		ByVal ppOverlapped As OVERLAPPED Ptr Ptr _
	)As HRESULT

	*ppOverlapped = @this->OverLap

	Return S_OK

End Function

Private Function AsyncResultAllocBuffers( _
		ByVal this As AsyncResult Ptr, _
		ByVal Length As Integer, _
		ByVal ppBuffers As Any Ptr Ptr _
	)As HRESULT

	Const RTTI_ID_ASYNCBUFFERS = !"\001Async__Buffers\001"

	#if __FB_DEBUG__
		Dim pMemory As UByte Ptr = IMalloc_Alloc( _
			this->pIMemoryAllocator, _
			Length + Len(RTTI_ID_ASYNCBUFFERS) _
		)
	#else
		Dim pMemory As UByte Ptr = IMalloc_Alloc( _
			this->pIMemoryAllocator, _
			Length _
		)
	#endif
	If pMemory = NULL Then
		*ppBuffers = NULL
		Return E_OUTOFMEMORY
	End If

	#if __FB_DEBUG__
		CopyMemory( _
			pMemory, _
			@Str(RTTI_ID_ASYNCBUFFERS), _
			Len(RTTI_ID_ASYNCBUFFERS) _
		)
	#endif

	this->pBuffers = pMemory

	#if __FB_DEBUG__
		*ppBuffers = @pMemory[Len(RTTI_ID_ASYNCBUFFERS)]
	#else
		*ppBuffers = pMemory
	#endif

	Return S_OK

End Function

Private Function AsyncResultGetAsyncCallback( _
		ByVal this As AsyncResult Ptr, _
		ByVal ppcb As AsyncCallback Ptr _
	)As HRESULT

	*ppcb = this->pcb

	Return S_OK

End Function


Private Function IAsyncResultQueryInterface( _
		ByVal this As IAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return AsyncResultQueryInterface(CONTAINING_RECORD(this, AsyncResult, lpVtbl), riid, ppvObject)
End Function

Private Function IAsyncResultAddRef( _
		ByVal this As IAsyncResult Ptr _
	)As HRESULT
	Return AsyncResultAddRef(CONTAINING_RECORD(this, AsyncResult, lpVtbl))
End Function

Private Function IAsyncResultRelease( _
		ByVal this As IAsyncResult Ptr _
	)As HRESULT
	Return AsyncResultRelease(CONTAINING_RECORD(this, AsyncResult, lpVtbl))
End Function

Private Function IAsyncResultGetAsyncStateWeakPtr( _
		ByVal this As IAsyncResult Ptr, _
		ByVal ppState As Any Ptr Ptr _
	)As HRESULT
	Return AsyncResultGetAsyncStateWeakPtr(CONTAINING_RECORD(this, AsyncResult, lpVtbl), ppState)
End Function

Private Function IAsyncResultSetAsyncStateWeakPtr( _
		ByVal this As IAsyncResult Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal pState As Any Ptr _
	)As HRESULT
	Return AsyncResultSetAsyncStateWeakPtr(CONTAINING_RECORD(this, AsyncResult, lpVtbl), pcb, pState)
End Function

Private Function IAsyncResultGetCompleted( _
		ByVal this As IAsyncResult Ptr, _
		ByVal pBytesTransferred As DWORD Ptr, _
		ByVal pCompleted As Boolean Ptr, _
		ByVal pdwError As DWORD Ptr _
	)As HRESULT
	Return AsyncResultGetCompleted(CONTAINING_RECORD(this, AsyncResult, lpVtbl), pBytesTransferred, pCompleted, pdwError)
End Function

Private Function IAsyncResultSetCompleted( _
		ByVal this As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal Completed As Boolean, _
		ByVal dwError As DWORD _
	)As HRESULT
	Return AsyncResultSetCompleted(CONTAINING_RECORD(this, AsyncResult, lpVtbl), BytesTransferred, Completed, dwError)
End Function

Private Function IAsyncResultGetWsaOverlapped( _
		ByVal this As IAsyncResult Ptr, _
		ByVal ppOverlapped As OVERLAPPED Ptr Ptr _
	)As HRESULT
	Return AsyncResultGetWsaOverlapped(CONTAINING_RECORD(this, AsyncResult, lpVtbl), ppOverlapped)
End Function

Private Function IAsyncResultAllocBuffers( _
		ByVal this As IAsyncResult Ptr, _
		ByVal Length As Integer, _
		ByVal ppBuffers As Any Ptr Ptr _
	)As HRESULT
	Return AsyncResultAllocBuffers(CONTAINING_RECORD(this, AsyncResult, lpVtbl), Length, ppBuffers)
End Function

Private Function IAsyncResultGetAsyncCallback( _
		ByVal this As IAsyncResult Ptr, _
		ByVal ppcb As AsyncCallback Ptr _
	)As HRESULT
	Return AsyncResultGetAsyncCallback(CONTAINING_RECORD(this, AsyncResult, lpVtbl), ppcb)
End Function

Dim GlobalAsyncResultVirtualTable As Const IAsyncResultVirtualTable = Type( _
	@IAsyncResultQueryInterface, _
	@IAsyncResultAddRef, _
	@IAsyncResultRelease, _
	@IAsyncResultGetAsyncStateWeakPtr, _
	@IAsyncResultSetAsyncStateWeakPtr, _
	@IAsyncResultGetCompleted, _
	@IAsyncResultSetCompleted, _
	@IAsyncResultGetWsaOverlapped, _
	@IAsyncResultAllocBuffers, _
	@IAsyncResultGetAsyncCallback _
)
