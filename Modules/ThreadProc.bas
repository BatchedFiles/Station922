#include "ThreadProc.bi"
#include "ConsoleColors.bi"
#include "Http.bi"
#include "IntegerToWString.bi"
#include "ProcessConnectRequest.bi"
#include "ProcessDeleteRequest.bi"
#include "ProcessGetHeadRequest.bi"
#include "ProcessOptionsRequest.bi"
#include "ProcessPostRequest.bi"
#include "ProcessPutRequest.bi"
#include "ProcessTraceRequest.bi"
#include "WebRequest.bi"
#include "WebResponse.bi"
#include "WebUtils.bi"
#include "WriteHttpError.bi"

Function ThreadProc(ByVal lpParam As LPVOID)As DWORD
	
	Dim param As ThreadParam Ptr = CPtr(ThreadParam Ptr, lpParam)
	
#ifndef service
	
	Dim m_startTicks As LARGE_INTEGER
	QueryPerformanceCounter(@m_startTicks)
	
#endif
	
	Dim ClientReader As StreamSocketReader = Any
	InitializeStreamSocketReader(@ClientReader)
	
	NetworkStream_NonVirtualAddRef(param->pINetworkStream)
	ClientReader.pStream = CPtr(IBaseStream Ptr, param->pINetworkStream)
	
	Dim request As WebRequest = Any
	Dim response As WebResponse = Any
	
	Do
		ClientReader.Flush()
		InitializeWebRequest(@request)
		InitializeWebResponse(@response)
		
		If request.ReadClientHeaders(@ClientReader) = False Then
			
			Select Case GetLastError()
				
				Case ParseRequestLineResult.HttpVersionNotSupported
					WriteHttpVersionNotSupported(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), 0)
					
				Case ParseRequestLineResult.BadRequest
					WriteHttpBadRequest(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), 0)
					
				Case ParseRequestLineResult.BadPath
					WriteHttpPathNotValid(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), 0)
					
				Case ParseRequestLineResult.EmptyRequest
					' Пустой запрос, клиент закрыл соединение
					
				Case ParseRequestLineResult.SocketError
					' Ошибка сокета
					
				Case ParseRequestLineResult.RequestUrlTooLong
					WriteHttpRequestUrlTooLarge(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), 0)
					
				Case ParseRequestLineResult.RequestHeaderFieldsTooLarge
					WriteHttpRequestHeaderFieldsTooLarge(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), 0)
					
				Case ParseRequestLineResult.HpptMethodNotSupported
					' TODO Выделить в отдельную функцию
					response.ResponseHeaders(HttpResponseHeaders.HeaderAllow) = @AllSupportHttpMethods
					WriteHttpNotImplemented(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), NULL)
					
			End Select
			
			Exit Do
			
		End If
		
		' TODO Заголовок Host может не быть в версии 1.0
		If lstrlen(request.RequestHeaders(HttpRequestHeaders.HeaderHost)) = 0 Then
			If request.HttpVersion = HttpVersions.Http10 Then
				request.RequestHeaders(HttpRequestHeaders.HeaderHost) = request.ClientURI.Url
			Else
				WriteHttpHostNotFound(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), 0)
				Exit Do
			End If
		End If
		
#ifndef service
			Dim CharsWritten As Integer = Any
			ConsoleWriteColorLineA(ClientReader.Buffer, @CharsWritten, ConsoleColors.Green, ConsoleColors.Black)
