#include once "HeapMemoryAllocator.bi"
#include once "ContainerOf.bi"
#include once "IClientSocket.bi"
#include once "ITimeCounter.bi"
#include once "Logger.bi"

Extern GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable
Extern GlobalTimeCounterVirtualTable As Const ITimeCounterVirtualTable
Extern GlobalClientSocketVirtualTable As Const IClientSocketVirtualTable

Const MEMORY_ALLOCATION_GRANULARITY As DWORD = 64 * 1024

Const PRIVATEHEAP_INITIALSIZE As DWORD = 0
Const PRIVATEHEAP_MAXIMUMSIZE As DWORD = MEMORY_ALLOCATION_GRANULARITY

Const HEAP_NO_SERIALIZE_FLAG = HEAP_NO_SERIALIZE

Type _HeapMemoryAllocator
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IHeapMemoryAllocatorVirtualTable Ptr
	lpVtblTimeCounter As Const ITimeCounterVirtualTable Ptr
	lpVtblClientSocket As Const IClientSocketVirtualTable Ptr
	ReferenceCounter As UInteger
	hHeap As HANDLE
	ClientSocket As SOCKET
	datStartOperation As FILETIME
	datFinishOperation As FILETIME
	ReadedData As ClientRequestBuffer
End Type

Type MemoryPoolItem
	pMalloc As IHeapMemoryAllocator Ptr
	IsUsed As Boolean
End Type

Type MemoryPool
	crSection As CRITICAL_SECTION
	Items As MemoryPoolItem Ptr
	Capacity As UInteger
	Length As UInteger
End Type

Dim Shared MemoryPoolObject As MemoryPool
Dim Shared HungsConnectionsEvent As HANDLE
Dim Shared HungsConnectionsThread As HANDLE

