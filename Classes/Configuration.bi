#ifndef CONFIGURATION_BI
#define CONFIGURATION_BI

#include "IConfiguration.bi"

Extern CLSID_CONFIGURATION Alias "CLSID_CONFIGURATION" As Const CLSID

Type Configuration As _Configuration

Type LPConfiguration As _Configuration Ptr

Declare Function CreateConfiguration( _
)As Configuration Ptr

Declare Sub DestroyConfiguration( _
	ByVal this As Configuration Ptr _
)

Declare Function ConfigurationQueryInterface( _
	ByVal this As Configuration Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function ConfigurationAddRef( _
	ByVal this As Configuration Ptr _
)As ULONG

Declare Function ConfigurationRelease( _
	ByVal this As Configuration Ptr _
)As ULONG

Declare Function ConfigurationSetIniFilename( _
	ByVal this As Configuration Ptr, _
	ByVal pFileName As WString Ptr _
)As HRESULT

Declare Function ConfigurationGetStringValue( _
	ByVal this As Configuration Ptr, _
	ByVal Section As WString Ptr, _
	ByVal Key As WString Ptr, _
	ByVal DefaultValue As WString Ptr, _
	ByVal BufferLength As Integer, _
	ByVal pValue As WString Ptr, _
	ByVal pValueLength As Integer Ptr _
)As HRESULT

Declare Function ConfigurationGetIntegerValue( _
	ByVal this As Configuration Ptr, _
	ByVal Section As WString Ptr, _
	ByVal Key As WString Ptr, _
	ByVal DefaultValue As Integer, _
	ByVal pValue As Integer Ptr _
)As HRESULT

Declare Function ConfigurationGetAllSections( _
	ByVal this As Configuration Ptr, _
	ByVal BufferLength As Integer, _
	ByVal pSections As WString Ptr, _
	ByVal pSectionsLength As Integer Ptr _
)As HRESULT

Declare Function ConfigurationGetAllKeys( _
	ByVal this As Configuration Ptr, _
	ByVal Section As WString Ptr, _
	ByVal BufferLength As Integer, _
	ByVal pKeys As WString Ptr, _
	ByVal pKeysLength As Integer Ptr _
)As HRESULT

Declare Function ConfigurationSetStringValue( _
	ByVal this As Configuration Ptr, _
	ByVal Section As WString Ptr, _
	ByVal Key As WString Ptr, _
	ByVal pValue As WString Ptr _
)As HRESULT

#endif
