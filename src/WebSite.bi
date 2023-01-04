#ifndef WEBSITE_BI
#define WEBSITE_BI

#include once "IWebSite.bi"

Extern CLSID_WEBSITE Alias "CLSID_WEBSITE" As Const CLSID

Const RTTI_ID_WEBSITE                 = !"\001Web_______Site\001"

Type WebSite As _WebSite

Type LPWebSite As _WebSite Ptr

Declare Function CreateWebSite( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyWebSite( _
	ByVal this As WebSite Ptr _
)

Declare Function WebSiteQueryInterface( _
	ByVal this As WebSite Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function WebSiteAddRef( _
	ByVal this As WebSite Ptr _
)As ULONG

Declare Function WebSiteRelease( _
	ByVal this As WebSite Ptr _
)As ULONG

Declare Function WebSiteGetHostName( _
	ByVal this As WebSite Ptr, _
	ByVal ppHost As HeapBSTR Ptr _
)As HRESULT

Declare Function WebSiteGetSitePhysicalDirectory( _
	ByVal this As WebSite Ptr, _
	ByVal ppPhysicalDirectory As HeapBSTR Ptr _
)As HRESULT

Declare Function WebSiteGetVirtualPath( _
	ByVal this As WebSite Ptr, _
	ByVal ppVirtualPath As HeapBSTR Ptr _
)As HRESULT

Declare Function WebSiteGetIsMoved( _
	ByVal this As WebSite Ptr, _
	ByVal pIsMoved As Boolean Ptr _
)As HRESULT

Declare Function WebSiteGetMovedUrl( _
	ByVal this As WebSite Ptr, _
	ByVal ppMovedUrl As HeapBSTR Ptr _
)As HRESULT

Declare Function WebSiteGetBuffer( _
	ByVal this As WebSite Ptr, _
	ByVal pIMalloc As IMalloc Ptr, _
	ByVal fAccess As FileAccess, _
	ByVal pRequest As IClientRequest Ptr, _
	ByVal BufferLength As LongInt, _
	ByVal pFlags As ContentNegotiationFlags Ptr, _
	ByVal ppResult As IAttributedStream Ptr Ptr _
)As HRESULT

Declare Function WebSiteGetErrorBuffer( _
	ByVal this As WebSite Ptr, _
	ByVal pIMalloc As IMalloc Ptr, _
	ByVal HttpError As ResponseErrorCode, _
	ByVal hrErrorCode As HRESULT, _
	ByVal StatusCode As HttpStatusCodes, _
	ByVal ppResult As IAttributedStream Ptr Ptr _
)As HRESULT

Declare Function WebSiteSetHostName( _
	ByVal this As WebSite Ptr, _
	ByVal pHost As HeapBSTR _
)As HRESULT

Declare Function WebSiteSetSitePhysicalDirectory( _
	ByVal this As WebSite Ptr, _
	ByVal pPhysicalDirectory As HeapBSTR _
)As HRESULT

Declare Function WebSiteSetVirtualPath( _
	ByVal this As WebSite Ptr, _
	ByVal pVirtualPath As HeapBSTR _
)As HRESULT

Declare Function WebSiteSetIsMoved( _
	ByVal this As WebSite Ptr, _
	ByVal IsMoved As Boolean _
)As HRESULT

Declare Function WebSiteSetMovedUrl( _
	ByVal this As WebSite Ptr, _
	ByVal pMovedUrl As HeapBSTR _
)As HRESULT

Declare Function WebSiteSetTextFileEncoding( _
	ByVal this As WebSite Ptr, _
	ByVal CodePage As TextFileCharsets _
)As HRESULT

Declare Function WebSiteNeedCgiProcessing( _
	ByVal this As WebSite Ptr, _
	ByVal Path As HeapBSTR, _
	ByVal pResult As Boolean Ptr _
)As HRESULT

#endif
