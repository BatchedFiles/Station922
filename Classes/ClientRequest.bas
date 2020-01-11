#include "ClientRequest.bi"

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\shlwapi.bi"
#include "CharacterConstants.bi"
#include "ContainerOf.bi"
#include "HttpConst.bi"
#include "HttpReader.bi"
#include "WebUtils.bi"

Declare Function AddRequestHeader( _
	ByVal pClientRequest As ClientRequest Ptr, _
	ByVal Header As WString Ptr, _
	ByVal Value As WString Ptr _
)As Integer

Dim Shared GlobalClientRequestVirtualTable As IClientRequestVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@ClientRequestQueryInterface, _
		@ClientRequestAddRef, _
		@ClientRequestRelease _
	), _
	@ClientRequestReadRequest, _
	@ClientRequestGetHttpMethod, _
	@ClientRequestGetUri, _
	@ClientRequestGetHttpVersion, _
	@ClientRequestGetHttpHeader, _
	@ClientRequestGetKeepAlive, _
	@ClientRequestGetContentLength, _
	@ClientRequestGetByteRange, _
	@ClientRequestGetZipMode _
)

Dim Shared GlobalClientRequestStringableVirtualTable As IStringableVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@ClientRequestStringableQueryInterface, _
		@ClientRequestStringableAddRef, _
		@ClientRequestStringableRelease _
	), _
	@ClientRequestStringableToString _
)

Sub InitializeClientRequest( _
		ByVal pClientRequest As ClientRequest Ptr _
	)
	
	pClientRequest->pClientRequestVirtualTable = @GlobalClientRequestVirtualTable
	pClientRequest->pStringableVirtualTable = @GlobalClientRequestStringableVirtualTable
	pClientRequest->ReferenceCounter = 0
	
	ZeroMemory(@pClientRequest->RequestHeaders(0), HttpRequestHeadersMaximum * SizeOf(WString Ptr))
	pClientRequest->HttpMethod = HttpMethods.HttpGet
	InitializeURI(@pClientRequest->ClientURI)
	pClientRequest->HttpVersion = HttpVersions.Http11
	pClientRequest->KeepAlive = False
	ZeroMemory(@pClientRequest->RequestZipModes(0), HttpZipModesMaximum * SizeOf(Boolean))
	pClientRequest->RequestByteRange.IsSet = ByteRangeIsSet.NotSet
	pClientRequest->RequestByteRange.FirstBytePosition = 0
	pClientRequest->RequestByteRange.LastBytePosition = 0
	pClientRequest->ContentLength = 0
	
End Sub

Sub UnInitializeClientRequest( _
		ByVal pClientRequest As ClientRequest Ptr _
	)
	
End Sub

Function CreateClientRequest( _
	)As ClientRequest Ptr
	
	Dim pRequest As ClientRequest Ptr = HeapAlloc( _
		GetProcessHeap(), _
		0, _
		SizeOf(ClientRequest) _
	)
	
	If pRequest = NULL Then
		Return NULL
	End If
	
	InitializeClientRequest(pRequest)
	
	Return pRequest
	
End Function

Sub DestroyClientRequest( _
		ByVal this As ClientRequest Ptr _
	)
	
	UnInitializeClientRequest(this)
	
	HeapFree(GetProcessHeap(), 0, this)
	
End Sub

Function ClientRequestQueryInterface( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IClientRequest, riid) Then
		*ppv = @pClientRequest->pClientRequestVirtualTable
	Else
		If IsEqualIID(@IID_IStringable, riid) Then
			*ppv = @pClientRequest->pStringableVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @pClientRequest->pClientRequestVirtualTable
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	ClientRequestAddRef(pClientRequest)
	
	Return S_OK
	
End Function

Function ClientRequestAddRef( _
		ByVal pClientRequest As ClientRequest Ptr _
	)As ULONG
	
	pClientRequest->ReferenceCounter += 1
	
	Return pClientRequest->ReferenceCounter
	
End Function

Function ClientRequestRelease( _
		ByVal pClientRequest As ClientRequest Ptr _
	)As ULONG
	
	pClientRequest->ReferenceCounter -= 1
	
	If pClientRequest->ReferenceCounter = 0 Then
		
		DestroyClientRequest(pClientRequest)
		
		Return 0
	End If
	
	Return pClientRequest->ReferenceCounter
	
