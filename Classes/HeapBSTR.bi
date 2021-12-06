#ifndef BATCHEDFILES_HEAPBSTR_BI
#define BATCHEDFILES_HEAPBSTR_BI

#include once "IString.bi"

Extern CLSID_HEAPBSTR Alias "CLSID_HEAPBSTR" As Const CLSID

#MACRO LET_HEAPSYSSTRING(lhs, rhs)
	HeapSysFreeString(lhs)
	HeapSysAddRefString(rhs)
	lhs = rhs
#ENDMACRO

Declare Function HeapSysAllocString( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal psz As Const WString Ptr _
)As HeapBSTR

Declare Function HeapSysAllocStringLen( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal psz As Const WString Ptr, _
	ByVal ui As UINT _
)As HeapBSTR

Declare Function HeapSysConcatString( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal lhs As HeapBSTR, _
	ByVal rhs As HeapBSTR _
)As HeapBSTR

Declare Function HeapSysAddRefString( _
	ByVal bstrString As HeapBSTR _
)As HRESULT

Declare Sub HeapSysFreeString( _
	ByVal bstrString As HeapBSTR _ 
)

Type InternalHeapBSTR As _InternalHeapBSTR

Type LPInternalHeapBSTR As _InternalHeapBSTR Ptr

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

Declare Function InternalHeapBSTRGetHeapBSTR( _
	ByVal this As InternalHeapBSTR Ptr, _
	ByVal pcHeapBSTR As HeapBSTR Const Ptr _
)As HRESULT

Declare Function GetIStringFromHeapBSTR( _
	ByVal bs As HeapBSTR _
)As IString Ptr

#endif
