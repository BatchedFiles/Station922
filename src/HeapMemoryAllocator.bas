#include once "HeapMemoryAllocator.bi"
#include once "crt.bi"
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

Enum PoolItemStatuses
	ItemUsed = -1
	ItemFree = 0
End Enum

Enum ConnectionStatuses
	Closed
	Hungs
	Alive
End Enum

Type HeapMemoryAllocator
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IHeapMemoryAllocatorVirtualTable Ptr
	lpVtblTimeCounter As Const ITimeCounterVirtualTable Ptr
	lpVtblClientSocket As Const IClientSocketVirtualTable Ptr
	ReferenceCounter As UInteger
	hHeap As HANDLE
	ClientSocket As SOCKET
	ItemStatus As PoolItemStatuses
	datStartOperation As FILETIME
	datFinishOperation As FILETIME
End Type

Type MemoryPoolItem
	pMalloc As IHeapMemoryAllocator Ptr
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

Private Sub PrintHeapAllocatorTaken( _
		ByVal hHeap As HANDLE, _
		ByVal FreeSpace As UInteger _
	)

	Const BufSize As Integer = 256
	Const FormatString = WStr(!"MemoryAllocator Instance with Heap %#p taken, free space:")
	Dim buf As WString * BufSize = Any
	wsprintfW( _
		@buf, _
		@FormatString, _
		hHeap _
	)

	Dim vtFreeSpace As VARIANT = Any
	vtFreeSpace.vt = VT_I4
	vtFreeSpace.lVal = CLng(FreeSpace)
	LogWriteEntry( _
		LogEntryType.Debug, _
		buf, _
		@vtFreeSpace _
	)

End Sub

