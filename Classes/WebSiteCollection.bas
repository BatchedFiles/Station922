#include once "WebSiteCollection.bi"
#include once "ContainerOf.bi"
#include once "Logger.bi"

Extern GlobalWebSiteCollectionVirtualTable As Const IWebSiteCollectionVirtualTable

Type WebSiteNode
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	LeftNode As WebSiteNode Ptr
	RightNode As WebSiteNode Ptr
	HostName As BSTR
	pIWebSite As IWebSite Ptr
End Type

Type _WebSiteCollection
	#if __FB_DEBUG__
		IdString As ZString * 16
	#endif
	lpVtbl As Const IWebSiteCollectionVirtualTable Ptr
	ReferenceCounter As Integer
	pIMemoryAllocator As IMalloc Ptr
	pDefaultNode As WebSiteNode Ptr
	pTree As WebSiteNode Ptr
	WebSitesCount As Integer
End Type

Sub TreeAddNode( _
		ByVal pTree As WebSiteNode Ptr, _
		ByVal pNode As WebSiteNode Ptr _
	)
	
	Dim CompareResult As Long = lstrcmpiW(pNode->HostName, pTree->HostName)
	
	Select Case CompareResult
		
		Case Is > 0
			If pTree->RightNode = NULL Then
				pTree->RightNode = pNode
			Else
				TreeAddNode(pTree->RightNode, pNode)
			End If
			
		Case Is < 0
			If pTree->LeftNode = NULL Then
				pTree->LeftNode = pNode
			Else
				TreeAddNode(pTree->LeftNode, pNode)
			End If
			
	End Select
	
End Sub

Function TreeFindNode( _
		ByVal pNode As WebSiteNode Ptr, _
		ByVal HostName As WString Ptr _
	)As WebSiteNode Ptr
	
	Select Case lstrcmpiW(HostName, pNode->HostName)
		
		Case Is > 0
			If pNode->RightNode = NULL Then
				Return NULL
			End If
			
			Return TreeFindNode(pNode->RightNode, HostName)
			
		Case 0
			Return pNode
			
		Case Is < 0
			If pNode->LeftNode = NULL Then
				Return NULL
			End If
			
			Return TreeFindNode(pNode->LeftNode, HostName)
			
	End Select
	
End Function

Function CreateWebSiteNode( _
		ByVal pIMemoryAllocator As IMalloc Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pValue As IWebSite Ptr _
	)As WebSiteNode Ptr
	
	Dim bstrHostName As BSTR = SysAllocString(pKey)
	If bstrHostName = NULL Then
		Return NULL
	End If
	
	Dim pNode As WebSiteNode Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebSiteNode) _
	)
	If pNode = NULL Then
		SysFreeString(bstrHostName)
		Return NULL
	End If
	
	#if __FB_DEBUG__
		CopyMemory( _
			@pNode->IdString, _
			@Str(RTTI_ID_WEBSITENODE), _
			Len(WebSiteNode.IdString) _
		)
	#endif
	pNode->HostName = bstrHostName
	IWebSite_AddRef(pValue)
	pNode->pIWebSite = pValue
	pNode->LeftNode = NULL
	pNode->RightNode = NULL
	
	Return pNode
	
End Function

Sub InitializeWebSiteCollection( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)
	
	#if __FB_DEBUG__
		CopyMemory( _
			@this->IdString, _
			@Str(RTTI_ID_WEBSITECOLLECTION), _
			Len(WebSiteCollection.IdString) _
		)
	#endif
	this->lpVtbl = @GlobalWebSiteCollectionVirtualTable
	this->ReferenceCounter = 0
	IMalloc_AddRef(pIMemoryAllocator)
	this->pIMemoryAllocator = pIMemoryAllocator
	this->pDefaultNode = NULL
	this->pTree = NULL
	this->WebSitesCount = 0
	
End Sub

Sub UnInitializeWebSiteCollection( _
		ByVal this As WebSiteCollection Ptr _
	)
	
	IMalloc_Release(this->pIMemoryAllocator)
	
End Sub

Function CreateWebSiteCollection( _
		ByVal pIMemoryAllocator As IMalloc Ptr _
	)As WebSiteCollection Ptr
	
	#if __FB_DEBUG__
	Scope
		Dim vtAllocatedBytes As VARIANT = Any
		vtAllocatedBytes.vt = VT_I4
		vtAllocatedBytes.lVal = SizeOf(WebSiteCollection)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr(!"WebSiteCollection creating\t"), _
			@vtAllocatedBytes _
		)
	End Scope
	#endif
	
	Dim this As WebSiteCollection Ptr = IMalloc_Alloc( _
		pIMemoryAllocator, _
		SizeOf(WebSiteCollection) _
	)
	If this = NULL Then
		Return NULL
	End If
	
	InitializeWebSiteCollection(this, pIMemoryAllocator)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebSiteCollection created"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	Return this
	
End Function

Sub DestroyWebSiteCollection( _
		ByVal this As WebSiteCollection Ptr _
	)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebSiteCollection destroying"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_AddRef(this->pIMemoryAllocator)
	Dim pIMemoryAllocator As IMalloc Ptr = this->pIMemoryAllocator
	
	UnInitializeWebSiteCollection(this)
	
	IMalloc_Free(pIMemoryAllocator, this)
	
	#if __FB_DEBUG__
	Scope
		Dim vtEmpty As VARIANT = Any
		VariantInit(@vtEmpty)
		LogWriteEntry( _
			LogEntryType.Debug, _
			WStr("WebSiteCollection destroyed"), _
			@vtEmpty _
		)
	End Scope
	#endif
	
	IMalloc_Release(pIMemoryAllocator)
	
