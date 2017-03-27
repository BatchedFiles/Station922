#include once "base64.bi"

Declare Function E0(v1 As UByte)As UByte
Declare Function E1(v1 As UByte, v2 As UByte)As UByte
Declare Function E2(v2 As UByte, v3 As UByte)As UByte
Declare Function E3(v3 As UByte)As UByte

Const Base64StringLength As Integer = 19

Function Encode64(ByVal sOut As WString Ptr, ByVal sEncodedB As UByte Ptr, ByVal sEncodedBCount As Integer, ByVal WithCrLf As Boolean)As Integer
	Dim ELM3 As Integer = sEncodedBCount Mod 3
	Dim k As Integer = 0
	Dim j As Integer = 0
	For j = 0 To sEncodedBCount - ELM3 - 1 Step 3
		' Перенести на новую строку, если не вмещается
		If WithCrLf Then
			If (j Mod Base64StringLength) = 0 AndAlso j > 0 Then
				sOut[k + 0] = 13
				sOut[k + 1] = 10
				k += 2
			End If
		End If
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
			sOut[k + 2] = 61
			sOut[k + 3] = 61
			k += 4
		Case 2
			sOut[k + 0] = (@B64 + E0(sEncodedB[j + 0]))[0]
			sOut[k + 1] = (@B64 + E1(sEncodedB[j + 0], sEncodedB[j + 1]))[0]
			sOut[k + 2] = (@B64 + E2(sEncodedB[j + 1], sEncodedB[j + 2]))[0]
			sOut[k + 3] = 61
			k += 4
	End Select
	' Поставить завершающий ноль
	sOut[k] = 0
	Return k
End Function

Function E0(v1 As UByte)As UByte
	Return v1 shr 2
End Function

Function E1(v1 As UByte, v2 As UByte)As UByte
	Return ((v1 And 3) shl 4) + (v2 shr 4)
End Function

Function E2(v2 As UByte, v3 As UByte)As UByte
	Return ((v2 And &H0F) shl 2) + (v3 shr 6)
End Function

Function E3(v3 As UByte)As UByte
	Return v3 And &H3F
End Function
