#include "ServerResponse.bi"
#include "ArrayStringWriter.bi"
#include "CharacterConstants.bi"
#include "ContainerOf.bi"
#include "StringConstants.bi"

Extern IID_IUnknown_WithoutMinGW As Const IID

Dim Shared GlobalServerResponseVirtualTable As IServerResponseVirtualTable
Dim Shared GlobalServerResponseStringableVirtualTable As IStringableVirtualTable

Sub InitializeServerResponseVirtualTable()
	GlobalServerResponseVirtualTable.InheritedTable.QueryInterface = Cast(Any Ptr, @ServerResponseQueryInterface)
	GlobalServerResponseVirtualTable.InheritedTable.Addref = Cast(Any Ptr, @ServerResponseAddRef)
	GlobalServerResponseVirtualTable.InheritedTable.Release = Cast(Any Ptr, @ServerResponseRelease)
	GlobalServerResponseVirtualTable.GetHttpVersion = Cast(Any Ptr, @ServerResponseGetHttpVersion)
	GlobalServerResponseVirtualTable.SetHttpVersion = Cast(Any Ptr, @ServerResponseSetHttpVersion)
	GlobalServerResponseVirtualTable.GetStatusCode = Cast(Any Ptr, @ServerResponseGetStatusCode)
	GlobalServerResponseVirtualTable.SetStatusCode = Cast(Any Ptr, @ServerResponseSetStatusCode)
	GlobalServerResponseVirtualTable.GetStatusDescription = Cast(Any Ptr, @ServerResponseGetStatusDescription)
	GlobalServerResponseVirtualTable.SetStatusDescription = Cast(Any Ptr, @ServerResponseSetStatusDescription)
	GlobalServerResponseVirtualTable.GetKeepAlive = Cast(Any Ptr, @ServerResponseGetKeepAlive)
	GlobalServerResponseVirtualTable.SetKeepAlive = Cast(Any Ptr, @ServerResponseSetKeepAlive)
	GlobalServerResponseVirtualTable.GetSendOnlyHeaders = Cast(Any Ptr, @ServerResponseGetSendOnlyHeaders)
	GlobalServerResponseVirtualTable.SetSendOnlyHeaders = Cast(Any Ptr, @ServerResponseSetSendOnlyHeaders)
	GlobalServerResponseVirtualTable.GetMimeType = Cast(Any Ptr, @ServerResponseGetMimeType)
	GlobalServerResponseVirtualTable.SetMimeType = Cast(Any Ptr, @ServerResponseSetMimeType)
	GlobalServerResponseVirtualTable.GetHttpHeader = Cast(Any Ptr, @ServerResponseGetHttpHeader)
	GlobalServerResponseVirtualTable.SetHttpHeader = Cast(Any Ptr, @ServerResponseSetHttpHeader)
	GlobalServerResponseVirtualTable.GetZipEnabled = Cast(Any Ptr, @ServerResponseGetZipEnabled)
	GlobalServerResponseVirtualTable.SetZipEnabled = Cast(Any Ptr, @ServerResponseSetZipEnabled)
	GlobalServerResponseVirtualTable.GetZipMode = Cast(Any Ptr, @ServerResponseGetZipMode)
	GlobalServerResponseVirtualTable.SetZipMode = Cast(Any Ptr, @ServerResponseSetZipMode)
	GlobalServerResponseVirtualTable.AddResponseHeader = Cast(Any Ptr, @ServerResponseAddResponseHeader)
	GlobalServerResponseVirtualTable.AddKnownResponseHeader = Cast(Any Ptr, @ServerResponseAddKnownResponseHeader)
	
	GlobalServerResponseStringableVirtualTable.InheritedTable.QueryInterface = Cast(Any Ptr, @ServerResponseStringableQueryInterface)
	GlobalServerResponseStringableVirtualTable.InheritedTable.Addref = Cast(Any Ptr, @ServerResponseStringableAddRef)
	GlobalServerResponseStringableVirtualTable.InheritedTable.Release = Cast(Any Ptr, @ServerResponseStringableRelease)
	GlobalServerResponseStringableVirtualTable.ToString = Cast(Any Ptr, @ServerResponseStringableToString)
