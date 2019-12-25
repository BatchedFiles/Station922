#include "ThreadProc.bi"
#include "ClientRequest.bi"
#include "HttpReader.bi"
#include "PrintDebugInfo.bi"
#include "ProcessConnectRequest.bi"
#include "ProcessDeleteRequest.bi"
#include "ProcessGetHeadRequest.bi"
#include "ProcessOptionsRequest.bi"
#include "ProcessPostRequest.bi"
#include "ProcessPutRequest.bi"
#include "ProcessTraceRequest.bi"
#include "ServerResponse.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Function ThreadProc(ByVal lpParam As LPVOID)As DWORD
	
	Dim pContext As ThreadContext Ptr = CPtr(ThreadContext Ptr, lpParam)
	
#ifndef WINDOWS_SERVICE
	
	Dim EndThreadTicks As LARGE_INTEGER
	QueryPerformanceCounter(@EndThreadTicks)
	
	Dim ElapsedTimes As LARGE_INTEGER
	ElapsedTimes.QuadPart = EndThreadTicks.QuadPart - pContext->m_startTicks.QuadPart
	
	PrintThreadStartCount(@pContext->Frequency, @ElapsedTimes)
	
#endif
	
	Dim reader As HttpReader = Any
	Dim pIHttpReader As IHttpReader Ptr = InitializeHttpReaderOfIHttpReader(@reader)
	
	HttpReader_NonVirtualSetBaseStream(pIHttpReader, CPtr(IBaseStream Ptr, pContext->pINetworkStream))
	
	Dim request As ClientRequest = Any
	Dim response As ServerResponse = Any
	
	Dim KeepAlive As Boolean = True
	Dim ProcessRequestResult As Boolean = True
	
	Do
#ifndef WINDOWS_SERVICE
	
		Dim StartTicks As LARGE_INTEGER
		QueryPerformanceCounter(@StartTicks)
	
#endif
		HttpReader_NonVirtualClear(pIHttpReader)
		
		Dim pIClientRequest As IClientRequest Ptr = InitializeClientRequestOfIClientRequest(@request)
		Dim pIResponse As IServerResponse Ptr = InitializeServerResponseOfIServerResponse(@response)
		
		Dim hrReadRequest As HRESULT = IClientRequest_ReadRequest(pIClientRequest, pIHttpReader)
		
#ifndef WINDOWS_SERVICE
		PrintRequestedBytes(pIHttpReader)
#endif
#ifndef WINDOWS_SERVICE
			
			Dim EndRequestTicks As LARGE_INTEGER
			QueryPerformanceCounter(@EndRequestTicks)
			
			ElapsedTimes.QuadPart = EndRequestTicks.QuadPart - StartTicks.QuadPart
			
			PrintThreadProcessCount(@pContext->Frequency, @ElapsedTimes)
			
