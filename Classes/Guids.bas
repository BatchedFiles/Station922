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

' {BAA2C5A2-E3D0-4AA4-BA7E-E7D13E3FA68D}
DEFINE_CLSID(CLSID_ARRAYSTRINGWRITER, _
	&hbaa2c5a2, &he3d0, &h4aa4, &hba, &h7e, &he7, &hd1, &h3e, &h3f, &ha6, &h8d _
)

' {BD54524E-FFA8-4182-817D-9D10F90A2B5B}
DEFINE_CLSID(CLSID_ASYNCRESULT, _
	&hBD54524E, &hFFA8, &h4182, &h81, &h7D, &h9D, &h10, &hF9, &h0A, &h2B, &h5B _
)

' {F103EB8A-22EC-4A4F-AB51-CBE7DE29B354}
DEFINE_CLSID(CLSID_CLIENTCONTEXT, _
	&hf103eb8a, &h22ec, &h4a4f, &hab, &h51, &hcb, &he7, &hde, &h29, &hb3, &h54 _
)

' {FB96C7A7-1B31-4351-A300-C17F30D1AF3C}
DEFINE_CLSID(CLSID_CLIENTREQUEST, _
	&hfb96c7a7, &h1b31, &h4351, &ha3, &h0, &hc1, &h7f, &h30, &hd1, &haf, &h3c _
)

' {345FC692-3557-487B-8986-F4D0E85C079E}
DEFINE_CLSID(CLSID_CLIENTURI, _
	&h345fc692, &h3557, &h487b, &h89, &h86, &hf4, &hd0, &he8, &h5c, &h7, &h9e _
)

' {EAE5C3F4-50D3-4E0F-843D-A6F838C5FA5C}
DEFINE_CLSID(CLSID_HEAPBSTR, _
	&heae5c3f4, &h50d3, &h4e0f, &h84, &h3d, &ha6, &hf8, &h38, &hc5, &hfa, &h5c _
)

' {48744EFA-75A5-4873-AD7E-AEC4F1AE3D6B}
DEFINE_CLSID(CLSID_HEAPMEMORYALLOCATOR, _
	&h48744efa, &h75a5, &h4873, &had, &h7e, &hae, &hc4, &hf1, &hae, &h3d, &h6b _
)

' {ECF4A262-2CFC-4FB3-91F0-67D2945ADFA6}
DEFINE_CLSID(CLSID_HTTPGETASYNCPROCESSOR, _
	&hecf4a262, &h2cfc, &h4fb3, &h91, &hf0, &h67, &hd2, &h94, &h5a, &hdf, &ha6 _
)

' {D040BF22-34E8-489F-9914-0A5C77FDCD44}
DEFINE_CLSID(CLSID_HTTPPROCESSORCOLLECTION, _
	&hd040bf22, &h34e8, &h489f, &h99, &h14, &ha, &h5c, &h77, &hfd, &hcd, &h44 _
)

' {080EB706-1D70-428E-819E-4BCA42154212}
DEFINE_CLSID(CLSID_HTTPREADER, _
	&h80eb706, &h1d70, &h428e, &h81, &h9e, &h4b, &hca, &h42, &h15, &h42, &h12 _
)

' {361758F9-2F6A-414B-AB88-4D7B1EC46C5F}
DEFINE_CLSID(CLSID_NETWORKSTREAM, _
	&h361758f9, &h2f6a, &h414b, &hab, &h88, &h4d, &h7b, &h1e, &hc4, &h6c, &h5f _
)

' {54E0F796-8CAA-4F4B-8C5F-2C614207ED8E}
DEFINE_CLSID(CLSID_READREQUESTASYNCTASK, _
	&h54e0f796, &h8caa, &h4f4b, &h8c, &h5f, &h2c, &h61, &h42, &h7, &hed, &h8e _
)

' {9377B23F-E796-4CF9-9F36-3992C79F8A26}
DEFINE_CLSID(CLSID_REQUESTEDFILE, _
	&h9377b23f, &he796, &h4cf9, &h9f, &h36, &h39, &h92, &hc7, &h9f, &h8a, &h26 _
)

