#ifndef CLASSFACTORY_BI
#define CLASSFACTORY_BI

#include once "windows.bi"
#include once "win\ole2.bi"

Type _ClassFactory
	
	Dim pVirtualTable As Const IClassFactoryVtbl Ptr
	Dim RefCounter As ReferenceCounter
	
End Type

Type ClassFactory As _ClassFactory

Declare Function CreateClassFactoryInterface( _
	ByVal CoClassCLSID As REFCLSID, _
	ByVal ClassFactoryIID As REFIID, _
	ByVal ppvIClassFactory As Any Ptr Ptr _
)As HRESULT

Declare Sub DestroyClassFactory( _
	ByVal this As ClassFactory Ptr _
)

Declare Function ClassFactoryQueryInterface( _
	ByVal this As ClassFactory Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function ClassFactoryAddRef( _
	ByVal this As ClassFactory Ptr _
)As ULONG

Declare Function ClassFactoryRelease( _
	ByVal this As ClassFactory Ptr _
)As ULONG

Declare Function ClassFactoryCreateInstance( _
	ByVal this As ClassFactory Ptr, _
	ByVal pUnknownOuter As IUnknown Ptr, _
	ByVal riid As REFIID, _
	ByVal ppv As Any Ptr Ptr _
)As HRESULT

Declare Function ClassFactoryLockServer( _
	ByVal this As ClassFactory Ptr, _
	ByVal fLock As BOOL _
)As HRESULT

#endif
