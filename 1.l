%{
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>
#include "y.tab.h"
extern YYSTYPE yylval;
void yyerror(char *);
extern FILE *yyin;
extern FILE *yyout;
extern FILE *yyError;
#define MAX_SIZE 100

int num_of_v = 0;

struct KeyValue {
    char key[20];
    int value;
};

struct KeyValue myMap[MAX_SIZE]; // Fixed-size map

void addToMap(const char *key, int value) {
    for (int i = 0; i < MAX_SIZE; ++i) {
        if (strcmp(myMap[i].key, key) == 0) {
            myMap[i].value = value; // Update value if key exists
            return;
        }
    }
    for (int i = 0; i < MAX_SIZE; ++i) {
        if (myMap[i].key[0] == '\0') { // Add new key-value pair
            strcpy(myMap[i].key, key);
            myMap[i].value = value;
            return;
        }
    }
    printf("Error: Map is full, cannot add more entries.\n");
}

int getValueFromMap(const char *key) {
    for (int i = 0; i < MAX_SIZE; ++i) {
        if (strcmp(myMap[i].key, key) == 0) {
            return myMap[i].value;
        }
    }
    return -1; // Key not found
}
%}

%%


"int"    { return INT; }
"float"  { return FLOAT; }
"char"   { return CHAR; }
[0-9]+   { yylval = atoi(yytext); return NUM; }
"<"      { return '<'; }
";"      { return ';'; }
","      { return ','; }
"if"     { return IF; }
"else"   { return ELSE; }
"{"      { return '{'; }
"}"      { return '}'; }
"print"  { return PRINT; }
"while"  { return WHILE; }
"main"   { return MAIN; }

[-+/*<>=,():;%^!]    {
                    yylval = yytext[0];	
                    return  *yytext;	
                    }

[a-zA-Z][a-zA-Z0-9]* { 
    if (getValueFromMap(yytext) == -1) {
        num_of_v++;
        addToMap(yytext, num_of_v);
        yylval = num_of_v; // Assign the unique index to yylval
    } else {
        yylval = getValueFromMap(yytext); // Retrieve the index
    }
    return VAR;
}

[#].*   {
        /*ignore comment*/
        }

[ \t\n]* {}
. {
    fprintf(yyError, "%s -> Unknown character!\n", yytext);
}
%%

int yywrap() {
    return 1;
}