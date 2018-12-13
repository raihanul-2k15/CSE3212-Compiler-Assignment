%{
	#include <malloc.h>
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include <math.h>
	
	struct _if_elif_chain_node {
		int condition;
		double content;
		struct _if_elif_chain_node *next;
	};
	typedef struct _if_elif_chain_node _if_elif_chain_node;
	
	struct _expr_list_node {
		int arrsize;
		double *arrptr;
	};
	typedef struct _expr_list_node _expr_list_node;
	
	struct symrec {
	  char *name;
	  int type;
	  union {
		double var;
		double (*fnctptr)(); 
		double *arrptr;
		char *strptr;
	  } value;
	  int arrsize;
	  struct symrec *next;
	};
	typedef struct symrec symrec;
	
	#define RECTYPE_ARR 400
	#define RECTYPE_VAR 500
	#define RECTYPE_FN 600
	#define RECTYPE_STR 700
	#define RECTYPE_NOTKNOWNYET 800
	symrec *sym_table = (symrec *)0;
	symrec *putsym (char *sym_name, int sym_type);
	symrec *getsym (char *sym_name);
	
	double read_dbl(char *);
	double factorial(double);
	double abs_wrapper(double);
	double print_ln_str(char*);
	double print_ln_dbl(double);
	double print_str(char*);
	double print_dbl(double);
	
	
	extern int yylex();
	extern char *yytext;
	extern FILE* yyin;
	extern FILE* yyout;

	
%}

%union {
char *str;
double 	dbl;
int itg;
struct 	symrec  *tptr;
struct _expr_list_node *elptr;
struct _if_elif_chain_node *ieptr;
}

%token IMPORT FROM AS IF ELIF ELSE FALSE TRUE FOR WHILE BREAK CONTINUE DEF RETURN CLASS DEL TRY EXCEPT FINALLY IN PASS AE SE ME DE EE NE GE LE AND OR NOT DD SS
%token CMX
%token <itg>  INT
%token <dbl>  FLT
%token <tptr> ID
%token <str> STR
%type <itg> bxpr;
%type <dbl>  expr
%type <elptr> expr_list
%type <ieptr> if_elif_chain

%left OR
%left AND
%left '<' '>' EE LE GE NE
%left NOT
%right '=' AE SE ME DE
%left '-' '+'
%left '*' '/'
%left '%'

%%
program:	/* empty */
	| program stmt
;
stmt: ';'
	| expr ';'	{ /*printf("%.10g\n", $1);*/ }
	| ID '=' STR ';'	{
		if ($1->type == RECTYPE_FN) {
			printf("%s is a function\n", $1->name);
		} else {
			$1->type = RECTYPE_STR;
			$1->value.strptr = $3;
		}
	}
	| ID '=' expr ';'	{
		if ($1->type == RECTYPE_FN) {
			printf("%s is a function\n", $1->name);
		} else {
			$1->type = RECTYPE_VAR;
			$1->value.var = $3;
		}
	}
	| ID AE expr ';'	{
		if ($1->type != RECTYPE_VAR) {
			printf("%s is not a variable\n", $1->name);
		} else {
			$1->value.var += $3;
		}
	}
	| ID SE expr ';'	{
		if ($1->type != RECTYPE_VAR) {
			printf("%s is not a variable\n", $1->name);
		} else {
			$1->value.var -= $3;
		}
	}
	| ID ME expr ';'	{
		if ($1->type != RECTYPE_VAR) {
			printf("%s is not a variable\n", $1->name);
		} else {
			$1->value.var *= $3;
		}
	}
	| ID DE expr ';'	{
		if ($1->type != RECTYPE_VAR) {
			printf("%s is not a variable\n", $1->name);
		} else {
			$1->value.var /= $3;
		}
	}
	| ID '=' '[' expr_list ']' ';' {
		if ($1->type == RECTYPE_FN) {
			printf("%s is a function", $1->name);
		} else {
			$1->type = RECTYPE_ARR;
			$1->value.arrptr = $4->arrptr;
			$1->arrsize = $4->arrsize;
		}
	}
	| ID '[' expr ']' '=' expr {
		if ($1->type == RECTYPE_ARR) {
			int index = (int) round($3);
			if (index >= 0 && index < $1->arrsize)
				$1->value.arrptr[index] = $6;
			else
				printf("Index %d Out of Bounds in array %s[%d..%d]\n", index, $1->name, 0, $1->arrsize-1);
		}
		else
			printf("%s is not an array\n", $1->name);
	}
	| FOR ID IN ID ':' ID SS {
		if ($2->type != RECTYPE_FN) $2->type = RECTYPE_VAR;
		if ($2->type == RECTYPE_VAR && $4->type == RECTYPE_ARR && $6->type == RECTYPE_VAR) {
			int i;
			for (i = 0; i<$4->arrsize; i++) {
				$2->value.var = $4->value.arrptr[i];
				print_dbl($6->value.var);
			}
		} else
			printf("Error in for loop\n");
	}
	| FOR ID IN INT DD INT ':' ID SS {
		if ($2->type != RECTYPE_FN) $2->type = RECTYPE_VAR;
		if ($2->type == RECTYPE_VAR && $8->type == RECTYPE_VAR) {
			int i;
			int step = $4 < $6 ? 1 : -1;
			for (i = $4; i != $6; i+=step) {
				$2->value.var = i;
				print_dbl($8->value.var);
			}
			$2->value.var = i;
			print_dbl((double)$8->value.var);
		} else
			printf("Error in for loop\n");
	}
	| if_elif_chain	{
		_if_elif_chain_node* cur = $1;
		while (cur != NULL && !cur->condition) cur = cur->next;
		if (cur != NULL)
			print_dbl(cur->content);
	}
	| if_elif_chain ELSE ':' expr SS	{
		_if_elif_chain_node* cur = $1;
		while (cur != NULL && !cur->condition) cur = cur->next;
		if (cur != NULL)
			print_dbl(cur->content);
		else
			print_dbl($4);
	}
	| IF bxpr ':' IF bxpr ':' expr SS ELSE ':' expr SS SS ELSE ':' expr SS	{
		if ($2) {
			if ($5)
				print_dbl($7);
			else
				print_dbl($11);
		}
		else
			print_dbl($16);
	}
	| DEL ID ';'	{ $2->type = RECTYPE_NOTKNOWNYET; }
	| IMPORT ID	{ printf("Imported %s\n", $2->name); }
	| FROM ID IMPORT ID	{ printf("Imported %s from %s\n", $4->name, $2->name); }
	| FROM ID IMPORT ID AS ID	{ printf("Imported %s from %s as %s\n", $4->name, $2->name, $6->name); }
	| DEF ID ':' PASS SS	{ printf("Uselss function defeind :)\n"); }
	| CLASS ID ':' PASS SS	{ printf("Uselss class defeind :)\n"); }
	| BREAK ';'	{ printf("No loop to break out of :)\n"); }
	| CONTINUE ';'	{ printf("No loop to continue on with :)\n"); }
	| RETURN ';'	{ printf("Nowhere to return to :)\n"); }
