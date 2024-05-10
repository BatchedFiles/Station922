#include once "WebServer.bi"
#include once "AcceptConnectionAsyncTask.bi"
#include once "ClientRequest.bi"
#include once "HeapBSTR.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpAsyncReader.bi"
#include once "Logger.bi"
#include once "Network.bi"
#include once "NetworkAsyncStream.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "WebSiteCollection.bi"
#include once "WebUtils.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "WriteResponseAsyncTask.bi"

Extern GlobalWebServerVirtualTable As Const IWebServerVirtualTable

Const SocketListCapacity As Integer = 10

Type WebServer
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IWebServerVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pIWebSites As IWebSiteCollection Ptr
	SocketList(0 To SocketListCapacity - 1) As SocketNode
	SocketListLength As Integer
	ListenAddress As HeapBSTR
	ListenPort As HeapBSTR
End Type

Type AcceptConnectionContext
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	pWebServer As WebServer Ptr
	pIMalloc As IMalloc Ptr
	pTask As IAcceptConnectionAsyncIoTask Ptr
End Type

Type ReadRequestContext
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	pWebServer As WebServer Ptr
	pIMalloc As IMalloc Ptr
	pTask As IReadRequestAsyncIoTask Ptr
End Type

Type WriteResponseContext
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	pWebServer As WebServer Ptr
	pIMalloc As IMalloc Ptr
	pTask As IWriteResponseAsyncIoTask Ptr
End Type

Type WriteErrorContext
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	pWebServer As WebServer Ptr
	pIMalloc As IMalloc Ptr
	pTask As IWriteErrorAsyncIoTask Ptr
End Type

Declare Sub ReadRequestCallback( _
	ByVal pIResult As IAsyncResult Ptr _
)

Private Function CreateAcceptConnectionContext( _
		ByVal this As WebServer Ptr _
	)As AcceptConnectionContext Ptr

	Dim pIMalloc As IMalloc Ptr = Any
	Dim hrGetMalloc As HRESULT = CoGetMalloc(1, @pIMalloc)

	If SUCCEEDED(hrGetMalloc) Then
		Dim pState As AcceptConnectionContext Ptr = IMalloc_Alloc( _
			pIMalloc, _
			SizeOf(AcceptConnectionContext) _
		)

		If pState Then

			Dim pTask As IAcceptConnectionAsyncIoTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateAcceptConnectionAsyncTask( _
				this->pIMemoryAllocator, _
				@IID_IAcceptConnectionAsyncIoTask, _
				@pTask _
			)

			If SUCCEEDED(hrCreateTask) Then

				#if __FB_DEBUG__
					CopyMemory( _
						@pState->RttiClassName(0), _
						@Str(!"\001Accept_Context\001"), _
						UBound(pState->RttiClassName) - LBound(pState->RttiClassName) + 1 _
					)
				#endif

				pState->pWebServer = this
				pState->pIMalloc = pIMalloc
				pState->pTask = pTask

				Return pState
			End If

			IMalloc_Free(pIMalloc, pState)
		End If

		IMalloc_Release(pIMalloc)
	End If

	Return NULL

End Function

Private Sub DestroyAcceptConnectionContext( _
		ByVal pAcceptContext As AcceptConnectionContext Ptr _
	)

	var localMalloc = pAcceptContext->pIMalloc
	var localTask = pAcceptContext->pTask

	IMalloc_Free(localMalloc, pAcceptContext)

	IAcceptConnectionAsyncIoTask_Release(localTask)
	IMalloc_Release(localMalloc)

End Sub

Private Function CreateReadRequestContextFromWriteContext( _
		ByVal pWriteContext As WriteResponseContext Ptr _
	)As ReadRequestContext Ptr

	Dim pReadContext As ReadRequestContext Ptr = IMalloc_Alloc( _
		pWriteContext->pIMalloc, _
		SizeOf(ReadRequestContext) _
	)

	If pReadContext Then

		Dim pTask As IReadRequestAsyncIoTask Ptr = Any
		Dim hrCreateTask As HRESULT = CreateReadRequestAsyncTask( _
			pWriteContext->pIMalloc, _
			@IID_IReadRequestAsyncIoTask, _
			@pTask _
		)

		If SUCCEEDED(hrCreateTask) Then

			#if __FB_DEBUG__
				CopyMemory( _
					@pReadContext->RttiClassName(0), _
					@Str(!"\001Read___Context\001"), _
					UBound(pReadContext->RttiClassName) - LBound(pReadContext->RttiClassName) + 1 _
				)
			#endif

			pReadContext->pWebServer = pWriteContext->pWebServer
			IMalloc_AddRef(pWriteContext->pIMalloc)
			pReadContext->pIMalloc = pWriteContext->pIMalloc
			pReadContext->pTask = pTask

			Dim pIHttpAsyncReader As IHttpAsyncReader Ptr = Any
			IWriteResponseAsyncIoTask_GetHttpReader( _
				pWriteContext->pTask, _
				@pIHttpAsyncReader _
			)

			Dim pStream As IBaseAsyncStream Ptr = Any
			IWriteResponseAsyncIoTask_GetBaseStream( _
				pWriteContext->pTask, _
				@pStream _
			)

			IReadRequestAsyncIoTask_SetBaseStream(pReadContext->pTask, pStream)
			IReadRequestAsyncIoTask_SetHttpReader(pReadContext->pTask, pIHttpAsyncReader)

			IBaseAsyncStream_Release(pStream)
			IHttpAsyncReader_Release(pIHttpAsyncReader)

			Return pReadContext
		End If

		IMalloc_Free(pWriteContext->pIMalloc, pReadContext)
	End If

	Return NULL

