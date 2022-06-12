#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "INetworkStream.bi"
#include once "Logger.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "WriteResponseAsyncTask.bi"

Extern GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable

Type _ReadRequestAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IReadRequestAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWebSitesWeakPtr As IWebSiteCollection Ptr
	pIProcessorsWeakPtr As IHttpProcessorCollection Ptr
	pIHttpReader As IHttpReader Ptr
	pIStream As IBaseStream Ptr
	pIRequest As IClientRequest Ptr
	RequestedLine As HeapBSTR
End Type

Sub InitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_READREQUESTASYNCTASK), _
			Len(ReadRequestAsyncTask.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalReadRequestAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSitesWeakPtr = NULL
	this->pIProcessorsWeakPtr = NULL
	this->pIHttpReader = NULL
	this->pIStream = NULL
	this->pIRequest = pIRequest
	this->RequestedLine = NULL
	
End Sub

Sub UnInitializeReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIRequest <> NULL Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	HeapSysFreeString(this->RequestedLine)
	
End Sub

Function CreateReadRequestAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ReadRequestAsyncTask Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ReadRequestAsyncTask)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ReadRequestAsyncTask creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim pIRequest As IClientRequest Ptr = Any
	Dim hrCreateRequest As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_CLIENTREQUEST, _
		@IID_IClientRequest, _
		@pIRequest _
	)

	If SUCCEEDED(hrCreateRequest) Then
		Dim this As ReadRequestAsyncTask Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(ReadRequestAsyncTask) _
		)
		
		If this <> NULL Then
			InitializeReadRequestAsyncTask( _
				this, _
				pIMemoryAllocator, _
				pIRequest _
			)
			
			#if __FB_DEBUG__
			Scope
				Dim vtEmpty As VARIANT = Any
				VariantInit(@vtEmpty)
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr("ReadRequestAsyncTask created"), _
					@vtEmpty _
				)
			End Scope
			#endif
			
			Return this
		End If
		
		IClientRequest_Release(pIRequest)
	End If
	
	Return NULL
	
End Function

