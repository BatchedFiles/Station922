#ifndef ITASK_BI
#define ITASK_BI

#include once "IThreadPool.bi"

Type ITask As ITask_

Type LPITASK As ITask Ptr

Type _TASKOVERLAPPED
	OverLap As OVERLAPPED
	pITask As ITask Ptr
End Type

Type TASKOVERLAPPED As _TASKOVERLAPPED

Type LPTASKOVERLAPPED As _TASKOVERLAPPED Ptr

Extern IID_ITask Alias "IID_ITask" As Const IID

Type ITaskVirtualTable
	
	QueryInterface As Function( _
		ByVal this As ITask Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As ITask Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As ITask Ptr _
	)As ULONG
	
	BeginExecute As Function( _
		ByVal this As ITask Ptr, _
		ByVal pPool As IThreadPool Ptr _
	)As HRESULT
	
	EndExecute As Function( _
		ByVal this As ITask Ptr, _
		ByVal BytesTransferred As DWORD, _
		ByVal CompletionKey As ULONG_PTR _
	)As HRESULT
	
End Type

Type ITask_
	lpVtbl As ITaskVirtualTable Ptr
End Type

#define ITask_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ITask_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ITask_Release(this) (this)->lpVtbl->Release(this)
#define ITask_BeginExecute(this, pPool) (this)->lpVtbl->BeginExecute(this, pPool)
#define ITask_EndExecute(this, BytesTransferred, CompletionKey) (this)->lpVtbl->EndExecute(this, BytesTransferred, CompletionKey)

#endif