End Function

Private Function CreateReadRequestContextFromSocket( _
		ByVal this As WebServer Ptr, _
		ByVal ClientSocket As SOCKET _
	)As ReadRequestContext Ptr

	Dim pIMalloc As IMalloc Ptr = GetHeapMemoryAllocatorInstance(ClientSocket)

	If pIMalloc Then
		Dim pState As ReadRequestContext Ptr = IMalloc_Alloc( _
			pIMalloc, _
			SizeOf(ReadRequestContext) _
		)

		If pState Then
			Dim pTask As IReadRequestAsyncIoTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateReadRequestAsyncTask( _
				pIMalloc, _
				@IID_IReadRequestAsyncIoTask, _
				@pTask _
			)

			If SUCCEEDED(hrCreateTask) Then
				Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
				Dim hrBind As HRESULT = IThreadPool_AssociateDevice( _
					pIPool, _
					Cast(HANDLE, ClientSocket), _
					Cast(Any Ptr, ClientSocket) _
				)

				If SUCCEEDED(hrBind) Then
					Dim pIHttpAsyncReader As IHttpAsyncReader Ptr = Any
					Dim hrCreateHttpReader As HRESULT = CreateHttpReader( _
						pIMalloc, _
						@IID_IHttpAsyncReader, _
						@pIHttpAsyncReader _
					)

					If SUCCEEDED(hrCreateHttpReader) Then

						Dim pINetworkAsyncStream As INetworkAsyncStream Ptr = Any
						Dim hrCreateNetworkStream As HRESULT = CreateNetworkStream( _
							pIMalloc, _
							@IID_INetworkAsyncStream, _
							@pINetworkAsyncStream _
						)

						If SUCCEEDED(hrCreateNetworkStream) Then

							#if __FB_DEBUG__
								CopyMemory( _
									@pState->RttiClassName(0), _
									@Str(!"\001Read___Context\001"), _
									UBound(pState->RttiClassName) - LBound(pState->RttiClassName) + 1 _
								)
							#endif

							pState->pWebServer = this
							pState->pIMalloc = pIMalloc
							pState->pTask = pTask

							INetworkAsyncStream_SetSocket( _
								pINetworkAsyncStream, _
								ClientSocket _
							)

							' TODO Запросить интерфейс вместо конвертирования указателя
							IHttpAsyncReader_SetBaseStream( _
								pIHttpAsyncReader, _
								CPtr(IBaseAsyncStream Ptr, pINetworkAsyncStream) _
							)

							IReadRequestAsyncIoTask_SetBaseStream(pTask, CPtr(IBaseAsyncStream Ptr, pINetworkAsyncStream))
							IReadRequestAsyncIoTask_SetHttpReader(pTask, pIHttpAsyncReader)

							INetworkAsyncStream_Release(pINetworkAsyncStream)
							IHttpAsyncReader_Release(pIHttpAsyncReader)

							Return pState
						End If

						IHttpAsyncReader_Release(pIHttpAsyncReader)
					End If

				End If

				IReadRequestAsyncIoTask_Release(pTask)
			End If

			IMalloc_Free(pIMalloc, pState)
		End If

		IMalloc_Release(pIMalloc)
	End If

	Return NULL

End Function

Private Sub DestroyReadRequestContext( _
		ByVal pReadContext As ReadRequestContext Ptr _
	)

	var localMalloc = pReadContext->pIMalloc
	var localTask = pReadContext->pTask

	IMalloc_Free(localMalloc, pReadContext)

	IReadRequestAsyncIoTask_Release(localTask)
	IMalloc_Release(localMalloc)

End Sub

Private Function CreateWriteResponseContext( _
		ByVal this As WebServer Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal pStream As IBaseAsyncStream Ptr, _
		ByVal pIHttpAsyncReader As IHttpAsyncReader Ptr, _
		ByVal pRequest As IClientRequest Ptr _
	)As WriteResponseContext Ptr

	Dim pContext As WriteResponseContext Ptr = IMalloc_Alloc( _
		pIMalloc, _
		SizeOf(WriteResponseContext) _
	)

	If pContext Then
		Dim pTask As IWriteResponseAsyncIoTask Ptr = Any
		Dim hrCreateTask As HRESULT = CreateWriteResponseAsyncTask( _
			pIMalloc, _
			@IID_IWriteResponseAsyncIoTask, _
			@pTask _
		)

		If SUCCEEDED(hrCreateTask) Then
			#if __FB_DEBUG__
				CopyMemory( _
					@pContext->RttiClassName(0), _
					@Str(!"\001Write__Context\001"), _
					UBound(pContext->RttiClassName) - LBound(pContext->RttiClassName) + 1 _
				)
			#endif

			IHttpAsyncReader_Clear(pIHttpAsyncReader)
			IWriteResponseAsyncIoTask_SetBaseStream(pTask, pStream)
			IWriteResponseAsyncIoTask_SetHttpReader(pTask, pIHttpAsyncReader)
			IWriteResponseAsyncIoTask_SetClientRequest(pTask, pRequest)

			pContext->pWebServer = this
			IMalloc_AddRef(pIMalloc)
			pContext->pIMalloc = pIMalloc
			pContext->pTask = pTask

			Return pContext
		End If

		IMalloc_Free(pIMalloc, pContext)
	End If

	Return NULL

