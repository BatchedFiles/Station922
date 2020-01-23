#ifndef STATION922URI_BI
#define STATION922URI_BI

Type UserInfo
	Dim pUserName As WString Ptr
	Dim pPassword As WString Ptr
End Type

Type Authority
	Dim Info As UserInfo
	Dim pHost As WString Ptr
	Dim pPort As WString Ptr
End Type

Type Station922Uri
	Const MaxUrlLength As Integer = 4096 - 1
	
	'Dim Scheme As WString Ptr
	'Dim Authority As Authority
	Dim pUrl As WString Ptr
	Dim Path As WString * (MaxUrlLength + 1)
	Dim pQueryString As WString Ptr
	Dim pFragment As WString Ptr
	
	Declare Function PathDecode( _
		ByVal Buffer As WString Ptr _
	)As Integer
	
End Type

Declare Sub InitializeURI( _
	ByVal pURI As Station922Uri Ptr _
)

/'
            userinfo          host        port
        ┌───────┴───────┐ ┌────┴────────┐ ┌┴┐ 
https://john.doe:password@www.example.com:123/forum/questions/?tag=networking&order=newest#top
└─┬─┘ └───────┬─────────────────────────────┘└─┬─────────────┘└──┬───────────────────────┘└┬─┘  
scheme     authority                          path              query                      fragment

'/

/'
Type Station922Uri
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

#endif
