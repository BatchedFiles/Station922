#ifndef ARRAYSTRINGWRITER_BI
#define ARRAYSTRINGWRITER_BI

Type ArrayStringWriter

	CodePage As Integer
	Capacity As Integer
	BufferLength As Integer
	Buffer As WString Ptr

	Declare Function WriteLengthString( _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As Boolean

	Declare Function WriteNewLine( _
	)As Boolean

	Declare Function WriteString( _
		ByVal w As WString Ptr _
	)As Boolean

	Declare Function WriteLengthStringLine( _
		ByVal w As WString Ptr, _
		ByVal Length As Integer _
	)As Boolean

	Declare Function WriteStringLine( _
		ByVal w As WString Ptr _
	)As Boolean

	Declare Function WriteChar( _
		ByVal wc As Integer _
	)As Boolean

	Declare Function WriteInt32( _
		ByVal Value As Long _
	)As Boolean

	Declare Function WriteUInt32( _
		ByVal Value As ULong _
	)As Boolean

	Declare Function WriteInt64( _
		ByVal Value As LongInt _
	)As Boolean

	Declare Function WriteUInt64( _
		ByVal Value As ULongInt _
	)As Boolean

	Declare Function GetCodePage( _
	)As Integer

	Declare Sub SetCodePage( _
		ByVal CodePage As Integer _
	)

	Declare Sub SetBuffer( _
		ByVal Buffer As WString Ptr, _
		ByVal Capacity As Integer _
	)

	Declare Function GetLength( _
	)As Integer

End Type

Declare Sub InitializeArrayStringWriter( _
	ByVal self As ArrayStringWriter Ptr _
)

#endif
