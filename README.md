# FreeBASICWebServer #

Очень компактный вебсервер для Windows, написанный на фрибейсике. Умеет обрабатывать методы CONNECT, GET, HEAD, PUT, DELETE, TRACE и OPTIONS.

Сервер работает «из коробки», необходимо лишь прописать пути к сайтам в настройках. Также для того, чтобы сервер вёл журнал сетевых соединений, необходимо создать каталог «logs» в папке с программой.


## Конфигурация сервера и сайтов ##

Настройки сервера и сайтов хранятся в обычных INI‐файлах. Рекомендуем сохранять такие файлы в кодировке UTF-16 LE для работы юникодных путей.

### Серверные настройки ###

Лежат в файле «WebServer.ini» в каталоге с программой. Пример:

```
[WebServer]
ListenAddress=0.0.0.0
Port=80
ConnectBindAddress=0.0.0.0
ConnectBindPort=0
```

ListenAddress — cетевой адрес, к которому будет привязан вебсервер. По умолчанию это 0.0.0.0, то есть сервер будет ожидать соединений со всех сетевых интерфейсов.

Port — порт для прослушивания. По умолчанию 80 (стандартный HTTP порт).

ConnectBindAddress — адрес, к которому будет привязываться сервер для выполнения метода CONNECT. По умолчанию 0.0.0.0.

ConnectBindPort — Порт, к которому будет привязываться сервер для выполнения метода CONNECT. По умолчанию 0.

### Методы CONNECT и PUT ###

Для своей работы эти методы требуют имени пользователя и пароля. Если имя пользователя и пароль не прописаны, то вебсервер будет отвечать на них ошибкой «401 Требуется авторизация».

 Создай в папке с программой файл «users.config» (текстовый INI‐файл) примерно следующего содержания:

```
[admins]
user=password
```

Где «user» — имя пользователя для авторизации, а «password» — пароль.

Для метода PUT аналогичный файл должен лежать в корневой директории сайта.


### Настройки сайтов ###

Лежат в файле «WebSites.ini» в каталоге с программой. Пример:

```
[localhost]
VirtualPath=/
PhisycalDir=c:\programming\сайты\localhost\
IsMoved=0
MovedUrl=http://localhost
```

Каждая секция в файле — это отдельный сайт, определяемый HTTP‐заголовком «Host». Для каждого сайта необходимо создавать отдельную секцию. Также нужно учитывать, что example.org, www.example.org и www.example.org:80 — разные сайты, каждый из которых требует отдельной секции.

VirtualPath — виртуальное имя сайта. Используется в сообщениях об ошибках.

PhisycalDir — физический каталог, где расположены файлы сайта.

IsMoved — указывает, что сайт является перенаправлением на другой сайт. Например, клиент делает запрос на example.org, а настоящий сайт находится на www.example.org. В таком случае необходимо установить 1 для перенаправления.

MovedUrl — адрес сайта, куда сервер будет перенаправлять. Необходимо начинать с «http://»

Таким образом при стандартных настройках, чтобы получить доступ к сайту, необходимо в браузере набрать http://localhost/

Если URL запрашиваемого файла не содержит полный путь, то сервер ищет в каталоге сайта файлы в порядке очерёдности:

* default.xml
* default.xhtml
* default.htm
* default.html
* index.xml
* index.xhtml
* index.htm
* index.html

Если ни один из этих файлов не найден, то сервер отправляет ошибку «410 Gone», если найдёт файл default.xml.410 или «404 Not Found».


## Компиляция ##

### Обычная версия ###

```
fbc.exe -mt -x "WebServer.exe" WebServer.bas Network.bas ThreadProc.bas ReadHeadersResult.bas WebUtils.bas ProcessRequests.bas base64-decode.bas Mime.bas Http.bas WebSite.bas HeapOnArray.bas
```

### В виде службы Windows ###

```
fbc.exe -mt -x "WebServer.exe" -d service=true WebServer.bas Network.bas ThreadProc.bas ReadHeadersResult.bas WebUtils.bas ProcessRequests.bas base64-decode.bas Mime.bas Http.bas WebSite.bas HeapOnArray.bas
```

Для регистрации службы выполни следующие команды:

```
set current_dir=%~dp0
sc create FreeBASICWebServer binPath= "%current_dir%WebServer.exe" start= "auto"
sc start FreeBASICWebServer
```
