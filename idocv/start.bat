@echo off
echo /******************************************/
echo /* I Doc View在线文档预览
echo /* www.idocv.com
echo /* All Rights Reserved        - 2014年08月
echo /******************************************/

set TITLE=I Doc View在线文档预览服务启动程序

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
:: 注：如果配置TOMCAT_STARTUP_MODE=service，
:: 即以windows服务方式运行tomcat，则需要做以下设置
:: 点击开始->运行->dcomcnfg.exe
:: 依次打开组件服务->计算机->我的电脑->DCOM配置
:: 分别找到以下三项，并在每一项上单击右键->属性->标识，
:: 修改“启动用户”为“下列用户”，并填写管理员用户名密码
:: Microsoft Word 97 - 2003文档
:: Microsoft Excel Application
:: Microsoft PowerPoint幻灯片
::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Check installation...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_MONGODB%==1 if not exist %MONGODB_HOME%\bin\mongod.exe (
  echo [ERROR] 您尚未安装MongoDB数据库！
  pause
  exit
)
if %IS_START_APACHE%==1 if not exist %APACHE_HOME%\bin\httpd.exe (
  echo [ERROR] 您尚未安装Apache！
  pause
  exit
)
if %IS_START_TOMCAT%==1 if not exist %TOMCAT_HOME%\bin\startup.bat (
  echo [ERROR] 您尚未安装Tomcat！
  pause
  exit
)
if not exist %IDOCV_CONVERTER_HOME%\NUL (
  echo [ERROR] 您尚未安装I Doc View文档转换器！
  echo 请将I Doc View文档转换器解压到目录：%IDOCV_CONVERTER_HOME%
  pause
  exit
)
if not exist %IDOCV_DOCVIEW_HOME%\NUL (
  echo [ERROR] 您尚未安装I Doc View文档预览WEB应用！
  echo 请将I Doc View文档预览WEB应用解压到目录：%IDOCV_DOCVIEW_HOME%
  pause
  exit
)
if not exist %IDOCV_DIR%\data mkdir %IDOCV_DIR%\data

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Initialize Database...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_MONGODB%==1 (
    echo 正在初始化数据库...
	timeout 1
	if not exist %MONGODB_HOME%\data mkdir %MONGODB_HOME%\data
	if not exist %MONGODB_HOME%\log mkdir %MONGODB_HOME%\log
	rem 如果需要开启用户验证，可在以下行末尾添加" --auth"，并在数据库初始化脚本db_init.js和预览服务配置文件conf.properties中设置数据库用户名和密码
	%MONGODB_HOME%\bin\mongod.exe --install --logpath %MONGODB_HOME%\log\mongo.log --logappend --dbpath %MONGODB_HOME%\data --port %MONGODB_PORT% --bind_ip 127.0.0.1
	net start MongoDB
	%MONGODB_HOME%\bin\mongo.exe --port %MONGODB_PORT% docview %MONGODB_HOME%\db_init.js
	echo 数据库初始化成功！
	timeout 3
)

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Start Apache...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_APACHE%==1 (
    echo 正在启动Apache服务...
    %APACHE_HOME%\bin\httpd.exe -k install
    net start Apache2.4
    echo Apache服务启动成功！
    timeout 3
)

:::::::::::::::::::::::::::::::::::::::::::::::::
:: Start Tomcat...
:::::::::::::::::::::::::::::::::::::::::::::::::
if %IS_START_TOMCAT%==1 (
    echo 准备启动Tomcat...
	timeout 1

	if "%TOMCAT_STARTUP_MODE%"=="console" goto START_TOMCAT_CONSOLE_MODE
	if "%TOMCAT_STARTUP_MODE%"=="service" goto START_TOMCAT_SERVICE_MODE
	:START_TOMCAT_CONSOLE_MODE
	echo 正在以控制台模式启动Tomcat...
	%TOMCAT_HOME%\bin\startup.bat
	goto START_TOMCAT_DONE

	:START_TOMCAT_SERVICE_MODE
	echo 正在以Windows服务模式启动Tomcat...

	rem -- tomcat service START -----------------------------------------------------
	set "CLASSPATH=%TOMCAT_HOME%\bin\bootstrap.jar;%TOMCAT_HOME%\bin\tomcat-juli.jar"
	rem %TOMCAT_EXE% //DS//%TOMCAT_SERVICE_NAME% 删除服务
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
	rem echo 安装Tomcat服务失败！
	rem :installedTomcat
	echo 安装Tomcat服务成功！
	net start %TOMCAT_SERVICE_NAME%
	rem -- tomcat service END -----------------------------------------------------
	goto START_TOMCAT_DONE

	:START_TOMCAT_DONE
	echo Tomcat启动成功！
)

pause

:::::::::::::::::::::::::::
:: All done, have fun :) ::
:::::::::::::::::::::::::::