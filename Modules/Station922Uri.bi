#ifndef STATION922URI_BI
#define STATION922URI_BI

#include once "windows.bi"

Const STATION922URI_E_URITOOLARGE As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0201)
Const STATION922URI_E_BADPATH As HRESULT = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_ITF, &h0202)

/'
        userinfo       host      port
        ┌──┴───┐ ┌──────┴──────┐ ┌┴┐
https://john.doe@www.example.com:123/forum/questions/?tag=networking&order=newest#top
└─┬─┘   └───────────┬──────────────┘└───────┬───────┘ └───────────┬─────────────┘ └┬┘
scheme          authority                  path                 query           fragment

'/

Type UserInfo
	UserName As WString Ptr
	Password As WString Ptr
End Type

Type Authority
	Info As UserInfo
	Host As WString Ptr
	Port As WString Ptr
End Type

Const URI_BUFFER_CAPACITY As Integer = (2 * 4096) \ SizeOf(WString) - SizeOf(Authority) \ SizeOf(WString) - (4 * SizeOf(WString Ptr)) \ SizeOf(WString) - SizeOf(WString)

Type Station922Uri
	Uri As WString * (URI_BUFFER_CAPACITY + 1)
	Scheme As WString Ptr
	Authority As Authority
	Path As WString Ptr
	Query As WString Ptr
	Fragment As WString Ptr
End Type

Declare Sub Station922UriInitialize( _
	ByVal pURI As Station922Uri Ptr _
)

Declare Function Station922UriSetUri( _
	ByVal pURI As Station922Uri Ptr, _
	ByVal UriString As WString Ptr _
)As HRESULT

#endif
