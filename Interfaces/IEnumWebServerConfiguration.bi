#ifndef IENUMWEBSERVERCONFIGURATION_BI
#define IENUMWEBSERVERCONFIGURATION_BI

#include once "IWebServerConfiguration.bi"

Type IEnumWebServerConfiguration As IEnumWebServerConfiguration_

Type LPIENUMWEBSERVERCONFIGURATION As IEnumWebServerConfiguration Ptr

Extern IID_IEnumWebServerConfiguration Alias "IID_IEnumWebServerConfiguration" As Const IID

Type IEnumWebServerConfigurationVirtualTable
	
	Dim QueryInterface As Function( _
		ByVal this As IEnumWebServerConfiguration Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	Dim AddRef As Function( _
		ByVal this As IEnumWebServerConfiguration Ptr _
	)As ULONG
	
	Dim Release As Function( _
		ByVal this As IEnumWebServerConfiguration Ptr _
	)As ULONG
	
	Dim Next As Function( _
		ByVal this As IEnumWebServerConfiguration Ptr, _
		ByVal celt As ULONG, _
		ByVal rgelt As IWebServerConfiguration Ptr Ptr, _
		ByVal pceltFetched As ULONG Ptr _
	)As HRESULT
	
	Dim Skip As Function( _
		ByVal this As IEnumWebServerConfiguration Ptr, _
		ByVal celt As ULONG _
	)As HRESULT
	
	Dim Reset As Function( _
		ByVal this As IEnumWebServerConfiguration Ptr _
	)As HRESULT
	
	Dim Clone As Function( _
		ByVal this As IEnumWebServerConfiguration Ptr, _
		ByVal ppenum As IEnumWebServerConfiguration Ptr Ptr _
	)As HRESULT
	
End Type

Type IEnumWebServerConfiguration_
	Dim lpVtbl As IEnumWebServerConfigurationVirtualTable Ptr
End Type

#define IEnumWebServerConfiguration_QueryInterface(this, riid, ppv) (this)->lpVtbl->QueryInterface(this, riid, ppv)
#define IEnumWebServerConfiguration_AddRef(this) (this)->lpVtbl->AddRef(this)
#define IEnumWebServerConfiguration_Release(this) (this)->lpVtbl->Release(this)
#define IEnumWebServerConfiguration_Next(this, celt, rgelt, pceltFetched) (this)->lpVtbl->Next(this, celt, rgelt, pceltFetched)
#define IEnumWebServerConfiguration_Skip(this, celt) (this)->lpVtbl->Skip(this, celt)
#define IEnumWebServerConfiguration_Reset(this) (this)->lpVtbl->Reset(this)
#define IEnumWebServerConfiguration_Clone(this, ppenum) (this)->lpVtbl->Clone(this, ppenum)

#endif