End Function

Private Sub DestroyWriteResponseContext( _
		ByVal pWriteContext As WriteResponseContext Ptr _
	)

	var localMalloc = pWriteContext->pIMalloc
	var localTask = pWriteContext->pTask

	IMalloc_Free(localMalloc, pWriteContext)

	IWriteResponseAsyncIoTask_Release(localTask)
	IMalloc_Release(localMalloc)

End Sub

Private Function CreateWriteErrorContext( _
		ByVal this As WebServer Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal pStream As IBaseAsyncStream Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal hrErrorCode As HRESULT _
	)As WriteErrorContext Ptr

	Dim pContext As WriteErrorContext Ptr = IMalloc_Alloc( _
		pIMalloc, _
		SizeOf(WriteErrorContext) _
	)

	If pContext Then

		Dim localRequest As IClientRequest Ptr = Any
		Dim hrCreateRequest As HRESULT = Any
		If pIRequest Then
			localRequest = pIRequest
			hrCreateRequest = S_OK
		Else
			hrCreateRequest = CreateClientRequest( _
				pIMalloc, _
				@IID_IClientRequest, _
				@localRequest _
			)
		End If

		If SUCCEEDED(hrCreateRequest) Then

			Dim pTask As IWriteErrorAsyncIoTask Ptr = Any
			Dim hrCreateTask As HRESULT = CreateWriteErrorAsyncTask( _
				pIMalloc, _
				@IID_IWriteErrorAsyncIoTask, _
				@pTask _
			)

			If SUCCEEDED(hrCreateTask) Then

				IWriteErrorAsyncIoTask_SetBaseStream(pTask, pStream)
				IWriteErrorAsyncIoTask_SetWebSiteCollectionWeakPtr(pTask, this->pIWebSites)

				IWriteErrorAsyncIoTask_SetClientRequest(pTask, localRequest)

				Dim HttpError As ResponseErrorCode = Any

				Select Case hrErrorCode

					Case HTTPREADER_E_INTERNALBUFFEROVERFLOW, HTTPREADER_E_INSUFFICIENT_BUFFER
						HttpError = ResponseErrorCode.RequestHeaderFieldsTooLarge

					Case CLIENTURI_E_CONTAINSBADCHAR, CLIENTURI_E_PATHNOTFOUND
						HttpError = ResponseErrorCode.BadRequest

					Case HTTPREADER_E_SOCKETERROR
						HttpError = ResponseErrorCode.BadRequest

					Case HTTPREADER_E_CLIENTCLOSEDCONNECTION
						HttpError = ResponseErrorCode.BadRequest

					Case CLIENTREQUEST_E_BADHOST
						HttpError = ResponseErrorCode.HostNotFound

					Case CLIENTREQUEST_E_BADREQUEST
						HttpError = ResponseErrorCode.BadRequest

					Case CLIENTREQUEST_E_BADPATH, CLIENTURI_E_PATHNOTFOUND
						HttpError = ResponseErrorCode.PathNotValid

					Case CLIENTURI_E_URITOOLARGE, CLIENTREQUEST_E_URITOOLARGE
						HttpError = ResponseErrorCode.RequestUrlTooLarge

					Case CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
						HttpError = ResponseErrorCode.VersionNotSupported

					Case CLIENTREQUEST_E_CONTENTTYPEEMPTY
						HttpError = ResponseErrorCode.ContentTypeEmpty

					Case WEBSITE_E_SITENOTFOUND
						HttpError = ResponseErrorCode.SiteNotFound

					Case WEBSITE_E_REDIRECTED
						HttpError = ResponseErrorCode.MovedPermanently

					Case WEBSITE_E_FILENOTFOUND
						HttpError = ResponseErrorCode.FileNotFound

					Case WEBSITE_E_FILEGONE
						HttpError = ResponseErrorCode.FileGone

					Case WEBSITE_E_FORBIDDEN
						HttpError = ResponseErrorCode.Forbidden

					Case WEBSITE_E_NEEDAUTHENTICATE
						HttpError = ResponseErrorCode.NeedAuthenticate

					Case WEBSITE_E_BADAUTHENTICATEPARAM
						HttpError = ResponseErrorCode.BadAuthenticateParam

					Case WEBSITE_E_NEEDBASICAUTHENTICATE
						HttpError = ResponseErrorCode.NeedBasicAuthenticate

					Case WEBSITE_E_EMPTYPASSWORD
						HttpError = ResponseErrorCode.EmptyPassword

					Case WEBSITE_E_BADUSERNAMEPASSWORD
						HttpError = ResponseErrorCode.BadUserNamePassword

					Case HTTPPROCESSOR_E_NOTIMPLEMENTED
						HttpError = ResponseErrorCode.NotImplemented

					Case HTTPPROCESSOR_E_RANGENOTSATISFIABLE
						HttpError = ResponseErrorCode.RequestRangeNotSatisfiable

					Case HTTPPROCESSOR_E_LENGTHREQUIRED
						HttpError = ResponseErrorCode.LengthRequired

					Case E_OUTOFMEMORY
						HttpError = ResponseErrorCode.NotEnoughMemory

					Case Else
						HttpError = ResponseErrorCode.InternalServerError

				End Select

				IWriteErrorAsyncIoTask_SetErrorCode(pTask, HttpError, hrErrorCode)

				Dim hrPrepare As HRESULT = IWriteErrorAsyncIoTask_Prepare(pTask)

				If SUCCEEDED(hrPrepare) Then

					#if __FB_DEBUG__
						CopyMemory( _
							@pContext->RttiClassName(0), _
							@Str(!"\001Error__Context\001"), _
							UBound(pContext->RttiClassName) - LBound(pContext->RttiClassName) + 1 _
						)
					#endif

					pContext->pWebServer = this
					IMalloc_AddRef(pIMalloc)
					pContext->pIMalloc = pIMalloc
					pContext->pTask = pTask

					If pIRequest = NULL Then
						IClientRequest_Release(localRequest)
					End If

					Return pContext
				End If

				IWriteErrorAsyncIoTask_Release(pTask)
			End If

			If pIRequest = NULL Then
				IClientRequest_Release(localRequest)
			End If
		End If

		IMalloc_Free(pIMalloc, pContext)
	End If

	Return NULL