End Function

Function ClientRequestReadRequest( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal pIReader As IHttpReader Ptr _
	)As HRESULT
	
	Dim pRequestedLine As WString Ptr = Any
	Dim RequestedLineLength As Integer = Any
	
	Dim hrReadLine As HRESULT = HttpReader_NonVirtualReadLine( _
		pIReader, _
		@RequestedLineLength, _
		@pRequestedLine _
	)
	
	If FAILED(hrReadLine) Then
		
		Select Case hrReadLine
			
			Case HTTPREADER_E_INTERNALBUFFEROVERFLOW
				Return CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
				
			Case HTTPREADER_E_BUFFERTOOSMALL
				Return CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
				
			Case HTTPREADER_E_SOCKETERROR
				Return CLIENTREQUEST_E_SOCKETERROR
				
			Case HTTPREADER_E_CLIENTCLOSEDCONNECTION
				Return CLIENTREQUEST_E_EMPTYREQUEST
				
		End Select
		
	End If
	
	' Метод, запрошенный ресурс и версия протокола
	' Первый пробел
	Dim pSpace As WString Ptr = StrChr(pRequestedLine, Characters.WhiteSpace)
	If pSpace = 0 Then
		Return CLIENTREQUEST_E_BADREQUEST
	End If
	
	' Удалить пробел и найти начало непробела
	pSpace[0] = 0
	Do
		pSpace += 1
	Loop While pSpace[0] = Characters.WhiteSpace
	
	' Теперь в pRequestedLine содержится имя метода
	Dim GetHttpMethodResult As Boolean = GetHttpMethod(pRequestedLine, @pClientRequest->HttpMethod)
	
	If GetHttpMethodResult = False Then
		Return CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED
	End If
	
	' Здесь начинается Url
	pClientRequest->ClientURI.pUrl = pSpace
	
	' Второй пробел
	pSpace = StrChr(pSpace, Characters.WhiteSpace)
	
	If pSpace <> 0 Then
		' Убрать пробел и найти начало непробела
		pSpace[0] = 0
		Do
			pSpace += 1
		Loop While pSpace[0] = Characters.WhiteSpace
		
		' Третий пробел
		If StrChr(pClientRequest->ClientURI.pUrl, Characters.WhiteSpace) <> 0 Then
			' Слишком много пробелов
			Return CLIENTREQUEST_E_BADREQUEST
		End If
		
	End If
	
	Dim GetHttpVersionResult As Boolean = GetHttpVersion(pSpace, @pClientRequest->HttpVersion)
	
	If GetHttpVersionResult = False Then
		Return CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
	End If
	
	Select Case pClientRequest->HttpVersion
		
		Case HttpVersions.Http11
			pClientRequest->KeepAlive = True ' Для версии 1.1 это по умолчанию
			
	End Select
	
	Dim ClientURILength As Integer = lstrlen(pClientRequest->ClientURI.pUrl)
	
	If ClientURILength > URI.MaxUrlLength Then
		Return CLIENTREQUEST_E_URITOOLARGE
	End If
	
	' Если есть «?», значит там строка запроса
	Dim wQS As WString Ptr = StrChr(pClientRequest->ClientURI.pUrl, Characters.QuestionMark)
	If wQS = 0 Then
		lstrcpy(@pClientRequest->ClientURI.Path, pClientRequest->ClientURI.pUrl)
	Else
		pClientRequest->ClientURI.pQueryString = wQS + 1
		' Получение пути
		wQS[0] = 0 ' убрать вопросительный знак
		lstrcpy(@pClientRequest->ClientURI.Path, pClientRequest->ClientURI.pUrl)
		wQS[0] = Characters.QuestionMark ' вернуть, чтобы не портить Url
	End If
	
	Dim PathLength As Integer = Any
	
	If StrChr(@pClientRequest->ClientURI.Path, PercentSign) = 0 Then
		PathLength = ClientURILength
	Else
		' Раскодировка пути
		Dim DecodedPath As WString * (URI.MaxUrlLength + 1) = Any
		PathLength = pClientRequest->ClientURI.PathDecode(@DecodedPath)
		lstrcpy(@pClientRequest->ClientURI.Path, @DecodedPath)
	End If
	
	If FAILED(ContainsBadCharSequence(@pClientRequest->ClientURI.Path, PathLength)) Then
		Return CLIENTREQUEST_E_BADPATH
	End If
	
	' Получить все заголовки запроса
	Do
		Dim pLine As WString Ptr = Any ' @pClientRequest->RequestHeaderBuffer[pClientRequest->RequestHeaderBufferLength]
		Dim LineLength As Integer = Any
		
		hrReadLine = HttpReader_NonVirtualReadLine( _
			pIReader, _
			@LineLength, _
			@pLine _
		)
		
		If FAILED(hrReadLine) Then
			
			Select Case hrReadLine
				
				Case HTTPREADER_E_INTERNALBUFFEROVERFLOW
					Return CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
					
				Case HTTPREADER_E_SOCKETERROR
					Return CLIENTREQUEST_E_SOCKETERROR
					
				Case HTTPREADER_E_CLIENTCLOSEDCONNECTION
					Return CLIENTREQUEST_E_EMPTYREQUEST
					
				Case HTTPREADER_E_BUFFERTOOSMALL
					Return CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
					
				Case Else
					Return E_FAIL
					
			End Select
			
		End If
		
		' pClientRequest->RequestHeaderBufferLength += LineLength + 1
		
		If LineLength = 0 Then
			' Клиент отправил все данные, можно приступать к обработке
			Exit Do
		End If
		
		Dim pColon As WString Ptr = StrChr(pLine, Characters.Colon)
		
		If pColon <> 0 Then
			pColon[0] = 0
			Do
				pColon += 1
			Loop While pColon[0] = Characters.WhiteSpace
			
			AddRequestHeader(pClientRequest, pLine, pColon)
			
		End If
		
	Loop
	
	Scope
		If StrStrI(pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderConnection), @CloseString) <> 0 Then
			pClientRequest->KeepAlive = False
		Else
			If StrStrI(pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderConnection), @"Keep-Alive") <> 0 Then
				pClientRequest->KeepAlive = True
			End If
		End If
			
		If StrStrI(pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding), @GzipString) <> 0 Then
			pClientRequest->RequestZipModes(ZipModes.GZip) = True
		End If
		
		If StrStrI(pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding), @DeflateString) <> 0 Then
			pClientRequest->RequestZipModes(ZipModes.Deflate) = True
		End If
			
		' Убрать UTC и заменить на GMT
		'If-Modified-Since: Thu, 24 Mar 2016 16:10:31 UTC
		'If-Modified-Since: Tue, 11 Mar 2014 20:07:57 GMT
		Dim wUTC As WString Ptr = StrStr(pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderIfModifiedSince), "UTC")
		
		If wUTC <> 0 Then
			lstrcpy(wUTC, "GMT")
		End If
		
		wUTC = StrStr(pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderIfUnModifiedSince), "UTC")
		
		If wUTC <> 0 Then
			lstrcpy(wUTC, "GMT")
		End If
		
		If lstrlen(pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderRange)) > 0 Then
			Dim wHeaderRange As WString Ptr = pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderRange)
			
			' TODO Обрабатывать несколько байтовых диапазонов
			Dim wCommaChar As WString Ptr = StrChr(wHeaderRange, Characters.Comma)
			
			If wCommaChar <> 0 Then
				wCommaChar[0] = 0
			End If
			
			Dim wStart As WString Ptr = StrStr(wHeaderRange, "bytes=")
			
			If wStart = wHeaderRange Then
				wStart = @wHeaderRange[6]
				Dim wStartIndex As WString Ptr = wStart
				
				Dim wHyphenMinusChar As WString Ptr = StrChr(wStart, Characters.HyphenMinus)
				
				If wHyphenMinusChar <> 0 Then
					wHyphenMinusChar[0] = 0
					Dim wEndIndex As WString Ptr = @wHyphenMinusChar[1]
					
					If StrToInt64Ex(wStartIndex, STIF_DEFAULT, @pClientRequest->RequestByteRange.FirstBytePosition) <> 0 Then
						pClientRequest->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet
					End If
					
					If StrToInt64Ex(wEndIndex, STIF_DEFAULT, @pClientRequest->RequestByteRange.LastBytePosition) <> 0 Then
						
						If pClientRequest->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet Then
							pClientRequest->RequestByteRange.IsSet = ByteRangeIsSet.FirstAndLastPositionIsSet
						Else
							pClientRequest->RequestByteRange.IsSet = ByteRangeIsSet.LastBytePositionIsSet
						End If
						
					End If
					
				Else
					Return CLIENTREQUEST_E_BADREQUEST
				End If
				
			Else
				Return CLIENTREQUEST_E_BADREQUEST
			End If
			
		End If
		
	End Scope
	
	Dim pHeaderContentLength As WString Ptr = pClientRequest->RequestHeaders(HttpRequestHeaders.HeaderContentLength)
	
	If pHeaderContentLength <> NULL Then
		StrToInt64Ex(pHeaderContentLength, STIF_DEFAULT, @pClientRequest->ContentLength)
	End If
	
	Return S_OK
	
