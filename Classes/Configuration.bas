#include "Configuration.bi"

Common Shared GlobalConfigurationVirtualTable As IConfigurationVirtualTable

Function ConfigurationGetStringValue( _
		ByVal this As Configuration Ptr, _
		ByVal Section As WString Ptr, _
		ByVal Key As WString Ptr, _
		ByVal DefaultValue As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pValue As WString Ptr, _
		ByVal pValueLength As Integer Ptr _
	)As HRESULT
	
	*pValueLength = GetPrivateProfileString(Section, Key, DefaultValue, pValue, Cast(DWORD, BufferLength), @this->IniFileName)
	
	Return S_OK
End Function

Function ConfigurationGetIntegerValue( _
		ByVal this As Configuration Ptr, _
		ByVal Section As WString Ptr, _
		ByVal Key As WString Ptr, _
		ByVal DefaultValue As Integer, _
		ByVal pValue As Integer Ptr _
	)As HRESULT
	
	*pValue = GetPrivateProfileInt(Section, Key, DefaultValue, @this->IniFileName)
	
	Return S_OK
End Function

Function ConfigurationGetAllSections( _
		ByVal this As Configuration Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pSections As WString Ptr, _
		ByVal pSectionsLength As Integer Ptr _
	)As HRESULT
	
	Dim DefaultValue As WString * 4 = Any
	DefaultValue[0] = 0
	DefaultValue[1] = 0
	DefaultValue[2] = 0
	DefaultValue[3] = 0
	
	*pSectionsLength = GetPrivateProfileString(NULL, NULL, @DefaultValue, pSections, Cast(DWORD, BufferLength), @this->IniFileName)
	
	Return S_OK
End Function

Function ConfigurationGetAllKeys( _
		ByVal this As Configuration Ptr, _
		ByVal Section As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pKeys As WString Ptr, _
		ByVal pKeysLength As Integer Ptr _
	)As HRESULT
	
	Dim DefaultValue As WString * 4 = Any
	DefaultValue[0] = 0
	DefaultValue[1] = 0
	DefaultValue[2] = 0
	DefaultValue[3] = 0
	
	*pKeysLength = GetPrivateProfileString(Section, NULL, @DefaultValue, pKeys, Cast(DWORD, BufferLength), @this->IniFileName)
	
	Return S_OK
End Function

Function ConfigurationSetStringValue( _
		ByVal this As Configuration Ptr, _
		ByVal Section As WString Ptr, _
		ByVal Key As WString Ptr, _
		ByVal pValue As WString Ptr _
	)As HRESULT
	
	Dim Result As Integer = WritePrivateProfileString(Section, Key, pValue, @this->IniFileName)
	
	Return S_OK
End Function

Sub InitializeConfiguration( _
		ByVal pConfiguration As Configuration Ptr, _
		ByVal pFileName As WString Ptr _
	)
	
	pConfiguration->pVirtualTable = @GlobalConfigurationVirtualTable
	pConfiguration->ReferenceCounter = 1
	lstrcpy(@pConfiguration->IniFileName,  pFileName)
End Sub
