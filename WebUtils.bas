#include once "WebUtils.bi"
#include once "HttpConst.bi"
#include once "URI.bi"
#include once "IntegerToWString.bi"
#include once "CharConstants.bi"
#include once "WriteHttpError.bi"

Const DateFormatString = "ddd, dd MMM yyyy "
Const TimeFormatString = "HH:mm:ss GMT"
Const DefaultHeaderWwwAuthenticate = "Basic realm=""Need username and password"""
Const DefaultHeaderWwwAuthenticate1 = "Basic realm=""Authorization"""
Const DefaultHeaderWwwAuthenticate2 = "Basic realm=""Use Basic auth"""

Function GetSafeString(ByVal Buffer As WString Ptr, ByVal BufferLength As Integer, ByVal strSafe As WString Ptr)As Integer
	Const MaxQuotationMarkSafeStringLength As Integer = 6
	Const MaxAmpersandCharSafeStringLength As Integer = 5
	Const MaxApostropheCharSafeStringLength As Integer = 6
	Const MaxLessThanSignCharSafeStringLength As Integer = 4
	Const MaxGreaterThanSignSafeStringLength As Integer = 4
	
	Dim strSafeLength As Integer = lstrlen(strSafe)
	
	' Посчитать размер буфера
	Scope
		
		Dim cbNeedenBufferLength As Integer = 0
		
		For i As Integer = 0 To strSafeLength - 1
			
			Dim Number As Integer = strSafe[i]
			
			Select Case Number
				
				Case QuotationMarkChar
					cbNeedenBufferLength += MaxQuotationMarkSafeStringLength
					
				Case AmpersandChar
					cbNeedenBufferLength += MaxAmpersandCharSafeStringLength
					
				Case ApostropheChar
					cbNeedenBufferLength += MaxApostropheCharSafeStringLength
					
				Case LessThanSignChar
					cbNeedenBufferLength += MaxLessThanSignCharSafeStringLength
					
				Case GreaterThanSign
					cbNeedenBufferLength += MaxGreaterThanSignSafeStringLength
					
				Case Else
					cbNeedenBufferLength += 1
					
			End Select
			
		Next
		
		If Buffer = 0 Then
			SetLastError(ERROR_SUCCESS)
			Return cbNeedenBufferLength
		End If
		
		If BufferLength < cbNeedenBufferLength Then
			SetLastError(ERROR_INSUFFICIENT_BUFFER)
			Return -1
		End If
	End Scope
	
	Scope
		
		Dim BufferIndex As Integer = 0
		
		For OriginalIndex As Integer = 0 To strSafeLength - 1
			Dim Number As Integer = strSafe[OriginalIndex]
			
			Select Case Number
				
				Case QuotationMarkChar
					' Заменить на &quot;
					Buffer[BufferIndex + 0] = 38        ' &
					Buffer[BufferIndex + 1] = &h71  ' q
					Buffer[BufferIndex + 2] = &h75  ' u
					Buffer[BufferIndex + 3] = &h6f  ' o
					Buffer[BufferIndex + 4] = &h74  ' t
					Buffer[BufferIndex + 5] = &h3b  ' ;
					BufferIndex += MaxQuotationMarkSafeStringLength
					
				Case AmpersandChar
					' Заменить на &amp;
					Buffer[BufferIndex + 0] = 38        ' &
					Buffer[BufferIndex + 1] = &h61  ' a
					Buffer[BufferIndex + 2] = &h6d  ' m
					Buffer[BufferIndex + 3] = &h70  ' p
					Buffer[BufferIndex + 4] = &h3b  ' ;
					BufferIndex += MaxAmpersandCharSafeStringLength
					
				Case ApostropheChar
					' Заменить на &apos;
					Buffer[BufferIndex + 0] = 38        ' &
					Buffer[BufferIndex + 1] = &h61  ' a
					Buffer[BufferIndex + 2] = &h70  ' p
					Buffer[BufferIndex + 3] = &h6f  ' o
					Buffer[BufferIndex + 4] = &h73  ' s
					Buffer[BufferIndex + 5] = &h3b  ' ;
					BufferIndex += MaxApostropheCharSafeStringLength
					
				Case LessThanSignChar
					' Заменить на &lt;
					Buffer[BufferIndex + 0] = 38        ' &
					Buffer[BufferIndex + 1] = &h6c  ' l
					Buffer[BufferIndex + 2] = &h74  ' t
					Buffer[BufferIndex + 3] = &h3b  ' ;
					BufferIndex += MaxLessThanSignCharSafeStringLength
					
				Case GreaterThanSign
					' Заменить на &gt;
					Buffer[BufferIndex + 0] = 38        ' &
					Buffer[BufferIndex + 1] = &h67  ' g
					Buffer[BufferIndex + 2] = &h74  ' t
					Buffer[BufferIndex + 3] = &h3b  ' ;
					BufferIndex += MaxGreaterThanSignSafeStringLength
					
				Case Else
					Buffer[BufferIndex] = Number
					BufferIndex += 1
					
			End Select
			
		Next
		' Завершающий нулевой символ
		Buffer[BufferIndex] = 0
		
		SetLastError(ERROR_SUCCESS)
		Return BufferIndex
	End Scope
