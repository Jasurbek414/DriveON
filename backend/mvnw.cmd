@REM Maven Wrapper startup batch script
@REM
@setlocal

@set WRAPPER_JAR="%~dp0\.mvn\wrapper\maven-wrapper.jar"
@set WRAPPER_URL="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar"

@if not exist %WRAPPER_JAR% (
    echo Downloading Maven Wrapper...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%WRAPPER_URL:"=%', '%WRAPPER_JAR:"=%')"
)

@set MAVEN_PROJECTBASEDIR=%~dp0
@set MAVEN_CMD_LINE_ARGS=%*

java -jar %WRAPPER_JAR% %MAVEN_CMD_LINE_ARGS%
