%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

#define MAX_SYMBOLES 50

typedef struct
{
  char *identifiant;
  char *type;
  int evenement;
  int debut_chaine;
  int longueur_chaine;
}Symbole;

FILE * tab;
FILE * tab2;
Symbole table_symboles[MAX_SYMBOLES];
int nb_symboles=0;
char tableau2[10000] = "";
int debfin=0; // 0 si debut , 1 si fin

%}
%start LIGNEOK
%start DATEUOK
%start DATEROK
%start DATEJOK
%start NBOK
%start JOUROK
%start ALARM
%start TEXTOK
%%
BEGIN:VCALENDAR {printf("Début calendrier\n");return DEBCAL;}
END:VCALENDAR {printf("Fin calendrier\n");return FINCAL;}
BEGIN:VEVENT {printf("Début événement\n"); BEGIN LIGNEOK;return DEBEVT;}
END:VEVENT {printf("Fin événement\n");return FINEVT;}
<LIGNEOK>DTSTART: {inserer_symbole("EVT", "UNIQ", NULL, NULL);debfin=0; printf("intro heure début evt unique\n"); BEGIN DATEUOK;return IDEBEVTU;}
<LIGNEOK>DTEND: {debfin=1;printf("intro heure fin evt unique\n"); BEGIN DATEUOK;return IFINEVTU;}
<LIGNEOK>SUMMARY: {inserer_symbole("TXT", "TITRE", 0, yyleng); printf("intro titre\n"); BEGIN TEXTOK;return ITITRE;}
<LIGNEOK>LOCATION: {inserer_symbole("TXT", "LIEU", 0, yyleng); printf("intro lieu\n"); BEGIN TEXTOK;return ILIEU;}
<LIGNEOK>DESCRIPTION: {inserer_symbole("TXT", "DESCRIPTION", 0, yyleng); printf("intro description\n"); BEGIN TEXTOK;return IDESCR;}
<LIGNEOK>BEGIN:VALARM {inserer_symbole("ARM", "DEBUT", 0, yyleng); printf("Début alarme\n"); BEGIN ALARM;return DEBAL;}
<ALARM>END:VALARM {inserer_symbole("ARM", "FIN", 0, yyleng); printf("Fin alarme\n"); BEGIN LIGNEOK ; return FINAL;}
<ALARM>TRIGGER:	{printf("intro position alarme\n");return TRIGGER;}
<LIGNEOK>RRULE:		{printf("intro règle répétition\n");return RRULE;}
<LIGNEOK>FREQ=		{printf("intro fréquence\n");return FREQ;}
<LIGNEOK>COUNT=		{printf("intro compteur\n"); BEGIN NBOK;return COUNT;}
<LIGNEOK>BYDAY=		{printf("intro liste jours\n"); BEGIN JOUROK;return BYDAY;}
<LIGNEOK>UNTIL=	{printf("intro limite\n"); BEGIN DATEUOK;return UNTIL;}
<LIGNEOK>WKST=SU		{printf("changement de semaine\n");return WKST;}
<LIGNEOK>DAILY|WEEKLY|MONTHLY|YEARLY {printf("frequence : %s\n", yytext);return VALFREQ;}
<LIGNEOK>; {printf("séparateur options\n");return PV;}
<LIGNEOK>DTSTART;TZID=[a-zA-Z/]+: {inserer_symbole("EVT", "REPET", NULL, NULL); debfin=0;  printf("intro heure début evt répétitif\n");
BEGIN DATEROK;return DEBEVTR;}
<LIGNEOK>DTEND;TZID=[a-zA-Z/]+: {debfin=1; printf("intro heure fin evt répétitif\n");
BEGIN DATEROK;return FINEVTR;}
<LIGNEOK>DTSTART;VALUE=DATE: {inserer_symbole("EVT", "JOUR", NULL, NULL);debfin=0; printf("intro heure début evt journée\n");
BEGIN DATEJOK;return DEBEVTJ;}
<LIGNEOK>DTEND;VALUE=DATE: {debfin=1; printf("intro heure fin evt journée\n");
BEGIN DATEJOK;return FINEVTJ; }
<ALARM>"-P"[0-9]+DT[0-9]+H[0-9]+M[0-9]+S {printf("position alarme : %s\n", yytext);return POSAL;}
<DATEJOK>[0-9]{4}((0[1-9])|(1[0-2]))((0[1-9])|([1-2][0-9])|(3[0-1])) {if(debfin == 0 )
                  {
                    inserer_symbole("DAT", "DEBUT", 0, yyleng);
                  }
                  else 
                  {
                    inserer_symbole("DAT", "FIN", 0, yyleng);
                  } 
                  ajouter_chaine_tableau2(yytext);
                  printf("date evt journée : %s\n", yytext);
                  BEGIN LIGNEOK;return DATEVTJ; }
