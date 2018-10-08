#ifndef ISTREAMWRITER_BI
#define ISTREAMWRITER_BI

#include "ITextWriter.bi"

Type IStreamWriter As IStreamWriter_

Type LPISTREAMWRITER As IStreamWriter Ptr

Type IStreamWriterVirtualTable
	Dim VirtualTable As ITextWriterVirtualTable
End Type

Type IStreamWriter_
	Dim pVirtualTable As IStreamWriterVirtualTable Ptr
End Type

#endif
