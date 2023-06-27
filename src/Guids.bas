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

#ifdef WITHOUT_RUNTIME

' {00000000-0000-0000-C000-000000000046}
DEFINE_IID(IID_IUnknown, _
	&h00000000, &h0000, &h0000, &hC0, &h00, &h00, &h00, &h00, &h00, &h00, &h46 _
)

' {00000002-0000-0000-C000-000000000046}
DEFINE_IID(IID_IMalloc, _
	&h00000002, &h0000, &h0000, &hC0, &h00, &h00, &h00, &h00, &h00, &h00, &h46 _
)

#endif

DEFINE_GUID(GUID_WSAID_ACCEPTEX, _
	&hb5367df1, &hcbac, &h11cf, &h95, &hca, &h00, &h80, &h5f, &h48, &ha1, &h92 _
)

DEFINE_GUID(GUID_WSAID_GETACCEPTEXSOCKADDRS, _
	&hb5367df2, &hcbac, &h11cf, &h95, &hca, &h00, &h80, &h5f, &h48, &ha1, &h92 _
)

DEFINE_GUID(GUID_WSAID_TRANSMITPACKETS, _
	&hd9689da0, &h1f90, &h11d3, &h99, &h71, &h00, &hc0, &h4f, &h68, &hc8, &h76 _
)

' {B40214BB-DFB6-4ACE-ACF4-8A66700F7CD0}
DEFINE_CLSID(CLSID_ACCEPTCONNECTIONASYNCTASK, _
	&hb40214bb, &hdfb6, &h4ace, &hac, &hf4, &h8a, &h66, &h70, &hf, &h7c, &hd0 _
)

' {BD54524E-FFA8-4182-817D-9D10F90A2B5B}
DEFINE_CLSID(CLSID_ASYNCRESULT, _
	&hBD54524E, &hFFA8, &h4182, &h81, &h7D, &h9D, &h10, &hF9, &h0A, &h2B, &h5B _
)

' {FB96C7A7-1B31-4351-A300-C17F30D1AF3C}
DEFINE_CLSID(CLSID_CLIENTREQUEST, _
	&hfb96c7a7, &h1b31, &h4351, &ha3, &h0, &hc1, &h7f, &h30, &hd1, &haf, &h3c _
)

' {345FC692-3557-487B-8986-F4D0E85C079E}
DEFINE_CLSID(CLSID_CLIENTURI, _
	&h345fc692, &h3557, &h487b, &h89, &h86, &hf4, &hd0, &he8, &h5c, &h7, &h9e _
)

' {9377B23F-E796-4CF9-9F36-3992C79F8A26}
DEFINE_CLSID(CLSID_FILESTREAM, _
	&h9377b23f, &he796, &h4cf9, &h9f, &h36, &h39, &h92, &hc7, &h9f, &h8a, &h26 _
)

' {EAE5C3F4-50D3-4E0F-843D-A6F838C5FA5C}
DEFINE_CLSID(CLSID_HEAPBSTR, _
	&heae5c3f4, &h50d3, &h4e0f, &h84, &h3d, &ha6, &hf8, &h38, &hc5, &hfa, &h5c _
)

' {48744EFA-75A5-4873-AD7E-AEC4F1AE3D6B}
DEFINE_CLSID(CLSID_HEAPMEMORYALLOCATOR, _
	&h48744efa, &h75a5, &h4873, &had, &h7e, &hae, &hc4, &hf1, &hae, &h3d, &h6b _
)

' {811EA582-2582-4681-83A4-DB2729DAF67C}
DEFINE_CLSID(CLSID_SERVERHEAPMEMORYALLOCATOR, _
	&h811ea582, &h2582, &h4681, &h83, &ha4, &hdb, &h27, &h29, &hda, &hf6, &h7c _
)

' {8681E6ED-776C-4BBA-884C-548B911EAADC}
DEFINE_GUID(CLSID_HTTPOPTIONSASYNCPROCESSOR, _
	&h8681e6ed, &h776c, &h4bba, &h88, &h4c, &h54, &h8b, &h91, &h1e, &haa, &hdc _
)

' {C9AE60EB-85CF-4F2D-A69B-F60DFC3F8117}
DEFINE_GUID(CLSID_HTTPDELETEASYNCPROCESSOR, _
	&hc9ae60eb, &h85cf, &h4f2d, &ha6, &h9b, &hf6, &hd, &hfc, &h3f, &h81, &h17 _
)

' {ECF4A262-2CFC-4FB3-91F0-67D2945ADFA6}
DEFINE_CLSID(CLSID_HTTPGETASYNCPROCESSOR, _
	&hecf4a262, &h2cfc, &h4fb3, &h91, &hf0, &h67, &hd2, &h94, &h5a, &hdf, &ha6 _
)

