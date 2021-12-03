#ifndef CLIENTURI_BI
#define CLIENTURI_BI

#include once "IClientUri.bi"

Extern CLSID_CLIENTURI Alias "CLSID_CLIENTURI" As Const CLSID

Type ClientUri As _ClientUri

Type LPClientUri As _ClientUri Ptr

Declare Function CreateClientUri( _
	ByVal pIMemoryAllocator As IMalloc Ptr _
)As ClientUri Ptr

Declare Sub DestroyClientUri( _
	ByVal this As ClientUri Ptr _
)

Declare Function ClientUriQueryInterface( _
	ByVal this As ClientUri Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

Declare Function ClientUriAddRef( _
	ByVal this As ClientUri Ptr _
)As ULONG

Declare Function ClientUriRelease( _
	ByVal this As ClientUri Ptr _
)As ULONG

Declare Function ClientUriUriFromString( _
	ByVal this As ClientUri Ptr, _
	ByVal bstrUri As BSTR _
)As HRESULT

Declare Function ClientUriGetOriginalString( _
	ByVal this As ClientUri Ptr, _
	ByVal ppOriginalString As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientUriGetUserName( _
	ByVal this As ClientUri Ptr, _
	ByVal ppUserName As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientUriGetPassword( _
	ByVal this As ClientUri Ptr, _
	ByVal ppPassword As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientUriGetHost( _
	ByVal this As ClientUri Ptr, _
	ByVal ppHost As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientUriGetPort( _
	ByVal this As ClientUri Ptr, _
	ByVal ppPort As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientUriGetScheme( _
	ByVal this As ClientUri Ptr, _
	ByVal ppScheme As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientUriGetPath( _
	ByVal this As ClientUri Ptr, _
	ByVal ppPath As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientUriGetQuery( _
	ByVal this As ClientUri Ptr, _
	ByVal ppQuery As HeapBSTR Ptr _
)As HRESULT

Declare Function ClientUriGetFragment( _
	ByVal this As ClientUri Ptr, _
	ByVal ppFragment As HeapBSTR Ptr _
)As HRESULT

#endif
