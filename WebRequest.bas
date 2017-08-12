#include once "WebRequest.bi"
#include once "windows.bi"
#include once "windows.bi"
#include once "win\shlwapi.bi"
#include once "CharConstants.bi"
#include once "HttpConst.bi"

Sub WebRequest.Initialize()
	memset(@RequestHeaders(0), 0, RequestHeaderMaximum * SizeOf(WString Ptr))
	memset(@RequestZipModes(0), 0, MaxRequestZipEnabled * SizeOf(Boolean))
	KeepAlive = False
	HttpVersion = HttpVersions.Http11
	RequestHeaderBufferLength = 0
	ClientURI.Initialize()
End Sub

Function WebRequest.ReadAllHeaders(ByVal ClientReader As StreamSocketReader Ptr)As Boolean
	Dim wLine As WString Ptr = @RequestHeaderBuffer[RequestHeaderBufferLength]
	Dim wLineLength As Integer = ClientReader->ReadLine(@RequestHeaderBuffer[RequestHeaderBufferLength], MaxRequestHeaderBuffer - RequestHeaderBufferLength)
	RequestHeaderBufferLength += wLineLength + 1
	
	Select Case GetLastError()
		Case StreamSocketReader.BufferOverflowError
			#if __FB_DEBUG__ <> 0
				Print "Буфер переполнен"
			#endif
			SetLastError(ParseRequestLineResult.RequestHeaderFieldsTooLarge)
			Return False
			
		Case StreamSocketReader.SocketError
			#if __FB_DEBUG__ <> 0
				Print "Ошибка сокета"
			#endif
			SetLastError(ParseRequestLineResult.SocketError)
			Return False
			
		Case StreamSocketReader.ClientClosedSocketError
			#if __FB_DEBUG__ <> 0
				Print "Клиент закрыл соединение"
			#endif
			SetLastError(ParseRequestLineResult.EmptyRequest)
			Return False
			
	End Select
	
	' Метод, запрошенный ресурс и версия протокола
	' Первый пробел
	Dim wSpace As WString Ptr = StrChr(wLine, SpaceChar)
	If wSpace = 0 Then
		SetLastError(ParseRequestLineResult.BadRequest)
		Return False
	End If
	
	' Удалить пробел
	wSpace[0] = 0
	' Теперь в RequestLine содержится имя метода
	HttpMethod = GetHttpMethod(wLine)
	
	' Здесь начинается Url
	ClientURI.Url = wSpace + 1
	
	' Второй пробел
	wSpace = StrChr(ClientURI.Url, SpaceChar)
	If wSpace = 0 Then
		' Есть только метод и Url, значит, версия HTTP = 0.9
		HttpVersion = HttpVersions.Http09
	Else
		' Убрать пробел
		wSpace[0] = 0
		
		' Третий пробел
		If StrChr(ClientURI.Url, SpaceChar) <> 0 Then
			' Слишком много пробелов
			SetLastError(ParseRequestLineResult.BadRequest)
			Return False
		End If
		
		' Теперь в (wSpace + 1) находится версия протокола, определить
		If lstrcmp(wSpace + 1, HttpVersion10) = 0 Then
			HttpVersion = HttpVersions.Http10
		Else
			If lstrcmp(wSpace + 1, HttpVersion11) = 0 Then
				HttpVersion = HttpVersions.Http11
				KeepAlive = True ' Для версии 1.1 это по умолчанию
			Else
				' Версия не поддерживается
				SetLastError(ParseRequestLineResult.HTTPVersionNotSupported)
				Return False
			End If
		End If
	End If
	
	If lstrlen(ClientURI.Url) > URI.MaxUrlLength Then
		SetLastError(ParseRequestLineResult.RequestUrlTooLong)
		Return False
	End If
	
	' Если есть «?», значит там строка запроса
	Dim wQS As WString Ptr = StrChr(ClientURI.Url, QuestionMarkChar)
	If wQS = 0 Then
		lstrcpy(@ClientURI.Path, ClientURI.Url)
	Else
		ClientURI.QueryString = wQS + 1
		' Получение пути
		wQS[0] = 0 ' убрать вопросительный знак
		lstrcpy(@ClientURI.Path, ClientURI.Url)
		wQS[0] = &h3F ' вернуть, чтобы не портить Url
	End If
	
	' Раскодировка пути
	If StrChr(@ClientURI.Path, PercentSign) <> 0 Then
		Dim DecodedPath As WString * (ClientURI.MaxUrlLength + 1) = Any
		ClientURI.PathDecode(@DecodedPath)
		lstrcpy(@ClientURI.Path, @DecodedPath)
	End If
	
	' TODO Звёздочка в пути допустима при методе OPTIONS
	If IsBadPath(@ClientURI.Path) Then
		SetLastError(ParseRequestLineResult.BadPath)
		Return False
	End If
	
	' Получить все заголовки запроса
	Do
		wLine = @RequestHeaderBuffer[RequestHeaderBufferLength]
		wLineLength = ClientReader->ReadLine(@RequestHeaderBuffer[RequestHeaderBufferLength], MaxRequestHeaderBuffer - RequestHeaderBufferLength)
		RequestHeaderBufferLength += wLineLength + 1
		
		Select Case GetLastError()
			Case StreamSocketReader.BufferOverflowError
				#if __FB_DEBUG__ <> 0
					Print "2 Буфер переполнен"
				#endif
				SetLastError(ParseRequestLineResult.RequestHeaderFieldsTooLarge)
				Return False
				
			Case StreamSocketReader.SocketError
				#if __FB_DEBUG__ <> 0
					Print "2 Ошибка сокета"
				#endif
				SetLastError(ParseRequestLineResult.SocketError)
				Return False
				
			Case StreamSocketReader.ClientClosedSocketError
				#if __FB_DEBUG__ <> 0
					Print "2 Клиент закрыл соединение"
				#endif
				SetLastError(ParseRequestLineResult.EmptyRequest)
				Return False
				
		End Select
		
		If lstrlen(wLine) = 0 Then
			' Клиент отправил все данные, можно приступать к обработке
			Exit Do
		Else
			' TODO Обработать ситуацию, когда клиент отправляет заголовок с переносом на новую строку
			Dim wColon As WString Ptr = StrChr(wLine, ColonChar)
			If wColon <> 0 Then
				wColon[0] = 0
				Do
					wColon += 1
				Loop While wColon[0] = 32
				
				AddRequestHeader(wLine, wColon)
				
			End If
		End If
	Loop
	
	SetLastError(ParseRequestLineResult.Success)
	Return True
