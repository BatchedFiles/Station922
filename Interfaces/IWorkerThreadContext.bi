#ifndef IWORKERTHREADCONTEXT_BI
#define IWORKERTHREADCONTEXT_BI

#include "IClientRequest.bi"
#include "IHttpReader.bi"
#include "INetworkStream.bi"
#include "IRequestedFile.bi"
#include "IServerResponse.bi"
#include "IWebSiteContainer.bi"

Type IWorkerThreadContext As IWorkerThreadContext_

Type LPIWORKERTHREADCONTEXT As IWorkerThreadContext Ptr

Extern IID_IWorkerThreadContext Alias "IID_IWorkerThreadContext" As Const IID

Type IWorkerThreadContextVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
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
	
	Dim GetClientRequest As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ppIRequest As IClientRequest Ptr Ptr _
	)As HRESULT
	
	Dim SetClientRequest As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pIRequest As IClientRequest Ptr _
	)As HRESULT
	
	Dim GetServerResponse As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ppIResponse As IServerResponse Ptr Ptr _
	)As HRESULT
	
	Dim SetServerResponse As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pIResponse As IServerResponse Ptr _
	)As HRESULT
	
	Dim GetHttpReader As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ppIHttpReader As IHttpReader Ptr Ptr _
	)As HRESULT
	
	Dim SetHttpReader As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr _
	)As HRESULT
	
	Dim GetRequestedFile As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal ppIRequestedFile As IRequestedFile Ptr Ptr _
	)As HRESULT
	
	Dim SetRequestedFile As Function( _
		ByVal this As IWorkerThreadContext Ptr, _
		ByVal pIRequestedFile As IRequestedFile Ptr _
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
#define IWorkerThreadContext_GetFrequency(this, pFrequency) (this)->pVirtualTable->GetFrequency(this, pFrequency)
#define IWorkerThreadContext_SetFrequency(this, Frequency) (this)->pVirtualTable->SetFrequency(this, Frequency)
#define IWorkerThreadContext_GetStartTicks(this, pStartTicks) (this)->pVirtualTable->GetStartTicks(this, pStartTicks)
#define IWorkerThreadContext_SetStartTicks(this, StartTicks) (this)->pVirtualTable->SetStartTicks(this, StartTicks)
#define IWorkerThreadContext_GetClientRequest(this, ppIRequest) (this)->pVirtualTable->GetClientRequest(this, ppIRequest)
#define IWorkerThreadContext_SetClientRequest(this, pIRequest) (this)->pVirtualTable->SetClientRequest(this, pIRequest)
#define IWorkerThreadContext_GetServerResponse(this, ppIResponse) (this)->pVirtualTable->GetServerResponse(this, ppIResponse)
#define IWorkerThreadContext_SetServerResponse(this, pIResponse) (this)->pVirtualTable->SetServerResponse(this, pIResponse)
#define IWorkerThreadContext_GetHttpReader(this, ppIHttpReader) (this)->pVirtualTable->GetHttpReader(this, ppIHttpReader)
#define IWorkerThreadContext_SetHttpReader(this, pIHttpReader) (this)->pVirtualTable->SetHttpReader(this, pIHttpReader)
#define IWorkerThreadContext_GetRequestedFile(this, ppIRequestedFile) (this)->pVirtualTable->GetRequestedFile(this, ppIRequestedFile)
#define IWorkerThreadContext_SetRequestedFile(this, pIRequestedFile) (this)->pVirtualTable->SetRequestedFile(this, pIRequestedFile)

#endif
