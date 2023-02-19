#include once "WebUtils.bi"
#include once "win\shlwapi.bi"
#include once "win\wincrypt.bi"
#include once "CharacterConstants.bi"
#include once "HeapBSTR.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpProcessorCollection.bi"
#include once "IniConfiguration.bi"
#include once "Logger.bi"
#include once "Mime.bi"
#include once "ThreadPool.bi"
#include once "WebSiteCollection.bi"
#include once "WriteErrorAsyncTask.bi"

Const DateFormatString = WStr("ddd, dd MMM yyyy ")
Const TimeFormatString = WStr("HH:mm:ss GMT")
Const DefaultCacheControl = WStr("max-age=2678400")
Const BasicAuthorization = WStr("Basic")

Const CompareResultEqual As Long = 0

Type WebServerConfig
	WorkerThreads As Integer
	MemoryPoolCapacity As UInteger
	WebSites(MaxWebSites - 1) As IWebSite Ptr
	' ProcessorCollection As IHttpProcessorCollection Ptr
End Type

' Declare Function GetBase64Sha1( _
' 	ByVal pDestination As WString Ptr, _
' 	ByVal pSource As WString Ptr _
' )As Boolean

Sub GetHttpDate( _
		ByVal Buffer As WString Ptr, _
		ByVal dt As SYSTEMTIME Ptr _
	)
	
	' Tue, 15 Nov 1994 12:45:26 GMT
	Dim dtBufferLength As Integer = GetDateFormatW( _
		LOCALE_INVARIANT, _
		0, _
		dt, _
		@DateFormatString, _
		Buffer, _
		31 _
	) - 1
	
	GetTimeFormatW( _
		LOCALE_INVARIANT, _
		0, _
		dt, _
		@TimeFormatString, _
		@Buffer[dtBufferLength], _
		31 - dtBufferLength _
	)
	
End Sub

Sub AddResponseCacheHeaders( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pDateLastFileModified As FILETIME Ptr, _
		ByVal ETag As HeapBSTR _
	)
	
	Dim IsFileModified As Boolean = True
	
	Scope
		' TODO пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅ HTTP-пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ
		Dim dFileLastModified As SYSTEMTIME = Any
		FileTimeToSystemTime(pDateLastFileModified, @dFileLastModified)
		
		Dim strFileLastModifiedHttpDate As WString * 256 = Any
		GetHttpDate(@strFileLastModifiedHttpDate, @dFileLastModified)
		
		IServerResponse_AddKnownResponseHeaderWstr( _
			pIResponse, _
			HttpResponseHeaders.HeaderLastModified, _
			@strFileLastModifiedHttpDate _
		)
		
		Dim pHeaderIfModifiedSince As HeapBSTR = Any
		IClientRequest_GetHttpHeader( _
			pIRequest, _
			HttpRequestHeaders.HeaderIfModifiedSince, _
			@pHeaderIfModifiedSince _
		)
		
		If SysStringLen(pHeaderIfModifiedSince) Then
			
			Dim resCompare As Long = lstrcmpiW( _
				@strFileLastModifiedHttpDate, _
				pHeaderIfModifiedSince _
			)
			If resCompare = CompareResultEqual Then
				IsFileModified = False
			End If
		End If
		
		HeapSysFreeString(pHeaderIfModifiedSince)
		
		Dim pHeaderIfUnModifiedSince As HeapBSTR = Any
		IClientRequest_GetHttpHeader( _
			pIRequest, _
			HttpRequestHeaders.HeaderIfUnModifiedSince, _
			@pHeaderIfUnModifiedSince _
		)
		
		If SysStringLen(pHeaderIfUnModifiedSince) Then
			
			Dim resCompare As Long = lstrcmpiW( _
				@strFileLastModifiedHttpDate, _
				pHeaderIfUnModifiedSince _
			)
			If resCompare = CompareResultEqual Then
				IsFileModified = True
			End If
		End If
		
		HeapSysFreeString(pHeaderIfUnModifiedSince)
	End Scope
	
	Scope
		IServerResponse_AddKnownResponseHeader( _
			pIResponse, _
			HttpResponseHeaders.HeaderETag, _
			ETag _
		)
		
		If IsFileModified Then
			
			Dim HeaderIfNoneMatch As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderIfNoneMatch, _
				@HeaderIfNoneMatch _
			)
			
			If SysStringLen(HeaderIfNoneMatch) Then
				Dim CompareResult As Long = lstrcmpiW(HeaderIfNoneMatch, ETag)
				If CompareResult = CompareResultEqual Then
					IsFileModified = False
				End If
			End If
			
			HeapSysFreeString(HeaderIfNoneMatch)
		End If
		
		If IsFileModified = False Then
			
			Dim HeaderIfMatch As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderIfMatch, _
				@HeaderIfMatch _
			)
			
			If SysStringLen(HeaderIfMatch) Then
				Dim CompareResult As Long = lstrcmpiW(HeaderIfMatch, ETag)
				If CompareResult = CompareResultEqual Then
					IsFileModified = True
				End If
			End If
			
			HeapSysFreeString(HeaderIfMatch)
		End If
		
	End Scope
	
	IServerResponse_AddKnownResponseHeaderWstrLen( _
		pIResponse, _
		HttpResponseHeaders.HeaderCacheControl, _
		@DefaultCacheControl, _
		Len(DefaultCacheControl) _
	)
	
	Dim SendOnlyHeaders As Boolean = Any
	IServerResponse_GetSendOnlyHeaders(pIResponse, @SendOnlyHeaders)
	
	SendOnlyHeaders = SendOnlyHeaders OrElse (Not IsFileModified)
	
	IServerResponse_SetSendOnlyHeaders(pIResponse, SendOnlyHeaders)
	
	If IsFileModified = False Then
		IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotModified)
	End If
	
