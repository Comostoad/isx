@ECHO OFF
:: delims is a TAB followed by a space
FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\InnerSpace.exe" /v "Path"') DO SET InnerSpacePath=%%B

copy "%InnerSpacePath%\.NET Programs\ISXEQ2Wrapper.dll" "."
copy "%InnerSpacePath%\Lavish.InnerSpace.dll" "."
