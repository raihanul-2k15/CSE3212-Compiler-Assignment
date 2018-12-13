%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "ezPy.tab.h"
	extern YYSTYPE yylval;

	extern struct symrec *putsym (char *sym_name, int sym_type);
	extern struct symrec *getsym (char *sym_name);
	typedef struct symrec symrec;
	#define RECTYPE_NOTKNOWNYET 700
	
	char c;
%}

%option noyywrap

ID	[a-zA-Z_][a-zA-Z0-9_]*
DIG	[0-9]
INT_LIT	-?{DIG}+
FLT_LIT	-?{DIG}+"."{DIG}+
CMX_LIT	{FLT_LIT}?[ \t]*[-+][ \t]*{DIG}+([.]{DIG}+)?([eE][-+]?{DIG}+)?j
STR_LIT	\"([^"\n\\]|\\.)*\"|\'([^'\n\\]|\\.)*\'
MLS_LIT	\"\"\"([^"\\]|\\.)*\"\"\"

%%
#	{ while ((c = input())!='\n') /* eat comment */ ; }
import	{ return IMPORT; }
from	{ return FROM; }
as	{ return AS; }
if	{ return IF; }
elif	{ return ELIF; }
else	{ return ELSE; }
false	{ return FALSE; }
true	{ return TRUE; }
for	{ return FOR; }
while	{ return WHILE; }
break	{ return BREAK; }
continue	{ return CONTINUE; }
def	{ return DEF; }
return	{ return RETURN; }
class	{ return CLASS; }
del	{ return DEL; }
try	{ return TRY; }
except	{ return EXCEPT; }
finally	{ return FINALLY; }
in	{ return IN; }
pass	{ return PASS; }
{STR_LIT}	{
	int len = strlen(yytext);
	yytext[len-1] = '\0';
	char* s = (char *) malloc (len - 2 + 1);
	strcpy(s, yytext + 1);
	yylval.str = s;
	yytext[len-1] = '"';
	return STR;
}
{MLS_LIT}	{ return STR; }
{INT_LIT}	{ yylval.itg = atoi(yytext); return INT; }
{FLT_LIT}	{ yylval.dbl = atof(yytext); return FLT; }
{CMX_LIT}	{ return CMX; }
"+"	{ return *yytext; }
"-"	{ return *yytext; }
"*"	{ return *yytext; }
"/"	{ return *yytext; }
"%"	{ return *yytext; }

"="	{ return *yytext; }
"+="	{ return AE; }
"-="	{ return SE; }
"*="	{ return ME; }
"/"=	{ return DE; }

"=="	{ return EE; }
"!="	{ return NE; }
">"	{ return '>'; }
"<"	{ return '<'; }
">="	{ return GE; }
"<="	{ return LE; }

and	{ return AND; }
or	{ return OR; }
not 	{ return NOT; }

{ID}		{ 
	symrec *ptr = getsym(yytext);
	if (ptr == NULL) {
		ptr = putsym(yytext, RECTYPE_NOTKNOWNYET);
	}
	yylval.tptr = ptr;
	return ID; 
}
","	{ return ','; }
";"	{ return ';'; }
":"	{ return ':'; }
"("	{ return '('; }
")"	{ return ')'; }
"{"	{ return '{'; }
"}"	{ return '}'; }
"["	{ return '['; }
"]"	{ return ']'; }
"."	{ return '.'; }
"~" { return '~'; }
".."	{ return DD; }
";;"	{ return SS; }
[ \t\n]*	{ /* ignore whitespace */ }
.		{ printf("Cannot match %s to any token patter\n", yytext); }
%%