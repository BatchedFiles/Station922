#ifndef ISTREAMREADER_BI
#define ISTREAMREADER_BI

#include "ITextReader.bi"

' {C34BFD65-8D8D-486A-97A3-85ADA013F83D}
Dim Shared IID_ISTREAMREADER As IID = Type(&hc34bfd65, &h8d8d, &h486a, _
	{&h97, &ha3, &h85, &had, &ha0, &h13, &hf8, &h3d})

Type LPISTREAMREADER As IStreamReader Ptr

Type IStreamReader As IStreamReader_

Type IStreamReaderVirtualTable
	Dim InheritedTable As ITextReaderVirtualTable
	
End Type

Type IStreamReader_
	Dim pVirtualTable As IStreamReaderVirtualTable Ptr
End Type

#endif
