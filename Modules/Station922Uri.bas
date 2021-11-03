#include once "Station922Uri.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"

Function Station922UriPathDecode( _
		ByVal pURI As Station922Uri Ptr, _
		ByVal pBuffer As WString Ptr _
	)As Integer
	
	' TODO Исправить раскодирование неправильного запроса
	' Расшифровываем url-кодировку %XY
	Dim iAcc As UInteger = 0
	Dim iHex As UInteger = 0
	
	Dim DecodedBytesUtf8Length As Integer = 0
	
	Dim DecodedBytesUtf8 As ZString * (URI_BUFFER_CAPACITY + 1) = Any
	
	For i As Integer = 0 To lstrlenW(pURI->Path) - 1
		
		Dim c As wchar_t = pURI->Path[i]
		
		If iHex <> 0 Then
			' 0 = 30 = 48 = 0
			' 1 = 31 = 49 = 1
			' 2 = 32 = 50 = 2
			' 3 = 33 = 51 = 3
			' 4 = 34 = 52 = 4
			' 5 = 35 = 53 = 5
			' 6 = 36 = 54 = 6
			' 7 = 37 = 55 = 7
			' 8 = 38 = 56 = 8
			' 9 = 39 = 57 = 9
			' A = 41 = 65 = 10
			' B = 42 = 66 = 11
			' C = 43 = 67 = 12
			' D = 44 = 68 = 13
			' E = 45 = 69 = 14
			' F = 46 = 70 = 15
			
			iHex += 1 ' раскодировать
			iAcc *= 16
			
			Select Case c
				
				Case Characters.DigitZero, Characters.DigitOne, Characters.DigitTwo, Characters.DigitThree, Characters.DigitFour, Characters.DigitFive, Characters.DigitSix, Characters.DigitSeven, Characters.DigitEight, Characters.DigitNine
					iAcc += c - Characters.DigitZero
					
				Case &h41, &h42, &h43, &h44, &h45, &h46 ' Коды ABCDEF
					iAcc += c - &h37 ' 55
					
				Case &h61, &h62, &h63, &h64, &h65, &h66 ' Коды abcdef
					iAcc += c - &h57 ' 87
					
			End Select
			
			If iHex = 3 Then
				c = iAcc
				iAcc = 0
				iHex = 0
			End if
		End if
		
		If c = Characters.PercentSign Then ' hex code coming?
			iHex = 1
			iAcc = 0
		End if
		
		If iHex = 0 Then
			DecodedBytesUtf8[DecodedBytesUtf8Length] = c
			DecodedBytesUtf8Length += 1
		End If
		
	Next
	
	' Завершающий ноль
	DecodedBytesUtf8[DecodedBytesUtf8Length] = 0
	
	Const dwFlags As DWORD = 0
	
	Dim Length As Integer = MultiByteToWideChar( _
		CP_UTF8, _
		dwFlags, _
		@DecodedBytesUtf8, _
		DecodedBytesUtf8Length, _
		pBuffer, _
		URI_BUFFER_CAPACITY _
	)
	
	Return Length
	
End Function

Function ContainsBadCharSequence( _
		ByVal Buffer As WString Ptr, _
		ByVal Length As Integer _
	)As HRESULT
	
	' TODO Звёздочка в пути допустима при методе OPTIONS
	
	If Length = 0 Then
		Return E_FAIL
	End If
	
	If Buffer[Length - 1] = Characters.FullStop Then
		Return E_FAIL
	End If
	
	For i As Integer = 0 To Length - 1
		
		Dim c As wchar_t = Buffer[i]
		
		Select Case c
			
			Case Is < Characters.WhiteSpace
				Return E_FAIL
				
			Case Characters.QuotationMark
				' Кавычки нельзя
				Return E_FAIL
				
			'Case Characters.DollarSign
				' Нельзя доллар, потому что могут открыть $MFT
				'Return E_FAIL
				
			'Case Characters.PercentSign
				' TODO Уточнить, почему нельзя использовать знак процента
				'Return E_FAIL
				
			'Case Characters.Ampersand
				' Объединение команд в одну
				'Return E_FAIL
				
			Case Characters.Asterisk
				' Нельзя звёздочку
				Return E_FAIL
				
			Case Characters.FullStop
				' Разрешены .. потому что могут встретиться в имени файла
				' Запрещены /.. потому что могут привести к смене каталога
				Dim NextChar As wchar_t = Buffer[i + 1]
				
				If NextChar = Characters.FullStop Then
					
					If i > 0 Then
						Dim PrevChar As wchar_t = Buffer[i - 1]
						
						If PrevChar = Characters.Solidus Then
							Return E_FAIL
						End If
						
					End If
					
				End If
				
			'Case Characters.Semicolon
				' Разделитель путей
				'Return E_FAIL
				
			Case Characters.LessThanSign
				' Защита от перенаправлений ввода-вывода
				Return E_FAIL
				
			Case Characters.GreaterThanSign
				' Защита от перенаправлений ввода-вывода
				Return E_FAIL
				
			Case Characters.QuestionMark
				' Подстановочный знак
				Return E_FAIL
				
			Case Characters.VerticalLine
				' Символ конвейера
				Return E_FAIL
				
		End Select
		
	Next
	
	Return S_OK
	
End Function

Sub Station922UriInitialize( _
		ByVal pURI As Station922Uri Ptr _
	)
	
	pURI->Uri[0] = Characters.NullChar
	pURI->Scheme = 0
	pURI->Authority.Info.UserName = 0
	pURI->Authority.Info.Password = 0
	pURI->Authority.Host = 0
	pURI->Authority.Port = 0
	pURI->Path = 0
	pURI->Query = 0
	pURI->Fragment = 0
	
End Sub

Function Station922UriSetUri( _
		ByVal pURI As Station922Uri Ptr, _
		ByVal UriString As WString Ptr _
	)As HRESULT
	
	Dim ClientURILength As Integer = lstrlenW(UriString)
	
	If ClientURILength > URI_BUFFER_CAPACITY Then
		Return STATION922URI_E_URITOOLARGE
	End If
	
	lstrcpyW(pURI->Uri, UriString)
	
	pURI->Path = @pURI->Uri
	
	Dim PathLength As Integer = Any
	
	Dim pQuestionMark As WString Ptr = StrChrW( _
		pURI->Uri, _
		Characters.QuestionMark _
	)
	If pQuestionMark = NULL Then
		PathLength = ClientURILength
	Else
		pQuestionMark[0] = Characters.NullChar
		pURI->Query = pQuestionMark + 1
		PathLength = lstrlenW(pURI->Path)
	End If
	
	/'
	If StrChrW(@this->ClientURI.Path, PercentSign) = 0 Then
		PathLength = ClientURILength
	Else
		' Раскодировка пути
		Dim DecodedPath As WString * (Station922Uri.MaxUrlLength + 1) = Any
		PathLength = Station922UriPathDecode(@this->ClientURI, @DecodedPath)
		lstrcpyW(@this->ClientURI.Path, @DecodedPath)
	End If
	'/
	
	Dim hrContainsBadChar As HRESULT = ContainsBadCharSequence( _
		pURI->Path, _
		PathLength _
	)
	If FAILED(hrContainsBadChar) Then
		Return STATION922URI_E_BADPATH
	End If
	
	Return S_OK
	
End Function
