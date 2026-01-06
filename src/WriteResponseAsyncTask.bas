#include once "WriteResponseAsyncTask.bi"
#include once "ClientRequest.bi"
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
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIHttpAsyncWriter As IHttpAsyncWriter Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_WRITERESPONSEASYNCTASK), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalWriteResponseAsyncIoTaskVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->pIHttpAsyncReader = NULL
	self->pIStream = NULL
	self->pIRequest = NULL
	' Do not need AddRef pIResponse
	self->pIResponse = pIResponse
	self->pIBuffer = NULL
	' Do not need AddRef pIHttpAsyncWriter
	self->pIHttpAsyncWriter = pIHttpAsyncWriter
	self->pIProcessorWeakPtr = NULL

End Sub

Private Sub UnInitializeWriteResponseAsyncTask( _
		ByVal self As WriteResponseAsyncTask Ptr _
	)

	If self->pIStream Then
		IBaseAsyncStream_Release(self->pIStream)
	End If

	If self->pIHttpAsyncReader Then
		IHttpAsyncReader_Release(self->pIHttpAsyncReader)
	End If

	If self->pIBuffer Then
		IAttributedAsyncStream_Release(self->pIBuffer)
	End If

	If self->pIRequest Then
		IClientRequest_Release(self->pIRequest)
	End If

	If self->pIResponse Then
		IServerResponse_Release(self->pIResponse)
	End If

	If self->pIHttpAsyncWriter Then
		IHttpAsyncWriter_Release(self->pIHttpAsyncWriter)
	End If

End Sub

