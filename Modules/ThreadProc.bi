#ifndef THREADPROC_BI
#define THREADPROC_BI

#include "IWebSite.bi"
#include "IWebSiteContainer.bi"
#include "NetworkStream.bi"
#include "Network.bi"

Type ThreadContext
	Dim ClientSocket As SOCKET
	Dim RemoteAddress As SOCKADDR_IN
	Dim RemoteAddressLength As Integer
	
	Dim ThreadId As DWORD
	Dim hThread As HANDLE
	Dim pExeDir As WString Ptr
	
	Dim tcpStream As NetworkStream
	Dim pIWebSites As IWebSiteContainer Ptr
	Dim pINetworkStream As INetworkStream Ptr
	
	' Dim hInput As HANDLE
	' Dim hOutput As HANDLE
	' Dim hError As HANDLE
	Dim hThreadContextHeap As HANDLE
	
	Dim Frequency As LARGE_INTEGER
	Dim m_startTicks As LARGE_INTEGER
	
End Type

Declare Function ThreadProc( _
	ByVal lpParam As LPVOID _
)As DWORD

#endif
