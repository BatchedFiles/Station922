#ifndef SAFEHANDLE_BI
#define SAFEHANDLE_BI

#include once "windows.bi"

Type SafeHandle
	Declare Constructor( _
		ByVal h As HANDLE _
	)
	
	Declare Destructor()
	
	Dim WinAPIHandle As HANDLE
End Type

#endif
