#include once "HeapMemoryAllocator.bi"
#include once "crt.bi"
#include once "ITimeCounter.bi"
#include once "Logger.bi"

Extern GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable
Extern GlobalTimeCounterVirtualTable As Const ITimeCounterVirtualTable

Const MEMORY_ALLOCATION_GRANULARITY As DWORD = 64 * 1024

Const PRIVATEHEAP_INITIALSIZE As DWORD = 0
Const PRIVATEHEAP_MAXIMUMSIZE As DWORD = MEMORY_ALLOCATION_GRANULARITY

Const HEAP_NO_SERIALIZE_FLAG = HEAP_NO_SERIALIZE

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
	ReferenceCounter As UInteger
	hHeap As HANDLE
	ClientSocket As SOCKET
	datStartOperation As FILETIME
	datFinishOperation As FILETIME
End Type

Enum PoolItemStatuses
	ItemUsed = -1
	ItemFree = 0
End Enum

Enum PoolStatuses
	PoolEmpty = -1
	PoolUsed = 0
End Enum

Type MemoryPoolItem
	pMalloc As HeapMemoryAllocator Ptr
	ItemStatus As PoolItemStatuses
End Type

Type MemoryPool
	crSection As CRITICAL_SECTION
	Items As MemoryPoolItem Ptr
	Capacity As Integer
	Length As Integer
	HungsConnectionsEvent As HANDLE
	HungsConnectionsThread As HANDLE
	KeepAliveInterval As Integer
End Type

Dim Shared pMemoryPool As MemoryPool

