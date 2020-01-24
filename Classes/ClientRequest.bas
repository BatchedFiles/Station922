#include "ClientRequest.bi"

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\shlwapi.bi"
#include "CharacterConstants.bi"
#include "ContainerOf.bi"
#include "HttpConst.bi"
#include "WebUtils.bi"

Type _ClientRequest
	Dim pClientRequestVirtualTable As IClientRequestVirtualTable Ptr
	Dim pStringableVirtualTable As IStringableVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim hHeap As HANDLE
	
	Dim RequestHeaders(HttpRequestHeadersMaximum - 1) As WString Ptr
	Dim HttpMethod As HttpMethods
	Dim ClientURI As Station922Uri
	Dim HttpVersion As HttpVersions
	Dim KeepAlive As Boolean
	Dim RequestZipModes(HttpZipModesMaximum - 1) As Boolean
	Dim RequestByteRange As ByteRange
	Dim ContentLength As LongInt
	
End Type

Declare Function AddRequestHeader( _
	ByVal this As ClientRequest Ptr, _
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
	@ClientRequestGetZipMode, _
	@ClientRequestClear _
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
		ByVal this As ClientRequest Ptr, _
		ByVal hHeap As HANDLE _
	)
	
	this->pClientRequestVirtualTable = @GlobalClientRequestVirtualTable
	this->pStringableVirtualTable = @GlobalClientRequestStringableVirtualTable
	this->ReferenceCounter = 0
	this->hHeap = hHeap
	
	ZeroMemory(@this->RequestHeaders(0), HttpRequestHeadersMaximum * SizeOf(WString Ptr))
	this->HttpMethod = HttpMethods.HttpGet
	InitializeURI(@this->ClientURI)
	this->HttpVersion = HttpVersions.Http11
	this->KeepAlive = False
	ZeroMemory(@this->RequestZipModes(0), HttpZipModesMaximum * SizeOf(Boolean))
	this->RequestByteRange.IsSet = ByteRangeIsSet.NotSet
	this->RequestByteRange.FirstBytePosition = 0
	this->RequestByteRange.LastBytePosition = 0
	this->ContentLength = 0
	
End Sub

Sub UnInitializeClientRequest( _
		ByVal this As ClientRequest Ptr _
	)
	
End Sub

Function CreateClientRequest( _
		ByVal hHeap As HANDLE _
	)As ClientRequest Ptr
	
	Dim pRequest As ClientRequest Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(ClientRequest) _
	)
	
	If pRequest = NULL Then
		Return NULL
	End If
	
	InitializeClientRequest(pRequest, hHeap)
	
	Return pRequest
	
End Function

Sub DestroyClientRequest( _
		ByVal this As ClientRequest Ptr _
	)
	
	UnInitializeClientRequest(this)
	
	HeapFree(this->hHeap, HEAP_NO_SERIALIZE, this)
	
End Sub

Function ClientRequestQueryInterface( _
		ByVal this As ClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IClientRequest, riid) Then
		*ppv = @this->pClientRequestVirtualTable
	Else
		If IsEqualIID(@IID_IStringable, riid) Then
			*ppv = @this->pStringableVirtualTable
		Else
			If IsEqualIID(@IID_IUnknown, riid) Then
				*ppv = @this->pClientRequestVirtualTable
			Else
				*ppv = NULL
				Return E_NOINTERFACE
			End If
		End If
	End If
	
	ClientRequestAddRef(this)
	
	Return S_OK
	
End Function

