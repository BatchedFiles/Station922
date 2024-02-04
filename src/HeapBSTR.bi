#ifndef BATCHEDFILES_HEAPBSTR_BI
#define BATCHEDFILES_HEAPBSTR_BI

#include once "IString.bi"

Extern CLSID_HEAPBSTR Alias "CLSID_HEAPBSTR" As Const CLSID

Const RTTI_ID_HEAPBSTR                = !"\001Heap____String\001"

#MACRO LET_HEAPSYSSTRING(lhs, rhs)
	HeapSysFreeString(lhs)
	HeapSysAddRefString(rhs)
	lhs = rhs
#ENDMACRO

Declare Function CreateHeapString( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal psz As Const WString Ptr _
)As HeapBSTR

Declare Function CreateHeapStringLen( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal psz As Const WString Ptr, _
	ByVal Length As UINT _
)As HeapBSTR

Declare Function CreateHeapZStringLen( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal psz As Const ZString Ptr, _
	ByVal Length As UINT _
)As HeapBSTR

Declare Function CreatePermanentHeapString( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal psz As Const WString Ptr _
)As HeapBSTR

Declare Function CreatePermanentHeapStringLen( _
	ByVal pIMemoryAllocator As IMalloc Ptr, _
	ByVal psz As Const WString Ptr, _
	ByVal Length As UINT _
)As HeapBSTR

Declare Function HeapSysAddRefString( _
	ByVal bstrString As HeapBSTR _
)As HRESULT

Declare Sub HeapSysFreeString( _
	ByVal bstrString As HeapBSTR _ 
)

Declare Function FindStringW( _
	ByVal pSource As WString Ptr, _
	ByVal SourceLength As Integer, _
	ByVal pSubstring As WString Ptr, _
	ByVal SubstringLength As Integer _
)As WString Ptr

Declare Function FindStringIW( _
	ByVal pSource As WString Ptr, _
	ByVal SourceLength As Integer, _
	ByVal pSubstring As WString Ptr, _
	ByVal SubstringLength As Integer _
)As WString Ptr

#endif
