#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "HeapBSTR.bi"

Extern GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable

Type ReadRequestAsyncTask
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IReadRequestAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIHttpAsyncReader As IHttpAsyncReader Ptr
	FirstLine As HeapBSTR
End Type

Private Sub InitializeReadRequestAsyncTask( _
		ByVal self As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_READREQUESTASYNCTASK), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalReadRequestAsyncIoTaskVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->pIHttpAsyncReader = NULL
	self->FirstLine = NULL

End Sub

Private Sub UnInitializeReadRequestAsyncTask( _
		ByVal self As ReadRequestAsyncTask Ptr _
	)

	If self->pIHttpAsyncReader Then
		IHttpAsyncReader_Release(self->pIHttpAsyncReader)
	End If

	HeapSysFreeString(self->FirstLine)

End Sub

Private Sub ReadRequestAsyncTaskCreated( _
		ByVal self As ReadRequestAsyncTask Ptr _
	)

End Sub

Private Sub ReadRequestAsyncTaskDestroyed( _
		ByVal self As ReadRequestAsyncTask Ptr _
	)

End Sub

Private Sub DestroyReadRequestAsyncTask( _
		ByVal self As ReadRequestAsyncTask Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeReadRequestAsyncTask(self)

	IMalloc_Free(pIMemoryAllocator, self)

	ReadRequestAsyncTaskDestroyed(self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function ReadRequestAsyncTaskAddRef( _
		ByVal self As ReadRequestAsyncTask Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function ReadRequestAsyncTaskRelease( _
		ByVal self As ReadRequestAsyncTask Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyReadRequestAsyncTask(self)

	Return 0

End Function

Private Function ReadRequestAsyncTaskQueryInterface( _
		ByVal self As ReadRequestAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IReadRequestAsyncIoTask, riid) Then
		*ppv = @self->lpVtbl
	Else
		If IsEqualIID(@IID_IAsyncIoTask, riid) Then
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

	ReadRequestAsyncTaskAddRef(self)

	Return S_OK

End Function

Public Function CreateReadRequestAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As ReadRequestAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ReadRequestAsyncTask) _
	)

	If self Then
		InitializeReadRequestAsyncTask( _
			self, _
			pIMemoryAllocator _
		)
		ReadRequestAsyncTaskCreated(self)

		Dim hrQueryInterface As HRESULT = ReadRequestAsyncTaskQueryInterface( _
			self, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyReadRequestAsyncTask(self)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function ReadRequestAsyncTaskBeginExecute( _
		ByVal self As ReadRequestAsyncTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim hrBeginReadLine As HRESULT = IHttpAsyncReader_BeginReadLine( _
		self->pIHttpAsyncReader, _
		pcb, _
		StateObject, _
		ppIResult _
	)
	If FAILED(hrBeginReadLine) Then
		Return hrBeginReadLine
	End If

	Return S_OK

End Function

Private Function ReadRequestAsyncTaskEndExecute( _
		ByVal self As ReadRequestAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	Dim hrEndReadLine As HRESULT = IHttpAsyncReader_EndReadLine( _
		self->pIHttpAsyncReader, _
		pIResult, _
		@self->FirstLine _
	)
	If FAILED(hrEndReadLine) Then
		Return hrEndReadLine
	End If

	Select Case hrEndReadLine

		Case S_OK
			Return S_OK

		Case S_FALSE
			' Read 0 bytes, reached the end of the stream, close the connection
			Return S_FALSE

		Case HTTPREADER_S_IO_PENDING
			Return READREQUESTASYNCIOTASK_S_IO_PENDING

	End Select

	Return S_OK

End Function

Private Function ReadRequestAsyncTaskGetHttpReader( _
		ByVal self As ReadRequestAsyncTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT

	If self->pIHttpAsyncReader Then
		IHttpAsyncReader_AddRef(self->pIHttpAsyncReader)
	End If

	*ppReader = self->pIHttpAsyncReader

	Return S_OK

End Function

Private Function ReadRequestAsyncTaskSetHttpReader( _
		ByVal self As ReadRequestAsyncTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT

	If self->pIHttpAsyncReader Then
		IHttpAsyncReader_Release(self->pIHttpAsyncReader)
	End If

	If pReader Then
		IHttpAsyncReader_AddRef(pReader)
	End If

	self->pIHttpAsyncReader = pReader

	Return S_OK

End Function

Private Function ReadRequestAsyncTaskParse( _
		ByVal self As ReadRequestAsyncTask Ptr, _
		ByVal ppRequest As IClientRequest Ptr Ptr _
	)As HRESULT

	Dim pIRequest As IClientRequest Ptr = Any
	Dim hrCreateRequest As HRESULT = CreateClientRequest( _
		self->pIMemoryAllocator, _
		@IID_IClientRequest, _
		@pIRequest _
	)

	If FAILED(hrCreateRequest) Then
		*ppRequest = NULL
		Return E_OUTOFMEMORY
	End If

	Dim hrParse As HRESULT = IClientRequest_Parse( _
		pIRequest, _
		self->pIHttpAsyncReader, _
		self->FirstLine _
	)
	If FAILED(hrParse) Then
		IClientRequest_Release(pIRequest)
		*ppRequest = NULL
		Return hrParse
	End If

	*ppRequest = pIRequest

	Return S_OK

End Function


Private Function IReadRequestAsyncTaskQueryInterface( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskQueryInterface(CONTAINING_RECORD(self, ReadRequestAsyncTask, lpVtbl), riid, ppv)
End Function

Private Function IReadRequestAsyncTaskAddRef( _
		ByVal self As IReadRequestAsyncIoTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskAddRef(CONTAINING_RECORD(self, ReadRequestAsyncTask, lpVtbl))
End Function

Private Function IReadRequestAsyncTaskRelease( _
		ByVal self As IReadRequestAsyncIoTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskRelease(CONTAINING_RECORD(self, ReadRequestAsyncTask, lpVtbl))
End Function

Private Function IReadRequestAsyncTaskBeginExecute( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskBeginExecute(CONTAINING_RECORD(self, ReadRequestAsyncTask, lpVtbl), pcb, StateObject, ppIResult)
End Function

Private Function IReadRequestAsyncTaskEndExecute( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskEndExecute(CONTAINING_RECORD(self, ReadRequestAsyncTask, lpVtbl), pIResult)
End Function

Private Function IReadRequestAsyncTaskGetHttpReader( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpReader(CONTAINING_RECORD(self, ReadRequestAsyncTask, lpVtbl), ppReader)
End Function

Private Function IReadRequestAsyncTaskSetHttpReader( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpReader(CONTAINING_RECORD(self, ReadRequestAsyncTask, lpVtbl), pReader)
End Function

Private Function IReadRequestAsyncTaskParse( _
		ByVal self As IReadRequestAsyncIoTask Ptr, _
		ByVal ppRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskParse(CONTAINING_RECORD(self, ReadRequestAsyncTask, lpVtbl), ppRequest)
End Function

Dim GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable = Type( _
	@IReadRequestAsyncTaskQueryInterface, _
	@IReadRequestAsyncTaskAddRef, _
	@IReadRequestAsyncTaskRelease, _
	@IReadRequestAsyncTaskBeginExecute, _
	@IReadRequestAsyncTaskEndExecute, _
	@IReadRequestAsyncTaskGetHttpReader, _
	@IReadRequestAsyncTaskSetHttpReader, _
	@IReadRequestAsyncTaskParse _
)
