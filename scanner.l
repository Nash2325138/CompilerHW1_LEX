%{
	#include <stdio.h>
	int lineCount=0;
%}

%%

int\n 		{
	lineCount++;
	printf("line:%d\nkeyword: %s\n", lineCount, yytext);
}
[[:alpha:]]*\n	{
	lineCount++;
	printf("line:%d\nalpha: %s\n", lineCount, yytext);
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