@echo off
setlocal enabledelayedexpansion

REM file to do the diff of 2 git branches
set gitSourceDir=C:\Users\user1\Documents\GitHub\SimpleFeedback
set gitTargetDir=C:\Work_GIT\SimpleFeedback
set master=master
set branch1=feature/v2.0.0
set outputFile=MasterFeatureDiff.txt

echo one: %sourceDir%
echo two: %master%
echo three: %branch1%
echo ------

cd %gitSourceDir%
git diff --name-status %master%..%branch1% >%gitSourceDir%\%outputFile%

cd C:\Work_GIT\SimpleFeedback
REM for /F "eol=; tokens=2,3* delims=," %i in (%outputFile%) do @echo %i %j %k
REM for /F %%G in  (%outputFile%) do echo %%G
for /F "tokens=2" %%G in  (%outputFile%) do (
	set file1=%%G 
    set file2=!file1:/=\!
    echo !file2!
	echo f | xcopy /f /y %gitSourceDir%\!file2! %gitTargetDir%\!file2!
	)


