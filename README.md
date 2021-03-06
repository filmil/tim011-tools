# tim011-tools

The home of various TIM-011 related projects.

## timdisk

timdisk.sh is a BASH script that can extract, create and list TIM-011 floppy images. The script uses cpmtools package for this.

When extracting a floppy image, its contents is extracted into a directory with the following structure:
```
dirname/
dirname/1/
dirname/2/
...
```
User area 0 is extracted directly into directory, while other user areas are extracted into their own subdirectories. Same structure is used when creating floppy image from directory.

Script timdisk.sh uses the following files:
* diskdefs - definitions of SB180 floppy formats for cpmtools
* empty.img - initial empty image used for new image creation

For detailed usage, type:
```
timdisk.sh -h
```
Empty image that is provided is made with boot sector extracted using dsktools and may not be as clean as it could be. But, it is OK enough to recreate TIM system disk. Further investigation is required...

## TimFont

timfont.py is a Python 2/3 script that can extract a font used by TIM-011 into a PNG file, and also generate a COM file from PNG.

Be sure that program you use for editing PNG won't change its format: 1 byte per pixel, greyscale, no alpha channel, no layers or anything else.
Photoshop users should use the "Flatten Layers" option before saving their PNG file.
GIMP users should export the image as "8bpc GRAY".

When converting to COM file, white color is the only one recognised as character color, so be sure that you do not change the palette.

Currently, only two fonts for TIM-011 are known, one inside ASC.COM (English) and the other one inside CIR.COM (Serbian cyrilic).
To be able to generate COM file with new font, the script needs DEFAULT.COM that is also included here (this is just a copy of ASC.COM).

![English font](./images/timfont0.png)

Each TIM-011 character is defined with 10 bytes.
Two lowest bits of each definition byte aren't used, so effective size is 6x10 pixels.
When generating PNG, those 2 lower bits are colored differently and should not be used for defining the characters.

Here are some examples of fonts done by Marko Šolajić:

![Example 1](./images/timfont1.jpg)
![Example 2](./images/timfont2.jpg)

## TimTile

timtile.py is a Python 2/3 script that converts PNG files into TIM-011 tiles supported by its graphic library for Small C compiler.

Use provided template for drawing (sprites.png), or create your own.
Be sure that program you use for editing PNG won't change its format: 1 byte per pixel, greyscale, no alpha channel, no layers or anything else.
Photoshop users should use the "Flatten Layers" option before saving their PNG file.
GIMP users should export the image as "8bpc GRAY".

Only colors recognised as pixels are 40h, 80h and FFh which represent the colors 01b, 10b and 11b on TIM-011.
All other colors will be treated as black (00b).

For each PNG file a separate '.h' file with DB definitions of each tile will be created.
That file can be directly imported into Small C programs.

First tile is considered to be a color picker and it is not converted.
All tiles that consist of only black pixels also are not converted.

You can make PNG of any size, the program will go row by row of 16x16 tiles and do the conversion.

File 'sprites.png' contains some tile examples.
One sprite was taken from each of these ZX Spectrum games: Manic Miner, Ghosts'n'Goblins and Dizzy 1.

## CP/M emulator with TIM-011 video output simulation

I have found a wonderful CP/M emulator that enabled me to easy integrate simulation of TIM-011 video output:

[ANSI CP/M Emulator](https://github.com/jhallen/cpm)

Since that emulator emulates Z80 at full speed of host processor, pauses were introduced in video memory access, to kind-of simulate the speed of real TIM-011.
Take note that speed of emulator and real TIM-011 aren't the same.

Modified emulator can be found inside CPMEmulator directory.
To compile it, for now you'll need Linux and these libraries:

* for Debian/Ubuntu-based distributions: libx11-dev libxext-dev
* for Arch-based distributions: lib32-libx11 lib32-libxext

Window and video display code was taken from an old project of mine
(an assignment I gave to students a couple of years back, where thay had to implement iz x86 assembly basic pixel drawing functions into a video memory matrix, while I provided them with all the surrounding code for simulating such video output).

The modifications to the emulator:

* main.c
    * emulator loop inside main() function was moved into separate function/thread
    * input() and output() functions were extended to check for TIM-011 video memory access
    * main() function is extended to handle X11 window manpulation and drawing
* Makefile
    * linker options were added for required libraries