' {D040BF22-34E8-489F-9914-0A5C77FDCD44}
DEFINE_CLSID(CLSID_HTTPPROCESSORCOLLECTION, _
	&hd040bf22, &h34e8, &h489f, &h99, &h14, &ha, &h5c, &h77, &hfd, &hcd, &h44 _
)

' {C7ABA4AC-C9EE-456D-AB60-9C332DDCB2F5}
DEFINE_CLSID(CLSID_HTTPPUTASYNCPROCESSOR, _
	&hc7aba4ac, &hc9ee, &h456d, &hab, &h60, &h9c, &h33, &h2d, &hdc, &hb2, &hf5 _
)

' {080EB706-1D70-428E-819E-4BCA42154212}
DEFINE_CLSID(CLSID_HTTPREADER, _
	&h80eb706, &h1d70, &h428e, &h81, &h9e, &h4b, &hca, &h42, &h15, &h42, &h12 _
)


' {EE548635-A2D8-43E3-BCB5-FC8BA0A2982E}
DEFINE_CLSID(CLSID_HTTPTRACEASYNCPROCESSOR, _
	&hee548635, &ha2d8, &h43e3, &hbc, &hb5, &hfc, &h8b, &ha0, &ha2, &h98, &h2e _
)

' {CA5DD19B-D8A6-467D-8919-CB419E0E8024}
DEFINE_CLSID(CLSID_HTTPWRITER, _
	&hca5dd19b, &hd8a6, &h467d, &h89, &h19, &hcb, &h41, &h9e, &he, &h80, &h24 _
)

' {190A5653-1F53-4FAD-A8CC-8E3998926514}
DEFINE_CLSID(CLSID_INICONFIGURATION, _
	&h190a5653, &h1f53, &h4fad, &ha8, &hcc, &h8e, &h39, &h98, &h92, &h65, &h14 _
)

' {381E6704-C5E4-40AB-9863-C420B6DE25D7}
DEFINE_CLSID(CLSID_MEMORYSTREAM, _
	&h381e6704, &hc5e4, &h40ab, &h98, &h63, &hc4, &h20, &hb6, &hde, &h25, &hd7 _
)

' {361758F9-2F6A-414B-AB88-4D7B1EC46C5F}
DEFINE_CLSID(CLSID_NETWORKSTREAM, _
	&h361758f9, &h2f6a, &h414b, &hab, &h88, &h4d, &h7b, &h1e, &hc4, &h6c, &h5f _
)

' {54E0F796-8CAA-4F4B-8C5F-2C614207ED8E}
DEFINE_CLSID(CLSID_READREQUESTASYNCTASK, _
	&h54e0f796, &h8caa, &h4f4b, &h8c, &h5f, &h2c, &h61, &h42, &h7, &hed, &h8e _
)

' {033C9EB2-AB1F-4AC1-A641-B54D4A9C83D7}
DEFINE_CLSID(CLSID_SERVERRESPONSE, _
	&h33c9eb2, &hab1f, &h4ac1, &ha6, &h41, &hb5, &h4d, &h4a, &h9c, &h83, &hd7 _
)

' {304ED50E-CBA9-44AF-B396-11E1E88688A8}
DEFINE_CLSID(CLSID_TCPLISTENER, _
	&h304ed50e, &hcba9, &h44af, &hb3, &h96, &h11, &he1, &he8, &h86, &h88, &ha8 _
)

' {EE0793B6-B903-4C0F-8205-AB8A13D22316}
DEFINE_CLSID(CLSID_THREADPOOL, _
	&hee0793b6, &hb903, &h4c0f, &h82, &h5, &hab, &h8a, &h13, &hd2, &h23, &h16 _
)

' {EA837873-0F90-4DD6-838C-60391FCF293E}
DEFINE_CLSID(CLSID_WEBSERVER, _
	&hdec52339, &hcc4d, &h409d, &h93, &h1, &h21, &hc6, &hd5, &h22, &h9e, &h68 _
)

' {AB26908E-C919-4D74-8C2C-78E70D11423C}
DEFINE_CLSID(CLSID_WEBSITE, _
	&hab26908e, &hc919, &h4d74, &h8c, &h2c, &h78, &he7, &hd, &h11, &h42, &h3c _
)

' {EA837873-0F90-4DD6-838C-60391FCF293E}
DEFINE_CLSID(CLSID_WEBSITECOLLECTION, _
	&hea837873, &hf90, &h4dd6, &h83, &h8c, &h60, &h39, &h1f, &hcf, &h29, &h3e _
)

' {BBA17F8D-AC89-4491-898A-72F3BBF80552}
DEFINE_CLSID(CLSID_WRITEERRORASYNCTASK, _
	&hbba17f8d, &hac89, &h4491, &h89, &h8a, &h72, &hf3, &hbb, &hf8, &h5, &h52 _
)