End Function

Sub WebRequest.AddRequestHeader(ByVal Header As WString Ptr, ByVal Value As WString Ptr)
	Dim HeaderIndex As Integer = GetKnownRequestHeaderIndex(Header)
	If HeaderIndex >= 0 Then
		
		Select Case HeaderIndex
			
			Case HttpRequestHeaderIndices.HeaderConnection
				If StrStrI(Value, @CloseString) <> 0 Then
					KeepAlive = False
				Else
					If StrStrI(Value, @"Keep-Alive") <> 0 Then
						KeepAlive = True
					End If
				End If
				
			Case HttpRequestHeaderIndices.HeaderAcceptEncoding
				If StrStrI(Value, @GzipString) <> 0 Then
					RequestZipModes(GZipIndex) = True
				End If
				If StrStrI(Value, @DeflateString) <> 0 Then
					RequestZipModes(DeflateIndex) = True
				End If
				
			Case HttpRequestHeaderIndices.HeaderIfModifiedSince
				' Убрать UTC и заменить на GMT
				'If-Modified-Since: Thu, 24 Mar 2016 16:10:31 UTC
				'If-Modified-Since: Tue, 11 Mar 2014 20:07:57 GMT
				Dim wUTC As WString Ptr = StrStr(Value, "UTC")
				If wUTC <> 0 Then
					lstrcpy(wUTC, "GMT")
				End If
				
		End Select
		RequestHeaders(HeaderIndex) = Value
	Else
		' TODO Добавить в нераспознанные заголовки запроса
	End If
End Sub
