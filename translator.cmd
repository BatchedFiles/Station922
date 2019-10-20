REM Транслятор бейсик‐файлов

REM Исходные коды: *.bas
REM Включаемые файлы: *.bi
REM Файлы ресурсов: *.rc

REM Параметры:
REM 1. Все компилируемые *.bas и *.rc файлы (в кавычках)
REM 2. Тип исполняемого файла               [console | gui | lib | dll | native | driver]
REM 3. Имя скомпилированного файла          [в кавычках] = имя первого файла + .exe
REM 4. Директория компилятора               [в кавычках] %ProgramFiles%\FreeBASIC
REM 5. Дополнительные параметры компиляции  [в кавычках]
REM 6. Флаг отладки                         [release   | debug]
REM 7. Флаг профилировщика                  [noprofile | profile]
REM 8. Флаг удаления RTL                    [runtime   | withoutruntime]

REM Типы исполняемых файлов
REM lib     Статически подключаемая библиотека  -
REM dll     Динамически подключаемая библиотека console
REM console Консольное приложение               console
REM gui     Графическое приложение              gui
REM native  Нативное приложение                 native
REM driver  Драйвер                             native

set CompilerLogErrorFileName=_out.txt

set AllCompiledFiles=%~1
set ExeTypeKind=%~2
set OutputFileName=%~3
set Directory=%~4
set CompilerParameters=%~5
set DebugFlag=%~6
set ProfileFlag=%~7
set WithoutRuntimeLibraryesFlag=%~8


:CreateCompilerExeTypeKind
	
	if "%ExeTypeKind%"=="dll" (
		if "%WithoutRuntimeLibraryesFlag%"=="withoutruntime" (
			set CompilerExeTypeKind=-lib
		) else (
			set CompilerExeTypeKind=-dll
		)
	) else (
		if "%WithoutRuntimeLibraryesFlag%"=="withoutruntime" (
			set CompilerExeTypeKind=-lib
		) else (
			if "%ExeTypeKind%"=="lib" (
				set CompilerExeTypeKind=-lib
			)
		)
	)
	
:CreateWin32Subsystem
	
	if "%ExeTypeKind%"=="lib" (
		set Win32Subsystem=console
	) else (
		if "%ExeTypeKind%"=="dll" (
			set Win32Subsystem=console
		) else (
			if "%ExeTypeKind%"=="console" (
				set Win32Subsystem=console
			) else (
				if "%ExeTypeKind%"=="gui" (
					set Win32Subsystem=gui
				) else (
					if "%ExeTypeKind%"=="native" (
						set Win32Subsystem=native
					) else (
						if "%ExeTypeKind%"=="driver" (
							set Win32Subsystem=native
						) else (
							set Win32Subsystem=console
						)
					)
				)
			)
		)
	)
	
:CreateCompilerOutputFileName
	
	if "%OutputFileName%"=="" (
		for /F "tokens=1" %%I in ("%AllCompiledFiles%") do (
			call :SetCompilerOutputFileName %%I
		)
	) else (
		set CompilerOutputFileName=%OutputFileName%
	)
	
	
:CreateCompilerPath
	
	if "%Directory%"=="" (
		set CompilerDirectory=%ProgramFiles%\FreeBASIC
	)
	
	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		set CompilerBinDirectory=%CompilerDirectory%\bin\win32
		set CompilerLibDirectory=%CompilerDirectory%\lib\win32
		set CodeGenerationBackend=gas
	) else (
		set CompilerBinDirectory=%CompilerDirectory%\bin\win64
		set CompilerLibDirectory=%CompilerDirectory%\lib\win64
		set CodeGenerationBackend=gcc
	)
	
	
:CreateCompilerDebugFlag
	
	if "%DebugFlag%"=="debug" (
		set CompilerDebugFlag=-g
	)
	
	
:CreateCompilerProfileFlag
	
	if "%ProfileFlag%"=="profile" (
		set CompilerProfileFlag=-profile
	)
	
	
