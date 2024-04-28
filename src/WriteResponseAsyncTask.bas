#include once "WriteResponseAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "HttpProcessorCollection.bi"
#include once "HttpAsyncWriter.bi"
#include once "ServerResponse.bi"
#include once "WebsiteCollection.bi"
#include once "WebUtils.bi"

Extern GlobalWriteResponseAsyncIoTaskVirtualTable As Const IWriteResponseAsyncIoTaskVirtualTable

Const CompareResultEqual As Long = 0

Type WriteResponseAsyncTask
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IWriteResponseAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIHttpAsyncReader As IHttpAsyncReader Ptr
	pIStream As IBaseAsyncStream Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pIBuffer As IAttributedAsyncStream Ptr
	pIHttpAsyncWriter As IHttpAsyncWriter Ptr
	pIProcessorWeakPtr As IHttpAsyncProcessor Ptr
	pIWebSiteWeakPtr As IWebSite Ptr
End Type

Private Sub InitializeWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIHttpAsyncWriter As IHttpAsyncWriter Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_WRITERESPONSEASYNCTASK), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalWriteResponseAsyncIoTaskVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIHttpAsyncReader = NULL
	this->pIStream = NULL
	this->pIRequest = NULL
	' Do not need AddRef pIResponse
	this->pIResponse = pIResponse
	this->pIBuffer = NULL
	' Do not need AddRef pIHttpAsyncWriter
	this->pIHttpAsyncWriter = pIHttpAsyncWriter
	this->pIProcessorWeakPtr = NULL

End Sub

Private Sub UnInitializeWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)

	If this->pIStream Then
		IBaseAsyncStream_Release(this->pIStream)
	End If

	If this->pIHttpAsyncReader Then
		IHttpAsyncReader_Release(this->pIHttpAsyncReader)
	End If

	If this->pIBuffer Then
		IAttributedAsyncStream_Release(this->pIBuffer)
	End If

	If this->pIRequest Then
		IClientRequest_Release(this->pIRequest)
	End If

	If this->pIResponse Then
		IServerResponse_Release(this->pIResponse)
	End If

	If this->pIHttpAsyncWriter Then
		IHttpAsyncWriter_Release(this->pIHttpAsyncWriter)
	End If

End Sub

Private Sub WriteResponseAsyncTaskCreated( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)

End Sub

Private Sub WriteResponseAsyncTaskDestroyed( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)

End Sub

