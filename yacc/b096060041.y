%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define nullptr NULL

/* macro definition */
#define MAX_LINE 1024
#define MAX_STRING_LENGTH 1024
#define MAX_SYMBOLS 100

/* construct the symbol table */
typedef struct {
    char *name;
    char *type;
} symbol;
unsigned int symbolCount = 0;
symbol symbolTable[MAX_SYMBOLS];

int yylex();
void yyerror(const char* message);
void addSymbol(const char* name, const char* type);
void addSymbolList(char* id_list, const char* type);
char *getSymbolType(const char* name);

extern unsigned int charCount, lineCount;
extern char *yytext;
extern char lines[MAX_LINE][MAX_STRING_LENGTH];

/* error handling in buffer*/
char *errorToken = "";
int errorCharCount = 0;
char lines_error[MAX_LINE][MAX_STRING_LENGTH];
%}

%union {
    int     intValue;
    float   floatValue;
    char*   stringValue;
}

/* ---reserved--- */
/* There are some reserved words which are not coverd in this parser */
%token <stringValue> ABSOULUTE AND ARRAY BEGIN_ BREAK CASE CONST CONTINUE DO DOUBLE
%token <stringValue> ELSE END_ REAL_ FOR FUNCTION IF INTEGER_ MOD NIL NOT
%token <stringValue> OBJECT OF OR PROGRAM READ STRING_ THEN TO VAR WHILE WRITE WRITELN

/* ---operator--- */
%token <stringValue> PLUS MINUS MUL DIV 
%token <stringValue> ASSIGNMENT LESS GREATER LESS_EQUAL GREATER_EQUAL EQUAL NOT_EQUAL 

/* ---symbol--- */
/* Noticing that this parser will not show the comments.
   Hence, the comment { ... } and (. ... .) will not show in the output.
   It will be ignored in the Lex scanner, which the LBRACE and RBRACE will not be used here. */
%token <stringValue> DOT COMMA SEMI COLON
%token <stringValue> LBRACKET RBRACKET LBRACE RBRACE LP RP

/* ---scanner type return---*/
%token <stringValue> INT 
%token <stringValue> REAL
%token <stringValue> ID STR CHAR

/* ---define precedence--- */
%nonassoc LOWER_THAN_ELSE  // Ensure that this token applies in cases where 'if' is effective but not for 'else'.
%nonassoc ELSE

/* ---start symbol--- */
%type <stringValue> prog_name id_list varid index_exp dec_list dec prog stmt_list stmt write_list write_exp 
%type <stringValue> assign read write for ifstmt relop
%type <stringValue> type standard_type array_type factor term exp simpexp body

%%

prog:
    PROGRAM prog_name SEMI
    VAR
    dec_list SEMI
    BEGIN_
    stmt_list SEMI
    END_ DOT
    | PROGRAM prog_name SEMI
    VAR
    dec_list SEMI
    BEGIN_
    stmt_list SEMI
    END_ error { sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: missing dot \".\" at the end.\n", lineCount); }
    ;

prog_name:
    ID
    ;

dec_list:
    dec { $$ = $1; }
    | dec_list SEMI dec
    ;

dec:
    id_list COLON type {
        addSymbolList($1, $3);
        char *temp = malloc(MAX_STRING_LENGTH);
        snprintf(temp, MAX_STRING_LENGTH, "%s: %s\n", $1, $3);
        $$ = temp;
    }
    | id_list error type { sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: at char %d, \":\" expected but \"%s\" found.\n", lineCount, errorCharCount, errorToken); }
    ;

id_list:
    ID { $$ = strdup($1); }
    | id_list COMMA ID {
        char *temp = malloc(MAX_STRING_LENGTH); 
        snprintf(temp, MAX_STRING_LENGTH, "%s, %s", $1, $3);
        $$ = temp;
    }
    | id_list error ID { sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: at char %d, \",\" expected but \"%s\" found.\n", lineCount, errorCharCount, errorToken); }
    ;

type:
    standard_type
    | array_type
    ;
    
standard_type:
    INTEGER_ { $$ = strdup("integer"); }
    | REAL_ { $$ = strdup("real"); }
    | STRING_ { $$ = strdup("string"); }
    ;
array_type:
    ARRAY LBRACKET INT DOT DOT INT RBRACKET OF standard_type
    ;

stmt_list:
    stmt
    | stmt_list SEMI stmt
    ;

stmt:
    assign { $$ = $1; }
    | read { $$ = $1; }
    | write { $$ = $1; }
    | for { $$ = $1; }
    | ifstmt { $$ = $1; }
    ;

