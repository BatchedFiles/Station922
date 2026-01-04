#include once "WriteErrorAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "HeapBSTR.bi"
#include once "HttpAsyncWriter.bi"
#include once "ServerResponse.bi"
#include once "WebsiteCollection.bi"
#include once "WebUtils.bi"

Extern GlobalWriteErrorAsyncIoTaskVirtualTable As Const IWriteErrorAsyncIoTaskVirtualTable

Const CompareResultEqual As Long = 0

Const DefaultHeaderWwwAuthenticate = WStr("Basic realm=""Need username and password""")
Const DefaultHeaderWwwAuthenticate1 = WStr("Basic realm=""Authorization""")
Const DefaultHeaderWwwAuthenticate2 = WStr("Basic realm=""Use Basic auth""")
Const DefaultRetryAfterString = WStr("300")

Type WriteErrorAsyncTask
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IWriteErrorAsyncIoTaskVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIStream As IBaseAsyncStream Ptr
	pIRequest As IClientRequest Ptr
	pIResponse As IServerResponse Ptr
	pIBuffer As IAttributedAsyncStream Ptr
	pIHttpAsyncWriter As IHttpAsyncWriter Ptr
	pIWebSitesWeakPtr As IWebSiteCollection Ptr
	HttpError As ResponseErrorCode
	hrErrorCode As HRESULT
End Type

