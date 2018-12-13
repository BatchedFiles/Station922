#ifndef INETWORKSTREAM_BI
#define INETWORKSTREAM_BI

#include "IBaseStream.bi"
#include "win\winsock2.bi"

' {A4C7EAED-5EC0-4B7C-81D2-05BE69E63A1F}
Dim Shared IID_INETWORKSTREAM As IID = Type(&ha4c7eaed, &h5ec0, &h4b7c, _
	{&h81, &hd2, &h5, &hbe, &h69, &he6, &h3a, &h1f})

Type LPINETWORKSTREAM As INetworkStream Ptr

Type INetworkStream As INetworkStream_

Type INetworkStreamVirtualTable
	Dim InheritedTable As IBaseStreamVirtualTable
	
	Dim GetSocket As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal pResult As SOCKET Ptr _
	)As HRESULT
	
	Dim SetSocket As Function( _
		ByVal this As INetworkStream Ptr, _
		ByVal sock As SOCKET _
	)As HRESULT
	
End Type

Type INetworkStream_
	Dim pVirtualTable As INetworkStreamVirtualTable Ptr
End Type

#endif
