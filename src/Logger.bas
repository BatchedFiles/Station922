#include once "Logger.bi"
#include once "crt.bi"

Private Sub ConsoleWriteColorStringW( _
		ByVal s As LPCWSTR _
	)

	Const FormatString = "%s"
	wprintf(@WStr(FormatString), s)

End Sub

Public Sub LogWriteEntry( _
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
				var fac = HRESULT_FACILITY(pvtData->scode)

				If fac = FACILITY_WIN32 Then
					Dim dwError As DWORD = HRESULT_CODE(pvtData->scode)
					Dim lpMsgBuf As LPVOID = Any

					FormatMessageW( _
						FORMAT_MESSAGE_ALLOCATE_BUFFER Or FORMAT_MESSAGE_FROM_SYSTEM Or FORMAT_MESSAGE_IGNORE_INSERTS, _
						NULL, _
						dwError, _
						MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), _
						Cast(LPWSTR, @lpMsgBuf), _
						0, NULL _
					)

					Const StringFormat = WStr(!"%s\t%X\t%s\r\n")
					wsprintfW( _
						@wszStringBuffer, _
						@StringFormat, _
						pwszText, _
						pvtData->scode, _
						lpMsgBuf _
					)

					LocalFree(lpMsgBuf)
				Else

					Const StringFormat = WStr(!"%s\t%X\r\n")
					wsprintfW( _
						@wszStringBuffer, _
						@StringFormat, _
						pwszText, _
						pvtData->scode _
					)
				End If

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
