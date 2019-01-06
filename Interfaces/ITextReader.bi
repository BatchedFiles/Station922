#ifndef ITEXTREADER_BI
#define ITEXTREADER_BI

#ifndef unicode
#define unicode
#endif
#include "windows.bi"
#include "win\objbase.bi"

' {D46D4E27-B2CD-4594-96EA-5B8203D21439}
Dim Shared IID_ITEXTREADER As IID = Type(&hd46d4e27, &hb2cd, &h4594, _
	{&h96, &hea, &h5b, &h82, &h3, &hd2, &h14, &h39})

Type LPITEXTREADER As ITextReader Ptr

Type ITextReader As ITextReader_

Type ITextReaderVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim CloseTextReader As Function( _
		ByVal pITextReader As ITextReader Ptr _
	)As HRESULT
	
	Dim OpenTextReader As Function( _
		ByVal pITextReader As ITextReader Ptr _
	)As HRESULT
	
	Dim Peek As Function( _
		ByVal pITextReader As ITextReader Ptr, _
		ByVal pChar As Integer Ptr _
	)As HRESULT
	
	Dim ReadChar As Function( _
		ByVal pITextReader As ITextReader Ptr, _
		ByVal pChar As Integer Ptr _
	)As HRESULT
	
	Dim ReadCharArray As Function( _
		ByVal pITextReader As ITextReader Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal Index As Integer, _
		ByVal Count As Integer, _
		ByVal pReadedChars As Integer Ptr _
	)As HRESULT
	
	Dim ReadLine As Function( _
		ByVal pITextReader As ITextReader Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pLineLength As Integer Ptr _
	)As HRESULT
	
	Dim ReadToEnd As Function( _
		ByVal pITextReader As ITextReader Ptr, _
		ByVal Buffer As WString Ptr, _
		ByVal BufferLength As Integer, _
		ByVal pLineLength As Integer Ptr _
	)As HRESULT
	
End Type

Type ITextReader_
	Dim pVirtualTable As ITextReaderVirtualTable Ptr
End Type

#endif
