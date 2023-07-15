#include once "Logger.bi"

Sub ConsoleWriteColorStringW( _
		ByVal s As LPCWSTR _
	)
	
	Dim OutHandle As HANDLE = GetStdHandle(STD_OUTPUT_HANDLE)
	
	Dim NumberOfCharsWritten As DWORD = Any
	Dim dwErrorConsole As WINBOOL = WriteConsoleW( _
		OutHandle, _
		s, _
		lstrlenW(s), _
		@NumberOfCharsWritten, _
		0 _
	)
	If dwErrorConsole = 0 Then
		
		Const MaxConsoleCharsCount As Integer = 512 - 1
		
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
	
	Dim IsSafeArray As Boolean = pvtData->vt And VT_ARRAY
	
	If IsSafeArray Then
		
		Dim Length As Integer = Any
		Scope
			Dim iLowerBound As Long = Any
			SafeArrayGetLBound(pvtData->parray, 1, @iLowerBound)
			
			Dim iUpperBound As Long = Any
			SafeArrayGetUBound(pvtData->parray, 1, @iUpperBound)
			
			Length = iUpperBound - iLowerBound + 1
		End Scope
		
		Scope
			Dim bytes As UByte Ptr = Any
			Dim hrAccess As HRESULT = SafeArrayAccessData( _
				pvtData->parray, _
				@bytes _
			)
			If FAILED(hrAccess) Then
				Exit Sub
			End If
			
			Dim OutHandle As HANDLE = GetStdHandle(STD_OUTPUT_HANDLE)
			Dim NumberOfBytesWritten As DWORD = Any
			WriteFile( _
				OutHandle, _
				bytes, _
				Cast(DWORD, Length), _
				@NumberOfBytesWritten, _
				0 _
			)
			
			SafeArrayUnaccessData(pvtData->parray)
		End Scope
	Else
		Dim wszStringBuffer As WString * 1024 = Any
		
		Select Case pvtData->vt
			
			Case VT_BSTR
				Const StringFormat = WStr(!"%s\t%s\r\n")
				wsprintfW( _
					@wszStringBuffer, _
					@StringFormat, _
					pwszText, _
					pvtData->bstrVal _
				)
				
			Case VT_ERROR
				Const StringFormat = WStr(!"%s\t%X\r\n")
				wsprintfW( _
					@wszStringBuffer, _
					@StringFormat, _
					pwszText, _
					pvtData->scode _
				)
				
			Case VT_EMPTY
				Const StringFormat = WStr(!"%s")
				wsprintfW( _
					@wszStringBuffer, _
					@StringFormat, _
					pwszText _
				)
				
			Case Else
				Const StringFormat = WStr(!"%s\t%i\r\n")
				wsprintfW( _
					@wszStringBuffer, _
					@StringFormat, _
					pwszText, _
					pvtData->lVal _
				)
				
		End Select
		
		ConsoleWriteColorStringW(@wszStringBuffer)
	End If
	
End Sub
