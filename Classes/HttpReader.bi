#ifndef HTTPREADER_BI
#define HTTPREADER_BI

#include "IHttpReader.bi"

Const HTTPREADER_MAXBUFFER_LENGTH As Integer = 16 * 1024 - 1

Extern CLSID_HTTPREADER Alias "CLSID_HTTPREADER" As Const CLSID

Type HttpReader As _HttpReader

Type LPHttpReader As _HttpReader Ptr

Declare Sub InitializeHttpReaderVirtualTable()

Declare Function CreateHttpReader( _
	ByVal hHeap As HANDLE _
)As HttpReader Ptr

Declare Sub DestroyHttpReader( _
	ByVal this As HttpReader Ptr _
)

Declare Function HttpReaderQueryInterface( _
	ByVal this As HttpReader Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function HttpReaderAddRef( _
	ByVal this As HttpReader Ptr _
)As ULONG

Declare Function HttpReaderRelease( _
	ByVal this As HttpReader Ptr _
)As ULONG

Declare Function HttpReaderReadLine( _
	ByVal this As HttpReader Ptr, _
	ByVal pLineLength As Integer Ptr, _
	ByVal pLine As WString Ptr Ptr _
)As HRESULT

Declare Function HttpReaderClear( _
	ByVal this As HttpReader Ptr _
)As HRESULT

Declare Function HttpReaderGetBaseStream( _
	ByVal this As HttpReader Ptr, _
	ByVal ppResult As IBaseStream Ptr Ptr _
)As HRESULT

Declare Function HttpReaderSetBaseStream( _
	ByVal this As HttpReader Ptr, _
	ByVal pIStream As IBaseStream Ptr _
)As HRESULT

Declare Function HttpReaderGetPreloadedBytes( _
	ByVal this As HttpReader Ptr, _
	ByVal pPreloadedBytesLength As Integer Ptr, _
	ByVal ppPreloadedBytes As UByte Ptr Ptr _
)As HRESULT

Declare Function HttpReaderGetRequestedBytes( _
	ByVal this As HttpReader Ptr, _
	ByVal pRequestedBytesLength As Integer Ptr, _
	ByVal ppRequestedBytes As UByte Ptr Ptr _
)As HRESULT

#endif
