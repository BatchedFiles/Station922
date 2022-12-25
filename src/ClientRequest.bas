#include once "ClientRequest.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "ClientUri.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "HeapBSTR.bi"

Extern GlobalClientRequestVirtualTable As Const IClientRequestVirtualTable

Const GzipString = WStr("gzip")
Const DeflateString = WStr("deflate")
Const BytesString = WStr("bytes")
Const CloseString = WStr("Close")
Const KeepAliveString = WStr("Keep-Alive")

Type _ClientRequest
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IClientRequestVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pClientURI As IClientUri Ptr
	
	pHttpMethod As HeapBSTR
	HttpVersion As HttpVersions
	ContentLength As LongInt
	
	RequestByteRange As ByteRange
	RequestHeaders(0 To HttpRequestHeadersMaximum - 1) As HeapBSTR
	RequestZipModes(0 To HttpZipModesMaximum - 1) As Boolean
	KeepAlive As Boolean
End Type

Function ClientRequestParseRequestedLine( _
		ByVal this As ClientRequest Ptr, _
		ByVal RequestedLine As HeapBSTR _
	)As HRESULT
	
	' Метод, запрошенный ресурс и версия протокола
	
	If SysStringLen(RequestedLine) = 0 Then
		Return CLIENTREQUEST_E_BADREQUEST
	End If
	
	Dim pFirstChar As WString Ptr = RequestedLine
	
	Dim FirstChar As Integer = pFirstChar[0]
	If FirstChar = Characters.WhiteSpace Then
		Return CLIENTREQUEST_E_BADREQUEST
	End If
	
	' Первый пробел
	Dim pSpace As WString Ptr = StrChrW( _
		pFirstChar, _
		Characters.WhiteSpace _
	)
	If pSpace = NULL Then
		Return CLIENTREQUEST_E_BADREQUEST
	End If
	
	' Verb
	Scope
		Dim pVerb As WString Ptr = pFirstChar
		
		Dim VerbLength As Integer = pSpace - pVerb
		this->pHttpMethod = CreateHeapStringLen( _
			this->pIMemoryAllocator, _
			pVerb, _
			VerbLength _
		)
	End Scope
	
	' Uri
	Scope
		Dim hrCreateUri As HRESULT = CreateInstance( _
			this->pIMemoryAllocator, _
			@CLSID_CLIENTURI, _
			@IID_IClientUri, _
			@this->pClientURI _
		)
		If FAILED(hrCreateUri) Then
			Return hrCreateUri
		End If
		
		' Найти начало непробела
		Do
			pSpace += 1
		Loop While pSpace[0] = Characters.WhiteSpace
		
		' Здесь начинается Url
		Dim pUri As WString Ptr = pSpace
		
		' Второй пробел
		Dim bstrUri As HeapBSTR = Any
		pSpace = StrChrW( _
			pSpace, _
			Characters.WhiteSpace _
		)
		If pSpace = NULL Then
			bstrUri = CreateHeapString( _
				this->pIMemoryAllocator, _
				pUri _
			)
		Else
			Dim UriLength As Integer = pSpace - pUri
			bstrUri = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pUri, _
				UriLength _
			)
		End If
		
		Dim hrUriFromString As HRESULT = IClientUri_UriFromString( _
			this->pClientURI, _
			bstrUri _
		)
		HeapSysFreeString(bstrUri)
		
		If FAILED(hrUriFromString) Then
			Return hrUriFromString
		End If
		
	End Scope
	
	' Version
	Scope
		If pSpace = NULL Then
			this->HttpVersion = HttpVersions.Http09
		Else
			' Найти начало непробела
			Do
				pSpace += 1
			Loop While pSpace[0] = Characters.WhiteSpace
			
			Dim pVersion As WString Ptr = pSpace
			
			' Третий пробел
			pSpace = StrChrW( _
				pSpace, _
				Characters.WhiteSpace _
			)
			If pSpace Then
				' Слишком много пробелов
				Return CLIENTREQUEST_E_BADREQUEST
			End If
			
			Dim bstrVersion As HeapBSTR = CreateHeapString( _
				this->pIMemoryAllocator, _
				pVersion _
			)
			
			Dim GetHttpVersionResult As Boolean = GetHttpVersionIndex( _
				bstrVersion, _
				@this->HttpVersion _
			)
			HeapSysFreeString(bstrVersion)
			
			If GetHttpVersionResult = False Then
				Return CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
			End If
			
			If this->HttpVersion = HttpVersions.Http11 Then
				this->KeepAlive = True ' Для версии 1.1 это по умолчанию
			End If
			
		End If
	End Scope
	
	Return S_OK
	
