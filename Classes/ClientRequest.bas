#include once "ClientRequest.bi"
#include once "win\shlwapi.bi"
#include once "IStringable.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "HeapBSTR.bi"
#include once "HttpConst.bi"
#include once "Logger.bi"
#include once "WebUtils.bi"

Extern GlobalClientRequestVirtualTable As Const IClientRequestVirtualTable
Extern GlobalClientRequestStringableVirtualTable As Const IStringableVirtualTable

Const MAX_CRITICAL_SECTION_SPIN_COUNT As DWORD = 4000

Type _ClientRequest
	lpVtbl As Const IClientRequestVirtualTable Ptr
	lpStringableVtbl As Const IStringableVirtualTable Ptr
	' crSection As CRITICAL_SECTION
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pIReader As ITextReader Ptr
	RequestedLine As HeapBSTR
	RequestHeaders(HttpRequestHeadersMaximum - 1) As HeapBSTR
	HttpMethod As HttpMethods
	pClientURI As Station922Uri Ptr
	HttpVersion As HttpVersions
	RequestByteRange As ByteRange
	ContentLength As LongInt
	RequestZipModes(HttpZipModesMaximum - 1) As Boolean
	KeepAlive As Boolean
End Type

Function ClientRequestAddRequestHeader( _
		ByVal this As ClientRequest Ptr, _
		ByVal Header As HeapBSTR, _
		ByVal Value As HeapBSTR _
	)As Integer
	
	Dim HeaderIndex As HttpRequestHeaders = Any
	
	If GetKnownRequestHeaderIndex(Header, @HeaderIndex) = False Then
		' TODO Добавить в нераспознанные заголовки запроса
		Return -1
	End If
	
	this->RequestHeaders(HeaderIndex) = Value
	
	Return HeaderIndex
	
End Function

Sub InitializeClientRequest( _
		ByVal this As ClientRequest Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pClientURI As Station922Uri Ptr _
	)
	
	this->lpVtbl = @GlobalClientRequestVirtualTable
	this->lpStringableVtbl = @GlobalClientRequestStringableVirtualTable
	' InitializeCriticalSectionAndSpinCount( _
		' @this->crSection, _
		' MAX_CRITICAL_SECTION_SPIN_COUNT _
	' )
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	this->pIReader = NULL
	this->RequestedLine = NULL
	ZeroMemory(@this->RequestHeaders(0), HttpRequestHeadersMaximum * SizeOf(HeapBSTR))
	this->HttpMethod = HttpMethods.HttpGet
	this->pClientURI = pClientURI
	Station922UriInitialize(this->pClientURI)
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
	
	HeapSysFreeString(this->RequestedLine)
	
	For i As Integer = 0 To HttpRequestHeadersMaximum - 1
		HeapSysFreeString(this->RequestHeaders(i))
	Next
	
	IMalloc_Free(this->pIMemoryAllocator, this->pClientURI)
	
	If this->pIReader <> NULL Then
		ITextReader_Release(this->pIReader)
	End If
	
	IMalloc_Release(this->pIMemoryAllocator)
	' DeleteCriticalSection(@this->crSection)
	
End Sub

Function CreateClientRequest( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ClientRequest Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ClientRequest)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ClientRequest creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim pClientURI As Station922Uri Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(Station922Uri) _
	)
	
	If pClientURI <> NULL Then
		Dim this As ClientRequest Ptr = IMalloc_Alloc( _
			pIMemoryAllocator, _
			SizeOf(ClientRequest) _
		)
		
		If this <> NULL Then
			
			InitializeClientRequest( _
				this, _
				pIMemoryAllocator, _
				pClientURI _
			)
			
			#if __FB_DEBUG__
			Scope
				Dim vtEmpty As VARIANT = Any
				VariantInit(@vtEmpty)
				LogWriteEntry( _
					LogEntryType.Debug, _
					WStr("ClientRequest created"), _
					@vtEmpty _
				)
			End Scope
			#endif
			
			Return this
		End If
		
		IMalloc_Free(pIMemoryAllocator, pClientURI)
	End If
	
	Return NULL
	
End Function

