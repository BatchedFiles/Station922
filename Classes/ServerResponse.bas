#include once "ServerResponse.bi"
#include once "IArrayStringWriter.bi"
#include once "IStringable.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HttpConst.bi"
#include once "ReferenceCounter.bi"
#include once "Resources.RH"
#include once "StringConstants.bi"
#include once "WebUtils.bi"

Extern GlobalServerResponseVirtualTable As Const IServerResponseVirtualTable
Extern GlobalServerResponseStringableVirtualTable As Const IStringableVirtualTable

Extern CLSID_ARRAYSTRINGWRITER Alias "CLSID_ARRAYSTRINGWRITER" As Const CLSID

Type _ServerResponse
	lpVtbl As Const IServerResponseVirtualTable Ptr
	lpStringableVtbl As Const IStringableVirtualTable Ptr
	RefCounter As ReferenceCounter
	pILogger As ILogger Ptr
	pIMemoryAllocator As IMalloc Ptr
	' Буфер заголовков ответа
	ResponseHeaderBuffer As WString * (MaxResponseBufferLength + 1)
	' Указатель на свободное место в буфере заголовков ответа
	StartResponseHeadersPtr As WString Ptr
	' Заголовки ответа
	ResponseHeaders(HttpResponseHeadersMaximum - 1) As WString Ptr
	HttpVersion As HttpVersions
	StatusCode As HttpStatusCodes
	StatusDescription As WString Ptr
	SendOnlyHeaders As Boolean
	KeepAlive As Boolean
	' Сжатие данных, поддерживаемое сервером
	ResponseZipEnable As Boolean
	ResponseZipMode As ZipModes
	Mime As MimeType
	ResponseHeaderBufferStringable As WString * (MaxResponseBufferLength + 1)
End Type

