%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#define nullptr NULL
#define MAX_LINE 1024
#define MAX_STRING_LENGTH 1024
unsigned int charCount = 1, lineCount = 1;
char lines[MAX_LINE][MAX_STRING_LENGTH];

void appendToLine(const char* str);
%}

%option case-insensitive

digit [0-9]
integer {digit}+
expoent [e|E][-|+]?{digit}+
real ([+|-]?{digit}+\.{digit}+|[+|-]?{digit}+\.{digit}*)f?
id [a-zA-Z_][a-zA-Z_0-9]*
notid [0-9~!@#$%\^&][a-zA-Z0-9_]+
string \'([^']|'')([^']|'')+\'
char \'([^']|'')\'
comment \(\*([^\*]|\*+[^\)\*])*\*+\)
space [ ]+
eol \r?\n
other .

%%
%xm // open the x mode, which ignore the whitespace characters

    /* ---reserved--- */
"absolute"  { appendToLine(yytext); return ABSOULUTE; }
"and"       { appendToLine(yytext); return AND; }
"array"     { appendToLine(yytext); return ARRAY; }
"begin"     { appendToLine(yytext); return BEGIN_; }
"break"     { appendToLine(yytext); return BREAK; }
"case"      { appendToLine(yytext); return CASE; }
"const"     { appendToLine(yytext); return CONST; }
"continue"  { appendToLine(yytext); return CONTINUE; }
"do"        { appendToLine(yytext); return DO; }
"double"    { appendToLine(yytext); return DOUBLE; }
"else"      { appendToLine(yytext); return ELSE; }
"end"       { appendToLine(yytext); return END_; }
"real"      { appendToLine(yytext); return REAL_; }
"for"       { appendToLine(yytext); return FOR; }
"function"  { appendToLine(yytext); return FUNCTION; }
"if"        { appendToLine(yytext); return IF; }
"integer"   { appendToLine(yytext); return INTEGER_; }
"mod"       { appendToLine(yytext); return MOD; }
"nil"       { appendToLine(yytext); return NIL; }
"not"       { appendToLine(yytext); return NOT; }
"object"    { appendToLine(yytext); return OBJECT; }
"of"        { appendToLine(yytext); return OF; }
"or"        { appendToLine(yytext); return OR; }
"program"   { appendToLine(yytext); return PROGRAM; }
"read"      { appendToLine(yytext); return READ; }
"string"    { appendToLine(yytext); return STRING_; }
"then"      { appendToLine(yytext); return THEN; }
"to"        { appendToLine(yytext); return TO; }
"var"       { appendToLine(yytext); return VAR; }
"while"     { appendToLine(yytext); return WHILE; }
"write"     { appendToLine(yytext); return WRITE; }
"writeln"   { appendToLine(yytext); return WRITELN; }

    /* ---operator--- */
"+"         { appendToLine(yytext); return PLUS; }
"-"         { appendToLine(yytext); return MINUS; }
"*"         { appendToLine(yytext); return MUL; }
"/"         { appendToLine(yytext); return DIV; }
":="        { appendToLine(yytext); return ASSIGNMENT; }
">"         { appendToLine(yytext); return GREATER; }
"<"         { appendToLine(yytext); return LESS; }
"<="        { appendToLine(yytext); return LESS_EQUAL; }
">="        { appendToLine(yytext); return GREATER_EQUAL; }
"<>"        { appendToLine(yytext); return NOT_EQUAL; }
"="         { appendToLine(yytext); return EQUAL; }

    /* ---symbol---*/
"."         { appendToLine(yytext); return DOT; }
","         { appendToLine(yytext); return COMMA; }
";"         { appendToLine(yytext); return SEMI; }
":"         { appendToLine(yytext); return COLON; }
"["         { appendToLine(yytext); return LBRACKET; }
"]"         { appendToLine(yytext); return RBRACKET; }
"{"         { appendToLine(yytext); return LBRACE; }
"}"         { appendToLine(yytext); return RBRACE;}
"("         { appendToLine(yytext); return LP; }
")"         { appendToLine(yytext); return RP; }


{space} { appendToLine(yytext); }
{eol} {
    /* It will only count the line number */
    if (strlen(lines[lineCount]))
        appendToLine(yytext);
    lineCount++; charCount = 1;
}
{integer} { 
    appendToLine(yytext); 
    yylval.stringValue = strdup(yytext);
    if (yylval.stringValue == nullptr) { 
        fprintf(stderr, "failed to allocate memory.\n");
        exit(EXIT_FAILURE);
    }
    return INT; 
}
{integer}{expoent} { 
    appendToLine(yytext); 
    yylval.stringValue = strdup(yytext);
    if (yylval.stringValue == nullptr) { 
        fprintf(stderr, "failed to allocate memory.\n");
        exit(EXIT_FAILURE);
    }
    return REAL; 
}
{real} { 
    appendToLine(yytext); 
    yylval.stringValue = strdup(yytext);
    if (yylval.stringValue == nullptr) { 
        fprintf(stderr, "failed to allocate memory.\n");
        exit(EXIT_FAILURE);
    }
    return REAL; 
}
{real}{expoent} { 
    appendToLine(yytext); 
    yylval.stringValue = strdup(yytext);
    if (yylval.stringValue == nullptr) { 
        fprintf(stderr, "failed to allocate memory.\n");
        exit(EXIT_FAILURE);
    }
    return REAL; 
}
{id} { 
    if (yyleng > 15 ){
        printf("Line %u: 1st char: %u, \"%s\" is an \"invalid ID\".\n", lineCount, charCount, yytext);
        charCount += yyleng;
    }
    else{
        appendToLine(yytext);
        yylval.stringValue = strdup(yytext); 
        if (yylval.stringValue == nullptr) { 
            fprintf(stderr, "failed to allocate memory.\n");
            exit(EXIT_FAILURE);
        }
        return ID;
    }
}
{notid} { 
    charCount += yyleng;
    printf("Line %d: 1st char: %d, \"%s\" is an \"invalid ID\".\n", lineCount, charCount, yytext);
}
{string} {
    if (yyleng - 2 > 30 ){
        printf("Line %u: 1st char: %u, \"%s\" is an \"invalid string\".\n", lineCount, charCount, yytext);
        charCount += yyleng;
    }
    else{
        appendToLine(yytext);
        yylval.stringValue = strdup(yytext); 
        if (yylval.stringValue == nullptr) { 
            fprintf(stderr, "failed to allocate memory.\n");
            exit(EXIT_FAILURE);
        }
        return STR;
    }
}
{char} {
    appendToLine(yytext);
    yylval.stringValue = strdup(yytext); 
        if (yylval.stringValue == nullptr) { 
            fprintf(stderr, "failed to allocate memory.\n");
            exit(EXIT_FAILURE);
        }
    return CHAR;
}
{comment} {
    /* the comments in this assignment will not return any value to the parser.
       That is, it will be ignored in Lex but count the linenumber continuously. */
    for (int i = 0; i < yyleng; i++) {
        if (yytext[i] == '\n'){
            memset(lines[lineCount], 0, sizeof(lines[lineCount]));
            charCount = 1; lineCount++;
        }
        else
            charCount++;
    }
}
{other} {
    printf("Line %d: 1st char: %d, \"%s\" is an \"invalid character\".\n", lineCount, charCount, yytext);
    charCount++;
}
%%
int yywrap(){ return 1; }
void appendToLine(const char* str) {
    /* recording the output */
    charCount += yyleng;
    strcat(lines[lineCount], str);
}