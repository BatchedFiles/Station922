#include "Configuration.bi"

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

Sub UnInitializeConfiguration( _
		ByVal pConfig As Configuration Ptr _
	)
	
End Sub

Function CreateConfiguration( _
	)As Configuration Ptr
	
	Dim pConfig As Configuration Ptr = HeapAlloc( _
		GetProcessHeap(), _
		0, _
		SizeOf(Configuration) _
	)
	
	If pConfig = NULL Then
		Return NULL
	End If
	
	InitializeConfiguration(pConfig)
	
	Return pConfig
	
End Function

Sub DestroyConfiguration( _
		ByVal this As Configuration Ptr _
	)
	
	UnInitializeConfiguration(this)
	
	HeapFree(GetProcessHeap(), 0, this)
	
End Sub

Function ConfigurationQueryInterface( _
		ByVal pConfiguration As Configuration Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IConfiguration, riid) Then
		*ppv = @pConfiguration->pVirtualTable
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
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
		
		DestroyConfiguration(pConfiguration)
		
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
