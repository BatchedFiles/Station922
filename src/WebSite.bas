#include once "WebSite.bi"
#include once "win\shlwapi.bi"
#include once "ArrayStringWriter.bi"
#include once "CharacterConstants.bi"
#include once "ContainerOf.bi"
#include once "CreateInstance.bi"
#include once "FileBuffer.bi"
#include once "HeapBSTR.bi"
#include once "IArrayStringWriter.bi"
#include once "Logger.bi"
#include once "MemoryBuffer.bi"
#include once "Mime.bi"

Extern GlobalWebSiteVirtualTable As Const IWebSiteVirtualTable

Const WEBSITE_MAXDEFAULTFILENAMELENGTH As Integer = 16 - 1
Const MaxHostNameLength As Integer = 1024 - 1
Const DefaultFileNames As Integer = 8

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
Const MaxHttpErrorBuffer As Integer = 16 * 1024 - 1

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

Const DefaultVirtualPath = WStr("/")

Type _WebSite
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWebSiteVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	pHostName As HeapBSTR
	pPhysicalDirectory As HeapBSTR
	pVirtualPath As HeapBSTR
	pMovedUrl As HeapBSTR
	IsMoved As Boolean
End Type

Sub FormatMessageErrorBody( _
		ByVal pIWriter As IArrayStringWriter Ptr, _
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
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartHeadTag)
	IArrayStringWriter_WriteString(pIWriter, HttpStartTitleTag)
	IArrayStringWriter_WriteString(pIWriter, DescriptionBuffer)
	IArrayStringWriter_WriteString(pIWriter, HttpEndTitleTag)
	IArrayStringWriter_WriteString(pIWriter, HttpEndHeadTag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartBodyTag)
	IArrayStringWriter_WriteString(pIWriter, HttpStartH1Tag)
	IArrayStringWriter_WriteString(pIWriter, DescriptionBuffer)
	IArrayStringWriter_WriteString(pIWriter, HttpEndH1Tag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartPTag)
	
	Select Case StatusCode
		
		Case 300 To 399
			IArrayStringWriter_WriteString(pIWriter, ClientMovedString)
			
		Case 400 To 499
			IArrayStringWriter_WriteString(pIWriter, ClientErrorString)
			
		Case 500 To 599
			IArrayStringWriter_WriteString(pIWriter, ServerErrorString)
			
	End Select
	
	IArrayStringWriter_WriteString(pIWriter, HttpErrorInApplicationString)
	IArrayStringWriter_WriteLengthString(pIWriter, VirtualPath, SysStringLen(VirtualPath))
	IArrayStringWriter_WriteString(pIWriter, HttpEndPTag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartH2Tag)
	IArrayStringWriter_WriteString(pIWriter, HttpStatusCodeString)
	IArrayStringWriter_WriteInt32(pIWriter, StatusCode)
	IArrayStringWriter_WriteString(pIWriter, HttpEndH2Tag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartPTag)
	IArrayStringWriter_WriteString(pIWriter, BodyText)
	IArrayStringWriter_WriteString(pIWriter, HttpEndPTag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartH2Tag)
	IArrayStringWriter_WriteString(pIWriter, HttpHresultErrorCodeString)
	IArrayStringWriter_WriteString(pIWriter, HttpEndH2Tag)
	
	IArrayStringWriter_WriteString(pIWriter, HttpStartPTag)
	IArrayStringWriter_WriteUInt32(pIWriter, hrErrorCode)
	IArrayStringWriter_WriteString(pIWriter, HttpEndPTag)
	
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
		IArrayStringWriter_WriteString(pIWriter, HttpStartPTag)
		IArrayStringWriter_WriteString(pIWriter, wBuffer)
		IArrayStringWriter_WriteString(pIWriter, HttpEndPTag)
	End If
	
	IArrayStringWriter_WriteString(pIWriter, HttpEndBodyTag)
	
End Sub

