#include "ServerResponse.bi"
#include "ArrayStringWriter.bi"
#include "CharacterConstants.bi"
#include "ContainerOf.bi"
#include "IStringable.bi"
#include "StringConstants.bi"

Type _ServerResponse
	Dim pServerResponseVirtualTable As IServerResponseVirtualTable Ptr
	Dim pStringableVirtualTable As IStringableVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim hHeap As HANDLE
	
	' Буфер заголовков ответа
	Dim ResponseHeaderBuffer As WString * (MaxResponseBufferLength + 1)
	' Указатель на свободное место в буфере заголовков ответа
	Dim StartResponseHeadersPtr As WString Ptr
	' Заголовки ответа
	Dim ResponseHeaders(HttpResponseHeadersMaximum - 1) As WString Ptr
	
	Dim HttpVersion As HttpVersions
	Dim StatusCode As HttpStatusCodes
	Dim StatusDescription As WString Ptr
	
	Dim SendOnlyHeaders As Boolean
	Dim KeepAlive As Boolean
	
	' Сжатие данных, поддерживаемое сервером
	Dim ResponseZipEnable As Boolean
	Dim ResponseZipMode As ZipModes
	
	Dim Mime As MimeType
	
	Dim ResponseHeaderBufferStringable As WString * (MaxResponseBufferLength + 1)
	
End Type

Dim Shared GlobalServerResponseVirtualTable As IServerResponseVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@ServerResponseQueryInterface, _
		@ServerResponseAddRef, _
		@ServerResponseRelease _
	), _
	@ServerResponseGetHttpVersion, _
	@ServerResponseSetHttpVersion, _
	@ServerResponseGetStatusCode, _
	@ServerResponseSetStatusCode, _
	@ServerResponseGetStatusDescription, _
	@ServerResponseSetStatusDescription, _
	@ServerResponseGetKeepAlive, _
	@ServerResponseSetKeepAlive, _
	@ServerResponseGetSendOnlyHeaders, _
	@ServerResponseSetSendOnlyHeaders, _
	@ServerResponseGetMimeType, _
	@ServerResponseSetMimeType, _
	@ServerResponseGetHttpHeader, _
	@ServerResponseSetHttpHeader, _
	@ServerResponseGetZipEnabled, _
	@ServerResponseSetZipEnabled, _
	@ServerResponseGetZipMode, _
	@ServerResponseSetZipMode, _
	@ServerResponseAddResponseHeader, _
	@ServerResponseAddKnownResponseHeader, _
	@ServerResponseClear _
)

Dim Shared GlobalServerResponseStringableVirtualTable As IStringableVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@ServerResponseStringableQueryInterface, _
		@ServerResponseStringableAddRef, _
		@ServerResponseStringableRelease _
	), _
	@ServerResponseStringableToString _
)

Sub InitializeServerResponse( _
		ByVal this As ServerResponse Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	this->pServerResponseVirtualTable = @GlobalServerResponseVirtualTable
	this->pStringableVirtualTable = @GlobalServerResponseStringableVirtualTable
	this->ReferenceCounter = 0
	this->hHeap = hHeap
	
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
	
End Sub

Function CreateServerResponse( _
		ByVal hHeap As HANDLE _
	)As ServerResponse Ptr
	
	Dim pResponse As ServerResponse Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(ServerResponse) _
	)
	
	If pResponse = NULL Then
		Return NULL
	End If
	
	InitializeServerResponse(pResponse, hHeap)
	
	Return pResponse
	
End Function

Sub DestroyServerResponse( _
		ByVal this As ServerResponse Ptr _
	)
	
	UnInitializeServerResponse(this)
	
	HeapFree(this->hHeap, HEAP_NO_SERIALIZE, this)
	
End Sub

