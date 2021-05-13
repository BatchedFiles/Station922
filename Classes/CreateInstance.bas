#include once "CreateInstance.bi"
#include once "ArrayStringWriter.bi"
#include once "AsyncResult.bi"
#include once "ClientContext.bi"
#include once "ClientRequest.bi"
#include once "ConsoleLogger.bi"
#include once "HttpGetProcessor.bi"
#include once "HttpReader.bi"
#include once "NetworkStream.bi"
#include once "HeapMemoryAllocator.bi"
#include once "RequestedFile.bi"
#include once "ServerResponse.bi"
#include once "WebServer.bi"
#include once "WebServerIniConfiguration.bi"
#include once "WebSite.bi"
#include once "WebSiteCollection.bi"

Function CreateInstance( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal rclsid As REFCLSID, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
	If IsEqualCLSID(@CLSID_WEBSITE, rclsid) Then
		Dim pWebSite As WebSite Ptr = CreateWebSite(pILogger, pIMemoryAllocator)
		If pWebSite = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebSiteQueryInterface(pWebSite, riid, ppv)
		If FAILED(hr) Then
			DestroyWebSite(pWebSite)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_HTTPREADER, rclsid) Then
		Dim pReader As HttpReader Ptr = CreateHttpReader(pILogger, pIMemoryAllocator)
		If pReader = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HttpReaderQueryInterface(pReader, riid, ppv)
		If FAILED(hr) Then
			DestroyHttpReader(pReader)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_SERVERRESPONSE, rclsid) Then
		Dim pResponse As ServerResponse Ptr = CreateServerResponse(pILogger, pIMemoryAllocator)
		If pResponse = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ServerResponseQueryInterface(pResponse, riid, ppv)
		If FAILED(hr) Then
			DestroyServerResponse(pResponse)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_CLIENTREQUEST, rclsid) Then
		Dim pRequest As ClientRequest Ptr = CreateClientRequest(pILogger, pIMemoryAllocator)
		If pRequest = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ClientRequestQueryInterface(pRequest, riid, ppv)
		If FAILED(hr) Then
			DestroyClientRequest(pRequest)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_NETWORKSTREAM, rclsid) Then
		Dim pStream As NetworkStream Ptr = CreateNetworkStream(pILogger, pIMemoryAllocator)
		If pStream = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = NetworkStreamQueryInterface(pStream, riid, ppv)
		If FAILED(hr) Then
			DestroyNetworkStream(pStream)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_CLIENTCONTEXT, rclsid) Then
		Dim pContext As ClientContext Ptr = CreateClientContext(pILogger, pIMemoryAllocator)
		If pContext = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ClientContextQueryInterface(pContext, riid, ppv)
		If FAILED(hr) Then
			DestroyClientContext(pContext)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WEBSITECOLLECTION, rclsid) Then
		Dim pWebSites As WebSiteCollection Ptr = CreateWebSiteCollection(pILogger, pIMemoryAllocator)
		If pWebSites = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebSiteCollectionQueryInterface(pWebSites, riid, ppv)
		If FAILED(hr) Then
			DestroyWebSiteCollection(pWebSites)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_REQUESTEDFILE, rclsid) Then
		Dim pRequestedFile As RequestedFile Ptr = CreateRequestedFile(pILogger, pIMemoryAllocator)
		If pRequestedFile = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = RequestedFileQueryInterface(pRequestedFile, riid, ppv)
		If FAILED(hr) Then
			DestroyRequestedFile(pRequestedFile)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WEBSERVER, rclsid) Then
		Dim pWebServer As WebServer Ptr = CreateWebServer(pILogger, pIMemoryAllocator)
		If pWebServer = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebServerQueryInterface(pWebServer, riid, ppv)
		If FAILED(hr) Then
			DestroyWebServer(pWebServer)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WEBSERVERINICONFIGURATION, rclsid) Then
		Dim pConfiguration As WebServerIniConfiguration Ptr = CreateWebServerIniConfiguration(pILogger, pIMemoryAllocator)
		If pConfiguration = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebServerIniConfigurationQueryInterface(pConfiguration, riid, ppv)
		If FAILED(hr) Then
			DestroyWebServerIniConfiguration(pConfiguration)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_ARRAYSTRINGWRITER, rclsid) Then
		Dim pWriter As ArrayStringWriter Ptr = CreateArrayStringWriter(pILogger, pIMemoryAllocator)
		If pWriter = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ArrayStringWriterQueryInterface(pWriter, riid, ppv)
		If FAILED(hr) Then
			DestroyArrayStringWriter(pWriter)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_ASYNCRESULT, rclsid) Then
		Dim pAsyncResult As AsyncResult Ptr = CreateAsyncResult(pILogger, pIMemoryAllocator)
		If pAsyncResult = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = AsyncResultQueryInterface(pAsyncResult, riid, ppv)
		If FAILED(hr) Then
			DestroyAsyncResult(pAsyncResult)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_HTTPGETPROCESSOR, rclsid) Then
		Dim pProcessor As HttpGetProcessor Ptr = CreateHttpGetProcessor(pILogger, pIMemoryAllocator)
		If pProcessor = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HttpGetProcessorQueryInterface(pProcessor, riid, ppv)
		If FAILED(hr) Then
			DestroyHttpGetProcessor(pProcessor)
		End If
		
		Return hr
	End If
	
	Return CLASS_E_CLASSNOTAVAILABLE
	
End Function

Function CreateMemoryAllocatorInstance( _
		ByVal pILogger As ILogger Ptr, _
		ByVal rclsid As REFCLSID, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualCLSID(@CLSID_HEAPMEMORYALLOCATOR, rclsid) Then
		Dim pAllocator As HeapMemoryAllocator Ptr = CreateHeapMemoryAllocator(pILogger)
		If pAllocator = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HeapMemoryAllocatorQueryInterface(pAllocator, riid, ppv)
		If FAILED(hr) Then
			DestroyHeapMemoryAllocator(pAllocator)
		End If
		
		Return hr
	End If
	
	Return CLASS_E_CLASSNOTAVAILABLE
	
End Function

Function CreateLoggerInstance( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal rclsid As REFCLSID, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualCLSID(@CLSID_CONSOLELOGGER, rclsid) Then
		Dim pLogger As ConsoleLogger Ptr = CreateConsoleLogger(pIMemoryAllocator)
		If pLogger = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ConsoleLoggerQueryInterface(pLogger, riid, ppv)
		If FAILED(hr) Then
			DestroyConsoleLogger(pLogger)
		End If
		
		Return hr
	End If
	
	Return CLASS_E_CLASSNOTAVAILABLE
	
End Function