Private Sub PrintHeapAllocatorTaken( _
		ByVal hHeap As HANDLE, _
		ByVal FreeSpace As Integer _
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
	Const FormatString = WStr(!"Region\r\n\t%d bytes committed\r\n\t%d bytes uncommitted\r\n\tFirst block offset:\t0x%04X\r\n\tLast block offset:\t0x%04X\r\nHeap header\r\n")

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

Private Sub DebugWalkingHeap( _
		ByVal hHeap As HANDLE _
	)

	PrintWalkingHeap(hHeap)

	Const BufSize As Integer = 256
	Const FormatString = WStr(!"MemoryAllocator Instance with Heap %#p released, free space:")
	Dim buf As WString * BufSize = Any
	wsprintfW( _
		@buf, _
		@FormatString, _
		hHeap _
	)

	Dim FreeSpace As Integer = pMemoryPool.Capacity - pMemoryPool.Length

	Dim vtFreeSpace As VARIANT = Any
	vtFreeSpace.vt = VT_I4
	vtFreeSpace.lVal = CLng(FreeSpace)

	LogWriteEntry( _
		LogEntryType.Debug, _
		buf, _
		@vtFreeSpace _
	)

End Sub

Private Function HeapMemoryAllocatorCloseSocket( _
		ByVal self As HeapMemoryAllocator Ptr _
	)As HRESULT

	If self->ClientSocket <> INVALID_SOCKET Then
		closesocket(self->ClientSocket)
		self->ClientSocket = INVALID_SOCKET
	End If

	Return S_OK

End Function

Private Sub HeapMemoryAllocatorResetState( _
		ByVal self As HeapMemoryAllocator Ptr _
	)

	HeapMemoryAllocatorCloseSocket(self)

	GetSystemTimeAsFileTime(@self->datStartOperation)
	GetSystemTimeAsFileTime(@self->datFinishOperation)

End Sub

Private Sub UnInitializeHeapMemoryAllocator( _
		ByVal self As HeapMemoryAllocator Ptr _
	)

	If self->hHeap Then
		HeapDestroy(self->hHeap)
	End If

End Sub

Private Sub DestroyHeapMemoryAllocator( _
		ByVal self As HeapMemoryAllocator Ptr _
	)

	UnInitializeHeapMemoryAllocator(self)

End Sub

Private Sub HeapMemoryAllocatorReturnToPool( _
		ByVal self As HeapMemoryAllocator Ptr _
	)

	EnterCriticalSection(@pMemoryPool.crSection)
	For i As Integer = 0 To pMemoryPool.Capacity - 1
		var localMalloc = pMemoryPool.Items[i].pMalloc

		If localMalloc = self Then

			HeapMemoryAllocatorResetState(self)

			pMemoryPool.Length -= 1
			pMemoryPool.Items[i].ItemStatus = PoolItemStatuses.ItemFree

			#if __FB_DEBUG__
				DebugWalkingHeap(self->hHeap)
			#endif

			Exit For
		End If
	Next
	LeaveCriticalSection(@pMemoryPool.crSection)

End Sub

Private Sub InitializeHeapMemoryAllocator( _
		ByVal self As HeapMemoryAllocator Ptr, _
		ByVal hHeap As HANDLE _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_HEAPMEMORYALLOCATOR), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalHeapMemoryAllocatorVirtualTable
	self->lpVtblTimeCounter = @GlobalTimeCounterVirtualTable
	self->ReferenceCounter = 0
	self->hHeap = hHeap
	self->ClientSocket = INVALID_SOCKET
	GetSystemTimeAsFileTime(@self->datStartOperation)
	GetSystemTimeAsFileTime(@self->datFinishOperation)

End Sub

Private Function HeapMemoryAllocatorAddRef( _
		ByVal self As HeapMemoryAllocator Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function HeapMemoryAllocatorRelease( _
		ByVal self As HeapMemoryAllocator Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	HeapMemoryAllocatorReturnToPool(self)

	Return 0

End Function

Private Function HeapMemoryAllocatorQueryInterface( _
		ByVal self As HeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IHeapMemoryAllocator, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_ITimeCounter, riid) Then
			*ppv = @self->lpVtblTimeCounter
		Else
			If IsEqualIID(@IID_IMalloc, riid) Then
				*ppv = @self->lpVtbl
			Else
				If IsEqualIID(@IID_IUnknown, riid) Then
					*ppv = @self->lpVtbl
				Else
					*ppv = NULL
					Return E_NOINTERFACE
				End If
			End If
		End If
	End If

	HeapMemoryAllocatorAddRef(self)

	Return S_OK

End Function

Private Function CreateHeapMemoryAllocator( _
	)As HeapMemoryAllocator Ptr

	Dim hHeap As HANDLE = HeapCreate( _
		HEAP_NO_SERIALIZE_FLAG, _
		PRIVATEHEAP_INITIALSIZE, _
		PRIVATEHEAP_MAXIMUMSIZE _
	)

	If hHeap Then
		Dim self As HeapMemoryAllocator Ptr = HeapAlloc( _
			hHeap, _
			HEAP_NO_SERIALIZE_FLAG, _
			SizeOf(HeapMemoryAllocator) _
		)

		If self Then

			InitializeHeapMemoryAllocator( _
				self, _
				hHeap _
			)

			Return self
		End If

		HeapDestroy(hHeap)
	End If

	PrintAllocationFailed(SizeOf(HeapMemoryAllocator))

	Return NULL

End Function

Private Function HeapMemoryAllocatorAlloc( _
		ByVal self As HeapMemoryAllocator Ptr, _
		ByVal BytesCount As SIZE_T_ _
	)As Any Ptr

	Dim pMemory As Any Ptr = HeapAlloc( _
		self->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		BytesCount _
	)
	If pMemory = NULL Then
		PrintAllocationFailed(BytesCount)
	End If

	Return pMemory

End Function

Private Function HeapMemoryAllocatorRealloc( _
		ByVal self As HeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr, _
		ByVal BytesCount As SIZE_T_ _
	)As Any Ptr

	Dim pMemory As Any Ptr = HeapReAlloc( _
		self->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pv, _
		BytesCount _
	)
	If pMemory = NULL Then
		PrintAllocationFailed(BytesCount)
	End If

	Return pMemory

End Function

Private Sub HeapMemoryAllocatorFree( _
		ByVal self As HeapMemoryAllocator Ptr, _
		ByVal pMemory As Any Ptr _
	)

	HeapFree( _
		self->hHeap, _
		HEAP_NO_SERIALIZE_FLAG, _
		pMemory _
	)

End Sub

Private Function HeapMemoryAllocatorStartWatch( _
		ByVal self As HeapMemoryAllocator Ptr _
	)As HRESULT

	GetSystemTimeAsFileTime(@self->datStartOperation)

	SetEvent(pMemoryPool.HungsConnectionsEvent)

	Return S_OK

End Function

Private Function HeapMemoryAllocatorStopWatch( _
		ByVal self As HeapMemoryAllocator Ptr _
	)As HRESULT

	GetSystemTimeAsFileTime(@self->datFinishOperation)

	Return S_OK

End Function

Private Function GetElapsedTime( _
		ByVal datStartOperation As FILETIME _
	) As ULongInt

	Dim ulStart As ULARGE_INTEGER = Any
	ulStart.LowPart = datStartOperation.dwLowDateTime
	ulStart.HighPart = datStartOperation.dwHighDateTime

	Dim datCurrent As FILETIME = Any
	GetSystemTimeAsFileTime(@datCurrent)

	Dim ulFinish As ULARGE_INTEGER = Any
	ulFinish.LowPart = datCurrent.dwLowDateTime
	ulFinish.HighPart = datCurrent.dwHighDateTime

	Dim nsElapsedTime As ULongInt = ulFinish.QuadPart - ulStart.QuadPart

	Return nsElapsedTime

End Function

Private Function HeapMemoryAllocatorGetConnectionStatus( _
		ByVal self As HeapMemoryAllocator Ptr, _
		ByVal KeepAliveInterval As Integer _
	)As ConnectionStatuses

	If self->ClientSocket = INVALID_SOCKET Then
		Return ConnectionStatuses.Closed
	End If

	Dim nsElapsedTime As ULongInt = GetElapsedTime(self->datStartOperation)

	' KeepAlive time in nanoseconds
	Dim ulKeepAliveInterval As ULongInt = CUlngInt(KeepAliveInterval)
	' 10 nanoseconds * 1000 microseconds * 1000 milliseconds
	Dim nsKeepAliveInterval As ULongInt = 10 * 1000 * 1000 * ulKeepAliveInterval

	Dim cmp As Boolean = nsElapsedTime > nsKeepAliveInterval

	If cmp Then
		Return ConnectionStatuses.Hungs
	End If

	Return ConnectionStatuses.Alive

End Function

Private Function MemoryPoolCloseHungsConnections( _
		ByVal KeepAliveInterval As Integer _
	)As PoolStatuses

	If pMemoryPool.Length = 0 Then
		Return PoolStatuses.PoolEmpty
	End If

	Dim IsPoolEmpty As Boolean = True

	Dim PoolCapacity As Integer = pMemoryPool.Capacity

	For i As Integer = 0 To PoolCapacity - 1

		If pMemoryPool.Items[i].ItemStatus = PoolItemStatuses.ItemUsed Then

			var self = pMemoryPool.Items[i].pMalloc

			Dim resClose As ConnectionStatuses = HeapMemoryAllocatorGetConnectionStatus( _
				self, _
				KeepAliveInterval _
			)

			Select Case resClose

				Case ConnectionStatuses.Closed

				Case ConnectionStatuses.Hungs
					IsPoolEmpty = False
					HeapMemoryAllocatorCloseSocket(self)

					#if __FB_DEBUG__
						Const BufSize As Integer = 256
						Const FormatString = WStr(!"MemoryAllocator Instance with Heap %#p forcely closed\r\n")
						Dim buf As WString * BufSize = Any
						wsprintfW( _
							@buf, _
							@FormatString, _
							self->hHeap _
						)

						Dim vtAllocatedBytes As VARIANT = Any
						vtAllocatedBytes.vt = VT_EMPTY
						LogWriteEntry( _
							LogEntryType.Debug, _
							@buf, _
							@vtAllocatedBytes _
						)
					#endif

				Case ConnectionStatuses.Alive
					IsPoolEmpty = False

			End Select

		End If
	Next

	If IsPoolEmpty Then
		Return PoolStatuses.PoolEmpty
	End If

	Return PoolStatuses.PoolUsed

End Function

Private Function ClearingThread( _
		ByVal lpParam As LPVOID _
	)As DWORD

	Dim dwInterval As DWORD = Cast(DWORD, pMemoryPool.KeepAliveInterval)
	Dim msTimeToHungsConnection As DWORD = 1000 * dwInterval

	Do
		Dim resWait As DWORD = WaitForSingleObjectEx( _
			pMemoryPool.HungsConnectionsEvent, _
			INFINITE, _
			TRUE _
		)

		If resWait <> WAIT_OBJECT_0 Then
			' Function returned due to I/O completion callback
			' self is a signal to complete the process
			' Need to close Event, Thread and exit from thread
			CloseHandle(pMemoryPool.HungsConnectionsThread)
			CloseHandle(pMemoryPool.HungsConnectionsEvent)
			Return 0
		End If

		Do
			Dim resWait As DWORD = SleepEx(msTimeToHungsConnection, TRUE)

			If resWait = WAIT_IO_COMPLETION Then
				' Return signal to I/O completion callback
				' self is a signal to complete the process
				' Need to close Event, Thread and exit from thread
				CloseHandle(pMemoryPool.HungsConnectionsThread)
				CloseHandle(pMemoryPool.HungsConnectionsEvent)
				Return 0
			End If

			var status = MemoryPoolCloseHungsConnections(pMemoryPool.KeepAliveInterval)

			If status = PoolStatuses.PoolEmpty Then

				Dim resReset As BOOL = ResetEvent(pMemoryPool.HungsConnectionsEvent)
				If resReset = 0 Then
					Return 1
				End If

				Exit Do
			End If

		Loop

	Loop

	Return 0

End Function

Private Sub WakeupClearingProc( _
		ByVal Parameter As ULONG_PTR _
	)

End Sub

Public Function CreateMemoryPool( _
		ByVal Capacity As Integer, _
		ByVal KeepAliveInterval As Integer _
	)As HRESULT

	If Capacity = 0 Then
		Return E_OUTOFMEMORY
	End If

	pMemoryPool.Capacity = Capacity
	pMemoryPool.Length = 0
	pMemoryPool.KeepAliveInterval = KeepAliveInterval

	Scope
		Const dwSpinCount As DWORD = 4000
		Dim resInitialize As BOOL = InitializeCriticalSectionAndSpinCount( _
			@pMemoryPool.crSection, _
			dwSpinCount _
		)
		If resInitialize = 0 Then
			Dim dwError As DWORD = GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If
	End Scope

	Scope
		pMemoryPool.Items = Allocate( _
			SizeOf(MemoryPoolItem) * Capacity _
		)
		If pMemoryPool.Items = NULL Then
			Return E_OUTOFMEMORY
		End If

		For i As Integer = 0 To Capacity - 1
			Dim pMalloc As HeapMemoryAllocator Ptr = CreateHeapMemoryAllocator()

			If pMalloc = NULL Then
				Return E_OUTOFMEMORY
			End If

			pMemoryPool.Items[i].pMalloc = pMalloc
			pMemoryPool.Items[i].ItemStatus = PoolItemStatuses.ItemFree
		Next
	End Scope

	Scope
		pMemoryPool.HungsConnectionsEvent = CreateEventW( _
			NULL, _
			TRUE, _
			FALSE, _
			NULL _
		)
		If pMemoryPool.HungsConnectionsEvent = NULL Then
			Return E_OUTOFMEMORY
		End If

		Const DefaultStackSize As SIZE_T_ = 0
		pMemoryPool.HungsConnectionsThread = CreateThread( _
			NULL, _
			DefaultStackSize, _
			@ClearingThread, _
			NULL, _
			0, _
			NULL _
		)
		If pMemoryPool.HungsConnectionsThread = NULL Then
			CloseHandle(pMemoryPool.HungsConnectionsEvent)
			Return E_OUTOFMEMORY
		End If
	End Scope

	Return S_OK

End Function

Public Sub DeleteMemoryPool()

	QueueUserAPC( _
		@WakeupClearingProc, _
		pMemoryPool.HungsConnectionsThread, _
		0 _
	)

End Sub

Public Function GetHeapMemoryAllocatorInstance( _
		ByVal ClientSocket As SOCKET _
	)As IMalloc Ptr

	Dim PoolLength As Integer = pMemoryPool.Length
	Dim PoolCapacity As Integer = pMemoryPool.Capacity

	If PoolLength >= PoolCapacity Then
		Return NULL
	End If

	Dim pMalloc As HeapMemoryAllocator Ptr = NULL

	EnterCriticalSection(@pMemoryPool.crSection)
	For i As Integer = 0 To pMemoryPool.Capacity - 1

		If pMemoryPool.Items[i].ItemStatus = PoolItemStatuses.ItemFree Then

			pMemoryPool.Items[i].ItemStatus = PoolItemStatuses.ItemUsed
			pMemoryPool.Length += 1

			pMalloc = pMemoryPool.Items[i].pMalloc

			Exit For
		End If
	Next
	LeaveCriticalSection(@pMemoryPool.crSection)

	If pMalloc Then
		pMalloc->ClientSocket = ClientSocket

		#if __FB_DEBUG__
			Dim FreeSpace As Integer = pMemoryPool.Capacity - pMemoryPool.Length
			PrintHeapAllocatorTaken(pMalloc->hHeap, FreeSpace)
		#endif

		Dim pIMalloc As IMalloc Ptr = Any
		HeapMemoryAllocatorQueryInterface( _
			pMalloc, _
			@IID_IMalloc, _
			@pIMalloc _
		)

		Return pIMalloc
	End If

	Return NULL

End Function


Private Function IHeapMemoryAllocatorQueryInterface( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtbl), riid, ppvObject)
End Function

Private Function IHeapMemoryAllocatorAddRef( _
		ByVal self As IHeapMemoryAllocator Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtbl))
End Function

Private Function IHeapMemoryAllocatorRelease( _
		ByVal self As IHeapMemoryAllocator Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtbl))
