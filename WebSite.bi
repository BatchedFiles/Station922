#ifndef unicode
#define unicode
#endif

#include once "windows.bi"
#include once "win\shlwapi.bi"

Const DotDotString = ".."
Const SlashString = "/"

Const DefaultFileNameString1 = "default.xml"
Const DefaultFileNameString2 = "default.xhtml"
Const DefaultFileNameString3 = "default.htm"
Const DefaultFileNameString4 = "default.html"

' Сайт на сервере
Type WebSite
	Const MaxHostNameLength As Integer = 1023
	' Максимальная длина пути к файлу
	Const MaxFilePathLength As Integer = 4095 + 32
	' Максимальная длина пути к файлу
	Const MaxFilePathTranslatedLength As Integer = MaxFilePathLength + 256
	
	Dim HostName As WString * (MaxHostNameLength + 1)
	Dim PhysicalDirectory As WString * (MAX_PATH + 1)
	Dim VirtualPath As WString * (MaxHostNameLength + 1)
	Dim IsMoved As Boolean
	Dim MovedUrl As WString * (MaxHostNameLength + 1)
	
	' Путь к файлу
	Dim FilePath As WString * (MaxFilePathLength + 1)
	' Путь к файлу на диске
	Dim PathTranslated As WString * (MaxFilePathTranslatedLength + 1)
	
	' Получает путь к файлу на диске
	Declare Sub GetFilePath(ByVal path As WString Ptr)
	
	' Заполняет буфер путём к файлу
	Declare Sub MapPath(ByVal Buffer As WString Ptr, ByVal path As WString Ptr)
	
End Type

' Проверяет существование сайта
Declare Function WebSiteExists(ByVal ExeDir As WString Ptr, ByVal wSiteName As WString Ptr)As Boolean

' Заполняет сайт по имени хоста
Declare Sub GetWebSite(ByVal ExeDir As WString Ptr, ByVal site As WebSite Ptr, ByVal HostName As WString Ptr)

' Проверяет путь на запрещённые символы
Declare Function IsBadPath(ByVal Path As WString Ptr)As Boolean

' Заполняем буфер именем файла по умолчанию
Declare Sub GetDefaultFileName(ByVal Buffer As WString Ptr, ByVal Index As Integer)
