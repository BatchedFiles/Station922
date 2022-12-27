#include once "WriteResponseAsyncTask.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "HttpWriter.bi"
#include once "ServerResponse.bi"
#include once "WebUtils.bi"

Extern GlobalWriteResponseAsyncIoTaskVirtualTable As Const IWriteResponseAsyncIoTaskVirtualTable

Extern pIWebSitesWeakPtr As IWebSiteCollection Ptr
Extern pIProcessorsWeakPtr As IHttpProcessorCollection Ptr

Const CompareResultEqual As Long = 0

Type _WriteResponseAsyncTask
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWriteResponseAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIHttpReader As IHttpReader Ptr
	pIStream As IBaseStream Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pIBuffer As IAttributedStream Ptr
	pIHttpWriter As IHttpWriter Ptr
	pIProcessorWeakPtr As IHttpAsyncProcessor Ptr
	pIWebSiteWeakPtr As IWebSite Ptr
End Type

Sub InitializeWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIHttpWriter As IHttpWriter Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_WRITERESPONSEASYNCTASK), _
			Len(WriteResponseAsyncTask.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalWriteResponseAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIHttpReader = NULL
	this->pIStream = NULL
	this->pIRequest = NULL
	this->pIResponse = pIResponse
	this->pIBuffer = NULL
	this->pIHttpWriter = pIHttpWriter
	this->pIProcessorWeakPtr = NULL
	this->pIWebSiteWeakPtr = NULL
	
End Sub

Sub UnInitializeWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)
	
	If this->pIRequest Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If this->pIHttpReader Then
		IHttpReader_Release(this->pIHttpReader)
	End If
	
	If this->pIBuffer Then
		IAttributedStream_Release(this->pIBuffer)
	End If
	
	If this->pIHttpWriter Then
		IHttpWriter_Release(this->pIHttpWriter)
	End If
	
	If this->pIResponse Then
		IServerResponse_Release(this->pIResponse)
	End If
	
End Sub

Function CreateWriteResponseAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WriteResponseAsyncTask Ptr
	
	Dim pIHttpWriter As IHttpWriter Ptr = Any
	Dim hrCreateWriter As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_HTTPWRITER, _
		@IID_IHttpWriter, _
		@pIHttpWriter _
	)
	
	If SUCCEEDED(hrCreateWriter) Then
		
		Dim pIResponse As IServerResponse Ptr = Any
		Dim hrCreateResponse As HRESULT = CreateInstance( _
			pIMemoryAllocator, _
			@CLSID_SERVERRESPONSE, _
			@IID_IServerResponse, _
			@pIResponse _
		)
		
		If SUCCEEDED(hrCreateResponse) Then
			
			Dim this As WriteResponseAsyncTask Ptr = IMalloc_Alloc( _
				pIMemoryAllocator, _
				SizeOf(WriteResponseAsyncTask) _
			)
			
			If this Then
				InitializeWriteResponseAsyncTask( _
					this, _
					pIMemoryAllocator, _
					pIResponse, _
					pIHttpWriter _
				)
				
				Return this
			End If
			
			IServerResponse_Release(pIResponse)
		End If
		
		IHttpWriter_Release(pIHttpWriter)
	End If
	
	Return NULL
	
End Function

