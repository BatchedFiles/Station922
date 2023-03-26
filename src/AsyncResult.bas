#include once "AsyncResult.bi"
#include once "ContainerOf.bi"

Extern GlobalAsyncResultVirtualTable As Const IAsyncResultVirtualTable

Type _AsyncResult
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IAsyncResultVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pState As Any Ptr
	OverLap As OVERLAPPED
	pBuffers As Any Ptr
	BytesTransferred As DWORD
	Completed As Boolean
End Type

Function GetAsyncResultFromOverlappedWeakPtr( _
		ByVal pOverLap As OVERLAPPED Ptr _
	)As IAsyncResult Ptr
	
	Dim this As AsyncResult Ptr = ContainerOf(pOverLap, AsyncResult, OverLap)
	
	Dim pResult As IAsyncResult Ptr = CPtr(IAsyncResult Ptr, @this->lpVtbl)
	
	Return pResult
	
End Function

Sub InitializeAsyncResult( _
		ByVal this As AsyncResult Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_ASYNCRESULT), _
			Len(AsyncResult.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalAsyncResultVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pState = NULL
	this->pBuffers = NULL
	ZeroMemory(@this->OverLap, SizeOf(OVERLAPPED))
	this->BytesTransferred = 0
	this->Completed = False
	
End Sub

Sub UnInitializeAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)
	
	If this->pBuffers Then
		IMalloc_Free(this->pIMemoryAllocator, this->pBuffers)
	End If
	
End Sub

Sub AsyncResultCreated( _
		ByVal this As AsyncResult Ptr _
	)
	
End Sub

Function CreateAsyncResult( _
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

Sub AsyncResultDestroyed( _
		ByVal this As AsyncResult Ptr _
	)
	
End Sub

Sub DestroyAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeAsyncResult(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	AsyncResultDestroyed(this)
	
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
	
	this->ReferenceCounter += 1
	
	Return 1
	
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

Function AsyncResultGetWsaOverlapped( _
		ByVal this As AsyncResult Ptr, _
		ByVal ppOverlapped As OVERLAPPED Ptr Ptr _
	)As HRESULT
	
	*ppOverlapped = @this->OverLap
	
	Return S_OK
	
End Function

Function AsyncResultAllocBuffers( _
		ByVal this As AsyncResult Ptr, _
		ByVal Length As Integer, _
		ByVal ppBuffers As Any Ptr Ptr _
	)As HRESULT
	
	Dim pMemory As Any Ptr = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		Length _
	)
	If pMemory = NULL Then
		*ppBuffers = NULL
		Return E_OUTOFMEMORY
	End If
	
	this->pBuffers = pMemory
	*ppBuffers = pMemory
	
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

Function IAsyncResultGetWsaOverlapped( _
		ByVal this As IAsyncResult Ptr, _
		ByVal ppOverlapped As OVERLAPPED Ptr Ptr _
	)As HRESULT
	Return AsyncResultGetWsaOverlapped(ContainerOf(this, AsyncResult, lpVtbl), ppOverlapped)
End Function

Function IAsyncResultAllocBuffers( _
		ByVal this As IAsyncResult Ptr, _
		ByVal Length As Integer, _
		ByVal ppBuffers As Any Ptr Ptr _
	)As HRESULT
	Return AsyncResultAllocBuffers(ContainerOf(this, AsyncResult, lpVtbl), Length, ppBuffers)
End Function

Dim GlobalAsyncResultVirtualTable As Const IAsyncResultVirtualTable = Type( _
	@IAsyncResultQueryInterface, _
	@IAsyncResultAddRef, _
	@IAsyncResultRelease, _
	@IAsyncResultGetAsyncStateWeakPtr, _
	@IAsyncResultGetCompleted, _
	@IAsyncResultSetCompleted, _
	@IAsyncResultSetAsyncStateWeakPtr, _
	@IAsyncResultGetWsaOverlapped, _
	@IAsyncResultAllocBuffers _
)
