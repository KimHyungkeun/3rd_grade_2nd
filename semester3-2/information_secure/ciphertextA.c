#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(void) {

    char *str = "GURTERNGRFGTYBELVAYVIVATYVRFABGVAARIRESNYYVATOHGVAEVFVATRIRELGVZRJRSNYY";
    int len = strlen(str);
    int i,j;
    int shift = 13;
    char newstr[72] = "\0";


        for (j=0;j<len;j++) {

             newstr[j] = str[j] - shift;

             if(newstr[j] < 65) {
                newstr[j] += 26;
            }

            
        }

        printf("%s\n\n", newstr);

    exit(0);

}
