#ifndef IWEBSITESCOLLECTION_BI
#define IWEBSITESCOLLECTION_BI

#include "IWebSite.bi"

' {9042F178-B211-478B-8FF6-9C4133984364}
Dim Shared IID_IWEBSITESCOLLECTION As IID = Type(&h9042f178, &hb211, &h478b, _
	{&h8f, &hf6, &h9c, &h41, &h33, &h98, &h43, &h64})

Type LPIWEBSITESCOLECTION As IWebSitesCollection Ptr

Type IWebSitesCollection As IWebSitesCollection_

Type IWebSitesCollectionVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim FindWebSite As Function( _
		ByVal this As IWebSitesCollection Ptr, _
		ByVal Host As WString Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	Dim LoadWebSites As Function( _
		ByVal this As IWebSitesCollection Ptr, _
		ByVal ExecutableDirectory As WString Ptr _
	)As HRESULT
	
End Type

Type IWebSitesCollection_
	Dim pVirtualTable As IWebSitesCollectionVirtualTable Ptr
End Type

#endif
