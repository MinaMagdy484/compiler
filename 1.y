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
int sym[100] = {0}; // Initialize to zero
int flag = 1;
int level = 0; // Current level for the parse tree

void print_tree(const char *node) {
    if (yyTreeOut) {
        // Print indentation based on the current level
        for (int i = 0; i < level; i++) {
            fprintf(yyTreeOut, "\t"); 
        }
        fprintf(yyTreeOut, "%s\n", node);
    }
}

void BEGIN_RULE(int level_increment) { level += level_increment ; }
void END_RULE(int level_decrement) { level -= level_decrement ; }

%}

%token MAIN INT FLOAT CHAR NUM VAR IF ELSE LB RB PRINT WHILE
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
               print_tree("declaration: INT VAR");
           }
           | FLOAT VAR ';'     
           { 
               sym[$2] = 0; 
               print_tree("declaration: FLOAT VAR");
           }
           | CHAR VAR ';'      
           { 
               sym[$2] = 0; 
               print_tree("declaration: CHAR VAR");
           };

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
                print_tree("statement: assignment");
                END_RULE(1);
            }
            | condition
            { 
                BEGIN_RULE(1);
                print_tree("statement: condition");
                END_RULE(1);
            }
            | PRINT '(' expression ')' ';' 
            { 
                BEGIN_RULE(1);

                fprintf(yyout, "Print: %d\n", $3); 
                print_tree("Print Statement");
                END_RULE(1);

            };

assignment: VAR '=' expression ';'      
            { 
              BEGIN_RULE(1);

                sym[$1] = $3; 
                print_tree("assignment: VAR = expression;");
              END_RULE(1);

            }
            | VAR '+' '=' NUM ';'         
            { 
              BEGIN_RULE(1);

                sym[$1] += $4; 
                print_tree("assignment: VAR += NUM;");
              END_RULE(1);

            }
            | VAR '+' '=' VAR ';'         
            { 
              BEGIN_RULE(1);

                sym[$1] += sym[$4]; 
                print_tree("assignment: VAR += VAR;");
              END_RULE(1);

            }
            | VAR '-' '=' NUM ';'         
            { 
              BEGIN_RULE(1);

                sym[$1] -= $4; 
                print_tree("assignment: VAR -= NUM;");
              END_RULE(1);

            }
            | VAR '-' '=' VAR ';'         
            { 
              BEGIN_RULE(1);
                sym[$1] -= sym[$4]; 
                print_tree("assignment: VAR -= VAR;");
              END_RULE(1);
            }
            | VAR '*' '=' NUM ';'         
            { 
              BEGIN_RULE(1);
                sym[$1] *= $4; 
                print_tree("assignment: VAR *= NUM;");
                END_RULE(1);
            }
            | VAR '*' '=' VAR ';'         
            { 
              BEGIN_RULE(1);
                sym[$1] *= sym[$4]; 
                print_tree("assignment: VAR *= VAR;");
                END_RULE(1);
            }
            | VAR '/' '=' NUM ';'         
            { 
              BEGIN_RULE(1);
                if ($4) {
                    sym[$1] /= $4; 
                    print_tree("assignment: VAR /= NUM;");
                } else {
                    fprintf(yyError, "\nRuntime Error: Division by zero\n");
                }
                END_RULE(1);
            }
            | VAR '/' '=' VAR ';'         
            { 
              BEGIN_RULE(1);
                if (sym[$4]) {
                    sym[$1] /= sym[$4]; 
                    print_tree("assignment: VAR /= VAR");
                } else {
                    fprintf(yyError, "\nRuntime Error: Division by zero\n");
                }
                END_RULE(1);
            };