;
if_elif_chain: IF bxpr ':' expr SS 	{
		$$ = (_if_elif_chain_node*) malloc(sizeof(_if_elif_chain_node));
		$$->condition = $2;
		$$->content = $4;
		$$->next = NULL;
	}
	| if_elif_chain ELIF bxpr ':' expr SS	{
		_if_elif_chain_node* newptr = (_if_elif_chain_node*) malloc(sizeof(_if_elif_chain_node));
		newptr->condition = $3;
		newptr->content = $5;
		newptr->next = NULL;
		// traversing for end of linked list
		_if_elif_chain_node* trav = $1;
		while (trav->next != NULL) trav = trav->next;
		trav->next = newptr;
		$$ = $1;
	}
;
expr_list: expr	{
		$$ = (_expr_list_node*) malloc(sizeof(_expr_list_node));
		$$->arrsize = 1;
		$$->arrptr = (double *)malloc(1 * sizeof(double));
		$$->arrptr[0] = $1;
	}
	| expr_list ',' expr	{
		$1->arrsize++;
		double *newptr = (double*) realloc($1->arrptr, $1->arrsize * sizeof(double));
		newptr[$1->arrsize - 1] = $3;
		// TODO: fix: undefined contents after realloc
		$1->arrptr = newptr;
		$$ = $1;
	}
