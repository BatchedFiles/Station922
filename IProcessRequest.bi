#ifndef IPROCESSREQUEST_BI
#define IPROCESSREQUEST_BI

#include "ReadHeadersResult.bi"
#include "WebSite.bi"
#include "StreamSocketReader.bi"

Type IProcessRequest As IProcessRequest_

Type IProcessRequestVirtualTable
	Dim Process As Function( _
		ByVal This As IProcessRequest Ptr, _
		ByVal pState As ReadHeadersResult Ptr, _
		ByVal ClientSocket As SOCKET, _
		ByVal pWebSite As WebSite Ptr, _
		ByVal fileExtention As WString Ptr, _
		ByVal pClientReader As StreamSocketReader Ptr, _
		ByVal hRequestedFile As Handle _
	)As Boolean
End Type

Type IProcessRequest_
	Dim lpVtbl As IProcessRequestVirtualTable Ptr
End Type

#endif