Sub DestroyReadRequestAsyncTask( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ReadRequestAsyncTask destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeReadRequestAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ReadRequestAsyncTask destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ReadRequestAsyncTaskQueryInterface( _
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

Function ReadRequestAsyncTaskAddRef( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function ReadRequestAsyncTaskRelease( _
		ByVal this As ReadRequestAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyReadRequestAsyncTask(this)
	
	Return 0
	
End Function

Function ReadRequestAsyncTaskBeginExecute( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Const NullCallback As AsyncCallback = NULL
	
	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim hrBeginReadLine As HRESULT = IHttpReader_BeginReadLine( _
		this->pIHttpReader, _
		NullCallback, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		ppIResult _
	)
	If FAILED(hrBeginReadLine) Then
		Return hrBeginReadLine
	End If
	
	' Ссылка на this сохранена в pIAsyncResult
	' Ссылка на pIAsyncResult сохранена в унаследованной от OVERLAPPED структуре
	' Ссылку на OVERLAPPED возвратит функция GetQueuedCompletionStatus бассейну потоков
	
	Return ASYNCTASK_S_IO_PENDING
	
End Function

Function ReadRequestAsyncTaskEndExecute( _
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
			this->pIWebSitesWeakPtr, _
			this->pIStream, _
			this->pIHttpReader, _
			this->pIProcessorsWeakPtr, _
			this->pIRequest, _
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
						this->pIWebSitesWeakPtr, _
						this->pIStream, _
						this->pIHttpReader, _
						this->pIProcessorsWeakPtr, _
						this->pIRequest, _
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
					Dim hrCreateTask As HRESULT = CreateInstance( _
						this->pIMemoryAllocator, _
						@CLSID_WRITERESPONSEASYNCTASK, _
						@IID_IWriteResponseAsyncIoTask, _
						@pTask _
					)
					If FAILED(hrCreateTask) Then
						Dim hrProcessError As HRESULT = ProcessErrorRequestResponse( _
							this->pIMemoryAllocator, _
							this->pIWebSitesWeakPtr, _
							this->pIStream, _
							this->pIHttpReader, _
							this->pIProcessorsWeakPtr, _
							this->pIRequest, _
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
					IWriteResponseAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSitesWeakPtr)
					IWriteResponseAsyncIoTask_SetHttpProcessorCollectionWeakPtr(pTask, this->pIProcessorsWeakPtr)
					IWriteResponseAsyncIoTask_SetBaseStream(pTask, this->pIStream)
					IWriteResponseAsyncIoTask_SetHttpReader(pTask, this->pIHttpReader)
					IWriteResponseAsyncIoTask_SetClientRequest(pTask, this->pIRequest)
					
					Dim hrPrepareResponse As HRESULT = IWriteResponseAsyncIoTask_Prepare(pTask)
					If FAILED(hrPrepareResponse) Then
						IWriteResponseAsyncIoTask_Release(pTask)
						
						Dim hrProcessError As HRESULT = ProcessErrorRequestResponse( _
							this->pIMemoryAllocator, _
							this->pIWebSitesWeakPtr, _
							this->pIStream, _
							this->pIHttpReader, _
							this->pIProcessorsWeakPtr, _
							this->pIRequest, _
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
	
End Function

Function ReadRequestAsyncTaskGetFileHandle( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim ns As INetworkStream Ptr = Any
	IBaseStream_QueryInterface(this->pIStream, @IID_INetworkStream, @ns)
	
	Dim s As SOCKET = Any
	INetworkStream_GetSocket(ns, @s)
	
	*pFileHandle = Cast(HANDLE, s)
	
	INetworkStream_Release(ns)
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetWebSiteCollectionWeakPtr( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	*ppIWebSites = this->pIWebSitesWeakPtr
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	this->pIWebSitesWeakPtr = pIWebSites
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetHttpProcessorCollectionWeakPtr( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	*ppIProcessors = this->pIProcessorsWeakPtr
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetHttpProcessorCollectionWeakPtr( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	this->pIProcessorsWeakPtr = pIProcessors
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetBaseStream( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetBaseStream( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream <> NULL Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pStream <> NULL Then
		IBaseStream_AddRef(pStream)
	End If
	
	this->pIStream = pStream
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskGetHttpReader( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function ReadRequestAsyncTaskSetHttpReader( _
		ByVal this As ReadRequestAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	If this->pIHttpReader <> NULL Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If pReader <> NULL Then
		IHttpReader_AddRef(pReader)
	End If
	
	this->pIHttpReader = pReader
	
	Return S_OK
	
End Function


Function IReadRequestAsyncTaskQueryInterface( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskQueryInterface(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), riid, ppv)
End Function

Function IReadRequestAsyncTaskAddRef( _
		ByVal this As IReadRequestAsyncIoTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskAddRef(ContainerOf(this, ReadRequestAsyncTask, lpVtbl))
End Function

Function IReadRequestAsyncTaskRelease( _
		ByVal this As IReadRequestAsyncIoTask Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskRelease(ContainerOf(this, ReadRequestAsyncTask, lpVtbl))
End Function

Function IReadRequestAsyncTaskBeginExecute( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskBeginExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIResult)
End Function

Function IReadRequestAsyncTaskEndExecute( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskEndExecute(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIResult, BytesTransferred, ppNextTask)
End Function

Function IReadRequestAsyncIoTaskGetFileHandle( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As ULONG
	Return ReadRequestAsyncTaskGetFileHandle(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pFileHandle)
End Function

Function IReadRequestAsyncTaskGetWebSiteCollectionWeakPtr( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetWebSiteCollectionWeakPtr(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IReadRequestAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetWebSiteCollectionWeakPtr(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIWebSites)
End Function

Function IReadRequestAsyncTaskGetHttpProcessorCollectionWeakPtr( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpProcessorCollectionWeakPtr(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IReadRequestAsyncTaskSetHttpProcessorCollectionWeakPtr( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpProcessorCollectionWeakPtr(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pIProcessors)
End Function

Function IReadRequestAsyncTaskGetBaseStream( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppStream)
End Function

Function IReadRequestAsyncTaskSetBaseStream( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetBaseStream(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pStream)
End Function

Function IReadRequestAsyncTaskGetHttpReader( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskGetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), ppReader)
End Function

Function IReadRequestAsyncTaskSetHttpReader( _
		ByVal this As IReadRequestAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return ReadRequestAsyncTaskSetHttpReader(ContainerOf(this, ReadRequestAsyncTask, lpVtbl), pReader)
End Function

Dim GlobalReadRequestAsyncIoTaskVirtualTable As Const IReadRequestAsyncIoTaskVirtualTable = Type( _
	@IReadRequestAsyncTaskQueryInterface, _
	@IReadRequestAsyncTaskAddRef, _
	@IReadRequestAsyncTaskRelease, _
	@IReadRequestAsyncTaskBeginExecute, _
	@IReadRequestAsyncTaskEndExecute, _
	@IReadRequestAsyncIoTaskGetFileHandle, _
	@IReadRequestAsyncTaskGetWebSiteCollectionWeakPtr, _
	@IReadRequestAsyncTaskSetWebSiteCollectionWeakPtr, _
	@IReadRequestAsyncTaskGetHttpProcessorCollectionWeakPtr, _
	@IReadRequestAsyncTaskSetHttpProcessorCollectionWeakPtr, _
	@IReadRequestAsyncTaskGetBaseStream, _
	@IReadRequestAsyncTaskSetBaseStream, _
	@IReadRequestAsyncTaskGetHttpReader, _
	@IReadRequestAsyncTaskSetHttpReader _
)
