#ifndef ICLIENTREQUEST_BI
#define ICLIENTREQUEST_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\objbase.bi"

Type IClientRequest As IClientRequest_

Type IClientRequestVirtualTable
	Dim VirtualTable As IUnknownVtbl
End Type

Type IClientRequest_
	Dim pVirtualTable As IClientRequestVirtualTable Ptr
End Type

#endif