' {6D9085B7-2309-4C33-AB53-9D8ECAB607C3}
DEFINE_CLSID(CLSID_WRITERESPONSEASYNCTASK, _
	&h6d9085b7, &h2309, &h4c33, &hab, &h53, &h9d, &h8e, &hca, &hb6, &h7, &hc3 _
)

' {9A15537E-64B6-4470-80EC-C3348C968C55}
DEFINE_IID(IID_IAcceptConnectionAsyncIoTask, _
	&h9a15537e, &h64b6, &h4470, &h80, &hec, &hc3, &h34, &h8c, &h96, &h8c, &h55 _
)

' {01640F76-0385-43D3-8878-D6DED3B468D1}
DEFINE_IID(IID_IAsyncResult, _
	&h1640f76, &h385, &h43d3, &h88, &h78, &hd6, &hde, &hd3, &hb4, &h68, &hd1 _
)

' {53989192-3F47-4309-A582-8AE24C03C9B3}
DEFINE_IID(IID_IAsyncIoTask, _
	&h53989192, &h3f47, &h4309, &ha5, &h82, &h8a, &he2, &h4c, &h3, &hc9, &hb3 _
)

' {FAC287DE-4E2C-4F51-8E7E-B0B77E2AE918}
DEFINE_IID(IID_IAttributedStream, _
	&hfac287de, &h4e2c, &h4f51, &h8e, &h7e, &hb0, &hb7, &h7e, &h2a, &he9, &h18 _
)

' {B6AC4CEF-9B3D-4B41-B2F6-DEA27D085EB7}
DEFINE_IID(IID_IBaseStream, _
	&hb6ac4cef, &h9b3d, &h4b41, &hb2, &hf6, &hde, &ha2, &h7d, &h8, &h5e, &hb7 _
)

' {E998CAB4-5559-409C-93BC-97AFDF6A3921}
DEFINE_IID(IID_IClientRequest, _
	&he998cab4, &h5559, &h409c, &h93, &hbc, &h97, &haf, &hdf, &h6a, &h39, &h21 _
)

' {38CBD760-F5C4-408A-B58D-A9AC9948A7C1}
DEFINE_IID(IID_IClientSocket, _
	&h38cbd760, &hf5c4, &h408a, &hb5, &h8d, &ha9, &hac, &h99, &h48, &ha7, &hc1 _
)

' {FA6493DA-9102-4FF6-822E-163399BF9E81}
DEFINE_IID(IID_IClientUri, _
	&hfa6493da, &h9102, &h4ff6, &h82, &h2e, &h16, &h33, &h99, &hbf, &h9e, &h81 _
)

' {9042F178-B211-478B-8FF6-9C4133984364}
DEFINE_IID(IID_IEnumWebSite, _
	&h9042f178, &hb211, &h478b, &h8f, &hf6, &h9c, &h41, &h33, &h98, &h43, &h64 _
)

