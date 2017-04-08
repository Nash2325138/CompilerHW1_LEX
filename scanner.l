%{
	#include <stdio.h>
	#include <string.h>
	char lineStr[10000];
	int lineCount = 0;
	int source = 1;
	int token = 1;
%}

Keyword "void"|"int"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"
Operator "+"|"-"|"*"|"/"|"\%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"*"|"&"
Punctuation ":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}" 

InvalidInt 0[0-9]+
Int 0?|[1-9][0-9]*
Float ([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*)
SciNum [0-9]*(.[0-9]*)?[Ee][+-]?[0-9]+

%x LINE

%%
\/\/.*\n
.*$ {
	strcpy(lineStr, yytext);
	if (token) {
		yyless(0);
		BEGIN LINE;
	}
}
<LINE>" "|"\t"
<LINE>{Keyword} {
	printf("key:%s\n", yytext);
}
<LINE>{Operator} {
	printf("op:%s\n", yytext);
}
<LINE>{Punctuation} {
	printf("punc:%s\n", yytext);
}
<LINE>[a-zA-Z_][a-zA-Z_0-9]*	{
	printf("id:%s\n", yytext);
}
<LINE>{Int}	{
	printf("int:%s\n", yytext);
}
<LINE>{InvalidInt} {
	printf("InvalidInt:%s\n", yytext);
}
<LINE>{Float}	{
	printf("double:%s\n", yytext);
}
<LINE>{SciNum} {
	printf("sci:%s\n", yytext);
}
<LINE>\n {
	if (source) {
		printf("%d:%s", ++lineCount, lineStr);
	}
	BEGIN 0;
}


%%

int main(int argc, char const *argv[])
{
	yylex();
	return 0;
}
int yywrap()
{
	return 1;
}