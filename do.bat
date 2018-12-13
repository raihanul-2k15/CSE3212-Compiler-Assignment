@ECHO OFF
SET /A argC=0
FOR %%x IN (%*) do SET /A argC+=1
CLS
IF %argC% EQU 0 (
    SET /p flex_fname="Enter flex .l filename: "
    SET /p bison_fname="Enter bison .y filename: "
) ELSE (
    IF %argC% EQU 1 (
        SET flex_fname = %1.l
        SET bison_fname = %1.y
    ) ELSE (
        SET flex_fname = %1
        SET bison_fname = %2
    )
)
ECHO Flexing %flex_fname% ...
flex %flex_fname%
IF NOT ERRORLEVEL 1 (
    ECHO Flex successful & ECHO.
    ECHO Bisoning %bison_fname% ....
    bison -d %bison_fname% -v
)
IF NOT ERRORLEVEL 1 (
    ECHO Compiling %bison_fname:.y=.tab.c% and lex.yy.c ...
    gcc %bison_fname:.y=.tab.c% lex.yy.c -o %bison_fname:.y=.exe%
)
IF NOT ERRORLEVEL 1 (
    ECHO Compilation successful & ECHO.
    ECHO Running %bison_fname:.y=.exe% ... & ECHO.
    %bison_fname:.y=.exe%
)
IF EXIST "lex.yy.c" (
    del lex.yy.c
)
IF EXIST %bison_fname:.y=.tab.h% (
    del %bison_fname:.y=.tab.h%
)
IF EXIST %bison_fname:.y=.tab.c% (
    del %bison_fname:.y=.tab.c%
)
PAUSE
:: ************************************************************************