@echo off
SET THEFILE=u_socketclient
echo Assembling %THEFILE%
C:\pp\bin\i386-win32\arm-wince-as.exe -mfpu=softvfp -o D:\wnhoo\PDATest\Client\bin\arm-wince\u_SocketClient.o D:\wnhoo\PDATest\Client\bin\arm-wince\u_SocketClient.s
if errorlevel 1 goto asmend
Del D:\wnhoo\PDATest\Client\bin\arm-wince\u_SocketClient.s
SET THEFILE=u_func
echo Assembling %THEFILE%
C:\pp\bin\i386-win32\arm-wince-as.exe -mfpu=softvfp -o D:\wnhoo\PDATest\Client\bin\arm-wince\u_Func.o D:\wnhoo\PDATest\Client\bin\arm-wince\u_Func.s
if errorlevel 1 goto asmend
Del D:\wnhoo\PDATest\Client\bin\arm-wince\u_Func.s
SET THEFILE=u_readerthread
echo Assembling %THEFILE%
C:\pp\bin\i386-win32\arm-wince-as.exe -mfpu=softvfp -o D:\wnhoo\PDATest\Client\bin\arm-wince\u_ReaderThread.o D:\wnhoo\PDATest\Client\bin\arm-wince\u_ReaderThread.s
if errorlevel 1 goto asmend
Del D:\wnhoo\PDATest\Client\bin\arm-wince\u_ReaderThread.s
SET THEFILE=unit1
echo Assembling %THEFILE%
C:\pp\bin\i386-win32\arm-wince-as.exe -mfpu=softvfp -o D:\wnhoo\PDATest\Client\bin\arm-wince\unit1.o D:\wnhoo\PDATest\Client\bin\arm-wince\unit1.s
if errorlevel 1 goto asmend
Del D:\wnhoo\PDATest\Client\bin\arm-wince\unit1.s
SET THEFILE=project1
echo Assembling %THEFILE%
C:\pp\bin\i386-win32\arm-wince-as.exe -mfpu=softvfp -o D:\wnhoo\PDATest\Client\bin\arm-wince\project1.o D:\wnhoo\PDATest\Client\bin\arm-wince\project1.s
if errorlevel 1 goto asmend
Del D:\wnhoo\PDATest\Client\bin\arm-wince\project1.s
SET THEFILE=D:\wnhoo\PDATest\Client\bin\project1.exe
echo Linking %THEFILE%
C:\pp\bin\i386-win32\arm-wince-ld.exe -m arm_wince_pe  --gc-sections  -s --subsystem wince --entry=_WinMainCRTStartup    -o D:\wnhoo\PDATest\Client\bin\project1.exe D:\wnhoo\PDATest\Client\bin\link.res
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end
