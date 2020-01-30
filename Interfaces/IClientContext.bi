#ifndef ICLIENTCONTEXT_BI
#define ICLIENTCONTEXT_BI

#include "IClientRequest.bi"
#include "IHttpReader.bi"
#include "INetworkStream.bi"
#include "IRequestedFile.bi"
#include "IServerResponse.bi"
#include "IWebSiteContainer.bi"

Type IClientContext As IClientContext_

Type LPICLIENTCONTEXT As IClientContext Ptr

Extern IID_IClientContext Alias "IID_IClientContext" As Const IID

Type IClientContextVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim GetRemoteAddress As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pRemoteAddress As SOCKADDR_IN Ptr _
	)As HRESULT
	
	Dim SetRemoteAddress As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal RemoteAddress As SOCKADDR_IN _
	)As HRESULT
	
	Dim GetRemoteAddressLength As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	Dim SetRemoteAddressLength As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
	Dim GetThreadId As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pThreadId As DWORD Ptr _
	)As HRESULT
	
	Dim SetThreadId As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ThreadId As DWORD _
	)As HRESULT
	
	Dim GetThreadHandle As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pThreadHandle As HANDLE Ptr _
	)As HRESULT
	
	Dim SetThreadHandle As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ThreadHandle As HANDLE _
	)As HRESULT
	
	Dim GetClientContextHeap As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pHeap As HANDLE Ptr _
	)As HRESULT
	
	Dim SetClientContextHeap As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal hHeap As HANDLE _
	)As HRESULT
	
	Dim GetExecutableDirectory As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppExecutableDirectory As WString Ptr Ptr _
	)As HRESULT
	
	Dim SetExecutableDirectory As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pExecutableDirectory As WString Ptr _
	)As HRESULT
	
	Dim GetWebSiteContainer As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIWebSiteContainer As IWebSiteContainer Ptr Ptr _
	)As HRESULT
	
	Dim SetWebSiteContainer As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIWebSiteContainer As IWebSiteContainer Ptr _
	)As HRESULT
	
	Dim GetNetworkStream As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppINetworkStream As INetworkStream Ptr Ptr _
	)As HRESULT
	
	Dim SetNetworkStream As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pINetworkStream As INetworkStream Ptr _
	)As HRESULT
	
	Dim GetFrequency As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pFrequency As LARGE_INTEGER Ptr _
	)As HRESULT
	
	Dim SetFrequency As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal Frequency As LARGE_INTEGER _
	)As HRESULT
	
	Dim GetStartTicks As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pStartTicks As LARGE_INTEGER Ptr _
	)As HRESULT
	
	Dim SetStartTicks As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal StartTicks As LARGE_INTEGER _
	)As HRESULT
	
	Dim GetClientRequest As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	Dim SetClientRequest As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	Dim GetServerResponse As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIResponse As IServerResponse Ptr Ptr _
	)As HRESULT
	
	Dim SetServerResponse As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)As HRESULT
	
	Dim GetHttpReader As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIHttpReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	Dim SetHttpReader As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr _
	)As HRESULT
	
	Dim GetRequestedFile As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIRequestedFile As IRequestedFile Ptr Ptr _
	)As HRESULT
	
	Dim SetRequestedFile As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
	)As HRESULT
	
	Dim GetWebSite As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	Dim SetWebSite As Function( _
		ByVal this As IClientContext Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
End Type

Type IClientContext_
	Dim pVirtualTable As IClientContextVirtualTable Ptr
End Type

#define IClientContext_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IClientContext_AddRef(this) (this)->pVirtualTable->InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IClientContext_Release(this) (this)->pVirtualTable->InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IClientContext_GetRemoteAddress(this, pRemoteAddress) (this)->pVirtualTable->GetRemoteAddress(this, pRemoteAddress)
#define IClientContext_SetRemoteAddress(this, RemoteAddress) (this)->pVirtualTable->SetRemoteAddress(this, RemoteAddress)
#define IClientContext_GetRemoteAddressLength(this, pRemoteAddressLength) (this)->pVirtualTable->GetRemoteAddressLength(this, pRemoteAddressLength)
#define IClientContext_SetRemoteAddressLength(this, RemoteAddressLength) (this)->pVirtualTable->SetRemoteAddressLength(this, RemoteAddressLength)
#define IClientContext_GetThreadId(this, pThreadId) (this)->pVirtualTable->GetThreadId(this, pThreadId)
#define IClientContext_SetThreadId(this, ThreadId) (this)->pVirtualTable->SetThreadId(this, ThreadId)
#define IClientContext_GetThreadHandle(this, pThreadHandle) (this)->pVirtualTable->GetThreadHandle(this, pThreadHandle)
#define IClientContext_SetThreadHandle(this, ThreadHandle) (this)->pVirtualTable->SetThreadHandle(this, ThreadHandle)
#define IClientContext_GetClientContextHeap(this, pHeap) (this)->pVirtualTable->GetClientContextHeap(this, pHeap)
#define IClientContext_SetClientContextHeap(this, hHeap) (this)->pVirtualTable->SetClientContextHeap(this, hHeap)
#define IClientContext_GetExecutableDirectory(this, ppExecutableDirectory) (this)->pVirtualTable->GetExecutableDirectory(this, ppExecutableDirectory)
#define IClientContext_SetExecutableDirectory(this, pExecutableDirectory) (this)->pVirtualTable->SetExecutableDirectory(this, pExecutableDirectory)
#define IClientContext_GetWebSiteContainer(this, ppIWebSiteContainer) (this)->pVirtualTable->GetWebSiteContainer(this, ppIWebSiteContainer)
#define IClientContext_SetWebSiteContainer(this, pIWebSiteContainer) (this)->pVirtualTable->SetWebSiteContainer(this, pIWebSiteContainer)
#define IClientContext_GetNetworkStream(this, ppINetworkStream) (this)->pVirtualTable->GetNetworkStream(this, ppINetworkStream)
' #define IClientContext_SetNetworkStream(this, pINetworkStream) (this)->pVirtualTable->SetNetworkStream(this, pINetworkStream)
#define IClientContext_GetFrequency(this, pFrequency) (this)->pVirtualTable->GetFrequency(this, pFrequency)
#define IClientContext_SetFrequency(this, Frequency) (this)->pVirtualTable->SetFrequency(this, Frequency)
#define IClientContext_GetStartTicks(this, pStartTicks) (this)->pVirtualTable->GetStartTicks(this, pStartTicks)
#define IClientContext_SetStartTicks(this, StartTicks) (this)->pVirtualTable->SetStartTicks(this, StartTicks)
#define IClientContext_GetClientRequest(this, ppIRequest) (this)->pVirtualTable->GetClientRequest(this, ppIRequest)
' #define IClientContext_SetClientRequest(this, pIRequest) (this)->pVirtualTable->SetClientRequest(this, pIRequest)
#define IClientContext_GetServerResponse(this, ppIResponse) (this)->pVirtualTable->GetServerResponse(this, ppIResponse)
' #define IClientContext_SetServerResponse(this, pIResponse) (this)->pVirtualTable->SetServerResponse(this, pIResponse)
#define IClientContext_GetHttpReader(this, ppIHttpReader) (this)->pVirtualTable->GetHttpReader(this, ppIHttpReader)
' #define IClientContext_SetHttpReader(this, pIHttpReader) (this)->pVirtualTable->SetHttpReader(this, pIHttpReader)
#define IClientContext_GetRequestedFile(this, ppIRequestedFile) (this)->pVirtualTable->GetRequestedFile(this, ppIRequestedFile)
' #define IClientContext_SetRequestedFile(this, pIRequestedFile) (this)->pVirtualTable->SetRequestedFile(this, pIRequestedFile)
#define IClientContext_GetWebSite(this, ppIWebSite) (this)->pVirtualTable->GetWebSite(this, ppIWebSite)
' #define IClientContext_SetWebSite(this, pIWebSite) (this)->pVirtualTable->SetWebSite(this, pIWebSite)

#endif
