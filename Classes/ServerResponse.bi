#ifndef SERVERRESPONSE_BI
#define SERVERRESPONSE_BI

#include "IServerResponse.bi"
#include "IStringable.bi"

Type ServerResponse
	Dim pServerResponseVirtualTable As IServerResponseVirtualTable Ptr
	Dim pStringableVirtualTable As IStringable Ptr
	Dim ReferenceCounter As ULONG
	
	Declare Constructor()
End Type

#endif
