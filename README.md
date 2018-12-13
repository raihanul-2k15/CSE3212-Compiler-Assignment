# CSE3212-Compiler-Assignment

This is my compiler assignment for my university compiler course
Even though it is a compiler course, this assignment is basically an interpreter.
It uses GNU flex and GNU bison

This simple parser can parse and execute Python like scripts.
Note that it is not totally python syntax.

# Features

1. Comments
2. Variables - string and number types
3. Assignment operations
4. print and println functions for printing to console
5. Arrays - number type only
6. Accessingand assigning array by index
7. For loops (only prints single expression)
8. if elif else ladder (only prints single expression)
9. User input - number only

Note that control flow statements only support a single expression to be printed. They don't support blocks of statements
Note that the parser takes source code input from input.txt and takes user input from standard input. You can easily change them in ezPy.y file

# How to run on windows

1. Run do.bat and enter ezPy.l and ezPy.y

Alternatively you can run the commands manually
	flex ezPy.l
	bison -d ezPy.y
	gcc ezPy.tab.c lex.yy.c -o parser.exe
	parser.exe

