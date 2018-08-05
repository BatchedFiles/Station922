#ifndef MIME_BI
#define MIME_BI

' Размер буфера для записи в него типа документа
Const MaxContentTypeLength As Integer = 256 - 1

Enum ContentTypes
	AnyAny
	
	ApplicationAny
	ApplicationXml
	ApplicationXmlXslt
	ApplicationXhtml
	ApplicationAtom
	ApplicationRssXml
	ApplicationJavascript
	ApplicationXJavascript
	ApplicationJson
	ApplicationSoapxml
	ApplicationXmldtd
	Application7z
	ApplicationRar
	ApplicationZip
	ApplicationGzip
	ApplicationXCompressed
	ApplicationRtf
	ApplicationPdf
	ApplicationOpenDocumentText
	ApplicationOpenDocumentTextTemplate
	ApplicationOpenDocumentGraphics
	ApplicationOpenDocumentGraphicsTemplate
	ApplicationOpenDocumentPresentation
	ApplicationOpenDocumentPresentationTemplate
	ApplicationOpenDocumentSpreadsheet
	ApplicationOpenDocumentSpreadsheetTemplate
	ApplicationOpenDocumentChart
	ApplicationOpenDocumentChartTemplate
	ApplicationOpenDocumentImage
	ApplicationOpenDocumentImageTemplate
	ApplicationOpenDocumentFormula
	ApplicationOpenDocumentFormulaTemplate
	ApplicationOpenDocumentMaster
	ApplicationOpenDocumentWeb
	ApplicationVndmsexcel
	ApplicationVndopenxmlformatsofficedocumentspreadsheetmlsheet
	ApplicationVndmspowerpoint
	ApplicationVndopenxmlformatsofficedocumentpresentationmlpresentation
	ApplicationMsword
	ApplicationVndopenxmlformatsofficedocumentwordprocessingmldocument
	ApplicationFontwoff
	ApplicationXfontttf
	ApplicationXwwwformurlencoded
	ApplicationFlash
	ApplicationOctetStream
	ApplicationXbittorrent
	ApplicationOgg
	ApplicationCertx509
	
	AudioAny
	AudioBasic
	AudioL24
	AudioMp4
	AudioAac
	AudioMpeg
	AudioOgg
	AudioVorbis
	AudioXmswma
	AudioXmswax
	AudioRealaudio
	AudioVndwave
	AudioWebm
	
	ImageAny
	ImageGif
	ImageJpeg
	ImagePjpeg
	ImagePng
	ImageSvg
	ImageTiff
	ImageIco
	ImageWbmp
	ImageWebp
	
	MessageAny
	MessageHttp
	MessageImdnxml
	MessagePartial
	MessageRfc822
	
	MultipartAny
	MultipartMixed
	MultipartAlternative
	MultipartRelated
	MultipartFormdata
	MultipartSigned
	MultipartEncrypted
	
	TextAny
	TextCmd
	TextCss
	TextCsv
	TextHtml
	TextPlain
	TextPhp
	TextXml
	
	VideoAny
	VideoMpeg
	VideoOgg
	VideoMp4
	VideoQuicktime
	VideoWebm
	VideoXmswmv
	VideoXflv
	Video3gpp
	Video3gpp2
	
	Unknown
End Enum

Enum DocumentCharsets
	ASCII
	Utf8BOM
	Utf16LE
	Utf16BE
End Enum

Type MimeType
	Dim ContentType As ContentTypes
	Dim IsTextFormat As Boolean
	Dim Charset As DocumentCharsets
End Type

Declare Sub GetContentTypeOfMimeType( _
	ByVal ContentType As WString Ptr, _
	ByVal mt As MimeType Ptr _
)

Declare Function GetMimeOfFileExtension( _
	ByVal mt As MimeType Ptr, _
	ByVal FileExtension As WString Ptr _
)As Boolean

Declare Function GetMimeOfStringContentType( _
	ByVal mt As MimeType Ptr, _
	ByVal ContentType As WString Ptr _
)As Boolean

#endif
