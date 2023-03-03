#include once "windows.bi"

#ifndef DEFINE_GUID
#define DEFINE_GUID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As Const GUID : _ 
	Dim n As Const GUID = Type(l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#endif

#ifndef DEFINE_IID
#define DEFINE_IID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As Const IID : _ 
	Dim n As Const IID = Type(l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#endif

#ifndef DEFINE_CLSID
#define DEFINE_CLSID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As Const CLSID : _ 
	Dim n As Const CLSID = Type(l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#endif

#ifndef DEFINE_LIBID
#define DEFINE_LIBID(n, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) Extern n Alias #n As Const GUID : _ 
	Dim n As Const GUID = Type(l, w1, w2, {b1, b2, b3, b4, b5, b6, b7, b8})
#endif

' {00000000-0000-0000-C000-000000000046}
DEFINE_IID(IID_IUnknown, _
	&h00000000, &h0000, &h0000, &hC0, &h00, &h00, &h00, &h00, &h00, &h00, &h46 _
)

' {00000002-0000-0000-C000-000000000046}
DEFINE_IID(IID_IMalloc, _
	&h00000002, &h0000, &h0000, &hC0, &h00, &h00, &h00, &h00, &h00, &h00, &h46 _
)
