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
#include once "Network.bi"
#include once "ThreadPool.bi"
#include once "WebSiteCollection.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "HttpGetProcessor.bi"
#include once "HttpOptionsProcessor.bi"
#include once "HttpPutProcessor.bi"
#include once "HttpTraceProcessor.bi"
#include once "HttpProcessorCollection.bi"

Const DateFormatString = WStr("ddd, dd MMM yyyy ")
Const TimeFormatString = WStr("HH:mm:ss GMT")
Const BasicAuthorization = WStr("Basic")

Const CompareResultEqual As Long = 0

' Declare Function GetBase64Sha1( _
' 	ByVal pDestination As WString Ptr, _
' 	ByVal pSource As WString Ptr _
' )As Boolean

Const HttpProcessorsLength As Integer = 5

Type HttpProcessorItem
	Key As WString Ptr
	Value As IHttpAsyncProcessor Ptr
End Type

Type HttpProcessorVector
	Vector(HttpProcessorsLength - 1) As HttpProcessorItem
End Type

Type WebSiteVector
	Vector(HttpProcessorsLength - 1) As IWebSite Ptr
End Type

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
	
	Dim pIMemoryAllocator As IMalloc Ptr = Any
	Dim WorkerThreads As Integer = Any
	Dim MemoryPoolCapacity As UInteger = Any
	Dim WebSitesLength As Integer = Any
	Dim pWebSites As WebSiteConfiguration Ptr = Any
	Dim HttpProcessors As HttpProcessorVector = Any
	
	Scope
		Dim hrNetworkStartup As HRESULT = NetworkStartUp()
		If FAILED(hrNetworkStartup) Then
			Return hrNetworkStartup
		End If
		
		Dim hrLoadWsa As HRESULT = LoadWsaFunctions()
		If FAILED(hrLoadWsa) Then
			NetworkCleanUp()
			Return hrLoadWsa
		End If
	End Scope
	
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
		Dim cbBytes As SIZE_T_ = MaxWebSites * SizeOf(WebSiteConfiguration)
		pWebSites = IMalloc_Alloc( _
			pIMemoryAllocator, _
			cbBytes _
		)
		If pWebSites = NULL Then
			Return E_OUTOFMEMORY
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
			@WorkerThreads _
		)
		
		IWebServerConfiguration_GetCachedClientMemoryContextCount( _
			pIConfig, _
			@MemoryPoolCapacity _
		)
		
		Dim hrWebSites As HRESULT = IWebServerConfiguration_GetWebSites( _
			pIConfig, _
			@WebSitesLength, _
			pWebSites _
		)
		If FAILED(hrWebSites) Then
			Return hrWebSites
		End If
		
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
		
		IThreadPool_SetMaxThreads(pIPool, WorkerThreads)
		
		Dim hrRunPool As HRESULT = IThreadPool_Run(pIPool)
		If FAILED(hrRunPool) Then
			Return hrRunPool
		End If
	End Scope
	
	Scope
		Dim hrCreateMemoryPool As HRESULT = CreateMemoryPool(MemoryPoolCapacity)
		If FAILED(hrCreateMemoryPool) Then
			Return hrCreateMemoryPool
		End If
	End Scope
	
	/'
	Dim pIProcessorCollection As IHttpProcessorCollection Ptr = Any
	Scope
		Dim hr As HRESULT = CreateHttpProcessorCollection( _
			this->pIMemoryAllocator, _
			@IID_IHttpProcessorCollection, _
			@pIProcessorCollection _
		)
		If FAILED(hr) Then
			*ppIHttpProcessorCollection = NULL
			Return hr
		End If
		
		Const AllMethodsString = "GET, HEAD, OPTIONS, PUT, TRACE"
		Dim AllMethods As HeapBSTR = CreatePermanentHeapStringLen( _
			this->pIMemoryAllocator, _
			WStr(AllMethodsString), _
			Len(AllMethodsString) _
		)
		
		IHttpProcessorCollection_SetAllMethods( _
			pIProcessorCollection, _
			AllMethods _
		)
		
		HeapSysFreeString(AllMethods)
	End Scope
	'/
	Scope
		
		Scope
			Dim pIHttpGetProcessor As IHttpAsyncProcessor Ptr = Any
			Dim hrCreateProcessor As HRESULT = CreateHttpGetProcessor( _
				pIMemoryAllocator, _
				@IID_IHttpGetAsyncProcessor, _
				@pIHttpGetProcessor _
			)
			If FAILED(hrCreateProcessor) Then
				Return hrCreateProcessor
			End If
			
			Const GetKeyString = WStr("GET")
			Const HeadKeyString = WStr("HEAD")
			
			HttpProcessors.Vector(0).Key = @GetKeyString
			HttpProcessors.Vector(0).Value = pIHttpGetProcessor
			
			IHttpAsyncProcessor_AddRef(pIHttpGetProcessor)
			
			HttpProcessors.Vector(1).Key = @HeadKeyString
			HttpProcessors.Vector(1).Value = pIHttpGetProcessor
		End Scope
		
		Scope
			Dim pIHttpPutProcessor As IHttpAsyncProcessor Ptr = Any
			Dim hrCreateProcessor As HRESULT = CreateHttpPutProcessor( _
				pIMemoryAllocator, _
				@IID_IHttpPutAsyncProcessor, _
				@pIHttpPutProcessor _
			)
			If FAILED(hrCreateProcessor) Then
				Return hrCreateProcessor
			End If
			
			Const PutKeyString = WStr("PUT")
			
			HttpProcessors.Vector(2).Key = @PutKeyString
			HttpProcessors.Vector(2).Value = pIHttpPutProcessor
		End Scope
		
		Scope
			Dim pIHttpTraceProcessor As IHttpAsyncProcessor Ptr = Any
			Dim hrCreateProcessor As HRESULT = CreateHttpTraceProcessor( _
				pIMemoryAllocator, _
				@IID_IHttpTraceAsyncProcessor, _
				@pIHttpTraceProcessor _
			)
			If FAILED(hrCreateProcessor) Then
				Return hrCreateProcessor
			End If
			
			Const TraceKeyString = WStr("TRACE")
			
			HttpProcessors.Vector(3).Key = @TraceKeyString
			HttpProcessors.Vector(3).Value = pIHttpTraceProcessor
		End Scope
		
		Scope
			Dim pIHttpOptionsProcessor As IHttpAsyncProcessor Ptr = Any
			Dim hrCreateProcessor As HRESULT = CreateHttpOptionsProcessor( _
				pIMemoryAllocator, _
				@IID_IHttpOptionsAsyncProcessor, _
				@pIHttpOptionsProcessor _
			)
			If FAILED(hrCreateProcessor) Then
				Return hrCreateProcessor
			End If
			
			Const OptionsKeyString = WStr("OPTIONS")
			
			HttpProcessors.Vector(4).Key = @OptionsKeyString
			HttpProcessors.Vector(4).Value = pIHttpOptionsProcessor
		End Scope
	End Scope
	
	Scope
		' создать массив сайтов
		' Dim pIWebSite As IWebSite Ptr = Any
		' Dim hrCreateWebSite As HRESULT = CreateWebSite( _
		' 	pIMemoryAllocator, _
		' 	@IID_IWebSite, _
		' 	@pIWebSite _
		' )
		' If FAILED(hrCreateWebSite) Then
		' 	*ppIWebSite = NULL
		' 	Return hrCreateWebSite
		' End If
		
		' IWebSite_SetHostName(pIWebSite, bstrWebSite)
		' HeapSysFreeString(bstrWebSite)
		
		' IWebSite_SetVirtualPath(pIWebSite, bstrVirtualPath)
		' HeapSysFreeString(bstrVirtualPath)
		
		' IWebSite_SetSitePhysicalDirectory(pIWebSite, bstrPhisycalDir)
		' HeapSysFreeString(bstrPhisycalDir)
		
		' IWebSite_SetMovedUrl(pIWebSite, bstrCanonicalUrl)
		' HeapSysFreeString(bstrCanonicalUrl)
		
		' IWebSite_SetListenAddress(pIWebSite, bstrListenAddress)
		' HeapSysFreeString(bstrListenAddress)
		
		' IWebSite_SetListenPort(pIWebSite, bstrListenPort)
		' HeapSysFreeString(bstrListenPort)
		
		' IWebSite_SetConnectBindAddress(pIWebSite, bstrConnectBindAddress)
		' HeapSysFreeString(bstrConnectBindAddress)
		
		' IWebSite_SetConnectBindPort(pIWebSite, bstrConnectBindPort)
		' HeapSysFreeString(bstrConnectBindPort)
		
		' IWebSite_SetTextFileEncoding(pIWebSite, bstrCharset)
		' HeapSysFreeString(bstrCharset)
		
		' IWebSite_SetIsMoved(pIWebSite, IsMoved)
		' IWebSite_SetUtfBomFileOffset(pIWebSite, Offset)
	End Scope
	
	Scope
		' Назначить каждому сайту своего обработчика
	End Scope
	
	Scope
		' создать массив серверов
	End Scope
	
	Scope
		' назначить каждому серверу свою коллекцию сайтов
	End Scope
	
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
	
	Scope
		For i As Integer = 0 To WebSitesLength - 1
			HeapSysFreeString(pWebSites[i].HostName)
			HeapSysFreeString(pWebSites[i].VirtualPath)
			HeapSysFreeString(pWebSites[i].PhysicalDirectory)
			HeapSysFreeString(pWebSites[i].CanonicalUrl)
			HeapSysFreeString(pWebSites[i].ListenAddress)
			HeapSysFreeString(pWebSites[i].ListenPort)
			HeapSysFreeString(pWebSites[i].ConnectBindAddress)
			HeapSysFreeString(pWebSites[i].ConnectBindPort)
			HeapSysFreeString(pWebSites[i].CodePage)
			HeapSysFreeString(pWebSites[i].Methods)
			HeapSysFreeString(pWebSites[i].DefaultFileName)
		Next
		IMalloc_Free(pIMemoryAllocator, pWebSites)
	End Scope
	
	pIWebSitesWeakPtr = NULL
	pIProcessorsWeakPtr = NULL
	
	Return S_OK
	
End Function

Dim pIWebSitesWeakPtr As IWebSiteCollection Ptr
Dim pIProcessorsWeakPtr As IHttpProcessorCollection Ptr
