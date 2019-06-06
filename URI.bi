#ifndef URI_BI
#define URI_BI

/'
        userinfo     host        port
        ┌─┴────┐ ┌────┴────────┐ ┌┴┐ 
https://john.doe@www.example.com:123/forum/questions/?tag=networking&order=newest#top
└─┬─┘ └───────┬────────────────────┘└─┬─────────────┘└──┬───────────────────────┘└┬─┘  
scheme     authority                 path              query                      fragment

'/

Type Authority
	Dim UserName As WString Ptr
	Dim Password As WString Ptr
	Dim Host As WString Ptr
	Dim Port As WString Ptr
End Type

/'
Type Uri
	Const MaxUrlLength As Integer = 4096 - 1
	
	Dim Scheme As WString Ptr
	Dim Authority As Authority
	Dim Path As WString Ptr
	Dim Query As WString Ptr
	Dim Fragment As WString Ptr
	
	Declare Sub PathDecode( _
		ByVal Buffer As WString Ptr _
	)
	
End Type
'/

Type URI
	Const MaxUrlLength As Integer = 4096 - 1
	
	Dim Scheme As WString Ptr
	Dim Authority As Authority
	Dim Url As WString Ptr
	Dim Path As WString * (MaxUrlLength + 1)
	Dim QueryString As WString Ptr
	Dim Fragment As WString Ptr
	
	Declare Sub PathDecode( _
		ByVal Buffer As WString Ptr _
	)
	
End Type

Declare Sub InitializeURI( _
	ByVal pURI As URI Ptr _
)

#endif
