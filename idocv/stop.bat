@echo off
echo /******************************************/
echo /* I Doc View在线文档预览
echo /* www.idocv.com
echo /* All Rights Reserved        - 2014年08月
echo /******************************************/

set TITLE=I Doc View在线文档预览服务停止程序

cd /D %~dp0
set IDOCV_DIR=%cd%
set JRE_HOME=%IDOCV_DIR%\server\jre_1.8.0_20
set MONGODB_HOME=%IDOCV_DIR%\db\mongodb_3.2
set MONGODB_PORT=27017
set APACHE_HOME=%IDOCV_DIR%\server\apache_2.4.33
set TOMCAT_HOME=%IDOCV_DIR%\server\tomcat_9.0.10
set CATALINA_HOME=%TOMCAT_HOME%
set CATALINA_BASE=%TOMCAT_HOME%
set TOMCAT_EXE=%TOMCAT_HOME%\bin\tomcat9.exe
set TOMCAT_SERVICE_NAME=tomcat9
rem console OR service
set TOMCAT_STARTUP_MODE=console
set IDOCV_CONVERTER_HOME=%IDOCV_DIR%\converter
set IDOCV_DOCVIEW_HOME=%IDOCV_DIR%\docview
set PORT=80

set IS_START_MONGODB=1
set IS_START_APACHE=1
set IS_START_TOMCAT=1

title %TITLE%
timeout 5

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Stop MongoDB...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_MONGODB%==1 (
    echo 正在停止MongoDB数据库服务...
	timeout 1
	net stop MongoDB
	%MONGODB_HOME%\bin\mongod.exe --remove
	echo 数据库服务停止成功！
	timeout 3
)

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Check Frontend Server...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_APACHE%==1 (
	if %PORT%==80 (
		echo 尝试停止World Wide Web Publishing Service服务...
		net stop W3SVC
		sc config W3SVC start= demand
		echo 尝试停止SQL Server Reporting Services服务...
		net stop reportserver
		sc config reportserver start= demand
	)
	if %IS_START_APACHE%==1 (
		echo 尝试停止Apache服务...
		%APACHE_HOME%\bin\httpd.exe -k stop
		%APACHE_HOME%\bin\httpd.exe -k uninstall
		timeout 5
	)
)

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Stop Tomcat...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_TOMCAT%==1 (
    echo 准备停止Tomcat...
	timeout 3

	if "%TOMCAT_STARTUP_MODE%"=="console" goto STOP_TOMCAT_CONSOLE_MODE
	if "%TOMCAT_STARTUP_MODE%"=="service" goto STOP_TOMCAT_SERVICE_MODE
	:STOP_TOMCAT_CONSOLE_MODE
	echo 正在以控制台模式停止Tomcat...
	%TOMCAT_HOME%\bin\shutdown.bat
	goto STOP_TOMCAT_DONE

	:STOP_TOMCAT_SERVICE_MODE
	echo 正在以Windows服务模式停止Tomcat...
	net stop %TOMCAT_SERVICE_NAME%
	%TOMCAT_EXE% //DS//%TOMCAT_SERVICE_NAME%
	goto STOP_TOMCAT_DONE

	:STOP_TOMCAT_DONE
	echo Tomcat服务关闭成功！
)

pause