End Sub

Function WebSiteCollectionQueryInterface( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IWebSiteCollection, riid) Then
		*ppv = @this->lpVtbl
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->lpVtbl
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	WebSiteCollectionAddRef(this)
	
	Return S_OK
	
End Function

Function WebSiteCollectionAddRef( _
		ByVal this As WebSiteCollection Ptr _
	)As ULONG
	
	#ifdef __FB_64BIT__
		InterlockedIncrement64(@this->ReferenceCounter)
	#else
		InterlockedIncrement(@this->ReferenceCounter)
	#endif
	
	Return 1
	
End Function

Function WebSiteCollectionRelease( _
		ByVal this As WebSiteCollection Ptr _
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
	
	DestroyWebSiteCollection(this)
	
	Return 0
	
End Function

' Declare Function WebSiteCollection_NewEnum( _
	' ByVal this As WebSiteCollection Ptr, _
	' ByVal ppIEnum As IEnumWebSite Ptr Ptr _
' )As HRESULT

Function WebSiteCollectionItem( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	*ppIWebSite = NULL
	
	Dim pNode As WebSiteNode Ptr = TreeFindNode(this->pTree, pKey)
	If pNode = NULL Then
		Return E_FAIL
	End If
	
	IWebSite_AddRef(pNode->pIWebSite)
	*ppIWebSite = pNode->pIWebSite
	
	Return S_OK
	
End Function

Function WebSiteCollectionCount( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	
	*pCount = this->WebSitesCount
	
	Return S_OK
	
End Function

Function WebSiteCollectionAdd( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	
	Dim pNode As WebSiteNode Ptr = CreateWebSiteNode( _
		this->pIMemoryAllocator, _
		pKey, _
		pIWebSite _
	)
	If pNode = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	If this->pTree = NULL Then
		this->pTree = pNode
	Else
		TreeAddNode(this->pTree, pNode)
	End If
	
	Return S_OK
	
End Function

Function WebSiteCollectionItemWeakPtr( _
		ByVal this As WebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	
	Dim pNode As WebSiteNode Ptr = TreeFindNode(this->pTree, pKey)
	If pNode = NULL Then
		*ppIWebSite = NULL
		Return E_FAIL
	End If
	
	*ppIWebSite = pNode->pIWebSite
	
	Return S_OK
	
End Function


Function IWebSiteCollectionQueryInterface( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal riid As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	Return WebSiteCollectionQueryInterface(ContainerOf(this, WebSiteCollection, lpVtbl), riid, ppvObject)
End Function

Function IWebSiteCollectionAddRef( _
		ByVal this As IWebSiteCollection Ptr _
	)As ULONG
	Return WebSiteCollectionAddRef(ContainerOf(this, WebSiteCollection, lpVtbl))
End Function

Function IWebSiteCollectionRelease( _
		ByVal this As IWebSiteCollection Ptr _
	)As ULONG
	Return WebSiteCollectionRelease(ContainerOf(this, WebSiteCollection, lpVtbl))
End Function

' Function IWebSiteCollection_NewEnum( _
		' ByVal this As IWebSiteCollection Ptr, _
		' ByVal ppIEnum As IEnumWebSite Ptr Ptr _
	' )As HRESULT
	' Return WebSiteCollection_NewEnum(ContainerOf(this, WebSiteCollection, lpVtbl), ppIEnum)
' End Function

Function IWebSiteCollectionItem( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal Host As WString Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	Return WebSiteCollectionItem(ContainerOf(this, WebSiteCollection, lpVtbl), Host, ppIWebSite)
End Function

Function IWebSiteCollectionCount( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pCount As Integer Ptr _
	)As HRESULT
	Return WebSiteCollectionCount(ContainerOf(this, WebSiteCollection, lpVtbl), pCount)
End Function

Function IWebSiteCollectionAdd( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal pKey As WString Ptr, _
		ByVal pIWebSite As IWebSite Ptr _
	)As HRESULT
	Return WebSiteCollectionAdd(ContainerOf(this, WebSiteCollection, lpVtbl), pKey, pIWebSite)
End Function

Function IWebSiteCollectionItemWeakPtr( _
		ByVal this As IWebSiteCollection Ptr, _
		ByVal Host As WString Ptr, _
		ByVal ppIWebSite As IWebSite Ptr Ptr _
	)As HRESULT
	Return WebSiteCollectionItemWeakPtr(ContainerOf(this, WebSiteCollection, lpVtbl), Host, ppIWebSite)
End Function

Dim GlobalWebSiteCollectionVirtualTable As Const IWebSiteCollectionVirtualTable = Type( _
	@IWebSiteCollectionQueryInterface, _
	@IWebSiteCollectionAddRef, _
	@IWebSiteCollectionRelease, _
	NULL, _ /' @IWebSiteCollection_NewEnum, _ '/
	@IWebSiteCollectionItem, _
	@IWebSiteCollectionCount, _
	@IWebSiteCollectionAdd, _
	@IWebSiteCollectionItemWeakPtr _
)
