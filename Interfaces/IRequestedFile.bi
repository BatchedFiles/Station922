#ifndef IREQUESTEDFILE_BI
#define IREQUESTEDFILE_BI

#include "IClientRequest.bi"

' {A44A1AB3-A0D5-42E6-A4FF-ADBAE8CE3682}
Dim Shared IID_IREQUESTEDFILE As IID = Type(&ha44a1ab3, &ha0d5, &h42e6, _
	{&ha4, &hff, &had, &hba, &he8, &hce, &h36, &h82})

Type LPIREQUESTEDFILE As IRequestedFile Ptr

Type IRequestedFile As IRequestedFile_

Type IRequestedFileVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim ChoiseFile As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pClientRequest As IClientRequest Ptr _
	)As HRESULT
	
	Dim FileExists As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As Boolean Ptr _
	)As HRESULT
	
	Dim GetFileHandle As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As HANDLE Ptr _
	)As HRESULT
	
	Dim GetLastFileModifiedDate As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As FILETIME Ptr _
	)As HRESULT
	
	Dim GetFileLength As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pResult As ULongInt Ptr _
	)As HRESULT
	
	Dim GetVaryHeaders As Function( _
		ByVal this As IRequestedFile Ptr, _
		ByVal pHeadersLength As Integer Ptr, _
		ByVal pHeaders As HttpRequestHeaders Ptr Ptr _
	)As HRESULT
	
End Type

Type IRequestedFile_
	Dim pVirtualTable As IRequestedFileVirtualTable Ptr
End Type

#endif
