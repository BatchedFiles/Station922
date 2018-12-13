#ifndef IREQUESTPROCESSOR_BI
#define IREQUESTPROCESSOR_BI

#include "IWebSite.bi"
#include "IClientRequest.bi"
#include "IHttpReader.bi"
#include "INetworkStream.bi"

' {6FA7FA73-6097-478F-BA06-C908C6AACFCC}
Dim Shared IID_IREQUESTPROCESSOR As IID = Type(&h6fa7fa73, &h6097, &h478f, _
	{&hba, &h6, &hc9, &h8, &hc6, &haa, &hcf, &hcc})

Type LPIREQUESTPROCESSOR As IRequestProcessor Ptr

Type IRequestProcessor As IRequestProcessor_

Type IRequestProcessorVirtualTable
	Dim InheritedTable As IUnknownVtbl
	
	Dim Process As Function( _
		ByVal this As IRequestProcessor Ptr, _
		ByVal pIWebSite As IWebSite Ptr, _
		ByVal pIRequest As IClientRequest Ptr, _
		ByVal pIHttpReader As IHttpReader Ptr, _
		ByVal pIWriter As INetworkStream Ptr, _
		ByVal dwError As DWORD _
	)As HRESULT
End Type

Type IRequestProcessor_
	Dim pVirtualTable As IRequestProcessorVirtualTable Ptr
End Type

#endif
