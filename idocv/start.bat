@echo off
echo /******************************************/
echo /* I Doc View�����ĵ�Ԥ��
echo /* www.idocv.com
echo /* All Rights Reserved        - 2014��08��
echo /******************************************/

set TITLE=I Doc View�����ĵ�Ԥ��������������

cd /D %~dp0
set IDOCV_DIR=%cd%
set JRE_HOME=%IDOCV_DIR%\server\jre_1.8.0_20
set MONGODB_HOME=%IDOCV_DIR%\db\mongodb_3.2
set MONGODB_PORT=27017
set APACHE_HOME=%IDOCV_DIR%\server\apache_2.4.34
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

::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ע���������TOMCAT_STARTUP_MODE=service��
:: ����windows����ʽ����tomcat������Ҫ����������
:: �����ʼ->����->dcomcnfg.exe
:: ���δ��������->�����->�ҵĵ���->DCOM����
:: �ֱ��ҵ������������ÿһ���ϵ����Ҽ�->����->��ʶ��
:: �޸ġ������û���Ϊ�������û���������д����Ա�û�������
:: Microsoft Word 97 - 2003�ĵ�
:: Microsoft Excel Application
:: Microsoft PowerPoint�õ�Ƭ
::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Check installation...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_MONGODB%==1 if not exist %MONGODB_HOME%\bin\mongod.exe (
  echo [ERROR] ����δ��װMongoDB���ݿ⣡
  pause
  exit
)
if %IS_START_APACHE%==1 if not exist %APACHE_HOME%\bin\httpd.exe (
  echo [ERROR] ����δ��װApache��
  pause
  exit
)
if %IS_START_TOMCAT%==1 if not exist %TOMCAT_HOME%\bin\startup.bat (
  echo [ERROR] ����δ��װTomcat��
  pause
  exit
)
if not exist %IDOCV_CONVERTER_HOME%\NUL (
  echo [ERROR] ����δ��װI Doc View�ĵ�ת������
  echo �뽫I Doc View�ĵ�ת������ѹ��Ŀ¼��%IDOCV_CONVERTER_HOME%
  pause
  exit
)
if not exist %IDOCV_DOCVIEW_HOME%\NUL (
  echo [ERROR] ����δ��װI Doc View�ĵ�Ԥ��WEBӦ�ã�
  echo �뽫I Doc View�ĵ�Ԥ��WEBӦ�ý�ѹ��Ŀ¼��%IDOCV_DOCVIEW_HOME%
  pause
  exit
)
if not exist %IDOCV_DIR%\data mkdir %IDOCV_DIR%\data

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Initialize Database...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_MONGODB%==1 (
    echo ���ڳ�ʼ�����ݿ�...
	timeout 1
	if not exist %MONGODB_HOME%\data mkdir %MONGODB_HOME%\data
	if not exist %MONGODB_HOME%\log mkdir %MONGODB_HOME%\log
	rem �����Ҫ�����û���֤������������ĩβ���" --auth"���������ݿ��ʼ���ű�db_init.js��Ԥ�����������ļ�conf.properties���������ݿ��û���������
	%MONGODB_HOME%\bin\mongod.exe --install --logpath %MONGODB_HOME%\log\mongo.log --logappend --dbpath %MONGODB_HOME%\data --port %MONGODB_PORT% --bind_ip 127.0.0.1
	net start MongoDB
	%MONGODB_HOME%\bin\mongo.exe --port %MONGODB_PORT% docview %MONGODB_HOME%\db_init.js
	echo ���ݿ��ʼ���ɹ���
	timeout 3
)

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Start Apache...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_APACHE%==1 (
    echo ��������Apache����...
    %APACHE_HOME%\bin\httpd.exe -k install
    net start Apache2.4
    echo Apache���������ɹ���
    timeout 3
)

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Start Tomcat...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_TOMCAT%==1 (
    echo ׼������Tomcat...
	timeout 1

	if "%TOMCAT_STARTUP_MODE%"=="console" goto START_TOMCAT_CONSOLE_MODE
	if "%TOMCAT_STARTUP_MODE%"=="service" goto START_TOMCAT_SERVICE_MODE
	:START_TOMCAT_CONSOLE_MODE
	echo �����Կ���̨ģʽ����Tomcat...
	%TOMCAT_HOME%\bin\startup.bat
	goto START_TOMCAT_DONE

	:START_TOMCAT_SERVICE_MODE
	echo ������Windows����ģʽ����Tomcat...

	rem -- tomcat service START -----------------------------------------------------
	set "CLASSPATH=%TOMCAT_HOME%\bin\bootstrap.jar;%TOMCAT_HOME%\bin\tomcat-juli.jar"
	rem %TOMCAT_EXE% //DS//%TOMCAT_SERVICE_NAME% ɾ������
	%TOMCAT_EXE% //IS//%TOMCAT_SERVICE_NAME% ^
		--Install "%TOMCAT_EXE%" ^
		--Classpath "%CLASSPATH%" ^
		--Jvm auto ^
		--Jvm %JRE_HOME%\bin\server\jvm.dll ^
		--StartMode jvm ^
		--StopMode jvm ^
		--StartClass org.apache.catalina.startup.Bootstrap ^
		--StopClass org.apache.catalina.startup.Bootstrap ^
		--StartParams start ^
		--StopParams stop ^
		--Startup auto
	rem if not errorlevel 1 goto installedTomcat
	rem echo ��װTomcat����ʧ�ܣ�
	rem :installedTomcat
	echo ��װTomcat����ɹ���
	net start %TOMCAT_SERVICE_NAME%
	rem -- tomcat service END -----------------------------------------------------
	goto START_TOMCAT_DONE

	:START_TOMCAT_DONE
	echo Tomcat�����ɹ���
)

pause

:::::::::::::::::::::::::::
:: All done, have fun :) ::
:::::::::::::::::::::::::::