Private Sub PrintWalkingHeapString( _
		ByVal hHeap As HANDLE _
	)

	Const BufSize As Integer = 256
	Const FormatString = WStr(!"Walking heap %#p...\r\n")
	Dim buf As WString * BufSize = Any
	wsprintfW( _
		@buf, _
		@FormatString, _
		hHeap _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		@buf, _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintAllocatedBlockString( _
		ByVal pMem As Any Ptr _
	)

	Dim IdString As ZString * 17 = Any
	CopyMemory( _
		@IdString, _
		pMem, _
		16 _
	)
	IdString[16] = 0

	Const BufSize As Integer = 256
	Const FormatString = WStr(!"Allocated block\t\t%hs\r\n")
	Dim buf As WString * BufSize = Any
	wsprintfW( _
		@buf, _
		@FormatString, _
		@IdString _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		@buf, _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintMovableWithHANDLEString( _
		ByVal hMem As Any Ptr _
	)

	Const BufSize As Integer = 256
	Const FormatString = WStr(!"\tMovable with HANDLE %#p\r\n")

	Dim buf As WString * BufSize = Any
	wsprintfW( _
		@buf, _
		@FormatString, _
		hMem _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		@buf, _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintDdeShareString( _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		WStr(!"\tDDESHARE\r\n"), _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintRegionString( _
		ByVal dwCommittedSize As DWORD, _
		ByVal dwUnCommittedSize As DWORD, _
		ByVal FirstBlockOffset As Integer, _
		ByVal LastBlockOffset As Integer _
	)

	Const BufSize As Integer = 256
	Const FormatString = WStr(!"Region\r\n\t%d bytes committed\r\n\t%d bytes uncommitted\r\n\tFirst block offset:\t0x%04X\r\n\tLast block offset:\t0x%04X\r\n")

	Dim buf As WString * BufSize = Any
	wsprintfW( _
		@buf, _
		@FormatString, _
		dwCommittedSize, _
		dwUnCommittedSize, _
		FirstBlockOffset, _
		LastBlockOffset _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		@buf, _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintUncommitedRangeString( _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		WStr(!"Uncommitted range\r\n"), _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintFreeBlockString( _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		WStr(!"Free block\r\n"), _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintDataPortionString( _
		ByVal DataOffset As Integer, _
		ByVal cbData As Integer, _
		ByVal cbOverhead As Integer, _
		ByVal iRegionIndex As Integer _
	)

	Const BufSize As Integer = 256
	Const FormatString = WStr(!"\tData portion begins at:\t0x%04X\r\n\tSize:\t\t%d bytes\r\n\tOverhead:\t%d bytes\r\n\tRegion index:\t%d\r\n")

	Dim buf As WString * BufSize = Any
	wsprintfW( _
		@buf, _
		@FormatString, _
		DataOffset, _
		cbData, _
		cbOverhead, _
		iRegionIndex _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		@buf, _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintNewLineString( _
	)

	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Debug, _
		WStr(!"\r\n"), _
		@vtAllocatedBytes _
	)

End Sub

Private Sub PrintAllocationFailed( _
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

Private Sub PrintWalkingHeap( _
		ByVal hHeap As HANDLE _
	)

	PrintWalkingHeapString(hHeap)

	Dim Entry As PROCESS_HEAP_ENTRY = Any
	Entry.lpData = NULL

	Dim resWalk As BOOL = HeapWalk(hHeap, @Entry)

	Do While resWalk <> 0

		Dim IsAllocatedBlock As Integer = Entry.wFlags And PROCESS_HEAP_ENTRY_BUSY

		If IsAllocatedBlock Then

			PrintAllocatedBlockString(Entry.lpData)

			Dim MovableFlag As Integer = Entry.wFlags And PROCESS_HEAP_ENTRY_MOVEABLE

			If MovableFlag Then
				PrintMovableWithHANDLEString(Entry.Block.hMem)
			End If

			Dim DdeShareFlag As Integer = Entry.wFlags And PROCESS_HEAP_ENTRY_DDESHARE

			If DdeShareFlag Then
				PrintDdeShareString()
			End If
		Else
			Dim IsRegion As Integer = Entry.wFlags And PROCESS_HEAP_REGION

			If IsRegion Then
				Dim FirstBlockOffset As Integer = Entry.Region.lpFirstBlock - hHeap
				Dim LastBlockOffset As Integer = Entry.Region.lpLastBlock - hHeap
				PrintRegionString( _
					Entry.Region.dwCommittedSize, _
					Entry.Region.dwUnCommittedSize, _
					FirstBlockOffset, _
					LastBlockOffset _
				)
			Else
				Dim IsUncommitted As Integer = Entry.wFlags And PROCESS_HEAP_UNCOMMITTED_RANGE

				If IsUncommitted Then
					PrintUncommitedRangeString()
				Else
					PrintFreeBlockString()
				End If
			End If
		End If

		Dim DataOffset As Integer = Entry.lpData - hHeap
		PrintDataPortionString( _
			DataOffset, _
			Entry.cbData, _
			Entry.cbOverhead, _
			Entry.iRegionIndex _
		)

		resWalk = HeapWalk(hHeap, @Entry)
	Loop

	PrintNewLineString()

End Sub

Private Function HeapMemoryAllocatorCloseSocket( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As HRESULT

	If this->ClientSocket <> INVALID_SOCKET Then
		closesocket(this->ClientSocket)
		this->ClientSocket = INVALID_SOCKET
	End If

	Return S_OK

End Function

Private Sub HeapMemoryAllocatorResetState( _
		ByVal this As HeapMemoryAllocator Ptr _
	)

	HeapMemoryAllocatorCloseSocket(this)

	' Restore the original state of the reference counter
	' Beecause number of reference is equal to one
	this->ReferenceCounter = 1

	GetSystemTimeAsFileTime(@this->datStartOperation)
	GetSystemTimeAsFileTime(@this->datFinishOperation)

	this->ItemStatus = PoolItemStatuses.ItemFree

End Sub

Private Sub UnInitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)

	If this->hHeap Then
		HeapDestroy(this->hHeap)
	End If

End Sub

Private Sub HeapMemoryAllocatorDestroyed( _
		ByVal this As HeapMemoryAllocator Ptr _
	)

End Sub

Private Sub DestroyHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr _
	)

	UnInitializeHeapMemoryAllocator(this)

	HeapMemoryAllocatorDestroyed(this)

End Sub

Private Sub ReleaseHeapMemoryAllocatorInstance( _
		ByVal pMalloc As IHeapMemoryAllocator Ptr _
	)

	EnterCriticalSection(@MemoryPoolObject.crSection)
	For i As UInteger = 0 To MemoryPoolObject.Capacity - 1
		var localMalloc = MemoryPoolObject.Items[i].pMalloc
		If localMalloc = pMalloc Then

			Dim this As HeapMemoryAllocator Ptr = CONTAINING_RECORD(localMalloc, HeapMemoryAllocator, lpVtbl)

			MemoryPoolObject.Length -= 1

			#if __FB_DEBUG__
				PrintWalkingHeap(this->hHeap)

				Const BufSize As Integer = 256
				Const FormatString = WStr(!"MemoryAllocator Instance with Heap %#p released, free space:")
				Dim buf As WString * BufSize = Any
				wsprintfW( _
					@buf, _
					@FormatString, _
					this->hHeap _
				)

				Dim FreeSpace As UInteger = MemoryPoolObject.Capacity - MemoryPoolObject.Length

				Dim vtFreeSpace As VARIANT = Any
				vtFreeSpace.vt = VT_I4
				vtFreeSpace.lVal = CLng(FreeSpace)

				LogWriteEntry( _
					LogEntryType.Debug, _
					buf, _
					@vtFreeSpace _
				)
			#endif

			HeapMemoryAllocatorResetState(this)

			Exit For
		End If
	Next
	LeaveCriticalSection(@MemoryPoolObject.crSection)

End Sub

Public Function GetHeapMemoryAllocatorInstance( _
	)As IHeapMemoryAllocator Ptr

	Dim PoolLength As UInteger = MemoryPoolObject.Length
	Dim PoolCapacity As UInteger = MemoryPoolObject.Capacity

	If PoolLength < PoolCapacity Then
		Dim pMalloc As IHeapMemoryAllocator Ptr = NULL

		EnterCriticalSection(@MemoryPoolObject.crSection)
		For i As UInteger = 0 To MemoryPoolObject.Capacity - 1
			var localMalloc = MemoryPoolObject.Items[i].pMalloc
			Dim this As HeapMemoryAllocator Ptr = CONTAINING_RECORD(localMalloc, HeapMemoryAllocator, lpVtbl)

			If this->ItemStatus = PoolItemStatuses.ItemFree Then

				this->ItemStatus = PoolItemStatuses.ItemUsed
				MemoryPoolObject.Length += 1

				pMalloc = MemoryPoolObject.Items[i].pMalloc

				#if __FB_DEBUG__
					Dim FreeSpace As UInteger = MemoryPoolObject.Capacity - MemoryPoolObject.Length
					PrintHeapAllocatorTaken(this->hHeap, FreeSpace)
				#endif

				Exit For
			End If
		Next
		LeaveCriticalSection(@MemoryPoolObject.crSection)

		' We do not increase the reference counter to the object
		' to track the lifetime
		' When the object reference count reaches zero
		' the Release function returns the object to the object pool
		Return pMalloc
	End If

	Return NULL

End Function

Private Sub InitializeHeapMemoryAllocator( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_HEAPMEMORYALLOCATOR), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalHeapMemoryAllocatorVirtualTable
	this->lpVtblTimeCounter = @GlobalTimeCounterVirtualTable
	this->lpVtblClientSocket = @GlobalClientSocketVirtualTable
	this->ReferenceCounter = 0
	this->hHeap = hHeap
	this->ClientSocket = INVALID_SOCKET
	GetSystemTimeAsFileTime(@this->datStartOperation)
	GetSystemTimeAsFileTime(@this->datFinishOperation)
	this->ItemStatus = PoolItemStatuses.ItemFree

End Sub

Private Sub HeapMemoryAllocatorCreated( _
		ByVal this As HeapMemoryAllocator Ptr _
	)

End Sub

Private Function HeapMemoryAllocatorAddRef( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function HeapMemoryAllocatorRelease( _
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

Private Function HeapMemoryAllocatorQueryInterface( _
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

Private Function CreateHeapMemoryAllocator( _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE_FLAG, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)

	If hHeap Then
		Dim this As HeapMemoryAllocator Ptr = HeapAlloc( _
			hHeap, _
			HEAP_NO_SERIALIZE_FLAG, _
			SizeOf(HeapMemoryAllocator) _
		)

		If this Then

			InitializeHeapMemoryAllocator( _
				this, _
				hHeap _
			)
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

		HeapDestroy(hHeap)
	End If

	PrintAllocationFailed(SizeOf(HeapMemoryAllocator))

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function HeapMemoryAllocatorAlloc( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal BytesCount As SIZE_T_ _
	)As Any Ptr

	Dim pMemory As Any Ptr = HeapAlloc( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		BytesCount _
	)
	If pMemory = NULL Then
		PrintAllocationFailed(BytesCount)
	End If

	Return pMemory

End Function

Private Sub HeapMemoryAllocatorFree( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)

	HeapFree( _
		this->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pMemory _
	)

End Sub

Private Function HeapMemoryAllocatorStartWatch( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As HRESULT

	GetSystemTimeAsFileTime(@this->datStartOperation)

	SetEvent(HungsConnectionsEvent)

	Return S_OK

End Function

Private Function HeapMemoryAllocatorStopWatch( _
		ByVal this As HeapMemoryAllocator Ptr _
	)As HRESULT

	GetSystemTimeAsFileTime(@this->datFinishOperation)

	Return S_OK

End Function

Private Function HeapMemoryAllocatorGetSocket( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT

	*pResult = this->ClientSocket

	Return S_OK

End Function

Private Function HeapMemoryAllocatorSetSocket( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT

	this->ClientSocket = sock

	Return S_OK

End Function

Private Function MemoryPoolCloseHungsConnections( _
		ByVal this As HeapMemoryAllocator Ptr, _
		ByVal KeepAliveInterval As Integer _
	)As ConnectionStatuses

	If this->ClientSocket = INVALID_SOCKET Then
		Return ConnectionStatuses.Closed
	End If

	Dim nsElapsedTime As ULongInt = Any
	Scope
		Dim ulStart As ULARGE_INTEGER = Any
		ulStart.LowPart = this->datStartOperation.dwLowDateTime
		ulStart.HighPart = this->datStartOperation.dwHighDateTime

		Dim datCurrent As FILETIME = Any
		GetSystemTimeAsFileTime(@datCurrent)

		Dim ulFinish As ULARGE_INTEGER = Any
		ulFinish.LowPart = datCurrent.dwLowDateTime
		ulFinish.HighPart = datCurrent.dwHighDateTime

		nsElapsedTime = ulFinish.QuadPart - ulStart.QuadPart
	End Scope

	' 10 nanoseconds * 1000 microseconds * 1000 milliseconds
	Dim ulKeepAliveInterval As ULongInt = CUlngInt(KeepAliveInterval)

	#if __FB_DEBUG__
		Dim nsKeepAliveInterval As ULongInt = ulKeepAliveInterval
		' Elapsed time in seconds
		nsElapsedTime \= 10 * 1000 * 1000
	#else
		' KeepAlive time in nanoseconds
		Dim nsKeepAliveInterval As ULongInt = 10 * 1000 * 1000 * ulKeepAliveInterval
	#endif

	If nsElapsedTime > nsKeepAliveInterval Then
		HeapMemoryAllocatorCloseSocket(this)
		Return ConnectionStatuses.Hungs
	End If

	Return ConnectionStatuses.Alive

End Function

Private Function CheckHungsConnections( _
		ByVal KeepAliveInterval As Integer _
	)As HRESULT

	Const msTimeToHungsConnection As DWORD = 1000 * 60

	Do
		Dim resWait As DWORD = SleepEx(msTimeToHungsConnection, TRUE)

		If resWait = WAIT_IO_COMPLETION Then
			' Return signal to I/O completion callback
			Return E_FAIL
		End If

		If MemoryPoolObject.Length = 0 Then
			Return S_OK
		End If

		Dim IsPoolFree As Boolean = True

		Dim PoolCapacity As UInteger = MemoryPoolObject.Capacity

		EnterCriticalSection(@MemoryPoolObject.crSection)
		For i As UInteger = 0 To PoolCapacity - 1
			var localMalloc = MemoryPoolObject.Items[i].pMalloc
			Dim this As HeapMemoryAllocator Ptr = CONTAINING_RECORD(localMalloc, HeapMemoryAllocator, lpVtbl)

			If this->ItemStatus = PoolItemStatuses.ItemUsed Then

				Dim resClose As ConnectionStatuses = MemoryPoolCloseHungsConnections( _
					this, _
					KeepAliveInterval _
				)

				Select Case resClose

					Case ConnectionStatuses.Closed
						MemoryPoolObject.Length -= 1

						#if __FB_DEBUG__
							PrintWalkingHeap(this->hHeap)

							Const BufSize As Integer = 256
							Const FormatString = WStr(!"MemoryAllocator Instance with Heap %#p forcely closed, free space:")
							Dim buf As WString * BufSize = Any
							wsprintfW( _
								@buf, _
								@FormatString, _
								this->hHeap _
							)

							Dim FreeSpace As UInteger = MemoryPoolObject.Capacity - MemoryPoolObject.Length

							Dim vtFreeSpace As VARIANT = Any
							vtFreeSpace.vt = VT_I4
							vtFreeSpace.lVal = CLng(FreeSpace)

							LogWriteEntry( _
								LogEntryType.Debug, _
								buf, _
								@vtFreeSpace _
							)
						#endif

						HeapMemoryAllocatorResetState(this)

					Case ConnectionStatuses.Hungs
						IsPoolFree = False

					Case ConnectionStatuses.Alive
						IsPoolFree = False

				End Select

			End If
		Next
		LeaveCriticalSection(@MemoryPoolObject.crSection)

		If IsPoolFree Then
			Return S_OK
		End If

	Loop

	Return S_OK

End Function

Private Function ClearingThread( _
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
			' Function returned due to I/O completion callback
			' This is a signal to complete the process
			' Need to close Event, Thread and exit from thread
			CloseHandle(HungsConnectionsThread)
			CloseHandle(HungsConnectionsEvent)
			Return 0
		End If

		Dim hrCheck As HRESULT = CheckHungsConnections(KeepAliveInterval)

		If FAILED(hrCheck) Then
			' This is a signal to complete the process
			' Need to close Event, Thread and exit from thread
			CloseHandle(HungsConnectionsThread)
			CloseHandle(HungsConnectionsEvent)
			Return 0
		End If

		Dim resReset As BOOL = ResetEvent(HungsConnectionsEvent)
		If resReset = 0 Then
			Return 1
		End If
	Loop

	Return 0

End Function

Private Sub WakeupClearingThread( _
		ByVal Parameter As ULONG_PTR _
	)

End Sub

Public Function CreateMemoryPool( _
		ByVal Capacity As UInteger, _
		ByVal KeepAliveInterval As Integer _
	)As HRESULT

	If Capacity = 0 Then
		Return E_OUTOFMEMORY
	End If

	MemoryPoolObject.Capacity = Capacity
	MemoryPoolObject.Length = 0

	Scope
		Const dwSpinCount As DWORD = 4000
		Dim resInitialize As BOOL = InitializeCriticalSectionAndSpinCount( _
			@MemoryPoolObject.crSection, _
			dwSpinCount _
		)
		If resInitialize = 0 Then
			Dim dwError As DWORD = GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If
	End Scope

	Scope
		Dim hHeap As HANDLE = GetProcessHeap()
		MemoryPoolObject.Items = HeapAlloc( _
			hHeap, _
			0, _
			SizeOf(MemoryPoolItem) * Capacity _
		)
		If MemoryPoolObject.Items = NULL Then
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
		Next
	End Scope

	Scope
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
			CloseHandle(HungsConnectionsEvent)
			Return E_OUTOFMEMORY
		End If
	End Scope

	Return S_OK

End Function

Public Sub DeleteMemoryPool()

	QueueUserAPC( _
		@WakeupClearingThread, _
		HungsConnectionsThread, _
		0 _
	)

End Sub


Private Function IHeapMemoryAllocatorQueryInterface( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtbl), riid, ppvObject)
End Function

Private Function IHeapMemoryAllocatorAddRef( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtbl))
End Function

Private Function IHeapMemoryAllocatorRelease( _
		ByVal this As IHeapMemoryAllocator Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtbl))
End Function

Private Function IHeapMemoryAllocatorAlloc( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	Return HeapMemoryAllocatorAlloc(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtbl), cb)
End Function

Private Sub IHeapMemoryAllocatorFree( _
		ByVal this As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	HeapMemoryAllocatorFree(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtbl), pv)
End Sub

Private Function ITimeCounterQueryInterface( _
		ByVal this As ITimeCounter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblTimeCounter), riid, ppvObject)
End Function

Private Function ITimeCounterAddRef( _
		ByVal this As ITimeCounter Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Private Function ITimeCounterRelease( _
		ByVal this As ITimeCounter Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Private Function ITimeCounterStartWatch( _
		ByVal this As ITimeCounter Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorStartWatch(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Private Function ITimeCounterStopWatch( _
		ByVal this As ITimeCounter Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorStopWatch(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Private Function IClientSocketQueryInterface( _
		ByVal this As IClientSocket Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblClientSocket), riid, ppvObject)
End Function

Private Function IClientSocketAddRef( _
		ByVal this As IClientSocket Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblClientSocket))
End Function

Private Function IClientSocketRelease( _
		ByVal this As IClientSocket Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblClientSocket))
End Function

Private Function IClientSocketGetSocket( _
		ByVal this As IClientSocket Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorGetSocket(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblClientSocket), pResult)
End Function

Private Function IClientSocketSetSocket( _
		ByVal this As IClientSocket Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	Return HeapMemoryAllocatorSetSocket(CONTAINING_RECORD(this, HeapMemoryAllocator, lpVtblClientSocket), sock)
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
	NULL _  /' RevokeMallocSpy '/
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
	@IClientSocketSetSocket _
)
