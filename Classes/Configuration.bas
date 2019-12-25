#include "Configuration.bi"

Extern IID_IUnknown_WithoutMinGW As Const IID

Dim Shared GlobalConfigurationVirtualTable As IConfigurationVirtualTable = Type( _
	Type<IUnknownVtbl>( _
		@ConfigurationQueryInterface, _
		@ConfigurationAddRef, _
		@ConfigurationRelease _
	), _
	@ConfigurationSetIniFilename, _
	@ConfigurationGetStringValue, _
	@ConfigurationGetIntegerValue, _
	@ConfigurationGetAllSections, _
	@ConfigurationGetAllKeys, _
	@ConfigurationSetStringValue _
)

Sub InitializeConfiguration( _
		ByVal pConfig As Configuration Ptr _
	)
	
	pConfig->pVirtualTable = @GlobalConfigurationVirtualTable
	pConfig->ReferenceCounter = 0
	pConfig->IniFileName[0] = 0
	
End Sub

Function InitializeConfigurationOfIConfiguration( _
		ByVal pConfig As Configuration Ptr _
	)As IConfiguration Ptr
	
	InitializeConfiguration(pConfig)
	pConfig->ExistsInStack = True
	
	Dim pIConfiguration As IConfiguration Ptr = Any
	
	ConfigurationQueryInterface( _
		pConfig, @IID_IConfiguration, @pIConfiguration _
	)
	
	Return pIConfiguration
	
End Function

Function ConfigurationQueryInterface( _
		ByVal pConfiguration As Configuration Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IConfiguration, riid) Then
		*ppv = @pConfiguration->pVirtualTable
	Else
		If IsEqualIID(@IID_IUnknown_WithoutMinGW, riid) Then
			*ppv = @pConfiguration->pVirtualTable
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ConfigurationAddRef(pConfiguration)
	
	Return S_OK
	
End Function

Function ConfigurationAddRef( _
		ByVal pConfiguration As Configuration Ptr _
	)As ULONG
	
	pConfiguration->ReferenceCounter += 1
	
	Return pConfiguration->ReferenceCounter
	
End Function

Function ConfigurationRelease( _
		ByVal pConfiguration As Configuration Ptr _
	)As ULONG
	
	pConfiguration->ReferenceCounter -= 1
	
	If pConfiguration->ReferenceCounter = 0 Then
		
		If pConfiguration->ExistsInStack = False Then
		
		End If
		
		Return 0
	End If
	
	Return pConfiguration->ReferenceCounter
	
End Function

Function ConfigurationSetIniFilename( _
		ByVal pConfiguration As Configuration Ptr, _
		ByVal pFileName As WString Ptr _
	)As HRESULT
	
	lstrcpyn(@pConfiguration->IniFileName, pFileName, MAX_PATH + 1)
	
	Return S_OK
	
End Function

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
