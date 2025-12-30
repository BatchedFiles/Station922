#ifndef IOBJECTPOOL_BI
#define IOBJECTPOOL_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Extern IID_IObjectPool Alias "IID_IObjectPool" As Const IID

Const OBJECT_POOL_CAPACITY = 1

Enum ObjectPoolIds
	HTTPREADER_POOL_ID
	NETWORKSTREAM_POOL_ID
	CLIENTREQUEST_POOL_ID
	CLIENTURI_POOL_ID
	FILEASYNCSTREAM_POOL_ID
	HTTPASYNCWRITER_POOL_ID
	READREQUESTASYNCTASK_POOL_ID
	SERVERRESPONSE_POOL_ID
	WRITERESPONSEASYNCTASK_POOL_ID
End Enum

Enum PoolItemStatuses
	ItemUsed = -1
	ItemFree = 0
End Enum

Type IObjectPool As IObjectPool_

Type IObjectPoolVirtualTable

	QueryInterface As Function( _
		ByVal this As IObjectPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal this As IObjectPool Ptr _
	)As ULONG

	Release As Function( _
		ByVal this As IObjectPool Ptr _
	)As ULONG

	GetPool As Function( _
		ByVal this As IObjectPool Ptr, _
		ByVal PoolId As ObjectPoolIds, _
		ByVal ppPool As Any Ptr Ptr _
	)As HRESULT

	SetPool As Function( _
		ByVal this As IObjectPool Ptr, _
		ByVal PoolId As ObjectPoolIds, _
		ByVal pPool As Any Ptr _
	)As HRESULT

End Type

Type IObjectPool_
	lpVtbl As IObjectPoolVirtualTable Ptr
End Type

#define IObjectPool_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IObjectPool_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IObjectPool_Release(this) (this)->lpVtbl->Release(this)
#define IObjectPool_GetPool(this, PoolId, ppPool) (this)->lpVtbl->GetPool(this, PoolId, ppPool)
#define IObjectPool_SetPool(this, PoolId, pPool) (this)->lpVtbl->SetPool(this, PoolId, pPool)

#endif
