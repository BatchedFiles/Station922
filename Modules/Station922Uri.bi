#ifndef STATION922URI_BI
#define STATION922URI_BI

Type UserInfo
	pUserName As WString Ptr
	pPassword As WString Ptr
End Type

Type Authority
	Info As UserInfo
	pHost As WString Ptr
	pPort As WString Ptr
End Type

Type Station922Uri
	Const MaxUrlLength As Integer = 4096 - 1
	
	'Scheme As WString Ptr
	'Authority As Authority
	pUrl As WString Ptr
	Path As WString * (MaxUrlLength + 1)
	pQueryString As WString Ptr
	pFragment As WString Ptr
	
	Declare Function PathDecode( _
		ByVal Buffer As WString Ptr _
	)As Integer
	
End Type

Declare Sub InitializeURI( _
	ByVal pURI As Station922Uri Ptr _
)

/'
            userinfo          host        port
        --------+-------¬ -----+--------¬ -+¬ 
https://john.doe:password@www.example.com:123/forum/questions/?tag=networking&order=newest#top
L-T-- L-------T------------------------------L-T--------------L--T------------------------LT--  
scheme     authority                          path              query                      fragment

'/

/'
Type Station922Uri
	Const MaxUrlLength As Integer = 4096 - 1
	
	Scheme As WString Ptr
	Authority As Authority
	Path As WString Ptr
	Query As WString Ptr
	Fragment As WString Ptr
	
	Declare Sub PathDecode( _
		ByVal Buffer As WString Ptr _
	)
	
End Type
'/

#endif
