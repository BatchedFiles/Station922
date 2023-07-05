#ifndef ITHREADPOOL_BI
#define ITHREADPOOL_BI

#include once "IAsyncResult.bi"

Extern IID_IThreadPool Alias "IID_IThreadPool" As Const IID

Type IThreadPool As IThreadPool_

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
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT
	
	SetMaxThreads As Function( _
		ByVal this As IThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT
	
	Run As Function( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	
	Stop As Function( _
		ByVal this As IThreadPool Ptr _
	)As HRESULT
	
	AssociateDevice As Function( _
		ByVal this As IThreadPool Ptr, _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT
	
	PostPacket As Function( _
		ByVal this As IThreadPool Ptr, _
		ByVal PacketSize As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pIResult As IAsyncResult Ptr _
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
#define IThreadPool_Run(this) (this)->lpVtbl->Run(this)
#define IThreadPool_Stop(this) (this)->lpVtbl->Stop(this)
#define IThreadPool_AssociateDevice(this, hHandle, pUserData) (this)->lpVtbl->AssociateDevice(this, hHandle, pUserData)
#define IThreadPool_PostPacket(this, PacketSize, CompletionKey, pIResult) (this)->lpVtbl->PostPacket(this, PacketSize, CompletionKey, pIResult)

#endif