End Sub

Function FindWebSiteWeakPtr( _
		ByVal pIWebSites As IWebSiteCollection Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal ppIWebSiteWeakPtr As IWebSite Ptr Ptr _
	)As HRESULT
	
	/'
	If HttpMethod = HttpMethods.HttpConnect Then
		IWebSiteCollection_Item( _
			pIWebSites, _
			NULL, _
			ppIWebSiteWeakPtr _
		)
		Return S_OK
	End If
	'/
	
	Dim HeaderHost As HeapBSTR = Any
	IClientRequest_GetHttpHeader( _
		pIRequest, _
		HttpRequestHeaders.HeaderHost, _
		@HeaderHost _
	)
	
	Dim hrFindSite As HRESULT = IWebSiteCollection_ItemWeakPtr( _
		pIWebSites, _
		HeaderHost, _
		ppIWebSiteWeakPtr _
	)
	
	HeapSysFreeString(HeaderHost)
	
	Return hrFindSite
	
End Function

Function StartExecuteTask( _
		ByVal pTask As IAsyncIoTask Ptr _
	)As HRESULT
	
	Dim pIResult As IAsyncResult Ptr = Any
	Dim hrBeginExecute As HRESULT = IAsyncIoTask_BeginExecute( _
		pTask, _
		@pIResult _
	)
	If FAILED(hrBeginExecute) Then
		Dim vtSCode As VARIANT = Any
		vtSCode.vt = VT_ERROR
		vtSCode.scode = hrBeginExecute
		LogWriteEntry( _
			LogEntryType.Error, _
			WStr(!"IAsyncTask_BeginExecute Error\t"), _
			@vtSCode _
		)
		
		Return hrBeginExecute
	End If
	
	Return S_OK
	
End Function

