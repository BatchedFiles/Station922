#ifndef BATCHEDFILES_HEAPBSTR_BI
#define BATCHEDFILES_HEAPBSTR_BI

#include once "IString.bi"

Extern CLSID_HEAPBSTR Alias "CLSID_HEAPBSTR" As Const CLSID

Type _HeapBSTR As OLECHAR Ptr

Type HeapBSTR As _HeapBSTR

Type LPHEAPBSTR As _HeapBSTR Ptr

Type InternalHeapBSTR As _InternalHeapBSTR

Type LPInternalHeapBSTR As _InternalHeapBSTR Ptr

Declare Function HeapSysAllocString( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	byval psz As Const WString Ptr _
)As HeapBSTR

Declare Function HeapSysAllocStringLen( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	byval psz As Const WString Ptr, _
	ByVal ui As UINT _
)As HeapBSTR

Declare Sub HeapSysFreeString( _
	byval bstrString As HeapBSTR _ 
)

Declare Function CreateInternalHeapBSTR( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
)As InternalHeapBSTR Ptr

Declare Sub DestroyInternalHeapBSTR( _
	ByVal this As InternalHeapBSTR Ptr _
)

Declare Function InternalHeapBSTRQueryInterface( _
	ByVal this As InternalHeapBSTR Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function InternalHeapBSTRAddRef( _
	ByVal this As InternalHeapBSTR Ptr _
)As ULONG

Declare Function InternalHeapBSTRRelease( _
	ByVal this As InternalHeapBSTR Ptr _
)As ULONG

#endif
