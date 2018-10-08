#ifndef FILESTREAM_BI
#define FILESTREAM_BI

#include "IFileStream.bi"

Type FileStream
	Dim pVirtualTable As IFileStreamVirtualTable Ptr
	Dim ReferenceCounter As ULONG
	Dim hFile As HANDLE
End Type

Declare Function FileStreamCanRead( _
	ByVal this As FileStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function FileStreamCanSeek( _
	ByVal this As FileStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function FileStreamCanWrite( _
	ByVal this As FileStream Ptr, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

Declare Function FileStreamCloseStream( _
	ByVal this As FileStream Ptr _
)As HRESULT

Declare Function FileStreamFlush( _
	ByVal this As FileStream Ptr _
)As HRESULT

Declare Function FileStreamGetLength( _
	ByVal this As FileStream Ptr, _
	ByVal pResult As LongInt Ptr _
)As HRESULT

Declare Function FileStreamOpenStream( _
	ByVal this As FileStream Ptr _
)As HRESULT

Declare Function FileStreamPosition( _
	ByVal this As FileStream Ptr, _
	ByVal pResult As LongInt Ptr _
)As HRESULT

Declare Function FileStreamRead( _
	ByVal this As FileStream Ptr, _
	ByVal buffer As UByte Ptr, _
	ByVal offset As Integer, _
	ByVal Count As Integer, _
	ByVal pReadedBytes As LongInt Ptr _
)As HRESULT

Declare Function FileStreamSeek( _
	ByVal this As FileStream Ptr, _
	ByVal offset As LongInt, _
	ByVal origin As SeekOrigin _
)As HRESULT

Declare Function FileStreamSetLength( _
	ByVal this As FileStream Ptr, _
	ByVal length As LongInt _
)As HRESULT

Declare Function FileStreamWrite( _
	ByVal this As FileStream Ptr, _
	ByVal buffer As UByte Ptr, _
	ByVal offset As Integer, _
	ByVal Count As Integer, _
	ByVal pWritedBytes As Integer Ptr _
)As HRESULT

Declare Sub InitializeFileStream Overload( _
	ByVal pFileStream As FileStream Ptr, _
	ByVal hFile As HANDLE _
)

Declare Sub InitializeFileStream Overload( _
	ByVal pFileStream As FileStream Ptr, _
	ByVal pFileName As WString Ptr _
)

#endif