End Sub

Sub InitializeServerResponse( _
		ByVal pServerResponse As ServerResponse Ptr _
	)
	
	pServerResponse->pServerResponseVirtualTable = @GlobalServerResponseVirtualTable
	pServerResponse->pStringableVirtualTable = @GlobalServerResponseStringableVirtualTable
	pServerResponse->ReferenceCounter = 0
	
	pServerResponse->ResponseHeaderBuffer[0] = 0
	pServerResponse->StartResponseHeadersPtr = @pServerResponse->ResponseHeaderBuffer
	ZeroMemory(@pServerResponse->ResponseHeaders(0), HttpResponseHeadersMaximum * SizeOf(WString Ptr))
	pServerResponse->HttpVersion = HttpVersions.Http11
	pServerResponse->StatusCode = HttpStatusCodes.OK
	pServerResponse->StatusDescription = NULL
	pServerResponse->SendOnlyHeaders = False
	pServerResponse->KeepAlive = True
	pServerResponse->ResponseZipEnable = False
	pServerResponse->Mime.ContentType = ContentTypes.AnyAny
	pServerResponse->Mime.IsTextFormat = False
	pServerResponse->Mime.Charset = DocumentCharsets.ASCII
	
End Sub

Function InitializeServerResponseOfIServerResponse( _
		ByVal pServerResponse As ServerResponse Ptr _
	)As IServerResponse Ptr
	
	InitializeServerResponse(pServerResponse)
	pServerResponse->ExistsInStack = True
	
	Dim pIResponse As IServerResponse Ptr = Any
	
	ServerResponseQueryInterface( _
		pServerResponse, @IID_IServerResponse, @pIResponse _
	)
	
	Return pIResponse
	
End Function

Function ServerResponseQueryInterface( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IServerResponse, riid) Then
		*ppv = @pServerResponse->pServerResponseVirtualTable
	Else
		If IsEqualIID(@IID_ISTRINGABLE, riid) Then
			*ppv = @pServerResponse->pStringableVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown_WithoutMinGW, riid) Then
				*ppv = @pServerResponse->pServerResponseVirtualTable
			Else
				*ppv = 0
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	ServerResponseAddRef(pServerResponse)
	
	Return S_OK
	
End Function

Function ServerResponseAddRef( _
		ByVal pServerResponse As ServerResponse Ptr _
	)As ULONG
	
	Return InterlockedIncrement(@pServerResponse->ReferenceCounter)
	
End Function

Function ServerResponseRelease( _
		ByVal pServerResponse As ServerResponse Ptr _
	)As ULONG
	
	InterlockedDecrement(@pServerResponse->ReferenceCounter)
	
	If pServerResponse->ReferenceCounter = 0 Then
		
		' UnInitializeServerResponse(pServerResponse)
		
		If pServerResponse->ExistsInStack = False Then
		
		End If
		
		Return 0
	End If
	
	Return pServerResponse->ReferenceCounter
	
End Function

