#ifndef STREAMWRITER_BI
#define STREAMWRITER_BI

#include "IStreamWriter.bi"
#include "IBaseStream.bi"

Type StreamWriter
	Dim pVirtualTable As ITextWriterVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim CodePage As Integer
End Type

Declare Sub InitializeStreamWriter( _
	ByVal pStreamWriter As StreamWriter Ptr, _
	ByVal CodePage As Integer, _
	ByVal pStream As IBaseStream Ptr _
)

#endif
