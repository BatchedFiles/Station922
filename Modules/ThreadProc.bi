#ifndef THREADPROC_BI
#define THREADPROC_BI

#include "IWebSite.bi"
#include "IWebSiteContainer.bi"
#include "NetworkStream.bi"
#include "Network.bi"

Type ThreadContext
	Dim ClientSocket As SOCKET
	Dim ServerSocket As SOCKET
	Dim tcpStream As NetworkStream
	Dim pINetworkStream As INetworkStream Ptr
	Dim RemoteAddress As SOCKADDR_IN
	Dim RemoteAddressLength As Integer
	Dim ThreadId As DWORD
	Dim hThread As HANDLE
	Dim pExeDir As WString Ptr
	Dim pIWebSites As IWebSiteContainer Ptr
	
	Dim Frequency As LARGE_INTEGER
	Dim m_startTicks As LARGE_INTEGER
	
	Dim hInput As HANDLE
	Dim hOutput As HANDLE
	Dim hError As HANDLE
	Dim hThreadContextHeap As HANDLE
End Type

Declare Function ThreadProc( _
	ByVal lpParam As LPVOID _
)As DWORD

#endif
