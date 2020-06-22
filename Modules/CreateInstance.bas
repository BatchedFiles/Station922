#include "CreateInstance.bi"
#include "ArrayStringWriter.bi"
#include "ClientContext.bi"
#include "ClientRequest.bi"
#include "Configuration.bi"
#include "HttpGetProcessor.bi"
#include "HttpReader.bi"
#include "NetworkStream.bi"
#include "NetworkStreamAsyncResult.bi"
#include "RequestedFile.bi"
#include "ServerResponse.bi"
#include "WebServer.bi"
#include "WebSite.bi"
#include "WebSiteContainer.bi"

Function CreateInstance( _
		ByVal hHeap As HANDLE, _
		ByVal rclsid As REFCLSID, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
	If IsEqualCLSID(@CLSID_WEBSITE, rclsid) Then
		Dim pWebSite As WebSite Ptr = CreateWebSite(hHeap)
		
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
		Dim pReader As HttpReader Ptr = CreateHttpReader(hHeap)
		
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
		Dim pResponse As ServerResponse Ptr = CreateServerResponse(hHeap)
		
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
		Dim pRequest As ClientRequest Ptr = CreateClientRequest(hHeap)
		
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
		Dim pStream As NetworkStream Ptr = CreateNetworkStream(hHeap)
		
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
		Dim pContext As ClientContext Ptr = CreateClientContext(hHeap)
		
		If pContext = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ClientContextQueryInterface(pContext, riid, ppv)
		
		If FAILED(hr) Then
			DestroyClientContext(pContext)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_WEBSITECONTAINER, rclsid) Then
		Dim pWebSites As WebSiteContainer Ptr = CreateWebSiteContainer()
		
		If pWebSites = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebSiteContainerQueryInterface(pWebSites, riid, ppv)
		
		If FAILED(hr) Then
			DestroyWebSiteContainer(pWebSites)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_REQUESTEDFILE, rclsid) Then
		Dim pRequestedFile As RequestedFile Ptr = CreateRequestedFile(hHeap)
		
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
		Dim pWebServer As WebServer Ptr = CreateWebServer()
		
		If pWebServer = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WebServerQueryInterface(pWebServer, riid, ppv)
		
		If FAILED(hr) Then
			DestroyWebServer(pWebServer)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_CONFIGURATION, rclsid) Then
		Dim pConfiguration As Configuration Ptr = CreateConfiguration()
		
		If pConfiguration = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ConfigurationQueryInterface(pConfiguration, riid, ppv)
		
		If FAILED(hr) Then
			DestroyConfiguration(pConfiguration)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_ARRAYSTRINGWRITER, rclsid) Then
		Dim pWriter As ArrayStringWriter Ptr = CreateArrayStringWriter(hHeap)
		
		If pWriter = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = ArrayStringWriterQueryInterface(pWriter, riid, ppv)
		
		If FAILED(hr) Then
			DestroyArrayStringWriter(pWriter)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_NETWORKSTREAMASYNCRESULT, rclsid) Then
		Dim pAsyncResult As NetworkStreamAsyncResult Ptr = CreateNetworkStreamAsyncResult(hHeap)
		
		If pAsyncResult = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = NetworkStreamAsyncResultQueryInterface(pAsyncResult, riid, ppv)
		
		If FAILED(hr) Then
			DestroyNetworkStreamAsyncResult(pAsyncResult)
		End If
		
		Return hr
	End If
	
	If IsEqualCLSID(@CLSID_HTTPGETPROCESSOR, rclsid) Then
		Dim pProcessor As HttpGetProcessor Ptr = CreateHttpGetProcessor(hHeap)
		
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