:CreateWithoutRuntimeLibraryesFlag
	
	if "%WithoutRuntimeLibraryesFlag%"=="withoutruntime" (
		set WITHOUT_RUNTIME_DEFINED=-d WITHOUT_RUNTIME
		set WriteOutOnlyAsm=-r
	)
	
:FreeBASICCompiler

	"%CompilerDirectory%\fbc.exe" %WITHOUT_RUNTIME_DEFINED% -x %CompilerOutputFileName% %WriteOutOnlyAsm% -s %Win32Subsystem% %CompilerExeTypeKind% -gen %CodeGenerationBackend% %CompilerDebugFlag% %CompilerProfileFlag% %CompilerParameters% %AllCompiledFiles% >%CompilerLogErrorFileName%

	if %errorlevel% GEQ 1 (
		exit /b 1
	)

	if not "%WithoutRuntimeLibraryesFlag%"=="withoutruntime" (
		exit /b 0
	)
	
	
:WithoutRuntimeCompilation

	set GCCWarning=-Werror -Wall -Wno-unused-label -Wno-unused-function -Wno-unused-variable -Wno-unused-but-set-variable -Wno-main
	set GCCNoInclude=-nostdlib -nostdinc
	set GCCOptimizations=-O0 -mno-stack-arg-probe -fno-stack-check -fno-stack-protector -fno-strict-aliasing -frounding-math -fno-math-errno -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-ident
	set IncludeObjectLibraries=-lshlwapi -lshell32 -lcrypt32 -lmswsock -lgdiplus -lkernel32 -lgdi32 -lmsimg32 -luser32 -lversion -ladvapi32 -limm32 -lole32 -luuid -loleaut32 -lmsvcrt -lmoldname -lgmon
	set OutputDefinitionFileName=%OutputFileName:~0,-3%def
	
	set UseThreadSafeRuntime=
	
	set MajorImageVersion=--major-image-version 1
	set MinorImageVersion=--minor-image-version 0

	REM Обычный
	REM "C:\Program Files\FreeBASIC\lib\win64\crt2.o"
	REM "C:\Program Files\FreeBASIC\lib\win64\crtbegin.o"
	REM "C:\Program Files\FreeBASIC\lib\win64\fbrt0.o"
	REM (библиотеки)
	REM "C:\Program Files\FreeBASIC\lib\win64\crtend.o"
	
	REM Профилировщик
	REM "C:\Program Files\FreeBASIC\lib\win64\crt2.o"
	REM "C:\Program Files\FreeBASIC\lib\win64\gcrt2.o"
	REM "C:\Program Files\FreeBASIC\lib\win64\crtbegin.o"
	REM "C:\Program Files\FreeBASIC\lib\win64\fbrt0.o"
	REM (библиотеки)
	REM "C:\Program Files\FreeBASIC\lib\win64\crtend.o"
	
	set AllFileWithExtensionC=
	set AllFileWithExtensionAsm=
	set AllObjectFiles=

	for %%I IN (%AllCompiledFiles%) do (
		if "%%~xI"==".bas" (
			call :GccCompier %%I
		)
	)
	for %%I IN (%AllCompiledFiles%) do (
		if "%%~xI"==".rc" (
			call :ResourceCompiler %%I
		)
	)

	call :GccLinker
	
	call :CleanUp
	
	exit /b 0
	
:CleanUp
	
	rem del %AllFileWithExtensionC% %AllFileWithExtensionAsm% %AllObjectFiles%
	
	exit /b 0