<NBOK>[0-9]+ {ajouter_chaine_tableau2(yytext); printf("nombre entier : %s\n", yytext); BEGIN LIGNEOK;return NOMBRE; }
<DATEROK>[0-9]{4}((0[1-9])|(1[0-2]))((0[1-9])|([1-2][0-9])|(3[0-1]))T(([0-1][0-9])|(2[0-3]))[0-5][0-9][0-5][0-9] { if(debfin == 0 )
                            {
                              inserer_symbole("DAT", "DEBUT", 0, yyleng);
                            }
                            else 
                            {
                              inserer_symbole("DAT", "FIN", 0, yyleng);
                            } 
                              ajouter_chaine_tableau2(yytext);
                              printf("date et heure evt répétitif : %s\n", yytext);
                              BEGIN LIGNEOK;return DATEVTR;
                           }
<DATEUOK>[0-9]{4}((0[1-9])|(1[0-2]))((0[1-9])|([1-2][0-9])|(3[0-1]))T(([0-1][0-9])|(2[0-3]))[0-5][0-9][0-5][0-9]Z {if(debfin == 0 )
                            {
                              inserer_symbole("DAT", "DEBUT", 0, yyleng);
                            }
                            else 
                            {
                              inserer_symbole("DAT", "FIN", 0, yyleng);
                            } 
                            ajouter_chaine_tableau2(yytext);
                            printf("date et heure evt unique : %s\n", yytext);
                            BEGIN LIGNEOK;return DATEVTU;}
<JOUROK>(SU|MO|TU|WE|TH|FR|SA)(,(SU|MO|TU|WE|TH|FR|SA)){0,6} {printf("liste jours : %s\n", yytext);
BEGIN LIGNEOK;return LISTJ;}
<TEXTOK>[^:\n]*$ {ajouter_chaine_tableau2(yytext); printf("Lieu, description ou titre : %s\n",yytext); BEGIN LIGNEOK;return TEXTE;}
.|\n ;
%%

void inserer_symbole(char *identifiant,char *type,int evenement,int longueur_chaine)
{
  if()
  Symbole symbole;
  symbole.identifiant=identifiant;
  symbole.type=type;
  symbole.evenement=evenement;
  if ((nb_symboles != 0)&&(identifiant != "EVT"))
    if(table_symboles[nb_symboles-1].identifiant != "EVT")
      symbole.debut_chaine=table_symboles[nb_symboles-1].debut_chaine + table_symboles[nb_symboles-1].longueur_chaine;
    else
      symbole.debut_chaine=table_symboles[nb_symboles-2].debut_chaine + table_symboles[nb_symboles-2].longueur_chaine;
  else if (identifiant == "EVT")
    symbole.debut_chaine = NULL;
  else
    symbole.debut_chaine = 0 ;
  symbole.longueur_chaine=longueur_chaine;
  table_symboles[nb_symboles]=symbole;
  nb_symboles++;
}

Symbole *rechercher_symbole(char *identifiant)
{
 for (int i=0;i<nb_symboles;i++)
 {
   if(strcmp(table_symboles[i].identifiant,identifiant)==0)
   {
     return &table_symboles[i];
   }
 }
 return NULL;
}


void ajouter_chaine_tableau2(char *chaine)
{
    int longueur=strlen(chaine);
    if(strlen(chaine) == 1 && chaine[0] == '\n')
    {
      printf("VIDE");
    }
    else
    {
      strcat(tableau2, chaine);
    }
}

void lireTab1() 
{
  tab = fopen("tableau.txt", "w+");
  for (int i = 0; i < sizeof(table_symboles) / sizeof(table_symboles[0]); i++) 
  {
      Symbole s = table_symboles[i];
      fprintf(tab, "%s, %s, %i, %i, %i\n", s.identifiant, s.type, s.evenement, s.debut_chaine, s.longueur_chaine);
  }
  fclose(tab);
}

void lireTab2() 
{
  tab2 = fopen("tableau2.txt", "w+");
  fprintf(tab2, "%s\n", tableau2);
  fclose(tab2);
}
/*
bool verifierDate(char *chaine)
{
 int longueur=strlen(chaine);
 bool verif=false;
 if(longueur == 8 ){
  verif=true;
 }
return verif;
} 
*/

int yywrap()
{
  	lireTab1();
  	lireTab2();
  return 1;
}