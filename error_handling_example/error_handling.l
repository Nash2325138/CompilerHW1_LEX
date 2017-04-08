%{
    int linenum = 1;
%}

%%
/*HANDLE ILLEGAL INTEGER CONSTANTS*/
<INITIAL>0/[0-9a-zA-Z] {fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);exit(1);}

%%
void main(void)
{
    yylex();
}

int yywrap() {
    return 1;
}
