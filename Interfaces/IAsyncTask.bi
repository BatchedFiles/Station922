#ifndef IASYNCTASK_BI
#define IASYNCTASK_BI

#include once "IThreadPool.bi"
#include once "IAsyncResult.bi"

Type IAsyncTask As IAsyncTask_

Extern IID_IAsyncTask Alias "IID_IAsyncTask" As Const IID

Type IAsyncTaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IAsyncTask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IAsyncTask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IAsyncTask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As IAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As IAsyncTask Ptr, _
		ByVal pPool As IThreadPool Ptr, _
		ByVal pIResult As IAsyncResult Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
	GetAssociatedWithIOCP As Function( _
		ByVal this As IAsyncTask Ptr, _
		ByVal pAssociated As Boolean Ptr _
	)As HRESULT
	
	SetAssociatedWithIOCP As Function( _
		ByVal this As IAsyncTask Ptr, _
		ByVal Associated As Boolean _
	)As HRESULT
	
End Type

Type IAsyncTask_
	lpVtbl As IAsyncTaskVirtualTable Ptr
End Type

#define IAsyncTask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IAsyncTask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IAsyncTask_Release(this) (this)->lpVtbl->Release(this)
#define IAsyncTask_BeginExecute(this, pPool) (this)->lpVtbl->BeginExecute(this, pPool)
#define IAsyncTask_EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey) (this)->lpVtbl->EndExecute(this, pPool, pIResult, BytesTransferred, CompletionKey)
#define IAsyncTask_GetAssociatedWithIOCP(this, pAssociated) (this)->lpVtbl->GetAssociatedWithIOCP(this, pAssociated)
#define IAsyncTask_SetAssociatedWithIOCP(this, Associated) (this)->lpVtbl->SetAssociatedWithIOCP(this, Associated)

#endif
