#include "mescc.h"

#include <timgraph.lib>
#include "sprites.h"

main() {
    int i, j;
    unsigned char f;
    f = 0;
/*
    for (j = 0; j < 10; j++) {
        for (i = 0; i < 200; ++i) {
            plotxy(i+0,i+0,0);
            plotxy(i+10,i,0);
            plotxy(i+20,i,0);
        }
        for (i = 0; i < 200; ++i) {
            plotxy(i+0,i+0,3);
            plotxy(i+10,i,2);
            plotxy(i+20,i,1);
        }
    }

    for (j = 0; j < 256; j++) {
        for (i = 0; i < 200; ++i) {
            scroll(j);
        }
    }
*/

/*
    for (i = 0; i < 200; ++i) {
        plotxy(i+0,i+0,3);
        plotxy(i+10,i,2);
        plotxy(i+20,i,1);
        plotxy(i+100,i+0,3);
        plotxy(i+110,i,2);
        plotxy(i+120,i,1);
    }

    gettile(0,20,backgr);
    for (i = 1; i < 80; ++i) {
        puttile(i-1,20,backgr);
        gettile(i,20,backgr);
        ortile(i,20,sprite);
    }

    for (j = 0; j < 256; j++) {
        for (i = 0; i < 200; ++i) {
            scroll(j);
        }
    }
*/

    puttile(2,5,0);
    puttile(6,5,pacman2);
    puttile(10,5,2);
    puttile(10,10,miner);

    puttile(20,10,ghosts1);
    puttile(24,10,ghosts2);
    puttile(20,14,ghosts3);
    puttile(24,14,ghosts4);

    puttile(10,20,dizzy1);
    puttile(14,20,dizzy2);
    puttile(10,24,dizzy3);
    puttile(14,24,dizzy4);

/*
    for (i = 0; i < 127; i+=4) {
        for (j = 0; j < 63; j+=4) {
            puttile(i,j,sprite);
            if (f & 1)
                flptilex(sprite);
            else
                flptiley(sprite);
            f++;
        }
        if (f & 1)
            flptilex(sprite);
        else
            flptiley(sprite);
        f++;
    }
*/
    return 0;
}

