#ifndef IHTTPREADER_BI
#define IHTTPREADER_BI

#include "IBaseStream.bi"
#include "ITextReader.bi"

' S_OK
Const HTTPREADER_E_INTERNALBUFFEROVERFLOW As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 1)
Const HTTPREADER_E_SOCKETERROR As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 2)
Const HTTPREADER_E_CLIENTCLOSEDCONNECTION As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 3)
Const HTTPREADER_E_BUFFERTOOSMALL As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 4)

Type IHttpReader As IHttpReader_

Type LPIHTTPREADER As IHttpReader Ptr

Extern IID_IHttpReader Alias "IID_IHttpReader" As Const IID

Type IHttpReaderVirtualTable
	Dim InheritedTable As ITextReaderVirtualTable
	
	Dim Clear As Function( _
		ByVal this As IHttpReader Ptr _
	)As HRESULT
	
	Dim GetBaseStream As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal ppResult As IBaseStream Ptr Ptr _
	)As HRESULT
	
	Dim SetBaseStream As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pIStream As IBaseStream Ptr _
	)As HRESULT
	
	Dim GetPreloadedBytes As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pPreloadedBytesLength As Integer Ptr, _
		ByVal ppPreloadedBytes As UByte Ptr Ptr _
	)As HRESULT
	
	Dim GetRequestedBytes As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pRequestedBytesLength As Integer Ptr, _
		ByVal ppRequestedBytes As UByte Ptr Ptr _
	)As HRESULT
	
End Type

Type IHttpReader_
	Dim pVirtualTable As IHttpReaderVirtualTable Ptr
End Type

#define IHttpReader_QueryInterface(this, riid, ppv) (this)->pVirtualTable->InheritedTable.InheritedTable.QueryInterface(CPtr(IUnknown Ptr, this), riid, ppv)
#define IHttpReader_AddRef(this) (this)->pVirtualTable->InheritedTable.InheritedTable.AddRef(CPtr(IUnknown Ptr, this))
#define IHttpReader_Release(this) (this)->pVirtualTable->InheritedTable.InheritedTable.Release(CPtr(IUnknown Ptr, this))
#define IHttpReader_ReadLine(this, pLineLength, pLine) (this)->pVirtualTable->InheritedTable.ReadLine(CPtr(ITextReader Ptr, this), pLineLength, pLine)
#define IHttpReader_Clear(this) (this)->pVirtualTable->Clear(this)
#define IHttpReader_GetBaseStream(this, ppResult) (this)->pVirtualTable->GetBaseStream(this, ppResult)
#define IHttpReader_SetBaseStream(this, pIStream) (this)->pVirtualTable->SetBaseStream(this, pIStream)
#define IHttpReader_GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes) (this)->pVirtualTable->GetPreloadedBytes(this, pPreloadedBytesLength, ppPreloadedBytes)
#define IHttpReader_GetRequestedBytes(this, pRequestedBytesLength, ppRequestedBytes) (this)->pVirtualTable->GetRequestedBytes(this, pRequestedBytesLength, ppRequestedBytes)

#endif
