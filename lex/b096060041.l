%{
#include <stdio.h>
#include <ctype.h>
#define nullptr NULL
unsigned int charCount = 1, lineCount = 1;
unsigned int symbolCount = 0;
char symbols[100][16];
void print_token(const unsigned use_an, const char *type, char *yytext);
void print_token_expression(const char *type, char *yytext);

void symbol_table_count(char *yytext);
void symbol_table();
%}

%option case-insensitive

reserved absolute|and|begin|break|case|const|continue|do|else|end|for|function|if|mod|nil|not|object|of|or|program|then|to|var|while|array|integer|double|write|writeln|string|float|read
eol \n
space [ \t\r]
id [a-zA-Z_][a-zA-Z_0-9]*
notid [0-9~!@#$%\^&\-][a-zA-Z0-9_]+
operator [\+\-\*\/]
symbol [\.;:\(\)\[\]\{\}]|:=|>|<|=|==|<=|>=
digit [0-9]
integer [+|-]?{digit}+
notreal \.{digit}+|{digit}+\.
real [+|-]?{digit}+(\.{digit}+)?(E[+|-]?{digit}+)?
string \'([^'\n]|\'\')+\'
notstring \'([^'\n]*|\'\')*
comment \(\*([^\*]|\*+[^\)\*])*\*+\)

%%

{reserved} { print_token(0, "reserved", yytext); }
{operator} { print_token(1, "operator", yytext); }
{symbol} { print_token(0, "symbol", yytext); }
{integer} { print_token(1, "integer", yytext); }
{integer}{operator} { print_token_expression("integer", yytext); } 
{notreal} { print_token(1, "invalid number", yytext); }
{real} { print_token(0, "real", yytext); }
{real}{operator} { print_token_expression("real", yytext); }
{notstring} { 
    int tempCount;
    for (tempCount = 1; tempCount < yyleng; tempCount++) { // starting count after first quote
        if (isalnum(yytext[tempCount]) == 0) break;
    }
    /* print invalid string */
    char temp[tempCount + 1];
    strncpy(temp, yytext, tempCount);
    printf("Line: %u, 1st char: %u, \"%s\" is an \"invalid string\"\n", lineCount, charCount, temp);
    
    /* print other symbol after invalid string */
    for (int i = tempCount; i < yyleng; i++){
        if (yytext[i] == '+' || yytext[i] == '-' || yytext[i] == '*' || yytext[i] == '/')
            printf("Line: %u, 1st char: %u, \"%c\" is an \"operator\"\n", lineCount, i + 1, yytext[i]);
        else
            printf("Line: %u, 1st char: %u, \"%c\" is a \"symbol\"\n", lineCount, i + 1, yytext[i]);
    }
}
{string} {
    if ((yyleng - 2) > 30) print_token(1, "invalid string", yytext);
    else print_token(0, "string", yytext);
}
{space} { charCount++; }
{eol} { lineCount++; charCount = 1; }
{notid} { print_token(1, "invalid id", yytext); }
{id} { 
    if (yyleng > 15 ) print_token(1, "invalid id", yytext);
    else print_token(1, "id", yytext);
}

{comment} {
	char* result = (char*)malloc(yyleng * 2 + 1);
    char* current = result;

	printf("Line: %d, 1st char: %d, ", lineCount, charCount);

    while (*yytext) {
        if (*yytext == '\n') {
            *current++ = '\\';
            *current++ = 'n';
			charCount = 0;
			lineCount++;
    	} else if(*yytext == '\r') {
			*current++ = '\\';
			*current++ = 'r';
		} else {
            *current++ = *yytext;
        }
        yytext++;
		charCount++;
    }
    *current = '\0';

	printf("\"%s\" is a \"comment\".\n", result);
}
"//".* { printf("Line: %u, 1st char: %u, \"%s\" is a \'comment\'\n", lineCount, charCount, yytext); }
. { printf("Line: %d, 1st char: %d, \"%s\" is an \"invalid character\".\n", lineCount, charCount, yytext); charCount++; }

%%

int main(){
    yylex();
    symbol_table();
    return 0;
}

void print_token(const unsigned use_an, const char *type, char *yytext){
    if (type == "id")
        symbol_table_count(yytext);
    printf("Line: %u, 1st char: %u, \"%s\" is %s \"%s\"\n", lineCount, charCount, yytext, use_an ? "an" : "a", type);
    charCount += yyleng;
}
void print_token_expression(const char *type, char *yytext){
    char temp[yyleng];
    strncpy(temp, yytext, yyleng - 1);
    temp[yyleng - 1] = '\0';
    if (type == "integer")
        printf("Line: %u, 1st char: %u, \"%s\" is an \"%s\"\n", lineCount, charCount, temp, type);
    else if (type == "real")
        printf("Line: %u, 1st char: %u, \"%s\" is a \"%s\"\n", lineCount, charCount, temp, type);

    printf("Line: %u, 1st char: %u, \"%c\" is an \"operator\"\n", lineCount, charCount + yyleng - 1, yytext[yyleng - 1]);
    charCount += yyleng;
}

/* symbol table */
void symbol_table_count(char *yytext){
    if (symbolCount > 100) return ;

    for (int i = 0; i < symbolCount; i++)
        if(strcmp(symbols[i], yytext) == 0) return;

    strncpy(symbols[symbolCount], yytext, 15);
    symbols[symbolCount][15] = '\0';
    symbolCount++;
}
void symbol_table(){
    printf("\nThe symbol table contains:\n");
    for (int i = 0; i < symbolCount; i++)
        printf("%s\n",symbols[i]);
}