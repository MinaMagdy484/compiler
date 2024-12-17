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
            fprintf(yyTreeOut, " / ");  // Indentation for tree levels
        }
        fprintf(yyTreeOut, "%s\n", label);  // Print the node label
    }

    void print_leaf(const char *label, int value) {
        for (int i = 0; i < level; ++i) {
            fprintf(yyTreeOut, "  ");
        }
        fprintf(yyTreeOut, "%s --> %d\n", label, value);
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
           print_tree("Program");
           level++;
           print_tree("Main Block");
           level--;
       };

declarations: declarations declaration 
            { 
                BEGIN_RULE(1);
                print_tree("declarations: declarations declaration");
                END_RULE(1);
            }
            | /* empty */ 
            { 
                BEGIN_RULE(1);
                print_tree("declarations: empty");
                END_RULE(1);
            };

declaration: INT VAR ';'       
           { 
               sym[$2] = 0; 
                      print_tree("declaration");
                      level++;
                      print_tree("int variable");
                      level++;
                      print_tree("=");
                      level++;
                      print_leaf("Var", sym[$2]);
                      level -= 3;
           }
           | FLOAT VAR ';'     
           { 
               sym[$2] = 0; 
                      print_tree("declaration");
                      level++;
                      print_tree("float variable");
                      level++;
                      print_tree("=");
                      level++;
                      print_leaf("Var", sym[$2]);
                      level -= 3;           }
           | CHAR VAR ';'      
           { 
               sym[$2] = 0; 
                      print_tree("declaration");
                      level++;
                      print_tree("char variable");
                      level++;
                      print_tree("=");
                      level++;
                      print_leaf("Var", sym[$2]);
                      level -= 3;           };

statements: statements statement
          { 
              BEGIN_RULE(1);
              print_tree("statements: statements statement");
              END_RULE(1);
          }
          | /* empty */ 
          { 
              BEGIN_RULE(1);
              print_tree("statements empty");
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
                print_tree("Print Statement");
                END_RULE(1);

            }
             
            ;

assignment: VAR '=' expression ';'      
            { 

                sym[$1] = $3; 
                print_tree("Assignment");
            level++;
            print_tree("VAR");
            print_tree("=");
            print_tree("Expression");
            level--;

            }
            | VAR '+' '=' NUM ';'         
            { 
             sym[$1] += $4; 
            print_tree("Assignment");
            level++;
            print_tree("+=");
            level++;
            print_tree("VAR");
            print_leaf("NUM", $4);
            level -= 2;
            }
            | VAR '+' '=' VAR ';'         
            {                 
              sym[$1] += sym[$4]; 

            print_tree("Assignment");
            level++;
            print_tree("+=");
            level++;
            print_tree("VAR");
            print_tree("VAR");
            level -= 2;

            }
            | VAR '-' '=' NUM ';'         
            {                 sym[$1] -= $4; 

            print_tree("Assignment");
           level++;
           print_tree("-=");
            level++;
            print_tree("VAR");
             print_leaf("NUM", $4);
             level -= 2; // Reset level back

            }
            | VAR '-' '=' VAR ';'         
            {                 sym[$1] -= sym[$4]; 

              print_tree("Assignment");
        level++;
        print_tree("-=");
        level++;
        print_tree("VAR");
        print_tree("VAR");
        level -= 2;
            }
            | VAR '*' '=' NUM ';'         
            {                 sym[$1] *= $4; 

                         print_tree("Assignment");
          level++;
        print_tree("*=");
        level++;
        print_tree("VAR");
        print_leaf("NUM", $4);
        level -= 2; 
            }
            | VAR '*' '=' VAR ';'         
            {                 sym[$1] *= sym[$4]; 
        print_tree("Assignment");
        level++;
        print_tree("*=");
        level++;
        print_tree("VAR");
        print_tree("VAR");
        level -= 2;
            }
            | VAR '/' '=' NUM ';'         
            { 
                if ($4) {
                    sym[$1] /= $4; 
          print_tree("Assignment");
            level++;
            print_tree("/=");
            level++;
            print_tree("VAR");
            print_leaf("NUM", $4);
            level -= 2;                 } else {
                    fprintf(yyError, "\nRuntime Error: Division by zero\n");
                }
            }
            | VAR '/' '=' VAR ';'         
            { 
                if (sym[$4]) {
                    sym[$1] /= sym[$4]; 
            print_tree("Assignment");
            level++;
            print_tree("/=");
            level++;
            print_tree("VAR");
            print_tree("VAR");
            level -= 2;
                } else {
                    fprintf(yyError, "\nRuntime Error: Division by zero\n");
                }
            }
           |VAR '-''-' ';' {sym[$1]=sym[$1]-1;
           $$ = sym[$1] ;
           print_tree("Decrement variable");
            level++;
            print_tree("VAR");
            print_leaf("VAR",sym[$1]);
            level -= 1;}

           |VAR '+''+' ';' {sym[$1]=sym[$1]+1;
           $$ = sym[$1] ;
           print_tree("increment variable");
            level++;
            print_tree("VAR");
            print_leaf("VAR",sym[$1]);
            level -= 1;} 
            
            
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
              level--; // Reset after expression
              print_tree("Body");
              level++;
              print_tree("Statements");
              level -= 2;
            if ($3) {
                fprintf(yyout, "IF is TRUE: Executing Statements\n");
                
                $$ = 1; 
                print_tree("IF Condition: TRUE");
            } else {
                fprintf(yyout, "IF is FALSE: Skipping Statements\n");
                $$ = 0; 
                print_tree("IF Condition: FALSE");
            }
          }
        | IF '(' expression ')' '{' statements '}' ELSE '{' statements '}' 
          {
            fprintf(yyout, "\nIF ELSE Condition Found\n");
            print_tree("IF-ELSE");
            level++;
            print_tree("Condition");
            level++;
            print_tree("Expression");
            level--;
            if ($3) { 
                fprintf(yyout, "IF is TRUE: Executing IF Statements\n");
                $$ = 1; 
                print_tree("IF ELSE Condition: TRUE");
            } else {
                fprintf(yyout, "ELSE is TRUE: Executing ELSE Statements\n");
                $$ = 0; 
                print_tree("IF ELSE Condition: FALSE");
            }
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
            print_leaf("NUM", $1);
            level--;
            }
          | VAR                      
            {                 $$ = sym[$1]; 

                               print_tree("expr");
            level++;
            print_tree("=");
            print_leaf("VAR", sym[$1]);
            level--;
            }
          | expression '*' expression           
            { 
                $$ = $1 * $3; 
                print_tree("Multiplication Expression");
            }
          | expression '/' expression           
            { 
                $$ = $1 / $3; 
                print_tree( "Division Expression");

            }
          | expression '+' expression           
            {                 $$ = $1 + $3; 
                print_tree( "Addition Expression");
            }
          | expression '-' expression           
            { 
                $$ = $1 - $3; 
                print_tree( "Subtraction Expression");

            }
          | '(' expression ')'            
            { 
                $$ = $2; 
                print_tree( "Parenthesized Expression");
            }
          | expression '%' expression
            { 
                if($3) {
                    fprintf(yyout, "\nMOD : %d %% %d = %d\n", $1, $3, $1 % $3);
                    $$ = $1 % $3;
                    print_tree( "Modulus Expression");
                } else {
                    $$ = 0;
                    fprintf(yyError, "\nRuntime Error: MOD by zero\n");
                    print_tree("expression: expression % expression (division by zero)");
                }
            }
          | expression '^' expression
            { 
                $$ = pow($1, $3); 
                print_tree( "Exponentiation Expression");

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

