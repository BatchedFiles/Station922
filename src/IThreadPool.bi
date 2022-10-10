#ifndef ITHREADPOOL_BI
#define ITHREADPOOL_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type ThreadPoolCallBack As Function( _
	ByVal param As Any Ptr, _
	ByVal BytesTransferred As DWORD, _
	ByVal CompletionKey As ULONG_PTR, _
	ByVal pOverlap As OVERLAPPED Ptr _
)As Integer

Type IThreadPool As IThreadPool_

Type LPITHREADPOOL As IThreadPool Ptr

Extern IID_IThreadPool Alias "IID_IThreadPool" As Const IID

Type IThreadPoolVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IThreadPool Ptr _
	)As ULONG
	
	GetMaxThreads As Function( _
		ByVal this As IThreadPool Ptr, _
		ByVal pMaxThreads As Integer Ptr _
	)As HRESULT
	
	SetMaxThreads As Function( _
		ByVal this As IThreadPool Ptr, _
		ByVal MaxThreads As Integer _
	)As HRESULT
	
	Run As Function( _
		ByVal this As IThreadPool Ptr, _
		ByVal CallBack As ThreadPoolCallBack, _
		ByVal param As Any Ptr _
	)As HRESULT
	
	Stop As Function( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	
	GetIOCompletionPort As Function( _
		ByVal this As IThreadPool Ptr, _
		ByVal pPort As HANDLE Ptr _
	)As HRESULT
	
End Type

Type IThreadPool_
	lpVtbl As IThreadPoolVirtualTable Ptr
End Type

#define IThreadPool_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IThreadPool_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IThreadPool_Release(this) (this)->lpVtbl->Release(this)
#define IThreadPool_GetMaxThreads(this, pMaxThreads) (this)->lpVtbl->GetMaxThreads(this, pMaxThreads)
#define IThreadPool_SetMaxThreads(this, MaxThreads) (this)->lpVtbl->SetMaxThreads(this, MaxThreads)
#define IThreadPool_Run(this, CallBack, param) (this)->lpVtbl->Run(this, CallBack, param)
#define IThreadPool_Stop(this) (this)->lpVtbl->Stop(this)
#define IThreadPool_GetIOCompletionPort(this, pPort) (this)->lpVtbl->GetIOCompletionPort(this, pPort)

#endif
