#ifndef ARRAYSTRINGWRITER_BI
#define ARRAYSTRINGWRITER_BI

#include once "IArrayStringWriter.bi"

Extern CLSID_ARRAYSTRINGWRITER Alias "CLSID_ARRAYSTRINGWRITER" As Const CLSID

Type ArrayStringWriter As _ArrayStringWriter

Type LPArrayStringWriter As _ArrayStringWriter Ptr

Declare Function CreateArrayStringWriter( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As ArrayStringWriter Ptr

Declare Sub DestroyArrayStringWriter( _
	ByVal this As ArrayStringWriter Ptr _
)

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

Declare Function ArrayStringWriterWriteUInt32( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal Value As ULong _
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

Declare Function ArrayStringWriterSetBuffer( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal Buffer As WString Ptr, _
	ByVal MaxBufferLength As Integer _
)As HRESULT

Declare Function ArrayStringWriterGetBufferLength( _
	ByVal this As ArrayStringWriter Ptr, _
	ByVal pLength As Integer Ptr _
)As HRESULT

#endif