End Function

Private Sub DestroyWriteErrorContext( _
		ByVal pErrorContext As WriteErrorContext Ptr _
	)

	var localMalloc = pErrorContext->pIMalloc
	var localTask = pErrorContext->pTask

	IMalloc_Free(localMalloc, pErrorContext)

	IWriteErrorAsyncIoTask_Release(localTask)
	IMalloc_Release(localMalloc)

End Sub

Private Sub WriteErrorCallback( _
		ByVal pIResult As IAsyncResult Ptr _
	)

	Dim pErrorContext As WriteErrorContext Ptr = Any
	IAsyncResult_GetAsyncStateWeakPtr(pIResult, @pErrorContext)

	Dim hrEndExecute As HRESULT = Any
	Scope
		hrEndExecute = IWriteErrorAsyncIoTask_EndExecute( _
			pErrorContext->pTask, _
			pIResult _
		)

		IAsyncResult_Release(pIResult)

		If FAILED(hrEndExecute) Then
			DestroyWriteErrorContext(pErrorContext)

			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_ERROR
			vtErrorCode.scode = hrEndExecute

			LogWriteEntry( _
				LogEntryType.Error, _
				@WStr("WriteErrorTask.EndExecute Error"), _
				@vtErrorCode _
			)

			Exit Sub
		End If
	End Scope

	Select Case hrEndExecute

		Case S_OK
			DestroyWriteErrorContext(pErrorContext)

		Case WRITEERRORASYNCIOTASK_S_IO_PENDING
			' Restart task
			Dim pNewResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IWriteErrorAsyncIoTask_BeginExecute( _
				pErrorContext->pTask, _
				@WriteErrorCallback, _
				pErrorContext, _
				@pNewResult _
			)
			If FAILED(hrBeginExecute) Then
				DestroyWriteErrorContext(pErrorContext)

				Dim vtErrorCode As VARIANT = Any
				vtErrorCode.vt = VT_ERROR
				vtErrorCode.scode = hrBeginExecute

				LogWriteEntry( _
					LogEntryType.Error, _
					@WStr("WriteErrorTask.BeginExecute Error"), _
					@vtErrorCode _
				)
			End If

			' Do not release pTask and pIResult

	End Select

End Sub

Private Sub WriteResponseCallback( _
		ByVal pIResult As IAsyncResult Ptr _
	)

	Dim pWriteContext As WriteResponseContext Ptr = Any
	IAsyncResult_GetAsyncStateWeakPtr(pIResult, @pWriteContext)

	Dim hrEndExecute As HRESULT = Any
	Scope
		hrEndExecute = IWriteResponseAsyncIoTask_EndExecute( _
			pWriteContext->pTask, _
			pIResult _
		)

		IAsyncResult_Release(pIResult)

		If FAILED(hrEndExecute) Then
			DestroyWriteResponseContext(pWriteContext)

			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_ERROR
			vtErrorCode.scode = hrEndExecute

			LogWriteEntry( _
				LogEntryType.Error, _
				@WStr("WriteResponseTask.EndExecute Error"), _
				@vtErrorCode _
			)

			Exit Sub
		End If
	End Scope

	Select Case hrEndExecute

		Case S_OK
			' Create ReadTask
			Dim pReadContext As ReadRequestContext Ptr = CreateReadRequestContextFromWriteContext( _
				pWriteContext _
			)

			DestroyWriteResponseContext(pWriteContext)

			If pReadContext = NULL Then
				' TODO Write 503 Service Unavailable
				Dim vtErrorCode As VARIANT = Any
				vtErrorCode.vt = VT_ERROR
				vtErrorCode.scode = E_OUTOFMEMORY

				LogWriteEntry( _
					LogEntryType.Error, _
					@WStr("Out Of Memory CreateReadRequestContext"), _
					@vtErrorCode _
				)

				Exit Sub
			End If

			Dim pNewResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IReadRequestAsyncIoTask_BeginExecute( _
				pReadContext->pTask, _
				@ReadRequestCallback, _
				pReadContext, _
				@pNewResult _
			)
			If FAILED(hrBeginExecute) Then
				DestroyReadRequestContext(pReadContext)

				Dim vtErrorCode As VARIANT = Any
				vtErrorCode.vt = VT_ERROR
				vtErrorCode.scode = hrBeginExecute

				LogWriteEntry( _
					LogEntryType.Error, _
					@WStr("ReadRequestTask.BeginExecute Error"), _
					@vtErrorCode _
				)
			End If

			' Do not release pTask and pIResult

		Case S_FALSE
			' Read 0 bytes, reached the end of the stream, close the connection
			DestroyWriteResponseContext(pWriteContext)

		Case WRITERESPONSEASYNCIOTASK_S_IO_PENDING
			' Restart task
			Dim pNewResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IWriteResponseAsyncIoTask_BeginExecute( _
				pWriteContext->pTask, _
				@WriteResponseCallback, _
				pWriteContext, _
				@pNewResult _
			)
			If FAILED(hrBeginExecute) Then
				DestroyWriteResponseContext(pWriteContext)

				Dim vtErrorCode As VARIANT = Any
				vtErrorCode.vt = VT_ERROR
				vtErrorCode.scode = hrBeginExecute

				LogWriteEntry( _
					LogEntryType.Error, _
					@WStr("WriteResponseTask.BeginExecute Error"), _
					@vtErrorCode _
				)
			End If

			' Do not release pTask and pIResult

	End Select

