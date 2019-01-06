#ifndef IFILESTREAM_BI
#define IFILESTREAM_BI

#include "IBaseStream.bi"

' {C409DE11-C44F-4EF8-8A4C-4CE38C61C8E3}
Dim Shared IID_IFILESTREAM As IID = Type(&hc409de11, &hc44f, &h4ef8, _
	{&h8a, &h4c, &h4c, &he3, &h8c, &h61, &hc8, &he3})

Type LPIFILESTREAM As IFileStream Ptr

Type IFileStream As IFileStream_

Type IFileStreamVirtualTable
	Dim InheritedTable As IBaseStreamVirtualTable
	
	Dim GetFileHandle As Function( _
		ByVal pIFileStream As IFileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	Dim SetFileHandle As Function( _
		ByVal pIFileStream As IFileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
End Type

Type IFileStream_
	Dim pVirtualTable As IFileStreamVirtualTable Ptr
End Type

#endif
