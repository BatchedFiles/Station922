#ifndef ISTREAMREADER_BI
#define ISTREAMREADER_BI

#include once "ITextReader.bi"

Type LPISTREAMREADER As IStreamReader Ptr

Type IStreamReader As IStreamReader_

Extern IID_IStreamReader Alias "IID_IStreamReader" As Const IID

Type IStreamReaderVirtualTable
	InheritedTable As ITextReaderVirtualTable
	
End Type

Type IStreamReader_
	lpVtbl As IStreamReaderVirtualTable Ptr
End Type

#endif