End Function

Function ClientRequestAddRequestHeader( _
		ByVal this As ClientRequest Ptr, _
		ByVal Header As WString Ptr, _
		ByVal Value As HeapBSTR _
	)As Boolean
	
	Dim HeaderIndex As HttpRequestHeaders = Any
	Dim Finded As Boolean = GetKnownRequestHeaderIndex( _
		Header, _
		@HeaderIndex _
	)
	If Finded = False Then
		' TODO Добавить в нераспознанные заголовки запроса
		HeapSysFreeString(Value)
		Return False
	End If
	
	this->RequestHeaders(HeaderIndex) = Value
	
	Return True
	
End Function

Function ClientRequestAddRequestHeaders( _
		ByVal this As ClientRequest Ptr, _
		ByVal pIReader As IHttpReader Ptr _
	)As HRESULT
	
	Do
		Dim pLine As HeapBSTR = Any
		Dim hrReadLine As HRESULT = IHttpReader_ReadLine( _
			pIReader, _
			@pLine _
		)
		If FAILED(hrReadLine) Then
			Return hrReadLine
		End If
		
		Dim LineLength As Integer = SysStringLen(pLine)
		If LineLength = 0 Then
			HeapSysFreeString(pLine)
			Return S_OK
		End If
		
		Dim pColon As WString Ptr = StrChrW(pLine, Characters.Colon)
		
		If pColon Then
			pColon[0] = 0
			
			Dim pwszValue As WString Ptr = @pColon[0]
			
			Do
				pwszValue += 1
			Loop While pwszValue[0] = Characters.WhiteSpace
			
			Dim pNullChar As WString Ptr = @pLine[LineLength]
			Dim ValueLength As Integer = pNullChar - pwszValue
			Dim Value As HeapBSTR = CreateHeapStringLen( _
				this->pIMemoryAllocator, _
				pwszValue, _
				ValueLength _
			)
			ClientRequestAddRequestHeader(this, pLine, Value)
			
		End If
		
		HeapSysFreeString(pLine)
	Loop
	
End Function

Sub ReplaceUtcToGmt( _
		ByVal pSource As WString Ptr, _
		ByVal SourceLength As Integer _
	)
	
	Const UTC = WStr("UTC")
	Const GMT = WStr("GMT")
	
	Dim UtcLength As Integer = Len(UTC)
	Dim GmtLength As Integer = Len(GMT)
	
	Dim pUTC As WString Ptr = FindStringW( _
		pSource, _
		SourceLength, _
		@UTC, _
		UtcLength _
	)
	
	Dim GmtBytes As Integer = GmtLength * SizeOf(WString)
	If pUTC Then
		CopyMemory( _
			pUTC, _
			@GMT, _
			GmtBytes _
		)
	End If
	
End Sub

