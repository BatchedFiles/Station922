#include once "AsyncResult.bi"
#include once "ContainerOf.bi"
#include once "ReferenceCounter.bi"

Extern GlobalMutableAsyncResultVirtualTable As Const IMutableAsyncResultVirtualTable

Type _AsyncResult
	Dim lpVtbl As Const IMutableAsyncResultVirtualTable Ptr
	Dim RefCounter As ReferenceCounter
	Dim pILogger As ILogger Ptr
	Dim pIMemoryAllocator As IMalloc Ptr
	Dim pState As IUnknown Ptr
	Dim callback As AsyncCallback
	Dim WaitHandle As HANDLE
	Dim OverLap As ASYNCRESULTOVERLAPPED
	Dim CompletedSynchronously As Boolean
End Type

Sub InitializeAsyncResult( _
		ByVal this As AsyncResult Ptr, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalMutableAsyncResultVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pState = NULL
	this->callback = NULL
	this->WaitHandle = NULL
	ZeroMemory(@this->OverLap, SizeOf(WSAOVERLAPPED))
	this->CompletedSynchronously = False
	
End Sub

Sub UnInitializeAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)
	
	If this->pState <> NULL Then
		IUnknown_Release(this->pState)
	End If
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	
	IMalloc_Release(this->pIMemoryAllocator)
	ILogger_Release(this->pILogger)
	
End Sub

Function CreateAsyncResult( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As AsyncResult Ptr
	
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = SizeOf(AsyncResult)
	ILogger_LogDebug(pILogger, WStr(!"AsyncResult creating\t"), vtAllocatedBytes)
	
	Dim this As AsyncResult Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(AsyncResult) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeAsyncResult(this, pILogger, pIMemoryAllocator)
	
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(pILogger, WStr("AsyncResult created"), vtEmpty)
	
	Return this
	
End Function

Sub DestroyAsyncResult( _
		ByVal this As AsyncResult Ptr _
	)
	
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("AsyncResult destroying"), vtEmpty)
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeAsyncResult(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	ILogger_LogDebug(pILogger, WStr("AsyncResult destroyed"), vtEmpty)
	
	IMalloc_Release(pIMemoryAllocator)
	ILogger_Release(pILogger)
	
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
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function AsyncResultRelease( _
		ByVal this As AsyncResult Ptr _
	)As ULONG
	
	ReferenceCounterDecrement(@this->RefCounter)
	
	If this->RefCounter.Counter = 0 Then
		
		DestroyAsyncResult(this)
		
		Return 0
	End If
	
	Return 1
	
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

Function AsyncResultGetWaitHandle( _
		ByVal this As AsyncResult Ptr, _
		ByVal pWaitHandle As HANDLE Ptr _
	)As HRESULT
	
	*pWaitHandle = this->WaitHandle
	
	Return S_OK
	
End Function

Function AsyncResultGetCompletedSynchronously( _
		ByVal this As AsyncResult Ptr, _
		ByVal pCompletedSynchronously As Boolean Ptr _
	)As HRESULT
	
	*pCompletedSynchronously = this->CompletedSynchronously
	
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

Function AsyncResultSetWaitHandle( _
		ByVal this As AsyncResult Ptr, _
		ByVal WaitHandle As HANDLE _
	)As HRESULT
	
	this->WaitHandle = WaitHandle
	
	Return S_OK
	
End Function

Function AsyncResultSetCompletedSynchronously( _
		ByVal this As AsyncResult Ptr, _
		ByVal CompletedSynchronously As Boolean _
	)As HRESULT
	
	this->CompletedSynchronously = CompletedSynchronously
	
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

Function IMutableAsyncResultGetWaitHandle( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pWaitHandle As HANDLE Ptr _
	)As HRESULT
	Return AsyncResultGetWaitHandle(ContainerOf(this, AsyncResult, lpVtbl), pWaitHandle)
End Function

Function IMutableAsyncResultGetCompletedSynchronously( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pCompletedSynchronously As Boolean Ptr _
	)As HRESULT
	Return AsyncResultGetCompletedSynchronously(ContainerOf(this, AsyncResult, lpVtbl), pCompletedSynchronously)
End Function

Function IMutableAsyncResultSetAsyncState( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal pState As IUnknown Ptr _
	)As HRESULT
	Return AsyncResultSetAsyncState(ContainerOf(this, AsyncResult, lpVtbl), pState)
End Function

Function IMutableAsyncResultSetWaitHandle( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal WaitHandle As HANDLE _
	)As HRESULT
	Return AsyncResultSetWaitHandle(ContainerOf(this, AsyncResult, lpVtbl), WaitHandle)
End Function

Function IMutableAsyncResultSetCompletedSynchronously( _
		ByVal this As IMutableAsyncResult Ptr, _
		ByVal CompletedSynchronously As Boolean _
	)As HRESULT
	Return AsyncResultSetCompletedSynchronously(ContainerOf(this, AsyncResult, lpVtbl), CompletedSynchronously)
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
	@IMutableAsyncResultGetWaitHandle, _
	@IMutableAsyncResultGetCompletedSynchronously, _
	@IMutableAsyncResultSetAsyncState, _
	@IMutableAsyncResultSetWaitHandle, _
	@IMutableAsyncResultSetCompletedSynchronously, _
	@IMutableAsyncResultGetAsyncCallback, _
	@IMutableAsyncResultSetAsyncCallback, _
	@IMutableAsyncResultGetWsaOverlapped _
)
