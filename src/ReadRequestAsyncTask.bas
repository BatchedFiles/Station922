#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "WebUtils.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "WriteResponseAsyncTask.bi"

Extern GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable

Type _ReadRequestAsyncTask
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IReadRequestAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIHttpReader As IHttpReader Ptr
	pIWebSitesWeakPtr As IWebSiteCollection Ptr
	pIStream As IBaseStream Ptr
	pIRequest As IClientRequest Ptr
	RequestedLine As HeapBSTR
End Type

Private Sub InitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
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
	this->pIHttpReader = NULL
	this->pIStream = NULL
	this->pIWebSitesWeakPtr = NULL
	' Do not need AddRef pIRequest
	this->pIRequest = pIRequest
	this->RequestedLine = NULL
	
End Sub

Private Sub UnInitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIHttpReader Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIRequest Then
		IClientRequest_Release(this->pIRequest)
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
		If IsEqualIID(@IID_IHttpAsyncIoTask, riid) Then
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
	End If
	
	ReadRequestAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Private Function ReadRequestAsyncTaskGetTaskId( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pId As AsyncIoTaskIDs Ptr _
	)As HRESULT
	
	*pId = AsyncIoTaskIDs.ReadRequest
	
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
		Dim pIRequest As IClientRequest Ptr = Any
		Dim hrCreateRequest As HRESULT = CreateClientRequest( _
			pIMemoryAllocator, _
			@IID_IClientRequest, _
			@pIRequest _
		)
		
		If SUCCEEDED(hrCreateRequest) Then
			
			InitializeReadRequestAsyncTask( _
				this, _
				pIMemoryAllocator, _
				pIRequest _
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
		
		IMalloc_Free( _
			pIMemoryAllocator, _
			this _
		)
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function ReadRequestAsyncTaskBeginExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim hrBeginReadLine As HRESULT = IHttpReader_BeginReadLine( _
		this->pIHttpReader, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		ppIResult _
	)
	If FAILED(hrBeginReadLine) Then
		Return hrBeginReadLine
	End If
	
	' Ссылка на this сохранена в pIAsyncResult
	' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
	' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
	
	Return S_OK
	
End Function

Private Function ReadRequestAsyncTaskEndExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim hrEndReadLine As HRESULT = IHttpReader_EndReadLine( _
		this->pIHttpReader, _
		pIResult, _
		@this->RequestedLine _
	)
	If FAILED(hrEndReadLine) Then
		
		Dim hrProcessError As HRESULT = ProcessErrorRequestResponse( _
			this->pIMemoryAllocator, _
			this->pIStream, _
			this->pIHttpReader, _
			this->pIRequest, _
			this->pIWebSitesWeakPtr, _
			hrEndReadLine, _
			CPtr(IWriteErrorAsyncIoTask Ptr Ptr, ppNextTask) _
		)
		If FAILED(hrProcessError) Then
			Return hrEndReadLine
		End If
		
		Return S_OK
	End If
	
	Select Case hrEndReadLine
		
		Case S_OK
			Scope
				Dim hrParse As HRESULT = IClientRequest_Parse( _
					this->pIRequest, _
					this->pIHttpReader, _
					this->RequestedLine _
				)
				HeapSysFreeString(this->RequestedLine)
				this->RequestedLine = NULL
				
				If FAILED(hrParse) Then
					Dim hrProcessError As HRESULT = ProcessErrorRequestResponse( _
						this->pIMemoryAllocator, _
						this->pIStream, _
						this->pIHttpReader, _
						this->pIRequest, _
						this->pIWebSitesWeakPtr, _
						hrParse, _
						CPtr(IWriteErrorAsyncIoTask Ptr Ptr, ppNextTask) _
					)
					If FAILED(hrProcessError) Then
						Return hrParse
					End If
					
					Return S_OK
				End If
			End Scope
			
			Scope
				Dim pTask As IWriteResponseAsyncIoTask Ptr = Any
				
				Scope
					Dim hrCreateTask As HRESULT = CreateWriteResponseAsyncTask( _
						this->pIMemoryAllocator, _
						@IID_IWriteResponseAsyncIoTask, _
						@pTask _
					)
					If FAILED(hrCreateTask) Then
						Dim hrProcessError As HRESULT = ProcessErrorRequestResponse( _
							this->pIMemoryAllocator, _
							this->pIStream, _
							this->pIHttpReader, _
							this->pIRequest, _
							this->pIWebSitesWeakPtr, _
							hrCreateTask, _
							CPtr(IWriteErrorAsyncIoTask Ptr Ptr, ppNextTask) _
						)
						If FAILED(hrProcessError) Then
							Return hrCreateTask
						End If
						
						Return S_OK
					End If
				End Scope
				
				Scope
					IWriteResponseAsyncIoTask_SetBaseStream(pTask, this->pIStream)
					IWriteResponseAsyncIoTask_SetHttpReader(pTask, this->pIHttpReader)
					IWriteResponseAsyncIoTask_SetClientRequest(pTask, this->pIRequest)
					IWriteResponseAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSitesWeakPtr)
					
					Dim hrPrepareResponse As HRESULT = IWriteResponseAsyncIoTask_Prepare(pTask)
					If FAILED(hrPrepareResponse) Then
						IWriteResponseAsyncIoTask_Release(pTask)
						
						Dim hrProcessError As HRESULT = ProcessErrorRequestResponse( _
							this->pIMemoryAllocator, _
							this->pIStream, _
							this->pIHttpReader, _
							this->pIRequest, _
							this->pIWebSitesWeakPtr, _
							hrPrepareResponse, _
							CPtr(IWriteErrorAsyncIoTask Ptr Ptr, ppNextTask) _
						)
						If FAILED(hrProcessError) Then
							Return hrPrepareResponse
						End If
						
						Return S_OK
					End If
					
				End Scope
				
				*ppNextTask = CPtr(IAsyncIoTask Ptr, pTask)
			End Scope
			
			Return S_OK
			
		Case S_FALSE
			' Принято 0 байт, достигли конец файла
			' клиент закрыл соединение
			*ppNextTask = NULL
			Return S_FALSE
			
		Case HTTPREADER_S_IO_PENDING
			' Продолжить чтение запроса
			ReadRequestAsyncTaskAddRef(this)
			*ppNextTask = CPtr(IAsyncIoTask Ptr, @this->lpVtbl)
			Return S_OK
			
	End Select
	
	Return S_OK
	