Private Sub DestroyWriteResponseAsyncTask( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeWriteResponseAsyncTask(this)

	IMalloc_Free(pIMemoryAllocator, this)

	WriteResponseAsyncTaskDestroyed(this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function WriteResponseAsyncTaskAddRef( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function WriteResponseAsyncTaskRelease( _
		ByVal this As WriteResponseAsyncTask Ptr _
	)As ULONG

	this->ReferenceCounter -= 1

	If this->ReferenceCounter Then
		Return 1
	End If

	DestroyWriteResponseAsyncTask(this)

	Return 0

End Function

Private Function WriteResponseAsyncTaskQueryInterface( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IWriteResponseAsyncIoTask, riid) Then
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

	WriteResponseAsyncTaskAddRef(this)

	Return S_OK

End Function

Public Function CreateWriteResponseAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim this As WriteResponseAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WriteResponseAsyncTask) _
	)

	If this Then
		Dim pIHttpAsyncWriter As IHttpAsyncWriter Ptr = Any
		Dim hrCreateWriter As HRESULT = CreateHttpWriter( _
			pIMemoryAllocator, _
			@IID_IHttpAsyncWriter, _
			@pIHttpAsyncWriter _
		)

		If SUCCEEDED(hrCreateWriter) Then

			Dim pIResponse As IServerResponse Ptr = Any
			Dim hrCreateResponse As HRESULT = CreateServerResponse( _
				pIMemoryAllocator, _
				@IID_IServerResponse, _
				@pIResponse _
			)

			If SUCCEEDED(hrCreateResponse) Then

				InitializeWriteResponseAsyncTask( _
					this, _
					pIMemoryAllocator, _
					pIResponse, _
					pIHttpAsyncWriter _
				)

				WriteResponseAsyncTaskCreated(this)

				Dim hrQueryInterface As HRESULT = WriteResponseAsyncTaskQueryInterface( _
					this, _
					riid, _
					ppv _
				)
				If FAILED(hrQueryInterface) Then
					DestroyWriteResponseAsyncTask(this)
				End If

				Return hrQueryInterface
			End If

			IHttpAsyncWriter_Release(pIHttpAsyncWriter)
		End If

		IMalloc_Free( _
			pIMemoryAllocator, _
			this _
		)
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function WriteResponseAsyncTaskBeginExecute( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim pc As ProcessorContext = Any
	pc.pIMemoryAllocator = this->pIMemoryAllocator
	pc.pIWebSite = this->pIWebSiteWeakPtr
	pc.pIRequest = this->pIRequest
	pc.pIResponse = this->pIResponse
	pc.pIReader = this->pIHttpAsyncReader
	pc.pIWriter = this->pIHttpAsyncWriter

	Dim hrBeginProcess As HRESULT = IHttpAsyncProcessor_BeginProcess( _
		this->pIProcessorWeakPtr, _
		@pc, _
		pcb, _
		StateObject, _
		ppIResult _
	)
	If FAILED(hrBeginProcess) Then
		Return hrBeginProcess
	End If

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskEndExecute( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	Dim pc As ProcessorContext = Any
	pc.pIMemoryAllocator = this->pIMemoryAllocator
	pc.pIWebSite = this->pIWebSiteWeakPtr
	pc.pIRequest = this->pIRequest
	pc.pIResponse = this->pIResponse
	pc.pIReader = this->pIHttpAsyncReader
	pc.pIWriter = this->pIHttpAsyncWriter

	Dim hrEndProcess As HRESULT = IHttpAsyncProcessor_EndProcess( _
		this->pIProcessorWeakPtr, _
		@pc, _
		pIResult _
	)
	If FAILED(hrEndProcess) Then
		Return hrEndProcess
	End If

	Select Case hrEndProcess

		Case S_OK

			Dim KeepAlive As Boolean = Any
			IServerResponse_GetKeepAlive(this->pIResponse, @KeepAlive)

			If KeepAlive = False Then
				Return S_FALSE
			End If

			Return S_OK

		Case S_FALSE
	' 		' Write 0 bytes
			Return S_FALSE

		Case HTTPASYNCPROCESSOR_S_IO_PENDING
			Return WRITERESPONSEASYNCIOTASK_S_IO_PENDING

	End Select

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskGetBaseStream( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	If this->pIStream Then
		IBaseAsyncStream_AddRef(this->pIStream)
	End If

	*ppStream = this->pIStream

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskSetBaseStream( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT

	If this->pIStream Then
		IBaseAsyncStream_Release(this->pIStream)
	End If

	If pStream Then
		IBaseAsyncStream_AddRef(pStream)
	End If

	this->pIStream = pStream

	IHttpAsyncWriter_SetBaseStream(this->pIHttpAsyncWriter, pStream)

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskGetHttpReader( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT

	If this->pIHttpAsyncReader Then
		IHttpAsyncReader_AddRef(this->pIHttpAsyncReader)
	End If

	*ppReader = this->pIHttpAsyncReader

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskSetHttpReader( _
		ByVal this As WriteResponseAsyncTask Ptr, _
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

Private Function WriteResponseAsyncTaskGetClientRequest( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT

	If this->pIRequest Then
		IClientRequest_AddRef(this->pIRequest)
	End If

	*ppIRequest = this->pIRequest

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskSetClientRequest( _
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

Private Function WriteResponseAsyncTaskPrepare( _
		ByVal this As WriteResponseAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT

	Scope
		Dim KeepAlive As Boolean = True
		IClientRequest_GetKeepAlive(this->pIRequest, @KeepAlive)
		IServerResponse_SetKeepAlive(this->pIResponse, KeepAlive)
		IHttpAsyncWriter_SetKeepAlive(this->pIHttpAsyncWriter, KeepAlive)
	End Scope

	Scope
		Dim HttpVersion As HttpVersions = Any
		IClientRequest_GetHttpVersion(this->pIRequest, @HttpVersion)
		IServerResponse_SetHttpVersion(this->pIResponse, HttpVersion)
	End Scope

	Scope
		Dim hrFindSite As HRESULT = FindWebSiteWeakPtr( _
			pIWebSites, _
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

		' TODO Грязный хак с robots.txt
		' если запрошен документ /robots.txt то не перенаправлять
		' Dim IsSiteMoved As Boolean = Any

		' Dim ClientURI As IClientUri Ptr = Any
		' IClientRequest_GetUri(this->pIRequest, @ClientURI)

		' Dim IsRobotsTxt As Long = lstrcmpiW(ClientURI.Path, WStr("/robots.txt"))
		' If IsRobotsTxt = CompareResultEqual Then
		' 	IsSiteMoved = False
		' Else
		' 	IWebSite_GetIsMoved(this->pIWebSite, @IsSiteMoved)
		' End If

		' IClientUri_Release(ClientURI)

		If IsSiteMoved Then
			Return WEBSITE_E_REDIRECTED
		End If
	End Scope

	Scope
		Dim HttpMethod As HeapBSTR = Any
		IClientRequest_GetHttpMethod(this->pIRequest, @HttpMethod)

		Dim pIProcessorsWeakPtr As IHttpProcessorCollection Ptr = Any
		IWebSite_GetProcessorCollectionWeakPtr( _
			this->pIWebSiteWeakPtr, _
			@pIProcessorsWeakPtr _
		)

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
		pc.pIReader = this->pIHttpAsyncReader
		pc.pIWriter = this->pIHttpAsyncWriter

		If this->pIBuffer Then
			IAttributedAsyncStream_Release(this->pIBuffer)
		End If

		Dim hrPrepareProcess As HRESULT = IHttpAsyncProcessor_Prepare( _
			this->pIProcessorWeakPtr, _
			@pc, _
			@this->pIBuffer _
		)
		If FAILED(hrPrepareProcess) Then
			Return hrPrepareProcess
		End If

		IHttpAsyncWriter_SetBuffer(this->pIHttpAsyncWriter, this->pIBuffer)
	End Scope

	Return S_OK

End Function


Private Function IWriteResponseAsyncTaskQueryInterface( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskQueryInterface(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), riid, ppv)
End Function

Private Function IWriteResponseAsyncTaskAddRef( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskAddRef(ContainerOf(this, WriteResponseAsyncTask, lpVtbl))
End Function

Private Function IWriteResponseAsyncTaskRelease( _
		ByVal this As IWriteResponseAsyncIoTask Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskRelease(ContainerOf(this, WriteResponseAsyncTask, lpVtbl))
End Function

Private Function IWriteResponseAsyncTaskBeginExecute( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskBeginExecute(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pcb, StateObject, ppIResult)
End Function

Private Function IWriteResponseAsyncTaskEndExecute( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskEndExecute(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIResult)
End Function

Private Function IWriteResponseAsyncTaskGetBaseStream( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetBaseStream(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppStream)
End Function

Private Function IWriteResponseAsyncTaskSetBaseStream( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetBaseStream(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pStream)
End Function

Private Function IWriteResponseAsyncTaskGetHttpReader( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetHttpReader(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppReader)
End Function

Private Function IWriteResponseAsyncTaskSetHttpReader( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetHttpReader(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pReader)
End Function

Private Function IWriteResponseAsyncTaskGetClientRequest( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetClientRequest(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), ppIRequest)
End Function

Private Function IWriteResponseAsyncTaskSetClientRequest( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetClientRequest(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIRequest)
End Function

Private Function IWriteResponseAsyncTaskPrepare( _
		ByVal this As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskPrepare(ContainerOf(this, WriteResponseAsyncTask, lpVtbl), pIWebSites)
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
