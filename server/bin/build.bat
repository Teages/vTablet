
go build -o dist/windows_amd64/
@REM xcopy .\assets\** .\dist\windows_amd64\assets\ /y /s
xcopy .\libs\windows\** .\dist\windows_amd64\libs\ /y /s
