#ifndef HTTPREADER_BI
#define HTTPREADER_BI

#include once "IHttpReader.bi"
#include once "ILogger.bi"

Extern CLSID_HTTPREADER Alias "CLSID_HTTPREADER" As Const CLSID

Type HttpReader As _HttpReader

Type LPHttpReader As _HttpReader Ptr

Declare Function CreateHttpReader( _
	ByVal pILogger As ILogger Ptr, _
	ByVal pIMemoryAllocator As IMalloc Ptr _
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

Declare Function HttpReaderBeginReadLine( _
	ByVal this As HttpReader Ptr, _
	ByVal callback As AsyncCallback, _
	ByVal StateObject As IUnknown Ptr, _
	ByVal ppIAsyncResult As IAsyncResult Ptr Ptr _
)As HRESULT

Declare Function HttpReaderEndReadLine( _
	ByVal this As HttpReader Ptr, _
	ByVal pIAsyncResult As IAsyncResult Ptr, _
	ByVal pLineLength As Integer Ptr, _
	ByVal ppLine As WString Ptr Ptr _
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

Declare Function HttpReaderIsCompleted( _
	ByVal this As HttpReader Ptr, _
	ByVal pCompleted As Boolean Ptr _
)As HRESULT

#endif
