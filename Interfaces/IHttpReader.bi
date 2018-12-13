#ifndef IHTTPREADER_BI
#define IHTTPREADER_BI

#include "ITextReader.bi"
#include "IBaseStream.bi"

' S_OK
Const HTTPREADER_E_INTERNALBUFFEROVERFLOW As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 1)
Const HTTPREADER_E_SOCKETERROR As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 2)
Const HTTPREADER_E_CLIENTCLOSEDCONNECTION As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 3)
Const HTTPREADER_E_BUFFERTOOSMALL As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, 4)

' {D34D026F-D057-422F-9B32-C6D9424336F2}
Dim Shared IID_IHTTPREADER As IID = Type(&hd34d026f, &hd057, &h422f, _
	{&h9b, &h32, &hc6, &hd9, &h42, &h43, &h36, &hf2})

Type LPIHTTPREADER As IHttpReader Ptr

Type IHttpReader As IHttpReader_

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
	
	Dim GetPreloadedContent As Function( _
		ByVal this As IHttpReader Ptr, _
		ByVal pPreloadedContentLength As Integer Ptr, _
		ByVal ppPreloadedContent As UByte Ptr Ptr _
	)As HRESULT
	
End Type

Type IHttpReader_
	Dim pVirtualTable As IHttpReaderVirtualTable Ptr
End Type

#endif