End Sub

Private Sub ReadRequestCallback( _
		ByVal pIResult As IAsyncResult Ptr _
	)

	Dim pReadContext As ReadRequestContext Ptr = Any
	IAsyncResult_GetAsyncStateWeakPtr(pIResult, @pReadContext)

	Dim hrEndExecute As HRESULT = Any
	Scope
		hrEndExecute = IReadRequestAsyncIoTask_EndExecute( _
			pReadContext->pTask, _
			pIResult _
		)

		IAsyncResult_Release(pIResult)

		If FAILED(hrEndExecute) Then
			DestroyReadRequestContext(pReadContext)

			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_ERROR
			vtErrorCode.scode = hrEndExecute

			LogWriteEntry( _
				LogEntryType.Error, _
				@WStr("ReadRequestTask.EndExecute Error"), _
				@vtErrorCode _
			)

			Exit Sub
		End If
	End Scope

	Select Case hrEndExecute

		Case S_OK
			' Get HttpReader
			Dim pIHttpAsyncReader As IHttpAsyncReader Ptr = Any
			IReadRequestAsyncIoTask_GetHttpReader( _
				pReadContext->pTask, _
				@pIHttpAsyncReader _
			)

			' Get Basestream
			Dim pStream As IBaseAsyncStream Ptr = Any
			IReadRequestAsyncIoTask_GetBaseStream( _
				pReadContext->pTask, _
				@pStream _
			)

			Dim pRequest As IClientRequest Ptr = Any
			Dim hrParse As HRESULT = IReadRequestAsyncIoTask_Parse( _
				pReadContext->pTask, _
				@pRequest _
			)
			If FAILED(hrParse) Then
				Dim pErrorContext As WriteErrorContext Ptr = CreateWriteErrorContext( _
					pReadContext->pWebServer, _
					pReadContext->pIMalloc, _
					pStream, _
					NULL, _
					hrParse _
				)

				IBaseAsyncStream_Release(pStream)
				IHttpAsyncReader_Release(pIHttpAsyncReader)
				DestroyReadRequestContext(pReadContext)

				If pErrorContext = NULL Then
					Exit Sub
				End If

				Dim pNewResult As IAsyncResult Ptr = Any
				Dim hrBeginWriteError As HRESULT = IWriteErrorAsyncIoTask_BeginExecute( _
					pErrorContext->pTask, _
					@WriteErrorCallback, _
					pErrorContext, _
					@pNewResult _
				)
				If FAILED(hrBeginWriteError) Then
					DestroyWriteErrorContext(pErrorContext)
					Exit Sub
				End If

				' Do not release pTask and pIResult

				Exit Sub
			End If

			' Create WriteResponseTask
			Dim pWriteContext As WriteResponseContext Ptr = CreateWriteResponseContext( _
				pReadContext->pWebServer, _
				pReadContext->pIMalloc, _
				pStream, _
				pIHttpAsyncReader, _
				pRequest _
			)

			If pWriteContext = NULL Then

				Dim pErrorContext As WriteErrorContext Ptr = CreateWriteErrorContext( _
					pReadContext->pWebServer, _
					pReadContext->pIMalloc, _
					pStream, _
					pRequest, _
					E_OUTOFMEMORY _
				)

				IClientRequest_Release(pRequest)
				IBaseAsyncStream_Release(pStream)
				IHttpAsyncReader_Release(pIHttpAsyncReader)
				DestroyReadRequestContext(pReadContext)

				If pErrorContext = NULL Then
					Exit Sub
				End If

				Dim pNewResult As IAsyncResult Ptr = Any
				Dim hrBeginWriteError As HRESULT = IWriteErrorAsyncIoTask_BeginExecute( _
					pErrorContext->pTask, _
					@WriteErrorCallback, _
					pErrorContext, _
					@pNewResult _
				)
				If FAILED(hrBeginWriteError) Then
					DestroyWriteErrorContext(pErrorContext)
					Exit Sub
				End If

				' Do not release pTask and pIResult

				Exit Sub
			End If

			' Prepare response
			Scope
				Dim hrPrepareResponse As HRESULT = IWriteResponseAsyncIoTask_Prepare( _
					pWriteContext->pTask, _
					pWriteContext->pWebServer->pIWebSites _
				)
				If FAILED(hrPrepareResponse) Then
					Dim pErrorContext As WriteErrorContext Ptr = CreateWriteErrorContext( _
						pReadContext->pWebServer, _
						pReadContext->pIMalloc, _
						pStream, _
						pRequest, _
						hrPrepareResponse _
					)

					DestroyWriteResponseContext(pWriteContext)
					IClientRequest_Release(pRequest)
					IBaseAsyncStream_Release(pStream)
					IHttpAsyncReader_Release(pIHttpAsyncReader)
					DestroyReadRequestContext(pReadContext)

					If pErrorContext = NULL Then
						Exit Sub
					End If

					Dim pNewResult As IAsyncResult Ptr = Any
					Dim hrBeginWriteError As HRESULT = IWriteErrorAsyncIoTask_BeginExecute( _
						pErrorContext->pTask, _
						@WriteErrorCallback, _
						pErrorContext, _
						@pNewResult _
					)
					If FAILED(hrBeginWriteError) Then
						DestroyWriteErrorContext(pErrorContext)
						Exit Sub
					End If

					' Do not release pTask and pIResult

					Exit Sub
				End If

			End Scope

			' Cleanup
			IClientRequest_Release(pRequest)
			IBaseAsyncStream_Release(pStream)
			IHttpAsyncReader_Release(pIHttpAsyncReader)
			DestroyReadRequestContext(pReadContext)

			' Write response
			Scope
				Dim pNewResult As IAsyncResult Ptr = Any
				Dim hrBeginExecute As HRESULT = IWriteResponseAsyncIoTask_BeginExecute( _
					pWriteContext->pTask, _
					@WriteResponseCallback, _
					pWriteContext, _
					@pNewResult _
				)
				If FAILED(hrBeginExecute) Then
					DestroyWriteResponseContext(pWriteContext)

					Dim vtErrorCode As VARIANT = Any
					vtErrorCode.vt = VT_ERROR
					vtErrorCode.scode = hrEndExecute

					LogWriteEntry( _
						LogEntryType.Error, _
						@WStr("WriteResponseTask.BeginExecute Error"), _
						@vtErrorCode _
					)

					Exit Sub
				End If

				' Do not release pTask and pIResult

			End Scope

		Case S_FALSE
			' Read 0 bytes, reached the end of the stream, close the connection
			DestroyReadRequestContext(pReadContext)

		Case READREQUESTASYNCIOTASK_S_IO_PENDING
			' Restart task
			Dim pNewResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IReadRequestAsyncIoTask_BeginExecute( _
				pReadContext->pTask, _
				@ReadRequestCallback, _
				pReadContext, _
				@pNewResult _
			)
			If FAILED(hrBeginExecute) Then
				DestroyReadRequestContext(pReadContext)

				Dim vtErrorCode As VARIANT = Any
				vtErrorCode.vt = VT_ERROR
				vtErrorCode.scode = hrBeginExecute

				LogWriteEntry( _
					LogEntryType.Error, _
					@WStr("ReadRequestTask.BeginExecute Error"), _
					@vtErrorCode _
				)
			End If

			' Do not release pTask and pIResult

	End Select