' {033C9EB2-AB1F-4AC1-A641-B54D4A9C83D7}
DEFINE_CLSID(CLSID_SERVERRESPONSE, _
	&h33c9eb2, &hab1f, &h4ac1, &ha6, &h41, &hb5, &h4d, &h4a, &h9c, &h83, &hd7 _
)

' {E9BE6663-1ED6-45A4-9090-01FF8A82AB99}
DEFINE_CLSID(CLSID_SERVERSTATE, _
	&he9be6663, &h1ed6, &h45a4, &h90, &h90, &h01, &hff, &h8a, &h82, &hab, &h99 _
)

' {EE0793B6-B903-4C0F-8205-AB8A13D22316}
DEFINE_CLSID(CLSID_THREADPOOL, _
	&hee0793b6, &hb903, &h4c0f, &h82, &h5, &hab, &h8a, &h13, &hd2, &h23, &h16 _
)

' {EA837873-0F90-4DD6-838C-60391FCF293E}
DEFINE_CLSID(CLSID_WEBSERVER, _
	&hdec52339, &hcc4d, &h409d, &h93, &h1, &h21, &hc6, &hd5, &h22, &h9e, &h68 _
)

' {190A5653-1F53-4FAD-A8CC-8E3998926514}
DEFINE_CLSID(CLSID_WEBSERVERINICONFIGURATION, _
	&h190a5653, &h1f53, &h4fad, &ha8, &hcc, &h8e, &h39, &h98, &h92, &h65, &h14 _
)

' {AB26908E-C919-4D74-8C2C-78E70D11423C}
DEFINE_CLSID(CLSID_WEBSITE, _
	&hab26908e, &hc919, &h4d74, &h8c, &h2c, &h78, &he7, &hd, &h11, &h42, &h3c _
)

' {EA837873-0F90-4DD6-838C-60391FCF293E}
DEFINE_CLSID(CLSID_WEBSITECOLLECTION, _
	&hea837873, &hf90, &h4dd6, &h83, &h8c, &h60, &h39, &h1f, &hcf, &h29, &h3e _
)

' {D1185FAE-8A30-4519-A532-5A37BEA6AD4D}
DEFINE_CLSID(CLSID_WORKERTHREADCONTEXT, _
	&hd1185fae, &h8a30, &h4519, &ha5, &h32, &h5a, &h37, &hbe, &ha6, &had, &h4d _
)

' {BBA17F8D-AC89-4491-898A-72F3BBF80552}
DEFINE_CLSID(CLSID_WRITEERRORASYNCTASK, _
	&hbba17f8d, &hac89, &h4491, &h89, &h8a, &h72, &hf3, &hbb, &hf8, &h5, &h52 _
)

' {6D9085B7-2309-4C33-AB53-9D8ECAB607C3}
DEFINE_CLSID(CLSID_WRITERESPONSEASYNCTASK, _
	&h6d9085b7, &h2309, &h4c33, &hab, &h53, &h9d, &h8e, &hca, &hb6, &h7, &hc3 _
)
' {BC192A6D-7ACC-4219-A7AB-2900107366A4}
DEFINE_IID(IID_IArrayStringWriter, _
	&hbc192a6d, &h7acc, &h4219, &ha7, &hab, &h29, &h0, &h10, &h73, &h66, &ha4 _
)

' {01640F76-0385-43D3-8878-D6DED3B468D1}
DEFINE_IID(IID_IAsyncResult, _
	&h1640f76, &h385, &h43d3, &h88, &h78, &hd6, &hde, &hd3, &hb4, &h68, &hd1 _
)

' {53989192-3F47-4309-A582-8AE24C03C9B3}
DEFINE_IID(IID_IAsyncIoTask, _
	&h53989192, &h3f47, &h4309, &ha5, &h82, &h8a, &he2, &h4c, &h3, &hc9, &hb3 _
)

' {B6AC4CEF-9B3D-4B41-B2F6-DEA27D085EB7}
DEFINE_IID(IID_IBaseStream, _
	&hb6ac4cef, &h9b3d, &h4b41, &hb2, &hf6, &hde, &ha2, &h7d, &h8, &h5e, &hb7 _
)

