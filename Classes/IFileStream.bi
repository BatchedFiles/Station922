#ifndef IFILESTREAM_BI
#define IFILESTREAM_BI

#include "IBaseStream.bi"

Type IFileStream As IFileStream_

Type IFileStreamVirtualTable
	Dim VirtualTable As IBaseStreamVirtualTable
	
End Type

Type IFileStream_
	Dim pVirtualTable As IFileStreamVirtualTable Ptr
End Type

#endif
