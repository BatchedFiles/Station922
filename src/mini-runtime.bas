#ifdef WITHOUT_RUNTIME

#include once "mini-runtime.bi"

#ifdef __FB_WIN32__
#include once "windows.bi"
#endif

#undef fb_End
#undef fb_Init

Declare Function main cdecl Alias "main"( _
	ByVal argc As Long, _
	ByVal argv As ZString Ptr Ptr _
) As Long

Public Sub __main cdecl Alias "__main"()
	' Do nothing
End Sub

Public Sub fb_Init Alias "fb_Init"( _
		ByVal argc As Long, _
		ByVal argv As ZString Ptr Ptr, _
		ByVal lang As Long _
	)
	' Do nothing
End Sub

Public Sub fb_End Alias "fb_End"( _
		ByVal RetCode As Long _
	)

	#ifdef __FB_WIN32__
		ExitProcess(RetCode)
	#endif

	#ifdef __FB_LINUX__
		#ifdef __FB_64BIT__
			' asm("xorq %rdi, %rdi");  // код выхода 0
			' asm("movq $60, %rax"); // номер системного вызова 60 - exit
			' asm("syscall"); // выход

			Asm
				mov rdi, [RetCode] /' код возврата    '/
				mov rax, 60        /' 60 - номер системного вызова exit '/
				syscall            /' выполняем системный вызов exit    '/
			End Asm
		#else
			Asm
				mov eax, 1         /' номер системного вызова exit = 1   '/
				mov ebx, [RetCode] /' передать 0 как значение параметра  '/
				int 0x80           /' вызвать exit(0)                    '/
			End Asm
		#endif
	#endif

End Sub

Private Sub fb_End_Internal( _
		ByVal RetCode As Long _
	)

	#ifdef __FB_WIN32__
		#ifdef WITHOUT_EXITPROCESS
		#else
			ExitProcess(RetCode)
		#endif
	#endif

	#ifdef __FB_LINUX__
		#ifdef __FB_64BIT__
			Asm
				mov rax, 60        /' 60 - номер системного вызова exit '/
				mov rdi, [RetCode] /' произвольный код возврата - 22    '/
				syscall            /' выполняем системный вызов exit    '/
			End Asm
		#else
			Asm
				mov eax, 1         /' номер системного вызова exit = 1   '/
				mov ebx, [RetCode] /' передать 0 как значение параметра  '/
				int 0x80           /' вызвать exit(0)                    '/
			End Asm
		#endif
	#endif
End Sub

#if __FB_GUI__ = 0
Public Function mainCRTStartup Alias "mainCRTStartup"()As Long

	Dim RetCode As Long = main(0, 0)

	fb_End_Internal(RetCode)

	Return RetCode

End Function
#else
Public Function WinMainCRTStartup Alias "WinMainCRTStartup"()As Long

	Dim RetCode As Long = main(0, 0)

	fb_End_Internal(RetCode)

	Return RetCode

End Function
#endif

#endif
