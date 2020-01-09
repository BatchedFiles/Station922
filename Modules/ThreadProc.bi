#ifndef THREADPROC_BI
#define THREADPROC_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"

Declare Function ThreadProc( _
	ByVal lpParam As LPVOID _
)As DWORD

#endif