Function ClientRequestParseRequestHeaders( _
		ByVal this As ClientRequest Ptr _
	)As HRESULT
	
	Scope
		Dim pSource As WString Ptr = this->RequestHeaders(HttpRequestHeaders.HeaderConnection)
		If pSource Then
			Dim SourceLength As Integer = SysStringLen(this->RequestHeaders(HttpRequestHeaders.HeaderConnection))
			Dim pCloseString As WString Ptr = FindStringIW( _
				pSource, _
				SourceLength, _
				@CloseString, _
				Len(CloseString) _
			)
			If pCloseString Then
				this->KeepAlive = False
			Else
				Dim pKeepAliveString As WString Ptr = FindStringIW( _
					pSource, _
					SourceLength, _
					@KeepAliveString, _
					Len(KeepAliveString) _
				)
				If pKeepAliveString Then
					this->KeepAlive = True
				End If
			End If
		End If
		
		HeapSysFreeString(this->RequestHeaders(HttpRequestHeaders.HeaderConnection))
		this->RequestHeaders(HttpRequestHeaders.HeaderConnection) = NULL
	End Scope
	
	Scope
		Dim pSource As WString Ptr = this->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding)
		If pSource Then
			Dim SourceLength As Integer = SysStringLen(this->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding))
			Dim pGzipString As PCWSTR = FindStringIW( _
				pSource, _
				SourceLength, _
				@GzipString, _
				Len(GzipString) _
			)
			If pGzipString Then
				this->RequestZipModes(ZipModes.GZip) = True
			End If
			
			Dim pDeflateString As PCWSTR = FindStringIW( _
				pSource, _
				SourceLength, _
				@DeflateString, _
				Len(DeflateString) _
			)
			If pDeflateString Then
				this->RequestZipModes(ZipModes.Deflate) = True
			End If
		End If
		
		HeapSysFreeString(this->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding))
		this->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding) = NULL
	End Scope
	
	Scope
		Scope
			Dim pSource As WString Ptr = this->RequestHeaders(HttpRequestHeaders.HeaderIfModifiedSince)
			If pSource Then
				Dim SourceLength As Integer = SysStringLen(this->RequestHeaders(HttpRequestHeaders.HeaderIfModifiedSince))
				ReplaceUtcToGmt(pSource, SourceLength)
			End If
		End Scope
		
		Scope
			Dim pSource As WString Ptr = this->RequestHeaders(HttpRequestHeaders.HeaderIfUnModifiedSince)
			If pSource Then
				Dim SourceLength As Integer = SysStringLen(this->RequestHeaders(HttpRequestHeaders.HeaderIfUnModifiedSince))
				ReplaceUtcToGmt(pSource, SourceLength)
			End If
		End Scope
		
		/'
		Dim wSeparator As WString Ptr = StrChrW( _
			pHeaderIfUnModifiedSince, _
			Characters.Semicolon _
		)
		If wSeparator Then
			wSeparator[0] = 0
		End If
		'/
	End Scope
	
	Scope
		Const BytesEqualString = WStr("bytes=")
		
		Dim pwszHeaderRange As WString Ptr = this->RequestHeaders(HttpRequestHeaders.HeaderRange)
		If pwszHeaderRange Then
			Dim HeaderRangeLength As Integer = SysStringLen( _
				this->RequestHeaders(HttpRequestHeaders.HeaderRange) _
			)
			
			' TODO Обрабатывать несколько байтовых диапазонов
			/'
			Dim pCommaChar As WString Ptr = StrChrW(pwszHeaderRange, Characters.Comma)
			If pCommaChar Then
				pCommaChar[0] = 0
			End If
			'/
			
			Dim pwszBytesString As WString Ptr = FindStringW( _
				pwszHeaderRange, _
				HeaderRangeLength, _
				@BytesEqualString, _
				Len(BytesEqualString) _
			)
			If pwszBytesString = pwszHeaderRange Then
				Dim wStartIntegerData As WString Ptr = @pwszHeaderRange[Len(BytesEqualString)]
				
				Dim wStartIndex As WString Ptr = wStartIntegerData
				
				Dim wHyphenMinusChar As WString Ptr = StrChrW( _
					wStartIndex, _
					Characters.HyphenMinus _
				)
				If wHyphenMinusChar Then
					wHyphenMinusChar[0] = 0
					
					Dim wEndIndex As WString Ptr = @wHyphenMinusChar[1]
					
					Dim FirstConverted As BOOL = StrToInt64ExW( _
						wStartIndex, _
						STIF_DEFAULT, _
						@this->RequestByteRange.FirstBytePosition _
					)
					If FirstConverted Then
						this->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet
					End If
					
					Dim LastConverted As BOOL = StrToInt64ExW( _
						wEndIndex, _
						STIF_DEFAULT, _
						@this->RequestByteRange.LastBytePosition _
					)
					If LastConverted Then
						If this->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet Then
							this->RequestByteRange.IsSet = ByteRangeIsSet.FirstAndLastPositionIsSet
						Else
							this->RequestByteRange.IsSet = ByteRangeIsSet.LastBytePositionIsSet
						End If
					End If
					
				End If
				
			End If
			
		End If
		
		HeapSysFreeString(this->RequestHeaders(HttpRequestHeaders.HeaderRange))
		this->RequestHeaders(HttpRequestHeaders.HeaderRange) = NULL
	End Scope
	
	Scope
		Dim HeaderContentLength As Integer = SysStringLen( _
			this->RequestHeaders(HttpRequestHeaders.HeaderContentLength) _
		)
		If HeaderContentLength Then
			StrToInt64ExW( _
				this->RequestHeaders(HttpRequestHeaders.HeaderContentLength), _
				STIF_DEFAULT, _
				@this->ContentLength _
			)
		End If
		
		HeapSysFreeString(this->RequestHeaders(HttpRequestHeaders.HeaderContentLength))
		this->RequestHeaders(HttpRequestHeaders.HeaderContentLength) = NULL
	End Scope
	
	Scope
		/'
		' TODO Найти правильный заголовок Host в зависимости от версии 1.0 или 1.1
		Dim HeaderHost As HeapBSTR = Any
		If HttpMethod = HttpMethods.HttpConnect Then
			' HeaderHost = ClientURI.Authority.Host
			IClientUri_GetHost(ClientURI, HeaderHost)
		Else
			IClientRequest_GetHttpHeader(pIRequest, HttpRequestHeaders.HeaderHost, @HeaderHost)
		End If
		'/
		
		Dim HeaderHostLength As Integer = SysStringLen( _
			this->RequestHeaders(HttpRequestHeaders.HeaderHost) _
		)
		If HeaderHostLength = 0 Then
			If this->HttpVersion = HttpVersions.Http11 Then
				Return CLIENTREQUEST_E_BADHOST
			Else
				Dim pHost As HeapBSTR = Any
				IClientUri_GetHost(this->pClientURI, @pHost)
				Dim ClientUriHostLength As Integer = SysStringLen( _
					pHost _
				)
				If ClientUriHostLength = 0 Then
					Return CLIENTREQUEST_E_BADHOST
				End If
				
				LET_HEAPSYSSTRING( _
					this->RequestHeaders(HttpRequestHeaders.HeaderHost), _
					pHost _
				)
			End If
		End If
	End Scope
	
	Return S_OK
	