;
expr: expr '+' expr		{ $$ = $1 + $3; }
	| expr '-' expr		{ $$ = $1 - $3; }
	| expr '*' expr		{ $$ = $1 * $3; }
	| expr '/' expr		{ $$ = $1 / $3; }
	| expr '%' expr		{ $$ = $1 - (((int)$1 / (int)$3) * $3); }
	| '(' expr ')'		{ $$ = $2; }
	| INT				{ $$ = (double) yylval.itg; }
	| FLT				{ $$ = yylval.dbl; }
	| ID				{ 
		$$ = -9e15; // in case of error
		if ($1->type == RECTYPE_VAR)
			$$ = $1->value.var;
		else if ($1->type == RECTYPE_FN) 
			printf("Expression expected after function %s\n", $1->name);
		else 
			printf("Variable %s not declared\n", $1->name);
	}
	| ID '[' expr ']' {
		$$ = -9e15; // in case index is out of range
		if ($1->type == RECTYPE_ARR) {
			int index = (int) round($3);
			if (index >= 0 && index < $1->arrsize)
				$$ = $1->value.arrptr[index];
			else
				printf("Index %d Out of Bounds in array %s[%d..%d]\n", index, $1->name, 0, $1->arrsize-1);
		}
		else
			printf("%s is not an array\n", $1->name);
	}
	| ID expr	{ 
		if ($1->type == RECTYPE_FN) {
			if (strcmp($1->name, "print") == 0)
				$$ = print_dbl($2);
			else if (strcmp($1->name, "println") == 0)
				$$ = print_ln_dbl($2);
			else if (strcmp($1->name, "read") == 0)
				printf("Read expects string parameter as a message.\n");
			else
				$$ = (*($1->value.fnctptr))($2); 
		}
		else printf("%s is not a function\n", $1->name);
	}
	| ID STR { 
		if ($1->type == RECTYPE_FN) {
			if (strcmp($1->name, "print") == 0)
				$$ = print_str($2);
			else if (strcmp($1->name, "println") == 0)
				$$ = print_ln_str($2);
			else if (strcmp($1->name, "read") == 0)
				$$ = read_dbl($2);
			else
				$$ = (*($1->value.fnctptr))($2); 
		}
		else printf("%s is not a function\n", $1->name);
	}
	| ID '~' ID  { 
		if ($1->type == RECTYPE_FN) {
			if ($3->type == RECTYPE_STR) {
				if (strcmp($1->name, "print") == 0)
					$$ = print_str($3->value.strptr);
				else if (strcmp($1->name, "println") == 0)
					$$ = print_ln_str($3->value.strptr);
				else if (strcmp($1->name, "read") == 0)
					$$ = read_dbl($3->value.strptr);
				else printf("Function %s is not applicable on a string\n", $1->name);
			}
			else printf("%s is not a string\n", $3->name);
		}
		else printf("%s is not a function\n", $1->name);
	}
;
bxpr: expr '<' expr  { $$ = $1 < $3; }
	| expr '>' expr  { $$ = $1 > $3; }
	| expr EE expr	 { $$ = $1 == $3; }
	| expr LE expr	 { $$ = $1 <= $3; }
	| expr GE expr	 { $$ = $1 >= $3; }
	| expr NE expr	 { $$ = $1 != $3; }
	| bxpr AND bxpr	 { $$ = $1 && $3; }
	| bxpr OR bxpr   { $$ = $1 || $3; }
	| NOT bxpr		 { $$ = !$2; }
	| '(' bxpr ')'	 { $$ = $2; }
	| TRUE			 { $$ = 1; }
	| FALSE			 { $$ = 0; }
	| expr 			 { $$ = (int) $1; }
%%
	symrec *putsym (char *sym_name, int sym_type) {
	  symrec *ptr;
	  ptr = (symrec *) malloc (sizeof (symrec));
	  ptr->name = (char *) malloc (strlen (sym_name) + 1);
	  strcpy (ptr->name,sym_name);
	  ptr->type = sym_type;
	  ptr->value.var = 0; /* set value to 0 even if fctn.  */
	  ptr->next = (struct symrec *)sym_table;
	  sym_table = ptr;
	  return ptr;
	}

	symrec *getsym (char *sym_name)	{
	  symrec *ptr;
	  for (ptr = sym_table; ptr != (symrec *) 0;
		   ptr = (symrec *)ptr->next)
		if (strcmp (ptr->name,sym_name) == 0)
		  return ptr;
	  return NULL;
	}
	
	struct init {
	  char *fname;
	  double (*fnct)();
	};

	struct init arith_fncts[] = {
	  "sin", sin,
	  "cos", cos,
	  "tan", tan,
	  "sininv", asin,
	  "cosinv", acos,
	  "taninv", atan,
	  "ln", log,
	  "ePower", exp,
	  "sqrt", sqrt,
	  "abs", abs_wrapper,
	  "fact", factorial,
	  "read", 0,
	  "println", 0,
	  "print", 0,
	  0, 0
	};

	init_table () {
		int i;
		symrec *ptr;
		for (i = 0; arith_fncts[i].fname != 0; i++) {
			ptr = (symrec*) putsym (arith_fncts[i].fname, RECTYPE_FN);
			ptr->value.fnctptr = arith_fncts[i].fnct;
		}
	}

int yyerror(char *s) /* called by yyparse on error */
{
	printf("%s\n",s);
	return(0);
}

double read_dbl(char *msg) {
	double x;
	printf("%s", msg);
	scanf("%lf", &x);
	return x;
}

double factorial(double x) {
	int f=(int)x, i=(int) (x-1);
	for (; i>1; i--) f *= i;
	return (double) f;
}

double abs_wrapper(double x) {
	return abs(x);
}

double print_ln_str(char *arg) {
	return (double) printf("%s\n", arg);
}

double print_str(char *arg) {
	return (double) printf("%s", arg);
}

double print_ln_dbl(double arg) {
	return (double) printf("%.10g\n", arg);
}

double print_dbl(double arg) {
	return (double) printf("%.10g ", arg);
}

int main(void)
{
	yyin = fopen("input.txt", "r");
	//yyout = freopen("output.txt", "w", stdout);

	init_table();
	yyparse();

	fclose(yyin);
	//fclose(yyout);

	exit(0);
}