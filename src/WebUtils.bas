#include once "WebUtils.bi"
#include once "win\shlwapi.bi"
#include once "win\wincrypt.bi"
#include once "CharacterConstants.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"
#include once "Mime.bi"
#include once "WriteErrorAsyncTask.bi"

Const DateFormatString = WStr("ddd, dd MMM yyyy ")
Const TimeFormatString = WStr("HH:mm:ss GMT")
Const DefaultCacheControl = WStr("max-age=2678400")
Const BasicAuthorization = WStr("Basic")

Const CompareResultEqual As Long = 0

' Declare Function GetBase64Sha1( _
' 	ByVal pDestination As WString Ptr, _
' 	ByVal pSource As WString Ptr _
' )As Boolean

Extern ThreadPoolCompletionPort As HANDLE

Sub GetHttpDate( _
		ByVal Buffer As WString Ptr, _
		ByVal dt As SYSTEMTIME Ptr _
	)
	
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

Sub AddResponseCacheHeaders( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pDateLastFileModified As FILETIME Ptr, _
		ByVal ETag As HeapBSTR _
	)
	
	Dim IsFileModified As Boolean = True
	
	Scope
		' TODO ����� ������������ ��� ��� HTTP-������� ����
		Dim dFileLastModified As SYSTEMTIME = Any
		FileTimeToSystemTime(pDateLastFileModified, @dFileLastModified)
		
		Dim strFileLastModifiedHttpDate As WString * 256 = Any
		GetHttpDate(@strFileLastModifiedHttpDate, @dFileLastModified)
		
		IServerResponse_AddKnownResponseHeaderWstr( _
			pIResponse, _
			HttpResponseHeaders.HeaderLastModified, _
			@strFileLastModifiedHttpDate _
		)
		
		Dim pHeaderIfModifiedSince As HeapBSTR = Any
		IClientRequest_GetHttpHeader( _
			pIRequest, _
			HttpRequestHeaders.HeaderIfModifiedSince, _
			@pHeaderIfModifiedSince _
		)
		
		If SysStringLen(pHeaderIfModifiedSince) Then
			
			Dim resCompare As Long = lstrcmpiW( _
				@strFileLastModifiedHttpDate, _
				pHeaderIfModifiedSince _
			)
			If resCompare = CompareResultEqual Then
				IsFileModified = False
			End If
		End If
		
		HeapSysFreeString(pHeaderIfModifiedSince)
		
		Dim pHeaderIfUnModifiedSince As HeapBSTR = Any
		IClientRequest_GetHttpHeader( _
			pIRequest, _
			HttpRequestHeaders.HeaderIfUnModifiedSince, _
			@pHeaderIfUnModifiedSince _
		)
		
		If SysStringLen(pHeaderIfUnModifiedSince) Then
			
			Dim resCompare As Long = lstrcmpiW( _
				@strFileLastModifiedHttpDate, _
				pHeaderIfUnModifiedSince _
			)
			If resCompare = CompareResultEqual Then
				IsFileModified = True
			End If
		End If
		
		HeapSysFreeString(pHeaderIfUnModifiedSince)
	End Scope
	
	Scope
		IServerResponse_AddKnownResponseHeader( _
			pIResponse, _
			HttpResponseHeaders.HeaderETag, _
			ETag _
		)
		
		If IsFileModified Then
			
			Dim HeaderIfNoneMatch As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderIfNoneMatch, _
				@HeaderIfNoneMatch _
			)
			
			If SysStringLen(HeaderIfNoneMatch) Then
				Dim CompareResult As Long = lstrcmpiW(HeaderIfNoneMatch, ETag)
				If CompareResult = CompareResultEqual Then
					IsFileModified = False
				End If
			End If
			
			HeapSysFreeString(HeaderIfNoneMatch)
		End If
		
		If IsFileModified = False Then
			
			Dim HeaderIfMatch As HeapBSTR = Any
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderIfMatch, _
				@HeaderIfMatch _
			)
			
			If SysStringLen(HeaderIfMatch) Then
				Dim CompareResult As Long = lstrcmpiW(HeaderIfMatch, ETag)
				If CompareResult = CompareResultEqual Then
					IsFileModified = True
				End If
			End If
			
			HeapSysFreeString(HeaderIfMatch)
		End If
		
	End Scope
	
	IServerResponse_AddKnownResponseHeaderWstrLen( _
		pIResponse, _
		HttpResponseHeaders.HeaderCacheControl, _
		@DefaultCacheControl, _
		Len(DefaultCacheControl) _
	)
	
	Dim SendOnlyHeaders As Boolean = Any
	IServerResponse_GetSendOnlyHeaders(pIResponse, @SendOnlyHeaders)
	
	SendOnlyHeaders = SendOnlyHeaders OrElse (Not IsFileModified)
	
	IServerResponse_SetSendOnlyHeaders(pIResponse, SendOnlyHeaders)
	
	If IsFileModified = False Then
		IServerResponse_SetStatusCode(pIResponse, HttpStatusCodes.NotModified)
	End If
	
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
	Dim hrCreateTask As HRESULT = CreateInstance( _
		pIMemoryAllocator, _
		@CLSID_WRITEERRORASYNCTASK, _
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
		ByVal hHandle As Handle, _
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