Function GetErrorBodyText( _
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

Sub GetETag( _
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

Function GetDefaultFileName( _
		ByVal Buffer As WString Ptr, _
		ByVal Index As Integer _
	)As Boolean
	
	Const DefaultFileNameDefaultXml = WStr("default.xml")
	Const DefaultFileNameDefaultXhtml = WStr("default.xhtml")
	Const DefaultFileNameDefaultHtm = WStr("default.htm")
	Const DefaultFileNameDefaultHtml = WStr("default.html")
	Const DefaultFileNameIndexXml = WStr("index.xml")
	Const DefaultFileNameIndexXhtml = WStr("index.xhtml")
	Const DefaultFileNameIndexHtm = WStr("index.htm")
	Const DefaultFileNameIndexHtml = WStr("index.html")
	
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

Function GetFileHandle( _
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
				GENERIC_READ Or GENERIC_WRITE, _
				0, _
				NULL, _
				CREATE_ALWAYS, _
				FILE_ATTRIBUTE_NORMAL, _
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
			
		Case FileAccess.ReadAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				GENERIC_READ, _
				FILE_SHARE_READ, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL, _
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
				GENERIC_READ Or GENERIC_WRITE, _
				0, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL, _
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
			
		Case Else ' FileAccess.DeleteAccess
			FileHandle = CreateFileW( _
				PathTranslated, _
				0, _
				0, _
				NULL, _
				OPEN_EXISTING, _
				FILE_ATTRIBUTE_NORMAL Or FILE_FLAG_DELETE_ON_CLOSE, _
				NULL _
			)
			If FileHandle = INVALID_HANDLE_VALUE Then
				Dim dwError As DWORD = GetLastError()
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				hrErrorCode = S_OK
			End If
			
	End Select
	
	*pFileHandle = FileHandle
	Return hrErrorCode
	
End Function

Function GetFileMappingHandle( _
		ByVal FileHandle As HANDLE, _
		ByVal fAccess As FileAccess, _
		ByVal FileLength As LongInt, _
		ByVal pFileMapHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim FileMapHandle As HANDLE = Any
	Dim hrErrorCode As HRESULT = Any
	
	Dim liFileSize As LARGE_INTEGER = Any
	liFileSize.QuadPart = FileLength
	
	Select Case fAccess
		
		Case FileAccess.CreateAccess, FileAccess.UpdateAccess
			FileMapHandle = CreateFileMappingW( _
				FileHandle, _
				NULL, _
				PAGE_READWRITE, _
				liFileSize.HighPart, liFileSize.LowPart, _
				NULL _
			)
			If FileMapHandle = NULL Then
				Dim dwError As DWORD = GetLastError()
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				hrErrorCode = S_OK
			End If
			
		Case FileAccess.ReadAccess
			FileMapHandle = CreateFileMappingW( _
				FileHandle, _
				NULL, _
				PAGE_READONLY, _
				liFileSize.HighPart, liFileSize.LowPart, _
				NULL _
			)
			If FileMapHandle = NULL Then
				Dim dwError As DWORD = GetLastError()
				hrErrorCode = HRESULT_FROM_WIN32(dwError)
			Else
				hrErrorCode = S_OK
			End If
			
		Case Else ' FileAccess.DeleteAccess
			FileMapHandle = NULL
			hrErrorCode = S_OK
			
	End Select
	
	*pFileMapHandle = FileMapHandle
	Return hrErrorCode
	
End Function

Sub ReplaceSolidus( _
		ByVal pBuffer As WString Ptr, _
		ByVal Length As Integer _
	)
	
	For i As Integer = 0 To Length - 1
		If pBuffer[i] = Characters.Solidus Then
			pBuffer[i] = Characters.ReverseSolidus
		End If
	Next
	
End Sub

Function GetCompressionHandle( _
		ByVal PathTranslated As WString Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pZipMode As ZipModes Ptr, _
		ByVal pEncodingVaryFlag As Boolean Ptr _
	)As Handle
	
	*pEncodingVaryFlag = False
	
	Scope
		Const GzipExtensionString = WStr(".gz")
		
		Dim GZipFileName As WString * (MAX_PATH + 1) = Any
		lstrcpyW(@GZipFileName, PathTranslated)
		lstrcatW(@GZipFileName, @GZipExtensionString)
		
		Dim hFile As HANDLE = CreateFileW( _
			@GZipFileName, _
			GENERIC_READ, _
			FILE_SHARE_READ, _
			NULL, _
			OPEN_EXISTING, _
			FILE_ATTRIBUTE_NORMAL, _
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
			FILE_ATTRIBUTE_NORMAL, _
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

Function GetDocumentCharset( _
		ByVal bytes As ZString Ptr _
	)As DocumentCharsets
	
	Dim byte1 As UByte = bytes[0]
	
	Select Case byte1
		
		Case 239
			Dim byte2 As UByte = bytes[1]
			If byte2 = 187 Then
				Dim byte3 As UByte = bytes[2]
				If byte3 = 191 Then
					Return DocumentCharsets.Utf8BOM
				End If
			End If
			
		Case 254
			Dim byte2 As UByte = bytes[1]
			If byte2 = 255 Then
				Return DocumentCharsets.Utf16BE
			End If
			
		Case 255
			Dim byte2 As UByte = bytes[1]
			If byte2 = 254 Then
				Return DocumentCharsets.Utf16LE
			End If
			
	End Select
	
	Return DocumentCharsets.ASCII
	
End Function

Function GetFileBytesOffset( _
		ByVal mt As MimeType Ptr, _
		ByVal FileBytes As ZString Ptr, _
		ByVal hZipFile As HANDLE _
	)As LongInt
	
	Dim offset As LongInt = Any
	
	If mt->IsTextFormat Then
		
		mt->Charset = GetDocumentCharset(FileBytes)
		
		If hZipFile <> INVALID_HANDLE_VALUE Then
			offset = 0
		Else
			
			Select Case mt->Charset
				
				Case DocumentCharsets.Utf8BOM
					offset = 3
					
				Case DocumentCharsets.Utf16LE
					offset = 0
					
				Case DocumentCharsets.Utf16BE
					offset = 2
					
				Case Else
					offset = 0
					
			End Select
		End If
		
	Else
		offset = 0
	End If
	
	Return offset
	
End Function

Function WebSiteMapPath( _
		ByVal this As WebSite Ptr, _
		ByVal pPath As WString Ptr, _
		ByVal pBuffer As WString Ptr _
	)As HRESULT
	
	lstrcpyW(pBuffer, this->pPhysicalDirectory)
	
	Scope
		Dim BufferLength As Integer = SysStringLen(this->pPhysicalDirectory)
		
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

Function WebSiteOpenRequestedFile( _
		ByVal this As WebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal pFileBuffer As IFileBuffer Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pFileName As WString Ptr, _
		ByVal fAccess As FileAccess _
	)As HRESULT
	
	Dim PathLength As Integer = SysStringLen(Path)
	Dim LastChar As Integer = Path[PathLength - 1]
	
	Dim IsLastCharNotSolidus As Boolean = LastChar <> Characters.Solidus
	If IsLastCharNotSolidus Then
		
		WebSiteMapPath(this, Path, pFileName)
		
		Dim hFile As HANDLE = Any
		Dim hrGetFileHandle As HRESULT = GetFileHandle( _
			pFileName, _
			fAccess, _
			@hFile _
		)
		
		IFileBuffer_SetFilePath(pFileBuffer, Path)
		IFileBuffer_SetFileHandle(pFileBuffer, hFile)
		
		Return hrGetFileHandle
		
	End If
	
	Dim FullDefaultFilename As WString * (MAX_PATH + 1) = Any
	Dim hrGetFile As HRESULT = Any
	
	For i As Integer = 0 To DefaultFileNames
		Dim DefaultFilename As WString * (WEBSITE_MAXDEFAULTFILENAMELENGTH + 1) = Any
		GetDefaultFileName(@DefaultFilename, i)
		
		lstrcpyW(@FullDefaultFilename, Path)
		lstrcatW(@FullDefaultFilename, DefaultFilename)
		
		WebSiteMapPath(this, @FullDefaultFilename, pFileName)
		
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
			
			IFileBuffer_SetFilePath(pFileBuffer, fp)
			IFileBuffer_SetFileHandle(pFileBuffer, hFile)
			
			HeapSysFreeString(fp)
			
			Return S_OK
			
		End If
		
	Next
	
	Return hrGetFile
	
End Function

Sub InitializeWebSite( _
		ByVal this As WebSite Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_WEBSITE), _
			Len(WebSite.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalWebSiteVirtualTable
	this->ReferenceCounter = CUInt(-1)
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pHostName = NULL
	this->pPhysicalDirectory = NULL
	this->pVirtualPath = NULL
	this->pMovedUrl = NULL
	this->IsMoved = False
	
End Sub

Sub UnInitializeWebSite( _
		ByVal this As WebSite Ptr _
	)
	
	HeapSysFreeString(this->pHostName)
	HeapSysFreeString(this->pPhysicalDirectory)
	HeapSysFreeString(this->pVirtualPath)
	HeapSysFreeString(this->pMovedUrl)
	
End Sub

Function CreatePermanentWebSite( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WebSite Ptr
	
	Dim this As WebSite Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebSite) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeWebSite(this, pIMemoryAllocator)
	
	Return this
	
End Function

Sub DestroyWebSite( _
		ByVal this As WebSite Ptr _
	)
	
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebSite(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WebSiteQueryInterface( _
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

Function WebSiteAddRef( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	Return 1
	
End Function

Function WebSiteRelease( _
		ByVal this As WebSite Ptr _
	)As ULONG
	
	Return 0
	
End Function

Function WebSiteGetHostName( _
		ByVal this As WebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pHostName)
	*ppHost = this->pHostName
	
	Return S_OK
	
End Function

Function WebSiteGetSitePhysicalDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pPhysicalDirectory)
	*ppPhysicalDirectory = this->pPhysicalDirectory
	
	Return S_OK
	
End Function

Function WebSiteGetVirtualPath( _
		ByVal this As WebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pVirtualPath)
	*ppVirtualPath = this->pVirtualPath
	
	Return S_OK
	
End Function

Function WebSiteGetIsMoved( _
		ByVal this As WebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	*pIsMoved = this->IsMoved
	
	Return S_OK
	
End Function

Function WebSiteGetMovedUrl( _
		ByVal this As WebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	
	HeapSysAddRefString(this->pMovedUrl)
	*ppMovedUrl = this->pMovedUrl
	
	Return S_OK
	
End Function

Function WebSiteGetBuffer( _
		ByVal this As WebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal pRequest As IClientRequest Ptr, _
		ByVal BufferLength As LongInt, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	
	Dim pIFile As IFileBuffer Ptr = Any
	Scope
		Dim hrCreateFileBuffer As HRESULT = CreateInstance( _
			pIMalloc, _
			@CLSID_FILEBUFFER, _
			@IID_IFileBuffer, _
			@pIFile _
		)
		If FAILED(hrCreateFileBuffer) Then
			*pFlags = ContentNegotiationFlags.ContentNegotiationNone
			*ppResult = NULL
			Return hrCreateFileBuffer
		End If
	End Scope
	
	Dim FileName As WString * (MAX_PATH + 1) = Any
	
	Scope
		Dim ClientURI As IClientUri Ptr = Any
		IClientRequest_GetUri(pRequest, @ClientURI)
		
		Dim Path As HeapBSTR = Any
		IClientUri_GetPath(ClientURI, @Path)
		
		Dim hrOpenFile As HRESULT = WebSiteOpenRequestedFile( _
			this, _
			pIMalloc, _
			pIFile, _
			Path, _
			@FileName, _
			fAccess _
		)
		HeapSysFreeString(Path)
		IClientUri_Release(ClientURI)
		
		If FAILED(hrOpenFile) Then
			Dim hrOpenFileTranslate As HRESULT = Any
			
			If hrOpenFile = HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND) Then
				
				Dim File410 As WString * (MAX_PATH + 1) = Any
				lstrcpyW(@File410, @FileName)
				lstrcatW(@File410, @FileGoneExtension)
				
				Dim Attributes As DWORD = GetFileAttributesW( _
					@File410 _
				)
				If Attributes = INVALID_FILE_ATTRIBUTES Then
					hrOpenFileTranslate = WEBSITE_E_FILENOTFOUND
				Else
					hrOpenFileTranslate = WEBSITE_E_FILEGONE
				End If
				
			Else
				hrOpenFileTranslate = hrOpenFile
			End If
			
			IFileBuffer_Release(pIFile)
			*pFlags = ContentNegotiationFlags.ContentNegotiationNone
			*ppResult = NULL
			Return hrOpenFileTranslate
		End If
		
	End Scope
	
	Dim Mime As MimeType = Any
	
	Scope
		Dim resGetMimeOfFileExtension As Boolean = GetMimeOfFileExtension( _
			@Mime, _
			PathFindExtensionW(FileName) _
		)
		If resGetMimeOfFileExtension = False Then
			IFileBuffer_Release(pIFile)
			*pFlags = ContentNegotiationFlags.ContentNegotiationNone
			*ppResult = NULL
			Return WEBSITE_E_FORBIDDEN
		End If
		
		' TODO Проверить идентификацию для запароленных ресурсов
		
	End Scope
	
	' В основном анализируются заголовки
	' Accept-Encoding: gzip, deflate
	' Accept: text/css, */*
	' Accept-Charset: utf-8
	' Accept-Language: ru-RU
	' User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36 Edge/15.15063
	
	Scope
		Dim ZipFileHandle As HANDLE = Any
		Dim ZipMode As ZipModes = Any
		Dim IsAcceptEncoding As Boolean = Any
		
		If Mime.IsTextFormat Then
			ZipFileHandle = GetCompressionHandle( _
				FileName, _
				pRequest, _
				@ZipMode, _
				@IsAcceptEncoding _
			)
		Else
			ZipFileHandle = INVALID_HANDLE_VALUE
			ZipMode = ZipModes.None
			IsAcceptEncoding = False
		End If
		
		IFileBuffer_SetEncoding(pIFile, ZipMode)
		IFileBuffer_SetZipFileHandle(pIFile, ZipFileHandle)
		
		Dim FileHandle As HANDLE = Any
		IFileBuffer_GetFileHandle(pIFile, @FileHandle)
		
		Scope
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
					IFileBuffer_Release(pIFile)
					*pFlags = ContentNegotiationFlags.ContentNegotiationNone
					*ppResult = NULL
					Return HRESULT_FROM_WIN32(dwError)
				End If
				
				IFileBuffer_SetFileTime(pIFile, @LastFileModifiedDate)
				
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
				IFileBuffer_SetETag(pIFile, ETag)
				
				HeapSysFreeString(ETag)
			End Scope
			
			Dim hRequestedFile As HANDLE = Any
			If ZipFileHandle <> INVALID_HANDLE_VALUE Then
				hRequestedFile = ZipFileHandle
			Else
				hRequestedFile = FileHandle
			End If
			
			Dim FileLength As LongInt = Any
			
			Select Case fAccess
				Case FileAccess.CreateAccess
					FileLength = BufferLength
					
				Case FileAccess.ReadAccess, FileAccess.UpdateAccess
					Dim FileSize As LARGE_INTEGER = Any
					Dim resGetFileSize As BOOL = GetFileSizeEx( _
						hRequestedFile, _
						@FileSize _
					)
					If resGetFileSize = 0 Then
						Dim dwError As DWORD = GetLastError()
						IFileBuffer_Release(pIFile)
						*pFlags = ContentNegotiationFlags.ContentNegotiationNone
						*ppResult = NULL
						Return HRESULT_FROM_WIN32(dwError)
					End If
					
					FileLength = FileSize.QuadPart
					
				Case Else ' FileAccess.DeleteAccess
					FileLength = 0
					
			End Select
			
			Dim hMapFile As HANDLE = Any
			Dim hrGetFileMappingHandle As HRESULT = GetFileMappingHandle( _
				hRequestedFile, _
				fAccess, _
				FileLength, _
				@hMapFile _
			)
			If FAILED(hrGetFileMappingHandle) Then
				IFileBuffer_Release(pIFile)
				*pFlags = ContentNegotiationFlags.ContentNegotiationNone
				*ppResult = NULL
				Return hrGetFileMappingHandle
			End If
			
			IFileBuffer_SetFileMappingHandle( _
				pIFile, _
				fAccess, _
				hMapFile _
			)
			
			IFileBuffer_SetFileSize(pIFile, FileLength)
		End Scope
		
		Scope
			Dim FileBytes As ZString Ptr = Any
			Dim hMapOroginalFileHandle As HANDLE = Any
			
			If ZipFileHandle <> INVALID_HANDLE_VALUE Then
				
				Dim FileSize As LARGE_INTEGER = Any
				Dim resGetFileSize As BOOL = GetFileSizeEx( _
					FileHandle, _
					@FileSize _
				)
				If resGetFileSize = 0 Then
					Dim dwError As DWORD = GetLastError()
					IFileBuffer_Release(pIFile)
					*pFlags = ContentNegotiationFlags.ContentNegotiationNone
					*ppResult = NULL
					Return HRESULT_FROM_WIN32(dwError)
				End If
				
				If FileSize.QuadPart <= 3 Then
					FileBytes = NULL
					hMapOroginalFileHandle = NULL
				Else
					Dim hrGetFileMappingHandle As HRESULT = GetFileMappingHandle( _
						FileHandle, _
						FileAccess.ReadAccess, _
						0, _
						@hMapOroginalFileHandle _
					)
					If FAILED(hrGetFileMappingHandle) Then
						IFileBuffer_Release(pIFile)
						*pFlags = ContentNegotiationFlags.ContentNegotiationNone
						*ppResult = NULL
						Return hrGetFileMappingHandle
					End If
					
					FileBytes = MapViewOfFile( _
						hMapOroginalFileHandle, _
						FILE_MAP_READ, _
						0, 0, _
						16 _
					)
					If FileBytes = NULL Then
						Dim dwError As DWORD = GetLastError()
						CloseHandle(hMapOroginalFileHandle)
						IFileBuffer_Release(pIFile)
						*pFlags = ContentNegotiationFlags.ContentNegotiationNone
						*ppResult = NULL
						Return HRESULT_FROM_WIN32(dwError)
					End If
				End If
			Else
				hMapOroginalFileHandle = NULL
				Dim Slice As BufferSlice = Any
				Dim hrSlice As HRESULT = IFileBuffer_GetSlice( _
					pIFile, _
					0, _
					BUFFERSLICECHUNK_SIZE, _
					@Slice _
				)
				If FAILED(hrSlice) Then
					IFileBuffer_Release(pIFile)
					*pFlags = ContentNegotiationFlags.ContentNegotiationNone
					*ppResult = NULL
					Return hrSlice
				End If
				
				FileBytes = Slice.pSlice
			End If
			
			Scope
				Dim EncodingFileOffset As LongInt = GetFileBytesOffset( _
					@Mime, _
					FileBytes, _
					ZipFileHandle _
				)
				
				IFileBuffer_SetFileOffset(pIFile, EncodingFileOffset)
				
				If IsAcceptEncoding Then
					*pFlags = ContentNegotiationFlags.ContentNegotiationNone Or ContentNegotiationFlags.ContentNegotiationAcceptEncoding
				End If
			End Scope
			
			If ZipFileHandle <> INVALID_HANDLE_VALUE Then
				If FileBytes Then
					UnmapViewOfFile(FileBytes)
				End If
				
				If hMapOroginalFileHandle Then
					CloseHandle(hMapOroginalFileHandle)
				End If
			End If
			
		End Scope
		
	End Scope
	
	IFileBuffer_SetContentType(pIFile, @Mime)
	
	' AddExtendedHeaders(pc->pIResponse, pc->pIRequestedFile)
	
	*ppResult = CPtr(IBuffer Ptr, pIFile)
	
	Return S_OK
	
End Function

Function WebSiteGetErrorBuffer( _
		ByVal this As WebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrErrorCode As HRESULT, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	
	Dim pIBuffer As IMemoryBuffer Ptr = Any
	Dim hrCreateBuffer As HRESULT = CreateInstance( _
		pIMalloc, _
		@CLSID_MEMORYBUFFER, _
		@IID_IMemoryBuffer, _
		@pIBuffer _
	)
	If FAILED(hrCreateBuffer) Then
		Return hrCreateBuffer
	End If
	
	Dim pIWriter As IArrayStringWriter Ptr = Any
	Dim hrCreateArrayStringWriter As HRESULT = CreateInstance( _
		pIMalloc, _
		@CLSID_ARRAYSTRINGWRITER, _
		@IID_IArrayStringWriter, _
		@pIWriter _
	)
	If FAILED(hrCreateArrayStringWriter) Then
		IMemoryBuffer_Release(pIBuffer)
		Return hrCreateArrayStringWriter
	End If
	
	Scope
		Dim BodyBuffer As WString * (MaxHttpErrorBuffer + 1) = Any
		IArrayStringWriter_SetBuffer(pIWriter, @BodyBuffer, MaxHttpErrorBuffer)
		
		Dim pBodyText As WString Ptr = GetErrorBodyText(HttpError)
		FormatMessageErrorBody( _
			pIWriter, _
			StatusCode, _
			this->pVirtualPath, _
			pBodyText, _
			hrErrorCode _
		)
		
		Dim BodyLength As Integer = Any
		IArrayStringWriter_GetLength(pIWriter, @BodyLength)
		
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
		Dim hrAllocBuffer As HRESULT = IMemoryBuffer_AllocBuffer( _
			pIBuffer, _
			SendBufferLength, _
			@pBuffer _
		)
		If FAILED(hrAllocBuffer) Then
			IArrayStringWriter_Release(pIWriter)
			IMemoryBuffer_Release(pIBuffer)
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
	
	IArrayStringWriter_Release(pIWriter)
	
	Dim Mime As MimeType = Any
	With Mime
		.ContentType = ContentTypes.TextHtml
		.Charset = DocumentCharsets.Utf8BOM
		.IsTextFormat = True
	End With
	IMemoryBuffer_SetContentType(pIBuffer, @Mime)
	
	*ppResult = CPtr(IBuffer Ptr, pIBuffer)
	
	Return S_OK
	
End Function

Function WebSiteNeedDllProcessing( _
		ByVal this As WebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	If StrStrIW(Path, WStr("/cgi-dll/")) = NULL Then
		*pResult = False
	Else
		*pResult = True
	End If
	
	Return S_OK
	
End Function

Function MutableWebSiteSetHostName( _
		ByVal this As WebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pHostName, pHost)
	
	Return S_OK
	
End Function

Function MutableWebSiteSetSitePhysicalDirectory( _
		ByVal this As WebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pPhysicalDirectory, pPhysicalDirectory)
	
	Return S_OK
	
End Function

Function MutableWebSiteSetVirtualPath( _
		ByVal this As WebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pVirtualPath, pVirtualPath)
	
	Return S_OK
	
End Function

Function MutableWebSiteSetIsMoved( _
		ByVal this As WebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	
	this->IsMoved = IsMoved
	
	Return S_OK
	
End Function

Function MutableWebSiteSetMovedUrl( _
		ByVal this As WebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT
	
	LET_HEAPSYSSTRING(this->pMovedUrl, pMovedUrl)
	
	Return S_OK
	
End Function

Function WebSiteNeedCgiProcessing( _
		ByVal this As WebSite Ptr, _
		ByVal path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	If StrStrIW(Path, WStr("/cgi-bin/")) = NULL Then
		*pResult = False
	Else
		*pResult = True
	End If
	
	Return S_OK
	
End Function


Function IMutableWebSiteQueryInterface( _
		ByVal this As IWebSite Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return WebSiteQueryInterface(ContainerOf(this, WebSite, lpVtbl), riid, ppvObject)
End Function

Function IMutableWebSiteAddRef( _
		ByVal this As IWebSite Ptr _
	)As ULONG
	Return WebSiteAddRef(ContainerOf(this, WebSite, lpVtbl))
End Function

Function IMutableWebSiteRelease( _
		ByVal this As IWebSite Ptr _
	)As ULONG
	Return WebSiteRelease(ContainerOf(this, WebSite, lpVtbl))
End Function

Function IMutableWebSiteGetHostName( _
		ByVal this As IWebSite Ptr, _
		ByVal ppHost As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetHostName(ContainerOf(this, WebSite, lpVtbl), ppHost)
End Function

Function IMutableWebSiteGetSitePhysicalDirectory( _
		ByVal this As IWebSite Ptr, _
		ByVal ppPhysicalDirectory As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetSitePhysicalDirectory(ContainerOf(this, WebSite, lpVtbl), ppPhysicalDirectory)
End Function

Function IMutableWebSiteGetVirtualPath( _
		ByVal this As IWebSite Ptr, _
		ByVal ppVirtualPath As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetVirtualPath(ContainerOf(this, WebSite, lpVtbl), ppVirtualPath)
End Function

Function IMutableWebSiteGetIsMoved( _
		ByVal this As IWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	Return WebSiteGetIsMoved(ContainerOf(this, WebSite, lpVtbl), pIsMoved)
End Function

Function IMutableWebSiteGetMovedUrl( _
		ByVal this As IWebSite Ptr, _
		ByVal ppMovedUrl As HeapBSTR Ptr _
	)As HRESULT
	Return WebSiteGetMovedUrl(ContainerOf(this, WebSite, lpVtbl), ppMovedUrl)
End Function

Function IMutableWebSiteGetBuffer( _
		ByVal this As IWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal fAccess As FileAccess, _
		ByVal pRequest As IClientRequest Ptr, _
		ByVal BufferLength As LongInt, _
		ByVal pFlags As ContentNegotiationFlags Ptr, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	Return WebSiteGetBuffer(ContainerOf(this, WebSite, lpVtbl), pIMalloc, fAccess, pRequest, BufferLength, pFlags, ppResult)
End Function

Function IMutableWebSiteGetErrorBuffer( _
		ByVal this As IWebSite Ptr, _
		ByVal pIMalloc As IMalloc Ptr, _
		ByVal HttpError As ResponseErrorCode, _
		ByVal hrErrorCode As HRESULT, _
		ByVal StatusCode As HttpStatusCodes, _
		ByVal ppResult As IBuffer Ptr Ptr _
	)As HRESULT
	Return WebSiteGetErrorBuffer(ContainerOf(this, WebSite, lpVtbl), pIMalloc, HttpError, hrErrorCode, StatusCode, ppResult)
End Function

Function IMutableWebSiteSetHostName( _
		ByVal this As IWebSite Ptr, _
		ByVal pHost As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetHostName(ContainerOf(this, WebSite, lpVtbl), pHost)
End Function

Function IMutableWebSiteSetSitePhysicalDirectory( _
		ByVal this As IWebSite Ptr, _
		ByVal pPhysicalDirectory As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetSitePhysicalDirectory(ContainerOf(this, WebSite, lpVtbl), pPhysicalDirectory)
End Function

Function IMutableWebSiteSetVirtualPath( _
		ByVal this As IWebSite Ptr, _
		ByVal pVirtualPath As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetVirtualPath(ContainerOf(this, WebSite, lpVtbl), pVirtualPath)
End Function

Function IMutableWebSiteSetIsMoved( _
		ByVal this As IWebSite Ptr, _
		ByVal IsMoved As Boolean _
	)As HRESULT
	Return MutableWebSiteSetIsMoved(ContainerOf(this, WebSite, lpVtbl), IsMoved)
End Function

Function IMutableWebSiteSetMovedUrl( _
		ByVal this As IWebSite Ptr, _
		ByVal pMovedUrl As HeapBSTR _
	)As HRESULT
	Return MutableWebSiteSetMovedUrl(ContainerOf(this, WebSite, lpVtbl), pMovedUrl)
End Function

Function IMutableWebSiteNeedCgiProcessing( _
		ByVal this As IWebSite Ptr, _
		ByVal Path As HeapBSTR, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	Return WebSiteNeedCgiProcessing(ContainerOf(this, WebSite, lpVtbl), Path, pResult)
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
	@IMutableWebSiteSetHostName, _
	@IMutableWebSiteSetSitePhysicalDirectory, _
	@IMutableWebSiteSetVirtualPath, _
	@IMutableWebSiteSetIsMoved, _
	@IMutableWebSiteSetMovedUrl, _
	@IMutableWebSiteNeedCgiProcessing _
)
