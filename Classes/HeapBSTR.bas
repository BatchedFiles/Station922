#include once "HeapBSTR.bi"
#include once "ContainerOf.bi"
#include once "ReferenceCounter.bi"

Extern GlobalInternalStringVirtualTable As Const IStringVirtualTable

Type _InternalHeapBSTR
	lpVtbl As Const IStringVirtualTable Ptr
	RefCounter As ReferenceCounter
	pILogger As ILogger Ptr
	pIMemoryAllocator As IMalloc Ptr
	cbBytes As UINT
	wszNullChar As OLECHAR
End Type

Sub InitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr, _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)
	this->lpVtbl = @GlobalInternalStringVirtualTable
	ReferenceCounterInitialize(@this->RefCounter)
	ILogger_AddRef(pILogger)
	this->pILogger = pILogger
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	
	If Length = 0 Then
		this->cbBytes = 0
		this->wszNullChar = 0
	Else
		this->cbBytes = Length * SizeOf(OLECHAR)
		memcpy(@this->wszNullChar, pwsz, (Length + 1) * SizeOf(OLECHAR))
	End If
	
End Sub

Sub UnInitializeInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
	ReferenceCounterUnInitialize(@this->RefCounter)
	IMalloc_Release(this->pIMemoryAllocator)
	ILogger_Release(this->pILogger)
	
End Sub

Function CreateInternalHeapBSTR( _
		ByVal pILogger As ILogger Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		byval pwsz As Const WString Ptr, _
		ByVal Length As UINT _
	)As InternalHeapBSTR Ptr
	
	Dim cbInternalHeapBSTR As Integer = SizeOf(InternalHeapBSTR)
	Dim cbValueBstr As Integer = (Length + 1) * SizeOf(OLECHAR)
	Dim cbBytes As Integer = cbInternalHeapBSTR + cbValueBstr
	
#if __FB_DEBUG__
	Dim vtAllocatedBytes As VARIANT = Any
	vtAllocatedBytes.vt = VT_I4
	vtAllocatedBytes.lVal = cbBytes
	ILogger_LogDebug(pILogger, WStr(!"InternalHeapBSTR creating\t"), vtAllocatedBytes)
#endif
	
	Dim this As InternalHeapBSTR Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		cbBytes _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeInternalHeapBSTR(this, pILogger, pIMemoryAllocator, pwsz, Length)
	
#if __FB_DEBUG__
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(pILogger, WStr("InternalHeapBSTR created"), vtEmpty)
#endif
	
	Return this
	
End Function

Sub DestroyInternalHeapBSTR( _
		ByVal this As InternalHeapBSTR Ptr _
	)
	
#if __FB_DEBUG__
	Dim vtEmpty As VARIANT = Any
	vtEmpty.vt = VT_EMPTY
	ILogger_LogDebug(this->pILogger, WStr("InternalHeapBSTR destroying"), vtEmpty)
#endif
	
	ILogger_AddRef(this->pILogger)
	Dim pILogger As ILogger Ptr = this->pILogger
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeInternalHeapBSTR(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
#if __FB_DEBUG__
	ILogger_LogDebug(pILogger, WStr("InternalHeapBSTR destroyed"), vtEmpty)
#endif
	
	IMalloc_Release(pIMemoryAllocator)
	ILogger_Release(pILogger)
	
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
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function InternalHeapBSTRRelease( _
		ByVal this As InternalHeapBSTR Ptr _
	)As ULONG
	
	If ReferenceCounterDecrement(@this->RefCounter) Then
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

/'
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
	
	Dim pHeapBstr As InternalHeapBSTR Ptr = CreateInternalHeapBSTR( _
		pIMemoryAllocator, _
		pwsz, _
		Length _
	)
	If pHeapBstr = NULL Then
		Return NULL
	End If
	
	InternalHeapBSTRAddRef(pHeapBstr)
	
	Return @pHeapBstr->wszNullChar
	
End Function

Sub HeapSysFreeString( _
		byval bstrString As HeapBSTR _ 
	)
	
	If bstrString <> NULL Then
		Dim this As InternalHeapBSTR Ptr = ContainerOf(bstrString, InternalHeapBSTR, wszNullChar)
		InternalHeapBSTRRelease(this)
	End If
	
End Sub
'/

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