#endif
		
		If FAILED(hrReadRequest) Then
			
			KeepAlive = False
			
			Select Case hrReadRequest
				
				Case CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
					WriteHttpVersionNotSupported(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_BADREQUEST
					WriteHttpBadRequest(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_BADPATH
					WriteHttpPathNotValid(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_EMPTYREQUEST
					' Пустой запрос, клиент закрыл соединение
					
				Case CLIENTREQUEST_E_SOCKETERROR
					' Ошибка сокета
					
				Case CLIENTREQUEST_E_URITOOLARGE
					WriteHttpRequestUrlTooLarge(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
					WriteHttpRequestHeaderFieldsTooLarge(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED
					' TODO Выделить в отдельную функцию
					IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethods)
					WriteHttpNotImplemented(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), NULL)
					
			End Select
			
		Else
			
			IClientRequest_GetKeepAlive(pIClientRequest, @KeepAlive)
			IServerResponse_SetKeepAlive(pIResponse, KeepAlive)
			
			Dim HttpMethod As HttpMethods = Any
			IClientRequest_GetHttpMethod(pIClientRequest, @HttpMethod)
			
			Dim ClientURI As URI = Any
			IClientRequest_GetUri(pIClientRequest, @ClientURI)
			
			' TODO Найти правильный заголовок Host в зависимости от версии 1.0 или 1.1
			Dim pHeaderHost As WString Ptr = Any
			
			If HttpMethod = HttpMethods.HttpConnect Then
				pHeaderHost = ClientURI.pUrl
			Else
				IClientRequest_GetHttpHeader(pIClientRequest, HttpRequestHeaders.HeaderHost, @pHeaderHost)
			End If
			
			Dim HttpVersion As HttpVersions = Any
			IClientRequest_GetHttpVersion(pIClientRequest, @HttpVersion)
			
			If lstrlen(pHeaderHost) = 0 AndAlso HttpVersion = HttpVersions.Http11 Then
				WriteHttpHostNotFound(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), 0)
			Else
				
				Dim pIWebSite As IWebSite Ptr = Any
				
				Dim hrFindSite As HRESULT = Any
				
				If HttpMethod = HttpMethods.HttpConnect Then
					hrFindSite = IWebSiteContainer_GetDefaultWebSite(pContext->pIWebSites, @pIWebSite)
				Else
					hrFindSite = IWebSiteContainer_FindWebSite(pContext->pIWebSites, pHeaderHost, @pIWebSite)
				End If
				
				If FAILED(hrFindSite) Then
					WriteHttpSiteNotFound(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), NULL)
				Else
					
					Dim IsSiteMoved As Boolean = Any
					
					If lstrcmpi(ClientURI.pUrl, "/robots.txt") = 0 Then
						IsSiteMoved = False
					Else
						IWebSite_GetIsMoved(pIWebSite, @IsSiteMoved)
					End If
					
					If IsSiteMoved Then
						' Сайт перемещён на другой ресурс
						' если запрошен документ /robots.txt то не перенаправлять
						WriteMovedPermanently(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), pIWebSite)
					Else
						
						' Обработка запроса
						
						Dim ProcessRequestVirtualTable As Function( _
							ByVal pIClientRequest As IClientRequest Ptr, _
							ByVal pIResponse As IServerResponse Ptr, _
							ByVal pINetworkStream As INetworkStream Ptr, _
							ByVal pIWebSite As IWebSite Ptr, _
							ByVal pIClientReader As IHttpReader Ptr, _
							ByVal pIFile As IRequestedFile Ptr _
						)As Boolean = Any
						
						Dim RequestedFileAccess As FileAccess = Any
						
						Select Case HttpMethod
							
							Case HttpMethods.HttpGet
								RequestedFileAccess = FileAccess.ForGetHead
								ProcessRequestVirtualTable = @ProcessGetHeadRequest
								
							Case HttpMethods.HttpHead
								IServerResponse_SetSendOnlyHeaders(pIResponse, True)
								RequestedFileAccess = FileAccess.ForGetHead
								ProcessRequestVirtualTable = @ProcessGetHeadRequest
								
							Case HttpMethods.HttpPost
								RequestedFileAccess = FileAccess.ForGetHead
								ProcessRequestVirtualTable = @ProcessPostRequest
								
							Case HttpMethods.HttpPut
								RequestedFileAccess = FileAccess.ForPut
								ProcessRequestVirtualTable = @ProcessPutRequest
								
							Case HttpMethods.HttpDelete
								RequestedFileAccess = FileAccess.ForGetHead
								ProcessRequestVirtualTable = @ProcessDeleteRequest
								
							Case HttpMethods.HttpOptions
								RequestedFileAccess = FileAccess.ForGetHead
								ProcessRequestVirtualTable = @ProcessOptionsRequest
								
							Case HttpMethods.HttpTrace
								RequestedFileAccess = FileAccess.ForGetHead
								ProcessRequestVirtualTable = @ProcessTraceRequest
								
							Case HttpMethods.HttpConnect
								RequestedFileAccess = FileAccess.ForGetHead
								ProcessRequestVirtualTable = @ProcessConnectRequest
								
							Case Else
								RequestedFileAccess = FileAccess.ForGetHead
								ProcessRequestVirtualTable = @ProcessGetHeadRequest
								
						End Select
						
						Dim pIFile As IRequestedFile Ptr = Any
						Dim hrGetFile As HRESULT = IWebSite_GetRequestedFile(pIWebSite, @ClientURI.Path, RequestedFileAccess, @pIFile)
						
						If FAILED(hrGetFile) Then
							WriteHttpNotEnoughMemory(pIClientRequest, pIResponse, CPtr(IBaseStream Ptr, pContext->pINetworkStream), pIWebSite)
						Else
							
							ProcessRequestResult = ProcessRequestVirtualTable( _
								pIClientRequest, _
								pIResponse, _
								pContext->pINetworkStream, _
								pIWebSite, _
								pIHttpReader, _
								pIFile _
							)
							
							IRequestedFile_Release(pIFile)
							
						End If
						
					End If
					
					IWebSite_Release(pIWebSite)
					
				End If
				
			End If
			
			IServerResponse_GetKeepAlive(pIResponse, @KeepAlive)
			
		End If
		
		IServerResponse_Release(pIResponse)
		IClientRequest_Release(pIClientRequest)
		
#ifndef WINDOWS_SERVICE
		
		Dim EndTicks As LARGE_INTEGER
		QueryPerformanceCounter(@EndTicks)
		
		ElapsedTimes.QuadPart = EndTicks.QuadPart - StartTicks.QuadPart
		
		PrintThreadProcessCount(@pContext->Frequency, @ElapsedTimes)
		
#endif
		
	Loop While KeepAlive AndAlso ProcessRequestResult
	
	HttpReader_NonVirtualRelease(pIHttpReader)
	
	NetworkStream_NonVirtualRelease(pContext->pINetworkStream)
	IWebSiteContainer_Release(pContext->pIWebSites)
	
	CloseHandle(pContext->hThread)
	
	HeapFree(pContext->hThreadContextHeap, 0, pContext)
	
	Return 0
	
End Function
