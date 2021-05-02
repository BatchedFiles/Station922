#include once "HeapMemoryAllocatorClassFactory.bi"
#include once "ObjectsCounter.bi"

Extern GlobalClassFactoryTestComServerVirtualTable As Const IClassFactoryVtbl
Extern GlobalClassFactoryVirtualTableConnectionPointVirtualTable As Const IClassFactoryVtbl
Extern GlobalClassFactoryDispatchConnectionPointVirtualTable As Const IClassFactoryVtbl

Type ClassFactoryVirtualTable
	Dim rclsid As Const CLSID Ptr
	Dim lpVtbl As Const IClassFactoryVtbl Ptr
End Type

Common Shared PGlobalCounter As ObjectsCounter Ptr

Const MAX_SUPPORTED_CLASSES As Integer = 3
Dim Shared ClassFactoryVirtualTables(MAX_SUPPORTED_CLASSES - 1) As ClassFactoryVirtualTable = { _
	Type(@CLSID_TESTCOMSERVER_VERSION10, @GlobalClassFactoryTestComServerVirtualTable), _
	Type(@CLSID_CONNECTIONPOINT_VIRTUALTABLE,  @GlobalClassFactoryVirtualTableConnectionPointVirtualTable), _
	Type(@CLSID_CONNECTIONPOINT_DISPATCH,  @GlobalClassFactoryDispatchConnectionPointVirtualTable) _
}

Sub ClassFactoryInitialize( _
		ByVal this As ClassFactory Ptr, _
		ByVal lpVtbl As Const IClassFactoryVtbl Ptr _
	)
	
	this->pVirtualTable = lpVtbl
	ReferenceCounterInitialize(@this->RefCounter)
	
End Sub

Sub ClassFactoryUnInitialize( _
		ByVal this As ClassFactory Ptr _
	)
	ReferenceCounterUnInitialize(@this->RefCounter)
End Sub

Function GetClassFactoryVirtualTable( _
		ByVal rclsid As REFCLSID _
	)As Const IClassFactoryVtbl Ptr
	
	For i As Integer = 0 To MAX_SUPPORTED_CLASSES - 1
		If IsEqualCLSID(ClassFactoryVirtualTables(i).rclsid, rclsid) Then
			Return ClassFactoryVirtualTables(i).lpVtbl
		End If
	Next
	
	Return NULL
	
End Function

Function CreateClassFactoryInterface( _
		ByVal CoClassCLSID As REFCLSID, _
		ByVal ClassFactoryIID As REFIID, _
		ByVal ppvObject As Any Ptr Ptr _
	)As HRESULT
	
	*ppvObject = NULL
	
	Dim lpVtbl As Const IClassFactoryVtbl Ptr = GetClassFactoryVirtualTable(CoClassCLSID)
	If lpVtbl = NULL Then
		Return CLASS_E_CLASSNOTAVAILABLE
	End If
	
	Dim pFactory As ClassFactory Ptr = CoTaskMemAlloc(SizeOf(ClassFactory))
	If pFactory = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	ClassFactoryInitialize(pFactory, lpVtbl)
	
	ObjectsCounterIncrement(PGlobalCounter)
	
	Dim hr As HRESULT = ClassFactoryQueryInterface(pFactory, ClassFactoryIID, ppvObject)
	If FAILED(hr) Then
		DestroyClassFactory(pFactory)
		Return hr
	End If
	
	Return S_OK
	
End Function

Sub DestroyClassFactory( _
		ByVal this As ClassFactory Ptr _
	)
	
	ObjectsCounterDecrement(PGlobalCounter)
	ClassFactoryUnInitialize(this)
	CoTaskMemFree(this)
	
End Sub

