// filmil@gmail.com: Sep 6, 2021.
// Ported to gcc: removed mescc-specific headers.
// Added support for non-sequential ihx lines.
// Removed the insistence on specifying a filename without extension.
//
/*	hextocom.c

	Converts an HEX file into a COM file for CP/M.

	(C) 2007-2016 FloppySoftware (Miguel I. Garcia Lopez, Spain).

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 2 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

	To compile with MESCC:

	cc hextocom
	ccopt hextocom.zsm
	zsm hextocom
	hextocom hextocom

	Revisions:

	(hextobin.c)

	18 Apr 2007 : v1.00 :
	21 Apr 2007 :       : Shows first and last addresses, code size.
	29 Apr 2007 : v1.01 : Bug showing code size upper than 0x8000 (shows
	                      negative number). Changed %d to %u to solve this bug.
	15 May 2007 : v1.02 : Change usage text.

	(hextocom.c)

	13 Nov 2014 : v1.03 : Modified to generate COM files for CP/M.
	04 Sep 2015 : v1.04 : Modified some comments and messages.
	10 Jan 2016 : v1.05 : Cleaned.
*/

/* Defines for MESCC libraries
   ---------------------------
*/
#define CC_FILEIO_SMALL // Exclude fread(), fwrite() and fgets().

/* Standard MESCC library
   ----------------------
*/
//#include <mescc.h>

/* Standard MESCC libraries
   ------------------------
*/
#include <printf.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Project defs.
   -------------
*/
#define APP_NAME    "HexToCom"
#define APP_VERSION "v1.05 / 10 Jan 2016"
#define APP_COPYRGT "(c) 2007-2016 FloppySoftware"
#define APP_USAGE   "HexToCom filename"


#define BYTE unsigned char

#define WORD unsigned int

/* Globals
   -------
*/
FILE	*fpi,  /* HEX - Input file  */
	*fpo;  /* COM - Output file */

BYTE chksum;   /* Checksum of current line */

WORD	adr,       /* Load address */
	ladr,      /* Load address of current line */
	madr, /* max address we ever got to. */
	first_adr; /* First address */

int	lbytes,    /* Number of data bytes of current line */
	line,      /* Number of current line */
	run,       /* Zero to exit program */
	flag_adr;  /* Zero if load address undefined */

char fn_hex[FILENAME_MAX],  /* HEX - filename */
     fn_com[FILENAME_MAX];  /* COM - filename */

/* Print error and exit
   --------------------
*/
void error(char* txt)
{
	printf("%s: %s.\n", APP_NAME, txt);
	exit(-1);
}

/* Print error with line number and exit
   -------------------------------------
*/
void errorln(char* txt)
{
	printf("%s: Error in line %d - %s.\n", APP_NAME, line, txt);
	exit(-1);
}

/* Read hex nibble
   ---------------
*/
BYTE getnib()
{
	int c;

	c=fgetc(fpi);

	if(c>='0' && c<='9')
		return c-'0';
	
	if(c>='A' && c<='F')
		return c-'A'+10;

	if(c==EOF)
		error("Unexpected EOF");

	error("Bad hexadecimal digit");
	return 1;
}

// Read a byte from the hex file.
BYTE gethex()
{
	BYTE nib, hex;

	nib=getnib();

	chksum+=(hex=(nib << 4) + getnib());

	return hex;
}

/* Write byte
   ----------
*/
void putbyte(BYTE byte)
{
	if(fputc(byte, fpo)==EOF)
		error("Writing COM file");
}

/* Main
   ----
*/
int main(int argc, char** argv)
{
	/* Program name, copyright, etc. */

	printf("%s %s\n\n", APP_NAME, APP_VERSION);
	printf("%s\n\n", APP_COPYRGT);

	/* Show usage? */

	if(argc != 3)
	{
		printf("Usage: %s\n", APP_USAGE);
		exit(0);
	}

	/* Filenames */

	strcpy(fn_hex, argv[1]);
	strcpy(fn_com, argv[2]);

	/* Open files */

	if((fpi=fopen(fn_hex, "r"))==NULL)
		error("Opening HEX file");

	if((fpo=fopen(fn_com, "wb"))==NULL)
		error("Opening COM file");

	/* Start process */

	first_adr=adr=0; /* Load address */
	line=run=1;      /* Line number and loop variable */
	flag_adr=0;      /* Load address undefined */
	madr = 0; /* Start from 0 */

	while(run)
	{
		if(fgetc(fpi) != ':')
			errorln("Missing colon");

		chksum=0;

		lbytes=gethex(); /* Bytes per line */

		ladr=gethex();
		ladr=(ladr<<8)+gethex(); /* Load adress */

		switch(gethex()) /* Line type */
		{
			case 0 : /* Data */
				if(!lbytes)
				{
					run = 0;
					break;
				}

				if(!flag_adr)
				{
					if((first_adr=adr=ladr) != 0x0100)
						error("Start address must be 0100H");

					++flag_adr;
				}
				else if(adr<ladr)
				{
					if (adr < madr) {
						int err = fseek(fpo, 0, SEEK_END);
						if (err != 0) {
							error("could not seek");
						}
						adr = madr;
					}
					while(adr!=ladr)
					{
						putbyte(0);
						++adr;
					}
				}
				else if(adr>ladr) {
					// Not sequential, needs a rewind.
					int err = fseek(fpo, ladr-0x100, SEEK_SET);
					if (err != 0) {
					   errorln("Bad address");
					}
					adr = ladr;
				}

				adr+=lbytes;

				while(lbytes--)
					putbyte(gethex()); 

				// Remember the max address we went to.
				if (adr > madr) { 
					madr = adr;
				}
				break;
			case 1 : /* End */
				run=0;
				break;
			default :
				errorln("Unknown record type");
				break;
		}

		gethex(); /* Checksum */

		if(chksum)
			errorln("Bad checksum");

		if(fgetc(fpi)!='\n')
			errorln("Missing newline");

		++line;
	}

	/* Close files */

	if(fclose(fpi))
		error("Closing HEX file");

	if(fclose(fpo))
		error("Closing COM file");

	/* Print facts */

	printf("First address: %04x\n", first_adr);
	printf("Last address:  %04x\n", adr-1);
	printf("Size of code:  %04x (%u dec) bytes\n", adr-first_adr, adr-first_adr);

}
