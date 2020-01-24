﻿#include "ThreadProc.bi"
#include "CreateInstance.bi"
#include "IWorkerThreadContext.bi"
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
	
	Dim pIContext As IWorkerThreadContext Ptr = CPtr(IWorkerThreadContext Ptr, lpParam)
	
	#ifndef WINDOWS_SERVICE
		
		Dim Frequency As LARGE_INTEGER
		IWorkerThreadContext_GetFrequency(pIContext, @Frequency)
		
		Dim EndThreadTicks As LARGE_INTEGER
		QueryPerformanceCounter(@EndThreadTicks)
		
		Dim StartThreadTicks As LARGE_INTEGER
		IWorkerThreadContext_GetStartTicks(pIContext, @StartThreadTicks)
		
		Dim ThreadWakeUpElapsedTimes As LARGE_INTEGER
		ThreadWakeUpElapsedTimes.QuadPart = EndThreadTicks.QuadPart - StartThreadTicks.QuadPart
		
		PrintThreadStartCount(@Frequency, @ThreadWakeUpElapsedTimes)
		
	#endif
	
	Dim pINetworkStream As INetworkStream Ptr = Any
	IWorkerThreadContext_GetNetworkStream(pIContext, @pINetworkStream)
	
	Dim pIRequest As IClientRequest Ptr = Any
	IWorkerThreadContext_GetClientRequest(pIContext, @pIRequest)
	
	Dim pIHttpReader As IHttpReader Ptr
	IWorkerThreadContext_GetHttpReader(pIContext, @pIHttpReader)
	
	Dim pIResponse As IServerResponse Ptr = Any
	IWorkerThreadContext_GetServerResponse(pIContext, @pIResponse)
	
	IHttpReader_SetBaseStream(pIHttpReader, CPtr(IBaseStream Ptr, pINetworkStream))
	
	Dim KeepAlive As Boolean = True
	Dim ProcessRequestResult As Boolean = True
	
	Do
		
		#ifndef WINDOWS_SERVICE
			
			Dim StartLoopTicks As LARGE_INTEGER
			QueryPerformanceCounter(@StartLoopTicks)
			
		#endif
		
		IHttpReader_Clear(pIHttpReader)
		
		Dim hrReadRequest As HRESULT = IClientRequest_ReadRequest(pIRequest, pIHttpReader)
		
		#ifndef WINDOWS_SERVICE
				PrintRequestedBytes(pIHttpReader)
		#endif
		#ifndef WINDOWS_SERVICE
			
			Dim EndRequestTicks As LARGE_INTEGER
			QueryPerformanceCounter(@EndRequestTicks)
			
			Dim EndRequestElapsedTimes As LARGE_INTEGER
			EndRequestElapsedTimes.QuadPart = EndRequestTicks.QuadPart - StartLoopTicks.QuadPart
			
			PrintThreadProcessCount(@Frequency, @EndRequestElapsedTimes)
			
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
				IWorkerThreadContext_GetWebSiteContainer(pIContext, @pIWebSites)
				
				Dim pIWebSite As IWebSite Ptr = Any
				
				Dim hrFindSite As HRESULT = Any
				
				If HttpMethod = HttpMethods.HttpConnect Then
					hrFindSite = IWebSiteContainer_GetDefaultWebSite(pIWebSites, @pIWebSite)
				Else
					hrFindSite = IWebSiteContainer_FindWebSite(pIWebSites, pHeaderHost, @pIWebSite)
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
						Dim hrGetFile As HRESULT = IWebSite_GetRequestedFile( _
							pIWebSite, _
							@ClientURI.Path, _
							RequestedFileAccess, _
							@pIFile _
						)
						
						If FAILED(hrGetFile) Then
							WriteHttpNotEnoughMemory(pIRequest, pIResponse, CPtr(IBaseStream Ptr, pINetworkStream), pIWebSite)
						Else
							
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
					
				End If
				
				IWebSiteContainer_Release(pIWebSites)
				
			End If
			
			IServerResponse_GetKeepAlive(pIResponse, @KeepAlive)
			
		End If
		
		#ifndef WINDOWS_SERVICE
			
			Dim EndLoopTicks As LARGE_INTEGER
			QueryPerformanceCounter(@EndLoopTicks)
			
			Dim EndLoopElapsedTimes As LARGE_INTEGER
			EndLoopElapsedTimes.QuadPart = EndLoopTicks.QuadPart - StartLoopTicks.QuadPart
			
			PrintThreadProcessCount(@Frequency, @EndLoopElapsedTimes)
			
		#endif
		
		IServerResponse_Clear(pIResponse)
		IClientRequest_Clear(pIRequest)
		
	Loop While KeepAlive AndAlso ProcessRequestResult
	
	IServerResponse_Release(pIResponse)
	IHttpReader_Release(pIHttpReader)
	IClientRequest_Release(pIRequest)
	INetworkStream_Release(pINetworkStream)
	
	IWorkerThreadContext_Release(pIContext)
	
	Return 0
	
End Function
