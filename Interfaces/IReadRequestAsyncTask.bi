#ifndef IREADREQUESTASYNCTASK_BI
#define IREADREQUESTASYNCTASK_BI

#include once "IAsyncTask.bi"
#include once "IAsyncResult.bi"
#include once "IWebSiteCollection.bi"
#include once "win\winsock2.bi"

Type IReadRequestAsyncTask As IReadRequestAsyncTask_

Type LPIREADREQUESTASYNCTASK As IReadRequestAsyncTask Ptr

Extern IID_IReadRequestAsyncTask Alias "IID_IReadRequestAsyncTask" As Const IID

Type IReadRequestAsyncTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IReadRequestAsyncTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IReadRequestAsyncTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	GetWebSiteCollection As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal ppIWebSites As IWebSiteCollection Ptr Ptr _
	)As HRESULT
	
	SetWebSiteCollection As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pIWebSites As IWebSiteCollection Ptr _
	)As HRESULT
	
	GetSocket As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	SetSocket As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	
	GetRemoteAddress As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal pRemoteAddress As SOCKADDR Ptr, _
		ByVal pRemoteAddressLength As Integer Ptr _
	)As HRESULT
	
	SetRemoteAddress As Function( _
		ByVal this As IReadRequestAsyncTask Ptr, _
		ByVal RemoteAddress As SOCKADDR Ptr, _
		ByVal RemoteAddressLength As Integer _
	)As HRESULT
	
End Type

Type IReadRequestAsyncTask_
	lpVtbl As IReadRequestAsyncTaskVirtualTable Ptr
End Type

#define IReadRequestAsyncTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IReadRequestAsyncTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IReadRequestAsyncTask_Release(this) (this)->lpVtbl->Release(this)
#define IReadRequestAsyncTask_BeginExecute(this, pPool) (this)->lpVtbl->BeginExecute(this, pPool)
#define IReadRequestAsyncTask_EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey) (this)->lpVtbl->EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey)
#define IReadRequestAsyncTask_GetWebSiteCollection(this, ppIWebSites) (this)->lpVtbl->GetWebSiteCollection(this, ppIWebSites)
#define IReadRequestAsyncTask_SetWebSiteCollection(this, pIWebSites) (this)->lpVtbl->SetWebSiteCollection(this, pIWebSites)
#define IReadRequestAsyncTask_GetSocket(this, pResult) (this)->lpVtbl->GetSocket(this, pResult)
#define IReadRequestAsyncTask_SetSocket(this, sock) (this)->lpVtbl->SetSocket(this, sock)
#define IReadRequestAsyncTask_GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength) (this)->lpVtbl->GetRemoteAddress(this, pRemoteAddress, pRemoteAddressLength)
#define IReadRequestAsyncTask_SetRemoteAddress(this, RemoteAddress, RemoteAddressLength) (this)->lpVtbl->SetRemoteAddress(this, RemoteAddress, RemoteAddressLength)

#endif
