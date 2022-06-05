#include once "ServerResponse.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"
#include once "StringConstants.bi"
#include once "WebUtils.bi"

Extern GlobalServerResponseVirtualTable As Const IServerResponseVirtualTable

Const BytesString = WStr("bytes")
Const CloseString = WStr("Close")
Const KeepAliveString = WStr("Keep-Alive")
Const MaxResponseBufferLength As Integer = 8 * 4096 - 1

Type _ServerResponse
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IServerResponseVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIWriter As IHttpWriter Ptr
	ResponseHeaders(HttpResponseHeadersMaximum - 1) As HeapBSTR
	ResponseHeaderLine As ZString Ptr
	ResponseHeaderLineLength As Integer
	HttpVersion As HttpVersions
	StatusCode As HttpStatusCodes
	StatusDescription As HeapBSTR
	ResponseZipMode As ZipModes
	Mime As MimeType
	ResponseZipEnable As Boolean
	SendOnlyHeaders As Boolean
	KeepAlive As Boolean
End Type

Sub InitializeServerResponse( _
		ByVal this As ServerResponse Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory(@this->IdString, @Str("Server__Response"), 16)
	#endif
	this->lpVtbl = @GlobalServerResponseVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pIWriter = NULL
	ZeroMemory(@this->ResponseHeaders(0), HttpResponseHeadersMaximum * SizeOf(HeapBSTR))
	this->ResponseHeaderLine = NULL
	this->ResponseHeaderLineLength = 0
	this->HttpVersion = HttpVersions.Http11
	this->StatusCode = HttpStatusCodes.OK
	this->StatusDescription = NULL
	this->SendOnlyHeaders = False
	this->KeepAlive = True
	this->ResponseZipEnable = False
	this->Mime.ContentType = ContentTypes.AnyAny
	this->Mime.IsTextFormat = False
	this->Mime.Charset = DocumentCharsets.ASCII
	
End Sub

Sub UnInitializeServerResponse( _
		ByVal this As ServerResponse Ptr _
	)
	
	If this->pIWriter <> NULL Then
		IHttpWriter_Release(this->pIWriter)
	End If
	
	For i As Integer = 0 To HttpResponseHeadersMaximum - 1
		HeapSysFreeString(this->ResponseHeaders(i))
	Next
	
	HeapSysFreeString(this->StatusDescription)
	
	If this->ResponseHeaderLine <> NULL Then
		IMalloc_Free( _
			this->pIMemoryAllocator, _
			this->ResponseHeaderLine _
		)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateServerResponse( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ServerResponse Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ServerResponse)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ServerResponse creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As ServerResponse Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ServerResponse) _
	)
	
	If this <> NULL Then
		
		InitializeServerResponse( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("ServerResponse created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyServerResponse( _
		ByVal this As ServerResponse Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ServerResponse destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeServerResponse(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ServerResponse destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ServerResponseQueryInterface( _
		ByVal this As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IServerResponse, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ServerResponseAddRef(this)
	
	Return S_OK
	
End Function

Function ServerResponseAddRef( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function ServerResponseRelease( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyServerResponse(this)
	
	Return 0
	
End Function

Function ServerResponseGetHttpVersion( _
		ByVal this As ServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	
	*pHttpVersion = this->HttpVersion
	
	Return S_OK
	
End Function

Function ServerResponseSetHttpVersion( _
		ByVal this As ServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT
	
	this->HttpVersion = HttpVersion
	
	Return S_OK
	
End Function

Function ServerResponseGetStatusCode( _
		ByVal this As ServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT
	
	*pStatusCode = this->StatusCode
	
	Return S_OK
	
End Function

Function ServerResponseSetStatusCode( _
		ByVal this As ServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT
	
	this->StatusCode = StatusCode
	
	Return S_OK
	
End Function

Function ServerResponseGetStatusDescription( _
		ByVal this As ServerResponse Ptr, _
		ByVal ppStatusDescription As HeapBSTR Ptr _
	)As HRESULT
	
	*ppStatusDescription = this->StatusDescription
	
	Return S_OK
	
End Function

Function ServerResponseSetStatusDescription( _
		ByVal this As ServerResponse Ptr, _
		ByVal pStatusDescription As HeapBSTR _
	)As HRESULT
	
	this->StatusDescription = pStatusDescription
	
	Return S_OK
	
End Function

Function ServerResponseGetKeepAlive( _
		ByVal this As ServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	*pKeepAlive = this->KeepAlive
	
	Return S_OK
	
End Function

Function ServerResponseSetKeepAlive( _
		ByVal this As ServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	
	this->KeepAlive = KeepAlive
	
	Return S_OK
	
End Function

Function ServerResponseGetSendOnlyHeaders( _
		ByVal this As ServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT
	
	*pSendOnlyHeaders = this->SendOnlyHeaders
	
	Return S_OK
	
End Function

Function ServerResponseSetSendOnlyHeaders( _
		ByVal this As ServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT
	
	this->SendOnlyHeaders = SendOnlyHeaders
	
	Return S_OK
	
End Function

Function ServerResponseGetMimeType( _
		ByVal this As ServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	*pMimeType = this->Mime
	
	Return S_OK
	
End Function

Function ServerResponseSetMimeType( _
		ByVal this As ServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	this->Mime = *pMimeType
	
	Return S_OK
	
End Function

Function ServerResponseGetHttpHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	
	*ppHeader = this->ResponseHeaders(HeaderIndex)
	
	Return S_OK
	
End Function

Function ServerResponseSetHttpHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As HeapBSTR _
	)As HRESULT
	
	this->ResponseHeaders(HeaderIndex) = pHeader
	
	Return S_OK
	
End Function

Function ServerResponseGetZipEnabled( _
		ByVal this As ServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT
	
	*pZipEnabled = this->ResponseZipEnable
	
	Return S_OK
	
End Function

Function ServerResponseSetZipEnabled( _
		ByVal this As ServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT
	
	this->ResponseZipEnable = ZipEnabled
	
	Return S_OK
	
End Function

Function ServerResponseGetZipMode( _
		ByVal this As ServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	*pZipMode = this->ResponseZipMode
	
	Return S_OK
	
End Function

Function ServerResponseSetZipMode( _
		ByVal this As ServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	this->ResponseZipMode = ZipMode
	
	Return S_OK
	
End Function

Function ServerResponseAddResponseHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderName As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	
	Dim HeaderIndex As HttpResponseHeaders = Any
	Dim Finded As Boolean = GetKnownResponseHeaderIndex(HeaderName, @HeaderIndex)
	If Finded Then
		Dim hrAddHeader As HRESULT = ServerResponseAddKnownResponseHeader( _
			this, _
			HeaderIndex, _
			Value _
		)
		Return hrAddHeader
	End If
	
	Return S_FALSE
	
End Function

Function ServerResponseAddKnownResponseHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ResponseHeaders(HeaderIndex), Value)
	
	Return S_OK
	
End Function

Function ServerResponseAddKnownResponseHeaderWstr( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	Dim Length As Integer = lstrlenW(Value)
	
	Dim hr As HRESULT = ServerResponseAddKnownResponseHeaderWstrLen( _
		this, _
		HeaderIndex, _
		Value, _
		Length _
	)
	
	Return hr
	
End Function

Function ServerResponseAddKnownResponseHeaderWstrLen( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	Dim hBstr As HeapBSTR = HeapSysAllocStringLen( _
		this->pIMemoryAllocator, _
		Value, _
		Length _
	)
	
	Dim hr As HRESULT = ServerResponseAddKnownResponseHeader( _
		this, _
		HeaderIndex, _
		hBstr _
	)
	
	HeapSysFreeString(hBstr)
	
	Return hr
	
End Function

Function ServerResponseGetTextWriter( _
		ByVal this As ServerResponse Ptr, _
		ByVal ppIWriter As IHttpWriter Ptr Ptr _
	)As HRESULT
	
	If this->pIWriter <> NULL Then
		IHttpWriter_AddRef(this->pIWriter)
	End If
	
	*ppIWriter = this->pIWriter
	
	Return S_OK
	
End Function

Function ServerResponseSetTextWriter( _
		ByVal this As ServerResponse Ptr, _
		ByVal pIWriter As IHttpWriter Ptr _
	)As HRESULT
	
	If pIWriter <> NULL Then
		IHttpWriter_AddRef(pIWriter)
	End If
	
	If this->pIWriter <> NULL Then
		IHttpWriter_Release(this->pIWriter)
	End If
	
	this->pIWriter = pIWriter
	
	Return S_OK
	
End Function

Function ServerResponseBeginWriteResponse( _
		ByVal this As ServerResponse Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Dim hrBeginWrite As HRESULT = IHttpWriter_BeginWrite( _
		this->pIWriter, _
		this->ResponseHeaderLine, _
		this->ResponseHeaderLineLength, _
		this->SendOnlyHeaders, _
		StateObject, _
		ppIAsyncResult _
	)
	If FAILED(hrBeginWrite) Then
		Return hrBeginWrite
	End If
	
	Return SERVERRESPONSE_S_IO_PENDING
	
End Function

Function ServerResponseEndWriteResponse( _
		ByVal this As ServerResponse Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	Dim hrEndWrite As HRESULT = IHttpWriter_EndWrite( _
		this->pIWriter, _
		pIAsyncResult _
	)
	If FAILED(hrEndWrite) Then
		Return hrEndWrite
	End If
	
	Select Case hrEndWrite
		
		Case S_OK
			Return S_OK
			
		Case S_FALSE
			Return S_FALSE
			
		Case HTTPWRITER_S_IO_PENDING
			Return SERVERRESPONSE_S_IO_PENDING
			
	End Select
	
End Function

Function ServerResponsePrepare( _
		ByVal this As ServerResponse Ptr, _
		ByVal ContentLength As LongInt _
	)As HRESULT
	
	Dim pIWriter As IArrayStringWriter Ptr = Any
	Dim hrCreateStringWriter As HRESULT = CreateInstance( _
		this->pIMemoryAllocator, _
		@CLSID_ARRAYSTRINGWRITER, _
		@IID_IArrayStringWriter, _
		@pIWriter _
	)
	If FAILED(hrCreateStringWriter) Then
		Return hrCreateStringWriter
	End If
	
	ServerResponseAddKnownResponseHeaderWstrLen( _
		this, _
		HttpResponseHeaders.HeaderAcceptRanges, _
		@BytesString, _
		Len(BytesString) _
	)
	
	#if __FB_DEBUG__
		ServerResponseAddKnownResponseHeaderWstr( _
			this, _
			HttpResponseHeaders.HeaderServer, _
			@WStr("Station922/0.9.0") _
		)
	#endif
	
	Select Case this->StatusCode
		
		Case HttpStatusCodes.CodeContinue, _
			HttpStatusCodes.SwitchingProtocols, _
			HttpStatusCodes.Processing, _
			HttpStatusCodes.NoContent
			
			ServerResponseAddKnownResponseHeader( _
				this, _
				HttpResponseHeaders.HeaderContentLength, _
				NULL _
			)
			
		Case Else
			Dim strContentLength As WString * (64) = Any
			_i64tow(ContentLength, @strContentLength, 10)
			
			ServerResponseAddKnownResponseHeaderWstr( _
				this, _
				HttpResponseHeaders.HeaderContentLength, _
				@strContentLength _
			)
			
	End Select
	
	If this->KeepAlive Then
		ServerResponseAddKnownResponseHeaderWstrLen( _
			this, _
			HttpResponseHeaders.HeaderConnection, _
			@KeepAliveString, _
			Len(KeepAliveString) _
		)
	Else
		ServerResponseAddKnownResponseHeaderWstrLen( _
			this, _
			HttpResponseHeaders.HeaderConnection, _
			@CloseString, _
			Len(CloseString) _
		)
	End If
	
	Scope
		Dim wContentType As WString * (MaxContentTypeLength + 1) = Any
		GetContentTypeOfMimeType(@wContentType, @this->Mime)
		
		ServerResponseAddKnownResponseHeaderWstr( _
			this, _
			HttpResponseHeaders.HeaderContentType, _
			@wContentType _
		)
	End Scope
	
	Dim HeadersBuffer As WString * (MaxResponseBufferLength + 1) = Any
	
	Scope
		IArrayStringWriter_SetBuffer( _
			pIWriter, _
			@HeadersBuffer, _
			MaxResponseBufferLength _
		)
		
		Scope
			Dim HttpVersionLength As Integer = Any
			Dim pwHttpVersion As WString Ptr = HttpVersionToString( _
				this->HttpVersion, _
				@HttpVersionLength _
			)
			
			IArrayStringWriter_WriteLengthString(pIWriter, pwHttpVersion, HttpVersionLength)
			IArrayStringWriter_WriteChar(pIWriter, Characters.WhiteSpace)
			IArrayStringWriter_WriteInt32(pIWriter, this->StatusCode)
			IArrayStringWriter_WriteChar(pIWriter, Characters.WhiteSpace)
			
			If this->StatusDescription = NULL Then
				Dim BufferLength As Integer = Any
				Dim wBuffer As WString Ptr = GetStatusDescription(this->StatusCode, @BufferLength)
				IArrayStringWriter_WriteLengthStringLine(pIWriter, wBuffer, BufferLength)
			Else
				IArrayStringWriter_WriteStringLine(pIWriter, this->StatusDescription)
			End If
		End Scope
		
		Scope
			Dim datNowF As FILETIME = Any
			GetSystemTimeAsFileTime(@datNowF)
			
			Dim datNowS As SYSTEMTIME = Any
			FileTimeToSystemTime(@datNowF, @datNowS)
			
			Dim dtBuffer As WString * (32) = Any
			GetHttpDate(@dtBuffer, @datNowS)
			
			ServerResponseAddKnownResponseHeaderWstr( _
				this, _
				HttpResponseHeaders.HeaderDate, _
				@dtBuffer _
			)
		End Scope
		
		For i As Integer = 0 To HttpResponseHeadersMaximum - 1
			
			Dim HeaderIndex As HttpResponseHeaders = Cast(HttpResponseHeaders, i)
			
			If this->ResponseHeaders(HeaderIndex) <> NULL Then
				
				Dim BufferLength As Integer = Any
				Dim wBuffer As WString Ptr = KnownResponseHeaderToString( _
					HeaderIndex, _
					@BufferLength _
				)
				
				IArrayStringWriter_WriteLengthString( _
					pIWriter, _
					wBuffer, _
					BufferLength _
				)
				IArrayStringWriter_WriteLengthString( _
					pIWriter, _
					@ColonWithSpaceString, _
					Len(ColonWithSpaceString) _
				)
				IArrayStringWriter_WriteStringLine( _
					pIWriter, _
					this->ResponseHeaders(HeaderIndex) _
				)
			End If
			
		Next
		
		IArrayStringWriter_WriteNewLine(pIWriter)
		
		IArrayStringWriter_GetLength(pIWriter, @this->ResponseHeaderLineLength)
		
	End Scope
	
	IArrayStringWriter_Release(pIWriter)
	
	#if __FB_DEBUG__
	Scope
		Dim vtResponse As VARIANT = Any
		vtResponse.vt = VT_BSTR
		vtResponse.bstrVal = SysAllocString(HeadersBuffer)
		LogWriteEntry( _
			LogEntryType.Debug, _
			NULL, _
			@vtResponse _
		)
		VariantClear(@vtResponse)
	End Scope
	#endif
	
	this->ResponseHeaderLine = IMalloc_Alloc( _
		this->pIMemoryAllocator, _
		this->ResponseHeaderLineLength _
	)
	If this->ResponseHeaderLine = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	WideCharToMultiByte( _
		CP_ACP, _
		0, _
		@HeadersBuffer, _
		this->ResponseHeaderLineLength, _
		this->ResponseHeaderLine, _
		this->ResponseHeaderLineLength, _
		0, _
		0 _
	)
	
	Return S_OK
	
End Function


Function IServerResponseQueryInterface( _
		ByVal this As IServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ServerResponseQueryInterface(ContainerOf(this, ServerResponse, lpVtbl), riid, ppvObject)
End Function

Function IServerResponseAddRef( _
		ByVal this As IServerResponse Ptr _
	)As ULONG
	Return ServerResponseAddRef(ContainerOf(this, ServerResponse, lpVtbl))
End Function

Function IServerResponseRelease( _
		ByVal this As IServerResponse Ptr _
	)As ULONG
	Return ServerResponseRelease(ContainerOf(this, ServerResponse, lpVtbl))
End Function

Function IServerResponseGetHttpVersion( _
		ByVal this As IServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	Return ServerResponseGetHttpVersion(ContainerOf(this, ServerResponse, lpVtbl), pHttpVersion)
End Function

Function IServerResponseSetHttpVersion( _
		ByVal this As IServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT
	Return ServerResponseSetHttpVersion(ContainerOf(this, ServerResponse, lpVtbl), HttpVersion)
End Function

Function IServerResponseGetStatusCode( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT
	Return ServerResponseGetStatusCode(ContainerOf(this, ServerResponse, lpVtbl), pStatusCode)
End Function

Function IServerResponseSetStatusCode( _
		ByVal this As IServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT
	Return ServerResponseSetStatusCode(ContainerOf(this, ServerResponse, lpVtbl), StatusCode)
End Function

Function IServerResponseGetStatusDescription( _
		ByVal this As IServerResponse Ptr, _
		ByVal ppStatusDescription As HeapBSTR Ptr _
	)As HRESULT
	Return ServerResponseGetStatusDescription(ContainerOf(this, ServerResponse, lpVtbl), ppStatusDescription)
End Function

Function IServerResponseSetStatusDescription( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusDescription As HeapBSTR _
	)As HRESULT
	Return ServerResponseSetStatusDescription(ContainerOf(this, ServerResponse, lpVtbl), pStatusDescription)
End Function

Function IServerResponseGetKeepAlive( _
		ByVal this As IServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetKeepAlive(ContainerOf(this, ServerResponse, lpVtbl), pKeepAlive)
End Function

Function IServerResponseSetKeepAlive( _
		ByVal this As IServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	Return ServerResponseSetKeepAlive(ContainerOf(this, ServerResponse, lpVtbl), KeepAlive)
End Function

Function IServerResponseGetSendOnlyHeaders( _
		ByVal this As IServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetSendOnlyHeaders(ContainerOf(this, ServerResponse, lpVtbl), pSendOnlyHeaders)
End Function

Function IServerResponseSetSendOnlyHeaders( _
		ByVal this As IServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT
	Return ServerResponseSetSendOnlyHeaders(ContainerOf(this, ServerResponse, lpVtbl), SendOnlyHeaders)
End Function

Function IServerResponseGetMimeType( _
		ByVal this As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	Return ServerResponseGetMimeType(ContainerOf(this, ServerResponse, lpVtbl), pMimeType)
End Function

Function IServerResponseSetMimeType( _
		ByVal this As IServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	Return ServerResponseSetMimeType(ContainerOf(this, ServerResponse, lpVtbl), pMimeType)
End Function

Function IServerResponseGetHttpHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	Return ServerResponseGetHttpHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, ppHeader)
End Function

Function IServerResponseSetHttpHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As HeapBSTR _
	)As HRESULT
	Return ServerResponseSetHttpHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, pHeader)
End Function

Function IServerResponseGetZipEnabled( _
		ByVal this As IServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT
	Return ServerResponseGetZipEnabled(ContainerOf(this, ServerResponse, lpVtbl), pZipEnabled)
End Function

Function IServerResponseSetZipEnabled( _
		ByVal this As IServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT
	Return ServerResponseSetZipEnabled(ContainerOf(this, ServerResponse, lpVtbl), ZipEnabled)
End Function

Function IServerResponseGetZipMode( _
		ByVal this As IServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	Return ServerResponseGetZipMode(ContainerOf(this, ServerResponse, lpVtbl), pZipMode)
End Function

Function IServerResponseSetZipMode( _
		ByVal this As IServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	Return ServerResponseSetZipMode(ContainerOf(this, ServerResponse, lpVtbl), ZipMode)
End Function

Function IServerResponseAddResponseHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderName As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddResponseHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderName, Value)
End Function

Function IServerResponseAddKnownResponseHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, Value)
End Function

Function IServerResponseAddKnownResponseHeaderWstr( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeaderWstr(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, Value)
End Function

Function IServerResponseAddKnownResponseHeaderWstrLen( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As HeapBSTR, _
		ByVal Length As Integer _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeaderWstrLen(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, Value, Length)
End Function

Function IServerResponseGetTextWriter( _
		ByVal this As IServerResponse Ptr, _
		ByVal ppIWriter As IHttpWriter Ptr Ptr _
	)As HRESULT
	Return ServerResponseGetTextWriter(ContainerOf(this, ServerResponse, lpVtbl), ppIWriter)
End Function

Function IServerResponseSetTextWriter( _
		ByVal this As IServerResponse Ptr, _
		ByVal pIWriter As IHttpWriter Ptr _
	)As HRESULT
	Return ServerResponseSetTextWriter(ContainerOf(this, ServerResponse, lpVtbl), pIWriter)
End Function

Function IServerResponseBeginWriteResponse( _
		ByVal this As IServerResponse Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return ServerResponseBeginWriteResponse(ContainerOf(this, ServerResponse, lpVtbl), StateObject, ppIAsyncResult)
End Function

Function IServerResponseEndWriteResponse( _
		ByVal this As IServerResponse Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return ServerResponseEndWriteResponse(ContainerOf(this, ServerResponse, lpVtbl), pIAsyncResult)
End Function

Function IServerResponsePrepare( _
		ByVal this As IServerResponse Ptr, _
		ByVal ContentLength As LongInt _
	)As HRESULT
	Return ServerResponsePrepare(ContainerOf(this, ServerResponse, lpVtbl), ContentLength)
End Function

Dim GlobalServerResponseVirtualTable As Const IServerResponseVirtualTable = Type( _
	@IServerResponseQueryInterface, _
	@IServerResponseAddRef, _
	@IServerResponseRelease, _
	@IServerResponseGetHttpVersion, _
	@IServerResponseSetHttpVersion, _
	@IServerResponseGetStatusCode, _
	@IServerResponseSetStatusCode, _
	@IServerResponseGetStatusDescription, _
	@IServerResponseSetStatusDescription, _
	@IServerResponseGetKeepAlive, _
	@IServerResponseSetKeepAlive, _
	@IServerResponseGetSendOnlyHeaders, _
	@IServerResponseSetSendOnlyHeaders, _
	@IServerResponseGetMimeType, _
	@IServerResponseSetMimeType, _
	@IServerResponseGetHttpHeader, _
	@IServerResponseSetHttpHeader, _
	@IServerResponseGetZipEnabled, _
	@IServerResponseSetZipEnabled, _
	@IServerResponseGetZipMode, _
	@IServerResponseSetZipMode, _
	@IServerResponseAddResponseHeader, _
	@IServerResponseAddKnownResponseHeader, _
	@IServerResponseAddKnownResponseHeaderWstr, _
	@IServerResponseAddKnownResponseHeaderWstrLen, _
	@IServerResponseGetTextWriter, _
	@IServerResponseSetTextWriter, _
	@IServerResponseBeginWriteResponse, _
	@IServerResponseEndWriteResponse, _
	@IServerResponsePrepare _
)