End Function

Sub InitializeClientRequest( _
		ByVal this As ClientRequest Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_CLIENTREQUEST), _
			Len(ClientRequest.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalClientRequestVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pClientURI = NULL
	
	this->pHttpMethod = NULL
	this->HttpVersion = HttpVersions.Http11
	this->ContentLength = 0
	
	this->RequestByteRange.FirstBytePosition = 0
	this->RequestByteRange.LastBytePosition = 0
	this->RequestByteRange.IsSet = ByteRangeIsSet.NotSet
	
	ZeroMemory(@this->RequestHeaders(0), HttpRequestHeadersMaximum * SizeOf(HeapBSTR))
	ZeroMemory(@this->RequestZipModes(0), HttpZipModesMaximum * SizeOf(Boolean))
	this->KeepAlive = False
	
End Sub

Sub UnInitializeClientRequest( _
		ByVal this As ClientRequest Ptr _
	)
	
	If this->pClientURI Then
		IClientUri_Release(this->pClientURI)
	End If
	
	HeapSysFreeString(this->pHttpMethod)
	
	For i As Integer = 0 To HttpRequestHeadersMaximum - 1
		HeapSysFreeString(this->RequestHeaders(i))
	Next
	
End Sub

Sub ClientRequestCreated( _
		ByVal this As ClientRequest Ptr _
	)
	
End Sub

Function CreateClientRequest( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ClientRequest Ptr
	
	Dim this As ClientRequest Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ClientRequest) _
	)
	
	If this Then
		
		InitializeClientRequest( _
			this, _
			pIMemoryAllocator _
		)
		
		ClientRequestCreated(this)
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub ClientRequestDestroyed( _
		ByVal this As ClientRequest Ptr _
	)
	
End Sub

