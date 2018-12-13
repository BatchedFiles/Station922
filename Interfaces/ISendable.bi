#ifndef ISENDABLE_BI
#define ISENDABLE_BI

#include "INetworkStream.bi"

' {E6C1A359-67A1-4B3D-A329-69001B3B8065}
Dim Shared IID_ISENDABLE As IID = Type(&he6c1a359, &h67a1, &h4b3d, _
	{&ha3, &h29, &h69, &h0, &h1b, &h3b, &h80, &h65})

Type LPISENDABLE As ISendable Ptr

Type ISendable As ISendable_

Type ISendableVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim Send As Function( _
		ByVal this As ISendable Ptr, _
		ByVal pIStream As INetworkStream Ptr _
	)As HRESULT
	
End Type

Type ISendable_
	Dim pVirtualTable As ISendableVirtualTable Ptr
End Type

#endif
