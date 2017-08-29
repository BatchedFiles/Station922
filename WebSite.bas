#ifndef unicode
#define unicode
#endif

#include once "WebSite.bi"
#include once "win\shlwapi.bi"
#include once "IniConst.bi"

Const DotDotString = ".."

Const DefaultFileNameString1 = "default.xml"
Const DefaultFileNameString2 = "default.xhtml"
Const DefaultFileNameString3 = "default.htm"
Const DefaultFileNameString4 = "default.html"
Const DefaultFileNameString5 = "index.xml"
Const DefaultFileNameString6 = "index.xhtml"
Const DefaultFileNameString7 = "index.htm"
Const DefaultFileNameString8 = "index.html"

Const WebSitesMapFileName = "FreeBASICWebServerSiteList"

Const MaxDefaultFileName As Integer = 15

' Открывает файл на чтение или для проверки существования
Declare Function OpenFileForReading(ByVal PathTranslated As WString Ptr, ByVal ForReading As FileAccess)As Handle
' Заполняем буфер именем файла по умолчанию
Declare Sub GetDefaultFileName(ByVal Buffer As WString Ptr, ByVal Index As Integer)

Sub LoadWebSite(ByVal ExeDir As WString Ptr, ByVal www As WebSite Ptr, ByVal HostName As WString Ptr)
	' Имя файла настроек программы
	Dim IniFileName As WString * (MAX_PATH + 1) = Any
	PathCombine(@IniFileName, ExeDir, @WebSitesIniFileString)
	Dim DefaultValue As WString * 2 = Any
	DefaultValue[0] = 0
	DefaultValue[1] = 0
	
	GetPrivateProfileString(HostName, @VirtualPathSectionString, @DefaultValue, @www->VirtualPath, WebSite.MaxHostNameLength, IniFileName)
	GetPrivateProfileString(HostName, @PhisycalDirSectionString, @DefaultValue, @www->PhysicalDirectory, MAX_PATH, IniFileName)
	Dim Result2 As UINT = GetPrivateProfileInt(HostName, @IsMovedSectionString, 0, IniFileName)
	If Result2 = 0 Then
		www->IsMoved = False
	Else
		www->IsMoved = True
	End If
	GetPrivateProfileString(HostName, @MovedUrlSectionString, @DefaultValue, @www->MovedUrl, WebSite.MaxHostNameLength, IniFileName)
	lstrcpy(@www->HostName, HostName)
End sub

Function LoadWebSites(ByVal ExeDir As WString Ptr)As Integer
	' Получение списка сайтов и сохранение информации в память
	
	Const SectionsLength As Integer = 32000 - 1
	Dim AllSections As WString * (SectionsLength + 1) = Any
	' Имя файла настроек программы
	Dim IniFileName As WString * (MAX_PATH + 1) = Any
	PathCombine(@IniFileName, ExeDir, @WebSitesIniFileString)
	
	Dim DefaultValue As WString * 2 = Any
	DefaultValue[0] = 0
	DefaultValue[1] = 0
	' Получить имена всех секций
	Dim Result As DWORD = GetPrivateProfileString(Null, Null, @DefaultValue, @AllSections, SectionsLength, @IniFileName)
	
	' Определить количество сайтов
	Dim Start As Integer = 0
	Dim w As WString Ptr = Any
	Dim WebSitesCount As Integer = 0
	Do While Start < Result
		' Получить указатель на начало строки
		w = @AllSections[Start]
		' Измерить длину строки, прибавить это к указателю + 1
		Start += lstrlen(w) + 1
		' Увеличить счётчик сайтов
		WebSitesCount += 1
		If WebSitesCount > MaxWebSitesCount Then
			Exit Do
		End If
	Loop
	
	If WebSitesCount = 0 Then
		Return 0
	End If
	Dim WebSiteBytesCount As Integer = MaxWebSitesCount * SizeOf(WebSite)
	
	' Выделить память под сайты
	Dim hMapFile As HANDLE = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, SizeOf(Integer) + WebSiteBytesCount, @WebSitesMapFileName)
	If hMapFile = 0 Then
		Return 0
	End If
	
	Dim MemoryWebSitesCount As Integer Ptr = CPtr(Integer Ptr, MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(Integer) + WebSiteBytesCount))
	If MemoryWebSitesCount = 0 Then
		CloseHandle(hMapFile)
		Return 0
	End If
	
	*MemoryWebSitesCount = WebSitesCount
	
	Dim b As WebSite Ptr = CPtr(WebSite Ptr, @MemoryWebSitesCount[1])
	
	' Получить имена всех секций
	Result = GetPrivateProfileString(Null, Null, @DefaultValue, @AllSections, SectionsLength, @IniFileName)
	
	' Получить конфигурацию для каждого сайта
	Start = 0
	Dim i As Integer = 0
	Do While Start < Result
		' Получить указатель на начало строки
		w = @AllSections[Start]
		LoadWebSite(ExeDir, @b[i], w)
		' Измерить длину строки, прибавить это к указателю + 1
		Start += lstrlen(w) + 1
		i += 1
		If i > MaxWebSitesCount Then
			Exit Do
		End If
	Loop
	
	' Выгрузить
	UnmapViewOfFile(MemoryWebSitesCount)
	
	' Отображение файла не закрывается, 
	' Оно нужно для сохранения сайтов в памяти
	
	Return WebSitesCount
