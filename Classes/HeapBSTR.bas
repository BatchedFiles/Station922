#include "HeapBSTR.bi"
#include "ContainerOf.bi"

Type InternalHeapBSTR
	Dim lpVtbl As Const IUnknownVtbl Ptr
	Dim pIMemoryAllocator As IMalloc Ptr
	Dim ReferenceCounter As Integer
	Dim BytesCount As Integer ' UINT
	' Dim wstrData As OLECHAR * (Any)
	Dim wstrNullChar As OLECHAR * (1)
End Type

Function GetBstrDataBytesCount( _
		ByVal pszlen As UINT _
	)As UINT
	
	Return pszlen * Cast(UINT, SizeOf(OLECHAR))
	
End Function

Function GetBstrDataWithNullCharBytesCount( _
		ByVal pszlen As UINT _
	)As UINT
	
	Return (pszlen + 1) * Cast(UINT, SizeOf(OLECHAR))
	
End Function

Function GetHeapBstrBytesCount( _
		ByVal pszlen As UINT _
	)As Integer
	
	Return SizeOf(InternalHeapBSTR) + CInt(GetBstrDataBytesCount(pszlen))
	
End Function

Sub InitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	this->lpVtbl = NULL
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->ReferenceCounter = 1
	this->BytesCount = 0
	' Dim wstrData As OLECHAR * (Any)
	this->wstrNullChar[0] = 0
End Sub

Sub UnInitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function GetHeapBstrPointer( _
		ByVal this As BSTR _
	)As InternalHeapBSTR Ptr
	
	Return ContainerOf(this, InternalHeapBSTR, wstrNullChar)
	
End Function

Function GetBstrPointer( _
		ByVal this As InternalHeapBSTR Ptr _
	)As BSTR
	
	Return @this->wstrNullChar
	
End Function

Function GetBstrBytesCountPointer( _
		ByVal this As InternalHeapBSTR Ptr _
	)As UINT Ptr
	
	Dim pBytes As Byte Ptr = @this->wstrNullChar
	
	Return CPtr(UINT Ptr, pBytes[-SizeOf(UINT)])
	
End Function

Function HeapSysAllocString( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval psz As Const WString Ptr _
	)As HeapBSTR
	
	Dim pszlen As UINT = lstrlenW(psz)
	
	Return HeapSysAllocStringLen(hHeap, psz, pszlen)
	
End Function

Function HeapSysAllocStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval psz As Const WString Ptr, _
		ByVal pszlen As UINT _
	)As HeapBSTR
		
	Dim this As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		GetHeapBstrBytesCount(pszlen) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeInternalHeapBSTR(this, pIMemoryAllocator)
	
	Dim pBSTR As BSTR = GetBstrPointer(this)
	Dim pBytesCount As UINT Ptr = GetBstrBytesCountPointer(this)
	
	*pBytesCount = GetBstrDataBytesCount(pszlen)
	memcpy(pBSTR, psz, GetBstrDataWithNullCharBytesCount(pszlen))
	
	Return pBSTR
	
End Function

Sub HeapSysFreeString( _
		byval bstrString As HeapBSTR _ 
	)
	
	If bstrString <> NULL Then
		Dim this As InternalHeapBSTR Ptr = GetHeapBstrPointer(bstrString)
		
		IMalloc_AddRef(this->pIMemoryAllocator)
		Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
		
		UnInitializeInternalHeapBSTR(this)
		
		IMalloc_Free(pIMemoryAllocator, this)
		
		IMalloc_Release(pIMemoryAllocator)
	End If
	
End Sub
