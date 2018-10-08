#ifndef IARRAYSTRINGWRITER_BI
#define IARRAYSTRINGWRITER_BI

#include "ITextWriter.bi"

Type IArrayStringWriter As IArrayStringWriter_

Type IArrayStringWriterVirtualTable
	Dim VirtualTable As ITextWriterVirtualTable
End Type

Type IArrayStringWriter_
	Dim pVirtualTable As IArrayStringWriterVirtualTable Ptr
End Type

#endif
