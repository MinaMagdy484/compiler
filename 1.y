%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yylex(void);
void yyerror(char *s);
extern FILE *yyin;
extern FILE *yyout;
FILE *yyTreeOut;
FILE *yyError;
float sym[100] = {0}; 
int flag = 1;
int level = 0; 

 void print_tree(const char *label) {
        for (int i = 0; i < level; ++i) {
            fprintf(yyTreeOut, " ||| ");  // Indentation for tree levels
        }
        fprintf(yyTreeOut, "%s\n", label);  // Print the node label
    }

    void print_leaf(const char *label, int value) {
        for (int i = 0; i < level; ++i) {
            fprintf(yyTreeOut, "     ");
        }
        fprintf(yyTreeOut, "%s  %d\n", label, value);
    }

void BEGIN_RULE(int level_increment) { level += level_increment ; }
void END_RULE(int level_decrement) { level -= level_decrement ; }

%}

%token MAIN INT FLOAT CHAR NUM VAR IF ELSE LB RB PRINT WHILE FOR
%right '='
%left '-' '+' '>' '<'
%left '*' '/' '%'
%left NEG


%%

// Program structure
program: MAIN '{' declarations statements '}'
       { 
           fprintf(yyout, "Program parsed successfully\n"); 
           print_tree("Start Program");
           level++;
           print_tree("Main Block");
           level--;
       };

declarations: declarations declaration 
            { 
                BEGIN_RULE(1);
                print_tree("declarations---> declarations declaration");
                END_RULE(1);
            }
            | /* empty */ 
            { 
                BEGIN_RULE(1);
                print_tree("declarations---> empty");
                END_RULE(1);
            };

declaration: INT VAR ';'       
           { 
               sym[$2] = 0; 
                      level++;
                      print_tree("declaration -->") ;
                      level+=2;
                      print_leaf("int variable ",sym[$2]);
                      level-=3;
                      
           }
           | FLOAT VAR ';'     
           { 
               sym[$2] = 0; 
                      level++;
                      print_tree("declaration -->") ;
                      level+=2;
                      print_leaf("int variable ",sym[$2]);
                      level-=3;     
            }
           | CHAR VAR ';'      
           { 
                sym[$2] = 0; 
                      level++;
                      print_tree("declaration -->") ;
                      level+=2;
                      print_leaf("int variable ",sym[$2]);
                      level-=3;       
                        };

statements: statements statement
          { 
              BEGIN_RULE(1);
              print_tree("statements---> statements statement");
              END_RULE(1);
          }
          | /* empty */ 
          { 
              BEGIN_RULE(1);
              print_tree("statements---> empty");
              END_RULE(1);
          };

statement: assignment
            { 
                BEGIN_RULE(1);
                print_tree("statement--> assignment");
                END_RULE(1);
            }
            | condition
            { 
                BEGIN_RULE(1);
                print_tree("statement--> condition");
                END_RULE(1);
            }
            | PRINT '(' expression ')' ';' 
            { 
                BEGIN_RULE(1);

                fprintf(yyout, "Print: %d\n", $3); 
                level++;
                print_tree("statement--> condition");
                END_RULE(2);

            }
             
            ;