#endif
		
		Dim pIWebSite As IWebSite Ptr = Any
		Dim FindSiteResult As HRESULT = IWebSiteContainer_FindWebSite( _
			param->pIWebSites, _
			request.RequestHeaders(HttpRequestHeaders.HeaderHost), _
			@pIWebSite _
		)
		
		If FAILED(FindSiteResult) Then
			If request.HttpMethod = HttpMethods.HttpConnect Then
				IWebSiteContainer_GetDefaultWebSite( _
					param->pIWebSites, _
					@pIWebSite _
				)
			Else
				WriteHttpSiteNotFound(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), NULL)
				Exit Do
			End If
		End If
		
		Dim IsSiteMoved As Boolean = Any
		IWebSite_GetIsMoved(pIWebSite, @IsSiteMoved)
		
		If IsSiteMoved <> False Then
			' Сайт перемещён на другой ресурс
			' если запрошен документ /robots.txt то не перенаправлять
			If lstrcmpi(request.ClientURI.Url, "/robots.txt") <> 0 Then
				WriteMovedPermanently(@request, @response, CPtr(IBaseStream Ptr, param->pINetworkStream), pIWebSite)
				Exit Do
			End If
		End If
		
		' Обработка запроса
		
		Dim ProcessRequestVirtualTable As Function( _
			ByVal pRequest As WebRequest Ptr, _
			ByVal pResponse As WebResponse Ptr, _
			ByVal pINetworkStream As INetworkStream Ptr, _
			ByVal pIWebSite As IWebSite Ptr, _
			ByVal pClientReader As StreamSocketReader Ptr, _
			ByVal pIFile As IRequestedFile Ptr _
		)As Boolean = Any
		
		Dim pIFile As IRequestedFile Ptr = Any
		Dim RequestedFileAccess As FileAccess = Any
		
		Select Case request.HttpMethod
			
			Case HttpMethods.HttpGet
				RequestedFileAccess = FileAccess.ForGetHead
				ProcessRequestVirtualTable = @ProcessGetHeadRequest
				
			Case HttpMethods.HttpHead
				response.SendOnlyHeaders = True
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
				
		End Select
		
		IWebSite_GetRequestedFile(pIWebSite, @request.ClientURI.Path, RequestedFileAccess, @pIFile)
		
		ProcessRequestVirtualTable( _
			@request, _
			@response, _
			param->pINetworkStream, _
			pIWebSite, _
			@ClientReader, _
			pIFile _
		)
		
		IRequestedFile_Release(pIFile)
		IWebSite_Release(pIWebSite)
		
#ifndef service
	
	Dim m_endTicks As LARGE_INTEGER
	QueryPerformanceCounter(@m_endTicks)
	
	Dim wstrTemp As WString * (255 + 1) = Any
	
	i64tow( _
		((m_startTicks.QuadPart - param->m_startTicks.QuadPart) * 1000 * 1000) \ param->m_frequency.QuadPart, _
		@wstrTemp, _
		10 _
	)
	
	ConsoleWriteColorStringW( _
		@!"Количество микросекунд запуска потока\t", _
		@CharsWritten, _
		ConsoleColors.Green, _
		ConsoleColors.Black _
	)
	ConsoleWriteColorLineW( _
		@wstrTemp, @CharsWritten, _
		ConsoleColors.Green, _
		ConsoleColors.Black _
	)
	
	i64tow( _
		((m_endTicks.QuadPart - param->m_startTicks.QuadPart) * 1000 * 1000) \ param->m_frequency.QuadPart, _
		@wstrTemp, _
		10 _
	)
	
	ConsoleWriteColorStringW( _
		@!"Количество микросекунд обработки запроса\t", _
		@CharsWritten, _
		ConsoleColors.Green, _
		ConsoleColors.Black _
	)
	ConsoleWriteColorLineW( _
		@wstrTemp, @CharsWritten, _
		ConsoleColors.Green, _
		ConsoleColors.Black _
	)
	
	param->m_startTicks.QuadPart = m_endTicks.QuadPart
	
#endif
	
	Loop While request.KeepAlive
	
	NetworkStream_NonVirtualRelease(param->pINetworkStream)
	NetworkStream_NonVirtualRelease(param->pINetworkStream)
	IWebSiteContainer_Release(param->pIWebSites)
	
	CloseHandle(param->hThread)
	
	HeapFree(GetProcessHeap(), 0, param)
	
	Return 0
End Function
