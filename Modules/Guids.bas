#include "Guids.bi"

#ifndef unicode
#define unicode
#endif

#include "windows.bi"
#include "win\ole2.bi"

' {9377B23F-E796-4CF9-9F36-3992C79F8A26}
DEFINE_CLSID(CLSID_REQUESTEDFILE, _
	&h9377b23f, &he796, &h4cf9, &h9f, &h36, &h39, &h92, &hc7, &h9f, &h8a, &h26 _
)

' {E9BE6663-1ED6-45A4-9090-01FF8A82AB99}
DEFINE_CLSID(CLSID_SERVERSTATE, _
	&he9be6663, &h1ed6, &h45a4, &h90, &h90, &h01, &hff, &h8a, &h82, &hab, &h99 _
)

' {EA837873-0F90-4DD6-838C-60391FCF293E}
DEFINE_CLSID(CLSID_WEBSERVER, _
	&hdec52339, &hcc4d, &h409d, &h93, &h1, &h21, &hc6, &hd5, &h22, &h9e, &h68 _
)

' {EA837873-0F90-4DD6-838C-60391FCF293E}
DEFINE_CLSID(CLSID_WEBSITECONTAINER, _
	&hea837873, &hf90, &h4dd6, &h83, &h8c, &h60, &h39, &h1f, &hcf, &h29, &h3e _
)

' {BC192A6D-7ACC-4219-A7AB-2900107366A4}
DEFINE_IID(IID_IArrayStringWriter, _
	&hbc192a6d, &h7acc, &h4219, &ha7, &hab, &h29, &h0, &h10, &h73, &h66, &ha4 _
)

' {01640F76-0385-43D3-8878-D6DED3B468D1}
DEFINE_IID(IID_IAsyncResult, _
	&h1640f76, &h385, &h43d3, &h88, &h78, &hd6, &hde, &hd3, &hb4, &h68, &hd1 _
)

' {B6AC4CEF-9B3D-4B41-B2F6-DEA27D085EB7}
DEFINE_IID(IID_IBaseStream, _
	&hb6ac4cef, &h9b3d, &h4b41, &hb2, &hf6, &hde, &ha2, &h7d, &h8, &h5e, &hb7 _
)

' {E998CAB4-5559-409C-93BC-97AFDF6A3921}
DEFINE_IID(IID_IClientRequest, _
	&he998cab4, &h5559, &h409c, &h93, &hbc, &h97, &haf, &hdf, &h6a, &h39, &h21 _
)

' {76A3EA34-6604-4126-9550-54280EAA291A}
DEFINE_IID(IID_IConfiguration, _
	&h76a3ea34, &h6604, &h4126, &h95, &h50, &h54, &h28, &he, &haa, &h29, &h1a _
)

' {C409DE11-C44F-4EF8-8A4C-4CE38C61C8E3}
DEFINE_IID(IID_IFileStream, _
	&hc409de11, &hc44f, &h4ef8, &h8a, &h4c, &h4c, &he3, &h8c, &h61, &hc8, &he3 _
)

' {D34D026F-D057-422F-9B32-C6D9424336F2}
DEFINE_IID(IID_IHttpReader, _
	&hd34d026f, &hd057, &h422f, &h9b, &h32, &hc6, &hd9, &h42, &h43, &h36, &hf2 _
)

' {A4C7EAED-5EC0-4B7C-81D2-05BE69E63A1F}
DEFINE_IID(IID_INetworkStream, _
	&ha4c7eaed, &h5ec0, &h4b7c, &h81, &hd2, &h5, &hbe, &h69, &he6, &h3a, &h1f _
)

' {A44A1AB3-A0D5-42E6-A4FF-ADBAE8CE3682}
DEFINE_IID(IID_IRequestedFile, _
	&ha44a1ab3, &ha0d5, &h42e6, &ha4, &hff, &had, &hba, &he8, &hce, &h36, &h82 _
)

' {6FA7FA73-6097-478F-BA06-C908C6AACFCC}
DEFINE_IID(IID_IRequestProcessor, _
	&h6fa7fa73, &h6097, &h478f, &hba, &h6, &hc9, &h8, &hc6, &haa, &hcf, &hcc _
)

' {6603A8F5-FB80-4CB9-BF80-CEADE4576F52}
DEFINE_IID(IID_IRunnable, _
	&h6603a8f5, &hfb80, &h4cb9, &hbf, &h80, &hce, &had, &he4, &h57, &h6f, &h52 _
)

' {E6C1A359-67A1-4B3D-A329-69001B3B8065}
DEFINE_IID(IID_ISendable, _
	&he6c1a359, &h67a1, &h4b3d, &ha3, &h29, &h69, &h0, &h1b, &h3b, &h80, &h65 _
)

' {C1BFB23D-79B3-4AE9-BEF9-5BF9D3073B84}
DEFINE_IID(IID_IServerResponse, _
	&hc1bfb23d, &h79b3, &h4ae9, &hbe, &hf9, &h5b, &hf9, &hd3, &h7, &h3b, &h84 _
)

' {226A7229-6122-45C4-AFFB-C7DEB403A13A}
DEFINE_IID(IID_IServerState, _
	&h226a7229, &h6122, &h45c4, &haf, &hfb, &hc7, &hde, &hb4, &h3, &ha1, &h3a _
)

' {C34BFD65-8D8D-486A-97A3-85ADA013F83D}
DEFINE_IID(IID_IStreamReader, _
	&hc34bfd65, &h8d8d, &h486a, &h97, &ha3, &h85, &had, &ha0, &h13, &hf8, &h3d _
)

' {2B67DF5D-D44E-4D1E-87BE-9609B1E2E10A}
DEFINE_IID(IID_IStreamWriter, _
	&h2b67df5d, &hd44e, &h4d1e, &h87, &hbe, &h96, &h9, &hb1, &he2, &he1, &ha _
)

' {286FF92C-2951-47BB-A4BB-09DA00A72725}
DEFINE_IID(IID_IStringable, _
	&h286ff92c, &h2951, &h47bb, &ha4, &hbb, &h9, &hda, &h0, &ha7, &h27, &h25 _
)

' {D46D4E27-B2CD-4594-96EA-5B8203D21439}
DEFINE_IID(IID_ITextReader, _
	&hd46d4e27, &hb2cd, &h4594, &h96, &hea, &h5b, &h82, &h3, &hd2, &h14, &h39 _
)

' {8F177D4A-A214-49D2-A752-0BF4CC000C1C}
DEFINE_IID(IID_ITextWriter, _
	&h8f177d4a, &ha214, &h49d2, &ha7, &h52, &hb, &hf4, &hcc, &h0, &hc, &h1c _
)

' {FA6493DA-9102-4FF6-822E-163399BF9E81}
DEFINE_IID(IID_IClientUri, _
	&hfa6493da, &h9102, &h4ff6, &h82, &h2e, &h16, &h33, &h99, &hbf, &h9e, &h81 _
)

' {DE416BE2-F7C8-40C6-81DF-44742D47F0F7}
DEFINE_IID(IID_IWebSite, _
	&hde416be2, &hf7c8, &h40c6, &h81, &hdf, &h44, &h74, &h2d, &h47, &hf0, &hf7 _
)

' {9042F178-B211-478B-8FF6-9C4133984364}
DEFINE_IID(IID_IWebSiteContainer, _
	&h9042f178, &hb211, &h478b, &h8f, &hf6, &h9c, &h41, &h33, &h98, &h43, &h64 _
)

