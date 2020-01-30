#include "PrintDebugInfo.bi"
#include "ConsoleColors.bi"
#include "IntegerToWString.bi"
#include "StringConstants.bi"

Const InformationForeground = ConsoleColors.Gray
Const InformationBackground = ConsoleColors.Black

Const RequestedBytesForeground = ConsoleColors.Green
Const RequestedBytesBackground = ConsoleColors.Black

Const ResponseBytesBackground = ConsoleColors.Black

Const MicroSeconds As LongInt = 1000 * 1000
Const IntegerToStringBufferLength As Integer = 128 - 1

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

#ifdef PERFORMANCE_TESTING

Sub ElapsedTimesToString( _
		ByVal wstrElapsedTimes As WString Ptr, _
		ByVal pFrequency As PLARGE_INTEGER, _
		ByVal pTicks As PLARGE_INTEGER _
	)
	Dim ElapsedTimes As LongInt = (pTicks->QuadPart * MicroSeconds) \ pFrequency->QuadPart
	
	i64tow(ElapsedTimes, wstrElapsedTimes, 10)
	
End Sub

Sub PrintRequestElapsedTimes( _
		ByVal pFrequency As PLARGE_INTEGER, _
		ByVal pTicks As PLARGE_INTEGER _
	)
	Dim wstrElapsedTimes As WString * (IntegerToStringBufferLength + 1) = Any
	ElapsedTimesToString(@wstrElapsedTimes, pFrequency, pTicks)
	
	Dim wstrTemp As WString * (2 * IntegerToStringBufferLength + 1) = Any
	lstrcpy(@wstrTemp, @!"Обработка запроса:\t")
	lstrcat(@wstrTemp, @wstrElapsedTimes)
	
	Dim CharsWritten As Integer = Any
	ConsoleWriteColorLineW( _
		@wstrTemp, _
		@CharsWritten, _
		InformationForeground, _
		InformationBackground _
	)
	
End Sub

Sub PrintThreadSuspendedElapsedTimes( _
		ByVal pFrequency As PLARGE_INTEGER, _
		ByVal pTicks As PLARGE_INTEGER _
	)
	Dim wstrElapsedTimes As WString * (IntegerToStringBufferLength + 1) = Any
	ElapsedTimesToString(@wstrElapsedTimes, pFrequency, pTicks)
	
	Dim wstrTemp As WString * (2 * IntegerToStringBufferLength + 1) = Any
	lstrcpy(@wstrTemp, @!"Пробуждение потока:\t")
	lstrcat(@wstrTemp, @wstrElapsedTimes)
	
	Dim CharsWritten As Integer = Any
	ConsoleWriteColorLineW( _
		@wstrTemp, _
		@CharsWritten, _
		InformationForeground, _
		InformationBackground _
	)
	
End Sub

#endif