End Sub

Private Sub AcceptConnectionCallback( _
		ByVal pIResult As IAsyncResult Ptr _
	)

	Dim pAcceptContext As AcceptConnectionContext Ptr = Any
	IAsyncResult_GetAsyncStateWeakPtr(pIResult, @pAcceptContext)

	Scope
		Dim hrEndExecute As HRESULT = IAcceptConnectionAsyncIoTask_EndExecute( _
			pAcceptContext->pTask, _
			pIResult _
		)

		IAsyncResult_Release(pIResult)

		If FAILED(hrEndExecute) Then
			DestroyAcceptConnectionContext(pAcceptContext)

			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_ERROR
			vtErrorCode.scode = hrEndExecute

			LogWriteEntry( _
				LogEntryType.Error, _
				@WStr("AcceptConnectionTask.EndExecute Error"), _
				@vtErrorCode _
			)

			' TODO Restart task
			Exit Sub
		End If
	End Scope

	Scope
		Dim ClientSocket As SOCKET = Any
		IAcceptConnectionAsyncIoTask_GetClientSocket( _
			pAcceptContext->pTask, _
			@ClientSocket _
		)

		Dim pReadContext As ReadRequestContext Ptr = CreateReadRequestContextFromSocket( _
			pAcceptContext->pWebServer, _
			ClientSocket _
		)

		If pReadContext Then

			Dim pNewResult As IAsyncResult Ptr = Any
			Dim hrBeginExecute As HRESULT = IReadRequestAsyncIoTask_BeginExecute( _
				pReadContext->pTask, _
				@ReadRequestCallback, _
				pReadContext, _
				@pNewResult _
			)
			If FAILED(hrBeginExecute) Then
				DestroyReadRequestContext(pReadContext)

				Dim vtErrorCode As VARIANT = Any
				vtErrorCode.vt = VT_ERROR
				vtErrorCode.scode = hrBeginExecute

				LogWriteEntry( _
					LogEntryType.Error, _
					@WStr("ReadRequestTask.BeginExecute Error"), _
					@vtErrorCode _
				)
			End If

			' Do not release pTask and pIResult

		Else
			' TODO Write 503 Service Unavailable
			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_ERROR
			vtErrorCode.scode = E_OUTOFMEMORY

			LogWriteEntry( _
				LogEntryType.Error, _
				@WStr("Out Of Memory CreateReadRequestContext"), _
				@vtErrorCode _
			)
		End If
	End Scope

	Scope
		Dim pNewResult As IAsyncResult Ptr = Any
		Dim hrBeginExecute As HRESULT = IAcceptConnectionAsyncIoTask_BeginExecute( _
			pAcceptContext->pTask, _
			@AcceptConnectionCallback, _
			pAcceptContext, _
			@pNewResult _
		)
		If FAILED(hrBeginExecute) Then
			DestroyAcceptConnectionContext(pAcceptContext)

			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_ERROR
			vtErrorCode.scode = hrBeginExecute

			LogWriteEntry( _
				LogEntryType.Error, _
				@WStr("AcceptConnectionTask.BeginExecute Error"), _
				@vtErrorCode _
			)

			' TODO Restart task

			Exit Sub
		End If

		' Do not release pTask and pIResult

	End Scope