' {DBFDAAD7-BEB7-4551-A432-FD87DCA6E7CD}
DEFINE_IID(IID_IClientContext, _
	&hdbfdaad7, &hbeb7, &h4551, &ha4, &h32, &hfd, &h87, &hdc, &ha6, &he7, &hcd _
)

' {E998CAB4-5559-409C-93BC-97AFDF6A3921}
DEFINE_IID(IID_IClientRequest, _
	&he998cab4, &h5559, &h409c, &h93, &hbc, &h97, &haf, &hdf, &h6a, &h39, &h21 _
)

' {FA6493DA-9102-4FF6-822E-163399BF9E81}
DEFINE_IID(IID_IClientUri, _
	&hfa6493da, &h9102, &h4ff6, &h82, &h2e, &h16, &h33, &h99, &hbf, &h9e, &h81 _
)

' {606E6533-1086-409E-A91C-93A88CF78B35}
DEFINE_IID(IID_ICloneable, _
	&h606e6533, &h1086, &h409e, &ha9, &h1c, &h93, &ha8, &h8c, &hf7, &h8b, &h35 _
)

' {76A3EA34-6604-4126-9550-54280EAA291A}
DEFINE_IID(IID_IEnumWebServerConfiguration, _
	&h76a3ea34, &h6604, &h4126, &h95, &h50, &h54, &h28, &he, &haa, &h29, &h1a _
)

' {9042F178-B211-478B-8FF6-9C4133984364}
DEFINE_IID(IID_IEnumWebSite, _
	&h9042f178, &hb211, &h478b, &h8f, &hf6, &h9c, &h41, &h33, &h98, &h43, &h64 _
)

' {C409DE11-C44F-4EF8-8A4C-4CE38C61C8E3}
DEFINE_IID(IID_IFileStream, _
	&hc409de11, &hc44f, &h4ef8, &h8a, &h4c, &h4c, &he3, &h8c, &h61, &hc8, &he3 _
)

' {6C7428A7-2E13-453C-90E9-534281710B85}
DEFINE_IID(IID_IHeapMemoryAllocator, _
	&h6c7428a7, &h2e13, &h453c, &h90, &he9, &h53, &h42, &h81, &h71, &hb, &h85 _
)

' {F1683D2F-C33F-4D2F-B536-E88A609BC9FC}
DEFINE_IID(IID_IHttpAsyncIoTask, _
	&hf1683d2f, &hc33f, &h4d2f, &hb5, &h36, &he8, &h8a, &h60, &h9b, &hc9, &hfc _
)

' {6FA7FA73-6097-478F-BA06-C908C6AACFCC}
DEFINE_IID(IID_IHttpAsyncProcessor, _
	&h6fa7fa73, &h6097, &h478f, &hba, &h6, &hc9, &h8, &hc6, &haa, &hcf, &hcc _
)

' {D596BBD2-86F2-4850-A807-34DA01953D61}

DEFINE_IID(IID_IHttpGetAsyncProcessor, _
	&hd596bbd2, &h86f2, &h4850, &ha8, &h7, &h34, &hda, &h1, &h95, &h3d, &h61 _
)

' {7C6F76B6-989B-4995-B312-AAC3DEEC673D}
DEFINE_IID(IID_IHttpProcessorCollection, _
	&h7c6f76b6, &h989b, &h4995, &hb3, &h12, &haa, &hc3, &hde, &hec, &h67, &h3d _
)

' {D34D026F-D057-422F-9B32-C6D9424336F2}
DEFINE_IID(IID_IHttpReader, _
	&hd34d026f, &hd057, &h422f, &h9b, &h32, &hc6, &hd9, &h42, &h43, &h36, &hf2 _
)

' {561C56F8-3D13-45C2-A10E-2C971347D8A7}
DEFINE_IID(IID_IMutableAsyncResult, _
	&h561c56f8, &h3d13, &h45c2, &ha1, &he, &h2c, &h97, &h13, &h47, &hd8, &ha7 _
)

' {3B2C4524-DB79-4D15-ACF5-576A7FE343B7}
DEFINE_IID(IID_IMutableHttpProcessorCollection, _
	&h3b2c4524, &hdb79, &h4d15, &hac, &hf5, &h57, &h6a, &h7f, &he3, &h43, &hb7 _
)

