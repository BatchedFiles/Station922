#include once "AcceptConnectionAsyncTask.bi"
#include once "win\winsock2.bi"
#include once "win\mswsock.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HttpReader.bi"
#include once "Logger.bi"
#include once "NetworkStream.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "TcpListener.bi"

Extern GlobalAcceptConnectionAsyncIoTaskVirtualTable As Const IAcceptConnectionAsyncIoTaskVirtualTable

Type _AcceptConnectionAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IAcceptConnectionAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIWebSitesWeakPtr As IWebSiteCollection Ptr
	pIProcessorsWeakPtr As IHttpProcessorCollection Ptr
	ListenSocket As SOCKET
	pIPoolWeakPtr As IThreadPool Ptr
End Type

/'
Создать:
	Аллокатор
	Буфер байтов запроса + адресов
	NetworkStream
	HttpReader
	ReadRequestAsyncIoTask
	
	При ошибке всё равно возвращать S_IO_PENDING?
	Иначе задачу уничтожит сборщик мусора
	Или возвращать специальное значение
	Это значит, что задача должна быть пересоздана
	
'/
Function CreateReadTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As IReadRequestAsyncIoTask Ptr
	
	Dim pIClientMemoryAllocator As IHeapMemoryAllocator Ptr = GetHeapMemoryAllocatorInstance()
	
	If pIClientMemoryAllocator <> NULL Then
		
		Dim pIHttpReader As IHttpReader Ptr = Any
		Dim hrCreateHttpReader As HRESULT = CreateInstance( _
			CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
			@CLSID_HTTPREADER, _
			@IID_IHttpReader, _
			@pIHttpReader _
		)
		
		If SUCCEEDED(hrCreateHttpReader) Then
			
			Dim pBuffer As ClientRequestBuffer Ptr = Any
			IHeapMemoryAllocator_GetClientBuffer(pIClientMemoryAllocator, @pBuffer)
			IHttpReader_SetClientBuffer(pIHttpReader, pBuffer)
			
			Dim pINetworkStream As INetworkStream Ptr = Any
			Dim hrCreateNetworkStream As HRESULT = CreateInstance( _
				CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
				@CLSID_NETWORKSTREAM, _
				@IID_INetworkStream, _
				@pINetworkStream _
			)
			
			If SUCCEEDED(hrCreateNetworkStream) Then
				
				CopyMemory( _
					@pBuffer->RemoteAddress, _
					pRemoteAddress, _
					min(RemoteAddressLength, SOCKET_ADDRESS_STORAGE_LENGTH) _
				)
				pBuffer->RemoteAddressLength = RemoteAddressLength
				
				INetworkStream_SetSocket(pINetworkStream, ClientSocket)
				INetworkStream_SetRemoteAddress( _
					pINetworkStream, _
					pRemoteAddress, _
					RemoteAddressLength _
				)
				
				' TODO Запросить интерфейс вместо конвертирования указателя
				IHttpReader_SetBaseStream( _
					pIHttpReader, _
					CPtr(IBaseStream Ptr, pINetworkStream) _
				)
				
				Dim pTask As IReadRequestAsyncIoTask Ptr = Any
				Dim hrCreateTask As HRESULT = CreateInstance( _
					CPtr(IMalloc Ptr, pIClientMemoryAllocator), _
					@CLSID_READREQUESTASYNCTASK, _
					@IID_IReadRequestAsyncIoTask, _
					@pTask _
				)
				
				If SUCCEEDED(hrCreateTask) Then
					IReadRequestAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSitesWeakPtr)
					IReadRequestAsyncIoTask_SetHttpProcessorCollectionWeakPtr(pTask, this->pIProcessorsWeakPtr)
					IReadRequestAsyncIoTask_SetBaseStream(pTask, CPtr(IBaseStream Ptr, pINetworkStream))
					IReadRequestAsyncIoTask_SetHttpReader(pTask, pIHttpReader)
					
					Dim hrAssociate As HRESULT = IThreadPool_AssociateTask( _
						this->pIPoolWeakPtr, _
						CPtr(IAsyncIoTask Ptr, pTask) _
					)
					If FAILED(hrAssociate) Then
						
					End If
					
					INetworkStream_Release(pINetworkStream)
					IHttpReader_Release(pIHttpReader)
					IHeapMemoryAllocator_Release(pIClientMemoryAllocator)
					
					pIClientMemoryAllocator = NULL
					pINetworkStream = NULL
					pIHttpReader = NULL
					
					Return pTask
				End If
				
				If pINetworkStream <> NULL Then
					INetworkStream_Release(pINetworkStream)
				End If
			End If
			
			If pIHttpReader <> NULL Then
				IHttpReader_Release(pIHttpReader)
			End If
		End If
		
		If pIClientMemoryAllocator <> NULL Then
			IHeapMemoryAllocator_Release(pIClientMemoryAllocator)
		End If
	End If
	
	Return NULL
				
