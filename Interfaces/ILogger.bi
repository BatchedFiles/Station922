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
	
	Dim LogDebug As Function( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Dim LogInformation As Function( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Dim LogWarning As Function( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Dim LogError As Function( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
	Dim LogCritical As Function( _
		ByVal this As ILogger Ptr, _
		ByVal pwszText As WString Ptr, _
		ByVal vtData As VARIANT _
	)As HRESULT
	
End Type

Type ILogger_
	Dim lpVtbl As ILoggerVirtualTable Ptr
End Type

#define ILogger_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define ILogger_AddRef(this) (this)->lpVtbl->AddRef(this)
#define ILogger_Release(this) (this)->lpVtbl->Release(this)
#define ILogger_LogDebug(this, pwszText, vtData) (this)->lpVtbl->LogDebug(this, pwszText, vtData)
#define ILogger_LogInformation(this, pwszText, vtData) (this)->lpVtbl->LogInformation(this, pwszText, vtData)
#define ILogger_LogWarning(this, pwszText, vtData) (this)->lpVtbl->LogWarning(this, pwszText, vtData)
#define ILogger_LogError(this, pwszText, vtData) (this)->lpVtbl->LogError(this, pwszText, vtData)
#define ILogger_LogCritical(this, pwszText, vtData) (this)->lpVtbl->LogCritical(this, pwszText, vtData)

#endif