assignment: VAR '=' expression ';'      
            { 

                sym[$1] = $3; 
            level++;
            print_tree("assignment-- > " );
            level+=2 ;
           print_leaf("Var =",$3 );

            level-=3;

            }
            | VAR '+' '=' NUM ';'         
            { 
             sym[$1] += $4; 
            level++;
            print_tree("VAR += -- > " );
            level+=2 ;
            print_leaf("VAR =",sym[$1]);

            level+=2 ;
            print_leaf("NUM =",$4 );

            level-=5;
            }

            | VAR '+' '=' VAR ';'         
            {                 
              sym[$1] += sym[$4]; 

            level++;
            print_tree("VAR += -- > " );
            level+=2 ;           
            print_leaf("VAR =",sym[$1]);
            level+=2 ;
            print_leaf("VAR =",sym[$4] );
            level-=5;
            }

            | VAR '-' '=' NUM ';'         
            {
            sym[$1] -= $4; 

            level++;
            print_tree("VAR -= -- > " );
            level+=2 ;          
           print_leaf("NUM =",$4);
            level+=2 ;           
          print_leaf("VAR =",sym[$1] );
            level-=5;

            }
            | VAR '-' '=' VAR ';'         
            {                 sym[$1] -= sym[$4]; 

            level++;
            print_tree("VAR -= -- > " );
            level+=2 ;
          print_leaf("VAR =",sym[$4]);

            level+=2 ;
           print_leaf("VAR =",sym[$1] );

            level-=5;
            }


            
            | VAR '*' '=' NUM ';'         
            {                 sym[$1] *= $4; 

            level++;
            print_tree("VAR *= -- > " );
            level+=2 ;
           print_leaf("NUM=",$4);

            level+=2 ;
            print_leaf("VAR =",sym[$1] );

            level-=5;
            }
            
            | VAR '*' '=' VAR ';'         
            {                 sym[$1] *= sym[$4]; 
            level++;
            print_tree("VAR" );
            level+=2 ;
            print_leaf("VAR=",sym[$4]);

            level+=2 ;
            print_leaf("VAR =",sym[$1] );

            level-=5;
            }
            | VAR '/' '=' NUM ';'         
            { 
                if ($4) {
                    sym[$1] /= $4; 
            level++;
            print_tree("VAR /= -- > " );
            level+=2 ;
                       print_leaf("NUM=",$4);

            level+=2 ;
                       print_leaf("VAR =",sym[$1] );

            level-=5;
            } else {
                    fprintf(yyError, "\nRuntime Error: Division by zero\n");
                }
            }
            | VAR '/' '=' VAR ';'         
            { 
                if (sym[$4]) {
                    sym[$1] /= sym[$4]; 
            level++;
            print_tree("VAR /= -- > " );
            level+=2 ;
                       print_leaf("VAR=",sym[$4]);

            level+=2 ;
                       print_leaf("VAR =",sym[$1] );

            level-=5;
                } else {
                    fprintf(yyError, "\nRuntime Error: Division by zero\n");
                }
            }
           |VAR '-''-' ';' {sym[$1]=sym[$1]-1;
           $$ = sym[$1] ;
           print_tree("Decrement variable (--)");
            level++;
            print_tree("VAR--");
            level +=2 ;
            print_leaf("VAR",sym[$1]);
            level -= 3;}

           |VAR '+''+' ';' {
            sym[$1]=sym[$1]+1;
           $$ = sym[$1] ;
           print_tree("increment variable (++)");
            level++;
            print_tree("VAR++");
            level+=2 ;
            print_leaf("VAR",sym[$1]);
            level -= 3;} 
            
            
            ;

condition: 
        IF '(' expression ')' '{' statements '}' 
          {
            fprintf(yyout, "\nIF Condition Found\n");
                        print_tree("IF");
              level++;
              print_tree("Condition");
              level++;
              print_tree("Expression");
              level++; // Reset after expression
              print_tree("Body");
              level++;
              print_tree("Statements");
            if ($3) {
                fprintf(yyout, "IF is TRUE: Executing Statements\n");
                
                $$ = 1; 
                level+=2;
                print_tree("IF Condition: TRUE");
            } else {
                fprintf(yyout, "IF is FALSE: Skipping Statements\n");
                $$ = 0; 
                level+=2;
                print_tree("IF Condition: FALSE");
            }
            level -= 8;

          }
        | IF '(' expression ')' '{' statements '}' ELSE '{' statements '}' 
          {
            fprintf(yyout, "\nIF ELSE Condition Found\n");
            print_tree("IF-ELSE");
            level++;
            print_tree("Condition");
            level++;
            print_tree("Expression");
            level++;
            if ($3) { 
                fprintf(yyout, "IF is TRUE: Executing IF Statements\n");
                $$ = 1; 
                level+=2;
                print_tree("IF ELSE Condition: TRUE");
            } else {
                fprintf(yyout, "ELSE is TRUE: Executing ELSE Statements\n");
                $$ = 0; 
                level+=2;
                print_tree("IF ELSE Condition: FALSE");
            }
            level-=7;
          }

          |WHILE '(' NUM ',' NUM ')' '{' statement '}' {
	                                                int i;
	                                                fprintf(yyout,"\nWHILE Loop Found\n");
                                                  print_tree("\nWHILE Loop Found\n");
            level++;
            print_tree("ITERATIONS");
            level++;

            
	                                                for(i=$3 ; i<$5 ; i++) 
                                                        {
                                                                fprintf(yyout,"%dth Loop: \n", i);
                                                                
                                                                      print_leaf("iteration num" , i);
                                                        }
                                                        level -=2 ;
				        }
        | WHILE '(' VAR ',' VAR ')' '{' statement '}' {
	                                                int i;
	                                                fprintf(yyout,"\nWHILE Loop Found\n");
	                                                for(i=sym[$3] ; i<sym[$5] ; i++) 
                                                        {
                                                                fprintf(yyout,"%dth Loop: \n", i);
                                                        }}
        | WHILE '(' VAR ',' NUM ')' '{' statement '}' {
	                                                int i;
	                                                fprintf(yyout,"\nWHILE Loop Found\n");
	                                                for(i=sym[$3] ; i<$5 ; i++) 
                                                        {
                                                                fprintf(yyout,"%dth Loop: \n", i);
                                                        }}
        | WHILE '(' NUM ',' VAR ')' '{' statement '}' {
	                                                int i;
	                                                fprintf(yyout,"\nWHILE Loop Found\n");
	                                                for(i=$3 ; i<sym[$5] ; i++) 
                                                        {
                                                                fprintf(yyout,"%dth Loop: \n", i);
                                                        }}                                                                            
          ;

