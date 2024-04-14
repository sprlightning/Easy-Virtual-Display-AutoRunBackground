@echo off
rem 关闭echo命令显示

chcp 65001
rem 强制开启UTF-8，以支持中文显示

rem 为本脚本获取管理员权限
ver | findstr "10\.[0-9]\.[0-9]*" >nul && goto powershellAdmin

:mshtaAdmin
rem 原理是利用mshta运行vbscript脚本给bat文件提权
rem 这里使用了前后带引号的%~dpnx0来表示当前脚本，比原版的短文件名%~s0更可靠
rem 这里使用了两次Net session，第二次是检测是否提权成功，如果提权失败则跳转到failed标签
rem 这有效避免了提权失败之后bat文件继续执行的问题
Net session >nul 2>&1 || mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c ""%~dpnx0""","","runas",1)(window.close)&&exit
Net session >nul 2>&1 || goto failed
goto Admin

:powershellAdmin
rem 原理是利用powershell给bat文件提权
rem 这里使用了两次Net session，第二次是检测是否提权成功，如果提权失败则跳转到failed标签
rem 这有效避免了提权失败之后bat文件继续执行的问题
Net session >nul 2>&1 || powershell start-process \"%0\" -verb runas && exit
Net session >nul 2>&1 || goto failed
goto Admin

:failed
echo 提权失败，可能是杀毒软件拦截了提权操作，或者您没有同意UAC提权申请。
echo 建议您右键点击此脚本，选择“以管理员身份运行”。
echo 按任意键退出。
pause >nul
exit

:Admin
echo 本脚本处理所在路径：%0
echo 已获取管理员权限！
ping 127.0.0.1 -n 1 > nul
echo 如果此窗口标题处显示“管理员”字样，那就说明提权成功了。

echo 尝试将工作目录转移到软件目录...
cd /d %~dp0
rem 切换软件工作目录到软件所在文件夹
ping 127.0.0.1 -n 1 > nul
echo 目录转移成功！

echo Designed by HPL at 2024年4月15日02点36分
echo:

set TITLE=STOP_EasyVirtualDisplay
set executable=VirtualDisplayProject.exe

title %TITLE%

tasklist|findstr /i "%executable%"
if errorlevel 1 (
echo [%DATE%%TIME:~0,8%]未发现正在运行的%executable%！
ping 127.0.0.1 -n 1 > nul
msg %username% /time:6 "虚拟屏%executable%未开启"
goto end
)
if errorlevel 0 (
echo [%DATE%%TIME:~0,8%]已找到%executable%，将在1s后关闭%executable%！
echo --------------------------------------------------------------------------------
ping 127.0.0.1 -n 1 > nul
goto stop
)

:stop
taskkill /f /im %executable%

msg %username% /time:6 "虚拟屏%executable%已关闭"

:end
exit