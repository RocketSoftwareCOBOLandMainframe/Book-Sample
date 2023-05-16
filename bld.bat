@echo off
set COBOL_ARGS=nologo stderr

rd /s/q bin obj 2> nul
md bin obj
cobol src\book.cbl %COBOL_ARGS%; 2> nul
cobol src\cli.cbl %COBOL_ARGS%; 2> nul
cbllink -Mcli -Obin\book.exe obj\book.obj obj\cli.obj > nul
