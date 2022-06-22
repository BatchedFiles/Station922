#include once "CreateInstance.bi"
#include once "AcceptConnectionAsyncTask.bi"
#include once "ArrayStringWriter.bi"
#include once "AsyncResult.bi"
#include once "ClientRequest.bi"
#include once "ClientUri.bi"
#include once "FileBuffer.bi"
#include once "HeapMemoryAllocator.bi"
#include once "HttpGetProcessor.bi"
#include once "HttpProcessorCollection.bi"
#include once "HttpReader.bi"
#include once "HttpTraceProcessor.bi"
#include once "HttpWriter.bi"
#include once "IniConfiguration.bi"
#include once "MemoryBuffer.bi"
#include once "NetworkStream.bi"
#include once "ReadRequestAsyncTask.bi"
#include once "ServerResponse.bi"
#include once "TcpListener.bi"
#include once "ThreadPool.bi"
#include once "WebServer.bi"
#include once "WebSite.bi"
#include once "WebSiteCollection.bi"
#include once "WriteErrorAsyncTask.bi"
#include once "WriteResponseAsyncTask.bi"

Function CreateInstance( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal rclsid As REFCLSID, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
	If IsEqualCLSID(@CLSID_ACCEPTCONNECTIONASYNCTASK, rclsid) Then
		Dim pTask As AcceptConnectionAsyncTask Ptr = CreateAcceptConnectionAsyncTask(pIMemoryAllocator)
		If pTask = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = AcceptConnectionAsyncTaskQueryInterface(pTask, riid, ppv)
		If FAILED(hr) Then
			DestroyAcceptConnectionAsyncTask(pTask)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_ARRAYSTRINGWRITER, rclsid) Then
		Dim pWriter As ArrayStringWriter Ptr = CreateArrayStringWriter(pIMemoryAllocator)
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
		Dim pAsyncResult As AsyncResult Ptr = CreateAsyncResult(pIMemoryAllocator)
		If pAsyncResult = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = AsyncResultQueryInterface(pAsyncResult, riid, ppv)
		If FAILED(hr) Then
			DestroyAsyncResult(pAsyncResult)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_CLIENTREQUEST, rclsid) Then
		Dim pRequest As ClientRequest Ptr = CreateClientRequest(pIMemoryAllocator)
		If pRequest = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ClientRequestQueryInterface(pRequest, riid, ppv)
		If FAILED(hr) Then
			DestroyClientRequest(pRequest)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_CLIENTURI, rclsid) Then
		Dim pUri As ClientUri Ptr = CreateClientUri(pIMemoryAllocator)
		If pUri = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ClientUriQueryInterface(pUri, riid, ppv)
		If FAILED(hr) Then
			DestroyClientUri(pUri)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_FILEBUFFER, rclsid) Then
		Dim pFileBuffer As FileBuffer Ptr = CreateFileBuffer(pIMemoryAllocator)
		If pFileBuffer = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = FileBufferQueryInterface(pFileBuffer, riid, ppv)
		If FAILED(hr) Then
			DestroyFileBuffer(pFileBuffer)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_HEAPMEMORYALLOCATOR, rclsid) Then
		Dim pAllocator As HeapMemoryAllocator Ptr = CreateHeapMemoryAllocator()
		If pAllocator = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HeapMemoryAllocatorQueryInterface(pAllocator, riid, ppv)
		If FAILED(hr) Then
			DestroyHeapMemoryAllocator(pAllocator)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_HTTPREADER, rclsid) Then
		Dim pReader As HttpReader Ptr = CreateHttpReader(pIMemoryAllocator)
		If pReader = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HttpReaderQueryInterface(pReader, riid, ppv)
		If FAILED(hr) Then
			DestroyHttpReader(pReader)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_HTTPWRITER, rclsid) Then
		Dim pWriter As HttpWriter Ptr = CreateHttpWriter(pIMemoryAllocator)
		If pWriter = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HttpWriterQueryInterface(pWriter, riid, ppv)
		If FAILED(hr) Then
			DestroyHttpWriter(pWriter)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_MEMORYBUFFER, rclsid) Then
		Dim pBuffer As MemoryBuffer Ptr = CreateMemoryBuffer(pIMemoryAllocator)
		If pBuffer = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = MemoryBufferQueryInterface(pBuffer, riid, ppv)
		If FAILED(hr) Then
			DestroyMemoryBuffer(pBuffer)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_NETWORKSTREAM, rclsid) Then
		Dim pStream As NetworkStream Ptr = CreateNetworkStream(pIMemoryAllocator)
		If pStream = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = NetworkStreamQueryInterface(pStream, riid, ppv)
		If FAILED(hr) Then
			DestroyNetworkStream(pStream)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_READREQUESTASYNCTASK, rclsid) Then
		Dim pTask As ReadRequestAsyncTask Ptr = CreateReadRequestAsyncTask(pIMemoryAllocator)
		If pTask = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ReadRequestAsyncTaskQueryInterface(pTask, riid, ppv)
		If FAILED(hr) Then
			DestroyReadRequestAsyncTask(pTask)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_SERVERRESPONSE, rclsid) Then
		Dim pResponse As ServerResponse Ptr = CreateServerResponse(pIMemoryAllocator)
		If pResponse = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ServerResponseQueryInterface(pResponse, riid, ppv)
		If FAILED(hr) Then
			DestroyServerResponse(pResponse)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_TCPLISTENER, rclsid) Then
		Dim pListener As TcpListener Ptr = CreateTcpListener(pIMemoryAllocator)
		If pListener = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = TcpListenerQueryInterface(pListener, riid, ppv)
		If FAILED(hr) Then
			DestroyTcpListener(pListener)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WEBSERVER, rclsid) Then
		Dim pWebServer As WebServer Ptr = CreateWebServer(pIMemoryAllocator)
		If pWebServer = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebServerQueryInterface(pWebServer, riid, ppv)
		If FAILED(hr) Then
			DestroyWebServer(pWebServer)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_INICONFIGURATION, rclsid) Then
		Dim pConfiguration As WebServerIniConfiguration Ptr = CreateWebServerIniConfiguration(pIMemoryAllocator)
		If pConfiguration = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebServerIniConfigurationQueryInterface(pConfiguration, riid, ppv)
		If FAILED(hr) Then
			DestroyWebServerIniConfiguration(pConfiguration)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WRITEERRORASYNCTASK, rclsid) Then
		Dim pTask As WriteErrorAsyncTask Ptr = CreateWriteErrorAsyncTask(pIMemoryAllocator)
		If pTask = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WriteErrorAsyncTaskQueryInterface(pTask, riid, ppv)
		If FAILED(hr) Then
			DestroyWriteErrorAsyncTask(pTask)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WRITERESPONSEASYNCTASK, rclsid) Then
		Dim pTask As WriteResponseAsyncTask Ptr = CreateWriteResponseAsyncTask(pIMemoryAllocator)
		If pTask = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WriteResponseAsyncTaskQueryInterface(pTask, riid, ppv)
		If FAILED(hr) Then
			DestroyWriteResponseAsyncTask(pTask)
		End If
		
		Return hr
	End If
	
	Return CLASS_E_CLASSNOTAVAILABLE
	