:GccLinker
	
	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		
		if "%ExeTypeKind%"=="dll" (
			set EntryPoint=_DllMain@12 --dll --enable-stdcall-fixup --output-def %OutputDefinitionFileName%
		) else (
			set EntryPoint=_EntryPoint@0
		)
		
		set PEFileFormat=i386pe
		
	) else (
		
		if "%ExeTypeKind%"=="dll" (
			set EntryPoint=DllMain --dll --enable-stdcall-fixup --output-def %OutputDefinitionFileName%
		) else (
			set EntryPoint=EntryPoint
		)
		
		set PEFileFormat=i386pep
		
	)
	
	if "%DebugFlag%"=="debug" (
		"%CompilerBinDirectory%\ld.exe" -m %PEFileFormat% -subsystem %Win32Subsystem% "%CompilerLibDirectory%\fbextra.x" -e %EntryPoint% --stack 1048576,1048576 -L "%CompilerLibDirectory%" -L "." %AllObjectFiles% -o %CompilerOutputFileName% -( %IncludeObjectLibraries% -)
	) else (
		"%CompilerBinDirectory%\ld.exe" -m %PEFileFormat% -subsystem %Win32Subsystem% "%CompilerLibDirectory%\fbextra.x" -e %EntryPoint% --stack 1048576,1048576 -s -L "%CompilerLibDirectory%" -L "." %AllObjectFiles% -o %CompilerOutputFileName% -( %IncludeObjectLibraries% -)
	)
	
	if "%ExeTypeKind%"=="dll" (
		"%CompilerBinDirectory%\dlltool.exe" --def %OutputDefinitionFileName% --dllname %CompilerOutputFileName% --output-lib lib%CompilerOutputFileName%.a
	)
	
	exit /b 0
	
	
:GccCompier

	set FileWithExtensionBas=%1
	set FileWithoutExtension=%FileWithExtensionBas:~0,-3%
	set FileWithExtensionC=%FileWithoutExtension%c
	set FileWithExtensionAsm=%FileWithoutExtension%asm
	set FileWithExtensionObj=%FileWithoutExtension%o

	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		set TargetAssemblerArch=--32
	) else (
		set TargetAssemblerArch=--64
		set GCCArchitecture=-m64 -march=x86-64
	)

	if "%CodeGenerationBackend%"=="gcc" (
		"%CompilerBinDirectory%\gcc.exe" %GCCWarning% %GCCNoInclude% %GCCOptimizations% %GCCArchitecture% %CompilerDebugFlag% -masm=intel -S %FileWithExtensionC% -o %FileWithExtensionAsm%
	)
	
	if "%DebugFlag%"=="debug" (
		"%CompilerBinDirectory%\as.exe" %TargetAssemblerArch% %FileWithExtensionAsm% -o %FileWithExtensionObj%
	) else (
		"%CompilerBinDirectory%\as.exe" %TargetAssemblerArch% --strip-local-absolute %FileWithExtensionAsm% -o %FileWithExtensionObj%
	)

	set AllFileWithExtensionC=%AllFileWithExtensionC% %FileWithExtensionC%
	set AllFileWithExtensionAsm=%AllFileWithExtensionAsm% %FileWithExtensionAsm%
	set AllObjectFiles=%AllObjectFiles% %FileWithExtensionObj%

	exit /b 0


:ResourceCompiler

	set ResourceFileWithExtension=%1
	set ResourceFileWithoutExtension=%ResourceFileWithExtension:~0,-2%
	set ResourceFileWithExtensionObj=%ResourceFileWithoutExtension%obj
	
	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		set ResourceCompiler64Flag=/nw
	) else (
		set ResourceCompiler64Flag=/machine X64
	)
	
	"%CompilerBinDirectory%\gorc.exe" /ni %ResourceCompiler64Flag% /o /fo %ResourceFileWithExtensionObj% %ResourceFileWithExtension%

	set AllObjectFiles=%AllObjectFiles% %ResourceFileWithExtensionObj%

	exit /b 0
	
	
:SetCompilerOutputFileName
	
	set CompilerOutputFileNameWithExtensionBas=%1
	set CompilerOutputFileNameWithouExtension=%CompilerOutputFileNameWithExtensionBas:~0,-3%
	
	if "%ExeTypeKind%"=="lib" (
		set CompilerOutputFileName=lib%CompilerOutputFileNameWithouExtension%.a
	) else (
		if "%ExeTypeKind%"=="dll" (
			set CompilerOutputFileName=%CompilerOutputFileNameWithouExtension%.dll
		) else (
			set CompilerOutputFileName=%CompilerOutputFileNameWithouExtension%.exe
		)
	)
	
	exit /b 0