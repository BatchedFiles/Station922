#include "NetworkStreamAsyncResult.bi"
#include "ContainerOf.bi"

Extern GlobalNetworkStreamAsyncResultVirtualTable As Const INetworkStreamAsyncResultVirtualTable

Const MAX_CRITICAL_SECTION_SPIN_COUNT As DWORD = 4000

Type _NetworkStreamAsyncResult
	Dim lpVtbl As Const INetworkStreamAsyncResultVirtualTable Ptr
	Dim ReferenceCounter As Integer
	Dim crSection As CRITICAL_SECTION
	Dim pIMemoryAllocator As IMalloc Ptr
	
	Dim pState As IUnknown Ptr
	Dim callback As AsyncCallback
	Dim WaitHandle As HANDLE
	Dim OverLap As ASYNCRESULTOVERLAPPED
	Dim CompletedSynchronously As Boolean
	
End Type

Sub InitializeNetworkStreamAsyncResult( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalNetworkStreamAsyncResultVirtualTable
	this->ReferenceCounter = 0
	InitializeCriticalSectionAndSpinCount( _
		@this->crSection, _
		MAX_CRITICAL_SECTION_SPIN_COUNT _
	)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pState = NULL
	this->callback = NULL
	this->WaitHandle = NULL
	ZeroMemory(@this->OverLap, SizeOf(WSAOVERLAPPED))
	this->CompletedSynchronously = False
	
End Sub

Sub UnInitializeNetworkStreamAsyncResult( _
		ByVal this As NetworkStreamAsyncResult Ptr _
	)
	
	If this->pState <> NULL Then
		IUnknown_Release(this->pState)
	End If
	
	DeleteCriticalSection(@this->crSection)
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateNetworkStreamAsyncResult( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As NetworkStreamAsyncResult Ptr
	
	Dim this As NetworkStreamAsyncResult Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(NetworkStreamAsyncResult) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeNetworkStreamAsyncResult(this, pIMemoryAllocator)
	
	Return this
	
End Function

Sub DestroyNetworkStreamAsyncResult( _
		ByVal this As NetworkStreamAsyncResult Ptr _
	)
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeNetworkStreamAsyncResult(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub


Function NetworkStreamAsyncResultQueryInterface( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_INetworkStreamAsyncResult, riid) Then
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
	
	NetworkStreamAsyncResultAddRef(this)
	
	Return S_OK
	
End Function

Function NetworkStreamAsyncResultAddRef( _
		ByVal this As NetworkStreamAsyncResult Ptr _
	)As ULONG
	
	EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter += 1
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	Return 1
	
End Function

Function NetworkStreamAsyncResultRelease( _
		ByVal this As NetworkStreamAsyncResult Ptr _
	)As ULONG
	
	EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter -= 1
	End Scope
	LeaveCriticalSection(@this->crSection)
	
	If this->ReferenceCounter = 0 Then
		
		DestroyNetworkStreamAsyncResult(this)
		
		Return 0
	End If
	
	Return 1
	
End Function

Function NetworkStreamAsyncResultGetAsyncState( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal ppState As IUnknown Ptr Ptr _
	)As HRESULT
	
	If this->pState <> NULL Then
		IUnknown_AddRef(this->pState)
	End If
	
	*ppState = this->pState
	
	Return S_OK
	
End Function

Function NetworkStreamAsyncResultGetWaitHandle( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal pWaitHandle As HANDLE Ptr _
	)As HRESULT
	
	*pWaitHandle = this->WaitHandle
	
	Return S_OK
	
End Function

Function NetworkStreamAsyncResultGetCompletedSynchronously( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal pCompletedSynchronously As Boolean Ptr _
	)As HRESULT
	
	*pCompletedSynchronously = this->CompletedSynchronously
	
	Return S_OK
	
End Function

Function NetworkStreamAsyncResultSetAsyncState( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
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

Function NetworkStreamAsyncResultSetWaitHandle( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal WaitHandle As HANDLE _
	)As HRESULT
	
	this->WaitHandle = WaitHandle
	
	Return S_OK
	
End Function

Function NetworkStreamAsyncResultSetCompletedSynchronously( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal CompletedSynchronously As Boolean _
	)As HRESULT
	
	this->CompletedSynchronously = CompletedSynchronously
	
	Return S_OK
	
End Function

Function NetworkStreamAsyncResultGetAsyncCallback( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal pcallback As AsyncCallback Ptr _
	)As HRESULT
	
	*pcallback = this->callback
	
	Return S_OK
	
End Function

Function NetworkStreamAsyncResultSetAsyncCallback( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal callback As AsyncCallback _
	)As HRESULT
	
	this->callback = callback
	
	Return S_OK
	
End Function

Function NetworkStreamAsyncResultGetWsaOverlapped( _
		ByVal this As NetworkStreamAsyncResult Ptr, _
		ByVal ppRecvOverlapped As LPASYNCRESULTOVERLAPPED Ptr _
	)As HRESULT
	
	*ppRecvOverlapped = @this->OverLap
	
	Return S_OK
	
End Function


Function INetworkStreamAsyncResultQueryInterface( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultQueryInterface(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), riid, ppvObject)
End Function

Function INetworkStreamAsyncResultAddRef( _
		ByVal this As INetworkStreamAsyncResult Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultAddRef(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl))
End Function

Function INetworkStreamAsyncResultRelease( _
		ByVal this As INetworkStreamAsyncResult Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultRelease(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl))
End Function

Function INetworkStreamAsyncResultGetAsyncState( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal ppState As IUnknown Ptr Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultGetAsyncState(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), ppState)
End Function

Function INetworkStreamAsyncResultGetWaitHandle( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal pWaitHandle As HANDLE Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultGetWaitHandle(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), pWaitHandle)
End Function

Function INetworkStreamAsyncResultGetCompletedSynchronously( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal pCompletedSynchronously As Boolean Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultGetCompletedSynchronously(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), pCompletedSynchronously)
End Function

Function INetworkStreamAsyncResultSetAsyncState( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal pState As IUnknown Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultSetAsyncState(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), pState)
End Function

Function INetworkStreamAsyncResultSetWaitHandle( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal WaitHandle As HANDLE _
	)As HRESULT
	Return NetworkStreamAsyncResultSetWaitHandle(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), WaitHandle)
End Function

Function INetworkStreamAsyncResultSetCompletedSynchronously( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal CompletedSynchronously As Boolean _
	)As HRESULT
	Return NetworkStreamAsyncResultSetCompletedSynchronously(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), CompletedSynchronously)
End Function

Function INetworkStreamAsyncResultGetAsyncCallback( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal pcallback As AsyncCallback Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultGetAsyncCallback(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), pcallback)
End Function

Function INetworkStreamAsyncResultSetAsyncCallback( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal callback As AsyncCallback _
	)As HRESULT
	Return NetworkStreamAsyncResultSetAsyncCallback(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), callback)
End Function

Function INetworkStreamAsyncResultGetWsaOverlapped( _
		ByVal this As INetworkStreamAsyncResult Ptr, _
		ByVal ppRecvOverlapped As LPASYNCRESULTOVERLAPPED Ptr _
	)As HRESULT
	Return NetworkStreamAsyncResultGetWsaOverlapped(ContainerOf(this, NetworkStreamAsyncResult, lpVtbl), ppRecvOverlapped)
End Function

Dim GlobalNetworkStreamAsyncResultVirtualTable As Const INetworkStreamAsyncResultVirtualTable = Type( _
	@INetworkStreamAsyncResultQueryInterface, _
	@INetworkStreamAsyncResultAddRef, _
	@INetworkStreamAsyncResultRelease, _
	@INetworkStreamAsyncResultGetAsyncState, _
	@INetworkStreamAsyncResultGetWaitHandle, _
	@INetworkStreamAsyncResultGetCompletedSynchronously, _
	@INetworkStreamAsyncResultSetAsyncState, _
	@INetworkStreamAsyncResultSetWaitHandle, _
	@INetworkStreamAsyncResultSetCompletedSynchronously, _
	@INetworkStreamAsyncResultGetAsyncCallback, _
	@INetworkStreamAsyncResultSetAsyncCallback, _
	@INetworkStreamAsyncResultGetWsaOverlapped _
)