Function ServerResponseQueryInterface( _
		ByVal this As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IServerResponse, riid) Then
		*ppv = @this->pServerResponseVirtualTable
	Else
		If IsEqualIID(@IID_IStringable, riid) Then
			*ppv = @this->pStringableVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->pServerResponseVirtualTable
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
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function ServerResponseRelease( _
		ByVal this As ServerResponse Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		DestroyServerResponse(this)
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
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
	lstrcpy(this->StartResponseHeadersPtr, Value)
	
	this->ResponseHeaders(HeaderIndex) = this->StartResponseHeadersPtr
	
	this->StartResponseHeadersPtr += lstrlen(Value) + 2
	
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
		ByVal pServerResponseStringable As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As ServerResponse Ptr = ContainerOf(pServerResponseStringable, ServerResponse, pStringableVirtualTable)
	
	Return ServerResponseQueryInterface( _
		this, riid, ppv _
	)
	
End Function

Function ServerResponseStringableAddRef( _
		ByVal pServerResponseStringable As ServerResponse Ptr _
	)As ULONG
	
	Dim this As ServerResponse Ptr = ContainerOf(pServerResponseStringable, ServerResponse, pStringableVirtualTable)
	
	Return ServerResponseAddRef(this)
	
End Function

Function ServerResponseStringableRelease( _
		ByVal pServerResponseStringable As ServerResponse Ptr _
	)As ULONG
	
	Dim this As ServerResponse Ptr = ContainerOf(pServerResponseStringable, ServerResponse, pStringableVirtualTable)
	
	Return ServerResponseRelease(this)
	
End Function

Function ServerResponseStringableToString( _
		ByVal pServerResponseStringable As ServerResponse Ptr, _
		ByVal ppResult As WString Ptr Ptr _
	)As HRESULT
	
	Dim this As ServerResponse Ptr = ContainerOf(pServerResponseStringable, ServerResponse, pStringableVirtualTable)
	
	Dim HeadersWriter As ArrayStringWriter = Any
	Dim pIWriter As IArrayStringWriter Ptr = InitializeArrayStringWriterOfIArrayStringWriter(@HeadersWriter)
	
	ArrayStringWriter_NonVirtualSetBuffer(pIWriter, @this->ResponseHeaderBufferStringable, MaxResponseBufferLength)
	
	Dim HttpVersionLength As Integer = Any
	Dim pwHttpVersion As WString Ptr = HttpVersionToString(this->HttpVersion, @HttpVersionLength)
	
	ArrayStringWriter_NonVirtualWriteLengthString(pIWriter, pwHttpVersion, HttpVersionLength)
	ArrayStringWriter_NonVirtualWriteChar(pIWriter, Characters.WhiteSpace)
	ArrayStringWriter_NonVirtualWriteInt32(pIWriter, this->StatusCode)
	ArrayStringWriter_NonVirtualWriteChar(pIWriter, Characters.WhiteSpace)
	
	If this->StatusDescription = NULL Then
		Dim BufferLength As Integer = Any
		Dim wBuffer As WString Ptr = GetStatusDescription(this->StatusCode, @BufferLength)
		ArrayStringWriter_NonVirtualWriteLengthStringLine(pIWriter, wBuffer, BufferLength)
	Else
		ArrayStringWriter_NonVirtualWriteStringLine(pIWriter, this->StatusDescription)
	End If
	
	For i As Integer = 0 To HttpResponseHeadersMaximum - 1
		
		Dim HeaderIndex As HttpResponseHeaders = Any
		HeaderIndex = Cast(HttpResponseHeaders, i)
		
		If this->ResponseHeaders(HeaderIndex) <> NULL Then
			
			Dim BufferLength As Integer = Any
			Dim wBuffer As WString Ptr = KnownResponseHeaderToString(HeaderIndex, @BufferLength)
			
			ArrayStringWriter_NonVirtualWriteLengthString(pIWriter, wBuffer, BufferLength)
			ArrayStringWriter_NonVirtualWriteLengthString(pIWriter, @ColonWithSpaceString, 2)
			ArrayStringWriter_NonVirtualWriteStringLine(pIWriter, this->ResponseHeaders(HeaderIndex))
		End If
		
	Next
	
	ArrayStringWriter_NonVirtualWriteNewLine(pIWriter)
	
	ArrayStringWriter_NonVirtualRelease(pIWriter)
	
	*ppResult = @this->ResponseHeaderBufferStringable
	
	Return S_OK
	
End Function