End Function

Function GetWebSite(ByVal www As WebSite Ptr, ByVal HostName As WString Ptr)As Boolean
	Dim WebSiteBytesCount As Integer = MaxWebSitesCount * SizeOf(WebSite)
	
	Dim hMapFile As HANDLE = OpenFileMapping(GENERIC_READ + GENERIC_WRITE, False, @WebSitesMapFileName)
	If hMapFile = 0 Then
		Return False
	End If
	
	Dim MemoryWebSitesCount As Integer Ptr = CPtr(Integer Ptr, MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(Integer) + WebSiteBytesCount))
	If MemoryWebSitesCount = 0 Then
		CloseHandle(hMapFile)
		Return False
	End If
	
	Dim b As WebSite Ptr = CPtr(WebSite Ptr, @MemoryWebSitesCount[1])
	Dim SiteFindResult As Boolean = False
	
	For i As Integer = 0 To *MemoryWebSitesCount - 1
		If lstrcmp(@b[i].HostName, HostName) = 0 Then
			RtlCopyMemory(www, @b[i], SizeOf(WebSite))
			SiteFindResult = True
		End If
	Next
	
	' Выгрузить
	UnmapViewOfFile(MemoryWebSitesCount)
	CloseHandle(hMapFile)
	
	Return SiteFindResult
End Function

Sub WebSite.MapPath(ByVal Buffer As WString Ptr, ByVal path As WString Ptr)
	lstrcpy(Buffer, @PhysicalDirectory)
	Dim BufferLength As Integer = lstrlen(Buffer)
	
	' Добавить \ если там его нет
	If Buffer[BufferLength - 1] <> &h5c Then
		Buffer[BufferLength] = &h5c
		BufferLength += 1
		Buffer[BufferLength] = 0
	End If
	
	' Объединение физической директории и пути
	If lstrlen(path) <> 0 Then
		If path[0] = &h2f Then
			lstrcat(Buffer, path + 1)
		Else
			lstrcat(Buffer, path)
		End If
	End If
	
	' замена / на \
	For i As Integer = 0 To lstrlen(Buffer) - 1
		If Buffer[i] = &h2f Then
			Buffer[i] = &h5c
		End If
	Next
End Sub

