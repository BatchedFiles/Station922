#ifndef ISTRINGABLE_BI
#define ISTRINGABLE_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"
#include once "win\objbase.bi"

' {286FF92C-2951-47BB-A4BB-09DA00A72725}
Dim Shared IID_ISTRINGABLE As IID = Type(&h286ff92c, &h2951, &h47bb, _
	{&ha4, &hbb, &h9, &hda, &h0, &ha7, &h27, &h25})

Type LPISTRINGABLE As IStringable Ptr

Type IStringable As IStringable_

Type IStringableVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim ToString As Function( _
		ByVal this As IStringable Ptr, _
		ByVal pResult As WString Ptr Ptr _
	)As HRESULT
	
End Type

Type IStringable_
	Dim pVirtualTable As IStringableVirtualTable Ptr
End Type

#endif
