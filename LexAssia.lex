%{
#include <stdio.h>
#include <stdlib.h>
  #include <errno.h>
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

 FILE *filestream;
FILE * tab;
FILE * tab2;
Symbole table_symboles[MAX_SYMBOLES];
int nb_symboles=0;
char tableau2[10000] = "";
int debfin=0; // 0 si debut , 1 si fin

char titre[1000];
char lieu[1000];
char description[1000];

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
<LIGNEOK>DTSTART: {inserer_symbole("EVT", "UNIQ", NULL, NULL);debfin=0; printf("intro heure début evt unique\n");
 BEGIN DATEUOK;return IDEBEVTU;}
<LIGNEOK>DTEND: {debfin=1;printf("intro heure fin evt unique\n"); BEGIN DATEUOK;return IFINEVTU;}
<LIGNEOK>SUMMARY: {inserer_symbole("TXT", "TITRE", 0, yyleng); printf("intro titre\n"); BEGIN TEXTOK;return ITITRE;}
<LIGNEOK>LOCATION: {inserer_symbole("TXT", "LIEU", 0, yyleng); printf("intro lieu\n"); BEGIN TEXTOK;return ILIEU;}
<LIGNEOK>DESCRIPTION: {inserer_symbole("TXT", "DESCRITION", 0, yyleng); printf("intro description\n"); BEGIN TEXTOK;return IDESCR;}
<LIGNEOK>BEGIN:VALARM {inserer_symbole("ARM", "DEBUT", 0, yyleng); printf("Début alarme\n"); BEGIN ALARM;return DEBAL;}
<ALARM>END:VALARM {inserer_symbole("ARM", "FIN", 0, yyleng); printf("Fin alarme\n"); BEGIN LIGNEOK ; return FINAL;}
<ALARM>TRIGGER: {printf("intro position alarme\n");return TRIGGER;}
<LIGNEOK>RRULE: {printf("intro règle répétition\n");return RRULE;}
<LIGNEOK>FREQ= {printf("intro fréquence\n");return FREQ;}
<LIGNEOK>COUNT= {printf("intro compteur\n"); BEGIN NBOK;return COUNT;}
<LIGNEOK>BYDAY= {printf("intro liste jours\n"); BEGIN JOUROK;return BYDAY;}
<LIGNEOK>UNTIL= {printf("intro limite\n"); BEGIN DATEUOK;return UNTIL;}
<LIGNEOK>WKST=SU {printf("changement de semaine\n");return WKST;}
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
<DATEJOK>[0-9]{8} {if(debfin == 0 )
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
<DATEROK>[0-9]{8}T[0-9]{6} { if(debfin == 0 )
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
<DATEUOK>[0-9]{8}T[0-9]{6}Z {if(debfin == 0 )
                            {
                              inserer_symbole("DAT", "DEBUT", 0, yyleng);
                            }
                            else
                            {
                              inserer_symbole("DAT", "FIN", 0, yyleng);
                            }
                            ajouter_chaine_tableau2(yytext);
                            printf("date et heure evt unique : %s\n", yytext); fprintf(filestream, "<h1><span style=\"color:black;\">Du %s </span></h1>\n", yytext);
                            BEGIN LIGNEOK;return DATEVTU;}
<JOUROK>(SU|MO|TU|WE|TH|FR|SA)(,(SU|MO|TU|WE|TH|FR|SA)){0,6} {printf("liste jours : %s\n", yytext);
BEGIN LIGNEOK;return LISTJ;}
<TEXTOK>[^:\n]*$ {ajouter_chaine_tableau2(yytext); printf("Lieu, description ou titre : %s\n",yytext); BEGIN LIGNEOK;return TEXTE;}
.|\n ;
%%

void inserer_symbole(char *identifiant,char *type,int evenement,int longueur_chaine)
{
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

    if(strlen(chaine) == 1 && chaine[0] == ' ')
    {
      printf("VIDE");
    }
    else
    {
      strcat(tableau2, chaine);
    }
}

void recupTitre(char chaine){
  if (strcmp(table_symboles[i].identifiant, "TXT" && table_symboles[i].type, "TITRE")== 0){
strncpy(chaine, symbole.debut_chaine, table_symboles[i].longueur_chaine);
  }
}

void recupLieu(char chaine){
  if (strcmp(table_symboles[i].identifiant, "TXT" && table_symboles[i].type, "LIEU")== 0){
strncpy(chaine, symbole.debut_chaine, table_symboles[i].longueur_chaine);
  }
}
void recupDescription(char chaine){
  if (strcmp(table_symboles[i].identifiant, "TXT" && table_symboles[i].type, "DESCRITION")== 0){
strncpy(chaine, symbole.debut_chaine, table_symboles[i].longueur_chaine);
  }
}

void afficherEvenement(){
char* couleur = "";
for ( int i=0;i< nb_symboles; i++){
        if (table_symboles[i].type == "UNIQ") {
            couleur = "black";
        } else if (table_symboles[i].type == "REPET") {
            couleur = "green";
        } else if (table_symboles[i].type == "JOUR") {
            couleur = "red";
        }
}
              recupTitre(titre);
              recupLieu(lieu);
              recupDescription(description);
              if (strlen(titre) == 0) {
                fprintf(filestream, "<h2><span style=\"color:%s;\">Sans titre</span></h2>\n", couleur);
              } else {
                fprintf(filestream, "<h2><span style=\"color:%s;\">%s</span></h2>\n", couleur, titre);
                  }
                  if (strlen(lieu) == 0) {
                    fprintf(filestream, "<p style=\"color:%s;\">Lieu: <span style=\"color:%s;\">Pas de lieu</span></p>\n", couleur, couleur);
                    } else {
                      fprintf(filestream, "<p style=\"color:%s;\">Lieu: <span style=\"color:%s;\">%s</span></p>\n", couleur, couleur, lieu);
                      }
                      if (strlen(description) == 0) {
                        fprintf(filestream, "<p style=\"color:%s;\">Description: <span style=\"color:%s;\">Pas de description</span></p>\n", couleur, couleur);
                        } else {
                            fprintf(filestream, "<p style=\"color:%s;\">Description: <span style=\"color:%s;\">%s</span></p>\n", couleur, couleur, description);
                            }
}



int nb_evenements_total() {
 int nb_evt_total=0;

    for (int i = 0; i < nb_symboles; i++) {
        if (strcmp(table_symboles[i].identifiant, "EVT") == 0){
            nb_evt_total++;
        }
    }
   return nb_evt_total;
}





int nb_evenements_unique() {
  int nb_evt_uniq = 0;
  for (int i = 0; i < nb_symboles; i++) {
      if (!strcmp(table_symboles[i].identifiant, "EVT") &&  !strcmp(table_symboles[i].type, "UNIQ")) {
          nb_evt_uniq++;

      }
  }
  return nb_evt_uniq;


}

int nb_evenements_repetitifs() {
  int nb_evt_repet = 0;
  for (int i = 0; i < nb_symboles; i++) {
      if (!strcmp(table_symboles[i].identifiant, "EVT") &&  !strcmp(table_symboles[i].type, "REPET")) {
          nb_evt_repet++;
      }
  }
  return nb_evt_repet;
}


int nb_evenements_journee() {
  int nb_evt_day = 0;
  for (int i = 0; i < nb_symboles; i++) {
      if (!strcmp(table_symboles[i].identifiant, "EVT") &&  !strcmp(table_symboles[i].type, "JOUR")) {
          nb_evt_day++;
      }
  }
  return nb_evt_day;
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

nb_evenements_total();
nb_evenements_unique();
nb_evenements_repetitifs();
nb_evenements_journee();
  return 1;

}