Sub DestroyClientRequest( _
		ByVal this As ClientRequest Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ClientRequest destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeClientRequest(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ClientRequest destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
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
	
	ClientRequestAddRef(this)
	
	Return S_OK
	
End Function

Function ClientRequestAddRef( _
		ByVal this As ClientRequest Ptr _
	)As ULONG
	
	' EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter += 1
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	Return this->ReferenceCounter
	
End Function

Function ClientRequestRelease( _
		ByVal this As ClientRequest Ptr _
	)As ULONG
	
	' EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter -= 1
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyClientRequest(this)
	
	Return 0
	
End Function

' Function ClientRequestReadRequest( _
		' ByVal this As ClientRequest Ptr _
	' )As HRESULT
	
	' Dim pRequestedLine As HeapBSTR = Any
	
	' Dim hrReadLine As HRESULT = ITextReader_ReadLine( _
		' this->pIReader, _
		' @pRequestedLine _
	' )
	
	' Return ReadRequestedLines( _
		' this, _
		' pRequestedLine, _
		' hrReadLine _
	' )
	
' End Function

Function ClientRequestBeginReadRequest( _
		ByVal this As ClientRequest Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	Const NullCallback As AsyncCallback = NULL
	
	Dim hrBeginReadLine As HRESULT = ITextReader_BeginReadLine( _
		this->pIReader, _
		NullCallback, _
		StateObject, _
		ppIAsyncResult _
	)
	If FAILED(hrBeginReadLine) Then
		Return CLIENTREQUEST_E_SOCKETERROR
	End If
	
	Return CLIENTREQUEST_S_IO_PENDING
	
End Function

Function ClientRequestEndReadRequest( _
		ByVal this As ClientRequest Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	
	Dim hrEndReadLine As HRESULT = ITextReader_EndReadLine( _
		this->pIReader, _
		pIAsyncResult, _
		@this->RequestedLine _
	)
	If FAILED(hrEndReadLine) Then
		
		Select Case hrEndReadLine
			
			Case HTTPREADER_E_INTERNALBUFFEROVERFLOW
				Return CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
				
			Case HTTPREADER_E_INSUFFICIENT_BUFFER
				Return CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
				
			Case HTTPREADER_E_SOCKETERROR
				Return CLIENTREQUEST_E_SOCKETERROR
				
			Case HTTPREADER_E_CLIENTCLOSEDCONNECTION
				Return CLIENTREQUEST_E_EMPTYREQUEST
				
			Case Else
				Return hrEndReadLine
				
		End Select
	End If
	
	Select Case hrEndReadLine
		
		Case TEXTREADER_S_IO_PENDING
			Return CLIENTREQUEST_S_IO_PENDING
			
		Case S_FALSE
			Return S_FALSE
			
		Case Else
			Return S_OK
			
	End Select
	
End Function

Function ClientRequestPrepare( _
		ByVal this As ClientRequest Ptr _
	)As HRESULT
	
	' Метод, запрошенный ресурс и версия протокола
	
	Dim pSpace As WString Ptr = Any
	
	Dim bstrVerb As HeapBSTR = Any
	Scope
		Dim pVerb As WString Ptr = this->RequestedLine
		
		' Первый пробел
		pSpace = StrChrW( _
			this->RequestedLine, _
			Characters.WhiteSpace _
		)
		If pSpace = NULL Then
			Return CLIENTREQUEST_E_BADREQUEST
		End If
		
		Dim VerbLength As Integer = pSpace - pVerb
		bstrVerb = HeapSysAllocStringLen( _
			this->pIMemoryAllocator, _
			pVerb, _
			VerbLength _
		)
		
		MessageBoxW(NULL, bstrVerb, "Verb", MB_OK)
		
		' TODO Метод должен определять сервер
		Dim GetHttpMethodResult As Boolean = GetHttpMethodIndex( _
			bstrVerb, _
			@this->HttpMethod _
		)
		If GetHttpMethodResult = False Then
			Return CLIENTREQUEST_E_HTTPMETHODNOTSUPPORTED
		End If
		
	End Scope
	HeapSysFreeString(bstrVerb)
	
	Dim bstrUri As HeapBSTR = Any
	Scope
		' Найти начало непробела
		Do
			pSpace += 1
		Loop While pSpace[0] = Characters.WhiteSpace
		
		' Здесь начинается Url
		Dim pUri As WString Ptr = pSpace
		
		' Второй пробел
		pSpace = StrChrW( _
			pSpace, _
			Characters.WhiteSpace _
		)
		If pSpace = NULL Then
			bstrUri = HeapSysAllocString( _
				this->pIMemoryAllocator, _
				pUri _
			)
		Else
			Dim UriLength As Integer = pSpace - pUri
			bstrUri = HeapSysAllocStringLen( _
				this->pIMemoryAllocator, _
				pUri, _
				UriLength _
			)
		End If
		
		MessageBoxW(NULL, bstrUri, "Uri", MB_OK)
	End Scope
	HeapSysFreeString(bstrUri)
	
	Dim bstrVersion As HeapBSTR = Any
	If pSpace = NULL Then
		bstrVersion = NULL
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
		If pSpace <> NULL Then
			' Слишком много пробелов
			Return CLIENTREQUEST_E_BADREQUEST
		End If
		
		bstrVersion = HeapSysAllocString( _
			this->pIMemoryAllocator, _
			pVersion _
		)
		
		MessageBoxW(NULL, bstrVersion, "Version", MB_OK)
		
		' TODO Версию протокола должен определять сервер
		Dim GetHttpVersionResult As Boolean = GetHttpVersionIndex( _
			bstrVersion, _
			@this->HttpVersion _
		)
		If GetHttpVersionResult = False Then
			Return CLIENTREQUEST_E_HTTPVERSIONNOTSUPPORTED
		End If
		
		Select Case this->HttpVersion
			
			Case HttpVersions.Http11
				this->KeepAlive = True ' Для версии 1.1 это по умолчанию
				
		End Select
	End If
	HeapSysFreeString(bstrVersion)
	
	/'
	Dim hrSetUri As HRESULT = Station922UriSetUri( _
		this->pClientURI, _
		pUri _
	)
	If FAILED(hrSetUri) Then
		Select Case hrSetUri
			
			Case STATION922URI_E_URITOOLARGE
				Return CLIENTREQUEST_E_URITOOLARGE
				
			Case STATION922URI_E_BADPATH
				Return CLIENTREQUEST_E_BADPATH
				
			Case Else
				Return hrSetUri
				
		End Select
	End If
	
	' Получить все заголовки запроса
	Do
		Dim pLine As HeapBSTR = Any
		Dim hrReadLine As HRESULT = ITextReader_ReadLine( _
			this->pIReader, _
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
					
				Case HTTPREADER_E_INSUFFICIENT_BUFFER
					Return CLIENTREQUEST_E_HEADERFIELDSTOOLARGE
					
				Case Else
					Return E_FAIL
					
			End Select
			
		End If
		
		' this->RequestHeaderBufferLength += LineLength + 1
		
		If SysStringLen(pLine) = 0 Then
			' Клиент отправил все данные, можно приступать к обработке
			Exit Do
		End If
		
		Dim pColon As WString Ptr = StrChrW(pLine, Characters.Colon)
		
		If pColon <> 0 Then
			pColon[0] = 0
			Do
				pColon += 1
			Loop While pColon[0] = Characters.WhiteSpace
			
			ClientRequestAddRequestHeader(this, pLine, pColon)
			
		End If
		
	Loop
	
	Scope
		If StrStrIW(this->RequestHeaders(HttpRequestHeaders.HeaderConnection), @CloseString) <> 0 Then
			this->KeepAlive = False
		Else
			If StrStrIW(this->RequestHeaders(HttpRequestHeaders.HeaderConnection), @KeepAliveString) <> 0 Then
				this->KeepAlive = True
			End If
		End If
			
		If StrStrIW(this->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding), @GzipString) <> 0 Then
			this->RequestZipModes(ZipModes.GZip) = True
		End If
		
		If StrStrIW(this->RequestHeaders(HttpRequestHeaders.HeaderAcceptEncoding), @DeflateString) <> 0 Then
			this->RequestZipModes(ZipModes.Deflate) = True
		End If
		
		' Убрать UTC и заменить на GMT
		'If-Modified-Since: Thu, 24 Mar 2016 16:10:31 UTC
		'If-Modified-Since: Tue, 11 Mar 2014 20:07:57 GMT
		Dim wUTC As WString Ptr = StrStrW(this->RequestHeaders(HttpRequestHeaders.HeaderIfModifiedSince), "UTC")
		
		If wUTC <> 0 Then
			lstrcpyW(wUTC, "GMT")
		End If
		
		wUTC = StrStrW(this->RequestHeaders(HttpRequestHeaders.HeaderIfUnModifiedSince), "UTC")
		
		If wUTC <> 0 Then
			lstrcpyW(wUTC, "GMT")
		End If
		
		If lstrlenW(this->RequestHeaders(HttpRequestHeaders.HeaderRange)) > 0 Then
			Dim wHeaderRange As WString Ptr = this->RequestHeaders(HttpRequestHeaders.HeaderRange)
			
			' TODO Обрабатывать несколько байтовых диапазонов
			Dim wCommaChar As WString Ptr = StrChrW(wHeaderRange, Characters.Comma)
			
			If wCommaChar <> 0 Then
				wCommaChar[0] = 0
			End If
			
			Dim wStart As WString Ptr = StrStrW(wHeaderRange, "bytes=")
			
			If wStart = wHeaderRange Then
				wStart = @wHeaderRange[6]
				Dim wStartIndex As WString Ptr = wStart
				
				Dim wHyphenMinusChar As WString Ptr = StrChrW(wStart, Characters.HyphenMinus)
				
				If wHyphenMinusChar <> 0 Then
					wHyphenMinusChar[0] = 0
					Dim wEndIndex As WString Ptr = @wHyphenMinusChar[1]
					
					If StrToInt64ExW(wStartIndex, STIF_DEFAULT, @this->RequestByteRange.FirstBytePosition) <> 0 Then
						this->RequestByteRange.IsSet = ByteRangeIsSet.FirstBytePositionIsSet
					End If
					
					If StrToInt64ExW(wEndIndex, STIF_DEFAULT, @this->RequestByteRange.LastBytePosition) <> 0 Then
						
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
		StrToInt64ExW(pHeaderContentLength, STIF_DEFAULT, @this->ContentLength)
	End If
	'/
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
	
	CopyMemory(pUri, this->pClientURI, SizeOf(Station922Uri))
	
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
	
	Dim copy As HeapBSTR = HeapSysCopyString( _
		this->pIMemoryAllocator, _
		this->RequestHeaders(HeaderIndex) _
	)
	
	*ppHeader = copy
	
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
	Station922UriInitialize(this->pClientURI)
	this->HttpVersion = HttpVersions.Http11
	this->KeepAlive = False
	ZeroMemory(@this->RequestZipModes(0), HttpZipModesMaximum * SizeOf(Boolean))
	this->RequestByteRange.IsSet = ByteRangeIsSet.NotSet
	this->RequestByteRange.FirstBytePosition = 0
	this->RequestByteRange.LastBytePosition = 0
	this->ContentLength = 0
	
	Return S_OK
	
End Function

Function ClientRequestGetTextReader( _
		ByVal this As ClientRequest Ptr, _
		ByVal ppIReader As ITextReader Ptr Ptr _
	)As HRESULT
	
	If this->pIReader = NULL Then
		*ppIReader = NULL
		Return S_FALSE
	End If
	
	ITextReader_AddRef(this->pIReader)
	*ppIReader = this->pIReader
	
	Return S_OK
	
End Function

Function ClientRequestSetTextReader( _
		ByVal this As ClientRequest Ptr, _
		ByVal pIReader As ITextReader Ptr _
	)As HRESULT
	
	If this->pIReader <> NULL Then
		ITextReader_Release(this->pIReader)
	End If
	
	If pIReader <> NULL Then
		ITextReader_AddRef(pIReader)
	End If
	
	this->pIReader = pIReader
	
	Return S_OK
	
End Function

Function ClientRequestStringableQueryInterface( _
		ByVal this As ClientRequest Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Return ClientRequestQueryInterface( _
		this, riid, ppv _
	)
	
End Function

Function ClientRequestStringableAddRef( _
		ByVal this As ClientRequest Ptr _
	)As ULONG
	
	Return ClientRequestAddRef(this)
	
End Function

Function ClientRequestStringableRelease( _
		ByVal this As ClientRequest Ptr _
	)As ULONG
	
	Return ClientRequestRelease(this)
	
End Function

' TODO Реализовать ClientRequestToString
' Function ClientRequestStringableToString( _
		' ByVal this As ClientRequest Ptr, _
		' ByVal pLength As Integer Ptr, _
		' ByVal ppResult As WString Ptr Ptr _
	' )As HRESULT
	
	' *pLength = 0
	' *ppResult = NULL
	
	' Return S_FALSE
	
' End Function


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

' Function IClientRequestReadRequest( _
		' ByVal this As IClientRequest Ptr _
	' )As HRESULT
	' Return ClientRequestReadRequest(ContainerOf(this, ClientRequest, lpVtbl))
' End Function

Function IClientRequestBeginReadRequest( _
		ByVal this As IClientRequest Ptr, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	Return ClientRequestBeginReadRequest(ContainerOf(this, ClientRequest, lpVtbl), StateObject, ppIAsyncResult)
End Function

Function IClientRequestEndReadRequest( _
		ByVal this As IClientRequest Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr _
	)As HRESULT
	Return ClientRequestEndReadRequest(ContainerOf(this, ClientRequest, lpVtbl), pIAsyncResult)
End Function

Function IClientRequestPrepare( _
		ByVal this As IClientRequest Ptr _
	)As HRESULT
	Return ClientRequestPrepare(ContainerOf(this, ClientRequest, lpVtbl))
End Function

Function IClientRequestGetHttpMethod( _
		ByVal this As IClientRequest Ptr, _
		ByVal pHttpMethod As HttpMethods Ptr _
	)As HRESULT
	Return ClientRequestGetHttpMethod(ContainerOf(this, ClientRequest, lpVtbl), pHttpMethod)
End Function

Function IClientRequestGetUri( _
		ByVal this As IClientRequest Ptr, _
		ByVal pUri As Station922Uri Ptr _
	)As HRESULT
	Return ClientRequestGetUri(ContainerOf(this, ClientRequest, lpVtbl), pUri)
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

Function IClientRequestClear( _
		ByVal this As IClientRequest Ptr _
	)As HRESULT
	Return ClientRequestClear(ContainerOf(this, ClientRequest, lpVtbl))
End Function

Function IClientRequestGetTextReader( _
		ByVal this As IClientRequest Ptr, _
		ByVal ppIReader As ITextReader Ptr Ptr _
	)As HRESULT
	Return ClientRequestGetTextReader(ContainerOf(this, ClientRequest, lpVtbl), ppIReader)
End Function

Function IClientRequestSetTextReader( _
		ByVal this As IClientRequest Ptr, _
		ByVal pIReader As ITextReader Ptr _
	)As HRESULT
	Return ClientRequestSetTextReader(ContainerOf(this, ClientRequest, lpVtbl), pIReader)
End Function

Dim GlobalClientRequestVirtualTable As Const IClientRequestVirtualTable = Type( _
	@IClientRequestQueryInterface, _
	@IClientRequestAddRef, _
	@IClientRequestRelease, _
	NULL, _ /' @IClientRequestReadRequest, _ '/
	@IClientRequestBeginReadRequest, _
	@IClientRequestEndReadRequest, _
	@IClientRequestPrepare, _
	@IClientRequestGetHttpMethod, _
	@IClientRequestGetUri, _
	@IClientRequestGetHttpVersion, _
	@IClientRequestGetHttpHeader, _
	@IClientRequestGetKeepAlive, _
	@IClientRequestGetContentLength, _
	@IClientRequestGetByteRange, _
	@IClientRequestGetZipMode, _
	@IClientRequestClear, _
	@IClientRequestGetTextReader, _
	@IClientRequestSetTextReader _
)

' Function IClientRequestStringableQueryInterface( _
		' ByVal this As IStringable Ptr, _
		' ByVal riid As REFIID, _
		' ByVal ppvObject As Any Ptr Ptr _
	' )As HRESULT
	' Return ClientRequestStringableQueryInterface(ContainerOf(this, ClientRequest, lpStringableVtbl), riid, ppvObject)
' End Function

' Function IClientRequestStringableAddRef( _
		' ByVal this As IStringable Ptr _
	' )As ULONG
	' Return ClientRequestStringableAddRef(ContainerOf(this, ClientRequest, lpStringableVtbl))
' End Function

' Function IClientRequestStringableRelease( _
		' ByVal this As IStringable Ptr _
	' )As ULONG
	' Return ClientRequestStringableRelease(ContainerOf(this, ClientRequest, lpStringableVtbl))
' End Function

' Function IClientRequestStringableToString( _
		' ByVal this As IStringable Ptr, _
		' ByVal pLength As Integer Ptr, _
		' ByVal ppResult As WString Ptr Ptr _
	' )As HRESULT
	' Return ClientRequestStringableToString(ContainerOf(this, ClientRequest, lpStringableVtbl), pLength, ppResult)
' End Function

Dim GlobalClientRequestStringableVirtualTable As Const IStringableVirtualTable = Type( _
	NULL, _ /' @IClientRequestStringableQueryInterface, _ '/
	NULL, _ /' @IClientRequestStringableAddRef, _ '/
	NULL, _ /' @IClientRequestStringableRelease, _ '/
	NULL _ /' @IClientRequestStringableToString _ '/
)