Function ProcessErrorRequestResponse( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIStream As IBaseStream Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal hrErrorCode As HRESULT, _
		ByVal ppTask As IWriteErrorAsyncIoTask Ptr Ptr _
	)As HRESULT
	
	Dim pTask As IWriteErrorAsyncIoTask Ptr = Any
	Dim hrCreateTask As HRESULT = CreateWriteErrorAsyncTask( _
		pIMemoryAllocator, _
		@IID_IWriteErrorAsyncIoTask, _
		@pTask _
	)
	If FAILED(hrCreateTask) Then
		*ppTask = NULL
		Return hrCreateTask
	End If
	
	IWriteErrorAsyncIoTask_SetBaseStream(pTask, pIStream)
	IWriteErrorAsyncIoTask_SetHttpReader(pTask, pIHttpReader)
	
	IWriteErrorAsyncIoTask_SetClientRequest(pTask, pIRequest)
	
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
	If FAILED(hrPrepare) Then
		IWriteErrorAsyncIoTask_Release(pTask)
		*ppTask = NULL
		Return hrPrepare
	End If
	
	*ppTask = pTask
	
	Return S_OK
	
End Function

Function BindToThreadPool( _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT
	
	Dim NewPort As HANDLE = CreateIoCompletionPort( _
		hHandle, _
		ThreadPoolCompletionPort, _
		Cast(ULONG_PTR, pUserData), _
		0 _
	)
	If NewPort = NULL Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

Function Station922Initialize( _
	)As HRESULT
	
	Dim Config As WebServerConfig = Any
	Dim pIMemoryAllocator As IMalloc Ptr = Any
	
	Scope
		Const dwReserved As DWORD = 1
		Dim hrGetMalloc As HRESULT = CoGetMalloc( _
			dwReserved, _
			@pIMemoryAllocator _
		)
		If FAILED(hrGetMalloc) Then
			Return hrGetMalloc
		End If
	End Scope
	
	Scope
		Dim pIConfig As IWebServerConfiguration Ptr = Any
		Dim hrCreateConfiguration As HRESULT = CreateWebServerIniConfiguration( _
			pIMemoryAllocator, _
			@IID_IIniConfiguration, _
			@pIConfig _
		)
		If FAILED(hrCreateConfiguration) Then
			Return hrCreateConfiguration
		End If
		
		IWebServerConfiguration_GetWorkerThreadsCount( _
			pIConfig, _
			@Config.WorkerThreads _
		)
		
		IWebServerConfiguration_GetCachedClientMemoryContextCount( _
			pIConfig, _
			@Config.MemoryPoolCapacity _
		)
		
		Dim WebSites As Integer = Any
		Dim hrWebSites As HRESULT = IWebServerConfiguration_GetWebSites( _
			pIConfig, _
			@WebSites, _
			@Config.WebSites(0) _
		)
		If FAILED(hrWebSites) Then
			Return hrWebSites
		End If
		
		/'
		Scope
			Dim pIDefaultWebSite As IWebSite Ptr = Any
			Dim hr2 As HRESULT = CreateWebSite( _
				this->pIMemoryAllocator, _
				@IID_IWebSite, _
				@pIDefaultWebSite _
			)
			If FAILED(hr2) Then
				IWebSiteCollection_Release(pIWebSiteCollection)
				*ppIWebSiteCollection = NULL
				Return hr2
			End If
			
			Scope
				Dim ExeFileName As WString * (MAX_PATH + 1) = Any
				GetModuleFileNameW( _
					0, _
					@ExeFileName, _
					MAX_PATH _
				)
				
				Dim ExecutableDirectory As WString * (MAX_PATH + 1) = Any
				lstrcpyW(@ExecutableDirectory, @ExeFileName)
				PathRemoveFileSpecW(@ExecutableDirectory)
				
				Dim bstrPhisycalDir As HeapBSTR = CreatePermanentHeapString( _
					this->pIMemoryAllocator, _
					@ExecutableDirectory _
				)
				IWebSite_SetSitePhysicalDirectory(pIDefaultWebSite, bstrPhisycalDir)
				HeapSysFreeString(bstrPhisycalDir)
			End Scope
			
			Scope
				Const DefaultVirtualPath = WStr("/")
				Dim pVirtualPath As WString Ptr = @DefaultVirtualPath
				
				Dim bstrVirtualPath As HeapBSTR = CreatePermanentHeapStringLen( _
					this->pIMemoryAllocator, _
					pVirtualPath, _
					Len(DefaultVirtualPath) _
				)
				IWebSite_SetVirtualPath(pIDefaultWebSite, bstrVirtualPath)
				HeapSysFreeString(bstrVirtualPath)
			End Scope
			
			' Scope
			' 	Dim MovedUrl As WString * (MAX_PATH + 1) = Any
			' 	Dim ValueLength As DWORD = GetPrivateProfileStringW( _
			' 		lpwszHost, _
			' 		@MovedUrlKeyString, _
			' 		@EmptyString, _
			' 		@MovedUrl, _
			' 		Cast(DWORD, MAX_PATH), _
			' 		this->pWebSitesIniFileName _
			' 	)
			' 	If ValueLength = 0 Then
			' 		Dim dwError As DWORD = GetLastError()
			' 		IWebSite_Release(pIWebSite)
			' 		IWebSiteCollection_Release(pIWebSiteCollection)
			' 		*ppIWebSiteCollection = NULL
			' 		Return HRESULT_FROM_WIN32(dwError)
			' 	End If
				
			' 	Dim bstrMovedUrl As HeapBSTR = CreatePermanentHeapStringLen( _
			' 		this->pIMemoryAllocator, _
			' 		@MovedUrl, _
			' 		ValueLength _
			' 	)
			' 	IWebSite_SetMovedUrl(pIDefaultWebSite, bstrMovedUrl)
			' 	HeapSysFreeString(bstrMovedUrl)
			' End Scope
			
			Scope
				IWebSite_SetIsMoved(pIDefaultWebSite, False)
			End Scope
			
			IWebSiteCollection_SetDefaultWebSite(pIWebSiteCollection, pIDefaultWebSite)
			IWebSite_Release(pIDefaultWebSite)
			
		End Scope
		'/
		
		/'
		Dim hrProcessors As HRESULT = IWebServerConfiguration_GetHttpProcessorCollection( _
			pIConfig, _
			@pWebServerConfig->ProcessorCollection _
		)
		If FAILED(hrProcessors) Then
			ZeroMemory(pWebServerConfig, SizeOf(WebServerConfig))
			Return hrProcessors
		End If
		'/
		IWebServerConfiguration_Release(pIConfig)
	End Scope
	
	Scope
		Dim pIPool As IThreadPool Ptr = Any
		Dim hrCreateThreadPool As HRESULT = CreateThreadPool( _
			pIMemoryAllocator, _
			@IID_IThreadPool, _
			@pIPool _
		)
		If FAILED(hrCreateThreadPool) Then
			Return hrCreateThreadPool
		End If
		
		IThreadPool_SetMaxThreads(pIPool, Config.WorkerThreads)
		
		Dim hrPool As HRESULT = IThreadPool_Run(pIPool)
		If FAILED(hrPool) Then
			Return hrPool
		End If
	End Scope
	
	Scope
		Dim hrCreateMemoryPool As HRESULT = CreateMemoryPool(Config.MemoryPoolCapacity)
		If FAILED(hrCreateMemoryPool) Then
			Return hrCreateMemoryPool
		End If
	End Scope
	
	Scope
		' создать массив серверов и запустить
	End Scope
	
	pIWebSitesWeakPtr = NULL
	pIProcessorsWeakPtr = NULL
	
	Return S_OK
	
End Function

Dim pIWebSitesWeakPtr As IWebSiteCollection Ptr
Dim pIProcessorsWeakPtr As IHttpProcessorCollection Ptr