Sub InitializeServerResponse( _
		ByVal this As ServerResponse Ptr, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalServerResponseVirtualTable
	this->lpStringableVtbl = @GlobalServerResponseStringableVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	this->ResponseHeaderBuffer[0] = 0
	this->StartResponseHeadersPtr = @this->ResponseHeaderBuffer
	ZeroMemory(@this->ResponseHeaders(0), HttpResponseHeadersMaximum * SizeOf(WString Ptr))
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
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	IMalloc_Release(this->pIMemoryAllocator)
	ILogger_Release(this->pILogger)
	
End Sub

Function CreateServerResponse( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ServerResponse Ptr
	
#if __FB_DEBUG__
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = SizeOf(ServerResponse)
	ILogger_LogDebug(pILogger, WStr(!"ServerResponse creating\t"), vtAllocatedBytes)
#endif
	
	Dim this As ServerResponse Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ServerResponse) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeServerResponse(this, pILogger, pIMemoryAllocator)
	
#if __FB_DEBUG__
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(pILogger, WStr("ServerResponse created"), vtEmpty)
#endif
	
	Return this
	
End Function

Sub DestroyServerResponse( _
		ByVal this As ServerResponse Ptr _
	)
	
#if __FB_DEBUG__
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("ServerResponse destroying"), vtEmpty)
#endif
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeServerResponse(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
#if __FB_DEBUG__
	ILogger_LogDebug(pILogger, WStr("ServerResponse destroyed"), vtEmpty)
#endif
	
	IMalloc_Release(pIMemoryAllocator)
	ILogger_Release(pILogger)
	
End Sub

Function ServerResponseQueryInterface( _
		ByVal this As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IServerResponse, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IStringable, riid) Then
			*ppv = @this->lpStringableVtbl
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->lpVtbl
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	ServerResponseAddRef(this)
	
	Return S_OK
	
End Function

Function ServerResponseAddRef( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function ServerResponseRelease( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	ReferenceCounterDecrement(@this->RefCounter)
	
	If this->RefCounter.Counter = 0 Then
		
		DestroyServerResponse(this)
		
		Return 0
	End If
	
	Return 1
	
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
		ByVal ppStatusDescription As WString Ptr Ptr _
	)As HRESULT
	
	*ppStatusDescription = this->StatusDescription
	
	Return S_OK
	
End Function

Function ServerResponseSetStatusDescription( _
		ByVal this As ServerResponse Ptr, _
		ByVal pStatusDescription As WString Ptr _
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
		ByVal ppHeader As WString Ptr Ptr _
	)As HRESULT
	
	*ppHeader = this->ResponseHeaders(HeaderIndex)
	
	Return S_OK
	
End Function

Function ServerResponseSetHttpHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As WString Ptr _
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
		ByVal HeaderName As WString Ptr, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	Dim HeaderIndex As HttpResponseHeaders = Any
	
	If GetKnownResponseHeaderIndex(HeaderName, @HeaderIndex) Then
		Return ServerResponseAddKnownResponseHeader(this, HeaderIndex, Value)
	End If
	
	Return S_FALSE
	
End Function

Function ServerResponseAddKnownResponseHeader( _
		ByVal this As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	' TODO Избежать многократного добавления заголовка
	
	' TODO Устранить переполнение буфера
	lstrcpyW(this->StartResponseHeadersPtr, Value)
	
	this->ResponseHeaders(HeaderIndex) = this->StartResponseHeadersPtr
	
	this->StartResponseHeadersPtr += lstrlenW(Value) + 2
	
	Return S_OK
	
End Function

Function ServerResponseClear( _
		ByVal this As ServerResponse Ptr _
	)As HRESULT
	
	' TODO Удалить дублирование инициализации
	this->ResponseHeaderBuffer[0] = 0
	this->StartResponseHeadersPtr = @this->ResponseHeaderBuffer
	ZeroMemory(@this->ResponseHeaders(0), HttpResponseHeadersMaximum * SizeOf(WString Ptr))
	this->HttpVersion = HttpVersions.Http11
	this->StatusCode = HttpStatusCodes.OK
	this->StatusDescription = NULL
	this->SendOnlyHeaders = False
	this->KeepAlive = True
	this->ResponseZipEnable = False
	this->Mime.ContentType = ContentTypes.AnyAny
	this->Mime.IsTextFormat = False
	this->Mime.Charset = DocumentCharsets.ASCII
	
	Return S_OK
	
End Function

Function ServerResponseStringableQueryInterface( _
		ByVal this As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Return ServerResponseQueryInterface( _
		this, riid, ppv _
	)
	
End Function

Function ServerResponseStringableAddRef( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	Return ServerResponseAddRef(this)
	
End Function

Function ServerResponseStringableRelease( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	Return ServerResponseRelease(this)
	
End Function

Function ServerResponseStringableToString( _
		ByVal this As ServerResponse Ptr, _
		ByVal pLength As Integer Ptr, _
		ByVal ppResult As WString Ptr Ptr _
	)As HRESULT
	
	Dim pIWriter As IArrayStringWriter Ptr = Any
	Dim hr As HRESULT = CreateInstance( _
		this->pILogger, _
		this->pIMemoryAllocator, _
		@CLSID_ARRAYSTRINGWRITER, _
		@IID_IArrayStringWriter, _
		@pIWriter _
	)
	If FAILED(hr) Then
		Return hr
	End If
	
	If this->KeepAlive Then
		If this->HttpVersion = HttpVersions.Http10 Then
			ServerResponseAddKnownResponseHeader(this, HttpResponseHeaders.HeaderConnection, @KeepAliveString)
		End If
	Else
		ServerResponseAddKnownResponseHeader(this, HttpResponseHeaders.HeaderConnection, @CloseString)
	End If
	
	Scope
		Dim wContentType As WString * (MaxContentTypeLength + 1) = Any
		GetContentTypeOfMimeType(@wContentType, @this->Mime)
		ServerResponseAddKnownResponseHeader(this, HttpResponseHeaders.HeaderContentType, @wContentType)
	End Scope
	
	IArrayStringWriter_SetBuffer(pIWriter, @this->ResponseHeaderBufferStringable, MaxResponseBufferLength)
	
	Scope
		Dim HttpVersionLength As Integer = Any
		Dim pwHttpVersion As WString Ptr = HttpVersionToString(this->HttpVersion, @HttpVersionLength)
		
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
		
		ServerResponseAddKnownResponseHeader(this, HttpResponseHeaders.HeaderDate, @dtBuffer)
	End Scope
	
	For i As Integer = 0 To HttpResponseHeadersMaximum - 1
		
		Dim HeaderIndex As HttpResponseHeaders = Cast(HttpResponseHeaders, i)
		
		If this->ResponseHeaders(HeaderIndex) <> NULL Then
			
			Dim BufferLength As Integer = Any
			Dim wBuffer As WString Ptr = KnownResponseHeaderToString(HeaderIndex, @BufferLength)
			
			IArrayStringWriter_WriteLengthString(pIWriter, wBuffer, BufferLength)
			IArrayStringWriter_WriteLengthString(pIWriter, @ColonWithSpaceString, 2)
			IArrayStringWriter_WriteStringLine(pIWriter, this->ResponseHeaders(HeaderIndex))
		End If
		
	Next
	
	IArrayStringWriter_WriteNewLine(pIWriter)
	
	IArrayStringWriter_GetBufferLength(pIWriter, pLength)
	
	IArrayStringWriter_Release(pIWriter)
	
	*ppResult = @this->ResponseHeaderBufferStringable
	
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
		ByVal ppStatusDescription As WString Ptr Ptr _
	)As HRESULT
	Return ServerResponseGetStatusDescription(ContainerOf(this, ServerResponse, lpVtbl), ppStatusDescription)
End Function

Function IServerResponseSetStatusDescription( _
		ByVal this As IServerResponse Ptr, _
		ByVal pStatusDescription As WString Ptr _
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
		ByVal ppHeader As WString Ptr Ptr _
	)As HRESULT
	Return ServerResponseGetHttpHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, ppHeader)
End Function

Function IServerResponseSetHttpHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As WString Ptr _
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
		ByVal HeaderName As WString Ptr, _
		ByVal Value As WString Ptr _
	)As HRESULT
	Return ServerResponseAddResponseHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderName, Value)
End Function

Function IServerResponseAddKnownResponseHeader( _
		ByVal this As IServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT
	Return ServerResponseAddKnownResponseHeader(ContainerOf(this, ServerResponse, lpVtbl), HeaderIndex, Value)
End Function

Function IServerResponseClear( _
		ByVal this As IServerResponse Ptr _
	)As HRESULT
	Return ServerResponseClear(ContainerOf(this, ServerResponse, lpVtbl))
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
	@IServerResponseClear _
)

Function IServerResponseStringableQueryInterface( _
		ByVal this As IStringable Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ServerResponseStringableQueryInterface(ContainerOf(this, ServerResponse, lpStringableVtbl), riid, ppvObject)
End Function

Function IServerResponseStringableAddRef( _
		ByVal this As IStringable Ptr _
	)As ULONG
	Return ServerResponseStringableAddRef(ContainerOf(this, ServerResponse, lpStringableVtbl))
End Function

Function IServerResponseStringableRelease( _
		ByVal this As IStringable Ptr _
	)As ULONG
	Return ServerResponseStringableRelease(ContainerOf(this, ServerResponse, lpStringableVtbl))
End Function

Function IServerResponseStringableToString( _
		ByVal this As IStringable Ptr, _
		ByVal pLength As Integer Ptr, _
		ByVal ppResult As WString Ptr Ptr _
	)As HRESULT
	Return ServerResponseStringableToString(ContainerOf(this, ServerResponse, lpStringableVtbl), pLength, ppResult)
End Function

Dim GlobalServerResponseStringableVirtualTable As Const IStringableVirtualTable = Type( _
	@IServerResponseStringableQueryInterface, _
	@IServerResponseStringableAddRef, _
	@IServerResponseStringableRelease, _
	@IServerResponseStringableToString _
)