' {FD8CC1E3-E4E0-4E11-87DF-903D193D1F84}
DEFINE_IID(IID_IMutableWebSite, _
	&hfd8cc1e3, &he4e0, &h4e11, &h87, &hdf, &h90, &h3d, &h19, &h3d, &h1f, &h84 _
)

' {86629567-EA4F-47C5-926A-17860A4887D9}
DEFINE_IID(IID_IMutableWebSiteCollection, _
	&h86629567, &hea4f, &h47c5, &h92, &h6a, &h17, &h86, &ha, &h48, &h87, &hd9 _
)

' {A4C7EAED-5EC0-4B7C-81D2-05BE69E63A1F}
DEFINE_IID(IID_INetworkStream, _
	&ha4c7eaed, &h5ec0, &h4b7c, &h81, &hd2, &h5, &hbe, &h69, &he6, &h3a, &h1f _
)

' {277ECE2A-2962-467F-AF0E-B12B2F1D40AB}
DEFINE_IID(IID_IPrivateHeapMemoryAllocatorClassFactory, _
	&h277ece2a, &h2962, &h467f, &haf, &he, &hb1, &h2b, &h2f, &h1d, &h40, &hab _
)

' {82B525C1-E266-4317-9FA5-F8B19DF8C73C}
DEFINE_IID(IID_IReadRequestAsyncIoTask, _
	&h82b525c1, &he266, &h4317, &h9f, &ha5, &hf8, &hb1, &h9d, &hf8, &hc7, &h3c _
)

' {A44A1AB3-A0D5-42E6-A4FF-ADBAE8CE3682}
DEFINE_IID(IID_IRequestedFile, _
	&ha44a1ab3, &ha0d5, &h42e6, &ha4, &hff, &had, &hba, &he8, &hce, &h36, &h82 _
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

' {D38929B0-17C1-47A2-A1AC-B07318B4C3C9}
DEFINE_IID(IID_IString, _
	&hd38929b0, &h17c1, &h47a2, &ha1, &hac, &hb0, &h73, &h18, &hb4, &hc3, &hc9 _
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

' {667DFC1A-466E-40BF-BEE3-7A34882BE2F9}
DEFINE_IID(IID_IThreadPool, _
	&h667dfc1a, &h466e, &h40bf, &hbe, &he3, &h7a, &h34, &h88, &h2b, &he2, &hf9 _
)

' {204A5587-12AC-4CE2-A438-B1F8049FD66E}
DEFINE_IID(IID_IWebServerConfiguration, _
	&h204a5587, &h12ac, &h4ce2, &ha4, &h38, &hb1, &hf8, &h4, &h9f, &hd6, &h6e _
)

' {DE416BE2-F7C8-40C6-81DF-44742D47F0F7}
DEFINE_IID(IID_IWebSite, _
	&hde416be2, &hf7c8, &h40c6, &h81, &hdf, &h44, &h74, &h2d, &h47, &hf0, &hf7 _
)

' {146ED9B9-B372-4F53-BC1A-AD31380633DA}
DEFINE_IID(IID_IWebSiteCollection, _
	&h146ed9b9, &hb372, &h4f53, &hbc, &h1a, &had, &h31, &h38, &h6, &h33, &hda _
)

' {263066C6-31B4-42EF-8982-6B58994E2D8F}
DEFINE_IID(IID_IWorkerThreadContext, _
	&h263066c6, &h31b4, &h42ef, &h89, &h82, &h6b, &h58, &h99, &h4e, &h2d, &h8f _
)

' {6964B4FE-BDAE-4B3B-BDF8-6C467BF35BFA}
DEFINE_IID(IID_IWriteErrorAsyncIoTask, _
	&h6964b4fe, &hbdae, &h4b3b, &hbd, &hf8, &h6c, &h46, &h7b, &hf3, &h5b, &hfa _
)

' {7BCB2D1D-0AA0-47EE-8420-594AD4378C94}
DEFINE_IID(IID_IWriteResponseAsyncIoTask, _
	&h7bcb2d1d, &haa0, &h47ee, &h84, &h20, &h59, &h4a, &hd4, &h37, &h8c, &h94 _
)
