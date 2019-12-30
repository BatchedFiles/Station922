#ifndef IWORKERTHREADCONTEXT_BI
#define IWORKERTHREADCONTEXT_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\ole2.bi"

Type IWorkerThreadContext As IWorkerThreadContext_

Type LPIWORKERTHREADCONTEXT As IWorkerThreadContext Ptr

Extern IID_IWorkerThreadContext Alias "IID_IWorkerThreadContext" As Const IID

Type IWorkerThreadContextVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim GetClientSocket As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pSocket As SOCKET Ptr _
	)As HRESULT
	
	Dim SetClientSocket As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ClientSocket As SOCKET _
	)As HRESULT
	
	Dim GetRemoteAddress As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pRemoteAddress As SOCKADDR_IN Ptr _
	)As HRESULT
	
	Dim SetRemoteAddress As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal RemoteAddress As SOCKADDR_IN _
	)As HRESULT
	
	Dim GetRemoteAddressLength As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	Dim SetRemoteAddressLength As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	Dim GetThreadId As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pThreadId As DWORD Ptr _
	)As HRESULT
	
	Dim SetThreadId As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ThreadId As DWORD _
	)As HRESULT
	
	Dim GetThreadHandle As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pThreadHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim SetThreadHandle As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ThreadHandle As HANDLE _
	)As HRESULT
	
	Dim GetExecutableDirectory As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ppExecutableDirectory As WString Ptr Ptr _
	)As HRESULT
	
	Dim SetExecutableDirectory As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pExecutableDirectory As WString Ptr _
	)As HRESULT
	
	Dim GetWebSiteContainer As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ppIWebSiteContainer As IWebSiteContainer Ptr Ptr _
	)As HRESULT
	
	Dim SetWebSiteContainer As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pIWebSiteContainer As IWebSiteContainer Ptr _
	)As HRESULT
	
	Dim GetNetworkStream As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ppINetworkStream As INetworkStream Ptr Ptr _
	)As HRESULT
	
	Dim SetNetworkStream As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr _
	)As HRESULT
	
	Dim GetThreadContextHeap As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pThreadContextHeap As HANDLE Ptr _
	)As HRESULT
	
	Dim SetThreadContextHeap As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ThreadContextHeap As HANDLE _
	)As HRESULT
	
	Dim GetFrequency As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pFrequency As LARGE_INTEGER Ptr _
	)As HRESULT
	
	Dim SetFrequency As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal Frequency As LARGE_INTEGER _
	)As HRESULT
	
	Dim GetStartTicks As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pStartTicks As LARGE_INTEGER Ptr _
	)As HRESULT
	
	Dim SetStartTicks As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal StartTicks As LARGE_INTEGER _
	)As HRESULT
	
	' Dim hInput As HANDLE
	' Dim hOutput As HANDLE
	' Dim hError As HANDLE
	
End Type

Type IWorkerThreadContext_
	Dim pVirtualTable As IWorkerThreadContextVirtualTable Ptr
End Type

#define IWorkerThreadContext_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IWorkerThreadContext_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IWorkerThreadContext_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IWorkerThreadContext_GetClientSocket(this, pSocket) (this)->pVirtualTable->GetClientSocket(this, pSocket)
#define IWorkerThreadContext_SetClientSocket(this, ClientSocket) (this)->pVirtualTable->SetClientSocket(this, ClientSocket)
#define IWorkerThreadContext_GetRemoteAddress(this, pRemoteAddress) (this)->pVirtualTable->GetRemoteAddress(this, pRemoteAddress)
#define IWorkerThreadContext_SetRemoteAddress(this, RemoteAddress) (this)->pVirtualTable->SetRemoteAddress(this, RemoteAddress)
#define IWorkerThreadContext_GetRemoteAddressLength(this, pRemoteAddressLength) (this)->pVirtualTable->GetRemoteAddressLength(this, pRemoteAddressLength)
#define IWorkerThreadContext_SetRemoteAddressLength(this, RemoteAddressLength) (this)->pVirtualTable->SetRemoteAddressLength(this, RemoteAddressLength)
#define IWorkerThreadContext_GetThreadId(this, pThreadId) (this)->pVirtualTable->GetThreadId(this, pThreadId)
#define IWorkerThreadContext_SetThreadId(this, ThreadId) (this)->pVirtualTable->SetThreadId(this, ThreadId)
#define IWorkerThreadContext_GetThreadHandle(this, pThreadHandle) (this)->pVirtualTable->GetThreadHandle(this, pThreadHandle)
#define IWorkerThreadContext_SetThreadHandle(this, ThreadHandle) (this)->pVirtualTable->SetThreadHandle(this, ThreadHandle)
#define IWorkerThreadContext_GetExecutableDirectory(this, ppExecutableDirectory) (this)->pVirtualTable->GetExecutableDirectory(this, ppExecutableDirectory)
#define IWorkerThreadContext_SetExecutableDirectory(this, pExecutableDirectory) (this)->pVirtualTable->SetExecutableDirectory(this, pExecutableDirectory)
#define IWorkerThreadContext_GetWebSiteContainer(this, ppIWebSiteContainer) (this)->pVirtualTable->GetWebSiteContainer(this, ppIWebSiteContainer)
#define IWorkerThreadContext_SetWebSiteContainer(this, pIWebSiteContainer) (this)->pVirtualTable->SetWebSiteContainer(this, pIWebSiteContainer)
#define IWorkerThreadContext_GetNetworkStream(this, ppINetworkStream) (this)->pVirtualTable->GetNetworkStream(this, ppINetworkStream)
#define IWorkerThreadContext_SetNetworkStream(this, pINetworkStream) (this)->pVirtualTable->SetNetworkStream(this, pINetworkStream)
#define IWorkerThreadContext_GetThreadContextHeap(this, pThreadContextHeap) (this)->pVirtualTable->GetThreadContextHeap(this, pThreadContextHeap)
#define IWorkerThreadContext_SetThreadContextHeap(this, ThreadContextHeap) (this)->pVirtualTable->SetThreadContextHeap(this, ThreadContextHeap)
#define IWorkerThreadContext_GetFrequency(this, pFrequency) (this)->pVirtualTable->GetFrequency(this, pFrequency)
#define IWorkerThreadContext_SetFrequency(this, Frequency) (this)->pVirtualTable->SetFrequency(this, Frequency)
#define IWorkerThreadContext_GetStartTicks(this, pStartTicks) (this)->pVirtualTable->GetStartTicks(this, pStartTicks)
#define IWorkerThreadContext_SetStartTicks(this, StartTicks) (this)->pVirtualTable->SetStartTicks(this, StartTicks)

#endif