Private Sub DestroyWriteResponseAsyncTask( _
		ByVal self As WriteResponseAsyncTask Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeWriteResponseAsyncTask(self)

	IMalloc_Free(pIMemoryAllocator, self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function WriteResponseAsyncTaskAddRef( _
		ByVal self As WriteResponseAsyncTask Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function WriteResponseAsyncTaskRelease( _
		ByVal self As WriteResponseAsyncTask Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyWriteResponseAsyncTask(self)

	Return 0

End Function

Private Function WriteResponseAsyncTaskQueryInterface( _
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IWriteResponseAsyncIoTask, riid) Then
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

	WriteResponseAsyncTaskAddRef(self)

	Return S_OK

End Function

Public Function CreateWriteResponseAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As WriteResponseAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WriteResponseAsyncTask) _
	)

	If self Then
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
					self, _
					pIMemoryAllocator, _
					pIResponse, _
					pIHttpAsyncWriter _
				)

				Dim hrQueryInterface As HRESULT = WriteResponseAsyncTaskQueryInterface( _
					self, _
					riid, _
					ppv _
				)
				If FAILED(hrQueryInterface) Then
					DestroyWriteResponseAsyncTask(self)
				End If

				Return hrQueryInterface
			End If

			IHttpAsyncWriter_Release(pIHttpAsyncWriter)
		End If

		IMalloc_Free( _
			pIMemoryAllocator, _
			self _
		)
	End If

	*ppv = NULL
	Return E_OUTOFMEMORY

End Function

Private Function WriteResponseAsyncTaskBeginExecute( _
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	Dim pc As ProcessorContext = Any
	pc.pIMemoryAllocator = self->pIMemoryAllocator
	pc.pIWebSite = self->pIWebSiteWeakPtr
	pc.pIRequest = self->pIRequest
	pc.pIResponse = self->pIResponse
	pc.pIReader = self->pIHttpAsyncReader
	pc.pIWriter = self->pIHttpAsyncWriter

	Dim hrBeginProcess As HRESULT = IHttpAsyncProcessor_BeginProcess( _
		self->pIProcessorWeakPtr, _
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
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	Dim pc As ProcessorContext = Any
	pc.pIMemoryAllocator = self->pIMemoryAllocator
	pc.pIWebSite = self->pIWebSiteWeakPtr
	pc.pIRequest = self->pIRequest
	pc.pIResponse = self->pIResponse
	pc.pIReader = self->pIHttpAsyncReader
	pc.pIWriter = self->pIHttpAsyncWriter

	Dim hrEndProcess As HRESULT = IHttpAsyncProcessor_EndProcess( _
		self->pIProcessorWeakPtr, _
		@pc, _
		pIResult _
	)
	If FAILED(hrEndProcess) Then
		Return hrEndProcess
	End If

	Select Case hrEndProcess

		Case S_OK

			Dim KeepAlive As Boolean = Any
			IServerResponse_GetKeepAlive(self->pIResponse, @KeepAlive)

			If KeepAlive = False Then
				Return S_FALSE
			End If

			Return S_OK

		Case S_FALSE
			' Write 0 bytes
			Return S_FALSE

		Case HTTPASYNCPROCESSOR_S_IO_PENDING
			Return WRITERESPONSEASYNCIOTASK_S_IO_PENDING

	End Select

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskGetBaseStream( _
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	If self->pIStream Then
		IBaseAsyncStream_AddRef(self->pIStream)
	End If

	*ppStream = self->pIStream

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskSetBaseStream( _
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT

	If self->pIStream Then
		IBaseAsyncStream_Release(self->pIStream)
	End If

	If pStream Then
		IBaseAsyncStream_AddRef(pStream)
	End If

	self->pIStream = pStream

	IHttpAsyncWriter_SetBaseStream(self->pIHttpAsyncWriter, pStream)

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskGetHttpReader( _
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT

	If self->pIHttpAsyncReader Then
		IHttpAsyncReader_AddRef(self->pIHttpAsyncReader)
	End If

	*ppReader = self->pIHttpAsyncReader

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskSetHttpReader( _
		ByVal self As WriteResponseAsyncTask Ptr, _
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

Private Function WriteResponseAsyncTaskGetClientRequest( _
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT

	If self->pIRequest Then
		IClientRequest_AddRef(self->pIRequest)
	End If

	*ppIRequest = self->pIRequest

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskSetClientRequest( _
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT

	If pIRequest Then
		IClientRequest_AddRef(pIRequest)
	End If

	If self->pIRequest Then
		IClientRequest_Release(self->pIRequest)
	End If

	self->pIRequest = pIRequest

	Return S_OK

End Function

Private Function WriteResponseAsyncTaskPrepare( _
		ByVal self As WriteResponseAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT

	Scope
		Dim KeepAlive As Boolean = True
		IClientRequest_GetKeepAlive(self->pIRequest, @KeepAlive)
		IServerResponse_SetKeepAlive(self->pIResponse, KeepAlive)
		IHttpAsyncWriter_SetKeepAlive(self->pIHttpAsyncWriter, KeepAlive)
	End Scope

	Scope
		Dim HttpVersion As HttpVersions = Any
		IClientRequest_GetHttpVersion(self->pIRequest, @HttpVersion)
		IServerResponse_SetHttpVersion(self->pIResponse, HttpVersion)
	End Scope

	Scope
		Dim hrFindSite As HRESULT = FindWebSiteWeakPtr( _
			pIWebSites, _
			self->pIRequest, _
			@self->pIWebSiteWeakPtr _
		)
		If FAILED(hrFindSite) Then
			Return WEBSITE_E_SITENOTFOUND
		End If
	End Scope

	Scope
		Dim IsSiteMoved As Boolean = Any
		IWebSite_GetIsMoved(self->pIWebSiteWeakPtr, @IsSiteMoved)

		' TODO Грязный хак с robots.txt
		' если запрошен документ /robots.txt то не перенаправлять
		' Dim IsSiteMoved As Boolean = Any

		' Dim ClientURI As IClientUri Ptr = Any
		' IClientRequest_GetUri(self->pIRequest, @ClientURI)

		' Dim IsRobotsTxt As Long = lstrcmpiW(ClientURI.Path, WStr("/robots.txt"))
		' If IsRobotsTxt = CompareResultEqual Then
		' 	IsSiteMoved = False
		' Else
		' 	IWebSite_GetIsMoved(self->pIWebSite, @IsSiteMoved)
		' End If

		' IClientUri_Release(ClientURI)

		If IsSiteMoved Then
			Return WEBSITE_E_REDIRECTED
		End If
	End Scope

	Scope
		Dim HttpMethod As HeapBSTR = Any
		IClientRequest_GetHttpMethod(self->pIRequest, @HttpMethod)

		Dim pIProcessorsWeakPtr As IHttpProcessorCollection Ptr = Any
		IWebSite_GetProcessorCollectionWeakPtr( _
			self->pIWebSiteWeakPtr, _
			@pIProcessorsWeakPtr _
		)

		Dim hrProcessorItem As HRESULT = IHttpProcessorCollection_ItemWeakPtr( _
			pIProcessorsWeakPtr, _
			HttpMethod, _
			@self->pIProcessorWeakPtr _
		)

		HeapSysFreeString(HttpMethod)

		If FAILED(hrProcessorItem) Then
			Return HTTPPROCESSOR_E_NOTIMPLEMENTED
		End If
	End Scope

	Scope
		Dim pc As ProcessorContext = Any
		pc.pIMemoryAllocator = self->pIMemoryAllocator
		pc.pIWebSite = self->pIWebSiteWeakPtr
		pc.pIRequest = self->pIRequest
		pc.pIResponse = self->pIResponse
		pc.pIReader = self->pIHttpAsyncReader
		pc.pIWriter = self->pIHttpAsyncWriter

		If self->pIBuffer Then
			IAttributedAsyncStream_Release(self->pIBuffer)
		End If

		Dim hrPrepareProcess As HRESULT = IHttpAsyncProcessor_Prepare( _
			self->pIProcessorWeakPtr, _
			@pc, _
			@self->pIBuffer _
		)
		If FAILED(hrPrepareProcess) Then
			Return hrPrepareProcess
		End If

		IHttpAsyncWriter_SetBuffer(self->pIHttpAsyncWriter, self->pIBuffer)
	End Scope

	Return S_OK

End Function


Private Function IWriteResponseAsyncTaskQueryInterface( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskQueryInterface(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), riid, ppv)
End Function

Private Function IWriteResponseAsyncTaskAddRef( _
		ByVal self As IWriteResponseAsyncIoTask Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskAddRef(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl))
End Function

Private Function IWriteResponseAsyncTaskRelease( _
		ByVal self As IWriteResponseAsyncIoTask Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskRelease(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl))
End Function

Private Function IWriteResponseAsyncTaskBeginExecute( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskBeginExecute(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), pcb, StateObject, ppIResult)
End Function

Private Function IWriteResponseAsyncTaskEndExecute( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As ULONG
	Return WriteResponseAsyncTaskEndExecute(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), pIResult)
End Function

Private Function IWriteResponseAsyncTaskGetBaseStream( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetBaseStream(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), ppStream)
End Function

Private Function IWriteResponseAsyncTaskSetBaseStream( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		byVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetBaseStream(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), pStream)
End Function

Private Function IWriteResponseAsyncTaskGetHttpReader( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppReader As IHttpAsyncReader Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetHttpReader(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), ppReader)
End Function

Private Function IWriteResponseAsyncTaskSetHttpReader( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		byVal pReader As IHttpAsyncReader Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetHttpReader(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), pReader)
End Function

Private Function IWriteResponseAsyncTaskGetClientRequest( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskGetClientRequest(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), ppIRequest)
End Function

Private Function IWriteResponseAsyncTaskSetClientRequest( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskSetClientRequest(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), pIRequest)
End Function

Private Function IWriteResponseAsyncTaskPrepare( _
		ByVal self As IWriteResponseAsyncIoTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	Return WriteResponseAsyncTaskPrepare(CONTAINING_RECORD(self, WriteResponseAsyncTask, lpVtbl), pIWebSites)
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
