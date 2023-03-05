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
#include once "WebSite.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "HttpGetProcessor.bi"
#include once "HttpOptionsProcessor.bi"
#include once "HttpPutProcessor.bi"
#include once "HttpTraceProcessor.bi"
#include once "WebSiteCollection.bi"
#include once "WebServer.bi"

' Declare Function GetBase64Sha1( _
' 	ByVal pDestination As WString Ptr, _
' 	ByVal pSource As WString Ptr _
' )As Boolean

Const CompareResultEqual As Long = 0

Const HttpProcessorsLength As Integer = 5

Type HttpProcessorItem
	Key As HeapBSTR
	Value As IHttpAsyncProcessor Ptr
End Type

Type HttpProcessorVector
	Vector(HttpProcessorsLength - 1) As HttpProcessorItem
End Type

Type WebSiteVector
	Vector(MaxWebSites - 1) As IWebSite Ptr
End Type

Type IpEndPoint
	ListenAddress As HeapBSTR
	ListenPort As HeapBSTR
End Type

Type IpEndPointVector
	Vector(MaxWebSites - 1) As IpEndPoint
End Type

Type WebServerVector
	Vector(MaxWebSites - 1) As IWebServer Ptr
End Type

Sub GetHttpDate( _
		ByVal Buffer As WString Ptr, _
		ByVal dt As SYSTEMTIME Ptr _
	)
	
	Const DateFormatString = WStr("ddd, dd MMM yyyy ")
	Const TimeFormatString = WStr("HH:mm:ss GMT")
	
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

Function IpEndPointExists( _
		ByVal pIpEndPoints As IpEndPointVector Ptr, _
		ByVal IpEndPointsLength As Integer, _
		ByVal ListenAddress As HeapBSTR, _
		ByVal ListenPort As HeapBSTR _
	)As Boolean
	
	For i As Integer = 0 To IpEndPointsLength - 1
		Dim resCompareAddress As Long = lstrcmpW( _
			pIpEndPoints->Vector(i).ListenAddress, _
			ListenAddress _
		)
		If resCompareAddress = CompareResultEqual Then
			Dim resComparePort As Long = lstrcmpW( _
				pIpEndPoints->Vector(i).ListenPort, _
				ListenPort _
			)
			If resComparePort = CompareResultEqual Then
				Return True
			End If
		End If
	Next
	
	Return False
	
End Function

Function IpEndPointCompare( _
		ByVal pWebSiteConfig As WebSiteConfiguration Ptr, _
		ByVal ListenAddress As HeapBSTR, _
		ByVal ListenPort As HeapBSTR _
	)As Boolean
	
	Dim resCompareAddress As Long = lstrcmpW( _
		pWebSiteConfig->ListenAddress, _
		ListenAddress _
	)
	If resCompareAddress = CompareResultEqual Then
		Dim resComparePort As Long = lstrcmpW( _
			pWebSiteConfig->ListenPort, _
			ListenPort _
		)
		If resComparePort = CompareResultEqual Then
			Return True
		End If
	End If
	
	Return False
	
End Function

