#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
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
	pIStream As IBaseAsyncStream Ptr
	RequestedLine As HeapBSTR
End Type

Private Sub InitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_READREQUESTASYNCTASK), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalReadRequestAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIHttpAsyncReader = NULL
	this->pIStream = NULL
	this->RequestedLine = NULL

End Sub

Private Sub UnInitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)

	If this->pIStream Then
		IBaseAsyncStream_Release(this->pIStream)
	End If

	If this->pIHttpAsyncReader Then
		IHttpAsyncReader_Release(this->pIHttpAsyncReader)
	End If

	HeapSysFreeString(this->RequestedLine)

End Sub

Private Sub ReadRequestAsyncTaskCreated( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)

End Sub

Private Sub ReadRequestAsyncTaskDestroyed( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)

End Sub

Private Sub DestroyReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeReadRequestAsyncTask(this)

	IMalloc_Free(pIMemoryAllocator, this)

	ReadRequestAsyncTaskDestroyed(this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function ReadRequestAsyncTaskAddRef( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function ReadRequestAsyncTaskRelease( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)As ULONG

	this->ReferenceCounter -= 1

	If this->ReferenceCounter Then
		Return 1
	End If

	DestroyReadRequestAsyncTask(this)

	Return 0

End Function

Private Function ReadRequestAsyncTaskQueryInterface( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IReadRequestAsyncIoTask, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IAsyncIoTask, riid) Then
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

	ReadRequestAsyncTaskAddRef(this)

	Return S_OK

End Function

Public Function CreateReadRequestAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim this As ReadRequestAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ReadRequestAsyncTask) _
	)

	If this Then
		InitializeReadRequestAsyncTask( _
			this, _
			pIMemoryAllocator _
		)
		ReadRequestAsyncTaskCreated(this)

		Dim hrQueryInterface As HRESULT = ReadRequestAsyncTaskQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyReadRequestAsyncTask(this)
		End If

		Return hrQueryInterface
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function ReadRequestAsyncTaskBeginExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim hrBeginReadLine As HRESULT = IHttpAsyncReader_BeginReadLine( _
		this->pIHttpAsyncReader, _
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
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	Dim hrEndReadLine As HRESULT = IHttpAsyncReader_EndReadLine( _
		this->pIHttpAsyncReader, _
		pIResult, _
		@this->RequestedLine _
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

Private Function ReadRequestAsyncTaskGetBaseStream( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	If this->pIStream Then
		IBaseAsyncStream_AddRef(this->pIStream)
	End If

	*ppStream = this->pIStream

	Return S_OK

End Function

Private Function ReadRequestAsyncTaskSetBaseStream( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT

	If this->pIStream Then
		IBaseAsyncStream_Release(this->pIStream)
	End If

	If pStream Then
		IBaseAsyncStream_AddRef(pStream)
	End If

	this->pIStream = pStream

	Return S_OK

End Function

Private Function ReadRequestAsyncTaskGetHttpReader( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT

	If this->pIHttpAsyncReader Then
		IHttpAsyncReader_AddRef(this->pIHttpAsyncReader)
	End If

	*ppReader = this->pIHttpAsyncReader

	Return S_OK

End Function

Private Function ReadRequestAsyncTaskSetHttpReader( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT

	If this->pIHttpAsyncReader Then
		IHttpAsyncReader_Release(this->pIHttpAsyncReader)
	End If

	If pReader Then
		IHttpAsyncReader_AddRef(pReader)
	End If

	this->pIHttpAsyncReader = pReader

	Return S_OK

End Function

Private Function ReadRequestAsyncTaskParse( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppRequest As IClientRequest Ptr Ptr _
	)As HRESULT

	Dim pIRequest As IClientRequest Ptr = Any
	Dim hrCreateRequest As HRESULT = CreateClientRequest( _
		this->pIMemoryAllocator, _
		@IID_IClientRequest, _
		@pIRequest _
	)

	If FAILED(hrCreateRequest) Then
		*ppRequest = NULL
		Return E_OUTOFMEMORY
	End If

	Dim hrParse As HRESULT = IClientRequest_Parse( _
		pIRequest, _
		this->pIHttpAsyncReader, _
		this->RequestedLine _
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
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskQueryInterface(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), riid, ppv)
End Function

Private Function IReadRequestAsyncTaskAddRef( _
		ByVal this As IReadRequestAsyncIoTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskAddRef(ContainerOf(this, ReadRequestAsyncTask, lpVtbl))
End Function

Private Function IReadRequestAsyncTaskRelease( _
		ByVal this As IReadRequestAsyncIoTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskRelease(ContainerOf(this, ReadRequestAsyncTask, lpVtbl))
End Function

Private Function IReadRequestAsyncTaskBeginExecute( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskBeginExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pcb, StateObject, ppIResult)
End Function

Private Function IReadRequestAsyncTaskEndExecute( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskEndExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIResult)
End Function

Private Function IReadRequestAsyncTaskGetBaseStream( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppStream)
End Function

Private Function IReadRequestAsyncTaskSetBaseStream( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pStream)
End Function

Private Function IReadRequestAsyncTaskGetHttpReader( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppReader)
End Function

Private Function IReadRequestAsyncTaskSetHttpReader( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pReader)
End Function

Private Function IReadRequestAsyncTaskParse( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskParse(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppRequest)
End Function

Dim GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable = Type( _
	@IReadRequestAsyncTaskQueryInterface, _
	@IReadRequestAsyncTaskAddRef, _
	@IReadRequestAsyncTaskRelease, _
	@IReadRequestAsyncTaskBeginExecute, _
	@IReadRequestAsyncTaskEndExecute, _
	@IReadRequestAsyncTaskGetBaseStream, _
	@IReadRequestAsyncTaskSetBaseStream, _
	@IReadRequestAsyncTaskGetHttpReader, _
	@IReadRequestAsyncTaskSetHttpReader, _
	@IReadRequestAsyncTaskParse _
)