Function IsBadPath(ByVal Path As WString Ptr)As Boolean
	' TODO Звёздочка в пути допустима при методе OPTIONS
	Dim PathLen As Integer = lstrlen(Path)
	If PathLen = 0 Then
		Return True
	End If
	If Path[PathLen - 1] = &h2e Then ' .
		Return True
	End If
	For i As Integer = 0 To PathLen - 1
		Dim c As Integer = Path[i]
		Select Case c
			Case Is < 32
				Return True
			Case 34 ' "
				Return True
			Case 36 ' $
				Return True
			Case 37 ' %
				Return True
			Case 60 ' <
				Return True
			Case 62 ' >
				Return True
			Case 63 ' ?
				Return True
			Case 124 ' |
				Return True
		End Select
	Next
	If StrStr(Path, DotDotString) > 0 Then
		Return True
	End If
	Return False
End Function

Function OpenFileForReading(ByVal PathTranslated As WString Ptr, ByVal ForReading As FileAccess)As Handle
	Select Case ForReading
		Case ForPut
			Return INVALID_HANDLE_VALUE
		Case ForGetHead
			' Для GetHead
			Return CreateFile(PathTranslated, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
		Case ForDelete
			' Для Delete
			Return CreateFile(PathTranslated, 0, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
	End Select
End Function

Function WebSite.GetFilePath(ByVal path As WString Ptr, ByVal ForReading As FileAccess)As Handle
	' Если оканчивается на «/», значит, передали имя каталога
	If Path[lstrlen(Path) - 1] <> &h2f Then
		' Path содержит имя конкретного файла
		lstrcpy(@FilePath, Path)
		MapPath(@PathTranslated, @FilePath)
		Return OpenFileForReading(@PathTranslated, ForReading)
	End If
	
	' Получить имя файла по умолчанию
	Dim DefaultFilename As WString * (MaxDefaultFileName + 1) = Any
	Dim DefaultFilenameIndex As Integer = 0
	
	GetDefaultFileName(@DefaultFilename, DefaultFilenameIndex)
	
	Do
		lstrcpy(@FilePath, Path)
		lstrcat(@FilePath, @DefaultFilename)
		
		MapPath(@PathTranslated, @FilePath)
		
		Dim hFile As Handle = OpenFileForReading(@PathTranslated, ForReading)
		If hFile <> INVALID_HANDLE_VALUE Then
			' Найден
			Return hFile
		End If
		
		DefaultFilenameIndex += 1
		GetDefaultFileName(@DefaultFilename, DefaultFilenameIndex)
	Loop While lstrlen(DefaultFilename) > 0
	
	' Файл по умолчанию не найден
	GetDefaultFileName(@DefaultFilename, 0)
	lstrcpy(@FilePath, Path)
	lstrcat(@FilePath, @DefaultFilename)
	
	MapPath(@PathTranslated, @FilePath)
	Return INVALID_HANDLE_VALUE
End Function

Sub GetDefaultFileName(ByVal Buffer As WString Ptr, ByVal Index As Integer)
	Select Case Index
		Case 0
			lstrcpy(Buffer, @DefaultFileNameString1)
		Case 1
			lstrcpy(Buffer, @DefaultFileNameString2)
		Case 2
			lstrcpy(Buffer, @DefaultFileNameString3)
		Case 3
			lstrcpy(Buffer, @DefaultFileNameString4)
		Case 4
			lstrcpy(Buffer, @DefaultFileNameString5)
		Case 5
			lstrcpy(Buffer, @DefaultFileNameString6)
		Case 6
			lstrcpy(Buffer, @DefaultFileNameString7)
		Case 7
			lstrcpy(Buffer, @DefaultFileNameString8)
		Case Else
			Buffer[0] = 0
	End Select
End Sub

Function NeedCGIProcessing(ByVal Path As WString Ptr)As Boolean
	' Проверка на CGI
	If StrStrI(Path, "/cgi-bin/") = Path Then
		Return True
	End If
	
	Return False
End Function

Function NeedDLLProcessing(ByVal Path As WString Ptr)As Boolean
	' Проверка на dll-cgi
	If StrStrI(Path, "/cgi-dll/") = Path Then
		Return True
	End If
	
	Return False
End Function
