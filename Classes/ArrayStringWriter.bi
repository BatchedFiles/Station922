#ifndef ARRAYSTRINGWRITER_BI
#define ARRAYSTRINGWRITER_BI

#include "IArrayStringWriter.bi"

Type _ArrayStringWriter
	
	Dim pVirtualTable As IArrayStringWriterVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim ExistsInStack As Boolean
	
	Dim CodePage As Integer
	Dim MaxBufferLength As Integer
	Dim BufferLength As Integer
	Dim Buffer As WString Ptr
	
End Type

Type ArrayStringWriter As _ArrayStringWriter

Type LPArrayStringWriter As _ArrayStringWriter Ptr

Declare Sub InitializeArrayStringWriterVirtualTable()

Declare Function InitializeArrayStringWriterOfIArrayStringWriter( _
	ByVal this As ArrayStringWriter Ptr _
)As IArrayStringWriter Ptr

Declare Function ArrayStringWriterQueryInterface( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function ArrayStringWriterAddRef( _
	ByVal this As ArrayStringWriter Ptr _
)As ULONG

Declare Function ArrayStringWriterRelease( _
	ByVal this As ArrayStringWriter Ptr _
)As ULONG

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
	ByVal wc As wchar_t _
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

Declare Function ArrayStringWriterSetBuffer( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal Buffer As WString Ptr, _
	ByVal MaxBufferLength As Integer _
)As HRESULT

#define ArrayStringWriter_NonVirtualQueryInterface(pIArrayStringWriter, riid, ppv) ArrayStringWriterQueryInterface(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), riid, ppv)
#define ArrayStringWriter_NonVirtualAddRef(pIArrayStringWriter) ArrayStringWriterAddRef(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter))
#define ArrayStringWriter_NonVirtualRelease(pIArrayStringWriter) ArrayStringWriterRelease(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter))
#define ArrayStringWriter_NonVirtualCloseTextWriter(pIArrayStringWriter) ArrayStringWriterCloseTextWriter(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter))
#define ArrayStringWriter_NonVirtualOpenTextWriter(pIArrayStringWriter) ArrayStringWriterOpenTextWriter(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter))
#define ArrayStringWriter_NonVirtualFlush(pIArrayStringWriter) ArrayStringWriterFlush(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter))
#define ArrayStringWriter_NonVirtualGetCodePage(pIArrayStringWriter, pCodePage) ArrayStringWriterGetCodePage(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), pCodePage)
#define ArrayStringWriter_NonVirtualSetCodePage(pIArrayStringWriter, CodePage) ArrayStringWriterGetCodePage(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), CodePage)
#define ArrayStringWriter_NonVirtualWriteNewLine(pIArrayStringWriter) ArrayStringWriterWriteNewLine(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter))
#define ArrayStringWriter_NonVirtualWriteStringLine(pIArrayStringWriter, w) ArrayStringWriterWriteStringLine(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), w)
#define ArrayStringWriter_NonVirtualWriteLengthStringLine(pIArrayStringWriter, w, Length) ArrayStringWriterWriteLengthStringLine(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), w, Length)
#define ArrayStringWriter_NonVirtualWriteString(pIArrayStringWriter, w) ArrayStringWriterWriteString(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), w)
#define ArrayStringWriter_NonVirtualWriteLengthString(pIArrayStringWriter, w, Length) ArrayStringWriterWriteLengthString(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), w, Length)
#define ArrayStringWriter_NonVirtualWriteChar(pIArrayStringWriter, wc) ArrayStringWriterWriteChar(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), wc)
#define ArrayStringWriter_NonVirtualWriteInt32(pIArrayStringWriter, Value) ArrayStringWriterWriteInt32(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), Value)
#define ArrayStringWriter_NonVirtualWriteInt64(pIArrayStringWriter, Value) ArrayStringWriterWriteInt64(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), Value)
#define ArrayStringWriter_NonVirtualWriteUInt64(pIArrayStringWriter, Value) ArrayStringWriterWriteUInt64(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), Value)
#define ArrayStringWriter_NonVirtualSetBuffer(pIArrayStringWriter, Buffer, MaxBufferLength) ArrayStringWriterSetBuffer(CPtr(ArrayStringWriter Ptr, pIArrayStringWriter), Buffer, MaxBufferLength)

#endif
