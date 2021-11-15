#ifndef BATCHEDFILES_HEAPBSTR_BI
#define BATCHEDFILES_HEAPBSTR_BI

#include once "IString.bi"

Extern CLSID_HEAPBSTR Alias "CLSID_HEAPBSTR" As Const CLSID

' Declare Function HeapSysAllocString( _
	' ByVal pIMemoryAllocator As IMalloc Ptr, _
	' ByVal psz As Const WString Ptr _
' )As HeapBSTR

' Declare Function HeapSysAllocStringLen( _
	' ByVal pIMemoryAllocator As IMalloc Ptr, _
	' ByVal psz As Const WString Ptr, _
	' ByVal ui As UINT _
' )As HeapBSTR

' Declare Sub HeapSysFreeString( _
	' ByVal bstrString As HeapBSTR _ 
' )
/'
typedef struct {
#ifdef _WIN64
    DWORD pad;
#endif
    DWORD size;
    union {
        char ptr[1];
        WCHAR str[1];
        DWORD dwptr[1];
    } u;
} bstr_t;
'/

Type HeapWideString
	Dim pIString As IString Ptr
	Declare Constructor(ByVal pIMemoryAllocator As IMalloc Ptr, ByVal psz As Const WString Ptr)
	Declare Constructor(ByVal pIMemoryAllocator As IMalloc Ptr, ByVal psz As Const WString Ptr, ByVal ui As UINT)
	Declare Constructor(ByRef lhs As Const HeapWideString)
	Declare Destructor
	Declare Operator Let(ByRef lhs As Const WString)
	Declare Operator Let(ByRef lhs As Const HeapWideString)
	Declare Operator += (ByRef lhs As Const WString)
	Declare Operator += (ByRef lhs As Const HeapWideString)
	Declare Operator &= (ByRef lhs As Const WString)
	Declare Operator &= (ByRef lhs As Const HeapWideString)
End Type

Declare Operator & (ByRef lhs As HeapWideString, ByRef rhs As HeapWideString)As HeapWideString
Declare Operator & (ByRef lhs As HeapWideString, ByRef rhs As WString)As HeapWideString
Declare Operator & (ByRef lhs As WString, ByRef rhs As HeapWideString)As HeapWideString
Declare Operator + (ByRef lhs As HeapWideString, ByRef rhs As HeapWideString)As HeapWideString
Declare Operator + (ByRef lhs As HeapWideString, ByRef rhs As WString)As HeapWideString
Declare Operator + (ByRef lhs As WString, ByRef rhs As HeapWideString)As HeapWideString
Declare Operator = (ByRef lhs As HeapWideString, ByRef rhs As HeapWideString)As Integer
Declare Operator = (ByRef lhs As HeapWideString, ByRef rhs As WString)As Integer
Declare Operator = (ByRef lhs As WString, ByRef rhs As HeapWideString)As Integer
Declare Operator <> (ByRef lhs As HeapWideString, ByRef rhs As HeapWideString)As Integer
Declare Operator <> (ByRef lhs As HeapWideString, ByRef rhs As WString)As Integer
Declare Operator <> (ByRef lhs As WString, ByRef rhs As HeapWideString)As Integer
Declare Operator Len(ByRef lhs As HeapWideString)As Integer
Declare Operator * (ByRef lhs As HeapWideString)As WString Ptr

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

#endif
