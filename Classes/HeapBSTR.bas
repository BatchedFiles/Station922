#include once "HeapBSTR.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalInternalPermanentStringVirtualTable As Const IStringVirtualTable
Extern GlobalInternalStringVirtualTable As Const IStringVirtualTable

Type _InternalHeapBSTR
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IStringVirtualTable Ptr
	ReferenceCounter As UInteger
	pIMemoryAllocator As IMalloc Ptr
	#ifdef __FB_64BIT__
		Padding As DWORD
	#endif
	cbBytes As DWORD
	wszNullChar(0 To 7) As OLECHAR
End Type

Sub InitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT, _
		ByVal Permanent As Boolean _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_HEAPBSTR), _
			Len(InternalHeapBSTR.IdString) _
		)
	#endif
	
	If Permanent Then
		this->lpVtbl = @GlobalInternalPermanentStringVirtualTable
		this->ReferenceCounter = CUInt(-1)
	Else
		this->lpVtbl = @GlobalInternalStringVirtualTable
		this->ReferenceCounter = 0
	End If
	
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	If Length = 0 Then
		this->cbBytes = 0
		this->wszNullChar(0) = 0
	Else
		this->cbBytes = Length * SizeOf(OLECHAR)
		CopyMemory( _
			@this->wszNullChar(0), _
			pwsz, _
			(Length) * SizeOf(OLECHAR) _
		)
		this->wszNullChar(Length) = 0
	End If
	
End Sub

Sub UnInitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
End Sub

Function CreateHeapString( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr _
	)As HeapBSTR
	
	Dim pszlen As UINT = Any
	If pwsz = NULL Then
		pszlen = 0
	Else
		pszlen = lstrlenW(pwsz)
	End If
	
	Return CreateHeapStringLen(pIMemoryAllocator, pwsz, pszlen)
	
End Function

Function CreateHeapStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR
	
	Dim this As InternalHeapBSTR Ptr = CreateInternalHeapBSTR( _
		pIMemoryAllocator, _
		pwsz, _
		Length, _
		False _
	)
	If this = NULL Then
		Return NULL
	End If
	
	Dim pIString As IString Ptr = Any
	Dim hr As HRESULT = InternalHeapBSTRQueryInterface( _
		this, _
		@IID_IString, _
		@pIString _
	)
	If FAILED(hr) Then
		DestroyInternalHeapBSTR(this)
		Return NULL
	End If
	
	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(this, @pHeapBstr)
	
	Return pHeapBstr
	
End Function

Function CreatePermanentHeapString( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr _
	)As HeapBSTR
	
	Dim pszlen As UINT = Any
	If pwsz = NULL Then
		pszlen = 0
	Else
		pszlen = lstrlenW(pwsz)
	End If
	
	Return CreatePermanentHeapStringLen(pIMemoryAllocator, pwsz, pszlen)
	
End Function

Function CreatePermanentHeapStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR
	
	Dim this As InternalHeapBSTR Ptr = CreateInternalHeapBSTR( _
		pIMemoryAllocator, _
		pwsz, _
		Length, _
		True _
	)
	If this = NULL Then
		Return NULL
	End If
	
	Dim pIString As IString Ptr = Any
	Dim hr As HRESULT = InternalPermanentHeapBSTRQueryInterface( _
		this, _
		@IID_IString, _
		@pIString _
	)
	If FAILED(hr) Then
		DestroyInternalHeapBSTR(this)
		Return NULL
	End If
	
	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(this, @pHeapBstr)
	
	Return pHeapBstr
	
End Function

