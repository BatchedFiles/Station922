#include once "WebUtils.bi"
#include once "win\shlwapi.bi"
#include once "win\wincrypt.bi"
#include once "CharacterConstants.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"
#include once "Mime.bi"

Const DateFormatString = WStr("ddd, dd MMM yyyy ")
Const TimeFormatString = WStr("HH:mm:ss GMT")
Const DefaultCacheControl = WStr("max-age=2678400")
Const BasicAuthorization = WStr("Basic")

Declare Function GetBase64Sha1( _
	ByVal pDestination As WString Ptr, _
	ByVal pSource As WString Ptr _
)As Boolean

Sub GetHttpDate( _
		ByVal Buffer As WString Ptr, _
		ByVal dt As SYSTEMTIME Ptr _
	)
	
	' Tue, 15 Nov 1994 12:45:26 GMT
	Dim dtBufferLength As Integer = GetDateFormatW(LOCALE_INVARIANT, 0, dt, @DateFormatString, Buffer, 31) - 1
	GetTimeFormatW(LOCALE_INVARIANT, 0, dt, @TimeFormatString, @Buffer[dtBufferLength], 31 - dtBufferLength)
	
End Sub

Sub GetHttpDate(ByVal Buffer As WString Ptr)
	
	Dim dt As SYSTEMTIME = Any
	GetSystemTime(@dt)
	GetHttpDate(Buffer, @dt)
	
End Sub


Sub AddResponseCacheHeaders( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIResponse As IServerResponse Ptr, _
		ByVal pDateLastFileModified As FILETIME Ptr, _
		ByVal ETag As HeapBSTR _
	)
	
	Dim IsFileModified As Boolean = True
	
	Scope
		' TODO Уметь распознавать все три HTTP-формата даты
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
			If resCompare = 0 Then
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
			If resCompare = 0 Then
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
				If lstrcmpiW(HeaderIfNoneMatch, ETag) = 0 Then
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
				If lstrcmpiW(HeaderIfMatch, ETag) = 0 Then
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
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr, _
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

Function Integer64Division( _
		ByVal Dividend As LongInt, _
		ByVal Divisor As LongInt _
	)As LongInt
	
	Dim varLeft As VARIANT = Any
	varLeft.vt = VT_I8
	varLeft.llVal = Dividend
	
	Dim varRight As VARIANT = Any
	varRight.vt = VT_I8
	varRight.llVal = Divisor
	
	Dim varResult As VARIANT = Any
	VariantInit(@varResult)
	
	Dim hr As HRESULT = VarIdiv( _
		@varLeft, _
		@varRight, _
		@varResult _
	)
	If FAILED(hr) Then
		Return 0
	End If
	
	Return varResult.llVal
	
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