End Sub

Private Function CreateServerSocketSink( _
		ByVal this As WebServer Ptr _
	)As HRESULT

	Dim hrCreateSocket As HRESULT = CreateSocketAndListenW( _
		this->ListenAddress, _
		this->ListenPort, _
		@this->SocketList(0), _
		SocketListCapacity, _
		@this->SocketListLength _
	)

	Scope
		Dim vtAddressMessage As VARIANT = Any
		vtAddressMessage.vt = VT_BSTR
		vtAddressMessage.bstrVal = this->ListenAddress
		LogWriteEntry( _
			LogEntryType.Information, _
			WStr(!"Listen address"), _
			@vtAddressMessage _
		)

		Dim vtPortMessage As VARIANT = Any
		vtPortMessage.vt = VT_BSTR
		vtPortMessage.bstrVal = this->ListenPort
		LogWriteEntry( _
			LogEntryType.Information, _
			WStr(!"Listen port"), _
			@vtPortMessage _
		)
	End Scope

	HeapSysFreeString(this->ListenAddress)
	this->ListenAddress = NULL

	HeapSysFreeString(this->ListenPort)
	this->ListenPort = NULL

	If FAILED(hrCreateSocket) Then
		Dim vtErrorMessage As VARIANT = Any
		vtErrorMessage.vt = VT_ERROR
		vtErrorMessage.scode = hrCreateSocket
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"Can not open and listend socket, error code"), _
			@vtErrorMessage _
		)
		Return hrCreateSocket
	End If

	Return S_OK

End Function

Private Sub InitializeWebServer( _
		ByVal this As WebServer Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)

	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_WEBSERVER), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalWebServerVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	' Do not need AddRef pIWebSites
	this->pIWebSites = pIWebSites
	this->ListenAddress = NULL
	this->ListenPort = NULL

End Sub

Private Sub UnInitializeWebServer( _
		ByVal this As WebServer Ptr _
	)

	HeapSysFreeString(this->ListenAddress)
	HeapSysFreeString(this->ListenPort)

	If this->pIWebSites Then
		IWebSiteCollection_Release(this->pIWebSites)
	End If

End Sub

Private Sub WebServerCreated( _
		ByVal this As WebServer Ptr _
	)

End Sub

Private Sub WebServerDestroyed( _
		ByVal this As WebServer Ptr _
	)

End Sub

Private Sub DestroyWebServer( _
		ByVal this As WebServer Ptr _
	)

	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator

	UnInitializeWebServer(this)

	IMalloc_Free(pIMemoryAllocator, this)

	WebServerDestroyed(this)

	IMalloc_Release(pIMemoryAllocator)

End Sub

Private Function WebServerAddRef( _
		ByVal this As WebServer Ptr _
	)As ULONG

	this->ReferenceCounter += 1

	Return 1

End Function

Private Function WebServerRelease( _
		ByVal this As WebServer Ptr _
	)As ULONG

	this->ReferenceCounter -= 1

	If this->ReferenceCounter Then
		Return 1
	End If

	DestroyWebServer(this)

	Return 0

End Function

