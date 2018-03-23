#include once "base64.bi"

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\shlwapi.bi"

Const B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

Function E0(ByVal v1 As UByte)As UByte
	' Получить шесть левых бит числа
	Return v1 Shr 2
End Function

Function E1(ByVal v1 As UByte, ByVal v2 As UByte)As UByte
	' Получить два правых бита первого числа и четыре левых бита второго числа
	Return ((v1 And &b00000011) Shl 4) + (v2 Shr 4)
End Function

Function E2(ByVal v2 As UByte, ByVal v3 As UByte)As UByte
	' Получить четыре правых бита первого числа и два левых бита второго числа
	Return ((v2 And &b00001111) Shl 2) + (v3 Shr 6)
End Function

Function E3(ByVal v3 As UByte)As UByte
	' Получить шесть правых бит числа
	Return v3 And &b00111111
End Function

Function Encode64(ByVal sOut As WString Ptr, ByVal sEncodedB As UByte Ptr, ByVal BytesCount As Integer)As Integer
	Dim j As Integer = 0
	Dim k As Integer = 0
	' Количество байт, не умещающихся в тройку байт
	Dim ELM3 As Integer = BytesCount Mod 3
	' Идти через каждые три байта
	For j = 0 To BytesCount - ELM3 - 1 Step 3
		Dim wChar1 As Integer = (@B64 + E0(sEncodedB[j + 0]))[0]
		sOut[k + 0] = wChar1
		
		Dim wChar2 As Integer = (@B64 + E1(sEncodedB[j + 0], sEncodedB[j + 1]))[0]
		sOut[k + 1] = wChar2
		
		Dim wChar3 As Integer = (@B64 + E2(sEncodedB[j + 1], sEncodedB[j + 2]))[0]
		sOut[k + 2] = wChar3
		
		Dim wChar4 As Integer = (@B64 + E3(sEncodedB[j + 2]))[0]
		sOut[k + 3] = wChar4
		
		k += 4
	Next
	
	Select Case ELM3
		
		Case 1
			Dim wChar1 As Integer = (@B64 + E0(sEncodedB[j + 0]))[0]
			sOut[k + 0] = wChar1
			
			Dim wChar2 As Integer = (@B64 + E1(sEncodedB[j + 0], sEncodedB[j + 1]))[0]
			sOut[k + 1] = wChar2
			
			sOut[k + 2] = &h3D
			
			sOut[k + 3] = &h3D
			
			k += 4
			
		Case 2
			Dim wChar1 As Integer = (@B64 + E0(sEncodedB[j + 0]))[0]
			sOut[k + 0] = wChar1
			
			Dim wChar2 As Integer = (@B64 + E1(sEncodedB[j + 0], sEncodedB[j + 1]))[0]
			sOut[k + 1] = wChar2
			
			Dim wChar3 As Integer = (@B64 + E2(sEncodedB[j + 1], sEncodedB[j + 2]))[0]
			sOut[k + 2] = wChar3
			
			sOut[k + 3] = &h3D
			
			k += 4
			
	End Select
	
	sOut[k] = 0
	Return k
End Function

Function GetBase64Index(ByVal sChar As Integer)As Integer
	If sChar = 0 Then
		Return -1
	End If
	Dim w As WString Ptr = StrChr(@B64, sChar)
	If w = 0 Then
		Return -1
	End If
	Return w - @B64
End Function

' Пропускаем все символы не из набора
Function SkipWrongChar(ByVal s As WString Ptr)As Integer
	Dim i As Integer = 0
	Dim schar As Integer = s[i]
	Do Until schar = 0
		If GetBase64Index(schar) <> -1 Then
			Exit Do
		End If
		i += 1
		schar = s[i]
	Loop
	Return i
End Function

Function CalculateString(ByVal b As UByte Ptr, ByVal BytesCount As Integer, ByVal w1 As Integer, ByVal w2 As Integer, ByVal w3 As Integer, ByVal w4 As Integer)As Integer
	If w2 > -1 Then
		b[BytesCount] = (w1 * 4 + w2 \ 16) And 255
		BytesCount += 1
	End If
	If w3 > -1 Then
		b[BytesCount] = (w2 * 16 + w3 \ 4) And 255
		BytesCount += 1
	End If
	If w4 > -1 Then
		b[BytesCount] = (w3 * 64 + w4) And 255
		BytesCount += 1
	End If
	Return BytesCount
End Function

Function Decode64(ByVal b As UByte Ptr, ByVal s As WString Ptr)As Integer
	Dim BytesCount As Integer = 0
	Dim length As Integer = lstrlen(s)
	For i As Integer = 0 To length - 1 Step 4
		Dim ww As Integer = Any
		' Необходимо пропустить все символы не из набора
		i += SkipWrongChar(s[i + 0])
		If i >= length - 0 Then
			Return BytesCount
		End If
		ww = s[i + 0]
		Dim w1 As Integer = GetBase64Index(ww)
		
		i += SkipWrongChar(s[i + 1])
		If i >= length - 1 Then
			Return CalculateString(b, BytesCount, w1, 0, 0, 0)
		End If
		ww = s[i + 1]
		Dim w2 As Integer = GetBase64Index(ww)
		
		i += SkipWrongChar(s[i + 2])
		If i >= length - 2 Then
			Return CalculateString(b, BytesCount, w1, w2, 0, 0)
		End If
		ww = s[i + 2]
		Dim w3 As Integer = GetBase64Index(ww)
		
		i += SkipWrongChar(s[i + 3])
		If i >= length - 3 Then
			Return CalculateString(b, BytesCount, w1, w2, w3, 0)
		End If
		ww = s[i + 3]
		Dim w4 As Integer = GetBase64Index(ww)
		
		BytesCount = CalculateString(b, BytesCount, w1, w2, w3, w4)
	Next
	Return BytesCount
End Function
