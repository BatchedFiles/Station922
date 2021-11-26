#include once "HeapBSTR.bi"
#include once "ContainerOf.bi"
#include once "ICloneable.bi"
#include once "Logger.bi"

Extern GlobalInternalStringVirtualTable As Const IStringVirtualTable

Const MAX_CRITICAL_SECTION_SPIN_COUNT As DWORD = 4000

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

Type _InternalHeapBSTR
	lpVtbl As Const IStringVirtualTable Ptr
	' crSection As CRITICAL_SECTION
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	#ifdef __FB_64BIT__
		Padding As DWORD
	#endif
	cbBytes As DWORD
	wszNullChar As OLECHAR
End Type

Function HeapSysCopyString( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal source As HeapBSTR _
	)As HeapBSTR
	
	If source = NULL Then
		Return NULL
	End If
	
	Dim pIString As IString Ptr = GetIStringFromHeapBSTR(source)
	
	Dim pICloneable As ICloneable Ptr = Any
	Dim hrCreateCloneable As HRESULT = IString_QueryInterface( _
		pIString, _
		@IID_ICloneable, _
		@pICloneable _
	)
	If FAILED(hrCreateCloneable) Then
		Return NULL
	End If
	
	Dim copy As IString Ptr = Any
	Dim hr As HRESULT = ICloneable_Clone( _
		pICloneable, _
		pIMemoryAllocator, _
		@IID_IString, _
		@copy _
	)
	If FAILED(hr) Then
		ICloneable_Release(pICloneable)
		Return NULL
	End If
	
	ICloneable_Release(pICloneable)
	
	Dim pHeapBstr As HeapBSTR = Any
	IString_GetHeapBSTR(copy, @pHeapBstr)
	
	Return pHeapBstr
	
End Function

Function HeapSysAllocString( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr _
	)As HeapBSTR
	
	Dim pszlen As UINT = lstrlenW(pwsz)
	
	Return HeapSysAllocStringLen(pIMemoryAllocator, pwsz, pszlen)
	
End Function

Function HeapSysAllocStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR
	
	Dim pInternalHeapBstr As InternalHeapBSTR Ptr = CreateInternalHeapBSTR( _
		pIMemoryAllocator, _
		pwsz, _
		Length _
	)
	If pInternalHeapBstr = NULL Then
		Return NULL
	End If
	
	Dim pIString As IString Ptr = Any
	Dim hr As HRESULT = InternalHeapBSTRQueryInterface( _
		pInternalHeapBstr, _
		@IID_IString, _
		@pIString _
	)
	If FAILED(hr) Then
		DestroyInternalHeapBSTR(pInternalHeapBstr)
		Return NULL
	End If
	
	Dim pHeapBstr As HeapBSTR = Any
	IString_GetHeapBSTR(pIString, @pHeapBstr)
	
	Return pHeapBstr
	
End Function

Sub HeapSysFreeString( _
		byval bstrString As HeapBSTR _ 
	)
	
	If bstrString <> NULL Then
		Dim pIString As IString Ptr = GetIStringFromHeapBSTR(bstrString)
		IString_Release(pIString)
	End If
	
End Sub

Sub InitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)
	this->lpVtbl = @GlobalInternalStringVirtualTable
	' InitializeCriticalSectionAndSpinCount( _
		' @this->crSection, _
		' MAX_CRITICAL_SECTION_SPIN_COUNT _
	' )
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	If Length = 0 Then
		this->cbBytes = 0
		this->wszNullChar = 0
	Else
		this->cbBytes = Length * SizeOf(OLECHAR)
		CopyMemory( _
			@this->wszNullChar, _
			pwsz, _
			(Length + 1) * SizeOf(OLECHAR) _
		)
	End If
	
End Sub

Sub UnInitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
	IMalloc_Release(this->pIMemoryAllocator)
	' DeleteCriticalSection(@this->crSection)
	
End Sub

Function CreateInternalHeapBSTR( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As InternalHeapBSTR Ptr
	
	Dim cbInternalHeapBSTR As Integer = SizeOf(InternalHeapBSTR)
	Dim cbValueBstr As Integer = (Length + 1) * SizeOf(OLECHAR)
	Dim cbBytes As Integer = cbInternalHeapBSTR + cbValueBstr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = cbBytes
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"HeapBSTR creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		cbBytes _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeInternalHeapBSTR( _
		this, _
		pIMemoryAllocator, _
		pwsz, _
		Length _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HeapBSTR created"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Return this
	
End Function

Sub DestroyInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HeapBSTR destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeInternalHeapBSTR(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("HeapBSTR destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
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
	Scope
		this->ReferenceCounter += 1
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	Return this->ReferenceCounter
	
End Function

Function InternalHeapBSTRRelease( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	' EnterCriticalSection(@this->crSection)
	Scope
		this->ReferenceCounter -= 1
	End Scope
	' LeaveCriticalSection(@this->crSection)
	
	If this->ReferenceCounter Then
		Return 1
	End If
	
	DestroyInternalHeapBSTR(this)
	
	Return 0
	
End Function

Function InternalHeapBSTRGetHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal pcHeapBSTR As HeapBSTR Const Ptr _
	)As HRESULT
	
	*pcHeapBSTR = @this->wszNullChar
	
	Return S_OK
	
End Function

Function GetIStringFromHeapBSTR( _
		ByVal bs As HeapBSTR _
	)As IString Ptr
	
	Dim this As InternalHeapBSTR Ptr = ContainerOf(bs, InternalHeapBSTR, wszNullChar)
	
	Dim pIString As IString Ptr = CPtr(IString Ptr, @this->lpVtbl)
	
	Return pIString
	
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

Function IStringGetHeapBSTR( _
		ByVal this As IString Ptr, _
		ByVal pcHeapBSTR As HeapBSTR Const Ptr _
	)As HRESULT
	Return InternalHeapBSTRGetHeapBSTR(ContainerOf(this, InternalHeapBSTR, lpVtbl), pcHeapBSTR)
End Function

Dim GlobalInternalStringVirtualTable As Const IStringVirtualTable = Type( _
	@IStringQueryInterface, _
	@IStringAddRef, _
	@IStringRelease, _
	@IStringGetHeapBSTR _
)
