%{
// Exemplo de reconhecimento de números e texto 
#include <iostream>
#include <fstream>
using namespace std;

bool doctype_already_seen = false;	// flag para saber se <!DOCTYPE html> já foi processado
unsigned tabs = 0;	// quantidade de tabs para printar na tela
unsigned tags = 0;	// quantidade de tags no documento
unsigned charcount = 0;	// quantidade de caracteres visíveis
unsigned currentcharcount = 0;	// quantidade atual de caractéres dentro de uma tag
unsigned lines = 1;	// quantidade de linhas do documento

void print_tabs();
void print_tag(const char*);
void handle_current_char_count();
%}

%option noyywrap
%x 								TEXT	
%x 								COMMENT
%x								STYLETAG

letter                 			[a-z] 
number                 			[0-9]
parent_tags             		html|head|title|h[1-6]|body|p|b|i|table|tr|th|td|ul|li|a
childless_tags          		br|img
attrs                  			{letter}+[{number}{letter}]*=\".*\"
open_tag                		\<{parent_tags}(" "{attrs}*)?\>
close_tag               		<\/{parent_tags}\>
childless_tag           		\<{childless_tags}(" "{attrs}*)?\>

%%

"<!DOCTYPE html>"											{ 
																if (!doctype_already_seen) 
																	doctype_already_seen = true;
																else 
																	REJECT;
															}

<COMMENT,STYLETAG,INITIAL>\n								{ lines++; }

"<!--"														{ BEGIN COMMENT; }
<COMMENT>"-->"												{ BEGIN INITIAL; }
<COMMENT>.													{ ; }

"<style>"													{ BEGIN STYLETAG; print_tag(YYText()); tags++; }
<STYLETAG>"</style>"										{ BEGIN INITIAL; print_tag(YYText()); }
<STYLETAG>.													{ ; }

[ \t]                           							{ ; }

{open_tag}                       							{ print_tag(YYText()); tabs++; }
{close_tag}                      							{ tags++; tabs--; print_tag(YYText()); }
{childless_tag}                  							{ print_tag(YYText()); tags++; }

.                               							{ BEGIN TEXT; currentcharcount++; charcount++; }
<TEXT>{open_tag}|{close_tag}|{childless_tag}				{ yyless(0); handle_current_char_count(); BEGIN INITIAL; }
<TEXT>"<!--"												{ yyless(0); BEGIN INITIAL; }
<TEXT>\n													{ lines++; handle_current_char_count(); }
<TEXT>.														{ currentcharcount++; charcount++; }

%%

void print_tabs() {
    for (int i = 0; i < tabs; i++) {
        cout << "|\t";
    }

    cout << "+--";
}

void print_tag(const char* tag) {
	print_tabs(); 
	cout << tag << endl;
}

void handle_current_char_count() {
	print_tabs();
	cout << "Texto[" << currentcharcount << ']' << endl;
	currentcharcount = 0;
}

int main(int argc, char ** argv)
{
	yyFlexLexer lexer;
	ifstream fin;
	ofstream fout;

	if (argc > 1) 
	{    
		fin.open(argv[1]);
		if (!fin.is_open()) 
        {
			cout << "Arquivo " << argv[1] << " não pode ser aberto!\n";
			exit(EXIT_FAILURE);
		}
		else
		{
			// altera entrada para arquivo aberto
			lexer.switch_streams(&fin);
		}
	}

	lexer.yylex();

	cout << endl << "TAGS HTML: " << tags << endl;
	cout << "Linhas: " << lines << endl;
	cout << "Caracteres: " << charcount << endl;
    
	fin.close();
	return 0;
}