' {A44A1AB3-A0D5-42E6-A4FF-ADBAE8CE3682}
DEFINE_IID(IID_IFileStream, _
	&ha44a1ab3, &ha0d5, &h42e6, &ha4, &hff, &had, &hba, &he8, &hce, &h36, &h82 _
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

' {B8B35871-1110-43F1-8674-C00DE24D0D7B}
DEFINE_IID(IID_IHttpOptionsAsyncProcessor, _
	&hb8b35871, &h1110, &h43f1, &h86, &h74, &hc0, &hd, &he2, &h4d, &hd, &h7b _
)

' {8580A82A-B959-4A91-986F-E63F12C0CC08}
DEFINE_IID(IID_IHttpDeleteAsyncProcessor, _
	&h8580a82a, &hb959, &h4a91, &h98, &h6f, &he6, &h3f, &h12, &hc0, &hcc, &h8 _
)

' {D596BBD2-86F2-4850-A807-34DA01953D61}
DEFINE_IID(IID_IHttpGetAsyncProcessor, _
	&hd596bbd2, &h86f2, &h4850, &ha8, &h7, &h34, &hda, &h1, &h95, &h3d, &h61 _
)

' {7FF2C598-DB91-4691-905D-174DF30D467B}
DEFINE_IID(IID_IHttpTraceAsyncProcessor, _
	&h7ff2c598, &hdb91, &h4691, &h90, &h5d, &h17, &h4d, &hf3, &hd, &h46, &h7b _
)

' {7C6F76B6-989B-4995-B312-AAC3DEEC673D}
DEFINE_IID(IID_IHttpProcessorCollection, _
	&h7c6f76b6, &h989b, &h4995, &hb3, &h12, &haa, &hc3, &hde, &hec, &h67, &h3d _
)

' {4A9F8492-6F76-4BED-86F4-CD4AEBF15DFA}
DEFINE_IID(IID_IHttpPutAsyncProcessor, _
	&h4a9f8492, &h6f76, &h4bed, &h86, &hf4, &hcd, &h4a, &heb, &hf1, &h5d, &hfa _
)

' {D34D026F-D057-422F-9B32-C6D9424336F2}
DEFINE_IID(IID_IHttpReader, _
	&hd34d026f, &hd057, &h422f, &h9b, &h32, &hc6, &hd9, &h42, &h43, &h36, &hf2 _
)

' {C910075B-3950-4831-85B0-8CAF047AB902}
DEFINE_IID(IID_IHttpWriter, _
	&hc910075b, &h3950, &h4831, &h85, &hb0, &h8c, &haf, &h4, &h7a, &hb9, &h2 _
)

' {204A5587-12AC-4CE2-A438-B1F8049FD66E}
DEFINE_IID(IID_IIniConfiguration, _
	&h204a5587, &h12ac, &h4ce2, &ha4, &h38, &hb1, &hf8, &h4, &h9f, &hd6, &h6e _
)

' {0BDF996F-284C-4CD5-B010-C88D5533FA50}
DEFINE_IID(IID_IMemoryStream, _
	&hbdf996f, &h284c, &h4cd5, &hb0, &h10, &hc8, &h8d, &h55, &h33, &hfa, &h50 _
)

' {A4C7EAED-5EC0-4B7C-81D2-05BE69E63A1F}
DEFINE_IID(IID_INetworkStream, _
	&ha4c7eaed, &h5ec0, &h4b7c, &h81, &hd2, &h5, &hbe, &h69, &he6, &h3a, &h1f _
)

' {82B525C1-E266-4317-9FA5-F8B19DF8C73C}
DEFINE_IID(IID_IReadRequestAsyncIoTask, _
	&h82b525c1, &he266, &h4317, &h9f, &ha5, &hf8, &hb1, &h9d, &hf8, &hc7, &h3c _
)

' {0013C420-C5FF-4C3A-986A-E510B66F3AAA}
DEFINE_IID(IID_ITimeCounter, _
	&h13c420, &hc5ff, &h4c3a, &h98, &h6a, &he5, &h10, &hb6, &h6f, &h3a, &haa _
)

' {C1BFB23D-79B3-4AE9-BEF9-5BF9D3073B84}
DEFINE_IID(IID_IServerResponse, _
	&hc1bfb23d, &h79b3, &h4ae9, &hbe, &hf9, &h5b, &hf9, &hd3, &h7, &h3b, &h84 _
)

' {D38929B0-17C1-47A2-A1AC-B07318B4C3C9}
DEFINE_IID(IID_IString, _
	&hd38929b0, &h17c1, &h47a2, &ha1, &hac, &hb0, &h73, &h18, &hb4, &hc3, &hc9 _
)

' {E1D64351-AB82-415B-9551-5923632EDCF4}
DEFINE_IID(IID_ITcpListener, _
	&he1d64351, &hab82, &h415b, &h95, &h51, &h59, &h23, &h63, &h2e, &hdc, &hf4 _
)

' {667DFC1A-466E-40BF-BEE3-7A34882BE2F9}
DEFINE_IID(IID_IThreadPool, _
	&h667dfc1a, &h466e, &h40bf, &hbe, &he3, &h7a, &h34, &h88, &h2b, &he2, &hf9 _
)

' {6603A8F5-FB80-4CB9-BF80-CEADE4576F52}
DEFINE_IID(IID_IWebServer, _
	&h6603a8f5, &hfb80, &h4cb9, &hbf, &h80, &hce, &had, &he4, &h57, &h6f, &h52 _
)

' {DE416BE2-F7C8-40C6-81DF-44742D47F0F7}
DEFINE_IID(IID_IWebSite, _
	&hde416be2, &hf7c8, &h40c6, &h81, &hdf, &h44, &h74, &h2d, &h47, &hf0, &hf7 _
)

' {146ED9B9-B372-4F53-BC1A-AD31380633DA}
DEFINE_IID(IID_IWebSiteCollection, _
	&h146ed9b9, &hb372, &h4f53, &hbc, &h1a, &had, &h31, &h38, &h6, &h33, &hda _
)

' {6964B4FE-BDAE-4B3B-BDF8-6C467BF35BFA}
DEFINE_IID(IID_IWriteErrorAsyncIoTask, _
	&h6964b4fe, &hbdae, &h4b3b, &hbd, &hf8, &h6c, &h46, &h7b, &hf3, &h5b, &hfa _
)

' {7BCB2D1D-0AA0-47EE-8420-594AD4378C94}
DEFINE_IID(IID_IWriteResponseAsyncIoTask, _
	&h7bcb2d1d, &haa0, &h47ee, &h84, &h20, &h59, &h4a, &hd4, &h37, &h8c, &h94 _
)