Function ClientRequestAddRef( _
		ByVal this As ClientRequest Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return this->ReferenceCounter
	
End Function

Function ClientRequestRelease( _
		ByVal this As ClientRequest Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter = 0 Then
		
		DestroyClientRequest(this)
		
		Return 0
	End If
	
	Return this->ReferenceCounter
	
End Function

Function ClientRequestReadRequest( _
		ByVal this As ClientRequest Ptr, _
		ByVal pIReader As IHttpReader Ptr _
	)As HRESULT
	
	Dim pRequestedLine As WString Ptr = Any
	Dim RequestedLineLength As Integer = Any
	
	Dim hrReadLine As HRESULT = IHttpReader_ReadLine( _
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
	Dim GetHttpMethodResult As Boolean = GetHttpMethod(pRequestedLine, @this->HttpMethod)
	
	If GetHttpMethodResult = False Then
		Return CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED
	End If
	
	' Здесь начинается Url
	this->ClientURI.pUrl = pSpace
	
	' Второй пробел
	pSpace = StrChr(pSpace, Characters.WhiteSpace)
	
	If pSpace <> 0 Then
		' Убрать пробел и найти начало непробела
		pSpace[0] = 0
		Do
			pSpace += 1
		Loop While pSpace[0] = Characters.WhiteSpace
		
		' Третий пробел
		If StrChr(this->ClientURI.pUrl, Characters.WhiteSpace) <> 0 Then
			' Слишком много пробелов
			Return CLIENTREQUEST_E_BADREQUEST
		End If
		
	End If
	
	Dim GetHttpVersionResult As Boolean = GetHttpVersion(pSpace, @this->HttpVersion)
	
	If GetHttpVersionResult = False Then
		Return CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
	End If
	
	Select Case this->HttpVersion
		
		Case HttpVersions.Http11
			this->KeepAlive = True ' Для версии 1.1 это по умолчанию
			
	End Select
	
	Dim ClientURILength As Integer = lstrlen(this->ClientURI.pUrl)
	
	If ClientURILength > Station922Uri.MaxUrlLength Then
		Return CLIENTREQUEST_E_URITOOLARGE
	End If
	
	' Если есть «?», значит там строка запроса
	Dim wQS As WString Ptr = StrChr(this->ClientURI.pUrl, Characters.QuestionMark)
	If wQS = 0 Then
		lstrcpy(@this->ClientURI.Path, this->ClientURI.pUrl)
	Else
		this->ClientURI.pQueryString = wQS + 1
		' Получение пути
		wQS[0] = 0 ' убрать вопросительный знак
		lstrcpy(@this->ClientURI.Path, this->ClientURI.pUrl)
		wQS[0] = Characters.QuestionMark ' вернуть, чтобы не портить Url
	End If
	
	Dim PathLength As Integer = Any
	
	If StrChr(@this->ClientURI.Path, PercentSign) = 0 Then
		PathLength = ClientURILength
	Else
		' Раскодировка пути
		Dim DecodedPath As WString * (Station922Uri.MaxUrlLength + 1) = Any
		PathLength = this->ClientURI.PathDecode(@DecodedPath)
		lstrcpy(@this->ClientURI.Path, @DecodedPath)
	End If
	
	If FAILED(ContainsBadCharSequence(@this->ClientURI.Path, PathLength)) Then
		Return CLIENTREQUEST_E_BADPATH
	End If
	
	' Получить все заголовки запроса
	Do
		Dim pLine As WString Ptr = Any ' @this->RequestHeaderBuffer[this->RequestHeaderBufferLength]
		Dim LineLength As Integer = Any
		
		hrReadLine = IHttpReader_ReadLine( _
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
		
		' this->RequestHeaderBufferLength += LineLength + 1
		
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
			
			AddRequestHeader(this, pLine, pColon)
			
		End If
		
	Loop
	
	Scope
		If StrStrI(this->RequestHeaders(HttpRequestHeaders.HeaderConnection), @CloseString) <> 0 Then
			this->KeepAlive = False
		Else
			If StrStrI(this->RequestHeaders(HttpRequestHeaders.HeaderConnection), @"Keep-Alive") <> 0 Then
				this->KeepAlive = True
			End If
		End If
			
		If StrStrI(this->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding), @GzipString) <> 0 Then
			this->RequestZipModes(ZipModes.GZip) = True
		End If
		
		If StrStrI(this->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding), @DeflateString) <> 0 Then
			this->RequestZipModes(ZipModes.Deflate) = True
		End If
			
		' Убрать UTC и заменить на GMT
		'If-Modified-Since: Thu, 24 Mar 2016 16:10:31 UTC
		'If-Modified-Since: Tue, 11 Mar 2014 20:07:57 GMT
		Dim wUTC As WString Ptr = StrStr(this->RequestHeaders(HttpRequestHeaders.HeaderIfModifiedSince), "UTC")
		
		If wUTC <> 0 Then
			lstrcpy(wUTC, "GMT")
		End If
		
		wUTC = StrStr(this->RequestHeaders(HttpRequestHeaders.HeaderIfUnModifiedSince), "UTC")
		
		If wUTC <> 0 Then
			lstrcpy(wUTC, "GMT")
		End If
		
		If lstrlen(this->RequestHeaders(HttpRequestHeaders.HeaderRange)) > 0 Then
			Dim wHeaderRange As WString Ptr = this->RequestHeaders(HttpRequestHeaders.HeaderRange)
			
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
					
					If StrToInt64Ex(wStartIndex, STIF_DEFAULT, @this->RequestByteRange.FirstBytePosition) <> 0 Then
						this->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet
					End If
					
					If StrToInt64Ex(wEndIndex, STIF_DEFAULT, @this->RequestByteRange.LastBytePosition) <> 0 Then
						
						If this->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet Then
							this->RequestByteRange.IsSet = ByteRangeIsSet.FirstAndLastPositionIsSet
						Else
							this->RequestByteRange.IsSet = ByteRangeIsSet.LastBytePositionIsSet
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
	
	Dim pHeaderContentLength As WString Ptr = this->RequestHeaders(HttpRequestHeaders.HeaderContentLength)
	
	If pHeaderContentLength <> NULL Then
		StrToInt64Ex(pHeaderContentLength, STIF_DEFAULT, @this->ContentLength)
	End If
	
	Return S_OK
	
End Function	

Function ClientRequestGetHttpMethod( _
		ByVal this As ClientRequest Ptr, _
		ByVal pHttpMethod As HttpMethods Ptr _
	)As HRESULT
	
	*pHttpMethod = this->HttpMethod
	
	Return S_OK
	
End Function

Function ClientRequestGetUri( _
		ByVal this As ClientRequest Ptr, _
		ByVal pUri As Station922Uri Ptr _
	)As HRESULT
	
	*pUri = this->ClientURI
	
	Return S_OK
	
End Function

Function ClientRequestGetHttpVersion( _
		ByVal this As ClientRequest Ptr, _
		ByVal pHttpVersion As HttpVersions Ptr _
	)As HRESULT
	
	*pHttpVersion = this->HttpVersion
	
	Return S_OK
	
End Function

Function ClientRequestGetHttpHeader( _
		ByVal this As ClientRequest Ptr, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal ppHeader As WString Ptr Ptr _
	)As HRESULT
	
	*ppHeader = this->RequestHeaders(HeaderIndex)
	
	Return S_OK
	
End Function

Function ClientRequestGetKeepAlive( _
		ByVal this As ClientRequest Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	
	*pKeepAlive = this->KeepAlive
	
	Return S_OK
End Function

Function ClientRequestGetContentLength( _
		ByVal this As ClientRequest Ptr, _
		ByVal pContentLength As LongInt Ptr _
	)As HRESULT
	
	*pContentLength = this->ContentLength
	
	Return S_OK
	
End Function

Function ClientRequestGetByteRange( _
		ByVal this As ClientRequest Ptr, _
		ByVal pRange As ByteRange Ptr _
	)As HRESULT
	
	*pRange = this->RequestByteRange
	
	Return S_OK
	
End Function

Function ClientRequestGetZipMode( _
		ByVal this As ClientRequest Ptr, _
		ByVal ZipIndex As ZipModes, _
		ByVal pSupported As Boolean Ptr _
	)As HRESULT
	
	*pSupported = this->RequestZipModes(ZipIndex)
	
	Return S_OK
	
End Function

Function ClientRequestClear( _
		ByVal this As ClientRequest Ptr _
	)As HRESULT
	
	' TODO Удалить дублирование инициализации
	ZeroMemory(@this->RequestHeaders(0), HttpRequestHeadersMaximum * SizeOf(WString Ptr))
	this->HttpMethod = HttpMethods.HttpGet
	InitializeURI(@this->ClientURI)
	this->HttpVersion = HttpVersions.Http11
	this->KeepAlive = False
	ZeroMemory(@this->RequestZipModes(0), HttpZipModesMaximum * SizeOf(Boolean))
	this->RequestByteRange.IsSet = ByteRangeIsSet.NotSet
	this->RequestByteRange.FirstBytePosition = 0
	this->RequestByteRange.LastBytePosition = 0
	this->ContentLength = 0
	
	Return S_OK
	
End Function


Function AddRequestHeader( _
		ByVal this As ClientRequest Ptr, _
		ByVal Header As WString Ptr, _
		ByVal Value As WString Ptr _
	)As Integer
	
	Dim HeaderIndex As HttpRequestHeaders = Any
	
	If GetKnownRequestHeaderIndex(Header, @HeaderIndex) = False Then
		' TODO Добавить в нераспознанные заголовки запроса
		Return -1
	End If
	
	this->RequestHeaders(HeaderIndex) = Value
	
	Return HeaderIndex
	
End Function

Function ClientRequestStringableQueryInterface( _
		ByVal pClientRequestStringable As ClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim this As ClientRequest Ptr = ContainerOf(pClientRequestStringable, ClientRequest, pStringableVirtualTable)
	
	Return ClientRequestQueryInterface( _
		this, riid, ppv _
	)
	
End Function

Function ClientRequestStringableAddRef( _
		ByVal pClientRequestStringable As ClientRequest Ptr _
	)As ULONG
	
	Dim this As ClientRequest Ptr = ContainerOf(pClientRequestStringable, ClientRequest, pStringableVirtualTable)
	
	Return ClientRequestAddRef(this)
	
End Function

Function ClientRequestStringableRelease( _
		ByVal pClientRequestStringable As ClientRequest Ptr _
	)As ULONG
	
	Dim this As ClientRequest Ptr = ContainerOf(pClientRequestStringable, ClientRequest, pStringableVirtualTable)
	
	Return ClientRequestRelease(this)
	
End Function

' TODO Реализовать ClientRequest ToString
Function ClientRequestStringableToString( _
		ByVal pClientRequestStringable As ClientRequest Ptr, _
		ByVal ppResult As WString Ptr Ptr _
	)As HRESULT
	
	Dim this As ClientRequest Ptr = ContainerOf(pClientRequestStringable, ClientRequest, pStringableVirtualTable)
	
	Return S_OK
	
End Function
