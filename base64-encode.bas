#include once "base64.bi"

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
		sOut[k + 0] = (@B64 + E0(sEncodedB[j + 0]))[0]
		sOut[k + 1] = (@B64 + E1(sEncodedB[j + 0], sEncodedB[j + 1]))[0]
		sOut[k + 2] = (@B64 + E2(sEncodedB[j + 1], sEncodedB[j + 2]))[0]
		sOut[k + 3] = (@B64 + E3(sEncodedB[j + 2]))[0]
		k += 4
	Next
	
	Select Case ELM3
		Case 1
			sOut[k + 0] = (@B64 + E0(sEncodedB[j + 0]))[0]
			sOut[k + 1] = (@B64 + E1(sEncodedB[j + 0], sEncodedB[j + 1]))[0]
			sOut[k + 2] = &h3D
			sOut[k + 3] = &h3D
			k += 4
		Case 2
			sOut[k + 0] = (@B64 + E0(sEncodedB[j + 0]))[0]
			sOut[k + 1] = (@B64 + E1(sEncodedB[j + 0], sEncodedB[j + 1]))[0]
			sOut[k + 2] = (@B64 + E2(sEncodedB[j + 1], sEncodedB[j + 2]))[0]
			sOut[k + 3] = &h3D
			k += 4
	End Select
	' Поставить завершающий ноль
	sOut[k] = 0
	Return k
End Function