Sub DestroyClientRequest( _
		ByVal this As ClientRequest Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeClientRequest(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	ClientRequestDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ClientRequestQueryInterface( _
		ByVal this As ClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IClientRequest, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ClientRequestAddRef(this)
	
	Return S_OK
	
End Function

Function ClientRequestAddRef( _
		ByVal this As ClientRequest Ptr _
	)As ULONG
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function ClientRequestRelease( _
		ByVal this As ClientRequest Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyClientRequest(this)
	
	Return 0
	
End Function

Function ClientRequestParse( _
		ByVal this As ClientRequest Ptr, _
		ByVal pIReader As IHttpReader Ptr, _
		ByVal RequestedLine As HeapBSTR _
	)As HRESULT
	
	Dim hrParseRequestedLine As HRESULT = ClientRequestParseRequestedLine( _
		this, _
		RequestedLine _
	)
	If FAILED(hrParseRequestedLine) Then
		Return hrParseRequestedLine
	End If
	
	Dim hrAddHeaders As HRESULT = ClientRequestAddRequestHeaders( _
		this, _
		pIReader _
	)
	If FAILED(hrAddHeaders) Then
		Return hrAddHeaders
	End If
	
	Dim hrParseHeaders As HRESULT = ClientRequestParseRequestHeaders(this)
	If FAILED(hrParseHeaders) Then
		Return hrParseHeaders
	End If
	
	Return S_OK
	
End Function

Function ClientRequestGetHttpMethod( _
		ByVal this As ClientRequest Ptr, _
		ByVal ppHttpMethod As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString( _
		this->pHttpMethod _
	)
	
	*ppHttpMethod = this->pHttpMethod
	
	Return S_OK
	
End Function

Function ClientRequestGetUri( _
		ByVal this As ClientRequest Ptr, _
		ByVal ppUri As IClientUri Ptr Ptr _
	)As HRESULT
	
	If this->pClientURI Then
		IClientUri_AddRef(this->pClientURI)
	End If
	
	*ppUri = this->pClientURI
	
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
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString( _
		this->RequestHeaders(HeaderIndex) _
	)
	
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


Function IClientRequestQueryInterface( _
		ByVal this As IClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return ClientRequestQueryInterface(ContainerOf(this, ClientRequest, lpVtbl), riid, ppvObject)
End Function

Function IClientRequestAddRef( _
		ByVal this As IClientRequest Ptr _
	)As ULONG
	Return ClientRequestAddRef(ContainerOf(this, ClientRequest, lpVtbl))
End Function

Function IClientRequestRelease( _
		ByVal this As IClientRequest Ptr _
	)As ULONG
	Return ClientRequestRelease(ContainerOf(this, ClientRequest, lpVtbl))
End Function

Function IClientRequestParse( _
		ByVal this As IClientRequest Ptr, _
		ByVal pIReader As IHttpReader Ptr, _
		ByVal RequestedLine As HeapBSTR _
	)As HRESULT
	Return ClientRequestParse(ContainerOf(this, ClientRequest, lpVtbl), pIReader, RequestedLine)
End Function

Function IClientRequestGetHttpMethod( _
		ByVal this As IClientRequest Ptr, _
		ByVal ppHttpMethod As HeapBSTR Ptr _
	)As HRESULT
	Return ClientRequestGetHttpMethod(ContainerOf(this, ClientRequest, lpVtbl), ppHttpMethod)
End Function

Function IClientRequestGetUri( _
		ByVal this As IClientRequest Ptr, _
		ByVal ppUri As IClientUri Ptr Ptr _
	)As HRESULT
	Return ClientRequestGetUri(ContainerOf(this, ClientRequest, lpVtbl), ppUri)
End Function

Function IClientRequestGetHttpVersion( _
		ByVal this As IClientRequest Ptr, _
		ByVal pHttpVersions As HttpVersions Ptr _
	)As HRESULT
	Return ClientRequestGetHttpVersion(ContainerOf(this, ClientRequest, lpVtbl), pHttpVersions)
End Function

Function IClientRequestGetHttpHeader( _
		ByVal this As IClientRequest Ptr, _
		ByVal HeaderIndex As HttpRequestHeaders, _
		ByVal ppHeader As HeapBSTR Ptr _
	)As HRESULT
	Return ClientRequestGetHttpHeader(ContainerOf(this, ClientRequest, lpVtbl), HeaderIndex, ppHeader)
End Function

Function IClientRequestGetKeepAlive( _
		ByVal this As IClientRequest Ptr, _
		ByVal pKeepAlive As Boolean Ptr _
	)As HRESULT
	Return ClientRequestGetKeepAlive(ContainerOf(this, ClientRequest, lpVtbl), pKeepAlive)
End Function

Function IClientRequestGetContentLength( _
		ByVal this As IClientRequest Ptr, _
		ByVal pContentLength As LongInt Ptr _
	)As HRESULT
	Return ClientRequestGetContentLength(ContainerOf(this, ClientRequest, lpVtbl), pContentLength)
End Function

Function IClientRequestGetByteRange( _
		ByVal this As IClientRequest Ptr, _
		ByVal pRange As ByteRange Ptr _
	)As HRESULT
	Return ClientRequestGetByteRange(ContainerOf(this, ClientRequest, lpVtbl), pRange)
End Function

Function IClientRequestGetZipMode( _
		ByVal this As IClientRequest Ptr, _
		ByVal ZipIndex As ZipModes, _
		ByVal pSupported As Boolean Ptr _
	)As HRESULT
	Return ClientRequestGetZipMode(ContainerOf(this, ClientRequest, lpVtbl), ZipIndex, pSupported)
End Function

Dim GlobalClientRequestVirtualTable As Const IClientRequestVirtualTable = Type( _
	@IClientRequestQueryInterface, _
	@IClientRequestAddRef, _
	@IClientRequestRelease, _
	@IClientRequestParse, _
	@IClientRequestGetHttpMethod, _
	@IClientRequestGetUri, _
	@IClientRequestGetHttpVersion, _
	@IClientRequestGetHttpHeader, _
	@IClientRequestGetKeepAlive, _
	@IClientRequestGetContentLength, _
	@IClientRequestGetByteRange, _
	@IClientRequestGetZipMode _
)
