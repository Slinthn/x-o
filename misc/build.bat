@echo off

mkdir ..\build
cls
pushd ..\build
fasm ../src/win64_main.s win64_main.exe
popd
