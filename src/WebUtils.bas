#include once "WebUtils.bi"
#include once "win\shlwapi.bi"
#include once "win\wincrypt.bi"
#include once "CharacterConstants.bi"
#include once "HeapBSTR.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpProcessorCollection.bi"
#include once "IniConfiguration.bi"
#include once "Mime.bi"
#include once "Network.bi"
#include once "ThreadPool.bi"
#include once "WebSite.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "HttpDeleteProcessor.bi"
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

Const HttpProcessorsLength As Integer = 6

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

Dim Shared GlobalThreadPool As IThreadPool Ptr
Dim Shared WebServers As WebServerVector
Dim Shared IpEndPointsLength As Integer

Public Function ConvertSystemDateToHttpDate( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal dt As SYSTEMTIME Ptr _
	)As HeapBSTR

	' Tue, 15 Nov 1994 12:45:26 GMT

	Const DateFormatString = WStr("ddd, dd MMM yyyy ")
	Const TimeFormatString = WStr("HH:mm:ss GMT")
	Const DateBufferCapacity As Integer = 31

	Dim Buffer As WString * (DateBufferCapacity + 1) = Any

	Dim resDateLength As Long = GetDateFormatW( _
		LOCALE_INVARIANT, _
		0, _
		dt, _
		@DateFormatString, _
		Buffer, _
		DateBufferCapacity _
	)
	If resDateLength = 0 Then
		Return NULL
	End If

	Dim DateLength As Integer = CInt(resDateLength - 1)
	Dim FreeSpaceLength As Integer = DateBufferCapacity - DateLength

	Dim resTimeLength As Long = GetTimeFormatW( _
		LOCALE_INVARIANT, _
		0, _
		dt, _
		@TimeFormatString, _
		@Buffer[DateLength], _
		FreeSpaceLength _
	)
	If resTimeLength = 0 Then
		Return NULL
	End If

	Dim TimeLength As Integer = CInt(resTimeLength - 1)

	Dim DateTimeLength As Integer = DateLength + TimeLength

	Dim bstrHttpDate As HeapBSTR = CreateHeapStringLen( _
		pIMemoryAllocator, _
		@Buffer, _
		DateTimeLength _
	)

	Return bstrHttpDate

End Function

