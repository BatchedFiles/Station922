#include once "WebSite.bi"
#include once "win\shlwapi.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "FileStream.bi"
#include once "HeapBSTR.bi"
#include once "HttpProcessorCollection.bi"
#include once "MemoryStream.bi"
#include once "Mime.bi"
#include once "WebUtils.bi"

Extern GlobalWebSiteVirtualTable As Const IWebSiteVirtualTable

Const MaxHostNameLength As Integer = 1024 - 1
Const DefaultFileNames As Integer = 8
Const BasicAuthorizationWithSpace = WStr("Basic ")

Const WebSocketGuidString = WStr("258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
Const UpgradeString = WStr("Upgrade")
Const WebSocketString = WStr("websocket")
Const WebSocketVersionString = WStr("13")
Const HeadersExtensionString = WStr(".headers")
Const FileGoneExtension = WStr(".410")
Const QuoteString = WStr("""")
Const GzipString = WStr("gzip")
Const DeflateString = WStr("deflate")

' Размер буфера в символах для записи в него кода html страницы с ошибкой
Const MaxHttpErrorBuffer As Integer = 1024 - 1

Const DefaultContentLanguage = WStr("en")
Const DefaultCacheControlNoCache = WStr("no-cache")

Const MovedPermanently = WStr("Moved Permanently.")
Const HttpError400BadRequest = WStr("Bad Request.")
Const HttpError400BadPath = WStr("Bad Path.")
Const HttpError400Host = WStr("Bad Host Header.")
Const HttpError403Forbidden = WStr("Forbidden.")
Const HttpError404FileNotFound = WStr("File Not Found.")
Const HttpError404SiteNotFound = WStr("Website Not Found.")
Const HttpError405NotAllowed = WStr("Method Not Allowed.")
Const HttpError410Gone = WStr("File Gone.")
Const HttpError411LengthRequired = WStr("Length Header Required.")
Const HttpError413RequestEntityTooLarge = WStr("Request Entity Too Large.")
Const HttpError414RequestUrlTooLarge = WStr("Request URL Too Large.")
Const HttpError416RangeNotSatisfiable = WStr("Range Not Satisfiable.")
Const HttpError431RequestRequestHeaderFieldsTooLarge = WStr("Request Header Fields Too Large")

Const HttpError500InternalServerError = WStr("Internal Server Error.")
Const HttpError500FileNotAvailable = WStr("File Not Available.")
Const HttpError500CannotCreateChildProcess = WStr("Can not Create Child Process")
Const HttpError500CannotCreatePipe = WStr("Can not Create Pipe.")
Const HttpError501NotImplemented = WStr("Method Not Implemented.")
Const HttpError501ContentTypeEmpty = WStr("Content-Type Header Empty.")
Const HttpError501ContentEncoding = WStr("Content Encoding is wrong.")
Const HttpError502BadGateway = WStr("Bad GateAway.")
Const HttpError503ThreadError = WStr("Can not create Thread.")
Const HttpError503Memory = WStr("Can not Allocate Memory.")
Const HttpError504GatewayTimeout = WStr("GateAway Timeout")
Const HttpError505VersionNotSupported = WStr("HTTP Version Not Supported.")

Const NeedUsernamePasswordString = WStr("Need Username And Password")
Const NeedUsernamePasswordString1 = WStr("Authorization wrong")
Const NeedUsernamePasswordString2 = WStr("Need Basic Authorization")
Const NeedUsernamePasswordString3 = WStr("Password must not be empty")

Type ListingFileItem
	FileName As WString * (MAX_PATH + 1)
	FileSize As LARGE_INTEGER
	IsDirectory As Boolean
End Type

Type _WebSite
	#if __FB_DEBUG__
		RttiClassName(15) As UByte
	#endif
	lpVtbl As Const IWebSiteVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pHostName As HeapBSTR
	pPhysicalDirectory As HeapBSTR
	pVirtualPath As HeapBSTR
	pCanonicalUrl As HeapBSTR
	ListenAddress As HeapBSTR
	ListenPort As HeapBSTR
	ConnectBindAddress As HeapBSTR
	ConnectBindPort As HeapBSTR
	CodePage As HeapBSTR
	DefaultFileName As HeapBSTR
	DirectoryListingEncoding As HeapBSTR
	ErrorPageEncoding As HeapBSTR
	UserName As HeapBSTR
	Password As HeapBSTR
	pIProcessorCollection As IHttpProcessorCollection Ptr
	UtfBomFileOffset As UInteger
	ReservedFileBytes As UInteger
	UseSsl As Boolean
	IsMoved As Boolean
	EnableDirectoryListing As Boolean
	EnableGetAllFiles As Boolean
End Type

Type FileIteratorW
	Declare Constructor(ByRef ListingDir As WString)
	Declare Destructor()
	Declare Operator For()
	Declare Operator Step()
	Declare Operator Next(ByRef endCond As FileIteratorW) As Integer
	
	FindData As WIN32_FIND_DATAW
	hFind As HANDLE
	pListingDir As WString Ptr
	resFindNext As BOOL
End Type

Private Constructor FileIteratorW(ByRef ListingDir As WString)
	
	hFind = INVALID_HANDLE_VALUE
	pListingDir = @ListingDir
	resFindNext = TRUE
	
End Constructor

Private Destructor FileIteratorW()
	
	If hFind <> INVALID_HANDLE_VALUE Then
		FindClose(hFind)
	End If
	
End Destructor

Private Operator FileIteratorW.For()
	
	hFind = FindFirstFileW( _
		pListingDir, _
		@FindData _
	)
	
End Operator

Private Operator FileIteratorW.Step()
	
	resFindNext = FindNextFileW( _
		hFind, _
		@FindData _
	)
	
End Operator

Private Operator FileIteratorW.Next(ByRef endCond As FileIteratorW) As Integer
	
	If hFind = INVALID_HANDLE_VALUE Then
		Return 0
	End If
	
	If resFindNext = 0 Then
		Return 0
	End If
	
	Return 1
	
End Operator

Private Function GetAuthorizationHeader( _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal ProxyAuthorization As Boolean _
	)As HeapBSTR
	
	Dim pHeaderAuthorization As HeapBSTR = Any
	
	If ProxyAuthorization Then
		IClientRequest_GetHttpHeader( _
			pIRequest, _
			HttpRequestHeaders.HeaderProxyAuthorization, _
			@pHeaderAuthorization _
		)
		
		Dim Length As Integer = SysStringLen(pHeaderAuthorization)
		If Length = 0 Then
			HeapSysFreeString(pHeaderAuthorization)
			IClientRequest_GetHttpHeader( _
				pIRequest, _
				HttpRequestHeaders.HeaderAuthorization, _
				@pHeaderAuthorization _
			)
		End If
	Else
		IClientRequest_GetHttpHeader( _
			pIRequest, _
			HttpRequestHeaders.HeaderAuthorization, _
			@pHeaderAuthorization _
		)
	End If
	
	Return pHeaderAuthorization
	
End Function

Private Function StartsWith( _
		ByVal pSource As WString Ptr, _
		ByVal pPattern As WString Ptr, _
		ByVal Length As Integer _
	)As Boolean
	
	Dim cbBytes As Integer = Length * SizeOf(WString)
	Dim CompareResult As Long = memcmp( _
		pSource, _
		pPattern, _
		cbBytes _
	)
	If CompareResult <> 0 Then
		Return False
	End If
	
	Return True
	
End Function

Private Function WebSiteHttpAuthUtil( _
		ByVal this As WebSite Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal ProxyAuthorization As Boolean _
	)As HRESULT
	
	Dim pHeaderAuthorization As HeapBSTR = GetAuthorizationHeader( _
		pIRequest, _
		ProxyAuthorization _
	)
	
	Dim AuthorizationHeaderLength As Integer = SysStringLen(pHeaderAuthorization)
	If AuthorizationHeaderLength = 0 Then
		HeapSysFreeString(pHeaderAuthorization)
		Return WEBSITE_E_NEEDAUTHENTICATE
	End If
	
	Dim resStarts As Boolean = StartsWith( _
		pHeaderAuthorization, _
		@BasicAuthorizationWithSpace, _
		Len(BasicAuthorizationWithSpace) _
	)
	If resStarts = False Then
		HeapSysFreeString(pHeaderAuthorization)
		Return WEBSITE_E_NEEDBASICAUTHENTICATE
	End If
	
	Dim pBase64 As WString Ptr = @pHeaderAuthorization[Len(BasicAuthorizationWithSpace)]
	Dim Base64Length As Integer = AuthorizationHeaderLength - Len(BasicAuthorizationWithSpace)
	
	Const UserNamePasswordCapacity As Integer = 1000 - 1
	Dim UsernamePasswordUtf8 As ZString * (UserNamePasswordCapacity + 1) = Any
	Dim dwUsernamePasswordUtf8Length As DWORD = Cast(DWORD, UserNamePasswordCapacity)
	
	Dim resCryptString As BOOL = CryptStringToBinaryW( _
		pBase64, _
		Cast(DWORD, Base64Length), _
		CRYPT_STRING_BASE64, _
		@UsernamePasswordUtf8, _
		@dwUsernamePasswordUtf8Length, _
		0, _
		0 _
	)
	If resCryptString = 0 Then
		Dim dwError As DWORD = GetLastError()
		HeapSysFreeString(pHeaderAuthorization)
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	UsernamePasswordUtf8[dwUsernamePasswordUtf8Length] = Characters.NullChar
	
	' Из массива байт в строку
	' Преобразуем utf8 в WString
	' -1 — значит, длина строки будет проверяться самой функцией по завершающему нулю
	Dim UsernamePasswordKey As WString * (UserNamePasswordCapacity + 1) = Any
	Dim DecodedLength As Long = MultiByteToWideChar( _
		CP_UTF8, _
		0, _
		@UsernamePasswordUtf8, _
		dwUsernamePasswordUtf8Length, _
		@UsernamePasswordKey, _
		UserNamePasswordCapacity _
	)
	UsernamePasswordKey[DecodedLength] = Characters.NullChar
	
	' Теперь pColonChar хранит в себе указатель на разделитель-двоеточие
	Dim pColonChar As WString Ptr = StrChrW(@UsernamePasswordKey, Characters.Colon)
	If pColonChar = NULL Then
		HeapSysFreeString(pHeaderAuthorization)
		Return WEBSITE_E_EMPTYPASSWORD
	End If
	
	' Remove Colon Character
	pColonChar[0] = 0
	
	Dim pClientUserName As WString Ptr = @UsernamePasswordKey
	Dim pClientPassword As WString Ptr = @pColonChar[1]
	
	Dim ServerUserNameLength As Integer = SysStringLen(this->UserName)
	
	If ServerUserNameLength Then
		
		Dim ServerPasswordLength As Integer = SysStringLen(this->Password)
		
		If ServerPasswordLength Then
			Dim UserNameCompareResult As Long = lstrcmpW(this->UserName, pClientUserName)
			
			If UserNameCompareResult = 0 Then
				Dim PasswordCompareResult As Long = lstrcmpW(this->Password, pClientPassword)
				
				If PasswordCompareResult = 0 Then
					
					HeapSysFreeString(pHeaderAuthorization)
					
					Return S_OK
				End If
			End If
		End If
	End If
	
	HeapSysFreeString(pHeaderAuthorization)
	
	Return WEBSITE_E_BADUSERNAMEPASSWORD
	
End Function

Private Sub FormatMessageErrorBody( _
		ByRef Writer As ArrayStringWriter, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal VirtualPath As HeapBSTR, _
		ByVal BodyText As WString Ptr, _
		ByVal hrErrorCode As HRESULT _
	)
	
	Const HttpStartHeadTag = WStr("<!DOCTYPE html><html xmlns=""http://www.w3.org/1999/xhtml"" lang=""en"" xml:lang=""en""><head><meta name=""viewport"" content=""width=device-width, initial-scale=1"" />")
	Const HttpStartTitleTag = WStr("<title>")
	Const HttpEndTitleTag = WStr("</title>")
	Const HttpEndHeadTag = WStr("</head>")
	Const HttpStartBodyTag = WStr("<body>")
	Const HttpStartH1Tag = WStr("<h1>")
	Const HttpEndH1Tag = WStr("</h1>")
	
	' 300
	Const ClientMovedString = WStr("Redirection")
	' 400
	Const ClientErrorString = WStr("Client Error")
	' 500
	Const ServerErrorString = WStr("Server Error")
	Const HttpErrorInApplicationString = WStr(" in application ")
	
	Const HttpStartH2Tag = WStr("<h2>")
	Const HttpStatusCodeString = WStr("HTTP Status Code ")
	Const HttpEndH2Tag = WStr("</h2>")
	Const HttpHresultErrorCodeString = WStr("HRESULT Error Code")
	Const HttpStartPTag = WStr("<p>")
	Const HttpEndPTag = WStr("</p>")
	
	'<p>Visit <a href=""/"">website main page</a>.</p>
	
	Const HttpEndBodyTag = WStr("</body></html>")
	
	Dim DescriptionBuffer As WString Ptr = GetStatusDescription(StatusCode, 0)
	
	Writer.WriteString(HttpStartHeadTag)
	Writer.WriteString(HttpStartTitleTag)
	Writer.WriteString(DescriptionBuffer)
	Writer.WriteString(HttpEndTitleTag)
	Writer.WriteString(HttpEndHeadTag)
	
	Writer.WriteString(HttpStartBodyTag)
	Writer.WriteString(HttpStartH1Tag)
	Writer.WriteString(DescriptionBuffer)
	Writer.WriteString(HttpEndH1Tag)
	
	Writer.WriteString(HttpStartPTag)
	
	Select Case StatusCode
		
		Case 300 To 399
			Writer.WriteString(ClientMovedString)
			
		Case 400 To 499
			Writer.WriteString(ClientErrorString)
			
		Case 500 To 599
			Writer.WriteString(ServerErrorString)
			
	End Select
	
	Writer.WriteString(HttpErrorInApplicationString)
	Writer.WriteLengthString(VirtualPath, SysStringLen(VirtualPath))
	Writer.WriteString(HttpEndPTag)
	
	Writer.WriteString(HttpStartH2Tag)
	Writer.WriteString(HttpStatusCodeString)
	Writer.WriteInt32(StatusCode)
	Writer.WriteString(HttpEndH2Tag)
	
	Writer.WriteString(HttpStartPTag)
	Writer.WriteString(BodyText)
	Writer.WriteString(HttpEndPTag)
	
	Writer.WriteString(HttpStartH2Tag)
	Writer.WriteString(HttpHresultErrorCodeString)
	Writer.WriteString(HttpEndH2Tag)
	
	Writer.WriteString(HttpStartPTag)
	Writer.WriteUInt32(hrErrorCode)
	Writer.WriteString(HttpEndPTag)
	
	Dim wBuffer As WString * 256 = Any
	Dim CharsCount As DWORD = FormatMessageW( _
		FORMAT_MESSAGE_FROM_SYSTEM Or FORMAT_MESSAGE_MAX_WIDTH_MASK, _
		NULL, _
		hrErrorCode, _
		MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US), _
		@wBuffer, _
		256 - 1, _
		NULL _
	)
	If CharsCount Then
		Writer.WriteString(HttpStartPTag)
		Writer.WriteString(wBuffer)
		Writer.WriteString(HttpEndPTag)
	End If
	
	Writer.WriteString(HttpEndBodyTag)
	
End Sub

Private Function GetErrorBodyText( _
		ByVal HttpError As ResponseErrorCode _
	)As WString Ptr
	
	Select Case HttpError
		
		Case ResponseErrorCode.MovedPermanently
			Return @MovedPermanently
			
		Case ResponseErrorCode.BadRequest
			Return @HttpError400BadRequest
			
		Case ResponseErrorCode.PathNotValid
			Return @HttpError400BadPath
			
		Case ResponseErrorCode.HostNotFound
			Return @HttpError400Host
			
		Case ResponseErrorCode.SiteNotFound
			Return @HttpError404SiteNotFound
			
		Case ResponseErrorCode.NeedAuthenticate
			Return @NeedUsernamePasswordString
			
		Case ResponseErrorCode.BadAuthenticateParam
			Return @NeedUsernamePasswordString1
			
		Case ResponseErrorCode.NeedBasicAuthenticate
			Return @NeedUsernamePasswordString2
			
		Case ResponseErrorCode.EmptyPassword
			Return @NeedUsernamePasswordString3
			
		Case ResponseErrorCode.BadUserNamePassword
			Return @NeedUsernamePasswordString
			
		Case ResponseErrorCode.Forbidden
			Return @HttpError403Forbidden
			
		Case ResponseErrorCode.FileNotFound
			Return @HttpError404FileNotFound
			
		Case ResponseErrorCode.MethodNotAllowed
			Return @HttpError405NotAllowed
			
		Case ResponseErrorCode.FileGone
			Return @HttpError410Gone
			
		Case ResponseErrorCode.LengthRequired
			Return @HttpError411LengthRequired
			
		Case ResponseErrorCode.RequestEntityTooLarge
			Return @HttpError413RequestEntityTooLarge
			
		Case ResponseErrorCode.RequestUrlTooLarge
			Return @HttpError414RequestUrlTooLarge
			
		Case ResponseErrorCode.RequestRangeNotSatisfiable
			Return @HttpError416RangeNotSatisfiable
			
		Case ResponseErrorCode.RequestHeaderFieldsTooLarge
			Return @HttpError431RequestRequestHeaderFieldsTooLarge
			
		Case ResponseErrorCode.InternalServerError
			Return @HttpError500InternalServerError
			
		Case ResponseErrorCode.FileNotAvailable
			Return @HttpError500FileNotAvailable
			
		Case ResponseErrorCode.CannotCreateChildProcess
			Return @HttpError500CannotCreateChildProcess
			
		Case ResponseErrorCode.CannotCreatePipe
			Return @HttpError500CannotCreatePipe
			
		Case ResponseErrorCode.NotImplemented
			Return @HttpError501NotImplemented
			
		Case ResponseErrorCode.ContentTypeEmpty
			Return @HttpError501ContentTypeEmpty
			
		Case ResponseErrorCode.ContentEncodingNotEmpty
			Return @HttpError501ContentEncoding
			
		Case ResponseErrorCode.BadGateway
			Return @HttpError502BadGateway
			
		Case ResponseErrorCode.NotEnoughMemory
			Return @HttpError503Memory
			
		Case ResponseErrorCode.CannotCreateThread
			Return @HttpError503ThreadError
			
		Case ResponseErrorCode.GatewayTimeout
			Return @HttpError504GatewayTimeout
			
		Case ResponseErrorCode.VersionNotSupported
			Return @HttpError505VersionNotSupported
			
		Case Else
			Return @HttpError500InternalServerError
			
	End Select
	
End Function

Private Sub GetETag( _
		ByVal wETag As WString Ptr, _
		ByVal pTime As FILETIME Ptr, _
		ByVal ZipMode As ZipModes _
	)
	
	lstrcpyW(wETag, @QuoteString)
	
	Dim ul As ULARGE_INTEGER = Any
	With ul
		.LowPart = pTime->dwLowDateTime
		.HighPart = pTime->dwHighDateTime
	End With
	
	_ui64tow(ul.QuadPart, @wETag[1], 10)
	
	Select Case ZipMode
		
		Case ZipModes.GZip
			lstrcatW(wETag, @GzipString)
			
		Case ZipModes.Deflate
			lstrcatW(wETag, @DeflateString)
			
	End Select
	
	lstrcatW(wETag, @QuoteString)
	
End Sub

Private Function GetDefaultFileName( _
		ByVal Buffer As WString Ptr, _
		ByVal Index As Integer, _
		ByVal DefaultFileName As HeapBSTR _
	)As Boolean
	
	Const DefaultFileNameDefaultXml = WStr("default.xml")
	Const DefaultFileNameDefaultXhtml = WStr("default.xhtml")
	Const DefaultFileNameDefaultHtm = WStr("default.htm")
	Const DefaultFileNameDefaultHtml = WStr("default.html")
	Const DefaultFileNameIndexXml = WStr("index.xml")
	Const DefaultFileNameIndexXhtml = WStr("index.xhtml")
	Const DefaultFileNameIndexHtm = WStr("index.htm")
	Const DefaultFileNameIndexHtml = WStr("index.html")
	
	Dim Length As Integer = SysStringLen(DefaultFileName)
	
	If Length Then
		lstrcpyW(Buffer, DefaultFileName)
		Return True
	End If
	
	Select Case Index
		
		Case 0
			lstrcpyW(Buffer, @DefaultFileNameDefaultXml)
			
		Case 1
			lstrcpyW(Buffer, @DefaultFileNameDefaultXhtml)
			
		Case 2
			lstrcpyW(Buffer, @DefaultFileNameDefaultHtm)
			
		Case 3
			lstrcpyW(Buffer, @DefaultFileNameDefaultHtml)
			
		Case 4
			lstrcpyW(Buffer, @DefaultFileNameIndexXml)
			
		Case 5
			lstrcpyW(Buffer, @DefaultFileNameIndexXhtml)
			
		Case 6
			lstrcpyW(Buffer, @DefaultFileNameIndexHtm)
			
		Case 7
			lstrcpyW(Buffer, @DefaultFileNameIndexHtml)
			
		Case Else
			lstrcpyW(Buffer, @DefaultFileNameDefaultXml)
			Return False
			
	End Select
	
	Return True
	
End Function

Private Function GetFileHandle( _
		ByVal PathTranslated As WString Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal pFileHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim FileHandle As HANDLE = Any
	Dim hrErrorCode As HRESULT = Any
	
	Select Case fAccess
		
		Case FileAccess.CreateAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				GENERIC_WRITE, _
				0, _
				NULL, _
				CREATE_ALWAYS, _
				FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_OVERLAPPED, _
				NULL _
			)
			
			Dim dwError As DWORD = GetLastError()
			
			If FileHandle = INVALID_HANDLE_VALUE Then
				If dwError = ERROR_PATH_NOT_FOUND Then
					Dim FileDir As WString * (MAX_PATH + 1) = Any
					lstrcpyW(@FileDir, PathTranslated)
					PathRemoveFileSpecW(@FileDir)
					CreateDirectoryW(@FileDir, NULL)
					
					Dim FileHandle2 As HANDLE = CreateFileW( _
						PathTranslated, _
						GENERIC_WRITE, _
						0, _
						NULL, _
						CREATE_ALWAYS, _
						FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_OVERLAPPED, _
						NULL _
					)
					
					If FileHandle2 = INVALID_HANDLE_VALUE Then
						Dim dwError2 As DWORD = GetLastError()
						hrErrorCode = HRESULT_FROM_WIN32(dwError2)
					Else
						FileHandle = FileHandle2
						hrErrorCode = WEBSITE_S_CREATE_NEW
					End If
				Else
					hrErrorCode = HRESULT_FROM_WIN32(dwError)
				End If
			Else
				If dwError = ERROR_ALREADY_EXISTS Then
					hrErrorCode = WEBSITE_S_ALREADY_EXISTS
				Else
					hrErrorCode = WEBSITE_S_CREATE_NEW
				End If
			End If
			
		Case FileAccess.ReadAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				GENERIC_READ, _
				FILE_SHARE_READ, _
				NULL, _
				OPEN_EXISTING, _
				FILE_FLAG_OVERLAPPED, _
				NULL _
			)
			If FileHandle = INVALID_HANDLE_VALUE Then
				Dim dwError As DWORD = GetLastError()
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				hrErrorCode = S_OK
			End If
			
		Case FileAccess.UpdateAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				GENERIC_WRITE, _
				0, _
				NULL, _
				OPEN_EXISTING, _
				FILE_FLAG_OVERLAPPED, _
				NULL _
			)
			
			Dim dwError As DWORD = GetLastError()
			
			If FileHandle = INVALID_HANDLE_VALUE Then
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				If dwError = ERROR_ALREADY_EXISTS Then
					hrErrorCode = WEBSITE_S_ALREADY_EXISTS
				Else
					hrErrorCode = S_OK
				End If
			End If
			
		Case FileAccess.DeleteAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				0, _
				0, _
				NULL, _
				OPEN_EXISTING, _
				FILE_FLAG_DELETE_ON_CLOSE Or FILE_FLAG_OVERLAPPED, _
				NULL _
			)
			If FileHandle = INVALID_HANDLE_VALUE Then
				Dim dwError As DWORD = GetLastError()
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				hrErrorCode = S_OK
			End If
			
		Case Else ' FileAccess.TemporaryAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				GENERIC_READ, _
				FILE_SHARE_READ Or FILE_SHARE_WRITE Or FILE_SHARE_DELETE, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_TEMPORARY Or FILE_FLAG_DELETE_ON_CLOSE Or FILE_FLAG_OVERLAPPED, _
				NULL _
			)
			If FileHandle = INVALID_HANDLE_VALUE Then
				Dim dwError As DWORD = GetLastError()
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				hrErrorCode = S_OK
			End If
			
	End Select
	
	If SUCCEEDED(hrErrorCode) Then
		Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
		Dim hrBind As HRESULT = IThreadPool_AssociateDevice( _
			pIPool, _
			FileHandle, _
			FileHandle _
		)
		If FAILED(hrBind) Then
			CloseHandle(FileHandle)
			*pFileHandle = INVALID_HANDLE_VALUE
			Return hrBind
		End If
	End If
	
	*pFileHandle = FileHandle
	
	Return hrErrorCode
	
End Function

Private Sub ReplaceSolidus( _
		ByVal pBuffer As WString Ptr, _
		ByVal Length As Integer _
	)
	
	For i As Integer = 0 To Length - 1
		If pBuffer[i] = Characters.Solidus Then
			pBuffer[i] = Characters.ReverseSolidus
		End If
	Next
	
End Sub

Private Function GetCompressionHandle( _
		ByVal PathTranslated As WString Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pZipMode As ZipModes Ptr, _
		ByVal pEncodingVaryFlag As Boolean Ptr _
	)As HANDLE
	
	*pEncodingVaryFlag = False
	
	Scope
		Const GZipExtensionString = WStr(".gz")
		
		Dim GZipFileName As WString * (MAX_PATH + 1) = Any
		lstrcpyW(@GZipFileName, PathTranslated)
		lstrcatW(@GZipFileName, @GZipExtensionString)
		
		Dim hFile As HANDLE = CreateFileW( _
			@GZipFileName, _
			GENERIC_READ, _
			FILE_SHARE_READ, _
			NULL, _
			OPEN_EXISTING, _
			FILE_FLAG_OVERLAPPED, _
			NULL _
		)
		
		If hFile <> INVALID_HANDLE_VALUE Then
			*pEncodingVaryFlag = True
			
			Dim IsClientSupportGZip As Boolean = Any
			IClientRequest_GetZipMode( _
				pIRequest, _
				ZipModes.GZip, _
				@IsClientSupportGZip _
			)
			
			If IsClientSupportGZip Then
				*pZipMode = ZipModes.GZip
				Return hFile
			End If
			
			CloseHandle(hFile)
		End If
	End Scope
	
	Scope
		Const DeflateExtensionString = WStr(".deflate")
		
		Dim DeflateFileName As WString * (MAX_PATH + 1) = Any
		lstrcpyW(@DeflateFileName, PathTranslated)
		lstrcatW(@DeflateFileName, @DeflateExtensionString)
		
		Dim hFile As HANDLE = CreateFileW( _
			@DeflateFileName, _
			GENERIC_READ, _
			FILE_SHARE_READ, _
			NULL, _
			OPEN_EXISTING, _
			FILE_FLAG_OVERLAPPED, _
			NULL _
		)
		
		If hFile <> INVALID_HANDLE_VALUE Then
			*pEncodingVaryFlag = True
		
			Dim IsClientSupportDeflate As Boolean = Any
			IClientRequest_GetZipMode( _
				pIRequest, _
				ZipModes.Deflate, _
				@IsClientSupportDeflate _
			)
			
			If IsClientSupportDeflate Then
				*pZipMode = ZipModes.Deflate
				Return hFile
			End If
			
			CloseHandle(hFile)
		End If
	End Scope
	
	*pZipMode = ZipModes.None
	
	Return INVALID_HANDLE_VALUE
	
End Function

Private Function GetFileBytesOffset( _
		ByVal CodePage As HeapBSTR, _
		ByVal hZipFileHandle As HANDLE, _
		ByVal pMime As MimeType Ptr, _
		ByVal UtfBomFileOffset As Integer _
	)As LongInt
	
	pMime->CharsetWeakPtr = CodePage
	
	If hZipFileHandle <> INVALID_HANDLE_VALUE Then
		Return 0
	End If
	
	Return UtfBomFileOffset
	
End Function

Private Function WebSiteMapPath( _
		ByVal pPhysicalDirectory As HeapBSTR, _
		ByVal pPath As WString Ptr, _
		ByVal pBuffer As WString Ptr _
	)As HRESULT
	
	lstrcpyW(pBuffer, pPhysicalDirectory)
	
	Scope
		Dim BufferLength As Integer = SysStringLen(pPhysicalDirectory)
		
		If pBuffer[BufferLength - 1] <> Characters.ReverseSolidus Then
			pBuffer[BufferLength] = Characters.ReverseSolidus
			pBuffer[BufferLength + 1] = 0
		End If
	End Scope
	
	If pPath[0] = Characters.Solidus Then
		lstrcatW(pBuffer, @pPath[1])
	Else
		lstrcatW(pBuffer, pPath)
	End If
	
	Dim BufferLength As Integer = lstrlenW(pBuffer)
	ReplaceSolidus(pBuffer, BufferLength)
	
	Return S_OK
	
End Function

Private Function WriteToFileW( _
		ByVal hFile As HANDLE, _
		ByVal pData As WString Ptr, _
		ByVal LengthW As Integer _
	)As HRESULT
	
	Dim NumberOfBytesWritten As DWORD = Any
	Dim resWrite As BOOL = WriteFile( _
		hFile, _
		pData, _
		LengthW * SizeOf(WString), _
		@NumberOfBytesWritten, _
		NULL _
	)
	If resWrite = 0 Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

Private Function FileNameIsDot( _
		ByVal pffd As WString Ptr _
	) As Boolean
	
	Const DotString = "."
	Const DotDotString = ".."
	
	Dim resCompareDotDot As Long = lstrcmpW( _
		pffd, _
		WStr(DotDotString) _
	)
	
	If resCompareDotDot = 0 Then
		Return True
	End If
	
	Dim resCompareDot As Long = lstrcmpW( _
		pffd, _
		WStr(DotString) _
	)
	
	If resCompareDot = 0 Then
		Return True
	End If
	
	Return False
	
End Function

Private Function GetFileList( _
		ByVal pListingDir As WString Ptr, _
		ByVal pCount As Integer Ptr _
	)As ListingFileItem Ptr
	
	Dim FileListCapacity As Integer = 1024
	Dim FilesCount As Integer = 0
	
	Dim pFiles As ListingFileItem Ptr = Allocate( _
		SizeOf(ListingFileItem) * FileListCapacity _
	)
	If pFiles = NULL Then
		*pCount = 0
		Return NULL
	End If
	
	For iterator As FileIteratorW = *pListingDir To WStr("")
		Dim resIsDot As Boolean = FileNameIsDot(@iterator.FindData.cFileName)
		
		If resIsDot = False Then
			
			If FilesCount >= FileListCapacity Then
				FileListCapacity = FileListCapacity * 2
				Dim pFilesNew As ListingFileItem Ptr = ReAllocate( _
					pFiles, _
					SizeOf(ListingFileItem) * FileListCapacity _
				)
				If pFilesNew = NULL Then
					*pCount = 0
					DeAllocate(pFiles)
					Return NULL
				End If
				
				pFiles = pFilesNew
			End If
			
			Dim IsDirectory As Boolean = iterator.FindData.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY
			
			lstrcpyW(@pFiles[FilesCount].FileName, iterator.FindData.cFileName)
			pFiles[FilesCount].FileSize.LowPart = iterator.FindData.nFileSizeLow
			pFiles[FilesCount].FileSize.HighPart = iterator.FindData.nFileSizeHigh
			pFiles[FilesCount].IsDirectory = IsDirectory
			
			FilesCount += 1
		End If
		
	Next
	
	*pCount = FilesCount
	Return pFiles
	
End Function

Private Function CompareListingFileItems cdecl( _
		ByVal p As Const Any Ptr, _
		ByVal q As Const Any Ptr _
	)As Long
	
	Dim x As ListingFileItem Ptr = CPtr(ListingFileItem Ptr, p)
	Dim y As ListingFileItem Ptr = CPtr(ListingFileItem Ptr, q)
	
	If x->IsDirectory Then
		If y->IsDirectory Then
			Dim resCompare As Long = lstrcmpW( _
				@x->FileName, _
				@y->FileName _
			)
			Return resCompare
		Else
			Return -1
		End If
	Else
		If y->IsDirectory Then
			Return 1
		Else
			Dim resCompare As Long = lstrcmpW( _
				@x->FileName, _
				@y->FileName _
			)
			Return resCompare
		End If
	End If
	
End Function

Private Function WriteDirectoryListingFile( _
		ByVal hFile As HANDLE, _
		ByVal pListingDir As WString Ptr _
	)As HRESULT
	
	Scope
		' Write UTF-16 LE Byte Order Mark
		Dim Utf16LeBomBytes As ZString * 2 = Any
		Utf16LeBomBytes[0] = &hFF
		Utf16LeBomBytes[1] = &hFE
		
		Dim hrWriteBom As HRESULT = WriteToFileW( _
			hFile, _
			Cast(WString Ptr, @Utf16LeBomBytes), _
			1 _
		)
		If FAILED(hrWriteBom) Then
			Return hrWriteBom
		End If
	End Scope
	
	Scope
		Const FileDataBytes = WStr("<!DOCTYPE html><html xmlns=""http://www.w3.org/1999/xhtml"" lang=""en"">")
		
		Dim hrWriteHeader As HRESULT = WriteToFileW( _
			hFile, _
			@FileDataBytes, _
			Len(FileDataBytes) _
		)
		If FAILED(hrWriteHeader) Then
			Return hrWriteHeader
		End If
	End Scope
	
	Scope
		Const FileDataBytes = WStr("<head><meta name=""viewport"" content=""width=device-width, initial-scale=1"" /><title>Directory Listing</title></head>")
		
		Dim hrWriteHeader As HRESULT = WriteToFileW( _
			hFile, _
			@FileDataBytes, _
			Len(FileDataBytes) _
		)
		If FAILED(hrWriteHeader) Then
			Return hrWriteHeader
		End If
	End Scope
	
	Scope
		Const FileDataBytes = WStr("<body><h1>Directory Listing</h1>")
		
		Dim hrWriteHeader As HRESULT = WriteToFileW( _
			hFile, _
			@FileDataBytes, _
			Len(FileDataBytes) _
		)
		If FAILED(hrWriteHeader) Then
			Return hrWriteHeader
		End If
	End Scope
	
	Scope
		Scope
			' <a href="/..">/..</a>
			Const FileDataBytes = WStr("<p><a href="".."">..</a></p>")
			WriteToFileW( _
				hFile, _
				FileDataBytes, _
				Len(FileDataBytes) _
			)
		End Scope
		
		Dim FilesInDirCount As Integer = Any
		Dim pFilesInDir As ListingFileItem Ptr = GetFileList( _
			pListingDir, _
			@FilesInDirCount _
		)
		If pFilesInDir = NULL Then
			Return E_OUTOFMEMORY
		End If
		
		qsort( _
			pFilesInDir, _
			FilesInDirCount, _
			SizeOf(ListingFileItem), _
			@CompareListingFileItems _
		)
		
		For i As Integer = 0 To FilesInDirCount - 1
			Scope
				Const FileDataBytes = WStr("<p>")
				WriteToFileW( _
					hFile, _
					@FileDataBytes, _
					Len(FileDataBytes) _
				)
			End Scope
			
			If pFilesInDir[i].IsDirectory Then
				' <a href="ссылка/">ссылка/</a>
				lstrcatW(@pFilesInDir[i].FileName, WStr("/"))
			End If
			
			Scope
				Const FileDataBytes = WStr("<a href=""")
				WriteToFileW( _
					hFile, _
					@FileDataBytes, _
					Len(FileDataBytes) _
				)
			End Scope
			
			Dim FindFileNameLength As Integer = lstrlenW(@pFilesInDir[i].FileName)
			Scope
				WriteToFileW( _
					hFile, _
					@pFilesInDir[i].FileName, _
					FindFileNameLength _
				)
			End Scope
			
			Scope
				Const FileDataBytes = WStr(""">")
				WriteToFileW( _
					hFile, _
					@FileDataBytes, _
					Len(FileDataBytes) _
				)
			End Scope
			
			Scope
				WriteToFileW( _
					hFile, _
					@pFilesInDir[i].FileName, _
					FindFileNameLength _
				)
			End Scope
			
			Scope
				Const FileDataBytes = WStr("</a>")
				WriteToFileW( _
					hFile, _
					@FileDataBytes, _
					Len(FileDataBytes) _
				)
			End Scope
			
			Scope
				Const FileDataBytes = WStr("</p>")
				WriteToFileW( _
					hFile, _
					@FileDataBytes, _
					Len(FileDataBytes) _
				)
			End Scope
			
		Next
		
		free(pFilesInDir)
	End Scope
	
	Scope
		Const FileDataBytes = WStr("</body></html>")
		
		Dim hrWriteHeader As HRESULT = WriteToFileW( _
			hFile, _
			@FileDataBytes, _
			Len(FileDataBytes) _
		)
		If FAILED(hrWriteHeader) Then
			Return hrWriteHeader
		End If
	End Scope
	
	Return S_OK
	
End Function

Private Function GetDirectoryListing( _
		ByVal pListingDir As WString Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal pFileBuffer As IFileStream Ptr, _
		ByVal pFileName As WString Ptr _
	)As HRESULT
	
	Scope
		Const TempPathPrefix = WStr("WebServer")
		
		Dim TempDir As WString * (MAX_PATH + 1) = Any
		Dim resGetTempPath As DWORD = GetTempPathW( _
			MAX_PATH, _
			@TempDir _
		)
		If resGetTempPath = 0 Then
			Dim dwError As DWORD = GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
		Dim resGetTempFileName As UINT = GetTempFileNameW( _
			@TempDir, _
			@TempPathPrefix, _
			0, _
			pFileName _
		)
		If resGetTempFileName = 0 Then
			Dim dwError As DWORD = GetLastError()
			Return HRESULT_FROM_WIN32(dwError)
		End If
		
	End Scope
	
	Dim hListingFile As HANDLE = CreateFileW( _
		pFileName, _
		GENERIC_WRITE, _
		FILE_SHARE_READ Or FILE_SHARE_WRITE Or FILE_SHARE_DELETE, _
		NULL, _
		CREATE_ALWAYS, _
		FILE_ATTRIBUTE_TEMPORARY Or FILE_FLAG_DELETE_ON_CLOSE, _
		NULL _
	)
	If hListingFile = INVALID_HANDLE_VALUE Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Dim hrWriteFileList As HRESULT = WriteDirectoryListingFile( _
		hListingFile, _
		pListingDir _
	)
	If FAILED(hrWriteFileList) Then
		CloseHandle(hListingFile)
		Return hrWriteFileList
	End If
	
	Scope
		Dim hDeleteFile As HANDLE = Any
		Dim hrOpen As HRESULT = GetFileHandle( _
			pFileName, _
			FileAccess.TemporaryAccess, _
			@hDeleteFile _
		)
		If FAILED(hrOpen) Then
			CloseHandle(hListingFile)
			Return hrOpen
		End If
		
		IFileStream_SetFileHandle(pFileBuffer, hDeleteFile)
		Dim fp As HeapBSTR = CreateHeapString( _
			pIMalloc, _
			pFileName _
		)
		If fp = NULL Then
			CloseHandle(hListingFile)
			Return E_OUTOFMEMORY
		End If
		
		IFileStream_SetFilePath(pFileBuffer, fp)
		HeapSysFreeString(fp)
	End Scope
	
	CloseHandle(hListingFile)
	
	Return WEBSITE_S_DIRECTORY_LISTING
	
End Function

Private Function WebSiteOpenRequestedFile( _
		ByVal pPhysicalDirectory As HeapBSTR, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal pFileBuffer As IFileStream Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal fAccess As FileAccess, _
		ByVal DefaultFileName As HeapBSTR, _
		ByVal EnableDirectoryListing As Boolean, _
		ByVal pFileName As WString Ptr _
	)As HRESULT
	
	Scope
		Dim PathLength As Integer = SysStringLen(Path)
		Dim LastChar As Integer = Path[PathLength - 1]
		
		Dim IsLastCharNotSolidus As Boolean = LastChar <> Characters.Solidus
		If IsLastCharNotSolidus Then
			
			WebSiteMapPath( _
				pPhysicalDirectory, _
				Path, _
				pFileName _
			)
			
			Dim hFile As HANDLE = Any
			Dim hrGetFileHandle As HRESULT = GetFileHandle( _
				pFileName, _
				fAccess, _
				@hFile _
			)
			
			IFileStream_SetFilePath(pFileBuffer, Path)
			IFileStream_SetFileHandle(pFileBuffer, hFile)
			
			Return hrGetFileHandle
			
		End If
	End Scope
	
	Scope
		Dim FileListLength As Integer = Any
		Dim DefaultFileNameLength As Integer = SysStringLen(DefaultFileName)
		If DefaultFileNameLength Then
			FileListLength = 1
		Else
			FileListLength = DefaultFileNames + 1
		End If
		
		Dim hrGetFile As HRESULT = E_FAIL
		
		For i As Integer = 0 To FileListLength - 1
			Dim defFilename As WString * (MAX_PATH + 1) = Any
			GetDefaultFileName(@defFilename, i, DefaultFileName)
			
			Dim FullDefaultFilename As WString * (MAX_PATH + 1) = Any
			lstrcpyW(@FullDefaultFilename, Path)
			lstrcatW(@FullDefaultFilename, @defFilename)
			
			WebSiteMapPath( _
				pPhysicalDirectory, _
				@FullDefaultFilename, _
				pFileName _
			)
			
			Dim hFile As HANDLE = Any
			hrGetFile = GetFileHandle( _
				pFileName, _
				fAccess, _
				@hFile _
			)
			
			If SUCCEEDED(hrGetFile) Then
				
				Dim fp As HeapBSTR = CreateHeapString( _
					pIMalloc, _
					@FullDefaultFilename _
				)
				If fp = NULL Then
					Return E_OUTOFMEMORY
				End If
				
				IFileStream_SetFilePath(pFileBuffer, fp)
				IFileStream_SetFileHandle(pFileBuffer, hFile)
				
				HeapSysFreeString(fp)
				
				Return hrGetFile
				
			End If
			
		Next
		
		If EnableDirectoryListing = False Then
			Return hrGetFile
		End If
	End Scope
	
	Scope
		Dim ListingDir As WString * (MAX_PATH + 1) = Any
		
		Scope
			Const AsteriskString = WStr("*")
			
			Dim FullDefaultFilename As WString * (MAX_PATH + 1) = Any
			lstrcpyW(@FullDefaultFilename, Path)
			lstrcatW(@FullDefaultFilename, @AsteriskString)
			
			WebSiteMapPath( _
				pPhysicalDirectory, _
				FullDefaultFilename, _
				@ListingDir _
			)
		End Scope
		
		Dim hrListing As HRESULT = GetDirectoryListing( _
			@ListingDir, _
			pIMalloc, _
			pFileBuffer, _
			pFileName _
		)
		
		Return hrListing
		
	End Scope
	
End Function

Private Sub InitializeWebSite( _
		ByVal this As WebSite Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pIProcessorCollection As IHttpProcessorCollection Ptr, _
		ByVal ErrorPageEncoding As HeapBSTR _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->RttiClassName(0), _
			@Str(RTTI_ID_WEBSITE), _
			UBound(this->RttiClassName) - LBound(this->RttiClassName) + 1 _
		)
	#endif
	this->lpVtbl = @GlobalWebSiteVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pHostName = NULL
	this->pPhysicalDirectory = NULL
	this->pVirtualPath = NULL
	this->pCanonicalUrl = NULL
	this->CodePage = NULL
	this->ListenAddress = NULL
	this->ListenPort = NULL
	this->ConnectBindAddress = NULL
	this->ConnectBindPort = NULL
	this->DefaultFileName = NULL
	this->DirectoryListingEncoding = NULL
	this->ErrorPageEncoding = ErrorPageEncoding
	this->UserName = NULL
	this->Password = NULL
	this->pIProcessorCollection = pIProcessorCollection
	this->UtfBomFileOffset = 0
	this->ReservedFileBytes = 0
	this->IsMoved = False
	this->UseSsl = False
	
End Sub

Private Sub UnInitializeWebSite( _
		ByVal this As WebSite Ptr _
	)
	
	HeapSysFreeString(this->pHostName)
	HeapSysFreeString(this->pPhysicalDirectory)
	HeapSysFreeString(this->pVirtualPath)
	HeapSysFreeString(this->pCanonicalUrl)
	HeapSysFreeString(this->CodePage)
	HeapSysFreeString(this->ListenAddress)
	HeapSysFreeString(this->ListenPort)
	HeapSysFreeString(this->ConnectBindAddress)
	HeapSysFreeString(this->ConnectBindPort)
	HeapSysFreeString(this->DefaultFileName)
	HeapSysFreeString(this->UserName)
	HeapSysFreeString(this->Password)
	If this->pIProcessorCollection Then
		IHttpProcessorCollection_Release(this->pIProcessorCollection)
	End If
	
End Sub

Private Sub WebSiteCreated( _
		ByVal this As WebSite Ptr _
	)
	
End Sub

Private Sub WebSiteDestroyed( _
		ByVal this As WebSite Ptr _
	)
	
End Sub

Private Sub DestroyWebSite( _
		ByVal this As WebSite Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebSite(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	WebSiteDestroyed(this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Private Function WebSiteAddRef( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	Return 1
	
End Function

Private Function WebSiteRelease( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	Return 0
	
End Function

Private Function WebSiteQueryInterface( _
		ByVal this As WebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWebSite, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebSiteAddRef(this)
	
	Return S_OK
	
End Function

Function CreateWebSite( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	Dim pIProcessorCollection As IHttpProcessorCollection Ptr = Any
	Scope
		Dim hrCreate As HRESULT = CreateHttpProcessorCollection( _
			pIMemoryAllocator, _
			@IID_IHttpProcessorCollection, _
			@pIProcessorCollection _
		)
		If FAILED(hrCreate) Then
			*ppv = NULL
			Return E_OUTOFMEMORY
		End If
	End Scope
	
	Dim ErrorPageEncoding As HeapBSTR = Any
	Scope
		Const Utf8EncodingString = WStr("utf-8")
		ErrorPageEncoding = CreatePermanentHeapStringLen( _
			pIMemoryAllocator, _
			@Utf8EncodingString, _
			Len(Utf8EncodingString) _
		)
		If ErrorPageEncoding = NULL Then
			*ppv = NULL
			Return E_OUTOFMEMORY
		End If
	End Scope
	
	Dim this As WebSite Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebSite) _
	)
	
	If this Then
		InitializeWebSite( _
			this, _
			pIMemoryAllocator, _
			pIProcessorCollection, _
			ErrorPageEncoding _
		)
		WebSiteCreated(this)
		
		Dim hrQueryInterface As HRESULT = WebSiteQueryInterface( _
			this, _
			riid, _
			ppv _
		)
		If FAILED(hrQueryInterface) Then
			DestroyWebSite(this)
		End If
		
		Return hrQueryInterface
	End If
	
	*ppv = NULL
	Return E_OUTOFMEMORY
	
End Function

Private Function WebSiteGetHostName( _
		ByVal this As WebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pHostName)
	*ppHost = this->pHostName
	
	Return S_OK
	
End Function

Private Function WebSiteGetSitePhysicalDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pPhysicalDirectory)
	*ppPhysicalDirectory = this->pPhysicalDirectory
	
	Return S_OK
	
End Function

Private Function WebSiteGetVirtualPath( _
		ByVal this As WebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pVirtualPath)
	*ppVirtualPath = this->pVirtualPath
	
	Return S_OK
	
End Function

Private Function WebSiteGetIsMoved( _
		ByVal this As WebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	*pIsMoved = this->IsMoved
	
	Return S_OK
	
End Function

Private Function WebSiteGetMovedUrl( _
		ByVal this As WebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pCanonicalUrl)
	*ppMovedUrl = this->pCanonicalUrl
	
	Return S_OK
	
End Function

Private Function GetFindFileErrorCode( _
		ByVal FileName As WString Ptr, _
		ByVal hrOpenFile As HRESULT _
	)As HRESULT
	
	Dim hrOpenFileTranslate As HRESULT = Any
	
	Select Case hrOpenFile
		
		Case HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND), HRESULT_FROM_WIN32(ERROR_PATH_NOT_FOUND)
			Dim File410 As WString * (MAX_PATH + 1) = Any
			lstrcpyW(@File410, FileName)
			lstrcatW(@File410, @FileGoneExtension)
			
			Dim Attributes As DWORD = GetFileAttributesW( _
				@File410 _
			)
			If Attributes = INVALID_FILE_ATTRIBUTES Then
				hrOpenFileTranslate = WEBSITE_E_FILENOTFOUND
			Else
				hrOpenFileTranslate = WEBSITE_E_FILEGONE
			End If
			
		Case HRESULT_FROM_WIN32(ERROR_ACCESS_DENIED)
			hrOpenFileTranslate = WEBSITE_E_FORBIDDEN
			
		Case Else
			hrOpenFileTranslate = hrOpenFile
			
	End Select
	
	Return hrOpenFileTranslate
	
End Function

Private Function NeedAuthenticate( _
		ByVal fAccess As FileAccess _
	)As Boolean
	
	Select Case fAccess
		
		Case FileAccess.CreateAccess, FileAccess.UpdateAccess, FileAccess.DeleteAccess
			Return True
			
		Case FileAccess.ReadAccess
			' TODO Verify authentication for password-protected resources
			
	End Select
	
	Return False
	
End Function

Private Function WebSiteGetBuffer( _
		ByVal this As WebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal pRequest As IClientRequest Ptr, _
		ByVal pIReader As IHttpReader Ptr, _
		ByVal BufferLength As LongInt, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal ppResult As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	Scope
		Dim NeedAuth As Boolean = NeedAuthenticate(fAccess)
		
		If NeedAuth Then
			Dim hrAuth As HRESULT = WebSiteHttpAuthUtil( _
				this, _
				pRequest, _
				False _
			)
			If FAILED(hrAuth) Then
				*pFlags = ContentNegotiationFlags.None
				*ppResult = NULL
				Return hrAuth
			End If
				
		End If
	End Scope
	
	Dim pIFile As IFileStream Ptr = Any
	Scope
		Dim hrCreateFileBuffer As HRESULT = CreateFileStream( _
			pIMalloc, _
			@IID_IFileStream, _
			@pIFile _
		)
		If FAILED(hrCreateFileBuffer) Then
			*pFlags = ContentNegotiationFlags.None
			*ppResult = NULL
			Return hrCreateFileBuffer
		End If
		
		If fAccess <> FileAccess.DeleteAccess Then
			Dim hrReservedFileBytes As HRESULT = IFileStream_SetReservedFileBytes( _
				pIFile, _
				this->ReservedFileBytes _
			)
			If FAILED(hrReservedFileBytes) Then
				IFileStream_Release(pIFile)
				*pFlags = ContentNegotiationFlags.None
				*ppResult = NULL
				Return hrCreateFileBuffer
			End If
			
			Dim PreloadedBytesLength As Integer = Any
			Dim pPreloadedBytes As UByte Ptr = Any
			IHttpReader_GetPreloadedBytes( _
				pIReader, _
				@PreloadedBytesLength, _
				@pPreloadedBytes _
			)
			
			IFileStream_SetPreloadedBytes( _
				pIFile, _
				PreloadedBytesLength, _
				pPreloadedBytes _
			)
		End If
	End Scope
	
	Dim hrOpenFile As HRESULT = Any
	Dim FileName As WString * (MAX_PATH + 1) = Any
	Scope
		Scope
			Dim ClientURI As IClientUri Ptr = Any
			IClientRequest_GetUri(pRequest, @ClientURI)
			
			Dim Path As HeapBSTR = Any
			IClientUri_GetPath(ClientURI, @Path)
			
			hrOpenFile = WebSiteOpenRequestedFile( _
				this->pPhysicalDirectory, _
				pIMalloc, _
				pIFile, _
				Path, _
				fAccess, _
				this->DefaultFileName, _
				this->EnableDirectoryListing, _
				@FileName _
			)
			HeapSysFreeString(Path)
			IClientUri_Release(ClientURI)
		End Scope
		
		If FAILED(hrOpenFile) Then
			Dim hrOpenFileTranslate As HRESULT = GetFindFileErrorCode( _
				@FileName, _
				hrOpenFile _
			)
			
			IFileStream_Release(pIFile)
			*pFlags = ContentNegotiationFlags.None
			*ppResult = NULL
			Return hrOpenFileTranslate
		End If
		
	End Scope
	
	Dim Mime As MimeType = Any
	Scope
		Select Case fAccess
			
			Case FileAccess.ReadAccess
				Dim resGetMimeOfFileExtension As Boolean = Any
				
				If hrOpenFile = WEBSITE_S_DIRECTORY_LISTING Then
					Mime.ContentType = ContentTypes.TextHtml
					Mime.CharsetWeakPtr = this->DirectoryListingEncoding
					Mime.Format = MimeFormats.Text
					resGetMimeOfFileExtension = True
				Else
					Dim DefaultMime As DefaultMimeIfNotFound = Any
					If this->EnableGetAllFiles Then
						DefaultMime = DefaultMimeIfNotFound.UseApplicationOctetStream
					Else
						DefaultMime = DefaultMimeIfNotFound.UseNone
					End If
					
					resGetMimeOfFileExtension = GetMimeOfFileExtension( _
						@Mime, _
						PathFindExtensionW(FileName), _
						DefaultMime _
					)
				End If
				
				If resGetMimeOfFileExtension = False Then
					IFileStream_Release(pIFile)
					*pFlags = ContentNegotiationFlags.None
					*ppResult = NULL
					Return WEBSITE_E_FORBIDDEN
				End If
				
			Case Else
				/'
				' TODO Get Mime from Content-Type
				' Change File Extension
				Dim pContentType As HeapBSTR = Any
				IClientRequest_GetHttpHeader( _
					pRequest, _
					HttpRequestHeaders.HeaderContentType, _
					@pContentType _
				)
				
				Dim ContentTypeLength As Integer = SysStringLen(pContentType)
				If ContentTypeLength = 0 Then
					HeapSysFreeString(pContentType)
					IFileStream_Release(pIFile)
					*pFlags = ContentNegotiationFlags.None
					*ppResult = NULL
					Return CLIENTREQUEST_E_CONTENTTYPEEMPTY
				End If
				
				HeapSysFreeString(pContentType)
				'/
				
				IFileStream_SetFileSize(pIFile, BufferLength)
				
				*pFlags = ContentNegotiationFlags.None
				*ppResult = CPtr(IAttributedStream Ptr, pIFile)
				
				Return hrOpenFile
				
		End Select
	End Scope
	
	Scope
		Dim ZipFileHandle As HANDLE = Any
		Dim ZipMode As ZipModes = Any
		Dim IsAcceptEncoding As Boolean = Any
		
		If hrOpenFile <> WEBSITE_S_DIRECTORY_LISTING Then
			If Mime.Format = MimeFormats.Text Then
				ZipFileHandle = GetCompressionHandle( _
					FileName, _
					pRequest, _
					@ZipMode, _
					@IsAcceptEncoding _
				)
				
				If ZipFileHandle <> INVALID_HANDLE_VALUE Then
					Dim pIPool As IThreadPool Ptr = GetThreadPoolWeakPtr()
					Dim hrBind As HRESULT = IThreadPool_AssociateDevice( _
						pIPool, _
						ZipFileHandle, _
						ZipFileHandle _
					)
					If FAILED(hrBind) Then
						CloseHandle(ZipFileHandle)
						IFileStream_Release(pIFile)
						*pFlags = ContentNegotiationFlags.None
						*ppResult = NULL
						Return hrBind
					End If
				End If
			Else
				ZipFileHandle = INVALID_HANDLE_VALUE
				ZipMode = ZipModes.None
				IsAcceptEncoding = False
			End If
		Else
			ZipFileHandle = INVALID_HANDLE_VALUE
			ZipMode = ZipModes.None
			IsAcceptEncoding = False
		End If
		
		IFileStream_SetEncoding(pIFile, ZipMode)
		IFileStream_SetZipFileHandle(pIFile, ZipFileHandle)
		
		Dim FileHandle As HANDLE = Any
		IFileStream_GetFileHandle(pIFile, @FileHandle)
		
		Scope
			Dim LastFileModifiedDate As FILETIME = Any
			Dim resFileTime As BOOL = GetFileTime( _
				FileHandle, _
				NULL, _
				NULL, _
				@LastFileModifiedDate _
			)
			If resFileTime = 0 Then
				Dim dwError As DWORD = GetLastError()
				IFileStream_Release(pIFile)
				*pFlags = ContentNegotiationFlags.None
				*ppResult = NULL
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			IFileStream_SetFileTime(pIFile, @LastFileModifiedDate)
			
			Dim ETagBuffer As WString * 256 = Any
			GetETag( _
				@ETagBuffer, _
				@LastFileModifiedDate, _
				ZipMode _
			)
			
			Dim ETag As HeapBSTR = CreateHeapString( _
				pIMalloc, _
				ETagBuffer _
			)
			If ETag = NULL Then
				IFileStream_Release(pIFile)
				*pFlags = ContentNegotiationFlags.None
				*ppResult = NULL
				Return E_OUTOFMEMORY
			End If
			
			IFileStream_SetETag(pIFile, ETag)
			
			HeapSysFreeString(ETag)
		End Scope
		
		Scope
			Dim hRequestedFile As HANDLE = Any
			If ZipFileHandle <> INVALID_HANDLE_VALUE Then
				hRequestedFile = ZipFileHandle
			Else
				hRequestedFile = FileHandle
			End If
			
			Dim FileSize As LARGE_INTEGER = Any
			Dim resGetFileSize As BOOL = GetFileSizeEx( _
				hRequestedFile, _
				@FileSize _
			)
			If resGetFileSize = 0 Then
				Dim dwError As DWORD = GetLastError()
				IFileStream_Release(pIFile)
				*pFlags = ContentNegotiationFlags.None
				*ppResult = NULL
				Return HRESULT_FROM_WIN32(dwError)
			End If
			
			IFileStream_SetFileSize(pIFile, FileSize.QuadPart)
		End Scope
		
		If Mime.Format = MimeFormats.Text Then
			If fAccess = FileAccess.ReadAccess Then
				If hrOpenFile <> WEBSITE_S_DIRECTORY_LISTING Then
					Dim EncodingFileOffset As LongInt = GetFileBytesOffset( _
						this->CodePage, _
						ZipFileHandle, _
						@Mime, _
						this->UtfBomFileOffset _
					)
					
					IFileStream_SetFileOffset(pIFile, EncodingFileOffset)
				End If
			End If
		End If
		
		If IsAcceptEncoding Then
			*pFlags = ContentNegotiationFlags.AcceptEncoding
		End If
		
	End Scope
	
	IFileStream_SetContentType(pIFile, @Mime)
	
	*ppResult = CPtr(IAttributedStream Ptr, pIFile)
	
	Return S_OK
	
End Function

Private Function WebSiteGetErrorBuffer( _
		ByVal this As WebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrErrorCode As HRESULT, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal ppResult As IAttributedStream Ptr Ptr _
	)As HRESULT
	
	Dim pIBuffer As IMemoryStream Ptr = Any
	Dim hrCreateBuffer As HRESULT = CreateMemoryStream( _
		pIMalloc, _
		@IID_IMemoryStream, _
		@pIBuffer _
	)
	If FAILED(hrCreateBuffer) Then
		Return hrCreateBuffer
	End If
	
	Dim Writer As ArrayStringWriter = Any
	InitializeArrayStringWriter(@Writer)
	
	Scope
		Dim BodyBuffer As WString * (MaxHttpErrorBuffer + 1) = Any
		Writer.SetBuffer(@BodyBuffer, MaxHttpErrorBuffer)
		
		Dim pBodyText As WString Ptr = GetErrorBodyText(HttpError)
		FormatMessageErrorBody( _
			Writer, _
			StatusCode, _
			this->pVirtualPath, _
			pBodyText, _
			hrErrorCode _
		)
		
		Dim BodyLength As Integer = Writer.GetLength()
		
		Dim SendBufferLength As Integer = WideCharToMultiByte( _
			CP_UTF8, _
			0, _
			@BodyBuffer, _
			BodyLength, _
			NULL, _
			0, _
			0, _
			0 _
		)
		
		Dim pBuffer As Any Ptr = Any
		Dim hrAllocBuffer As HRESULT = IMemoryStream_AllocBuffer( _
			pIBuffer, _
			SendBufferLength, _
			@pBuffer _
		)
		If FAILED(hrAllocBuffer) Then
			IMemoryStream_Release(pIBuffer)
			Return E_OUTOFMEMORY
		End If
		
		WideCharToMultiByte( _
			CP_UTF8, _
			0, _
			@BodyBuffer, _
			BodyLength, _
			pBuffer, _
			SendBufferLength, _
			0, _
			0 _
		)
		
	End Scope
	
	Dim Mime As MimeType = Any
	With Mime
		.ContentType = ContentTypes.TextHtml
		.CharsetWeakPtr = this->ErrorPageEncoding
		.Format = MimeFormats.Text
	End With
	IMemoryStream_SetContentType(pIBuffer, @Mime)
	
	*ppResult = CPtr(IAttributedStream Ptr, pIBuffer)
	
	Return S_OK
	
End Function

Private Function WebSiteGetProcessorCollectionWeakPtr( _
		ByVal this As WebSite Ptr, _
		ByVal ppResult As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	
	*ppResult = this->pIProcessorCollection
	
	Return S_OK
	
End Function

Private Function WebSiteNeedDllProcessing( _
		ByVal this As WebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	Const CgiDll = WStr("/cgi-dll/")
	
	Dim pSource As WString Ptr = Path
	Dim SourceLength As Integer = SysStringLen(Path)
	Dim pRes As WString Ptr = FindStringIW( _
		pSource, _
		SourceLength, _
		@CgiDll, _
		Len(CgiDll) _
	)
	
	If pRes Then
		*pResult = True
	Else
		*pResult = False
	End If
	
	Return S_OK
	
End Function

Private Function MutableWebSiteSetHostName( _
		ByVal this As WebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pHostName, pHost)
	
	Return S_OK
	
End Function

Private Function MutableWebSiteSetSitePhysicalDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pPhysicalDirectory, pPhysicalDirectory)
	
	Return S_OK
	
End Function

Private Function MutableWebSiteSetVirtualPath( _
		ByVal this As WebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pVirtualPath, pVirtualPath)
	
	Return S_OK
	
End Function

Private Function MutableWebSiteSetIsMoved( _
		ByVal this As WebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	
	this->IsMoved = IsMoved
	
	Return S_OK
	
End Function

Private Function MutableWebSiteSetMovedUrl( _
		ByVal this As WebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pCanonicalUrl, pMovedUrl)
	
	Return S_OK
	
End Function

Private Function WebSiteSetTextFileEncoding( _
		ByVal this As WebSite Ptr, _
		ByVal CodePage As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->CodePage, CodePage)
	
	Return S_OK
	
End Function

Private Function WebSiteSetListenAddress( _
		ByVal this As WebSite Ptr, _
		ByVal ListenAddress As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ListenAddress, ListenAddress)
	
	Return S_OK
	
End Function

Private Function WebSiteSetListenPort( _
		ByVal this As WebSite Ptr, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ListenPort, ListenPort)
	
	Return S_OK
	
End Function

Private Function WebSiteSetConnectBindAddress( _
		ByVal this As WebSite Ptr, _
		ByVal ConnectBindAddress As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ConnectBindAddress, ConnectBindAddress)
	
	Return S_OK
	
End Function

Private Function WebSiteSetConnectBindPort( _
		ByVal this As WebSite Ptr, _
		ByVal ConnectBindPort As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->ConnectBindPort, ConnectBindPort)
	
	Return S_OK
	
End Function

Private Function WebSiteSetDefaultFileName( _
		ByVal this As WebSite Ptr, _
		ByVal DefaultFileName As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->DefaultFileName, DefaultFileName)
	
	Return S_OK
	
End Function

Private Function WebSiteSetUseSsl( _
		ByVal this As WebSite Ptr, _
		ByVal UseSsl As Boolean _
	)As HRESULT
	
	this->UseSsl = UseSsl
	
	Return S_OK
	
End Function

Private Function WebSiteSetReservedFileBytes( _
		ByVal this As WebSite Ptr, _
		ByVal ReservedFileBytes As UInteger _
	)As HRESULT
	
	this->ReservedFileBytes = ReservedFileBytes
	
	Return S_OK
	
End Function

Private Function WebSiteSetUtfBomFileOffset( _
		ByVal this As WebSite Ptr, _
		ByVal Offset As UInteger _
	)As HRESULT
	
	this->UtfBomFileOffset = Offset
	
	Return S_OK
	
End Function

Private Function WebSiteNeedCgiProcessing( _
		ByVal this As WebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	Const CgiBin = WStr("/cgi-bin/")
	
	Dim pSource As WString Ptr = Path
	Dim SourceLength As Integer = SysStringLen(Path)
	Dim pRes As WString Ptr = FindStringIW( _
		pSource, _
		SourceLength, _
		@CgiBin, _
		Len(CgiBin) _
	)
	
	If pRes Then
		*pResult = True
	Else
		*pResult = False
	End If
	
	Return S_OK
	
End Function

Private Function WebSiteSetAddHttpProcessor( _
		ByVal this As WebSite Ptr, _
		ByVal Key As HeapBSTR, _
		ByVal Value As IHttpAsyncProcessor Ptr _
	)As HRESULT
	
	Dim hrAdd As HRESULT = IHttpProcessorCollection_Add( _
		this->pIProcessorCollection, _
		Key, _
		Value _
	)
	If FAILED(hrAdd) Then
		Return hrAdd
	End If
	
	Return S_OK
	
End Function

Private Function WebSiteSetDirectoryListing( _
		ByVal this As WebSite Ptr, _
		ByVal DirectoryListing As Boolean _
	)As HRESULT
	
	this->EnableDirectoryListing = DirectoryListing
	
	If DirectoryListing Then
		Const Utf16EncodingString = WStr("utf-16")
		this->DirectoryListingEncoding = CreatePermanentHeapStringLen( _
			this->pIMemoryAllocator, _
			@Utf16EncodingString, _
			Len(Utf16EncodingString) _
		)
	End If
	
	Return S_OK
	
End Function

Private Function WebSiteSetGetAllFiles( _
		ByVal this As WebSite Ptr, _
		ByVal bGetAllFiles As Boolean _
	)As HRESULT
	
	this->EnableGetAllFiles = bGetAllFiles
	
	Return S_OK
	
End Function

Private Function WebSiteSetAllMethods( _
		ByVal this As WebSite Ptr, _
		ByVal pMethods As HeapBSTR _
	)As HRESULT
	
	IHttpProcessorCollection_SetAllMethods( _
		this->pIProcessorCollection, _
		pMethods _
	)
	
	Return S_OK
	
End Function

Private Function WebSiteSetUserName( _
		ByVal this As WebSite Ptr, _
		ByVal pUserName As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->UserName, pUserName)
	
	Return S_OK
	
End Function

Private Function WebSiteSetPassword( _
		ByVal this As WebSite Ptr, _
		ByVal pPassword As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->Password, pPassword)
	
	Return S_OK
	
End Function


Private Function IMutableWebSiteQueryInterface( _
		ByVal this As IWebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return WebSiteQueryInterface(ContainerOf(this, WebSite, lpVtbl), riid, ppvObject)
End Function

Private Function IMutableWebSiteAddRef( _
		ByVal this As IWebSite Ptr _
	)As ULONG
	Return WebSiteAddRef(ContainerOf(this, WebSite, lpVtbl))
End Function

Private Function IMutableWebSiteRelease( _
		ByVal this As IWebSite Ptr _
	)As ULONG
	Return WebSiteRelease(ContainerOf(this, WebSite, lpVtbl))
End Function

Private Function IMutableWebSiteGetHostName( _
		ByVal this As IWebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetHostName(ContainerOf(this, WebSite, lpVtbl), ppHost)
End Function

Private Function IMutableWebSiteGetSitePhysicalDirectory( _
		ByVal this As IWebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetSitePhysicalDirectory(ContainerOf(this, WebSite, lpVtbl), ppPhysicalDirectory)
End Function

Private Function IMutableWebSiteGetVirtualPath( _
		ByVal this As IWebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetVirtualPath(ContainerOf(this, WebSite, lpVtbl), ppVirtualPath)
End Function

Private Function IMutableWebSiteGetIsMoved( _
		ByVal this As IWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	Return WebSiteGetIsMoved(ContainerOf(this, WebSite, lpVtbl), pIsMoved)
End Function

Private Function IMutableWebSiteGetMovedUrl( _
		ByVal this As IWebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetMovedUrl(ContainerOf(this, WebSite, lpVtbl), ppMovedUrl)
End Function

Private Function IMutableWebSiteGetBuffer( _
		ByVal this As IWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal pRequest As IClientRequest Ptr, _
		ByVal pIReader As IHttpReader Ptr, _
		ByVal BufferLength As LongInt, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal ppResult As IAttributedStream Ptr Ptr _
	)As HRESULT
	Return WebSiteGetBuffer(ContainerOf(this, WebSite, lpVtbl), pIMalloc, fAccess, pRequest, pIReader, BufferLength, pFlags, ppResult)
End Function

Private Function IMutableWebSiteGetErrorBuffer( _
		ByVal this As IWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrErrorCode As HRESULT, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal ppResult As IAttributedStream Ptr Ptr _
	)As HRESULT
	Return WebSiteGetErrorBuffer(ContainerOf(this, WebSite, lpVtbl), pIMalloc, HttpError, hrErrorCode, StatusCode, ppResult)
End Function

Private Function IMutableWebSiteGetProcessorCollectionWeakPtr( _
		ByVal this As IWebSite Ptr, _
		ByVal ppResult As IHttpProcessorCollection Ptr Ptr _
	)As HRESULT
	Return WebSiteGetProcessorCollectionWeakPtr(ContainerOf(this, WebSite, lpVtbl), ppResult)
End Function

Private Function IMutableWebSiteSetHostName( _
		ByVal this As IWebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetHostName(ContainerOf(this, WebSite, lpVtbl), pHost)
End Function

Private Function IMutableWebSiteSetSitePhysicalDirectory( _
		ByVal this As IWebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetSitePhysicalDirectory(ContainerOf(this, WebSite, lpVtbl), pPhysicalDirectory)
End Function

Private Function IMutableWebSiteSetVirtualPath( _
		ByVal this As IWebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetVirtualPath(ContainerOf(this, WebSite, lpVtbl), pVirtualPath)
End Function

Private Function IMutableWebSiteSetIsMoved( _
		ByVal this As IWebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	Return MutableWebSiteSetIsMoved(ContainerOf(this, WebSite, lpVtbl), IsMoved)
End Function

Private Function IMutableWebSiteSetMovedUrl( _
		ByVal this As IWebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetMovedUrl(ContainerOf(this, WebSite, lpVtbl), pMovedUrl)
End Function

Private Function IMutableWebSiteSetTextFileEncoding( _
		ByVal this As IWebSite Ptr, _
		ByVal CodePage As HeapBSTR _
	)As HRESULT
	Return WebSiteSetTextFileEncoding(ContainerOf(this, WebSite, lpVtbl), CodePage)
End Function

Private Function IWebSiteSetUtfBomFileOffset( _
		ByVal this As IWebSite Ptr, _
		ByVal Offset As UInteger _
	)As HRESULT
	Return WebSiteSetUtfBomFileOffset(ContainerOf(this, WebSite, lpVtbl), Offset)
End Function

Private Function IMutableWebSiteSetListenAddress( _
		ByVal this As IWebSite Ptr, _
		ByVal ListenAddress As HeapBSTR _
	)As HRESULT
	Return WebSiteSetListenAddress(ContainerOf(this, WebSite, lpVtbl), ListenAddress)
End Function

Private Function IMutableWebSiteSetListenPort( _
		ByVal this As IWebSite Ptr, _
		ByVal ListenPort As HeapBSTR _
	)As HRESULT
	Return WebSiteSetListenPort(ContainerOf(this, WebSite, lpVtbl), ListenPort)
End Function

Private Function IMutableWebSiteSetConnectBindAddress( _
		ByVal this As IWebSite Ptr, _
		ByVal ConnectBindAddress As HeapBSTR _
	)As HRESULT
	Return WebSiteSetConnectBindAddress(ContainerOf(this, WebSite, lpVtbl), ConnectBindAddress)
End Function

Private Function IMutableWebSiteSetConnectBindPort( _
		ByVal this As IWebSite Ptr, _
		ByVal ConnectBindPort As HeapBSTR _
	)As HRESULT
	Return WebSiteSetConnectBindPort(ContainerOf(this, WebSite, lpVtbl), ConnectBindPort)
End Function

Private Function IMutableWebSiteSetDefaultFileName( _
		ByVal this As IWebSite Ptr, _
		ByVal DefaultFileName As HeapBSTR _
	)As HRESULT
	Return WebSiteSetDefaultFileName(ContainerOf(this, WebSite, lpVtbl), DefaultFileName)
End Function

Private Function IMutableWebSiteSetUseSsl( _
		ByVal this As IWebSite Ptr, _
		ByVal UseSsl As Boolean _
	)As HRESULT
	Return WebSiteSetUseSsl(ContainerOf(this, WebSite, lpVtbl), UseSsl)
End Function

Private Function IMutableWebSetReservedFileBytes( _
		ByVal this As IWebSite Ptr, _
		ByVal ReservedFileBytes As UInteger _
	)As HRESULT
	Return WebSiteSetReservedFileBytes(ContainerOf(this, WebSite, lpVtbl), ReservedFileBytes)
End Function

Private Function IMutableWebSetAddHttpProcessor( _
		ByVal this As IWebSite Ptr, _
		ByVal Key As HeapBSTR, _
		ByVal Value As IHttpAsyncProcessor Ptr _
	)As HRESULT
	Return WebSiteSetAddHttpProcessor(ContainerOf(this, WebSite, lpVtbl), Key, Value)
End Function

Private Function IMutableWebSiteNeedCgiProcessing( _
		ByVal this As IWebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	Return WebSiteNeedCgiProcessing(ContainerOf(this, WebSite, lpVtbl), Path, pResult)
End Function

Private Function IMutableWebSiteSetDirectoryListing( _
		ByVal this As IWebSite Ptr, _
		ByVal DirectoryListing As Boolean _
	)As HRESULT
	Return WebSiteSetDirectoryListing(ContainerOf(this, WebSite, lpVtbl), DirectoryListing)
End Function

Private Function IMutableWebSiteSetGetAllFiles( _
		ByVal this As IWebSite Ptr, _
		ByVal bGetAllFiles As Boolean _
	)As HRESULT
	Return WebSiteSetGetAllFiles(ContainerOf(this, WebSite, lpVtbl), bGetAllFiles)
End Function

Private Function IMutableWebSiteSetAllMethods( _
		ByVal this As IWebSite Ptr, _
		ByVal pMethods As HeapBSTR _
	)As HRESULT
	Return WebSiteSetAllMethods(ContainerOf(this, WebSite, lpVtbl), pMethods)
End Function

Private Function IMutableWebSiteSetUserName( _
		ByVal this As IWebSite Ptr, _
		ByVal pUserName As HeapBSTR _
	)As HRESULT
	Return WebSiteSetUserName(ContainerOf(this, WebSite, lpVtbl), pUserName)
End Function

Private Function IMutableWebSiteSetPassword( _
		ByVal this As IWebSite Ptr, _
		ByVal pPassword As HeapBSTR _
	)As HRESULT
	Return WebSiteSetPassword(ContainerOf(this, WebSite, lpVtbl), pPassword)
End Function

Dim GlobalWebSiteVirtualTable As Const IWebSiteVirtualTable = Type( _
	@IMutableWebSiteQueryInterface, _
	@IMutableWebSiteAddRef, _
	@IMutableWebSiteRelease, _
	@IMutableWebSiteGetHostName, _
	@IMutableWebSiteGetSitePhysicalDirectory, _
	@IMutableWebSiteGetVirtualPath, _
	@IMutableWebSiteGetIsMoved, _
	@IMutableWebSiteGetMovedUrl, _
	@IMutableWebSiteGetBuffer, _
	@IMutableWebSiteGetErrorBuffer, _
	@IMutableWebSiteGetProcessorCollectionWeakPtr, _
	@IMutableWebSiteSetHostName, _
	@IMutableWebSiteSetSitePhysicalDirectory, _
	@IMutableWebSiteSetVirtualPath, _
	@IMutableWebSiteSetIsMoved, _
	@IMutableWebSiteSetMovedUrl, _
	@IMutableWebSiteSetTextFileEncoding, _
	@IWebSiteSetUtfBomFileOffset, _
	@IMutableWebSiteSetListenAddress, _
	@IMutableWebSiteSetListenPort, _
	@IMutableWebSiteSetConnectBindAddress, _
	@IMutableWebSiteSetConnectBindPort, _
	@IMutableWebSiteSetUseSsl, _
	@IMutableWebSiteSetDefaultFileName, _
	@IMutableWebSetReservedFileBytes, _
	@IMutableWebSetAddHttpProcessor, _
	@IMutableWebSiteNeedCgiProcessing, _
	@IMutableWebSiteSetDirectoryListing, _
	@IMutableWebSiteSetGetAllFiles, _
	@IMutableWebSiteSetAllMethods, _
	@IMutableWebSiteSetUserName, _
	@IMutableWebSiteSetPassword _
)
