#ifndef IWEBSITE_BI
#define IWEBSITE_BI

#include "IRequestedFile.bi"

' {DE416BE2-F7C8-40C6-81DF-44742D47F0F7}
Dim Shared IID_IWEBSITE As IID = Type(&hde416be2, &hf7c8, &h40c6, _
	{&h81, &hdf, &h44, &h74, &h2d, &h47, &hf0, &hf7})

Type LPIWEBSITE As IWebSite Ptr

Type IWebSite As IWebSite_

Type IWebSiteVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim GetHostName As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pHost As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetPhysicalDirectory As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pPhysicalDirectory As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetVirtualPath As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pVirtualPath As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetIsMoved As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIsMoved As Boolean Ptr _
	)As HRESULT
	
	Dim GetMovedUrl As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pMovedUrl As WString Ptr Ptr _
	)As HRESULT
	
	Dim MapPath As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal path As WString Ptr, _
		ByVal pResult As WString Ptr Ptr _
	)As HRESULT
	
	Dim GetRequestedFile As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal FilePath As WString Ptr, _
		ByVal pRequestedFile As IRequestedFile Ptr Ptr _
	)As HRESULT
	
	Dim NeedCGIProcessing As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal path As WString Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	Dim NeedDLLProcessing As Function( _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal path As WString Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
End Type

Type IWebSite_
	Dim pVirtualTable As IWebSiteVirtualTable Ptr
End Type

#endif
