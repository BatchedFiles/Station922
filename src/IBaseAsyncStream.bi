#ifndef IBASEASYNCSTREAM_BI
#define IBASEASYNCSTREAM_BI

#include once "IAsyncResult.bi"

Extern IID_IBaseAsyncStream Alias "IID_IBaseAsyncStream" As Const IID

' IBaseAsyncStream.BeginRead:
' S_OK, Any E_FAIL

' IBaseAsyncStream.EndRead:
' S_OK, S_FALSE, E_FAIL

' IBaseAsyncStream.BeginWrite:
' S_OK, Any E_FAIL

' IBaseAsyncStream.EndWrite:
' S_OK, S_FALSE, E_FAIL

Enum SeekOrigin
	SeekBegin
	SeekCurrent
	SeekEnd
End Enum

Type BaseStreamBuffer
	Buffer As ZString Ptr
	Length As Integer
End Type

Type IBaseAsyncStream As IBaseAsyncStream_

Type IBaseAsyncStreamVirtualTable

	QueryInterface As Function( _
		ByVal self As IBaseAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT

	AddRef As Function( _
		ByVal self As IBaseAsyncStream Ptr _
	)As ULONG

	Release As Function( _
		ByVal self As IBaseAsyncStream Ptr _
	)As ULONG

	BeginRead As Function( _
		ByVal self As IBaseAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	BeginWrite As Function( _
		ByVal self As IBaseAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	EndRead As Function( _
		ByVal self As IBaseAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT

	EndWrite As Function( _
		ByVal self As IBaseAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT

	BeginReadScatter As Function( _
		ByVal self As IBaseAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	BeginWriteGather As Function( _
		ByVal self As IBaseAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

	BeginWriteGatherAndShutdown As Function( _
		ByVal self As IBaseAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT

End Type

Type IBaseAsyncStream_
	lpVtbl As IBaseAsyncStreamVirtualTable Ptr
End Type

#define IBaseAsyncStream_QueryInterface(self, riid, ppv) (self)->lpVtbl->QueryInterface(self, riid, ppv)
#define IBaseAsyncStream_AddRef(self) (self)->lpVtbl->AddRef(self)
#define IBaseAsyncStream_Release(self) (self)->lpVtbl->Release(self)
#define IBaseAsyncStream_BeginRead(self, Buffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginRead(self, Buffer, Count, pcb, StateObject, ppIAsyncResult)
#define IBaseAsyncStream_BeginWrite(self, Buffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginWrite(self, Buffer, Count, pcb, StateObject, ppIAsyncResult)
#define IBaseAsyncStream_EndRead(self, pIAsyncResult, pReadedBytes) (self)->lpVtbl->EndRead(self, pIAsyncResult, pReadedBytes)
#define IBaseAsyncStream_EndWrite(self, pIAsyncResult, pWritedBytes) (self)->lpVtbl->EndWrite(self, pIAsyncResult, pWritedBytes)
#define IBaseAsyncStream_BeginReadScatter(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginReadScatter(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define IBaseAsyncStream_BeginWriteGather(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginWriteGather(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define IBaseAsyncStream_BeginWriteGatherAndShutdown(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (self)->lpVtbl->BeginWriteGatherAndShutdown(self, pBuffer, Count, pcb, StateObject, ppIAsyncResult)

#endif
