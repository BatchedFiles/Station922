#ifndef ICLIENTSOCKET_BI
#define ICLIENTSOCKET_BI

#include once "IBaseStream.bi"
#include once "win\winsock2.bi"

Extern IID_IClientSocket Alias "IID_IClientSocket" As Const IID

Type IClientSocket As IClientSocket_

Type IClientSocketVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IClientSocket Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IClientSocket Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IClientSocket Ptr _
	)As ULONG
	
	GetSocket As Function( _
		ByVal this As IClientSocket Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	SetSocket As Function( _
		ByVal this As IClientSocket Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	
	CloseSocket As Function( _
		ByVal this As IClientSocket Ptr _
	)As HRESULT
	
End Type

Type IClientSocket_
	lpVtbl As IClientSocketVirtualTable Ptr
End Type

#define IClientSocket_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IClientSocket_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IClientSocket_Release(this) (this)->lpVtbl->Release(this)
#define IClientSocket_GetSocket(this, pResult) (this)->lpVtbl->GetSocket(this, pResult)
#define IClientSocket_SetSocket(this, sock) (this)->lpVtbl->SetSocket(this, sock)
#define IClientSocket_CloseSocket(this) (this)->lpVtbl->CloseSocket(this)

#endif
