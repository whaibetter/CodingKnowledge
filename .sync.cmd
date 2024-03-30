@echo off

setlocal enabledelayedexpansion

git add .

:: 获取暂存区中的更改文件列表
for /f "delims=" %%a in ('git diff --cached --name-only') do (
    set "changed_files=!changed_files! %%a"
)

:: 如果没有文件更改，则设置一个默认的提交信息
if "%changed_files%"=="" (
    set "commit_message=No files changed"
) else (
    :: 设置提交信息，包括修改的文件列表
    set "commit_message=Updated files: %changed_files%"
)

:: 执行git commit
git commit -m "%commit_message%"
echo "git push origin master"
git push origin master
echo "git push gitee master"
git push gitee master
echo "git push github master"
git push github master

endlocal