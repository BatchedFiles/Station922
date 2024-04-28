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
		ByVal this As IBaseAsyncStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IBaseAsyncStream Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IBaseAsyncStream Ptr _
	)As ULONG
	
	BeginRead As Function( _
		ByVal this As IBaseAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWrite As Function( _
		ByVal this As IBaseAsyncStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndRead As Function( _
		ByVal this As IBaseAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	EndWrite As Function( _
		ByVal this As IBaseAsyncStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	BeginReadScatter As Function( _
		ByVal this As IBaseAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGather As Function( _
		ByVal this As IBaseAsyncStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal pcb As AsyncCallback, _
		ByVal StateObject As Any Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGatherAndShutdown As Function( _
		ByVal this As IBaseAsyncStream Ptr, _
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

#define IBaseAsyncStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IBaseAsyncStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IBaseAsyncStream_Release(this) (this)->lpVtbl->Release(this)
#define IBaseAsyncStream_BeginRead(this, Buffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginRead(this, Buffer, Count, pcb, StateObject, ppIAsyncResult)
#define IBaseAsyncStream_BeginWrite(this, Buffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, Buffer, Count, pcb, StateObject, ppIAsyncResult)
#define IBaseAsyncStream_EndRead(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndRead(this, pIAsyncResult, pReadedBytes)
#define IBaseAsyncStream_EndWrite(this, pIAsyncResult, pWritedBytes) (this)->lpVtbl->EndWrite(this, pIAsyncResult, pWritedBytes)
#define IBaseAsyncStream_BeginReadScatter(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadScatter(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define IBaseAsyncStream_BeginWriteGather(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGather(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult)
#define IBaseAsyncStream_BeginWriteGatherAndShutdown(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGatherAndShutdown(this, pBuffer, Count, pcb, StateObject, ppIAsyncResult)

#endif
