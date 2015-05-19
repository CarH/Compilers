%{
#include <stdio.h>     
#include <stdlib.h>
#include <cstring>
#include <iostream>
#include "myscanner.h"

using namespace std;


// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
void check(char* ident, char *expected);
extern int line_num;
%}

%locations
%define parse.error verbose
%union 
{
    int numi;
    float numf;
    char *str;
}        /* definições do yacc */

%start programa
%token ERRODESC              
%token <str>IDENT                 // NOME DO PROGRAMA, POR EXEMPLO
%token SEMICOLON             // ;
%token ENDPOINT              // .
%token ATTRIBUTION           // :=
%token CONST_IDENT           // SERÁ QUE É O MESMO DE IDENT ? PQ EU ACHO Q A REGRA DISSO = REGRA DO IDENT
%token COLON                 // :
%token TYPE                 // integer/real
%token COMMA                // ,
%token PROCEDURE_IDENT      // NOME DO PROCEDIMENTO
%token OPEN_PAR             // (
%token CLOSE_PAR            // )
%token EQUAL                // =
%token DIF                  // <>
%token GREATER_EQUAL        // >=
%token LESSER_EQUAL         // <=
%token GREATER              // >
%token LESSER               // <
%token PLUS                 // +
%token MINUS                // -
%token MULT                 // *
%token DIV                  // /
%token INTEGER_NUMBER       // NUMERO INTEIRO
%token REAL_NUMBER          // NUMERO REAL DIFERENTE DE INTEIRO
%token UNEXPECTED_CHAR      // Unexpected character
%token ERROINT
%token ERROIDENT
%token ERROFLOAT
%token PROGRAM           
%token BEG           
%token END           
%token IF           
%token ELSE           
%token CONST           
%token VAR           
%token PROCEDURE           
%token REAL           
%token INTEGER           
%token READ
%token WRITE
%token WHILE
%token DO
%token THEN
%token FOR
%token TO
%%

/* Gramática da linguagem. 
   Cada regra é associada a uma ação, descrita em código C. 
   Um ponto e vírgula significa não fazer nada. */


programa : PROGRAM IDENT SEMICOLON corpo ENDPOINT                           {;}
        ;
corpo : dc BEG comandos END                                                 {;}
        ;
dc : dc_c dc_v dc_p                                                         {;}
        ;
dc_c : CONST IDENT EQUAL numero SEMICOLON dc_c                              {;}
        | /*vazio*/                                                         {;}
        ;
dc_v : VAR variaveis COLON tipo_var SEMICOLON dc_v                          {;}
        | /*vazio*/                                                         {;}
        ;
tipo_var : REAL                                                             {;}
        | INTEGER                                                           {;}
variaveis : IDENT mais_var                                                  {;}
        ;
mais_var : COMMA variaveis                                                  {;}
        | /*vazio*/                                                         {;}
        ;
dc_p : PROCEDURE IDENT parametros SEMICOLON corpo_p dc_p                    {;}
        | /*vazio*/                                                         {;}
        ;
parametros : OPEN_PAR lista_par CLOSE_PAR                                   {;}
        | /*vazio*/                                                         {;}
        ;
lista_par : variaveis COLON tipo_var mais_par                                   {;}
        ;
mais_par : SEMICOLON lista_par                                              {;}
        | /*vazio*/                                                         {;}
        ;
corpo_p : dc_loc BEG comandos END SEMICOLON                                 {;}
        ;
dc_loc : dc_v                                                               {;}
        ;
lista_arg : OPEN_PAR argumentos CLOSE_PAR                                   {;}
        | /*vazio*/                                                         {;}
        ;
argumentos : IDENT mais_ident                                               {;}
mais_ident : SEMICOLON argumentos                                           {;}
        | /*vazio*/                                                         {;}
        ;
pfalsa : ELSE cmd                                                           {;}
        | /*vazio*/                                                         {;}
        ;
comandos : cmd SEMICOLON comandos                                           {;}
        | /*vazio*/                                                         {;}
        ;
cmd : READ OPEN_PAR variaveis CLOSE_PAR                                     {;}
        | WRITE OPEN_PAR variaveis CLOSE_PAR                                {;}
        | WHILE OPEN_PAR condicao CLOSE_PAR DO cmd                          {;}
        | IF condicao THEN cmd pfalsa                                       {;}
        | IDENT ATTRIBUTION expressao                                       {;}
        | IDENT lista_arg                                                   {;}
        | BEG comandos END                                                  {;}
        | FOR IDENT ATTRIBUTION numero TO numero DO BEG comandos END        {;}
        ;
condicao : expressao relacao expressao                                      {;}
        ;
relacao : EQUAL                                                             {;}
        | DIF                                                               {;}
        | GREATER_EQUAL                                                     {;}
        | LESSER_EQUAL                                                      {;}
        | GREATER                                                           {;}
        | LESSER                                                            {;}
        | /*vazio*/                                                         {;}
        ;
expressao : termo outros_termos                                             {;}
        ;
op_un : PLUS                                                                {;}
        | MINUS                                                             {;}
        | /*vazio*/                                                         {;}
        ;
outros_termos : op_ad termo outros_termos                                   {;}
        | /*vazio*/                                                         {;}
        ;
op_ad : PLUS                                                                {;}
        | MINUS                                                             {;}
        ;
termo : op_un fator mais_fatores                                            {;}
        ;
mais_fatores : op_mul fator mais_fatores                                    {;}
        | /*vazio*/                                                         {;}
        ;
op_mul : MULT                                                               {;}
        | DIV                                                               {;}
        ;
fator : IDENT                                                               {;}
        | numero                                                            {;}
        | OPEN_PAR expressao CLOSE_PAR                                      {;}
        ;
numero : INTEGER_NUMBER                                                     {;}
        | REAL_NUMBER                                                       {;}
        ;




%%

/* Código C inserido diretamente no arquivo gerado pelo yacc */

void check(char* ident, char *expected)
{  
    char *erro = (char*)malloc(256 * sizeof(char));
    
    if (strcmp(ident, expected))
    {
        sprintf(erro, "Era esperada a palavra reservada %s, encontrou-se %s",expected, ident);
        yyerror(erro);
    }
    else
    {
        int tam = strlen(ident);
        if (tam > MAIORTAMANHO)
        {
            sprintf(erro, "%s excede tamanho maximo de %d caracteres (Possui %d caracteres)\n",ident,MAIORTAMANHO,tam);
            yyerror(erro);
        }
    }
    free(erro);
}
/**/

int main(int argc, char const *argv[]){
    int ntoken;
    int tam;

    /// Inicializa a TRIE apropriadamente
    ///

    return yyparse ( );
}
void yyerror(const char *str)
{
    fprintf(stderr,"Line %d: %s\n",line_num,str);
    exit(-1);
}