Function Station922Initialize()As HRESULT
	
	Dim pIMemoryAllocator As IMalloc Ptr = Any
	Dim WorkerThreads As Integer = Any
	Dim MemoryPoolCapacity As UInteger = Any
	Dim WebSites As WebSiteVector = Any
	Dim WebSitesLength As Integer = Any
	Dim pWebSiteConfig As WebSiteConfiguration Ptr = Any
	Dim DefaultWebSiteConfig As WebSiteConfiguration = Any
	Dim HttpProcessors As HttpProcessorVector = Any
	Dim pIDefaultWebSite As IWebSite Ptr = Any
	Dim IpEndPoints As IpEndPointVector = Any
	Dim IpEndPointsLength As Integer = 0
	Dim WebServers As WebServerVector = Any
	
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
		pWebSiteConfig = IMalloc_Alloc( _
			pIMemoryAllocator, _
			cbBytes _
		)
		If pWebSiteConfig = NULL Then
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
			pWebSiteConfig _
		)
		If FAILED(hrWebSites) Then
			Return hrWebSites
		End If
		
		Dim hrDefaultWebSite As HRESULT = IWebServerConfiguration_GetDefaultWebSite( _
			pIConfig, _
			@DefaultWebSiteConfig _
		)
		If FAILED(hrDefaultWebSite) Then
			Return hrDefaultWebSite
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
			Dim bstrGetString As HeapBSTR = CreatePermanentHeapStringLen( _
				pIMemoryAllocator, _
				@GetKeyString, _
				Len(GetKeyString) _
			)
			If bstrGetString = NULL Then
				Return E_OUTOFMEMORY
			End If
			
			HttpProcessors.Vector(0).Key = bstrGetString
			HttpProcessors.Vector(0).Value = pIHttpGetProcessor
			
			IHttpAsyncProcessor_AddRef(pIHttpGetProcessor)
			
			Const HeadKeyString = WStr("HEAD")
			Dim bstrHeadString As HeapBSTR = CreatePermanentHeapStringLen( _
				pIMemoryAllocator, _
				@HeadKeyString, _
				Len(HeadKeyString) _
			)
			If bstrHeadString = NULL Then
				Return E_OUTOFMEMORY
			End If
			HttpProcessors.Vector(1).Key = bstrHeadString
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
			Dim bstrPutString As HeapBSTR = CreatePermanentHeapStringLen( _
				pIMemoryAllocator, _
				@PutKeyString, _
				Len(PutKeyString) _
			)
			If bstrPutString = NULL Then
				Return E_OUTOFMEMORY
			End If
			
			HttpProcessors.Vector(2).Key = bstrPutString
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
			Dim bstrTraceString As HeapBSTR = CreatePermanentHeapStringLen( _
				pIMemoryAllocator, _
				@TraceKeyString, _
				Len(TraceKeyString) _
			)
			If bstrTraceString = NULL Then
				Return E_OUTOFMEMORY
			End If
			
			HttpProcessors.Vector(3).Key = bstrTraceString
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
			Dim bstrOptionsString As HeapBSTR = CreatePermanentHeapStringLen( _
				pIMemoryAllocator, _
				@OptionsKeyString, _
				Len(OptionsKeyString) _
			)
			If bstrOptionsString = NULL Then
				Return E_OUTOFMEMORY
			End If
			
			HttpProcessors.Vector(4).Key = bstrOptionsString
			HttpProcessors.Vector(4).Value = pIHttpOptionsProcessor
		End Scope
	End Scope
	
	Scope
		For i As Integer = 0 To WebSitesLength - 1
			Dim pIWebSite As IWebSite Ptr = Any
			Dim hrCreateWebSite As HRESULT = CreateWebSite( _
				pIMemoryAllocator, _
				@IID_IWebSite, _
				@pIWebSite _
			)
			If FAILED(hrCreateWebSite) Then
				Return hrCreateWebSite
			End If
			
			IWebSite_SetHostName(pIWebSite, pWebSiteConfig[i].HostName)
			IWebSite_SetVirtualPath(pIWebSite, pWebSiteConfig[i].VirtualPath)
			IWebSite_SetSitePhysicalDirectory(pIWebSite, pWebSiteConfig[i].PhysicalDirectory)
			IWebSite_SetMovedUrl(pIWebSite, pWebSiteConfig[i].CanonicalUrl)
			IWebSite_SetListenAddress(pIWebSite, pWebSiteConfig[i].ListenAddress)
			IWebSite_SetListenPort(pIWebSite, pWebSiteConfig[i].ListenPort)
			IWebSite_SetConnectBindAddress(pIWebSite, pWebSiteConfig[i].ConnectBindAddress)
			IWebSite_SetConnectBindPort(pIWebSite, pWebSiteConfig[i].ConnectBindPort)
			IWebSite_SetTextFileEncoding(pIWebSite, pWebSiteConfig[i].CodePage)
			IWebSite_SetSupportedMethods(pIWebSite, pWebSiteConfig[i].Methods)
			IWebSite_SetDefaultFileName(pIWebSite, pWebSiteConfig[i].DefaultFileName)
			IWebSite_SetUtfBomFileOffset(pIWebSite, pWebSiteConfig[i].UtfBomFileOffset)
			IWebSite_SetReservedFileBytes(pIWebSite, pWebSiteConfig[i].ReservedFileBytes)
			IWebSite_SetIsMoved(pIWebSite, pWebSiteConfig[i].IsMoved)
			IWebSite_SetUseSsl(pIWebSite, pWebSiteConfig[i].UseSsl)
			
			WebSites.Vector(i) = pIWebSite
		Next
	End Scope
	
	Scope
		Dim hrCreateWebSite As HRESULT = CreateWebSite( _
			pIMemoryAllocator, _
			@IID_IWebSite, _
			@pIDefaultWebSite _
		)
		If FAILED(hrCreateWebSite) Then
			Return hrCreateWebSite
		End If
		
		IWebSite_SetHostName(pIDefaultWebSite, DefaultWebSiteConfig.HostName)
		IWebSite_SetVirtualPath(pIDefaultWebSite, DefaultWebSiteConfig.VirtualPath)
		IWebSite_SetSitePhysicalDirectory(pIDefaultWebSite, DefaultWebSiteConfig.PhysicalDirectory)
		IWebSite_SetMovedUrl(pIDefaultWebSite, DefaultWebSiteConfig.CanonicalUrl)
		IWebSite_SetListenAddress(pIDefaultWebSite, DefaultWebSiteConfig.ListenAddress)
		IWebSite_SetListenPort(pIDefaultWebSite, DefaultWebSiteConfig.ListenPort)
		IWebSite_SetConnectBindAddress(pIDefaultWebSite, DefaultWebSiteConfig.ConnectBindAddress)
		IWebSite_SetConnectBindPort(pIDefaultWebSite, DefaultWebSiteConfig.ConnectBindPort)
		IWebSite_SetTextFileEncoding(pIDefaultWebSite, DefaultWebSiteConfig.CodePage)
		IWebSite_SetSupportedMethods(pIDefaultWebSite, DefaultWebSiteConfig.Methods)
		IWebSite_SetDefaultFileName(pIDefaultWebSite, DefaultWebSiteConfig.DefaultFileName)
		IWebSite_SetUtfBomFileOffset(pIDefaultWebSite, DefaultWebSiteConfig.UtfBomFileOffset)
		IWebSite_SetReservedFileBytes(pIDefaultWebSite, DefaultWebSiteConfig.ReservedFileBytes)
		IWebSite_SetIsMoved(pIDefaultWebSite, DefaultWebSiteConfig.IsMoved)
		IWebSite_SetUseSsl(pIDefaultWebSite, DefaultWebSiteConfig.UseSsl)
		
		
		' IWebSiteCollection_SetDefaultWebSite(pIWebSiteCollection, pIDefaultWebSite)
		' IWebSite_Release(pIDefaultWebSite)
		
	End Scope
	
	Scope
		For j As Integer = 0 To WebSitesLength - 1
			Dim MethodsLength As Integer = SysStringLen(pWebSiteConfig[j].Methods)
			
			For i As Integer = 0 To HttpProcessorsLength - 1
				Dim KeyLength As Integer = SysStringLen(HttpProcessors.Vector(i).Key)
				
				Dim pFind As WString Ptr = FindStringW( _
					pWebSiteConfig[j].Methods, _
					MethodsLength, _
					HttpProcessors.Vector(i).Key, _
					KeyLength _
				)
				
				If pFind Then
					IWebSite_AddHttpProcessor( _
						WebSites.Vector(j), _
						HttpProcessors.Vector(i).Key, _
						HttpProcessors.Vector(i).Value _
					)
				End If
			Next
		Next
	End Scope
	
	Scope
		For i As Integer = 0 To WebSitesLength - 1
			Dim resExists As Boolean = IpEndPointExists( _
				@IpEndPoints, _
				IpEndPointsLength, _
				pWebSiteConfig[i].ListenAddress, _
				pWebSiteConfig[i].ListenPort _
			)
			
			If resExists = False Then
				IpEndPoints.Vector(IpEndPointsLength).ListenAddress = pWebSiteConfig[i].ListenAddress
				IpEndPoints.Vector(IpEndPointsLength).ListenPort = pWebSiteConfig[i].ListenPort
				IpEndPointsLength += 1
			End If
		Next
		
		For i As Integer = 0 To IpEndPointsLength - 1
			Dim pIWebServer As IWebServer Ptr = Any
			Dim hrCreate As HRESULT = CreateWebServer( _
				pIMemoryAllocator, _
				@IID_IWebServer, _
				@pIWebServer _
			)
			If FAILED(hrCreate) Then
				Return hrCreate
			End If
			
			WebServers.Vector(i) = pIWebServer
		Next
	End Scope
	
	Scope
		For j As Integer = 0 To IpEndPointsLength - 1
			
			For i As Integer = 0 To WebSitesLength - 1
				Dim resCompare As Boolean = IpEndPointCompare( _
					@pWebSiteConfig[i], _
					IpEndPoints.Vector(j).ListenAddress, _
					IpEndPoints.Vector(j).ListenPort _
				)
				
				If resCompare Then
					Dim hrAddWebSite As HRESULT = IWebServer_AddWebSite( _
						WebServers.Vector(j), _
						pWebSiteConfig[i].HostName, _
						WebSites.Vector(i) _
					)
					If FAILED(hrAddWebSite) Then
						Return hrAddWebSite
					End If
				End If
				
			Next
			
			Scope
				Dim hrAddDefaultWebSite As HRESULT = IWebServer_AddDefaultWebSite( _
					WebServers.Vector(j), _
					pIDefaultWebSite _
				)
				If FAILED(hrAddDefaultWebSite) Then
					Return hrAddDefaultWebSite
				End If
				
				Dim hrSetEndPoint As HRESULT = IWebServer_SetEndPoint( _
					WebServers.Vector(j), _
					IpEndPoints.Vector(j).ListenAddress, _
					IpEndPoints.Vector(j).ListenPort _
				)
				If FAILED(hrSetEndPoint) Then
					Return hrSetEndPoint
				End If
			End Scope
		Next
	End Scope
	
	Scope
		For i As Integer = 0 To IpEndPointsLength - 1
			Dim hrStart As HRESULT = IWebServer_Run( _
				WebServers.Vector(i) _
			)
			If FAILED(hrStart) Then
				Return hrStart
			End If
		Next
	End Scope
	
	Scope
		' Cleanup
		For i As Integer = 0 To WebSitesLength - 1
			HeapSysFreeString(pWebSiteConfig[i].HostName)
			HeapSysFreeString(pWebSiteConfig[i].VirtualPath)
			HeapSysFreeString(pWebSiteConfig[i].PhysicalDirectory)
			HeapSysFreeString(pWebSiteConfig[i].CanonicalUrl)
			HeapSysFreeString(pWebSiteConfig[i].ListenAddress)
			HeapSysFreeString(pWebSiteConfig[i].ListenPort)
			HeapSysFreeString(pWebSiteConfig[i].ConnectBindAddress)
			HeapSysFreeString(pWebSiteConfig[i].ConnectBindPort)
			HeapSysFreeString(pWebSiteConfig[i].CodePage)
			HeapSysFreeString(pWebSiteConfig[i].Methods)
			HeapSysFreeString(pWebSiteConfig[i].DefaultFileName)
		Next
		
		IMalloc_Free(pIMemoryAllocator, pWebSiteConfig)
	End Scope
	
	pIWebSitesWeakPtr = NULL
	pIProcessorsWeakPtr = NULL
	
	Return S_OK
	
End Function

Dim pIWebSitesWeakPtr As IWebSiteCollection Ptr
Dim pIProcessorsWeakPtr As IHttpProcessorCollection Ptr