Private Function WriteErrorAsyncTaskGetStatusCode( _
		ByVal self As WriteErrorAsyncTask Ptr _
	)As HttpStatusCodes

	Select Case self->HttpError

		Case ResponseErrorCode.MovedPermanently
			Dim pIWebSiteWeakPtr As IWebSite Ptr = Any
			Dim hrFindSite As HRESULT = FindWebSiteWeakPtr( _
				self->pIWebSitesWeakPtr, _
				self->pIRequest, _
				@pIWebSiteWeakPtr _
			)

			If SUCCEEDED(hrFindSite) Then
				Dim MovedUrl As HeapBSTR = Any
				IWebSite_GetMovedUrl(pIWebSiteWeakPtr, @MovedUrl)

				Dim ClientURI As IClientUri Ptr = Any
				IClientRequest_GetUri(self->pIRequest, @ClientURI)

				Dim Path As HeapBSTR = Any
				IClientUri_GetPath(ClientURI, @Path)

				Dim buf As WString * (1500 + 1) = Any
				lstrcpyW(@buf, MovedUrl)
				lstrcatW(@buf, Path)

				IServerResponse_AddKnownResponseHeaderWstr( _
					self->pIResponse, _
					HttpResponseHeaders.HeaderLocation, _
					@buf _
				)

				HeapSysFreeString(Path)
				IClientUri_Release(ClientURI)
				HeapSysFreeString(MovedUrl)
			End If

			Return HttpStatusCodes.MovedPermanently

		Case ResponseErrorCode.BadRequest
			Return HttpStatusCodes.BadRequest

		Case ResponseErrorCode.PathNotValid
			Return HttpStatusCodes.BadRequest

		Case ResponseErrorCode.HostNotFound
			Return HttpStatusCodes.BadRequest

		Case ResponseErrorCode.SiteNotFound
			Return HttpStatusCodes.NotFound

		Case ResponseErrorCode.NeedAuthenticate
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				self->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			Return HttpStatusCodes.Unauthorized

		Case ResponseErrorCode.BadAuthenticateParam
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				self->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate1, _
				Len(DefaultHeaderWwwAuthenticate1) _
			)
			Return HttpStatusCodes.Unauthorized

		Case ResponseErrorCode.NeedBasicAuthenticate
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				self->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate2, _
				Len(DefaultHeaderWwwAuthenticate2) _
			)
			Return HttpStatusCodes.Unauthorized

		Case ResponseErrorCode.EmptyPassword
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				self->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			Return HttpStatusCodes.Unauthorized

		Case ResponseErrorCode.BadUserNamePassword
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				self->pIResponse, _
				HttpResponseHeaders.HeaderWwwAuthenticate, _
				@DefaultHeaderWwwAuthenticate, _
				Len(DefaultHeaderWwwAuthenticate) _
			)
			Return HttpStatusCodes.Unauthorized

		Case ResponseErrorCode.Forbidden
			Return HttpStatusCodes.Forbidden

		Case ResponseErrorCode.FileNotFound
			Return HttpStatusCodes.NotFound

		Case ResponseErrorCode.MethodNotAllowed
			Return HttpStatusCodes.MethodNotAllowed

		Case ResponseErrorCode.FileGone
			Return HttpStatusCodes.Gone

		Case ResponseErrorCode.LengthRequired
			Return HttpStatusCodes.LengthRequired

		Case ResponseErrorCode.RequestEntityTooLarge
			Return HttpStatusCodes.RequestEntityTooLarge

		Case ResponseErrorCode.RequestUrlTooLarge
			Return HttpStatusCodes.RequestURITooLarge

		Case ResponseErrorCode.RequestRangeNotSatisfiable
			Return HttpStatusCodes.RangeNotSatisfiable

		Case ResponseErrorCode.RequestHeaderFieldsTooLarge
			Return HttpStatusCodes.RequestHeaderFieldsTooLarge

		Case ResponseErrorCode.InternalServerError
			Return HttpStatusCodes.InternalServerError

		Case ResponseErrorCode.FileNotAvailable
			Return HttpStatusCodes.InternalServerError

		Case ResponseErrorCode.CannotCreateChildProcess
			Return HttpStatusCodes.InternalServerError

		Case ResponseErrorCode.CannotCreatePipe
			Return HttpStatusCodes.InternalServerError

		Case ResponseErrorCode.NotImplemented

			Dim pIWebSiteWeakPtr As IWebSite Ptr = Any
			Dim hrFindSite As HRESULT = FindWebSiteWeakPtr( _
				self->pIWebSitesWeakPtr, _
				self->pIRequest, _
				@pIWebSiteWeakPtr _
			)

			If SUCCEEDED(hrFindSite) Then

				Dim pIProcessorsWeakPtr As IHttpProcessorCollection Ptr = Any
				IWebSite_GetProcessorCollectionWeakPtr( _
					pIWebSiteWeakPtr, _
					@pIProcessorsWeakPtr _
				)

				Dim AllMethods As HeapBSTR = Any
				IHttpProcessorCollection_GetAllMethods( _
					pIProcessorsWeakPtr, _
					@AllMethods _
				)
				IServerResponse_AddKnownResponseHeader( _
					self->pIResponse, _
					HttpResponseHeaders.HeaderAllow, _
					AllMethods _
				)
				HeapSysFreeString(AllMethods)
			End If

			Return HttpStatusCodes.NotImplemented

		Case ResponseErrorCode.ContentTypeEmpty
			Return HttpStatusCodes.NotImplemented

		Case ResponseErrorCode.ContentEncodingNotEmpty
			Return HttpStatusCodes.NotImplemented

		Case ResponseErrorCode.BadGateway
			Return HttpStatusCodes.BadGateway

		Case ResponseErrorCode.NotEnoughMemory
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				self->pIResponse, _
				HttpResponseHeaders.HeaderRetryAfter, _
				@DefaultRetryAfterString, _
				Len(DefaultRetryAfterString) _
			)
			Return HttpStatusCodes.ServiceUnavailable

		Case ResponseErrorCode.CannotCreateThread
			IServerResponse_AddKnownResponseHeaderWstrLen( _
				self->pIResponse, _
				HttpResponseHeaders.HeaderRetryAfter, _
				@DefaultRetryAfterString, _
				Len(DefaultRetryAfterString) _
			)
			Return HttpStatusCodes.ServiceUnavailable

		Case ResponseErrorCode.GatewayTimeout
			Return HttpStatusCodes.GatewayTimeout

		Case ResponseErrorCode.VersionNotSupported
			Return HttpStatusCodes.HTTPVersionNotSupported

		Case Else
			Return HttpStatusCodes.InternalServerError

	End Select

End Function

