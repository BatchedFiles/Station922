#ifndef WORKERTHREADCONTEXT_BI
#define WORKERTHREADCONTEXT_BI

#include "IWorkerThreadContext.bi"

Extern CLSID_WORKERTHREADCONTEXT Alias "CLSID_WORKERTHREADCONTEXT" As Const CLSID

Type WorkerThreadContext
	Dim pVirtualTable As IWorkerThreadContextVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim RemoteAddress As SOCKADDR_IN
	Dim RemoteAddressLength As Integer
	
	Dim ThreadId As DWORD
	Dim hThread As HANDLE
	Dim pExeDir As WString Ptr
	
	Dim pIWebSites As IWebSiteContainer Ptr
	Dim pINetworkStream As INetworkStream Ptr
	Dim pIRequest As IClientRequest Ptr
	
	Dim hThreadContextHeap As HANDLE
	
	Dim Frequency As LARGE_INTEGER
	Dim StartTicks As LARGE_INTEGER
	
End Type

Declare Function CreateWorkerThreadContext( _
)As WorkerThreadContext Ptr

Declare Sub DestroyWorkerThreadContext( _
	ByVal this As WorkerThreadContext Ptr _
)

Declare Function WorkerThreadContextQueryInterface( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function WorkerThreadContextAddRef( _
	ByVal this As WorkerThreadContext Ptr _
)As ULONG

Declare Function WorkerThreadContextRelease( _
	ByVal this As WorkerThreadContext Ptr _
)As ULONG

Declare Function WorkerThreadContextGetRemoteAddress( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pRemoteAddress As SOCKADDR_IN Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetRemoteAddress( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal RemoteAddress As SOCKADDR_IN _
)As HRESULT

Declare Function WorkerThreadContextGetRemoteAddressLength( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pRemoteAddressLength As Integer Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetRemoteAddressLength( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal RemoteAddressLength As Integer _
)As HRESULT

Declare Function WorkerThreadContextGetThreadId( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pThreadId As DWORD Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetThreadId( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal ThreadId As DWORD _
)As HRESULT

Declare Function WorkerThreadContextGetThreadHandle( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pThreadHandle As HANDLE Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetThreadHandle( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal ThreadHandle As HANDLE _
)As HRESULT

Declare Function WorkerThreadContextGetExecutableDirectory( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal ppExecutableDirectory As WString Ptr Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetExecutableDirectory( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pExecutableDirectory As WString Ptr _
)As HRESULT

Declare Function WorkerThreadContextGetWebSiteContainer( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal ppIWebSiteContainer As IWebSiteContainer Ptr Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetWebSiteContainer( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pIWebSiteContainer As IWebSiteContainer Ptr _
)As HRESULT

Declare Function WorkerThreadContextGetNetworkStream( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal ppINetworkStream As INetworkStream Ptr Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetNetworkStream( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pINetworkStream As INetworkStream Ptr _
)As HRESULT

Declare Function WorkerThreadContextGetThreadContextHeap( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pThreadContextHeap As HANDLE Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetThreadContextHeap( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal ThreadContextHeap As HANDLE _
)As HRESULT

Declare Function WorkerThreadContextGetFrequency( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pFrequency As LARGE_INTEGER Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetFrequency( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal Frequency As LARGE_INTEGER _
)As HRESULT

Declare Function WorkerThreadContextGetStartTicks( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pStartTicks As LARGE_INTEGER Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetStartTicks( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal StartTicks As LARGE_INTEGER _
)As HRESULT

Declare Function WorkerThreadContextGetClientRequest( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal ppIRequest As IClientRequest Ptr Ptr _
)As HRESULT

Declare Function WorkerThreadContextSetClientRequest( _
	ByVal this As WorkerThreadContext Ptr, _
	ByVal pIRequest As IClientRequest Ptr _
)As HRESULT

#endif
