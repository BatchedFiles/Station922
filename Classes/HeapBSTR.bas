#include once "HeapBSTR.bi"
#include once "ContainerOf.bi"
#include once "PrintDebugInfo.bi"

Extern GlobalInternalStringVirtualTable As Const IStringVirtualTable

#define GetBstrDataBytesCount(pszlen) ((pszlen) * Cast(UINT, SizeOf(OLECHAR)))

Type _InternalHeapBSTR
	Dim lpVtbl As Const IStringVirtualTable Ptr
	Dim pIMemoryAllocator As IMalloc Ptr
	Dim ReferenceCounter As Integer
	Dim BytesCount As UINT
	' Dim wstrData As OLECHAR * (Any)
	Dim wstrNullChar As OLECHAR
End Type

Sub InitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval psz As Const WString Ptr, _
		ByVal pszlen As UINT _
	)
	this->lpVtbl = @GlobalInternalStringVirtualTable
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->ReferenceCounter = 0
	
	If pszlen = 0 Then
		this->BytesCount = 0
		this->wstrNullChar = 0
	Else
		this->BytesCount = pszlen * SizeOf(OLECHAR)
		memcpy(@this->wstrNullChar, psz, (pszlen + 1) * SizeOf(OLECHAR))
	End If
	
End Sub

Sub UnInitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateInternalHeapBSTR( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As InternalHeapBSTR Ptr
	
	DebugPrintInteger(WStr(!"InternalHeapBSTR creating\t"), SizeOf(InternalHeapBSTR))
	
	Dim this As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(InternalHeapBSTR) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeInternalHeapBSTR(this, pIMemoryAllocator, NULL, 0)
	
	DebugPrintWString(WStr("InternalHeapBSTR created"))
	
	Return this
	
End Function

Function HeapSysAllocString( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval psz As Const WString Ptr _
	)As HeapBSTR
	
	Dim pszlen As UINT = lstrlenW(psz)
	
	Return HeapSysAllocStringLen(pIMemoryAllocator, psz, pszlen)
	
End Function

Function HeapSysAllocStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval psz As Const WString Ptr, _
		ByVal pszlen As UINT _
	)As HeapBSTR
	
	DebugPrintWString(WStr("InternalHeapBSTR creating"))
	
	Dim this As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(InternalHeapBSTR) + Cast(Integer, pszlen * Cast(UINT, SizeOf(OLECHAR))) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeInternalHeapBSTR(this, pIMemoryAllocator, psz, pszlen)
	
	Dim p As IString Ptr = Any
	Dim hr As HRESULT = InternalHeapBSTRQueryInterface(this, @IID_IString, @p)
	
	If FAILED(hr) Then
		DestroyInternalHeapBSTR(this)
	End If
	
	DebugPrintWString(WStr("InternalHeapBSTR created"))
	
	Return @this->wstrNullChar
	
End Function

Sub DestroyInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
	DebugPrintWString(WStr("InternalHeapBSTR destroying"))
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeInternalHeapBSTR(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	IMalloc_Release(pIMemoryAllocator)
	
	DebugPrintWString(WStr("InternalHeapBSTR destroyed"))
	
End Sub

Sub HeapSysFreeString( _
		byval bstrString As HeapBSTR _ 
	)
	
	If bstrString <> NULL Then
		Dim this As InternalHeapBSTR Ptr = ContainerOf(bstrString, InternalHeapBSTR, wstrNullChar)
		InternalHeapBSTRRelease(this)
	End If
	
End Sub

Function InternalHeapBSTRQueryInterface( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IString, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	InternalHeapBSTRAddRef(this)
	
	Return S_OK
	
End Function

Function InternalHeapBSTRAddRef( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	' EnterCriticalSection(@this->crSection)
	' Scope
		this->ReferenceCounter += 1
	' End Scope
	' LeaveCriticalSection(@this->crSection)
	
	Return 1
	
End Function

Function InternalHeapBSTRRelease( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	' EnterCriticalSection(@this->crSection)
	' Scope
		this->ReferenceCounter -= 1
	' End Scope
	' LeaveCriticalSection(@this->crSection)
	
	If this->ReferenceCounter = 0 Then
		
		DestroyInternalHeapBSTR(this)
		
		Return 0
	End If
	
	Return 1
	
End Function


Function IStringQueryInterface( _
		ByVal this As IString Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return InternalHeapBSTRQueryInterface(ContainerOf(this, InternalHeapBSTR, lpVtbl), riid, ppvObject)
End Function

Function IStringAddRef( _
		ByVal this As IString Ptr _
	)As ULONG
	Return InternalHeapBSTRAddRef(ContainerOf(this, InternalHeapBSTR, lpVtbl))
End Function

Function IStringRelease( _
		ByVal this As IString Ptr _
	)As ULONG
	Return InternalHeapBSTRRelease(ContainerOf(this, InternalHeapBSTR, lpVtbl))
End Function

Dim GlobalInternalStringVirtualTable As Const IStringVirtualTable = Type( _
	@IStringQueryInterface, _
	@IStringAddRef, _
	@IStringRelease _
)