Sub HeapMemoryAllocatorResetState( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	' Restore the original state of the reference counter
	' Beecause number of reference is equal to one
	this->ReferenceCounter = 1
	
	InitializeClientRequestBuffer(@this->ReadedData)
	
End Sub

Function HeapMemoryAllocatorCloseHungsConnections( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal KeepAliveInterval As ULongInt _
	)As Boolean
	
	If this->ClientSocket = INVALID_SOCKET Then
		Return False
	End If
	
	Dim ulStart As ULARGE_INTEGER = Any
	ulStart.LowPart = this->datStartOperation.dwLowDateTime
	ulStart.HighPart = this->datStartOperation.dwHighDateTime
	
	Dim datCurrent As FILETIME
	GetSystemTimeAsFileTime(@datCurrent)
	
	Dim ulCurrent As ULARGE_INTEGER = Any
	ulCurrent.LowPart = datCurrent.dwLowDateTime
	ulCurrent.HighPart = datCurrent.dwHighDateTime
	
	If ulCurrent.QuadPart > ulStart.QuadPart Then
		Dim nsElapsedTime As ULongInt = ulCurrent.QuadPart - ulStart.QuadPart
		Dim nsKeepAliveInterval As ULongInt = 10 * 1000 * 1000 * KeepAliveInterval
		
		If nsElapsedTime > nsKeepAliveInterval Then
			HeapMemoryAllocatorCloseSocket(this)
			Return False
		End If
	End If
	
	Return True
	
End Function

Sub ReleaseHeapMemoryAllocatorInstance( _
		ByVal pMalloc As IHeapMemoryAllocator Ptr _
	)
	
	Dim Finded As Boolean = False
	
	If MemoryPoolObject.Length Then
		EnterCriticalSection(@MemoryPoolObject.crSection)
		Scope
			For i As UInteger = 0 To MemoryPoolObject.Capacity - 1
				If MemoryPoolObject.Items[i].pMalloc = pMalloc Then
					
					Dim this As HeapMemoryAllocator Ptr = ContainerOf(pMalloc, HeapMemoryAllocator, lpVtbl)
					HeapMemoryAllocatorResetState(this)
					
					MemoryPoolObject.Items[i].IsUsed = False
					MemoryPoolObject.Length -= 1
					
					Finded = True
					
					Exit For
				End If
			Next
		End Scope
		LeaveCriticalSection(@MemoryPoolObject.crSection)
	End If
	
	If Finded = False Then
		Dim this As HeapMemoryAllocator Ptr = ContainerOf(pMalloc, HeapMemoryAllocator, lpVtbl)
		DestroyHeapMemoryAllocator(this)
	End If
	
End Sub

Function GetHeapMemoryAllocatorInstance( _
	)As IHeapMemoryAllocator Ptr
	
	If MemoryPoolObject.Length < MemoryPoolObject.Capacity Then
		Dim pMalloc As IHeapMemoryAllocator Ptr = NULL
		
		EnterCriticalSection(@MemoryPoolObject.crSection)
		Scope
			For i As UInteger = 0 To MemoryPoolObject.Capacity - 1
				If MemoryPoolObject.Items[i].IsUsed = False Then
					
					MemoryPoolObject.Items[i].IsUsed = True
					pMalloc = MemoryPoolObject.Items[i].pMalloc
					MemoryPoolObject.Length += 1
					
					Exit For
				End If
			Next
		End Scope
		LeaveCriticalSection(@MemoryPoolObject.crSection)
		
		If pMalloc Then
			' We do not increase the reference counter to the object
			' to track the lifetime
			' When the object reference count reaches zero
			' the Release function returns the object to the object pool
			Return pMalloc
		End If
	End If
	
	Scope
		Dim pMalloc As IHeapMemoryAllocator Ptr = Any
		Dim hrCreateMalloc As HRESULT = CreateHeapMemoryAllocator( _
			@IID_IHeapMemoryAllocator, _
			@pMalloc _
		)
		If FAILED(hrCreateMalloc) Then
			Return NULL
		End If
		
		Return pMalloc
	End Scope
	
End Function

Function CheckHungsConnections( _
		ByVal KeepAliveInterval As Integer _
	)As Boolean
	
	Do
		Const msTimeToHungsConnection As DWORD = 1000 * 60
		Dim resWait As DWORD = SleepEx(msTimeToHungsConnection, TRUE)
		If resWait <> 0 Then
			Return True
		End If
		
		Dim AnyClientsConnected As Boolean = False
		
		EnterCriticalSection(@MemoryPoolObject.crSection)
		Scope
			For i As UInteger = 0 To MemoryPoolObject.Capacity - 1
				If MemoryPoolObject.Items[i].IsUsed Then
					Dim this As HeapMemoryAllocator Ptr = ContainerOf(MemoryPoolObject.Items[i].pMalloc, HeapMemoryAllocator, lpVtbl)
					Dim resClose As Boolean = HeapMemoryAllocatorCloseHungsConnections( _
						this, _
						KeepAliveInterval _
					)
					If resClose Then
						AnyClientsConnected = True
					End If
				End If
			Next
		End Scope
		LeaveCriticalSection(@MemoryPoolObject.crSection)
		
		If AnyClientsConnected = False Then
			Exit Do
		End If
		
	Loop
	
	Return False
	
End Function

Sub WakeupClearingThread( _
		ByVal Parameter As ULONG_PTR _
	)
	
End Sub

Function ClearingThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim KeepAliveInterval As Integer = CInt(lpParam)
	
	Do
		Dim resWait As DWORD = WaitForSingleObjectEx( _
			HungsConnectionsEvent, _
			INFINITE, _
			TRUE _
		)
		If resWait <> WAIT_OBJECT_0 Then
			Return 0
		End If
		
		Dim resCheck As Boolean = CheckHungsConnections(KeepAliveInterval)
		If resCheck Then
			Return 0
		End If
		
		Dim resReset As BOOL = ResetEvent(HungsConnectionsEvent)
		If resReset = 0 Then
			Return 0
		End If
	Loop
	
	Return 0
	
End Function

Function CreateMemoryPool( _
		ByVal Capacity As UInteger, _
		ByVal KeepAliveInterval As Integer _
	)As HRESULT
	
	MemoryPoolObject.Capacity = Capacity
	MemoryPoolObject.Length = 0
	
	If Capacity Then
		Const dwSpinCount As DWORD = 4000
		Dim resInitialize As BOOL = InitializeCriticalSectionAndSpinCount( _
			@MemoryPoolObject.crSection, _
			dwSpinCount _
		)
		If resInitialize = 0 Then
			Dim dwError As DWORD =  GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
		Dim hHeap As HANDLE = GetProcessHeap()
		MemoryPoolObject.Items = HeapAlloc( _
			hHeap, _
			0, _
			SizeOf(MemoryPoolItem) * Capacity _
		)
		If MemoryPoolObject.Items = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		HungsConnectionsEvent = CreateEventW( _
			NULL, _
			TRUE, _
			FALSE, _
			NULL _
		)
		If HungsConnectionsEvent = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Const DefaultStackSize As SIZE_T_ = 0
		HungsConnectionsThread = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@ClearingThread, _
			CPtr(Integer Ptr, KeepAliveInterval), _
			0, _
			NULL _
		)
		If HungsConnectionsThread = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		For i As UInteger = 0 To Capacity - 1
			Dim pMalloc As IHeapMemoryAllocator Ptr = Any
			Dim hrCreateMalloc As HRESULT = CreateHeapMemoryAllocator( _
				@IID_IHeapMemoryAllocator, _
				@pMalloc _
			)
			If FAILED(hrCreateMalloc) Then
				Return E_OUTOFMEMORY
			End If
			
			MemoryPoolObject.Items[i].pMalloc = pMalloc
			MemoryPoolObject.Items[i].IsUsed = False
		Next
	End If
	
	Return S_OK
	
