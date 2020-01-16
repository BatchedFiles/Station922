﻿#include "PrintDebugInfo.bi"
#include "ConsoleColors.bi"
#include "IntegerToWString.bi"
#include "StringConstants.bi"

Const InformationForeground = ConsoleColors.Gray
Const InformationBackground = ConsoleColors.Black

Const RequestedBytesForeground = ConsoleColors.Green
Const RequestedBytesBackground = ConsoleColors.Black

Const ResponseBytesBackground = ConsoleColors.Black

Const MicroSeconds As LongInt = 1000 * 1000
Const IntegerToStringBufferLength As Integer = 255

Sub PrintThreadProcessCount( _
		ByVal pFrequency As PLARGE_INTEGER, _
		ByVal pTicks As PLARGE_INTEGER _
	)
	
	Dim CharsWritten As Integer = Any
	Dim wstrTemp As WString * (IntegerToStringBufferLength + 1) = Any
	
	i64tow( _
		(pTicks->QuadPart * MicroSeconds) \ pFrequency->QuadPart, _
		@wstrTemp, _
		10 _
	)
	' i64tow( _
		' pTicks->QuadPart, _
		' @wstrTemp, _
		' 10 _
	' )
	
	lstrcat(@wstrTemp, @NewLineString)
	lstrcat(@wstrTemp, @NewLineString)
	
	ConsoleWriteColorStringW( _
		@!"Количество микросекунд обработки запроса\t", _
		@CharsWritten, _
		InformationForeground, _
		InformationBackground _
	)
	ConsoleWriteColorLineW( _
		@wstrTemp, _
		@CharsWritten, _
		InformationForeground, _
		InformationBackground _
	)
	
End Sub

Sub PrintThreadStartCount( _
		ByVal pFrequency As PLARGE_INTEGER, _
		ByVal pTicks As PLARGE_INTEGER _
	)
	
	Dim CharsWritten As Integer = Any
	Dim wstrTemp As WString * (IntegerToStringBufferLength + 1) = Any
	
	i64tow( _
		(pTicks->QuadPart * MicroSeconds) \ pFrequency->QuadPart, _
		@wstrTemp, _
		10 _
	)
	' i64tow( _
		' pTicks->QuadPart, _
		' @wstrTemp, _
		' 10 _
	' )
	
	ConsoleWriteColorStringW( _
		@!"Количество микросекунд запуска потока\t", _
		@CharsWritten, _
		InformationForeground, _
		InformationBackground _
	)
	ConsoleWriteColorLineW( _
		@wstrTemp, _
		@CharsWritten, _
		InformationForeground, _
		InformationBackground _
	)
	
End Sub

Sub PrintRequestedBytes( _
		ByVal pIHttpReader As IHttpReader Ptr _
	)
	Dim pRequestedBytes As UByte Ptr = Any
	Dim RequestedBytesLength As Integer = Any
	IHttpReader_GetRequestedBytes(pIHttpReader, @RequestedBytesLength, @pRequestedBytes)
	
	Dim CharsWritten As Integer = Any
	ConsoleWriteColorLineA(pRequestedBytes, _
		@CharsWritten, _
		RequestedBytesForeground, _
		RequestedBytesBackground _
	)
	
End Sub

Sub PrintResponseString( _
		ByVal wResponse As WString Ptr, _
		ByVal StatusCode As Integer _
	)
	Dim ForeColor As ConsoleColors = Any
	
	Select Case StatusCode
		
		Case 100 To 199
			ForeColor = ConsoleColors.Gray
			
		Case 200
			ForeColor = ConsoleColors.Blue
			
		Case 201 To 299
			ForeColor = ConsoleColors.Cyan
			
		Case 300 To 399
			ForeColor = ConsoleColors.Yellow
			
		Case 400 To 499
			ForeColor = ConsoleColors.Red
			
		Case Else
			ForeColor = ConsoleColors.Magenta
			
	End Select
	
	Dim CharsWritten As Integer = Any
	ConsoleWriteColorLineW(wResponse, @CharsWritten, ForeColor, ResponseBytesBackground)
	
End Sub