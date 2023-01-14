#include once "Logger.bi"

Sub ConsoleWriteColorStringW( _
		ByVal s As LPCWSTR _
	)
	
	Dim OutHandle As HANDLE = GetStdHandle(STD_OUTPUT_HANDLE)
	
	' SetConsoleTextAttribute(OutHandle, _
		' GetWinAPIForeColor(ForeColor) + GetWinAPIBackColor(BackColor) _
	' )
	
	Dim NumberOfCharsWritten As DWORD = Any
	Dim dwErrorConsole As WINBOOL = WriteConsoleW( _
		OutHandle, _
		s, _
		lstrlenW(s), _
		@NumberOfCharsWritten, _
		0 _
	)
	If dwErrorConsole = 0 Then
		
		Const MaxConsoleCharsCount As Integer = 32000 - 1
		
		Dim OutputCodePage As Integer = GetConsoleOutputCP()
		Dim Buffer As ZString * (MaxConsoleCharsCount + 1) = Any
		Dim BytesCount As Integer = WideCharToMultiByte( _
			OutputCodePage, _
			0, _
			s, _
			-1, _
			@Buffer, _
			MaxConsoleCharsCount, _
			NULL, _
			NULL _
		)
		
		Dim NumberOfBytesWritten As DWORD = Any
		WriteFile( _
			OutHandle, _
			@Buffer, _
			BytesCount - 1, _
			@NumberOfBytesWritten, _
			0 _
		)
		
	End If
	
End Sub

Sub LogWriteEntry( _
		ByVal Reason As LogEntryType, _
		ByVal pwszText As WString Ptr, _
		ByVal pvtData As VARIANT Ptr _
	)
	
	' Dim Entry As LogEntry = Any
	' Entry.Reason = Reason
	' Entry.Description = SysAllocString(pwszText)
	' VariantInit(@Entry.vtData)
	' VariantCopy(@Entry.vtData, pvtData)
	
	If pvtData->vt And VT_ARRAY Then
		
		Dim OutHandle As HANDLE = GetStdHandle(STD_OUTPUT_HANDLE)
		
		Dim iLo As Long = Any
		SafeArrayGetLBound(pvtData->parray, 1, @iLo)
		
		Dim iUp As Long = Any
		SafeArrayGetUBound(pvtData->parray, 1, @iUp)
		
		Dim Length As Integer = iUp - iLo + 1
		
		Dim bytes As UByte Ptr = Any
		SafeArrayAccessData(pvtData->parray, @bytes)
		
		Dim NumberOfBytesWritten As DWORD = Any
		WriteFile( _
			OutHandle, _
			bytes, _
			Cast(DWORD, Length), _
			@NumberOfBytesWritten, _
			0 _
		)
		
		SafeArrayUnaccessData(pvtData->parray)
	Else
		Dim buf As WString * 255 = Any
		
		Dim vt As VARTYPE = pvtData->vt
		Select Case vt
			
			Case VT_ERROR
				_ultow(pvtData->scode, @buf, 16)
				
			Case Else
				_ltow(pvtData->lVal, @buf, 10)
				
		End Select
		
		ConsoleWriteColorStringW(pwszText)
		ConsoleWriteColorStringW(@buf)
		ConsoleWriteColorStringW(WStr(!"\r\n"))
		
	End If
	
End Sub
