/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT
    #define PRINT(symbol, token) printf("%-8s \t %s\n", symbol, #token)

    enum {NOR, COM, COM_END};
    int line_num = 0;
    int comment_num = 0;
    int state = NOR;
%}

/* Define regular expression label */
letter          [a-zA-Z_]
digit           [0-9]
id              {letter}+({letter}|{digit})*
inumber         {digit}+
fnumber         ({digit}*\.{digit}+)
strlt           "\""([^"^\n]|"\\\"")*"\""
c_com_content   (("/"*|"*"*)([^*^/^\n]|\^))* 
c_com_start     "/*"
c_com_end       "*/"
cpp_com         "//".*

/* Rules section */
%%
"\n"            { if (state == COM) {
                      PRINT(yytext, C Comment);
                      comment_num++;
                  }
                  else {
                      PRINT("", NEWLINE);
                      if (state == COM_END) {
                          state = NOR;
                          comment_num++;
                      }
                  } 
                  line_num++; }
{cpp_com}       { PRINT(yytext, C++ Comment); 
                  state = COM_END; }
{c_com_end}     { PRINT(yytext, C Comment); 
                  state = COM_END; }
{c_com_content} { if (state != COM)
                      REJECT;
                  printf("%s", yytext); }
{c_com_start}   { printf("%s", yytext); 
                  state = COM; } 

"print"         { PRINT(yytext, PRINT); }
"println"       { PRINT(yytext, PRINTLN); }
"if"            { PRINT(yytext, IF); }
"else"          { PRINT(yytext, ELSE); }
"for"           { PRINT(yytext, FOR); }
"int32"         { PRINT(yytext, INT); }
"float32"       { PRINT(yytext, FLOAT); }
"string"        { PRINT(yytext, STRING); }
"bool"          { PRINT(yytext, BOOL); }
"true"          { PRINT(yytext, TRUE); }
"false"         { PRINT(yytext, FALSE); }
"var"           { PRINT(yytext, VAR); }

{inumber}       { PRINT(yytext, INT_LIT); }
{fnumber}       { PRINT(yytext, FLOAT_LIT); }
{strlt}         { yytext[strlen(yytext) - 1] = '\0';
                  PRINT("\"", QUOTA); 
                  PRINT(yytext + 1, STRING);
                  PRINT("\"", QUOTA); }
{id}            { PRINT(yytext, IDENT); }

"+"             { PRINT(yytext, ADD); }
"-"             { PRINT(yytext, SUB); }
"*"             { PRINT(yytext, MUL); }
"/"             { PRINT(yytext, QUO); }
"%"             { PRINT(yytext, REM); }
"++"            { PRINT(yytext, INC); }
"--"            { PRINT(yytext, DEC); }
">"             { PRINT(yytext, GTR); }
"<"             { PRINT(yytext, LSS); }
">="            { PRINT(yytext, GEQ); }
"<="            { PRINT(yytext, LEQ); }
"=="            { PRINT(yytext, EQL); }
"!="            { PRINT(yytext, NEQ); }
"="             { PRINT(yytext, ASSIGN); }
"+="            { PRINT(yytext, ADD_ASSIGN); }
"-="            { PRINT(yytext, SUB_ASSIGN); }
"*="            { PRINT(yytext, MUL_ASSIGN); }
"/="            { PRINT(yytext, QUO_ASSIGN); }
"%="            { PRINT(yytext, REM_ASSIGN); }
"&&"            { PRINT(yytext, LAND); }
"||"            { PRINT(yytext, LOR); }
"!"             { PRINT(yytext, NOT); }
"("             { PRINT(yytext, LPAREN); }
")"             { PRINT(yytext, RPAREN); }
"["             { PRINT(yytext, LBRACK); }
"]"             { PRINT(yytext, RBRACK); }
"{"             { PRINT(yytext, LBRACE); }
"}"             { PRINT(yytext, RBRACE); }
";"             { PRINT(yytext, SEMICOLON); }
","             { PRINT(yytext, COMMA); }
"\""            { PRINT(yytext, QUOTA); }

<<EOF>>         { comment_num += (state == COM_END);
                  line_num++; yyterminate(); }
.               {;}

%%

/*  C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %d\n", line_num);
    printf("comment line: %d\n", comment_num);
    fclose(yyin);
    return 0;
}
