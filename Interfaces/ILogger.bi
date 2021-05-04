#ifndef ILOGGER_BI
#define ILOGGER_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type ILogger As ILogger_

Type LPLOGGER As ILogger Ptr

Extern IID_ILogger Alias "IID_ILogger" As Const IID

Type ILoggerVirtualTable
	
	Dim QueryInterface As Function( _
		ByVal this As ILogger Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Dim AddRef As Function( _
		ByVal this As ILogger Ptr _
	)As ULONG
	
	Dim Release As Function( _
		ByVal this As ILogger Ptr _
	)As ULONG
	
End Type

Type ILogger_
	Dim lpVtbl As ILoggerVirtualTable Ptr
End Type

#define ILogger_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ILogger_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ILogger_Release(this) (this)->lpVtbl->Release(this)

#endif