condition: 
        IF '(' expression ')' '{' statements '}' 
          {
            BEGIN_RULE(1);
            fprintf(yyout, "\nIF Condition Found\n");
            if ($3) {
                fprintf(yyout, "IF is TRUE: Executing Statements\n");
                $$ = 1; 
                print_tree("IF Condition: TRUE");
            } else {
                fprintf(yyout, "IF is FALSE: Skipping Statements\n");
                $$ = 0; 
                print_tree("IF Condition: FALSE");
            }
            END_RULE(1);
          }
        | IF '(' expression ')' '{' statements '}' ELSE '{' statements '}' 
          {
            BEGIN_RULE(1);
            fprintf(yyout, "\nIF ELSE Condition Found\n");
            if ($3) { 
                fprintf(yyout, "IF is TRUE: Executing IF Statements\n");
                $$ = 1; 
                print_tree("IF ELSE Condition: TRUE");
            } else {
                fprintf(yyout, "ELSE is TRUE: Executing ELSE Statements\n");
                $$ = 0; 
                print_tree("IF ELSE Condition: FALSE");
            }
            END_RULE(1);
          };

expression: NUM                      
            { 
                BEGIN_RULE(1); 
                $$ = $1; 
                print_tree("expression: NUM");
                END_RULE(1); 
            }
          | VAR                      
            { 
                BEGIN_RULE(1); 
                $$ = sym[$1]; 
                print_tree("expression: VAR");
                END_RULE(1); 
            }
          | expression '*' expression           
            { 
                BEGIN_RULE(1);
                $$ = $1 * $3; 
                print_tree("expression: expression * expression");
                END_RULE(1); 
            }
          | expression '/' expression           
            { 
                BEGIN_RULE(1);
                $$ = $1 / $3; 
                print_tree("expression: expression / expression");
                END_RULE(1); 
            }
          | expression '+' expression           
            { 
                BEGIN_RULE(1);
                $$ = $1 + $3; 
                print_tree("expression: expression + expression");
                END_RULE(1); 
            }
          | expression '-' expression           
            { 
                BEGIN_RULE(1);
                $$ = $1 - $3; 
                print_tree("expression: expression - expression");
                END_RULE(1); 
            }
          | '(' expression ')'            
            { 
                BEGIN_RULE(1);
                $$ = $2; 
                print_tree("expression: ( expression )");
                END_RULE(1); 
            }
          | expression '%' expression
            { 
                BEGIN_RULE(1);
                if($3) {
                    fprintf(yyout, "\nMOD : %d %% %d = %d\n", $1, $3, $1 % $3);
                    $$ = $1 % $3;
                    print_tree("expression: expression % expression");
                } else {
                    $$ = 0;
                    fprintf(yyError, "\nRuntime Error: MOD by zero\n");
                    print_tree("expression: expression % expression (division by zero)");
                }
                END_RULE(1); 
            }
          | expression '^' expression
            { 
                BEGIN_RULE(1);
                $$ = pow($1, $3); 
                print_tree("expression: expression ^ expression");
                END_RULE(1); 
            }
          | expression '<' expression
            { 
                BEGIN_RULE(1);
                if ($1 < $3) {
                    $$ = 1; 
                } else {
                    $$ = 0; 
                }
                print_tree("expression: expression < expression");
                END_RULE(1); 
            }
          | expression '>' expression
            { 
                BEGIN_RULE(1);
                if ($1 > $3) {
                    $$ = 1; 
                } else {
                    $$ = 0; 
                }
                print_tree("expression: expression > expression");
                END_RULE(1); 
            }
          | expression '=' '=' expression  
            { 
                BEGIN_RULE(1);
                if ($1 == $3) {
                    $$ = 1; 
                } else {
                    $$ = 0; 
                }
                print_tree("expression: expression == expression");
                END_RULE(1); 
            }
          | expression '!' '=' expression 
            { 
                BEGIN_RULE(1);
                if ($1 != $3) {
                    $$ = 1; 
                } else {
                    $$ = 0; 
                }
                print_tree("expression: expression != expression");
                END_RULE(1); 
            }
          | '!' expression  
            { 
                BEGIN_RULE(1);
                $$ = !$2; 
                print_tree("expression: ! expression");
                END_RULE(1); 
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