Private Sub InitializeWriteErrorAsyncTask( _
		ByVal self As WriteErrorAsyncTask Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pIHttpAsyncWriter As IHttpAsyncWriter Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@self->RttiClassName(0), _
			@Str(RTTI_ID_WRITEERRORASYNCTASK), _
			UBound(self->RttiClassName) - LBound(self->RttiClassName) + 1 _
		)
	#endif
	self->lpVtbl = @GlobalWriteErrorAsyncIoTaskVirtualTable
	self->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	self->pIMemoryAllocator = pIMemoryAllocator
	self->pIStream = NULL
	self->pIRequest = NULL
	' Do not need AddRef pIResponse
	self->pIResponse = pIResponse
	self->pIBuffer = NULL
	' Do not need AddRef pIHttpAsyncWriter
	self->pIHttpAsyncWriter = pIHttpAsyncWriter
	self->pIWebSitesWeakPtr = NULL

End Sub

Private Sub UnInitializeWriteErrorAsyncTask( _
		ByVal self As WriteErrorAsyncTask Ptr _
	)

	If self->pIRequest Then
		IClientRequest_Release(self->pIRequest)
	End If

	If self->pIStream Then
		IBaseAsyncStream_Release(self->pIStream)
	End If

	If self->pIBuffer Then
		IAttributedAsyncStream_Release(self->pIBuffer)
	End If

	If self->pIHttpAsyncWriter Then
		IHttpAsyncWriter_Release(self->pIHttpAsyncWriter)
	End If

	If self->pIResponse Then
		IServerResponse_Release(self->pIResponse)
	End If

End Sub

Private Sub WriteErrorAsyncTaskCreated( _
		ByVal self As WriteErrorAsyncTask Ptr _
	)

End Sub

Private Sub WriteErrorAsyncTaskDestroyed( _
		ByVal self As WriteErrorAsyncTask Ptr _
	)

End Sub

