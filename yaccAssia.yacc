%{
    #include <stdio.h>
    int yyerror(char* s);
    extern FILE *filestream;
%}

%token DEBCAL FINCAL DEBEVT FINEVT IDEBEVTU IFINEVTU DATEVTU
%token ITITRE ILIEU IDESCR DEBAL TRIGGER POSAL FINAL TEXTE
%token RRULE FREQ COUNT BYDAY UNTIL WKST VALFREQ PV NOMBRE LISTJ
%token DEBEVTR FINEVTR DEBEVTJ FINEVTJ DATEVTJ DATEVTR
%start fichier

%%
fichier : DEBCAL liste_evenements FINCAL ;
liste_evenements : evenement liste_evenements | ;
evenement : DEBEVT infos_evenement FINEVT ;
infos_evenement : infos_evenement_unique | infos_evenement_repetitif | infos_evenement_journalier ;
infos_evenement_unique : IDEBEVTU DATEVTU IFINEVTU DATEVTU suite_infos_evenement ;
suite_infos_evenement : les_textes liste_alarmes ;
les_textes : IDESCR TEXTE ILIEU TEXTE ITITRE TEXTE ;
infos_evenement_repetitif : DEBEVTR DATEVTR FINEVTR DATEVTR repetition suite_infos_evenement ;
infos_evenement_journalier : DEBEVTJ DATEVTJ FINEVTJ DATEVTJ suite_infos_evenement ;
liste_alarmes : alarme liste_alarmes | ;
alarme : DEBAL TRIGGER POSAL FINAL ;
repetition : RRULE FREQ VALFREQ PV WKST PV COUNT NOMBRE PV BYDAY LISTJ
    | RRULE FREQ VALFREQ PV UNTIL DATEVTU
    | RRULE FREQ VALFREQ PV WKST PV UNTIL DATEVTU
    | RRULE FREQ VALFREQ PV UNTIL DATEVTU PV BYDAY LISTJ
    | RRULE FREQ VALFREQ PV WKST PV UNTIL DATEVTU PV BYDAY LISTJ ;
%%

int yyerror(char* s)
 {
    fprintf(stdout,"\n Erreur -> %s \n",s);
    return 0;
 }



 int main()
 {

printf("\nFin des analyses lexicale et syntaxique\n");
filestream = fopen("monfichier.html", "w");
    if (filestream == NULL) {
       printf("Erreur: Impossible d'ouvrir le fichier\n");
       exit(1);
    }

    fprintf(filestream, "<p>%d événements rencontrés dans le fichier</p>\n", nb_evenements_total());
    fprintf(filestream, "<ul>\n<li>%d événements uniques : </li>\n", nb_evenements_unique());
    fprintf(filestream, "<li>%d événements répétitifs : </li>\n", nb_evenements_repetitifs());
    fprintf(filestream, "<li>%d événements à la journée : </li>\n</ul>", nb_evenements_journee());



    fclose(filestream);
    yyparse();


    return 0;
 }