Function ClassFactoryQueryInterface( _
		ByVal this As ClassFactory Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	If IsEqualIID(@IID_IClassFactory, riid) Then
		*ppv = @this->pVirtualTable
	Else
		If IsEqualIID(@IID_IUnknown, riid) Then
			*ppv = @this->pVirtualTable
		Else
			*ppv = NULL
			Return E_NOINTERFACE
		End If
	End If
	
	ClassFactoryAddRef(this)
	
	Return S_OK
	
End Function

Function ClassFactoryAddRef( _
		ByVal this As ClassFactory Ptr _
	)As ULONG
	
	ReferenceCounterIncrement(@this->RefCounter)
	
	Return 1
	
End Function

Function ClassFactoryRelease( _
		ByVal this As ClassFactory Ptr _
	)As ULONG
	
	ReferenceCounterDecrement(@this->RefCounter)
	
	If this->RefCounter.Counter = 0 Then
		DestroyClassFactory(this)
		Return 0
	End If
	
	Return 1
	
End Function

Function ClassFactoryCreateInstanceTestComServer( _
		ByVal this As ClassFactory Ptr, _
		ByVal pUnknownOuter As IUnknown Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
	If pUnknownOuter <> NULL AndAlso IsEqualIID(@IID_IUnknown, riid) = 0 Then
		Return CLASS_E_NOAGGREGATION
	End If
	
	Dim pTestCOMServer As TestCOMServer Ptr = Any
	Dim hr As HRESULT = CreateTestCOMServer(pUnknownOuter, @pTestCOMServer)
	If FAILED(hr) Then
		Return hr
	End If
	
	' TODO Ошибка: необходимо запросить неделегирующий IUnknown
	hr = TestCOMServerQueryInterface(pTestCOMServer, riid, ppv)
	If FAILED(hr) Then
		DestroyTestCOMServer(pTestCOMServer)
		Return hr
	End If
	
	Return S_OK
	
End Function

Function ClassFactoryCreateInstanceVirtualTableConnectionPoint( _
		ByVal this As ClassFactory Ptr, _
		ByVal pUnknownOuter As IUnknown Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
	If pUnknownOuter <> NULL Then
		Return CLASS_E_NOAGGREGATION
	End If
	
	Dim pPoint As TestCOMServerEventsConnectionPoint Ptr = CreateTestCOMServerEventsVirtualTableConnectionPoint()
	If pPoint = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	Dim hr As HRESULT = TestCOMServerEventsConnectionPointQueryInterface(pPoint, riid, ppv)
	If FAILED(hr) Then
		DestroyTestCOMServerEventsConnectionPoint(pPoint)
		Return hr
	End If
	
	Return S_OK
	
End Function

Function ClassFactoryCreateInstanceDispatchConnectionPoint( _
		ByVal this As ClassFactory Ptr, _
		ByVal pUnknownOuter As IUnknown Ptr, _
		ByVal riid As REFIID, _
		ByVal ppv As Any Ptr Ptr _
	)As HRESULT
	
	*ppv = NULL
	
	If pUnknownOuter <> NULL Then
		Return CLASS_E_NOAGGREGATION
	End If
	
	Dim pPoint As TestCOMServerEventsConnectionPoint Ptr = CreateTestCOMServerEventsDispatchConnectionPoint()
	If pPoint = NULL Then
		Return E_OUTOFMEMORY
	End If
	
	Dim hr As HRESULT = TestCOMServerEventsConnectionPointQueryInterface(pPoint, riid, ppv)
	If FAILED(hr) Then
		DestroyTestCOMServerEventsConnectionPoint(pPoint)
		Return hr
	End If
	
	Return S_OK
	
End Function
	
Function ClassFactoryLockServer( _
		ByVal this As ClassFactory Ptr, _
		ByVal fLock As BOOL _
	)As HRESULT
	
	' Dim Delta As Long = Any
	
	If fLock Then
		ObjectsCounterIncrement(PGlobalCounter)
	Else
		ObjectsCounterDecrement(PGlobalCounter)
	End If
	
	Return S_OK
	
End Function
