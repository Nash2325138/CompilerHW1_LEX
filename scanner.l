%{
	#include <stdio.h>
	#include <string.h>
	char lineStr[10000];
	int lineCount = 1;
	int source = 1;
	int token = 1;

	int sameLine = 1;
	enum{state_pragma, state_line, state_zero};
	int last_state;

	int pragma_pieces;
	enum{turn_none, turn_source, turn_token};
	int turn;
	int turn_on;

	void errorExit() {
		fprintf(stderr, "Error at line %d: %s\n", lineCount, yytext);
		exit(1); 
	}
	void printLine() {
		if (lineStr[strlen(lineStr)-1] != '\n') {
			strcat(lineStr, "\n");
		}
		if (source) {
			fprintf(stdout, "%d:%s", lineCount, lineStr);
		}
		lineCount++;
		lineStr[0] = '\0';
	}
	void printToken(const char* str) {
		if (token) {
			fprintf(stdout, "#%s:%s\n", str, yytext);	
		}
	}
	void printTokenString(const char* str) {
		static char temp[10000];
		strncpy(temp, yytext+1, strlen(yytext)-2);
		temp[strlen(yytext)-2] = '\0';
		if (token) {
			fprintf(stdout, "#%s:%s\n", str, temp);	
		}
		
	}
%}

Keyword {stdio}|{stdfile}|{stdchio}|{stdblio}|{stdfilepos}|{stderror}|"void"|"int"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"
stdio "printf"|"scanf"|"fprintf"|"fscanf"|"sprintf"|"sscanf"|"vfprintf"|"vprintf"|"vsprintf"
stdfile "fclose"|"fflush"|"fopen"|"freopen"|"remove"|"rename"|"setbuf"|"setvbuf"|"tmpfile"|"tmpnam"
stdchio "fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"
stdblio "fread"|"fwrite"
stdfilepos "fgetpos"|"fseek"|"fsetpos"|"ftell"|"rewind"
stderror "clearerr"|"feof"|"ferror"|"perror"

Operator "+"|"-"|"*"|"/"|"\%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"*"|"&"
Punctuation ":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}" 

Int 0?|[1-9][0-9]*
Float ([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*)
SciNum ({Float}|[0-9]+)[Ee][+-]?[0-9]+

ID [a-zA-Z_][a-zA-Z_0-9]*

InvalidInt 0[0-9]+
InvalidSciNum ({Float}|[0-9])+[Ee][+-]?[0-9]*\.[0-9]*
InvalidID [0-9]+[a-zA-Z_]
InvalidChar '.[^\']+'
InvalidString {Quote}[^"\n]*\n

END [ \t\n]

Char '.'|'\\n'|'\\t'
String {Quote}([^"\n]|\\\")*{Quote}

Quote "\""

%x LINE
%x COMMENT
%x PRAGMA

%%
" ".*\n {
	// puts("LOL");
	yyless(1);
	strcat(lineStr, " ");
}
"\t".*\n {
	// puts("LOL");
	yyless(1);
	strcat(lineStr, "\t");
}
"/*".*\n {
	// puts("OK");
	last_state = state_zero;
	sameLine = 0;
	strcat(lineStr, "/*");
	yyless(2);
	BEGIN COMMENT;
}
#.*\n {
	// if (strcmp(yytext+strlen(yytext)-strlen("#pragma"), "#pragma") != 0) {
	// 	errorExit();
	// }
	// puts("YA!");
	strcat(lineStr, yytext);
	yyless(1);
	pragma_pieces = 0;
	BEGIN PRAGMA;
}
.*\n {
	// puts("WHY");
	strcat(lineStr, yytext);
	sameLine = 1;
	yyless(0);
	BEGIN LINE;
}

<PRAGMA>" "|"\t" {}
<PRAGMA>"pragma"/{END} {
	if (pragma_pieces != 0) {
		errorExit();
	}
	pragma_pieces++;
}
<PRAGMA>"source"/{END} {
	if (pragma_pieces != 1) {
		errorExit();
	}
	turn = turn_source;
	pragma_pieces++;
}
<PRAGMA>"token"/{END} {
	if (pragma_pieces != 1) {
		errorExit();
	}
	turn = turn_token;
	pragma_pieces++;
}
<PRAGMA>"on"/{END} {
	if (pragma_pieces != 2) {
		errorExit();
	}
	turn_on = 1;
	pragma_pieces++;
}
<PRAGMA>"off"/{END} {
	if (pragma_pieces != 2) {
		errorExit();
	}
	turn_on = 0;
	pragma_pieces++;
}
<PRAGMA>"/*".* {
	last_state = state_pragma;
	yyless(2);
	sameLine = 1;
	BEGIN COMMENT;
}
<PRAGMA>\n {
	if (pragma_pieces != 3) {
		errorExit();
	}
	if (!sameLine) {
		strcat(lineStr, "\n");
	}
	if (turn == turn_token) {
		token = turn_on;
		// puts("hi");
	} else if (turn == turn_source) {
		source = turn_on;
		// puts("yo");
	}
	printLine();
	BEGIN 0;
}
<PRAGMA>"//".*\n {
	if (!sameLine) strcat(lineStr, yytext);
	printLine();
	BEGIN 0;
}
<PRAGMA>[^ \t\n]* {
	errorExit();
}

<LINE>" " {}
<LINE>"//".*\n {
	if (!sameLine) strcat(lineStr, yytext);
	printLine();
	BEGIN 0;
}
<LINE>"/*" {
	last_state = state_line;
	sameLine = 1;
	BEGIN COMMENT;
}
<COMMENT>\n {
	// if(!sameLine) strcat(lineStr, yytext);
	sameLine = 0;
	printLine();
}
<COMMENT>. {
	if(!sameLine) strcat(lineStr, yytext);
}
<COMMENT>"*/".* {
	if(last_state == state_line) {
		if(!sameLine) strcat(lineStr, yytext);
		yyless(2);
		BEGIN LINE;
	} else if (last_state == state_pragma) {
		if(!sameLine) strcat(lineStr, yytext);
		yyless(2);
		BEGIN PRAGMA;
	} else if (last_state == state_zero) {
		strcat(lineStr, "*/");
		yyless(2);
		BEGIN 0;
	}
}
<LINE>{Keyword} {
	printToken("key");
}
<LINE>{Operator} {
	printToken("op");
}
<LINE>{Punctuation} {
	printToken("punc");
}
<LINE>{ID}	{
	printToken("id");
}
<LINE>{Int}	{
	printToken("integer");
}
<LINE>{Float}	{
	printToken("double");
}
<LINE>{SciNum} {
	printToken("sci");
}
<LINE>{Char} {
	printToken("char");
}
<LINE>{String} {
	printTokenString("string");
}
<LINE>{InvalidInt}|{InvalidSciNum}|{InvalidID}|{InvalidString}|{InvalidChar} {
	errorExit();
}
<LINE>. {
	errorExit();
}
<LINE>\n {
	// if (!sameLine) strcat(lineStr, yytext);
	printLine();
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