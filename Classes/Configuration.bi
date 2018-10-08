#ifndef CONFIGURATION_BI
#define CONFIGURATION_BI

#include "IConfiguration.bi"

Type Configuration
	Dim pVirtualTable As IConfigurationVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim IniFileName As WString * (MAX_PATH + 1)
End Type

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

Declare Sub InitializeConfiguration( _
	ByVal pConfiguration As Configuration Ptr, _
	ByVal pFileName As WString Ptr _
)

#endif
