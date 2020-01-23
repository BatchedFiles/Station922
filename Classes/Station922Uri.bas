#include "Station922URI.bi"

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "CharacterConstants.bi"

Sub InitializeURI( _
		ByVal pURI As Station922Uri Ptr _
	)
	pURI->pUrl = NULL
	pURI->pQueryString = NULL
	pURI->Path[0] = 0
End Sub

Function Station922Uri.PathDecode( _
		ByVal pBuffer As WString Ptr _
	)As Integer
	
	' TODO Исправить раскодирование неправильного запроса
	' Расшифровываем url-кодировку %XY
	Dim iAcc As UInteger = 0
	Dim iHex As UInteger = 0
	
	Dim DecodedBytesUtf8Length As Integer = 0
	
	Dim DecodedBytesUtf8 As ZString * (Station922Uri.MaxUrlLength + 1) = Any
	
	For i As Integer = 0 To lstrlen(Path) - 1
		
		Dim c As wchar_t = Path[i]
		
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
		Station922Uri.MaxUrlLength _
	)
	
	Return Length
	
End Function
