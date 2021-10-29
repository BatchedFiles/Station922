#ifndef IFILESTREAM_BI
#define IFILESTREAM_BI

#include once "IBaseStream.bi"

Type IFileStream As IFileStream_

Type LPIFILESTREAM As IFileStream Ptr

Extern IID_IFileStream Alias "IID_IFileStream" As Const IID

Type IFileStreamVirtualTable
	Dim InheritedTable As IBaseStreamVirtualTable
	
	GetFileHandle As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	SetFileHandle As Function( _
		ByVal this As IFileStream Ptr, _
		ByVal hFile As HANDLE _
	)As HRESULT
	
End Type

Type IFileStream_
	lpVtbl As IFileStreamVirtualTable Ptr
End Type

#endif