End Function

Sub DeleteMemoryPool()
	
	QueueUserAPC( _
		@WakeupClearingThread, _
		HungsConnectionsThread, _
		0 _
	)
	
End Sub

Sub AllocationFailed( _
		ByVal BytesCount As SIZE_T_ _
	)
	
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = CLng(BytesCount)
	LogWriteEntry( _
		LogEntryType.Error, _
		WStr(!"AllocMemory Failed"), _
		@vtAllocatedBytes _
	)
	
End Sub

Sub InitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_HEAPMEMORYALLOCATOR), _
			Len(HeapMemoryAllocator.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalHeapMemoryAllocatorVirtualTable
	this->lpVtblTimeCounter = @GlobalTimeCounterVirtualTable
	this->lpVtblClientSocket = @GlobalClientSocketVirtualTable
	this->ReferenceCounter = 0
	this->hHeap = hHeap
	this->ClientSocket = INVALID_SOCKET
	InitializeClientRequestBuffer(@this->ReadedData)
	
End Sub

Sub UnInitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
End Sub

Sub HeapMemoryAllocatorCreated( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
End Sub

Function CreateHeapMemoryAllocator( _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE_FLAG, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)
	If hHeap = NULL Then
		Dim dwError As DWORD = GetLastError()
		*ppv = NULL
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim this As HeapMemoryAllocator Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		SizeOf(HeapMemoryAllocator) _
	)
	
	If this Then
		InitializeHeapMemoryAllocator(this, hHeap)
		HeapMemoryAllocatorCreated(this)
		
		Dim hrQueryInterface As HRESULT = HeapMemoryAllocatorQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyHeapMemoryAllocator(this)
		End If
		
		Return hrQueryInterface
	End If
	
	AllocationFailed(SizeOf(HeapMemoryAllocator))
	
	HeapDestroy(hHeap)
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Sub HeapMemoryAllocatorDestroyed( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
End Sub

Sub DestroyHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)
	
	Dim hHeap As HANDLE = this->hHeap
	
	UnInitializeHeapMemoryAllocator(this)
	
	If hHeap Then
		HeapFree( _
			this->hHeap, _
			HEAP_NO_SERIALIZE_FLAG, _
			this _
		)
		
		Dim resHeapDestroy As BOOL = HeapDestroy(hHeap)
		If resHeapDestroy = 0 Then
		End If
	End If
	
	HeapMemoryAllocatorDestroyed(this)
	
End Sub

Function HeapMemoryAllocatorQueryInterface( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IHeapMemoryAllocator, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_ITimeCounter, riid) Then
			*ppv = @this->lpVtblTimeCounter
		Else
			If IsEqualIID(@IID_IClientSocket, riid) Then
				*ppv = @this->lpVtblClientSocket
			Else
				If IsEqualIID(@IID_IMalloc, riid) Then
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
		End If
	End If
	
	HeapMemoryAllocatorAddRef(this)
	
	Return S_OK
	
End Function

Function HeapMemoryAllocatorAddRef( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function HeapMemoryAllocatorRelease( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	Dim pInterface As IHeapMemoryAllocator Ptr = CPtr(IHeapMemoryAllocator Ptr, @this->lpVtbl)
	ReleaseHeapMemoryAllocatorInstance(pInterface)
	
	Return 0
	
End Function

Function HeapMemoryAllocatorAlloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal BytesCount As SIZE_T_ _
	)As Any Ptr
	
	Dim pMemory As Any Ptr = HeapAlloc( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		BytesCount _
	)
	If pMemory = NULL Then
		AllocationFailed(BytesCount)
	End If
	
	Return pMemory
	
End Function

Sub HeapMemoryAllocatorFree( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)
	
	HeapFree( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pMemory _
	)
	
End Sub

Function HeapMemoryAllocatorGetClientBuffer( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal ppBuffer As ClientRequestBuffer Ptr Ptr _
	)As HRESULT
	
	*ppBuffer = @this->ReadedData
	
	Return S_OK
	
End Function

Function HeapMemoryAllocatorStartWatch( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As HRESULT
	
	GetSystemTimeAsFileTime(@this->datStartOperation)
	
	SetEvent(HungsConnectionsEvent)
	
	Return S_OK
	
End Function
	
Function HeapMemoryAllocatorStopWatch( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As HRESULT
	
	GetSystemTimeAsFileTime(@this->datFinishOperation)
	
	Return S_OK
	
End Function

Function HeapMemoryAllocatorGetSocket( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	*pResult = this->ClientSocket
	
	Return S_OK
	
End Function
	
Function HeapMemoryAllocatorSetSocket( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	
	this->ClientSocket = sock
	
	Return S_OK
	
End Function
	
Function HeapMemoryAllocatorCloseSocket( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As HRESULT
	
	If this->ClientSocket <> INVALID_SOCKET Then
		closesocket(this->ClientSocket)
		this->ClientSocket = INVALID_SOCKET
	End If
	
	Return S_OK
	
End Function


Function IHeapMemoryAllocatorQueryInterface( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(ContainerOf(this, HeapMemoryAllocator, lpVtbl), riid, ppvObject)
End Function

Function IHeapMemoryAllocatorAddRef( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(ContainerOf(this, HeapMemoryAllocator, lpVtbl))
End Function

Function IHeapMemoryAllocatorRelease( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(ContainerOf(this, HeapMemoryAllocator, lpVtbl))
End Function

Function IHeapMemoryAllocatorAlloc( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	Return HeapMemoryAllocatorAlloc(ContainerOf(this, HeapMemoryAllocator, lpVtbl), cb)
End Function

Sub IHeapMemoryAllocatorFree( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	HeapMemoryAllocatorFree(ContainerOf(this, HeapMemoryAllocator, lpVtbl), pv)
End Sub

Function IHeapMemoryAllocatorGetClientBuffer( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal ppBuffer As ClientRequestBuffer Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorGetClientBuffer(ContainerOf(this, HeapMemoryAllocator, lpVtbl), ppBuffer)
End Function

Function ITimeCounterQueryInterface( _
		ByVal this As ITimeCounter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(ContainerOf(this, HeapMemoryAllocator, lpVtblTimeCounter), riid, ppvObject)
End Function

Function ITimeCounterAddRef( _
		ByVal this As ITimeCounter Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(ContainerOf(this, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Function ITimeCounterRelease( _
		ByVal this As ITimeCounter Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(ContainerOf(this, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Function ITimeCounterStartWatch( _
		ByVal this As ITimeCounter Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorStartWatch(ContainerOf(this, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Function ITimeCounterStopWatch( _
		ByVal this As ITimeCounter Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorStopWatch(ContainerOf(this, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Function IClientSocketQueryInterface( _
		ByVal this As IClientSocket Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(ContainerOf(this, HeapMemoryAllocator, lpVtblClientSocket), riid, ppvObject)
End Function

Function IClientSocketAddRef( _
		ByVal this As IClientSocket Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(ContainerOf(this, HeapMemoryAllocator, lpVtblClientSocket))
End Function

Function IClientSocketRelease( _
		ByVal this As IClientSocket Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(ContainerOf(this, HeapMemoryAllocator, lpVtblClientSocket))
End Function

Function IClientSocketGetSocket( _
		ByVal this As IClientSocket Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorGetSocket(ContainerOf(this, HeapMemoryAllocator, lpVtblClientSocket), pResult)
End Function

Function IClientSocketSetSocket( _
		ByVal this As IClientSocket Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	Return HeapMemoryAllocatorSetSocket(ContainerOf(this, HeapMemoryAllocator, lpVtblClientSocket), sock)
End Function

Function IClientSocketCloseSocket( _
		ByVal this As IClientSocket Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorCloseSocket(ContainerOf(this, HeapMemoryAllocator, lpVtblClientSocket))
End Function

Dim GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable = Type( _
	@IHeapMemoryAllocatorQueryInterface, _
	@IHeapMemoryAllocatorAddRef, _
	@IHeapMemoryAllocatorRelease, _
	@IHeapMemoryAllocatorAlloc, _
	NULL, _ /' @IHeapMemoryAllocatorRealloc, _ '/
	@IHeapMemoryAllocatorFree, _
	NULL, _ /' @IHeapMemoryAllocatorGetSize, _ '/
	NULL, _ /' @IHeapMemoryAllocatorDidAlloc, _ '/
	NULL, _ /' @IHeapMemoryAllocatorHeapMinimize, _ '/
	NULL, _ /' RegisterMallocSpy '/
	NULL, _ /' RevokeMallocSpy '/
	@IHeapMemoryAllocatorGetClientBuffer _
)

Dim GlobalTimeCounterVirtualTable As Const ITimeCounterVirtualTable = Type( _
	@ITimeCounterQueryInterface, _
	@ITimeCounterAddRef, _
	@ITimeCounterRelease, _
	@ITimeCounterStartWatch, _
	@ITimeCounterStopWatch _
)

Dim GlobalClientSocketVirtualTable As Const IClientSocketVirtualTable = Type( _
	@IClientSocketQueryInterface, _
	@IClientSocketAddRef, _
	@IClientSocketRelease, _
	@IClientSocketGetSocket, _
	@IClientSocketSetSocket, _
	@IClientSocketCloseSocket _
)