End Function

Private Function ReadRequestAsyncTaskGetBaseStream( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Private Function ReadRequestAsyncTaskSetBaseStream( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pStream Then
		IBaseStream_AddRef(pStream)
	End If
	
	this->pIStream = pStream
	
	Return S_OK
	
End Function

Private Function ReadRequestAsyncTaskGetHttpReader( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Private Function ReadRequestAsyncTaskSetHttpReader( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	If this->pIHttpReader Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If pReader Then
		IHttpReader_AddRef(pReader)
	End If
	
	this->pIHttpReader = pReader
	
	Return S_OK
	
End Function

Private Function ReadRequestAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		byVal pCollection As IWebSiteCollection Ptr _
	)As HRESULT
	
	this->pIWebSitesWeakPtr = pCollection
	
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

Private Function IReadRequestAsyncTaskGetTaskId( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pId As AsyncIoTaskIDs Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetTaskId(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pId)
End Function

Private Function IReadRequestAsyncTaskBeginExecute( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskBeginExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIResult)
End Function

Private Function IReadRequestAsyncTaskEndExecute( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskEndExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIResult, BytesTransferred, ppNextTask)
End Function

Private Function IReadRequestAsyncTaskGetBaseStream( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppStream)
End Function

Private Function IReadRequestAsyncTaskSetBaseStream( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pStream)
End Function

Private Function IReadRequestAsyncTaskGetHttpReader( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppReader)
End Function

Private Function IReadRequestAsyncTaskSetHttpReader( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pReader)
End Function

Private Function IReadRequestAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pCollection As IWebSiteCollection Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetWebSiteCollectionWeakPtr(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pCollection)
End Function

Dim GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable = Type( _
	@IReadRequestAsyncTaskQueryInterface, _
	@IReadRequestAsyncTaskAddRef, _
	@IReadRequestAsyncTaskRelease, _
	@IReadRequestAsyncTaskGetTaskId, _
	@IReadRequestAsyncTaskBeginExecute, _
	@IReadRequestAsyncTaskEndExecute, _
	@IReadRequestAsyncTaskGetBaseStream, _
	@IReadRequestAsyncTaskSetBaseStream, _
	@IReadRequestAsyncTaskGetHttpReader, _
	@IReadRequestAsyncTaskSetHttpReader, _
	@IReadRequestAsyncTaskSetWebSiteCollectionWeakPtr _
)