End Function

Function CreatePermanentInstance( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal rclsid As REFCLSID, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
	If IsEqualCLSID(@CLSID_HTTPGETASYNCPROCESSOR, rclsid) Then
		Dim pProcessor As HttpGetProcessor Ptr = CreatePermanentHttpGetProcessor(pIMemoryAllocator)
		If pProcessor = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HttpGetProcessorQueryInterface(pProcessor, riid, ppv)
		If FAILED(hr) Then
			DestroyHttpGetProcessor(pProcessor)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_HTTPPROCESSORCOLLECTION, rclsid) Then
		Dim pProcessors As HttpProcessorCollection Ptr = CreatePermanentHttpProcessorCollection(pIMemoryAllocator)
		If pProcessors = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HttpProcessorCollectionQueryInterface(pProcessors, riid, ppv)
		If FAILED(hr) Then
			DestroyHttpProcessorCollection(pProcessors)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_HTTPTRACEASYNCPROCESSOR, rclsid) Then
		Dim pProcessor As HttpTraceProcessor Ptr = CreatePermanentHttpTraceProcessor(pIMemoryAllocator)
		If pProcessor = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = HttpTraceProcessorQueryInterface(pProcessor, riid, ppv)
		If FAILED(hr) Then
			DestroyHttpTraceProcessor(pProcessor)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_THREADPOOL, rclsid) Then
		Dim pPool As ThreadPool Ptr = CreatePermanentThreadPool(pIMemoryAllocator)
		If pPool = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ThreadPoolQueryInterface(pPool, riid, ppv)
		If FAILED(hr) Then
			DestroyThreadPool(pPool)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WEBSITE, rclsid) Then
		Dim pWebSite As WebSite Ptr = CreatePermanentWebSite(pIMemoryAllocator)
		If pWebSite = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebSiteQueryInterface(pWebSite, riid, ppv)
		If FAILED(hr) Then
			DestroyWebSite(pWebSite)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WEBSITECOLLECTION, rclsid) Then
		Dim pWebSites As WebSiteCollection Ptr = CreatePermanentWebSiteCollection(pIMemoryAllocator)
		If pWebSites = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebSiteCollectionQueryInterface(pWebSites, riid, ppv)
		If FAILED(hr) Then
			DestroyWebSiteCollection(pWebSites)
		End If
		
		Return hr
	End If
	
	Return CLASS_E_CLASSNOTAVAILABLE
	
End Function

Function GetHeapMemoryAllocatorInstance( _
	)As IHeapMemoryAllocator Ptr
	
	Dim pMalloc As IHeapMemoryAllocator Ptr = Any
	Dim hrCreateMalloc As HRESULT = CreateInstance( _
		NULL, _
		@CLSID_HEAPMEMORYALLOCATOR, _
		@IID_IHeapMemoryAllocator, _
		@pMalloc _
	)
	If FAILED(hrCreateMalloc) Then
		Return NULL
	End If
	
	Return pMalloc
	
End Function
