#ifndef ITHREADPOOL_BI
#define ITHREADPOOL_BI

#include once "IAsyncResult.bi"

Extern IID_IThreadPool Alias "IID_IThreadPool" As Const IID

Type IThreadPool As IThreadPool_

Type IThreadPoolVirtualTable

	QueryInterface As Function( _
		ByVal self As IThreadPool Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IThreadPool Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IThreadPool Ptr _
	)As ULONG

	GetMaxThreads As Function( _
		ByVal self As IThreadPool Ptr, _
		ByVal pMaxThreads As UInteger Ptr _
	)As HRESULT

	SetMaxThreads As Function( _
		ByVal self As IThreadPool Ptr, _
		ByVal MaxThreads As UInteger _
	)As HRESULT

	Run As Function( _
		ByVal self As IThreadPool Ptr _
	)As HRESULT

	Stop As Function( _
		ByVal self As IThreadPool Ptr _
	)As HRESULT

	AssociateDevice As Function( _
		ByVal self As IThreadPool Ptr, _
		ByVal hHandle As HANDLE, _
		ByVal pUserData As Any Ptr _
	)As HRESULT

	PostPacket As Function( _
		ByVal self As IThreadPool Ptr, _
		ByVal PacketSize As DWORD, _
		ByVal CompletionKey As ULONG_PTR, _
		ByVal pIResult As IAsyncResult Ptr _
	)As HRESULT

End Type

Type IThreadPool_
	lpVtbl As IThreadPoolVirtualTable Ptr
End Type

#define IThreadPool_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IThreadPool_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IThreadPool_Release(self) (self)->lpVtbl->Release(self)
#define IThreadPool_GetMaxThreads(self, pMaxThreads) (self)->lpVtbl->GetMaxThreads(self, pMaxThreads)
#define IThreadPool_SetMaxThreads(self, MaxThreads) (self)->lpVtbl->SetMaxThreads(self, MaxThreads)
#define IThreadPool_Run(self) (self)->lpVtbl->Run(self)
#define IThreadPool_Stop(self) (self)->lpVtbl->Stop(self)
#define IThreadPool_AssociateDevice(self, hHandle, pUserData) (self)->lpVtbl->AssociateDevice(self, hHandle, pUserData)
#define IThreadPool_PostPacket(self, PacketSize, CompletionKey, pIResult) (self)->lpVtbl->PostPacket(self, PacketSize, CompletionKey, pIResult)

#endif