End Function	

Function ClientRequestGetHttpMethod( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal pHttpMethod As HttpMethods Ptr _
	)As HRESULT
	
	*pHttpMethod = pClientRequest->HttpMethod
	
	Return S_OK
	
End Function

Function ClientRequestGetUri( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal pUri As Uri Ptr _
	)As HRESULT
	
	*pUri = pClientRequest->ClientURI
	
	Return S_OK
	
End Function

Function ClientRequestGetHttpVersion( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	
	*pHttpVersion = pClientRequest->HttpVersion
	
	Return S_OK
	
End Function

Function ClientRequestGetHttpHeader( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal ppHeader As WString Ptr Ptr _
	)As HRESULT
	
	*ppHeader = pClientRequest->RequestHeaders(HeaderIndex)
	
	Return S_OK
	
End Function

Function ClientRequestGetKeepAlive( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	*pKeepAlive = pClientRequest->KeepAlive
	
	Return S_OK
End Function

Function ClientRequestGetContentLength( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal pContentLength As LongInt Ptr _
	)As HRESULT
	
	*pContentLength = pClientRequest->ContentLength
	
	Return S_OK
	
End Function

Function ClientRequestGetByteRange( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal pRange As ByteRange Ptr _
	)As HRESULT
	
	*pRange = pClientRequest->RequestByteRange
	
	Return S_OK
	
End Function

Function ClientRequestGetZipMode( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal ZipIndex As ZipModes, _
		ByVal pSupported As Boolean Ptr _
	)As HRESULT
	
	*pSupported = pClientRequest->RequestZipModes(ZipIndex)
	
	Return S_OK
	
End Function

Function AddRequestHeader( _
		ByVal pClientRequest As ClientRequest Ptr, _
		ByVal Header As WString Ptr, _
		ByVal Value As WString Ptr _
	)As Integer
	
	Dim HeaderIndex As HttpRequestHeaders = Any
	
	If GetKnownRequestHeaderIndex(Header, @HeaderIndex) = False Then
		' TODO Добавить в нераспознанные заголовки запроса
		Return -1
	End If
	
	pClientRequest->RequestHeaders(HeaderIndex) = Value
	
	Return HeaderIndex
	
End Function

Function ClientRequestStringableQueryInterface( _
		ByVal pClientRequestStringable As ClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim pClientRequest As ClientRequest Ptr = ContainerOf(pClientRequestStringable, ClientRequest, pStringableVirtualTable)
	
	Return ClientRequestQueryInterface( _
		pClientRequest, riid, ppv _
	)
	
End Function

Function ClientRequestStringableAddRef( _
		ByVal pClientRequestStringable As ClientRequest Ptr _
	)As ULONG
	
	Dim pClientRequest As ClientRequest Ptr = ContainerOf(pClientRequestStringable, ClientRequest, pStringableVirtualTable)
	
	Return ClientRequestAddRef(pClientRequest)
	
End Function

Function ClientRequestStringableRelease( _
		ByVal pClientRequestStringable As ClientRequest Ptr _
	)As ULONG
	
	Dim pClientRequest As ClientRequest Ptr = ContainerOf(pClientRequestStringable, ClientRequest, pStringableVirtualTable)
	
	Return ClientRequestRelease(pClientRequest)
	
End Function

' TODO Реализовать ClientRequest ToString
Function ClientRequestStringableToString( _
		ByVal pClientRequestStringable As ClientRequest Ptr, _
		ByVal ppResult As WString Ptr Ptr _
	)As HRESULT
	
	Dim pClientRequest As ClientRequest Ptr = ContainerOf(pClientRequestStringable, ClientRequest, pStringableVirtualTable)
	
	Return S_OK
	
End Function
