%{
        #include<stdio.h>
        #include<stdlib.h>
        #include<string.h>
        #include<math.h>
        int yylex(void);
        void yyerror(char *);
        extern FILE *yyin;
        extern FILE *yyout;
        FILE *yyTreeOut;
        FILE *yyError;
        int sym[1000] = {0}; // Initialize to zero
        int flag = 1;
        int level = 0;
        int f=0;

          void print_tree( const char* label) {
            for (int i = 0; i < level; ++i) {
                fprintf(yyTreeOut, "  ");  // Indentation for tree levels
            }
            fprintf(yyTreeOut, "%s\n", label);  // Print the node label
            level ++;
        }
%}

%token MAIN INT FLOAT CHAR NUM VAR IF ELSE LB RB PRINT WHILE
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%right  '='
%left '-' '+' '>' '<'
%left '*' '/' '%'
%left NEG


%%

// Program structure
program: MAIN '{' declarations statements '}'
       { fprintf(yyout, "Program parsed successfully\n"); 
                  print_tree( "Program parsed successfully");
};

declarations: declarations declaration 
            | /* empty */;

declaration: INT VAR ';'       { sym[$2] = 0;   print_tree("Declaration: INT VAR");}
           | FLOAT VAR ';'     { sym[$2] = 0;   print_tree("Declaration: FLOAT VAR");
}
           | CHAR VAR ';'      { sym[$2] = 0;   print_tree("Declaration: CHAR VAR");
};

statements: statements statement
          | /* empty */;

statement: assignment
            | condition
            | PRINT '(' expression ')' ';' { fprintf(yyout, "Print: %d\n", $3); print_tree("Print Statement");}      
;

assignment: VAR '=' expression ';'      { sym[$1] = $3; }

        | VAR '+''=' NUM ';'         {
                                sym[$1]=sym[$1]+$4;
                        }
        | VAR '+''=' VAR ';'         {
                                sym[$1]=sym[$1]+sym[$4];
                        }

        | VAR '-''=' NUM ';'         {
                                sym[$1]=sym[$1]-$4;
                        }
        | VAR '-''=' VAR ';'         {
                                sym[$1]=sym[$1]-sym[$4];
                        }

        | VAR '*''=' NUM ';'         {
                                sym[$1]=sym[$1]*$4;
                        }
        | VAR '*''=' VAR ';'         {
                                    sym[$1]=sym[$1]*sym[$4];
                        }
        | VAR '/''=' NUM ';'         {
                                        if($4){
                                                sym[$1]=sym[$1]/$4;
				  	}
				  	else{
						$$ = 0;
						fprintf(yyError,"\nRuntime Error: Division by zero\n\t");
				  	} 	
                        }
        | VAR '/''=' VAR ';'         {
                                        if(sym[$4]){
                                                sym[$1]=sym[$1]/sym[$4];
				  	}
				  	else{
						$$ = 0;
						fprintf(yyError,"\nRuntime Error: Division by zero\n\t");
				  	} 	
                        }

condition: 
        IF '(' expression ')' '{' statements '}' 
          {
            fprintf(yyout, "\nIF Condition Found\n");
            if ($3) {
                fprintf(yyout, "IF is TRUE: Executing Statements\n");
                $$ = 1; 
            } else {
                fprintf(yyout, "IF is FALSE: Skipping Statements\n");
                $$ = 0; 
            }
          }
        | IF '(' expression ')' '{' statements '}' ELSE '{' statements '}' 
          {
            fprintf(yyout, "\nIF ELSE Condition Found\n");
            if ($3 != 0 ) { 
                fprintf(yyout, "IF is TRUE: Executing IF Statements\n");
                //execute_statements($6);
                $$ = 1;
                f=1; 
            } else {
                if(f!=1){
                fprintf(yyout, "ELSE is TRUE: Executing ELSE Statements\n");
                //execute_statements($10);
                $$ = 0; 
                }
        
            }
          };



expression: NUM                      { $$ = $1; }
            | VAR                      { $$ = sym[$1]; }
            | expression '*' expression           { $$ = $1 * $3; }
            | expression '/' expression           { $$ = $1 / $3; }
            | expression '+' expression           { $$ = $1 + $3; }
            | expression '-' expression           { $$ = $1 - $3; }
            | '(' expression ')'            { $$ = $2; };
            | expression '%' expression	{ if($3){
				     		fprintf(yyout,"\nMOD :%d % %d \n",$1,$3,$1 % $3);
				     		$$ = $1 % $3;
				     					
				  	}
				  	else{
						$$ = 0;
						fprintf(yyError,"\nRuntime Error: MOD by zero\n");
				  	} 	
				}
	        | expression '^' expression	{  $$ = pow($1 , $3);}
            	| expression '<' expression	{ if($1 < $3) 
                                                {$$=1 ;}
                                                
                                                else
                                                {
                                                $$=0;
                                                }
                                                 }
	
	        | expression '>' expression	{if($1 > $3) 
                                                $$=1 ;
                                                else
                                                $$=0; }
            | expression '=''=' expression  {if($1 == $3) 
                                                $$=1 ;
                                                else
                                                $$=0; }
            | expression '!''=' expression {if($1 != $3) 
                                                $$=1;
                                                else
                                                $$=0; }
            | '!' expression  {
                                   
                                        $$ = !$2;                                        
                                }


%%

void yyerror(char *s) {
    fprintf(yyError, "%s\n", s);
}

int main(void) {
    yyin = fopen("input.txt", "r");
    yyout = fopen("output.txt", "w");
    yyError = fopen("outError.txt", "w");
    yyTreeOut = fopen("parse_tree.txt", "w");
    yyparse();  

    fclose(yyin);
    fclose(yyout);
    fclose(yyError);
    return 0;
}