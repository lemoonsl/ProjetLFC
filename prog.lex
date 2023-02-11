%{
	//Compilation
	//lex -v exemple0.lex
	//gcc -Wall lex.yy.c -o analyseur -lfl
	
#include <stdio.h>

%}

%%




BEGIN:VCALENDAR { printf("début calendrier \n");
} ;
END:VCALENDAR] { printf("fin calendrier \n");
} ;
BEGIN:VEVENT { printf("début événement  \n");
} ;
END:VEVENT { printf("fin événement \n");
} ;
DTSTART: { printf("intro heure début evt unique  \n");
} ;
DTEND: { printf("intro heure fin evt unique   \n");
} ;
SUMMARY: { printf("intro titre    \n");
} ;
LOCATION: { printf("intro lieu   \n");
} ;
DESCRIPTION: { printf("intro description     \n");
} ;
BEGIN:VALARM { printf("début alarme \n");
} ;
END:VALARM { printf("fin alarme \n");
} ;
TRIGGER: { printf("intro position alarme      \n");
} ;
RRULE: { printf("intro règle répétition      \n");
} ;
FREQ= { printf("intro fréquence\n");
} ;
COUNT= { printf("intro compteur\n");
} ;
BYDAY= { printf("intro liste jours \n");
} ;
UNTIL= { printf("intro limite\n");
} ;
WKST=SU { printf("changement de semaine\n");
} ;
; { printf("séparateur d’options \n");
} ;
DTSTART;VALUE=DATE:  { printf("intro heure début evt journée\n");
} ;
DTEND;VALUE=DATE: { printf("intro heure fin evt journée \n");
} ;
.|\n ;
%%
int main(){

yylex();
return 0;
}

int yywrap(){
return 1;
}