Function CreateHeapZStringLen( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal psz As Const ZString Ptr, _
		ByVal Length As UINT _
	)As HeapBSTR
	
	Dim cbInternalHeapBSTR As Integer = SizeOf(InternalHeapBSTR) - SizeOf(OLECHAR)
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
		NULL, _
		0, _
		False _
	)
	
	Dim pIString As IString Ptr = Any
	Dim hr As HRESULT = InternalHeapBSTRQueryInterface( _
		this, _
		@IID_IString, _
		@pIString _
	)
	If FAILED(hr) Then
		DestroyInternalHeapBSTR(this)
		Return NULL
	End If
	
	Const dwFlags As DWORD = 0
	MultiByteToWideChar( _
		CP_ACP, _
		dwFlags, _
		psz, _
		Length, _
		@this->wszNullChar(0), _
		Length _
	)
	
	this->cbBytes = Length * SizeOf(OLECHAR)
	this->wszNullChar(Length) = 0
	
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
	
	Dim pHeapBstr As HeapBSTR = Any
	InternalHeapBSTRGetHeapBSTR(this, @pHeapBstr)
	
	Return pHeapBstr
	
End Function

Function CreateInternalHeapBSTR( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT, _
		ByVal Permanent As Boolean _
	)As InternalHeapBSTR Ptr
	
	Dim cbInternalHeapBSTR As Integer = SizeOf(InternalHeapBSTR) - SizeOf(OLECHAR)
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
		Length, _
		Permanent _
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
		Dim vtString As VARIANT = Any
		vtString.vt = VT_BSTR
		vtString.bstrVal = @this->wszNullChar(0)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"HeapBSTR destroying:\t"), _
			@vtString _
		)
	End Scope
	#endif
	
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

Function HeapSysAddRefString( _
		ByVal bstrString As HeapBSTR _
	)As HRESULT
	
	If bstrString <> NULL Then
		Dim this As InternalHeapBSTR Ptr = ContainerOf(bstrString, InternalHeapBSTR, wszNullChar(0))
		InternalHeapBSTRAddRef(this)
	End If
	
	Return S_OK
	
End Function

Sub HeapSysFreeString( _
		byval bstrString As HeapBSTR _ 
	)
	
	If bstrString <> NULL Then
		Dim this As InternalHeapBSTR Ptr = ContainerOf(bstrString, InternalHeapBSTR, wszNullChar(0))
		InternalHeapBSTRRelease(this)
	End If
	
End Sub

Function InternalPermanentHeapBSTRQueryInterface( _
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
	
	InternalPermanentHeapBSTRAddRef(this)
	
	Return S_OK
	
End Function

Function InternalPermanentHeapBSTRAddRef( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	Return 1
	
End Function

Function InternalPermanentHeapBSTRRelease( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	Return 0
	
End Function

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
	
	this->ReferenceCounter += 1
	
	Return 1
	
End Function

Function InternalHeapBSTRRelease( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	this->ReferenceCounter -= 1
	
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
	
	*pcHeapBSTR = @this->wszNullChar(0)
	
	Return S_OK
	
End Function


Function IPermanentStringQueryInterface( _
		ByVal this As IString Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return InternalPermanentHeapBSTRQueryInterface(ContainerOf(this, InternalHeapBSTR, lpVtbl), riid, ppvObject)
End Function

Function IPermanentStringAddRef( _
		ByVal this As IString Ptr _
	)As ULONG
	Return InternalPermanentHeapBSTRAddRef(ContainerOf(this, InternalHeapBSTR, lpVtbl))
End Function

Function IPermanentStringRelease( _
		ByVal this As IString Ptr _
	)As ULONG
	Return InternalPermanentHeapBSTRRelease(ContainerOf(this, InternalHeapBSTR, lpVtbl))
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

Dim GlobalInternalPermanentStringVirtualTable As Const IStringVirtualTable = Type( _
	@IPermanentStringQueryInterface, _
	@IPermanentStringAddRef, _
	@IPermanentStringRelease, _
	@IStringGetHeapBSTR _
)

Dim GlobalInternalStringVirtualTable As Const IStringVirtualTable = Type( _
	@IStringQueryInterface, _
	@IStringAddRef, _
	@IStringRelease, _
	@IStringGetHeapBSTR _
)