End Function

Sub InitializeAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_ACCEPTCONNECTIONASYNCTASK), _
			Len(AcceptConnectionAsyncTask.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalAcceptConnectionAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWebSitesWeakPtr = NULL
	this->pIProcessorsWeakPtr = NULL
	this->ListenSocket = INVALID_SOCKET
	this->pIPoolWeakPtr = NULL
	
End Sub

Sub UnInitializeAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
End Sub

Function CreateAcceptConnectionAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As AcceptConnectionAsyncTask Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(AcceptConnectionAsyncTask)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"AcceptConnectionAsyncTask creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As AcceptConnectionAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(AcceptConnectionAsyncTask) _
	)
	
	If this <> NULL Then
		InitializeAcceptConnectionAsyncTask( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("AcceptConnectionAsyncTask created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyAcceptConnectionAsyncTask( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("AcceptConnectionAsyncTask destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeAcceptConnectionAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("AcceptConnectionAsyncTask destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function AcceptConnectionAsyncTaskQueryInterface( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IAcceptConnectionAsyncIoTask, riid) Then
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
	
	AcceptConnectionAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskAddRef( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function AcceptConnectionAsyncTaskRelease( _
		ByVal this As AcceptConnectionAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyAcceptConnectionAsyncTask(this)
	
	Return 0
	
End Function

Function AcceptConnectionAsyncTaskBeginExecute( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	/'
	Dim hrBeginProcess As HRESULT = IHttpAsyncProcessor_BeginProcess( _
		this->pIProcessorWeakPtr, _
		@pc, _
		CPtr(IUnknown Ptr, @this->lpVtbl), _
		ppIResult _
	)
	If FAILED(hrBeginProcess) Then
		Return hrBeginProcess
	End If
	
	Return ASYNCTASK_S_IO_PENDING
	'/
	
	Return E_FAIL
	
End Function

Function AcceptConnectionAsyncTaskEndExecute( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	/'
	Dim hrEndProcess As HRESULT = IHttpAsyncProcessor_EndProcess( _
		this->pIProcessorWeakPtr, _
		@pc, _
		pIResult _
	)
	If FAILED(hrEndProcess) Then
		*ppNextTask = NULL
		Return hrEndProcess
	End If
	
	Select Case hrEndProcess
		
		Case S_OK
			
			' Сейчас мы не уменьшаем счётчик ссылок на задачу
			' Счётчик ссылок уменьшим в пуле потоков после функции EndExecute
			*ppNextTask = CPtr(IAsyncIoTask Ptr, pTask)
			Return S_OK
			
		Case S_FALSE
			' Read 0 bytes
			*ppNextTask = NULL
			Return S_FALSE
			
		Case HTTPASYNCPROCESSOR_S_IO_PENDING
			' Продолжить отправку ответа
			AcceptConnectionAsyncTaskAddRef(this)
			*ppNextTask = CPtr(IAsyncIoTask Ptr, @this->lpVtbl)
			Return S_OK
			
	End Select
	'/
	
	Return E_FAIL
	
End Function

Function AcceptConnectionAsyncTaskGetFileHandle( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	*pFileHandle = Cast(HANDLE, this->ListenSocket)
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskGetWebSiteCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	*ppIWebSites = this->pIWebSitesWeakPtr
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	this->pIWebSitesWeakPtr = pIWebSites
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskGetHttpProcessorCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	*ppIProcessors = this->pIProcessorsWeakPtr
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskSetHttpProcessorCollectionWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	
	this->pIProcessorsWeakPtr = pIProcessors
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskGetBaseStream( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	*ppStream = NULL
	
	Return E_NOTIMPL
	
End Function

Function AcceptConnectionAsyncTaskSetBaseStream( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
End Function

Function AcceptConnectionAsyncTaskGetHttpReader( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	*ppReader = NULL
	
	Return E_NOTIMPL
	
End Function

Function AcceptConnectionAsyncTaskSetHttpReader( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	
	Return E_NOTIMPL
	
End Function

Function AcceptConnectionAsyncTaskGetListenSocket( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	
	*pListenSocket = this->ListenSocket
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskSetListenSocket( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	
	this->ListenSocket = ListenSocket
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskGetThreadPoolWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal ppPool As IThreadPool Ptr Ptr _
	)As HRESULT
	
	*ppPool = this->pIPoolWeakPtr
	
	Return S_OK
	
End Function

Function AcceptConnectionAsyncTaskSetThreadPoolWeakPtr( _
		ByVal this As AcceptConnectionAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	
	this->pIPoolWeakPtr = pPool
	
	Return S_OK
	
End Function


Function IAcceptConnectionAsyncTaskQueryInterface( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskQueryInterface(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), riid, ppv)
End Function

Function IAcceptConnectionAsyncTaskAddRef( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskAddRef(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl))
End Function

Function IAcceptConnectionAsyncTaskRelease( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskRelease(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl))
End Function

Function IAcceptConnectionAsyncTaskBeginExecute( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskBeginExecute(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppIResult)
End Function

Function IAcceptConnectionAsyncTaskEndExecute( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskEndExecute(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pIResult, BytesTransferred, ppNextTask)
End Function

Function IAcceptConnectionAsyncTaskGetFileHandle( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pFileHandle As HANDLE Ptr _
	)As ULONG
	Return AcceptConnectionAsyncTaskGetFileHandle(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pFileHandle)
End Function

Function IAcceptConnectionAsyncTaskGetWebSiteCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetWebSiteCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppIWebSites)
End Function

Function IAcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pIWebSites)
End Function

Function IAcceptConnectionAsyncTaskGetHttpProcessorCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppIProcessors As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetHttpProcessorCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppIProcessors)
End Function

Function IAcceptConnectionAsyncTaskSetHttpProcessorCollectionWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pIProcessors As IHttpProcessorCollection Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetHttpProcessorCollectionWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pIProcessors)
End Function

Function IAcceptConnectionAsyncTaskGetBaseStream( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetBaseStream(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppStream)
End Function

Function IAcceptConnectionAsyncTaskSetBaseStream( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetBaseStream(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pStream)
End Function

Function IAcceptConnectionAsyncTaskGetHttpReader( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetHttpReader(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppReader)
End Function

Function IAcceptConnectionAsyncTaskSetHttpReader( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetHttpReader(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pReader)
End Function

Function IAcceptConnectionAsyncTaskGetListenSocket( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pListenSocket As SOCKET Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetListenSocket(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pListenSocket)
End Function

Function IAcceptConnectionAsyncTaskSetListenSocket( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ListenSocket As SOCKET _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetListenSocket(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ListenSocket)
End Function

Function IAcceptConnectionAsyncTaskGetThreadPoolWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal ppPool As IThreadPool Ptr Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskGetThreadPoolWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), ppPool)
End Function

Function IAcceptConnectionAsyncTaskSetThreadPoolWeakPtr( _
		ByVal this As IAcceptConnectionAsyncIoTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	Return AcceptConnectionAsyncTaskSetThreadPoolWeakPtr(ContainerOf(this, AcceptConnectionAsyncTask, lpVtbl), pPool)
End Function

Dim GlobalAcceptConnectionAsyncIoTaskVirtualTable As Const IAcceptConnectionAsyncIoTaskVirtualTable = Type( _
	@IAcceptConnectionAsyncTaskQueryInterface, _
	@IAcceptConnectionAsyncTaskAddRef, _
	@IAcceptConnectionAsyncTaskRelease, _
	@IAcceptConnectionAsyncTaskBeginExecute, _
	@IAcceptConnectionAsyncTaskEndExecute, _
	@IAcceptConnectionAsyncTaskGetFileHandle, _
	@IAcceptConnectionAsyncTaskGetWebSiteCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskSetWebSiteCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskGetHttpProcessorCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskSetHttpProcessorCollectionWeakPtr, _
	@IAcceptConnectionAsyncTaskGetBaseStream, _
	@IAcceptConnectionAsyncTaskSetBaseStream, _
	@IAcceptConnectionAsyncTaskGetHttpReader, _
	@IAcceptConnectionAsyncTaskSetHttpReader, _
	@IAcceptConnectionAsyncTaskGetListenSocket, _
	@IAcceptConnectionAsyncTaskSetListenSocket, _
	@IAcceptConnectionAsyncTaskGetThreadPoolWeakPtr, _
	@IAcceptConnectionAsyncTaskSetThreadPoolWeakPtr _
)