Private Sub DestroyWriteErrorAsyncTask( _
		ByVal self As WriteErrorAsyncTask Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = self->pIMemoryAllocator

	UnInitializeWriteErrorAsyncTask(self)

	IMalloc_Free(pIMemoryAllocator, self)

	WriteErrorAsyncTaskDestroyed(self)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function WriteErrorAsyncTaskAddRef( _
		ByVal self As WriteErrorAsyncTask Ptr _
	)As ULONG

	self->ReferenceCounter += 1

	Return 1

End Function

Private Function WriteErrorAsyncTaskRelease( _
		ByVal self As WriteErrorAsyncTask Ptr _
	)As ULONG

	self->ReferenceCounter -= 1

	If self->ReferenceCounter Then
		Return 1
	End If

	DestroyWriteErrorAsyncTask(self)

	Return 0

End Function

Private Function WriteErrorAsyncTaskQueryInterface( _
		ByVal self As WriteErrorAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IWriteErrorAsyncIoTask, riid) Then
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

	WriteErrorAsyncTaskAddRef(self)

	Return S_OK

End Function

Public Function CreateWriteErrorAsyncTask( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim self As WriteErrorAsyncTask Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WriteErrorAsyncTask) _
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

				InitializeWriteErrorAsyncTask( _
					self, _
					pIMemoryAllocator, _
					pIResponse, _
					pIHttpAsyncWriter _
				)
				WriteErrorAsyncTaskCreated(self)

				Dim hrQueryInterface As HRESULT = WriteErrorAsyncTaskQueryInterface( _
					self, _
					riid, _
					ppv _
				)
				If FAILED(hrQueryInterface) Then
					DestroyWriteErrorAsyncTask(self)
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

Private Function WriteErrorAsyncTaskBeginExecute( _
		ByVal self As WriteErrorAsyncTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	' TODO Запросить интерфейс вместо конвертирования указателя
	Dim hrBeginWrite As HRESULT = IHttpAsyncWriter_BeginWrite( _
		self->pIHttpAsyncWriter, _
		pcb, _
		StateObject, _
		ppIResult _
	)
	If FAILED(hrBeginWrite) Then
		Return hrBeginWrite
	End If

	Return S_OK

End Function

Private Function WriteErrorAsyncTaskEndExecute( _
		ByVal self As WriteErrorAsyncTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

	Dim hrEndWrite As HRESULT = IHttpAsyncWriter_EndWrite( _
		self->pIHttpAsyncWriter, _
		pIResult _
	)
	If FAILED(hrEndWrite) Then
		Return hrEndWrite
	End If

	Select Case hrEndWrite

		Case S_OK
			' Close the connection when an error occurred
			Return S_OK

		Case S_FALSE
			' Write 0 bytes
			Return S_OK

		Case HTTPWRITER_S_IO_PENDING
			Return WRITEERRORASYNCIOTASK_S_IO_PENDING

	End Select

	Return S_OK

End Function

Private Function WriteErrorAsyncTaskGetBaseStream( _
		ByVal self As WriteErrorAsyncTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT

	If self->pIStream Then
		IBaseAsyncStream_AddRef(self->pIStream)
	End If

	*ppStream = self->pIStream

	Return S_OK

End Function

Private Function WriteErrorAsyncTaskSetBaseStream( _
		ByVal self As WriteErrorAsyncTask Ptr, _
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

Private Function WriteErrorAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal self As WriteErrorAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT

	self->pIWebSitesWeakPtr = pIWebSites

	Return S_OK

End Function

Private Function WriteErrorAsyncTaskGetClientRequest( _
		ByVal self As WriteErrorAsyncTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT

	If self->pIRequest Then
		IClientRequest_AddRef(self->pIRequest)
	End If

	*ppIRequest = self->pIRequest

	Return S_OK

End Function

Private Function WriteErrorAsyncTaskSetClientRequest( _
		ByVal self As WriteErrorAsyncTask Ptr, _
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

Private Function WriteErrorAsyncTaskPrepare( _
		ByVal self As WriteErrorAsyncTask Ptr _
	)As HRESULT

	Dim StatusCode As HttpStatusCodes = WriteErrorAsyncTaskGetStatusCode(self)
	IServerResponse_SetStatusCode( _
		self->pIResponse, _
		StatusCode _
	)

	Dim pIWebSiteWeakPtr As IWebSite Ptr = Any

	Scope
		Dim HeaderHost As HeapBSTR = Any
		IClientRequest_GetHttpHeader( _
			self->pIRequest, _
			HttpRequestHeaders.HeaderHost, _
			@HeaderHost _
		)

		Dim HeaderHostLength As Integer = SysStringLen(HeaderHost)
		If HeaderHostLength Then
			Dim hrFindSite As HRESULT = IWebSiteCollection_ItemWeakPtr( _
				self->pIWebSitesWeakPtr, _
				HeaderHost, _
				@pIWebSiteWeakPtr _
			)
			If FAILED(hrFindSite) Then
				IWebSiteCollection_GetDefaultWebSite( _
					self->pIWebSitesWeakPtr, _
					@pIWebSiteWeakPtr _
				)
			End If
		Else
			IWebSiteCollection_GetDefaultWebSite( _
				self->pIWebSitesWeakPtr, _
				@pIWebSiteWeakPtr _
			)
		End If

		HeapSysFreeString(HeaderHost)

	End Scope

	Dim SendBufferLength As LongInt = Any
	Scope
		Dim pIBuffer As IAttributedAsyncStream Ptr = Any
		Dim hrGetBuffer As HRESULT = IWebSite_GetErrorBuffer( _
			pIWebSiteWeakPtr, _
			self->pIMemoryAllocator, _
			self->HttpError, _
			self->hrErrorCode, _
			StatusCode, _
			@pIBuffer _
		)
		If FAILED(hrGetBuffer) Then
			Return hrGetBuffer
		End If

		IHttpAsyncWriter_SetBuffer(self->pIHttpAsyncWriter, pIBuffer)

		Dim Mime As MimeType = Any
		IAttributedAsyncStream_GetContentType(pIBuffer, @Mime)
		IServerResponse_SetMimeType(self->pIResponse, @Mime)

		IAttributedAsyncStream_GetLength(pIBuffer, @SendBufferLength)

		IAttributedAsyncStream_Release(pIBuffer)
	End Scope

	Scope
		' Close Connection when Error occured
		IServerResponse_SetKeepAlive(self->pIResponse, False)
		IHttpAsyncWriter_SetKeepAlive(self->pIHttpAsyncWriter, False)
	End Scope

	Scope
		Dim HttpMethod As HeapBSTR = Any
		IClientRequest_GetHttpMethod(self->pIRequest, @HttpMethod)

		Dim CompareResult As Long = lstrcmpW(HttpMethod, WStr("HEAD"))
		If CompareResult = CompareResultEqual Then
			IServerResponse_SetSendOnlyHeaders(self->pIResponse, True)
		End If

		HeapSysFreeString(HttpMethod)
	End Scope

	Dim hrPrepareResponse As HRESULT = IHttpAsyncWriter_Prepare( _
		self->pIHttpAsyncWriter, _
		self->pIResponse, _
		SendBufferLength, _
		FileAccess.ReadAccess _
	)
	If FAILED(hrPrepareResponse) Then
		Return hrPrepareResponse
	End If

	Return S_OK

End Function

Private Function WriteErrorAsyncTaskSetErrorCode( _
		ByVal self As WriteErrorAsyncTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT

	self->HttpError = HttpError
	self->hrErrorCode = hrCode

	Return S_OK

End Function


Private Function IWriteErrorAsyncTaskQueryInterface( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskQueryInterface(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), riid, ppv)
End Function

Private Function IWriteErrorAsyncTaskAddRef( _
		ByVal self As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskAddRef(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl))
End Function

Private Function IWriteErrorAsyncTaskRelease( _
		ByVal self As IWriteErrorAsyncIoTask Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskRelease(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl))
End Function

Private Function IWriteErrorAsyncTaskBeginExecute( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIResult As IAsyncResult Ptr Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskBeginExecute(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), pcb, StateObject, ppIResult)
End Function

Private Function IWriteErrorAsyncTaskEndExecute( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIResult As IAsyncResult Ptr _
	)As ULONG
	Return WriteErrorAsyncTaskEndExecute(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), pIResult)
End Function

Private Function IWriteErrorAsyncTaskGetBaseStream( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppStream As IBaseAsyncStream Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetBaseStream(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), ppStream)
End Function

Private Function IWriteErrorAsyncTaskSetBaseStream( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		byVal pStream As IBaseAsyncStream Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetBaseStream(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), pStream)
End Function

Private Function IWriteErrorAsyncTaskSetWebSiteCollectionWeakPtr( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		byVal pCollection As IWebSiteCollection Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetWebSiteCollectionWeakPtr(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), pCollection)
End Function

Private Function IWriteErrorAsyncTaskGetClientRequest( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskGetClientRequest(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), ppIRequest)
End Function

Private Function IWriteErrorAsyncTaskSetClientRequest( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskSetClientRequest(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), pIRequest)
End Function

Private Function IWriteErrorAsyncTaskSetErrorCode( _
		ByVal self As IWriteErrorAsyncIoTask Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrCode As HRESULT _
	)As HRESULT
	Return WriteErrorAsyncTaskSetErrorCode(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl), HttpError, hrCode)
End Function

Private Function IWriteErrorAsyncTaskPrepare( _
		ByVal self As IWriteErrorAsyncIoTask Ptr _
	)As HRESULT
	Return WriteErrorAsyncTaskPrepare(CONTAINING_RECORD(self, WriteErrorAsyncTask, lpVtbl))
End Function

Dim GlobalWriteErrorAsyncIoTaskVirtualTable As Const IWriteErrorAsyncIoTaskVirtualTable = Type( _
	@IWriteErrorAsyncTaskQueryInterface, _
	@IWriteErrorAsyncTaskAddRef, _
	@IWriteErrorAsyncTaskRelease, _
	@IWriteErrorAsyncTaskBeginExecute, _
	@IWriteErrorAsyncTaskEndExecute, _
	@IWriteErrorAsyncTaskGetBaseStream, _
	@IWriteErrorAsyncTaskSetBaseStream, _
	@IWriteErrorAsyncTaskSetWebSiteCollectionWeakPtr, _
	@IWriteErrorAsyncTaskGetClientRequest, _
	@IWriteErrorAsyncTaskSetClientRequest, _
	@IWriteErrorAsyncTaskSetErrorCode, _
	@IWriteErrorAsyncTaskPrepare _
)
