#include "CreateInstance.bi"
' #include "ArrayStringWriter.bi"
#include "ClientRequest.bi"
#include "Configuration.bi"
#include "HttpReader.bi"
#include "NetworkStream.bi"
#include "RequestedFile.bi"
#include "ServerResponse.bi"
' #include "ServerState.bi"
#include "WebServer.bi"
' #include "WebSite.bi"
#include "WebSiteContainer.bi"
#include "WorkerThreadContext.bi"

Function CreateInstance( _
		ByVal hHeap As HANDLE, _
		ByVal rclsid As REFCLSID, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
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
	
	If IsEqualCLSID(@CLSID_WORKERTHREADCONTEXT, rclsid) Then
		Dim pContext As WorkerThreadContext Ptr = CreateWorkerThreadContext(hHeap)
		
		If pContext = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		Dim hr As HRESULT = WorkerThreadContextQueryInterface(pContext, riid, ppv)
		
		If FAILED(hr) Then
			DestroyWorkerThreadContext(pContext)
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
		Dim pRequestedFile As RequestedFile Ptr = CreateRequestedFile()
		
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
	
	Return CLASS_E_CLASSNOTAVAILABLE
	
End Function
