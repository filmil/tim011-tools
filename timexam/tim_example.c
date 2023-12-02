#include "lib/tim/timgraph.h"
#include "lib/sprites/sprites_sdcc.h"

int main(void) {

    // Works.
    for (int i = 0; i < 100; i++) {
        plotxy(i, i, COLOR_BRIGHT_GREEN);
    }

    line(COLOR_BRIGHT_GREEN, 100, 100, 200, 0);


    puttile(6,5,pacman2);
    puttile(10,10,miner);

    puttile(20,10,ghosts1);
    puttile(24,10,ghosts2);
    puttile(20,14,ghosts3);
    puttile(24,14,ghosts4);

    puttile(10,20,dizzy1);
    puttile(14,20,dizzy2);
    puttile(10,24,dizzy3);
    puttile(14,24,dizzy4);

    // Does not work.
    for(;;);
}
