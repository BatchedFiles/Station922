#ifndef ARRAYSTRINGWRITER_BI
#define ARRAYSTRINGWRITER_BI

#include "IArrayStringWriter.bi"

Type ArrayStringWriter
	Dim pVirtualTable As IArrayStringWriterVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim Buffer As WString Ptr
	Dim BufferLength As Integer
	Dim MaxBufferLength As Integer
	Dim CodePage As Integer
End Type

Declare Sub InitializeArrayStringWriter( _
	ByVal pArrayStringWriter As ArrayStringWriter Ptr, _
	ByVal Buffer As WString Ptr, _
	ByVal MaxBufferLength As Integer _
)

Declare Function ArrayStringWriterWriteLengthString( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal w As WString Ptr, _
	ByVal Length As Integer _
)As HRESULT

Declare Function ArrayStringWriterWriteNewLine( _
	ByVal this As ArrayStringWriter Ptr _
)As HRESULT

Declare Function ArrayStringWriterWriteString( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal w As WString Ptr _
)As HRESULT

Declare Function ArrayStringWriterWriteLengthStringLine( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal w As WString Ptr, _
	ByVal Length As Integer _
)As HRESULT

Declare Function ArrayStringWriterWriteStringLine( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal w As WString Ptr _
)As HRESULT

Declare Function ArrayStringWriterWriteChar( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal wc As Integer _
)As HRESULT

Declare Function ArrayStringWriterWriteInt32( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal Value As Long _
)As HRESULT

Declare Function ArrayStringWriterWriteInt64( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal Value As LongInt _
)As HRESULT

Declare Function ArrayStringWriterWriteUInt64( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal Value As ULongInt _
)As HRESULT

Declare Function ArrayStringWriterGetCodePage( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal CodePage As Integer Ptr _
)As HRESULT

Declare Function ArrayStringWriterSetCodePage( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal CodePage As Integer _
)As HRESULT

Declare Function ArrayStringWriterCloseTextWriter( _
	ByVal this As ArrayStringWriter Ptr _
)As HRESULT

#endif