End Function

Private Function IHeapMemoryAllocatorAlloc( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	Return HeapMemoryAllocatorAlloc(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtbl), cb)
End Function

Private Function IHeapMemoryAllocatorRealloc( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr, _
		ByVal cb As SIZE_T_ _
	)As Any Ptr
	Return HeapMemoryAllocatorRealloc(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtbl), pv, cb)
End Function

Private Sub IHeapMemoryAllocatorFree( _
		ByVal self As IHeapMemoryAllocator Ptr, _
		ByVal pv As Any Ptr _
	)
	HeapMemoryAllocatorFree(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtbl), pv)
End Sub

Private Function ITimeCounterQueryInterface( _
		ByVal self As ITimeCounter Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorQueryInterface(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtblTimeCounter), riid, ppvObject)
End Function

Private Function ITimeCounterAddRef( _
		ByVal self As ITimeCounter Ptr _
	)As ULONG
	Return HeapMemoryAllocatorAddRef(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Private Function ITimeCounterRelease( _
		ByVal self As ITimeCounter Ptr _
	)As ULONG
	Return HeapMemoryAllocatorRelease(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Private Function ITimeCounterStartWatch( _
		ByVal self As ITimeCounter Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorStartWatch(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Private Function ITimeCounterStopWatch( _
		ByVal self As ITimeCounter Ptr _
	)As HRESULT
	Return HeapMemoryAllocatorStopWatch(CONTAINING_RECORD(self, HeapMemoryAllocator, lpVtblTimeCounter))
End Function

Dim GlobalHeapMemoryAllocatorVirtualTable As Const IHeapMemoryAllocatorVirtualTable = Type( _
	@IHeapMemoryAllocatorQueryInterface, _
	@IHeapMemoryAllocatorAddRef, _
	@IHeapMemoryAllocatorRelease, _
	@IHeapMemoryAllocatorAlloc, _
	@IHeapMemoryAllocatorRealloc, _
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
