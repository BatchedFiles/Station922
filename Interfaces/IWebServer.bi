#ifndef IWEBSERVER_BI
#define IWEBSERVER_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\objbase.bi"

' {6603A8F5-FB80-4CB9-BF80-CEADE4576F52}
Dim Shared IID_IWEBSERVER As IID = Type(&h6603a8f5, &hfb80, &h4cb9, _
	{&hbf, &h80, &hce, &had, &he4, &h57, &h6f, &h52})

Type LPIWEBSERVER As IWebServer Ptr

Type IWebServer As IWebServer_

Type IWebServerVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim RunServer As Function( _
		ByVal this As IWebServer Ptr _
	)As HRESULT
	
End Type

Type IWebServer_
	Dim pVirtualTable As IWebServerVirtualTable Ptr
End Type


#endif