End Function

Function GetDocumentCharset(ByVal b As ZString Ptr)As DocumentCharsets
	If b[0] = 239 AndAlso b[1] = 187 AndAlso b[2] = 191 Then
		Return DocumentCharsets.Utf8BOM
	End If
	If b[0] = 255 AndAlso b[1] = 254 Then
		Return DocumentCharsets.Utf16LE
	End If
	If b[0] = 254 AndAlso b[1] = 255 Then
		Return DocumentCharsets.Utf16BE
	End If
	Return DocumentCharsets.ASCII
End Function

Sub GetHttpDate(ByVal Buffer As WString Ptr, ByVal dt As SYSTEMTIME Ptr)
	' Tue, 15 Nov 1994 12:45:26 GMT
	Dim dtBufferLength As Integer = GetDateFormat(LOCALE_INVARIANT, 0, dt, @DateFormatString, Buffer, 31) - 1
	GetTimeFormat(LOCALE_INVARIANT, 0, dt, @TimeFormatString, @Buffer[dtBufferLength], 31 - dtBufferLength)
End Sub

Sub GetHttpDate(ByVal Buffer As WString Ptr)
	Dim dt As SYSTEMTIME = Any
	GetSystemTime(@dt)
	GetHttpDate(Buffer, @dt)
End Sub

Function FindCrLfA(ByVal Buffer As ZString Ptr, ByVal Start As Integer, ByVal BufferLength As Integer)As Integer
	For i As Integer = Start To BufferLength - 2 ' Минус 2 потому что один байт под Lf и один, чтобы не выйти за границу
		If Buffer[i] = 13 AndAlso Buffer[i + 1] = 10 Then
			Return i
		End If
	Next
	Return -1
End Function

Function FindCrLfW(ByVal Buffer As WString Ptr, ByVal Start As Integer, ByVal BufferLength As Integer)As Integer
	For i As Integer = Start To BufferLength - 2 ' Минус 2 потому что один байт под Lf и один, чтобы не выйти за границу
		If Buffer[i] = 13 AndAlso Buffer[i + 1] = 10 Then
			Return i
		End If
	Next
	Return -1
End Function

Function HttpAuthUtil( _
	ByVal state As ReadHeadersResult Ptr, _
	ByVal ClientSocket As SOCKET, _
	ByVal www As WebSite Ptr, _
	ByVal hOutput As Handle)As Boolean
	
	Dim intHttpAuth As HttpAuthResult = state->HttpAuth(www)
	If intHttpAuth <> HttpAuthResult.Success Then
		state->ServerResponse.StatusCode = 401
		
		Select Case intHttpAuth
			Case HttpAuthResult.NeedAuth
				' Требуется авторизация
				state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString, @www->VirtualPath, hOutput)
				
			Case HttpAuthResult.BadAuth
				' Параметры авторизации неверны
				state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate1
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString1, @www->VirtualPath, hOutput)
				
			Case HttpAuthResult.NeedBasicAuth
				' Необходимо использовать Basic‐авторизацию
				state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate2
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString2, @www->VirtualPath, hOutput)
				
			Case HttpAuthResult.EmptyPassword
				' Пароль не может быть пустым
				state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString3, @www->VirtualPath, hOutput)
				
			Case HttpAuthResult.BadUserNamePassword
				' Имя пользователя или пароль не подходят
				state->ServerResponse.ResponseHeaders(HttpResponseHeaderIndices.HeaderWwwAuthenticate) = @DefaultHeaderWwwAuthenticate
				WriteHttpError(state, ClientSocket, HttpErrors.NeedUsernamePasswordString, @www->VirtualPath, hOutput)
				
		End Select
		
		Return False
	End If
	
	Return True
End Function