expression: NUM                      
            { 
                $$ = $1; 
               print_tree("expr");
            level++;
            print_tree("=");
            level+=2;
            print_leaf("NUM", $1);
            level-=3;
            }
          | VAR                      
            {                 $$ = sym[$1]; 

            print_tree("expr");
            level++;
            print_tree("=");
            level+=2;
            print_leaf("VAR", sym[$1]);
            level-=3;
            }
          | expression '*' expression           
            { 
                $$ = $1 * $3; 
                print_tree("Multiplication Expression");
                level+=2;
                print_leaf("Expression1",$1);
                level+=2;
                print_tree("*");
                level-=2;
                print_leaf("Expression1",$3);
                level+=2;
              print_leaf("result",$$);

                level-=4;

            }
          | expression '/' expression           
            {
              if ($3) {
                $$ = $1 / $3; 
                print_tree("Division Expression");
                level+=2;
                print_leaf("Expression1",$1);
                level+=2;
                print_tree("/");
                level-=2;
                print_leaf("Expression1",$3);
                level+=2;
              print_leaf("result",$$);

                level-=4;               
            } else {
                    fprintf(yyError, "\nRuntime Error: Division by zero\n");
                } 
                print_tree( "Division Expression");

            }
          | expression '+' expression           
            {                 $$ = $1 + $3; 
                print_tree("Addition Expression");
                level+=2;
                print_leaf("Expression1",$1);
                level+=2;
                print_tree("+");
                level-=2;
                print_leaf("Expression1",$3);
                level+=2;
              print_leaf("result",$$);

                level-=4;  
            }
          | expression '-' expression           
            { 
                $$ = $1 - $3; 
                print_tree( "Subtraction Expression");
               level+=2;
                print_leaf("Expression1",$1);
                level+=2;
                print_tree("-");
                level-=2;
                print_leaf("Expression1",$3);
                level+=2;
              print_leaf("result",$$);

                level-=4;  

            }
          | '(' expression ')'            
            { 
                $$ = $2; 
                print_tree( "Parenthesized Expression");
                level++;
                print_leaf("(expression)" , $2)
            }
          | expression '%' expression
            { 
                if($3) {
                    fprintf(yyout, "\nMOD : %d %% %d = %d\n", $1, $3, $1 % $3);
                    $$ = $1 % $3;
                    print_tree( "Modulus Expression");
                                    level+=2;
                print_leaf("Expression1",$1);
                level+=2;
                print_tree("%%");
                level-=2;
                print_leaf("Expression1",$3);
                level+=2;
              print_leaf("result",$$);

                level-=4; 
                } else {
                    $$ = 0;
                    fprintf(yyError, "\nRuntime Error: MOD by zero\n");
                    print_tree("expression: expression % expression (division by zero)");
                }
            }
          | expression '^' expression
            { 
                $$ = pow($1, $3); 
                print_tree( "Exponentiation Expression");           ;
               level+=2;
                print_leaf("Expression1",$1);
                level+=2;
                print_tree("^");
                level-=2;
                print_leaf("Expression1",$3);
                level+=2;
              print_leaf("result",$$);

                level-=4;  

            }
          | expression '<' expression
            { 
                if ($1 < $3) {
                    $$ = 1; 
                } else {
                    $$ = 0; 
                }
                print_tree( "Less Than Comparison");

            }
          | expression '>' expression
            { 
                if ($1 > $3) {
                    $$ = 1; 
                } else {
                    $$ = 0; 
                }
                print_tree( "Greater Than Comparison");

            }
          | expression '=' '=' expression  
            { 
                if ($1 == $3) {
                    $$ = 1; 
                } else {
                    $$ = 0; 
                }
                print_tree("Equal Comparison");
            }
          | expression '!' '=' expression 
            { 
                if ($1 != $3) {
                    $$ = 1; 
                } else {
                    $$ = 0; 
                }
                print_tree( "Not Equal Comparison");

            }
          | '!' expression  
            { 
                $$ = !$2; 
                print_tree( "Logical NOT Expression");

            }
          |'-' expression
          {
          $$ = -$2; 
          print_tree( "negative expression");

          }
          ;

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