Public Function FindWebSiteWeakPtr( _
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

Private Function IpEndPointExists( _
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

Private Function IpEndPointCompare( _
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

Public Function Station922Initialize()As HRESULT

	Dim pIMemoryAllocator As IMalloc Ptr = Any
	Dim WorkerThreads As Integer = Any
	Dim MemoryPoolCapacity As UInteger = Any
	Dim KeepAliveInterval As ULongInt = Any
	Dim WebSites As WebSiteVector = Any
	Dim WebSitesLength As Integer = Any
	Dim pWebSiteConfig As WebSiteConfiguration Ptr = Any
	Dim DefaultWebSiteConfig As WebSiteConfiguration = Any
	Dim HttpProcessors As HttpProcessorVector = Any
	Dim pIDefaultWebSite As IWebSite Ptr = Any

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

		IWebServerConfiguration_GetMemoryPoolCapacity( _
			pIConfig, _
			@MemoryPoolCapacity _
		)

		IWebServerConfiguration_GetKeepAliveInterval( _
			pIConfig, _
			@KeepAliveInterval _
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
		Dim hrCreateMemoryPool As HRESULT = CreateMemoryPool( _
			MemoryPoolCapacity, _
			KeepAliveInterval _
		)
		If FAILED(hrCreateMemoryPool) Then
			Return hrCreateMemoryPool
		End If
	End Scope

	Scope
		Dim hrCreateThreadPool As HRESULT = CreateThreadPool( _
			pIMemoryAllocator, _
			@IID_IThreadPool, _
			@GlobalThreadPool _
		)
		If FAILED(hrCreateThreadPool) Then
			Return hrCreateThreadPool
		End If

		IThreadPool_SetMaxThreads(GlobalThreadPool, WorkerThreads)

		Dim hrRunPool As HRESULT = IThreadPool_Run(GlobalThreadPool)
		If FAILED(hrRunPool) Then
			Return hrRunPool
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

		Scope
			Dim pIHttpDeleteProcessor As IHttpAsyncProcessor Ptr = Any
			Dim hrCreateProcessor As HRESULT = CreateHttpDeleteProcessor( _
				pIMemoryAllocator, _
				@IID_IHttpDeleteAsyncProcessor, _
				@pIHttpDeleteProcessor _
			)
			If FAILED(hrCreateProcessor) Then
				Return hrCreateProcessor
			End If

			Const DeleteKeyString = WStr("DELETE")
			Dim bstrDeleteString As HeapBSTR = CreatePermanentHeapStringLen( _
				pIMemoryAllocator, _
				@DeleteKeyString, _
				Len(DeleteKeyString) _
			)
			If bstrDeleteString = NULL Then
				Return E_OUTOFMEMORY
			End If

			HttpProcessors.Vector(5).Key = bstrDeleteString
			HttpProcessors.Vector(5).Value = pIHttpDeleteProcessor
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
			IWebSite_SetAllMethods(pIWebSite, pWebSiteConfig[i].Methods)
			IWebSite_SetDefaultFileName(pIWebSite, pWebSiteConfig[i].DefaultFileName)
			IWebSite_SetUserName(pIWebSite, pWebSiteConfig[i].UserName)
			IWebSite_SetPassword(pIWebSite, pWebSiteConfig[i].Password)
			IWebSite_SetUtfBomFileOffset(pIWebSite, pWebSiteConfig[i].UtfBomFileOffset)
			IWebSite_SetReservedFileBytes(pIWebSite, pWebSiteConfig[i].ReservedFileBytes)
			IWebSite_SetIsMoved(pIWebSite, pWebSiteConfig[i].IsMoved)
			IWebSite_SetUseSsl(pIWebSite, pWebSiteConfig[i].UseSsl)
			IWebSite_SetDirectoryListing(pIWebSite, pWebSiteConfig[i].EnableDirectoryListing)
			IWebSite_SetGetAllFiles(pIWebSite, pWebSiteConfig[i].EnableGetAllFiles)

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
		IWebSite_SetAllMethods(pIDefaultWebSite, DefaultWebSiteConfig.Methods)
		IWebSite_SetDefaultFileName(pIDefaultWebSite, DefaultWebSiteConfig.DefaultFileName)
		IWebSite_SetUserName(pIDefaultWebSite, DefaultWebSiteConfig.UserName)
		IWebSite_SetPassword(pIDefaultWebSite, DefaultWebSiteConfig.Password)
		IWebSite_SetUtfBomFileOffset(pIDefaultWebSite, DefaultWebSiteConfig.UtfBomFileOffset)
		IWebSite_SetReservedFileBytes(pIDefaultWebSite, DefaultWebSiteConfig.ReservedFileBytes)
		IWebSite_SetIsMoved(pIDefaultWebSite, DefaultWebSiteConfig.IsMoved)
		IWebSite_SetUseSsl(pIDefaultWebSite, DefaultWebSiteConfig.UseSsl)
		IWebSite_SetDirectoryListing(pIDefaultWebSite, DefaultWebSiteConfig.EnableDirectoryListing)
		IWebSite_SetGetAllFiles(pIDefaultWebSite, DefaultWebSiteConfig.EnableGetAllFiles)
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
		Dim IpEndPoints As IpEndPointVector = Any

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
						pWebSiteConfig[i].ListenPort, _
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

	Return S_OK

End Function

Public Sub Station922CleanUp()

	For i As Integer = 0 To IpEndPointsLength - 1
		IWebServer_Stop(WebServers.Vector(i))
		IWebServer_Release(WebServers.Vector(i))
	Next

	IThreadPool_Stop(GlobalThreadPool)

	IThreadPool_Release(GlobalThreadPool)

	DeleteMemoryPool()

End Sub

Public Function GetThreadPoolWeakPtr()As IThreadPool Ptr

	Return GlobalThreadPool

End Function

Public Function WaitAlertableLoop( _
		ByVal hEvent As HANDLE _
	)As HRESULT

	Do
		Dim resWait As DWORD = WaitForSingleObjectEx( _
			hEvent, _
			INFINITE, _
			TRUE _
		)

		Select Case resWait

			Case WAIT_OBJECT_0
				' The event became a signal
				' exit from loop
				Return S_OK

			Case WAIT_IO_COMPLETION
				' The asynchronous procedure has ended
				' we continue to wait
				Continue Do

			Case Else ' WAIT_ABANDONED, WAIT_TIMEOUT, WAIT_FAILED
				Return E_FAIL

		End Select
	Loop

End Function
