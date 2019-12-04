%{
	#include<stdio.h>
	#include<defs.h>
	#include<y.tab.h>

	int for_detector = 0;
	int direct_declarator = 0;
%}
%union{
	struct {
		int count_p;
		int count_m;
		int type;
		int size;
		int val;
		float fval;
		void * sentry;
		int t[4];
		char* string_val;
	}vv;

}

%token FOR WHILE DO IF ELSE RETURN
%token INT VOID FLOAT
%token CONST_Q //type qualifier  const int...
%token <vv> CONST IDENTIFIER
%token STRING //const = 10 ...etc
%token '='
%token '(' ')' ';' '}' '{' ']' '['
%token AND_OP OR_OP LE_OP GE_OP EQ_OP NE_OP
%type <vv> type_specifier declaration_specifiers
%type <vv> pointer direct_declarator declarator init_declarator
%start declaration_list
%%


declaration_list
	: declaration
	| declaration_list declaration
	;//=================================================USED
declaration
	: declaration_specifiers ';'
	//we have type in declaration_specifiers
	// check if declaration_specifier type fits into all items of init_declarator_list
	| declaration_specifiers init_declarator_list ';'
	; //==========================================================USED

declaration_specifiers
	:
	type_specifier {
		 $$.type = $1.type;
		 //TODO check composed types=====!
	}
	//| type_specifier declaration_specifiers // int ..
	//| type_qualifier declaration_specifiers //const int ...
	;
//| storage_class_specifier
//| storage_class_specifier declaration_specifiers
//=======================================================USED
type_specifier
	: VOID {
		$$.type = VOID;
		//printf("TYPE : %d",$$);
	}
	| INT  {
		$$.type = INT;
		//printf("TYPE : %d",$$);
	}
	| FLOAT {
		$$.type = FLOAT;
		//printf("TYPE : %d",$$);
	}
	;

init_declarator_list
	: init_declarator {
		symbol_p varp = (symbol_p) $1.sentry;
		int countp = $1.count_p; //TODO maybe 0
		int countm = $1.count_m;
		if(countp > 0 || countm > 0){
			varp->type = VAR_ARR;
			varp->arr.dimention_m = countm;
			varp->arr.dimention_p = countp;
			for(int pp = 0;pp<4;pp++)
				varp->arr.size[pp] = $1.t[pp];

		}


	}
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator {
		for(int l = 0;l<4;l++)
			$$.t[l] = $1.t[l];
		$$.sentry = $1.sentry;
		$$.count_p  = $1.count_p; //TODO maybe 0
		$$.count_m  = $1.count_m;
	}
	| declarator '=' initializer {
		for(int l = 0;l<4;l++)
			$$.t[l] = $1.t[l];
		$$.sentry = $1.sentry;
		$$.count_p  = $1.count_p; //TODO maybe 0
		$$.count_m  = $1.count_m;
	}
	;
declarator
	: pointer direct_declarator {
		//printf("SIZE(%d) ",$1+$2);
		for(int l = 0;l<4;l++)
			$$.t[l] = $2.t[l];
		$$.sentry = $2.sentry;
		$$.count_p  = $1.count_p;
		$$.count_m  = $2.count_m;

	}
	| direct_declarator {
		for(int l = 0;l<4;l++)
			$$.t[l] = $1.t[l];
		$$.sentry = $1.sentry;
		$$.count_p  = $1.count_p; //TODO maybe 0
		$$.count_m  = $1.count_m;
		//printf("SIZE(%d) ",$1);

	}
	;

direct_declarator
	: IDENTIFIER {
		$$.count_p  = 0;
		$$.count_m  = 0;
		$$.sentry = $1.sentry;
	}
        //| direct_declarator '[' ']' {
        // 	$$.count_p = $1.count_p +1;
       // 	// TODO maybe add the array size
        //}
        | direct_declarator '[' CONST ']' {
         	//$$ = $1 +1;
        	$$.t[direct_declarator] = $3.val;
         	direct_declarator++;
		$$.count_m = direct_declarator;

        }
        ;

pointer
	: '*'{
		$$.count_p = 1;
	}
	//| '*' type_qualifier_list
	| '*' pointer {
	 	$$.count_p = $2.count_p +1;
	}
	//| '*' type_qualifier_list pointer
	;


initializer
	:primary_expression
	//: assignment_expression TODO change later
	| '{' initializer_list '}'
	//| '{' initializer_list ',' '}'
	;
initializer_list
	: initializer
	| initializer_list ',' initializer
	;
primary_expression
	: IDENTIFIER
	| CONST
	| STRING
	//| '(' expression ')'
	;
//type_qualifier_list
//	: type_qualifier
//	| type_qualifier_list type_qualifier
//	;
//type_qualifier
//	: CONST_Q
//	;





%%

int yyerror(const char *str)
{
	printf("error : %s\tline : %d\n",str,line_counter);
	return -1;
}

int yywrap()
{
return 1;
}