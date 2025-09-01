@echo off
echo Gerando keystore para assinatura de producao...
echo.

REM Tentar encontrar o Java
set JAVA_HOME=
for /f "tokens=*" %%i in ('where java 2^>nul') do (
    set JAVA_PATH=%%i
    goto :found_java
)

echo Java nao encontrado no PATH. Tentando localizar...
if exist "C:\Program Files\Java\jdk-17\bin\keytool.exe" (
    set JAVA_PATH=C:\Program Files\Java\jdk-17\bin\keytool.exe
    goto :found_java
)
if exist "C:\Program Files\Java\jdk-11\bin\keytool.exe" (
    set JAVA_PATH=C:\Program Files\Java\jdk-11\bin\keytool.exe
    goto :found_java
)
if exist "C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot\bin\keytool.exe" (
    set JAVA_PATH=C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot\bin\keytool.exe
    goto :found_java
)

echo ERRO: Java nao encontrado. Instale o Java JDK primeiro.
pause
exit /b 1

:found_java
echo Java encontrado em: %JAVA_PATH%
echo.

"%JAVA_PATH%" -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass motopro123 -keypass motopro123 -dname "CN=MotoPro, OU=Development, O=YourCompany, L=YourCity, S=YourState, C=BR"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Keystore gerado com sucesso!
    echo Arquivo: android/app/upload-keystore.jks
    echo.
    echo IMPORTANTE: Guarde este arquivo em local seguro!
    echo.
) else (
    echo.
    echo ERRO ao gerar keystore!
    echo.
)

pause
