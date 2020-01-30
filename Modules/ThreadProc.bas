#include "ThreadProc.bi"
#include "CreateInstance.bi"
#include "IClientContext.bi"
#include "PrintDebugInfo.bi"
#include "ProcessConnectRequest.bi"
#include "ProcessDeleteRequest.bi"
#include "ProcessGetHeadRequest.bi"
#include "ProcessOptionsRequest.bi"
#include "ProcessPostRequest.bi"
#include "ProcessPutRequest.bi"
#include "ProcessTraceRequest.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Type LPProcessRequestVirtualTable As Function(ByVal pIRequest As IClientRequest Ptr, ByVal pIResponse As IServerResponse Ptr, ByVal pINetworkStream As INetworkStream Ptr, ByVal pIWebSite As IWebSite Ptr, ByVal pIClientReader As IHttpReader Ptr, ByVal pIFile As IRequestedFile Ptr)As Boolean

Function ThreadProc(ByVal lpParam As LPVOID)As DWORD
	
	Dim pIContext As IClientContext Ptr = CPtr(IClientContext Ptr, lpParam)
	
	#ifdef PERFORMANCE_TESTING
		
		Dim Frequency As LARGE_INTEGER
		IClientContext_GetFrequency(pIContext, @Frequency)
		
		Dim StartThreadSuspendedTicks As LARGE_INTEGER
		IClientContext_GetStartTicks(pIContext, @StartThreadSuspendedTicks)
		
		Dim EndThreadSuspendedTicks As LARGE_INTEGER
		QueryPerformanceCounter(@EndThreadSuspendedTicks)
		
		Dim ThreadSuspendedElapsedTimes As LARGE_INTEGER
		ThreadSuspendedElapsedTimes.QuadPart = EndThreadSuspendedTicks.QuadPart - StartThreadSuspendedTicks.QuadPart
		
		PrintThreadSuspendedElapsedTimes(@Frequency, @ThreadSuspendedElapsedTimes)
		
	#endif
	
	Dim pINetworkStream As INetworkStream Ptr = Any
	IClientContext_GetNetworkStream(pIContext, @pINetworkStream)
	
	Dim pIRequest As IClientRequest Ptr = Any
	IClientContext_GetClientRequest(pIContext, @pIRequest)
	
	Dim pIHttpReader As IHttpReader Ptr
	IClientContext_GetHttpReader(pIContext, @pIHttpReader)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IClientContext_GetServerResponse(pIContext, @pIResponse)
	
	IHttpReader_SetBaseStream(pIHttpReader, CPtr(IBaseStream Ptr, pINetworkStream))
	
	Dim KeepAlive As Boolean = True
	Dim ProcessRequestResult As Boolean = True
	
	Do
		
		#ifdef PERFORMANCE_TESTING
			
			Dim StartLoopTicks As LARGE_INTEGER
			QueryPerformanceCounter(@StartLoopTicks)
			
		#endif
		
		IHttpReader_Clear(pIHttpReader)
		
		Dim hrReadRequest As HRESULT = IClientRequest_ReadRequest(pIRequest, pIHttpReader)
		
		#ifndef WINDOWS_SERVICE
				PrintRequestedBytes(pIHttpReader)
		#endif
		
		#ifdef PERFORMANCE_TESTING
			
			Dim EndRequestTicks As LARGE_INTEGER
			QueryPerformanceCounter(@EndRequestTicks)
			
			Dim RequestElapsedTimes As LARGE_INTEGER
			RequestElapsedTimes.QuadPart = EndRequestTicks.QuadPart - StartLoopTicks.QuadPart
			
			PrintRequestElapsedTimes(@Frequency, @RequestElapsedTimes)
			
		#endif
		
		If FAILED(hrReadRequest) Then
			
			KeepAlive = False
			
			Select Case hrReadRequest
				
				Case CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
					WriteHttpVersionNotSupported(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_BADREQUEST
					WriteHttpBadRequest(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_BADPATH
					WriteHttpPathNotValid(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_EMPTYREQUEST
					' Пустой запрос, клиент закрыл соединение
					
				Case CLIENTREQUEST_E_SOCKETERROR
					' Ошибка сокета
					
				Case CLIENTREQUEST_E_URITOOLARGE
					WriteHttpRequestUrlTooLarge(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
					WriteHttpRequestHeaderFieldsTooLarge(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), 0)
					
				Case CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED
					' TODO Выделить в отдельную функцию
					IServerResponse_SetHttpHeader(pIResponse, HttpResponseHeaders.HeaderAllow, @AllSupportHttpMethods)
					WriteHttpNotImplemented(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
					
				Case Else
					WriteHttpBadRequest(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), 0)
					
			End Select
			
		Else
			
			IClientRequest_GetKeepAlive(pIRequest, @KeepAlive)
			IServerResponse_SetKeepAlive(pIResponse, KeepAlive)
			
			Dim HttpMethod As HttpMethods = Any
			IClientRequest_GetHttpMethod(pIRequest, @HttpMethod)
			
			Dim ClientURI As Station922Uri = Any
			IClientRequest_GetUri(pIRequest, @ClientURI)
			
			' TODO Найти правильный заголовок Host в зависимости от версии 1.0 или 1.1
			Dim pHeaderHost As WString Ptr = Any
			
			If HttpMethod = HttpMethods.HttpConnect Then
				pHeaderHost = ClientURI.pUrl
			Else
				IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderHost, @pHeaderHost)
			End If
			
			Dim HttpVersion As HttpVersions = Any
			IClientRequest_GetHttpVersion(pIRequest, @HttpVersion)
			
			If lstrlen(pHeaderHost) = 0 AndAlso HttpVersion = HttpVersions.Http11 Then
				WriteHttpHostNotFound(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), 0)
			Else
				
				Dim pIWebSites As IWebSiteContainer Ptr = Any
				IClientContext_GetWebSiteContainer(pIContext, @pIWebSites)
				
				Dim pIWebSite As IWebSite Ptr = Any
				IClientContext_GetWebSite(pIContext, @pIWebSite)
				
				Dim hrFindSite As HRESULT = Any
				If HttpMethod = HttpMethods.HttpConnect Then
					hrFindSite = IWebSiteContainer_GetDefaultWebSite(pIWebSites, pIWebSite)
				Else
					hrFindSite = IWebSiteContainer_FindWebSite(pIWebSites, pHeaderHost, pIWebSite)
				End If
				
				If FAILED(hrFindSite) Then
					WriteHttpSiteNotFound(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), NULL)
				Else
					
					Dim IsSiteMoved As Boolean = Any
					' TODO Грязный хак с robots.txt
					If lstrcmpi(ClientURI.pUrl, "/robots.txt") = 0 Then
						IsSiteMoved = False
					Else
						IWebSite_GetIsMoved(pIWebSite, @IsSiteMoved)
					End If
					
					If IsSiteMoved Then
						' Сайт перемещён на другой ресурс
						' если запрошен документ /robots.txt то не перенаправлять
						WriteMovedPermanently(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
					Else
						
						' TODO Создать отдельные классы обработчиков запроса
						Dim ProcessRequestVirtualTable As LPProcessRequestVirtualTable = Any
						Dim RequestedFileAccess As FileAccess = Any
						
						Select Case HttpMethod
							
							Case HttpMethods.HttpGet
								RequestedFileAccess = FileAccess.ReadAccess
								ProcessRequestVirtualTable = @ProcessGetHeadRequest
								
							Case HttpMethods.HttpHead
								IServerResponse_SetSendOnlyHeaders(pIResponse, True)
								RequestedFileAccess = FileAccess.ReadAccess
								ProcessRequestVirtualTable = @ProcessGetHeadRequest
								
							Case HttpMethods.HttpPost
								RequestedFileAccess = FileAccess.UpdateAccess
								ProcessRequestVirtualTable = @ProcessPostRequest
								
							Case HttpMethods.HttpPut
								RequestedFileAccess = FileAccess.CreateAccess
								ProcessRequestVirtualTable = @ProcessPutRequest
								
							Case HttpMethods.HttpDelete
								RequestedFileAccess = FileAccess.DeleteAccess
								ProcessRequestVirtualTable = @ProcessDeleteRequest
								
							Case HttpMethods.HttpOptions
								RequestedFileAccess = FileAccess.ReadAccess
								ProcessRequestVirtualTable = @ProcessOptionsRequest
								
							Case HttpMethods.HttpTrace
								RequestedFileAccess = FileAccess.ReadAccess
								ProcessRequestVirtualTable = @ProcessTraceRequest
								
							Case HttpMethods.HttpConnect
								RequestedFileAccess = FileAccess.ReadAccess
								ProcessRequestVirtualTable = @ProcessConnectRequest
								
							Case Else
								RequestedFileAccess = FileAccess.ReadAccess
								ProcessRequestVirtualTable = @ProcessGetHeadRequest
								
						End Select
						
						Dim pIFile As IRequestedFile Ptr = Any
						IClientContext_GetRequestedFile(pIContext, @pIFile)
						
						Dim hrGetFile As HRESULT = IWebSite_OpenRequestedFile( _
							pIWebSite, _
							pIFile, _
							@ClientURI.Path, _
							RequestedFileAccess _
						)
						
						ProcessRequestResult = ProcessRequestVirtualTable( _
							pIRequest, _
							pIResponse, _
							pINetworkStream, _
							pIWebSite, _
							pIHttpReader, _
							pIFile _
						)
						
						IRequestedFile_Release(pIFile)
						
					End If
					
				End If
				
				IWebSite_Release(pIWebSite)
				IWebSiteContainer_Release(pIWebSites)
				
			End If
			
			IServerResponse_GetKeepAlive(pIResponse, @KeepAlive)
			
		End If
		
		#ifdef PERFORMANCE_TESTING
			
			Dim EndLoopTicks As LARGE_INTEGER
			QueryPerformanceCounter(@EndLoopTicks)
			
			Dim LoopElapsedTimes As LARGE_INTEGER
			LoopElapsedTimes.QuadPart = EndLoopTicks.QuadPart - StartLoopTicks.QuadPart
			
			PrintRequestElapsedTimes(@Frequency, @LoopElapsedTimes)
			
		#endif
		
		IServerResponse_Clear(pIResponse)
		IClientRequest_Clear(pIRequest)
		
	Loop While KeepAlive AndAlso ProcessRequestResult
	
	IServerResponse_Release(pIResponse)
	IHttpReader_Release(pIHttpReader)
	IClientRequest_Release(pIRequest)
	INetworkStream_Release(pINetworkStream)
	
	Dim hClientContextHeap As HANDLE = Any
	IClientContext_GetClientContextHeap(pIContext, @hClientContextHeap)
	
	IClientContext_Release(pIContext)
	
	HeapDestroy(hClientContextHeap)
	
	Return 0
	
End Function
