# tim011-tools

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