assign:
    varid ASSIGNMENT simpexp
    | varid error simpexp { sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: at char %d, \":=\" expected but \"%s\" found.\n", lineCount, errorCharCount, errorToken); }
    ;

varid:
    ID {
        if (getSymbolType($1) == nullptr)
            sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: \"%s\" is an undeclared variable\n", lineCount, $1);
        $$ = $1;
    }
    | ID LBRACKET simpexp RBRACKET{
        if (getSymbolType($1) == nullptr)
            sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: \"%s\" is an undeclared variable\n", lineCount, $1);
    }
    ;
exp:
    simpexp { $$ = $1; }
    | exp relop simpexp
    ;

relop:
    GREATER { $$ = strdup(">"); }
    | LESS { $$ = strdup("<"); }
    | GREATER_EQUAL { $$ = strdup(">="); }
    | LESS_EQUAL { $$ = strdup("<="); }
    | NOT_EQUAL { $$ = strdup("<>"); }
    | EQUAL { $$ = strdup("="); }
    ;

simpexp:
    term { $$ = $1; }
    | simpexp PLUS term{
        char *type1 = getSymbolType($1), *type2 = getSymbolType($3);
        if (type1 && type2 && strcmp(type1, type2) != 0)
            sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: type mismatch: cannot add \"%s\" (%s) to \"%s\" (%s)\n", lineCount, $1, type1, $3, type2);
        $$ = $1 ? strdup($1) : strdup($3); // same data type
    }
    | simpexp MINUS term{
        char *type1 = getSymbolType($1), *type2 = getSymbolType($3);
        if (type1 && type2 && strcmp(type1, type2) != 0)
            sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: type mismatch: cannot substract \"%s\" (%s) to \"%s\" (%s)\n", lineCount, $1, type1, $3, type2);
        $$ = $1 ? strdup($1) : strdup($3); // same data type
    }
    | PLUS term
    | MINUS term
    ;

term:
    factor { $$ = $1; }
    | term MUL factor
    | term DIV factor
    | term MOD factor
    ;

factor:
    varid { $$ = $1; }
    | INT { $$ = $1; }
    | REAL { $$ = $1; }
    | STR { $$ = $1; }
    | LP simpexp RP
    ;

read:
    READ LP id_list RP
    ;

write:
    WRITE LP write_list RP
    | WRITELN LP write_list RP
    | WRITE
    | WRITELN
    ;

write_list:
    write_exp { $$ = $1; }
    | write_list COMMA write_exp
    ;

write_exp:
    term { $$ = $1; }
    | CHAR { $$ = strdup("char"); }
    ;

for:
    FOR index_exp DO body
    ;

index_exp:
    varid ASSIGNMENT simpexp TO exp
    ;

ifstmt:
    IF LP exp RP THEN body %prec LOWER_THAN_ELSE
    | IF LP exp RP THEN body ELSE body
    | IF LP exp RP error body { sprintf(lines_error[lineCount] + strlen(lines_error[lineCount]), "Line %d: at char %d, \"then\" expected but \"%s\" found.\n", lineCount, errorCharCount, errorToken); }
    ;

body:
    stmt { $$ = $1; }
    | BEGIN_ stmt_list SEMI END_
    ;

%%
int main(){
    /* initilization */
    memset(lines, 0, sizeof(lines));
    memset(lines_error, 0, sizeof(lines_error));

    yyparse();

    /* standard output */
    for (int i = 1; i <= lineCount; i++) {
        if (strlen(lines_error[i]) != 0)
            printf("%s", lines_error[i]);
        else if (strlen(lines[i]) != 0)
            printf("Line %d: %s", i, lines[i]);
    }
    printf("\n");
    return 0;
}
void yyerror(const char* message){ 
    errorCharCount = charCount - strlen(yytext);
    errorToken = strdup(yytext);
    /* printf("invalid format at line %d, and the error code is: %s\n", lineCount++, message);  */
}
void addSymbol(const char* name, const char* type){
    if (symbolCount >= MAX_SYMBOLS) {
        fprintf(stderr, "Symbol table overflow.\n");
        return;
    }
    symbolTable[symbolCount].name = strdup(name);
    symbolTable[symbolCount].type = strdup(type);
    symbolCount++;
}
void addSymbolList(char* id_list, const char* type){
    char *token = strtok(id_list, ", "); // extract tokens from strings
    while (token != nullptr){
        addSymbol(token, type);
        token = strtok(nullptr, ", ");
    }
}
char *getSymbolType(const char* name){
    for(int i = 0; i < symbolCount; i++)
        if(strcmp(symbolTable[i].name, name) == 0)
            return symbolTable[i].type;
    return nullptr;
}