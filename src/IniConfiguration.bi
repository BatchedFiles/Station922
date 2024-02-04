#ifndef INICONFIGURATION_BI
#define INICONFIGURATION_BI

#include once "IIniConfiguration.bi"

Extern CLSID_INICONFIGURATION Alias "CLSID_INICONFIGURATION" As Const CLSID

Const RTTI_ID_INICONFIGURATION        = !"\001INI_____Config\001"

Declare Function CreateWebServerIniConfiguration( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

#endif