Function ServerResponseGetHttpVersion( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	
	*pHttpVersion = pServerResponse->HttpVersion
	
	Return S_OK
	
End Function

Function ServerResponseSetHttpVersion( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal HttpVersion As HttpVersions _
	)As HRESULT
	
	pServerResponse->HttpVersion = HttpVersion
	
	Return S_OK
	
End Function

Function ServerResponseGetStatusCode( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pStatusCode As HttpStatusCodes Ptr _
	)As HRESULT
	
	*pStatusCode = pServerResponse->StatusCode
	
	Return S_OK
	
End Function

Function ServerResponseSetStatusCode( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal StatusCode As HttpStatusCodes _
	)As HRESULT
	
	pServerResponse->StatusCode = StatusCode
	
	Return S_OK
	
End Function

Function ServerResponseGetStatusDescription( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal ppStatusDescription As WString Ptr Ptr _
	)As HRESULT
	
	*ppStatusDescription = pServerResponse->StatusDescription
	
	Return S_OK
	
End Function

Function ServerResponseSetStatusDescription( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pStatusDescription As WString Ptr _
	)As HRESULT
	
	pServerResponse->StatusDescription = pStatusDescription
	
	Return S_OK
	
End Function

Function ServerResponseGetKeepAlive( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	*pKeepAlive = pServerResponse->KeepAlive
	
	Return S_OK
	
End Function

Function ServerResponseSetKeepAlive( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal KeepAlive As Boolean _
	)As HRESULT
	
	pServerResponse->KeepAlive = KeepAlive
	
	Return S_OK
	
End Function

Function ServerResponseGetSendOnlyHeaders( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pSendOnlyHeaders As Boolean Ptr _
	)As HRESULT
	
	*pSendOnlyHeaders = pServerResponse->SendOnlyHeaders
	
	Return S_OK
	
End Function

Function ServerResponseSetSendOnlyHeaders( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal SendOnlyHeaders As Boolean _
	)As HRESULT
	
	pServerResponse->SendOnlyHeaders = SendOnlyHeaders
	
	Return S_OK
	
End Function

Function ServerResponseGetMimeType( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	*pMimeType = pServerResponse->Mime
	
	Return S_OK
	
End Function

Function ServerResponseSetMimeType( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pMimeType As MimeType Ptr _
	)As HRESULT
	
	pServerResponse->Mime = *pMimeType
	
	Return S_OK
	
End Function

Function ServerResponseGetHttpHeader( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal ppHeader As WString Ptr Ptr _
	)As HRESULT
	
	*ppHeader = pServerResponse->ResponseHeaders(HeaderIndex)
	
	Return S_OK
	
End Function

Function ServerResponseSetHttpHeader( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal pHeader As WString Ptr _
	)As HRESULT
	
	pServerResponse->ResponseHeaders(HeaderIndex) = pHeader
	
	Return S_OK
	
End Function

Function ServerResponseGetZipEnabled( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pZipEnabled As Boolean Ptr _
	)As HRESULT
	
	*pZipEnabled = pServerResponse->ResponseZipEnable
	
	Return S_OK
	
End Function

Function ServerResponseSetZipEnabled( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal ZipEnabled As Boolean _
	)As HRESULT
	
	pServerResponse->ResponseZipEnable = ZipEnabled
	
	Return S_OK
	
End Function

Function ServerResponseGetZipMode( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal pZipMode As ZipModes Ptr _
	)As HRESULT
	
	*pZipMode = pServerResponse->ResponseZipMode
	
	Return S_OK
	
End Function

Function ServerResponseSetZipMode( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal ZipMode As ZipModes _
	)As HRESULT
	
	pServerResponse->ResponseZipMode = ZipMode
	
	Return S_OK
	
End Function

Function ServerResponseAddResponseHeader( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal HeaderName As WString Ptr, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	Dim HeaderIndex As HttpResponseHeaders = Any
	
	If GetKnownResponseHeader(HeaderName, @HeaderIndex) Then
		Return ServerResponseAddKnownResponseHeader(pServerResponse, HeaderIndex, Value)
	End If
	
	Return S_FALSE
	
End Function

Function ServerResponseAddKnownResponseHeader( _
		ByVal pServerResponse As ServerResponse Ptr, _
		ByVal HeaderIndex As HttpResponseHeaders, _
		ByVal Value As WString Ptr _
	)As HRESULT
	
	' TODO Избежать многократного добавления заголовка
	
	' TODO Устранить переполнение буфера
	lstrcpy(pServerResponse->StartResponseHeadersPtr, Value)
	
	pServerResponse->ResponseHeaders(HeaderIndex) = pServerResponse->StartResponseHeadersPtr
	
	pServerResponse->StartResponseHeadersPtr += lstrlen(Value) + 2
	
	Return S_OK
	
End Function

Function ServerResponseStringableQueryInterface( _
		ByVal pServerResponseStringable As ServerResponse Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim pServerResponse As ServerResponse Ptr = ContainerOf(pServerResponseStringable, ServerResponse, pStringableVirtualTable)
	
	Return ServerResponseQueryInterface( _
		pServerResponse, riid, ppv _
	)
	
End Function

Function ServerResponseStringableAddRef( _
		ByVal pServerResponseStringable As ServerResponse Ptr _
	)As ULONG
	
	Dim pServerResponse As ServerResponse Ptr = ContainerOf(pServerResponseStringable, ServerResponse, pStringableVirtualTable)
	
	Return ServerResponseAddRef(pServerResponse)
	
End Function

Function ServerResponseStringableRelease( _
		ByVal pServerResponseStringable As ServerResponse Ptr _
	)As ULONG
	
	Dim pServerResponse As ServerResponse Ptr = ContainerOf(pServerResponseStringable, ServerResponse, pStringableVirtualTable)
	
	Return ServerResponseRelease(pServerResponse)
	
End Function

Function ServerResponseStringableToString( _
		ByVal pServerResponseStringable As ServerResponse Ptr, _
		ByVal ppResult As WString Ptr Ptr _
	)As HRESULT
	
	Dim pServerResponse As ServerResponse Ptr = ContainerOf(pServerResponseStringable, ServerResponse, pStringableVirtualTable)
	
	Dim HeadersWriter As ArrayStringWriter = Any
	Dim pIWriter As IArrayStringWriter Ptr = InitializeArrayStringWriterOfIArrayStringWriter(@HeadersWriter)
	
	ArrayStringWriter_NonVirtualSetBuffer(pIWriter, @pServerResponse->ResponseHeaderBufferStringable, MaxResponseBufferLength)
	
	Dim HttpVersionLength As Integer = Any
	Dim pwHttpVersion As WString Ptr = HttpVersionToString(pServerResponse->HttpVersion, @HttpVersionLength)
	
	ArrayStringWriter_NonVirtualWriteLengthString(pIWriter, pwHttpVersion, HttpVersionLength)
	ArrayStringWriter_NonVirtualWriteChar(pIWriter, Characters.WhiteSpace)
	ArrayStringWriter_NonVirtualWriteInt32(pIWriter, pServerResponse->StatusCode)
	ArrayStringWriter_NonVirtualWriteChar(pIWriter, Characters.WhiteSpace)
	
	If pServerResponse->StatusDescription = NULL Then
		Dim BufferLength As Integer = Any
		Dim wBuffer As WString Ptr = GetStatusDescription(pServerResponse->StatusCode, @BufferLength)
		ArrayStringWriter_NonVirtualWriteLengthStringLine(pIWriter, wBuffer, BufferLength)
	Else
		ArrayStringWriter_NonVirtualWriteStringLine(pIWriter, pServerResponse->StatusDescription)
	End If
	
	For i As Integer = 0 To HttpResponseHeadersMaximum - 1
		
		Dim HeaderIndex As HttpResponseHeaders = Any
		HeaderIndex = Cast(HttpResponseHeaders, i)
		
		If pServerResponse->ResponseHeaders(HeaderIndex) <> NULL Then
			
			Dim BufferLength As Integer = Any
			Dim wBuffer As WString Ptr = KnownResponseHeaderToString(HeaderIndex, @BufferLength)
			
			ArrayStringWriter_NonVirtualWriteLengthString(pIWriter, wBuffer, BufferLength)
			ArrayStringWriter_NonVirtualWriteLengthString(pIWriter, @ColonWithSpaceString, 2)
			ArrayStringWriter_NonVirtualWriteStringLine(pIWriter, pServerResponse->ResponseHeaders(HeaderIndex))
		End If
		
	Next
	
	ArrayStringWriter_NonVirtualWriteNewLine(pIWriter)
	
	ArrayStringWriter_NonVirtualRelease(pIWriter)
	
	*ppResult = @pServerResponse->ResponseHeaderBufferStringable
	
	Return S_OK
	
End Function