Private Function WebServerQueryInterface( _
		ByVal this As WebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	If IsEqualIID(@IID_IWebServer, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If

	WebServerAddRef(this)

	Return S_OK

End Function

Public Function CreateWebServer( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT

	Dim this As WebServer Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebServer) _
	)

	If this Then
		Dim pIWebSites As IWebSiteCollection Ptr = Any
		Dim hrCreateCollection As HRESULT = CreateWebSiteCollection( _
			pIMemoryAllocator, _
			@IID_IWebSiteCollection, _
			@pIWebSites _
		)

		If SUCCEEDED(hrCreateCollection) Then

			InitializeWebServer( _
				this, _
				pIMemoryAllocator, _
				pIWebSites _
			)

			WebServerCreated(this)

			Dim hrQueryInterface As HRESULT = WebServerQueryInterface( _
				this, _
				riid, _
				ppv _
			)
			If FAILED(hrQueryInterface) Then
				DestroyWebServer(this)
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

Private Function WebServerAddWebSite( _
		ByVal this As WebServer Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT

	Dim hrAdd As HRESULT = IWebSiteCollection_Add( _
		this->pIWebSites, _
		pKey, _
		Port, _
		pIWebSite _
	)
	If FAILED(hrAdd) Then
		Return hrAdd
	End If

	Return S_OK

End Function

Private Function WebServerAddDefaultWebSite( _
		ByVal this As WebServer Ptr, _
		ByVal pIDefaultWebSite As IWebSite Ptr _
	)As HRESULT

	Dim hrAdd As HRESULT = IWebSiteCollection_SetDefaultWebSite( _
		this->pIWebSites, _
		pIDefaultWebSite _
	)
	If FAILED(hrAdd) Then
		Return hrAdd
	End If

	Return S_OK

End Function

Private Function WebServerSetEndPoint( _
		ByVal this As WebServer Ptr, _
		ByVal ListenAddress As HeapBSTR, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT

	LET_HEAPSYSSTRING(this->ListenAddress, ListenAddress)
	LET_HEAPSYSSTRING(this->ListenPort, ListenPort)

	Return S_OK

End Function

Private Function WebServerRun( _
		ByVal this As WebServer Ptr _
	)As HRESULT

	Dim hrSocket As HRESULT = CreateServerSocketSink(this)
	If FAILED(hrSocket) Then
		Return hrSocket
	End If

	For i As Integer = 0 To this->SocketListLength - 1

		Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
		Dim hrBind As HRESULT = IThreadPool_AssociateDevice( _
			pIPool, _
			Cast(HANDLE, this->SocketList(i).ClientSocket), _
			Cast(Any Ptr, this->SocketList(i).ClientSocket) _
		)
		If FAILED(hrBind) Then
			Return E_OUTOFMEMORY
		End If

		Dim pState As AcceptConnectionContext Ptr = CreateAcceptConnectionContext(this)

		If pState = NULL Then
			Return E_OUTOFMEMORY
		End If

		IAcceptConnectionAsyncIoTask_SetListenSocket( _
			pState->pTask, _
			this->SocketList(i).ClientSocket _
		)

		Dim pIResult As IAsyncResult Ptr = Any
		Dim hrBeginExecute As HRESULT = IAcceptConnectionAsyncIoTask_BeginExecute( _
			pState->pTask, _
			@AcceptConnectionCallback, _
			pState, _
			@pIResult _
		)
		If FAILED(hrBeginExecute) Then
			IAcceptConnectionAsyncIoTask_Release(pState->pTask)
			Dim pIMalloc As IMalloc Ptr = pState->pIMalloc
			IMalloc_Free(pIMalloc, pState)
			IMalloc_Release(pIMalloc)

			Dim vtErrorCode As VARIANT = Any
			vtErrorCode.vt = VT_ERROR
			vtErrorCode.scode = hrBeginExecute

			LogWriteEntry( _
				LogEntryType.Error, _
				@WStr("AcceptConnectionTask.BeginExecute Error"), _
				@vtErrorCode _
			)

			Return hrBeginExecute
		End If

		' Do not release pTask and pIResult

	Next

	Dim vtSucceededMessage As VARIANT = Any
	vtSucceededMessage.vt = VT_EMPTY
	LogWriteEntry( _
		LogEntryType.Information, _
		WStr(!"WebServer create succeeded\r\n"), _
		@vtSucceededMessage _
	)

	Return S_OK

End Function

Private Function WebServerStop( _
		ByVal this As WebServer Ptr _
	)As HRESULT

	For i As Integer = 0 To this->SocketListLength - 1
		closesocket(this->SocketList(i).ClientSocket)
	Next

	Return S_OK

End Function


Private Function IWebServerQueryInterface( _
		ByVal this As IWebServer Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	Return WebServerQueryInterface(CONTAINING_RECORD(this, WebServer, lpVtbl), riid, ppv)
End Function

Private Function IWebServerAddRef( _
		ByVal this As IWebServer Ptr _
	)As ULONG
	Return WebServerAddRef(CONTAINING_RECORD(this, WebServer, lpVtbl))
End Function

Private Function IWebServerRelease( _
		ByVal this As IWebServer Ptr _
	)As ULONG
	Return WebServerRelease(CONTAINING_RECORD(this, WebServer, lpVtbl))
End Function

Private Function IWebServerAddWebSite( _
		ByVal this As IWebServer Ptr, _
		ByVal pKey As HeapBSTR, _
		ByVal Port As HeapBSTR, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	Return WebServerAddWebSite(CONTAINING_RECORD(this, WebServer, lpVtbl), pKey, Port, pIWebSite)
End Function

Private Function IWebServerAddDefaultWebSite( _
		ByVal this As IWebServer Ptr, _
		ByVal pIDefaultWebSite As IWebSite Ptr _
	)As HRESULT
	Return WebServerAddDefaultWebSite(CONTAINING_RECORD(this, WebServer, lpVtbl), pIDefaultWebSite)
End Function

Private Function IWebServerSetEndPoint( _
		ByVal this As IWebServer Ptr, _
		ByVal ListenAddress As HeapBSTR, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT
	Return WebServerSetEndPoint(CONTAINING_RECORD(this, WebServer, lpVtbl), ListenAddress, ListenPort)
End Function

Private Function IWebServerRun( _
		ByVal this As IWebServer Ptr _
	)As HRESULT
	Return WebServerRun(CONTAINING_RECORD(this, WebServer, lpVtbl))
End Function

Private Function IWebServerStop( _
		ByVal this As IWebServer Ptr _
	)As HRESULT
	Return WebServerStop(CONTAINING_RECORD(this, WebServer, lpVtbl))
End Function

Dim GlobalWebServerVirtualTable As Const IWebServerVirtualTable = Type( _
	@IWebServerQueryInterface, _
	@IWebServerAddRef, _
	@IWebServerRelease, _
	@IWebServerAddWebSite, _
	@IWebServerAddDefaultWebSite, _
	@IWebServerSetEndPoint, _
	@IWebServerRun, _
	@IWebServerStop _
)
