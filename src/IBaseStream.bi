#ifndef IBASESTREAM_BI
#define IBASESTREAM_BI

#include once "IAsyncResult.bi"

Extern IID_IBaseStream Alias "IID_IBaseStream" As Const IID

' IBaseStream.BeginRead:
' BASESTREAM_S_IO_PENDING, Any E_FAIL

' IBaseStream.EndRead:
' S_OK, S_FALSE, E_FAIL

' IBaseStream.BeginWrite:
' BASESTREAM_S_IO_PENDING, Any E_FAIL

' IBaseStream.EndWrite:
' S_OK, S_FALSE, E_FAIL

Const BASESTREAM_S_IO_PENDING As HRESULT = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_ITF, &h0201)

Enum SeekOrigin
	SeekBegin
	SeekCurrent
	SeekEnd
End Enum

Type BaseStreamBuffer
	Buffer As ZString Ptr
	Length As Integer
End Type

Type IBaseStream As IBaseStream_

Type IBaseStreamVirtualTable
	
	QueryInterface As Function( _
		ByVal this As IBaseStream Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	AddRef As Function( _
		ByVal this As IBaseStream Ptr _
	)As ULONG
	
	Release As Function( _
		ByVal this As IBaseStream Ptr _
	)As ULONG
	
	BeginRead As Function( _
		ByVal this As IBaseStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWrite As Function( _
		ByVal this As IBaseStream Ptr, _
		ByVal Buffer As LPVOID, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	EndRead As Function( _
		ByVal this As IBaseStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pReadedBytes As DWORD Ptr _
	)As HRESULT
	
	EndWrite As Function( _
		ByVal this As IBaseStream Ptr, _
		ByVal pIAsyncResult As IAsyncResult Ptr, _
		ByVal pWritedBytes As DWORD Ptr _
	)As HRESULT
	
	BeginReadScatter As Function( _
		ByVal this As IBaseStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGather As Function( _
		ByVal this As IBaseStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
	BeginWriteGatherAndShutdown As Function( _
		ByVal this As IBaseStream Ptr, _
		ByVal pBuffer As BaseStreamBuffer Ptr, _
		ByVal Count As DWORD, _
		ByVal StateObject As IUnknown Ptr, _
		ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
	)As HRESULT
	
End Type

Type IBaseStream_
	lpVtbl As IBaseStreamVirtualTable Ptr
End Type

#define IBaseStream_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IBaseStream_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IBaseStream_Release(this) (this)->lpVtbl->Release(this)
#define IBaseStream_BeginRead(this, Buffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginRead(this, Buffer, Count, StateObject, ppIAsyncResult)
#define IBaseStream_BeginWrite(this, Buffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWrite(this, Buffer, Count, StateObject, ppIAsyncResult)
#define IBaseStream_EndRead(this, pIAsyncResult, pReadedBytes) (this)->lpVtbl->EndRead(this, pIAsyncResult, pReadedBytes)
#define IBaseStream_EndWrite(this, pIAsyncResult, pWritedBytes) (this)->lpVtbl->EndWrite(this, pIAsyncResult, pWritedBytes)
#define IBaseStream_BeginReadScatter(this, pBuffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginReadScatter(this, pBuffer, Count, StateObject, ppIAsyncResult)
#define IBaseStream_BeginWriteGather(this, pBuffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGather(this, pBuffer, Count, StateObject, ppIAsyncResult)
#define IBaseStream_BeginWriteGatherAndShutdown(this, pBuffer, Count, StateObject, ppIAsyncResult) (this)->lpVtbl->BeginWriteGatherAndShutdown(this, pBuffer, Count, StateObject, ppIAsyncResult)

#endif