Sub DestroyWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWriteResponseAsyncTask(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WriteResponseAsyncTaskQueryInterface( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWriteResponseAsyncIoTask, riid) Then
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
	
	WriteResponseAsyncTaskAddRef(this)
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskAddRef( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function WriteResponseAsyncTaskRelease( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyWriteResponseAsyncTask(this)
	
	Return 0
	
End Function

Function WriteResponseAsyncTaskBeginExecute( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim pc As ProcessorContext = Any
	pc.pIMemoryAllocator = this->pIMemoryAllocator
	pc.pIWebSite = this->pIWebSiteWeakPtr
	pc.pIRequest = this->pIRequest
	pc.pIResponse = this->pIResponse
	pc.pIReader = this->pIHttpReader
	pc.pIWriter = this->pIHttpWriter
	
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
	
End Function

Function WriteResponseAsyncTaskEndExecute( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim pc As ProcessorContext = Any
	pc.pIMemoryAllocator = this->pIMemoryAllocator
	pc.pIWebSite = this->pIWebSiteWeakPtr
	pc.pIRequest = this->pIRequest
	pc.pIResponse = this->pIResponse
	pc.pIReader = this->pIHttpReader
	pc.pIWriter = this->pIHttpWriter
	
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
			
			Dim KeepAlive As Boolean = Any
			IServerResponse_GetKeepAlive(this->pIResponse, @KeepAlive)
			
			If KeepAlive = False Then
				*ppNextTask = NULL
				Return ASYNCTASK_S_KEEPALIVE_FALSE
			End If
			
			Dim pTask As IReadRequestAsyncIoTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateInstance( _
				this->pIMemoryAllocator, _
				@CLSID_READREQUESTASYNCTASK, _
				@IID_IReadRequestAsyncIoTask, _
				@pTask _
			)
			If FAILED(hrCreateTask) Then
				' Мы не запускаем задачу отправки ошибки
				' Чтобы не войти в бесконечный цикл
				*ppNextTask = NULL
				Return hrCreateTask
			End If
			
			IHttpReader_Clear(this->pIHttpReader)
			
			IReadRequestAsyncIoTask_SetBaseStream(pTask, this->pIStream)
			IReadRequestAsyncIoTask_SetHttpReader(pTask, this->pIHttpReader)
			
			' Сейчас мы не уменьшаем счётчик ссылок на задачу
			' Счётчик ссылок уменьшим в пуле потоков после функции EndExecute
			*ppNextTask = CPtr(IAsyncIoTask Ptr, pTask)
			Return S_OK
			
		Case S_FALSE
			' Write 0 bytes
			*ppNextTask = NULL
			Return S_FALSE
			
		Case HTTPASYNCPROCESSOR_S_IO_PENDING
			' Продолжить отправку ответа
			WriteResponseAsyncTaskAddRef(this)
			*ppNextTask = CPtr(IAsyncIoTask Ptr, @this->lpVtbl)
			Return S_OK
			
	End Select
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskGetBaseStream( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_AddRef(this->pIStream)
	End If
	
	*ppStream = this->pIStream
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskSetBaseStream( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pStream As IBaseStream Ptr _
	)As HRESULT
	
	If this->pIStream Then
		IBaseStream_Release(this->pIStream)
	End If
	
	If pStream Then
		IBaseStream_AddRef(pStream)
	End If
	
	this->pIStream = pStream
	
	IHttpWriter_SetBaseStream(this->pIHttpWriter, pStream)
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskGetHttpReader( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	If this->pIHttpReader Then
		IHttpReader_AddRef(this->pIHttpReader)
	End If
	
	*ppReader = this->pIHttpReader
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskSetHttpReader( _
		ByVal this As WriteResponseAsyncTask Ptr, _
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

Function WriteResponseAsyncTaskGetClientRequest( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	If this->pIRequest Then
		IClientRequest_AddRef(this->pIRequest)
	End If
	
	*ppIRequest = this->pIRequest
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskSetClientRequest( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	If pIRequest Then
		IClientRequest_AddRef(pIRequest)
	End If
	
	If this->pIRequest Then
		IClientRequest_Release(this->pIRequest)
	End If
	
	this->pIRequest = pIRequest
	
	Return S_OK
	
End Function

Function WriteResponseAsyncTaskPrepare( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)As HRESULT
	
	Scope
		Dim KeepAlive As Boolean = True
		IClientRequest_GetKeepAlive(this->pIRequest, @KeepAlive)
		IServerResponse_SetKeepAlive(this->pIResponse, KeepAlive)
		IHttpWriter_SetKeepAlive(this->pIHttpWriter, KeepAlive)
	End Scope
	
	Scope
		Dim HttpVersion As HttpVersions = Any
		IClientRequest_GetHttpVersion(this->pIRequest, @HttpVersion)
		IServerResponse_SetHttpVersion(this->pIResponse, HttpVersion)
	End Scope
	
	Scope
		Dim hrFindSite As HRESULT = FindWebSiteWeakPtr( _
			pIWebSitesWeakPtr, _
			this->pIRequest, _
			@this->pIWebSiteWeakPtr _
		)
		If FAILED(hrFindSite) Then
			Return WEBSITE_E_SITENOTFOUND
		End If
	End Scope
	
	Scope
		Dim IsSiteMoved As Boolean = Any
		IWebSite_GetIsMoved(this->pIWebSiteWeakPtr, @IsSiteMoved)
		
		/'
		Dim IsSiteMoved As Boolean = Any
		
		' TODO Грязный хак с robots.txt
		' если запрошен документ /robots.txt то не перенаправлять
		
		Dim ClientURI As IClientUri Ptr = Any
		IClientRequest_GetUri(this->pIRequest, @ClientURI)
		
		Dim IsRobotsTxt As Long = lstrcmpiW(ClientURI.Path, WStr("/robots.txt"))
		If IsRobotsTxt = CompareResultEqual Then
			IsSiteMoved = False
		Else
			IWebSite_GetIsMoved(this->pIWebSite, @IsSiteMoved)
		End If
		
		IClientRequest_Release(ClientURI)
		'/
		
		If IsSiteMoved Then
			Return WEBSITE_E_REDIRECTED
		End If
	End Scope
	
	Scope
		Dim HttpMethod As HeapBSTR = Any
		IClientRequest_GetHttpMethod(this->pIRequest, @HttpMethod)
		
		Dim hrProcessorItem As HRESULT = IHttpProcessorCollection_ItemWeakPtr( _
			pIProcessorsWeakPtr, _
			HttpMethod, _
			@this->pIProcessorWeakPtr _
		)
		HeapSysFreeString(HttpMethod)
		
		If FAILED(hrProcessorItem) Then
			Return HTTPPROCESSOR_E_NOTIMPLEMENTED
		End If
	End Scope
	
	Scope
		Dim pc As ProcessorContext = Any
		pc.pIMemoryAllocator = this->pIMemoryAllocator
		pc.pIWebSite = this->pIWebSiteWeakPtr
		pc.pIRequest = this->pIRequest
		pc.pIResponse = this->pIResponse
		pc.pIReader = this->pIHttpReader
		pc.pIWriter = this->pIHttpWriter
		
		If this->pIBuffer Then
			IAttributedStream_Release(this->pIBuffer)
		End If
		
		Dim hrPrepareProcess As HRESULT = IHttpAsyncProcessor_Prepare( _
			this->pIProcessorWeakPtr, _
			@pc, _
			@this->pIBuffer _
		)
		If FAILED(hrPrepareProcess) Then
			Return hrPrepareProcess
		End If
		
		IHttpWriter_SetBuffer(this->pIHttpWriter, this->pIBuffer)
	End Scope
	
	Return S_OK
	
End Function


Function IWriteResponseAsyncTaskQueryInterface( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskQueryInterface(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), riid, ppv)
End Function

Function IWriteResponseAsyncTaskAddRef( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskAddRef(ContainerOf(this, WriteResponseAsyncTask, lpVtbl))
End Function

Function IWriteResponseAsyncTaskRelease( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskRelease(ContainerOf(this, WriteResponseAsyncTask, lpVtbl))
End Function

Function IWriteResponseAsyncTaskBeginExecute( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskBeginExecute(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppIResult)
End Function

Function IWriteResponseAsyncTaskEndExecute( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal ppNextTask As IAsyncIoTask Ptr Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskEndExecute(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIResult, BytesTransferred, ppNextTask)
End Function

Function IWriteResponseAsyncTaskGetBaseStream( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppStream As IBaseStream Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetBaseStream(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppStream)
End Function

Function IWriteResponseAsyncTaskSetBaseStream( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pStream As IBaseStream Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetBaseStream(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pStream)
End Function

Function IWriteResponseAsyncTaskGetHttpReader( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppReader As IHttpReader Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetHttpReader(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppReader)
End Function

Function IWriteResponseAsyncTaskSetHttpReader( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pReader As IHttpReader Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetHttpReader(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pReader)
End Function

Function IWriteResponseAsyncTaskGetClientRequest( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetClientRequest(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppIRequest)
End Function

Function IWriteResponseAsyncTaskSetClientRequest( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetClientRequest(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIRequest)
End Function

Function IWriteResponseAsyncTaskPrepare( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskPrepare(ContainerOf(this, WriteResponseAsyncTask, lpVtbl))
End Function

Dim GlobalWriteResponseAsyncIoTaskVirtualTable As Const IWriteResponseAsyncIoTaskVirtualTable = Type( _
	@IWriteResponseAsyncTaskQueryInterface, _
	@IWriteResponseAsyncTaskAddRef, _
	@IWriteResponseAsyncTaskRelease, _
	@IWriteResponseAsyncTaskBeginExecute, _
	@IWriteResponseAsyncTaskEndExecute, _
	@IWriteResponseAsyncTaskGetBaseStream, _
	@IWriteResponseAsyncTaskSetBaseStream, _
	@IWriteResponseAsyncTaskGetHttpReader, _
	@IWriteResponseAsyncTaskSetHttpReader, _
	@IWriteResponseAsyncTaskGetClientRequest, _
	@IWriteResponseAsyncTaskSetClientRequest, _
	@IWriteResponseAsyncTaskPrepare _
)
