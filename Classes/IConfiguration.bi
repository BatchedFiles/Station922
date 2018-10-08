#ifndef ICONFIGURATION_BI
#define ICONFIGURATION_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\objbase.bi"


' {76A3EA34-6604-4126-9550-54280EAA291A}
Dim Shared IID_IConfiguration As IID = Type(&h76a3ea34, &h6604, &h4126, _
	{&h95, &h50, &h54, &h28, &he, &haa, &h29, &h1a})

Type LPICONFIGURATION As IConfiguration Ptr

Type IConfiguration As IConfiguration_

Type IConfigurationVirtualTable
	Dim VirtualTable As IUnknownVtbl
	
	Dim GetStringValue As Function( _
		ByVal this As IConfiguration Ptr, _
		ByVal Section As WString Ptr, _
		ByVal Key As WString Ptr, _
		ByVal DefaultValue As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pValue As WString Ptr, _
		ByVal pValueLength As Integer Ptr _
	)As HRESULT
	
	Dim GetIntegerValue As Function( _
		ByVal this As IConfiguration Ptr, _
		ByVal Section As WString Ptr, _
		ByVal Key As WString Ptr, _
		ByVal DefaultValue As Integer, _
		ByVal pValue As Integer Ptr _
	)As HRESULT
	
	Dim GetAllSections As Function( _
		ByVal this As IConfiguration Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pSections As WString Ptr, _
		ByVal pSectionsLength As Integer Ptr _
	)As HRESULT
	
	Dim GetAllKeys As Function( _
		ByVal this As IConfiguration Ptr, _
		ByVal Section As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pKeys As WString Ptr, _
		ByVal pKeysLength As Integer Ptr _
	)As HRESULT
	
	Dim SetStringValue As Function( _
		ByVal this As IConfiguration Ptr, _
		ByVal Section As WString Ptr, _
		ByVal Key As WString Ptr, _
		ByVal pValue As WString Ptr _
	)As HRESULT
	
End Type

Type IConfiguration_
	Dim pVirtualTable As IConfigurationVirtualTable Ptr
End Type

#endif
