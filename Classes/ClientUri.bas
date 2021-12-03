#include once "ClientUri.bi"
#include once "win\shlwapi.bi"
#include once "CharacterConstants.bi"
#include once "HeapBSTR.bi"
#include once "Logger.bi"

Extern GlobalClientUriVirtualTable As Const IClientUriVirtualTable

Type _ClientUri
	lpVtbl As Const IClientUriVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	Uri As HeapBSTR
	UserName As HeapBSTR
	Password As HeapBSTR
	Host As HeapBSTR
	Port As HeapBSTR
	Scheme As HeapBSTR
	Path As HeapBSTR
	Query As HeapBSTR
	Fragment As HeapBSTR
End Type

Sub InitializeClientUri( _
		ByVal this As ClientUri Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	this->lpVtbl = @GlobalClientUriVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->Uri = NULL
	this->UserName = NULL
	this->Password = NULL
	this->Host = NULL
	this->Port = NULL
	this->Scheme = NULL
	this->Path = NULL
	this->Query = NULL
	this->Fragment = NULL
	
End Sub

Sub UnInitializeClientUri( _
		ByVal this As ClientUri Ptr _
	)
	
	HeapSysFreeString(this->Uri)
	HeapSysFreeString(this->UserName)
	HeapSysFreeString(this->Password)
	HeapSysFreeString(this->Host)
	HeapSysFreeString(this->Port)
	HeapSysFreeString(this->Scheme)
	HeapSysFreeString(this->Path)
	HeapSysFreeString(this->Query)
	HeapSysFreeString(this->Fragment)
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateClientUri( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As ClientUri Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(ClientUri)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"ClientUri creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As ClientUri Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(ClientUri) _
	)
	
	If this <> NULL Then
		
		InitializeClientUri( _
			this, _
			pIMemoryAllocator _
		)
		
		#if __FB_DEBUG__
		Scope
			Dim vtEmpty As VARIANT = Any
			VariantInit(@vtEmpty)
			LogWriteEntry( _
				LogEntryType.Debug, _
				WStr("ClientUri created"), _
				@vtEmpty _
			)
		End Scope
		#endif
		
		Return this
	End If
	
	Return NULL
	
End Function

Sub DestroyClientUri( _
		ByVal this As ClientUri Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ClientUri destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeClientUri(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("ClientUri destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function ClientUriQueryInterface( _
		ByVal this As ClientUri Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IClientUri, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ClientUriAddRef(this)
	
	Return S_OK
	
End Function

Function ClientUriAddRef( _
		ByVal this As ClientUri Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function ClientUriRelease( _
		ByVal this As ClientUri Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		If InterlockedDecrement64(@this->ReferenceCounter) Then
			Return 1
		End If
	#else
		If InterlockedDecrement(@this->ReferenceCounter) Then
			Return 1
		End If
	#endif
	
	DestroyClientUri(this)
	
	Return 0
	
End Function


/'
QueryInterface As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal riid As REFIID, _
	ByVal ppvObject As Any Ptr Ptr _
)As HRESULT

AddRef As Function( _
	ByVal this As IClientUri Ptr _
)As ULONG

Release As Function( _
	ByVal this As IClientUri Ptr _
)As ULONG

UriFromString As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal bstrUri As BSTR _
)As HRESULT

GetOriginalString As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppOriginalString As HeapBSTR Ptr _
)As HRESULT

GetUserName As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppUserName As HeapBSTR Ptr _
)As HRESULT

GetPassword As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppPassword As HeapBSTR Ptr _
)As HRESULT

GetHost As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppHost As HeapBSTR Ptr _
)As HRESULT

GetPort As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppPort As HeapBSTR Ptr _
)As HRESULT

GetScheme As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppScheme As HeapBSTR Ptr _
)As HRESULT

GetPath As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppPath As HeapBSTR Ptr _
)As HRESULT

GetQuery As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppQuery As HeapBSTR Ptr _
)As HRESULT

GetFragment As Function( _
	ByVal this As IClientUri Ptr, _
	ByVal ppFragment As HeapBSTR Ptr _
)As HRESULT

Dim GlobalClientUriVirtualTable As Const IClientUriVirtualTable = Type( _
)
'/