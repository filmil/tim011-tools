#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    TimFont8 (c) 2021  Žarko Živanov

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

from __future__ import print_function
from __future__ import division

VERSION="1.0"

import sys
import os
import argparse
import array
import png      # python-png / python3-png / pypng

###############################################
#               Common functions
###############################################

# returns the size of an open file
def flen(f):
    return os.fstat(f.fileno()).st_size

# prints error message and exits the program
def error(s):
    print("\nERROR: {0}\n".format(s))
    exit(1)

###############################################
#           Argument parser settings
###############################################
about = """TimFont8 %s (c) 2021  Zarko Zivanov

This program is used to convert PNG of ZX Spectrum
8x8 font into TIM-011 font used with its Small C
print library. Be sure to use 8-bit grayscale
format. Only colors recognised as pixels are 40h,
80h and FFh which represent the colors 01b, 10b
and 11b on TIM-011. All other colors will be
treated as black (00b).

For each PNG file a separate '.h' file with DB
definitions of each tile will be created. That file
can be directly imported into Small C programs.""" % (VERSION)

epilog="""
Be sure that program you use for editing PNG won't
change its format: 1 byte per pixel, greyscale, no
alpha channel, no layers or anything else. Photoshop
users should use the "Flatten Layers" option before
saving their PNG file. GIMP users should export the
image as "8bpc GRAY"."""

# to be used with later program version
#ASCII=""" !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"""
#ASCII_DICT={ASCII[pos]:pos for pos in range(len(ASCII))}
#ASCII_ALT1={ '\\':'/' , '_':'-' , "`":"'" , '{':'[' , '|':'/' , '}':']' , '~':'-' }
#ASCII_ALT2={ '\\':'\xFD' , '_':'\xFE' , "`":"'" , '{':'[' , '|':'/' , '}':']' , '~':'-' }

#C64SCR_LO="""@abcdefghijklmnopqrstuvwxyz[\xFD]^\xFE !"#$%&'()*+,-./0123456789:;<=>?\xFFABCDEFGHIJKLMNOPQRSTUVWXYZ"""
#C64SCR_LO_DICT={C64SCR_LO[pos]:pos for pos in range(len(C64SCR_LO))}

#C64SCR_HI="""@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\xFD]^\xFE !"#$%&'()*+,-./0123456789:;<=>?"""
#C64SCR_HI_DICT={C64SCR_HI[pos]:pos for pos in range(len(C64SCR_HI))}

#ZXASC=""" !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_\xFDabcdefghijklmnopqrstuvwxyz{|}~\xFF"""
#ASCII_DICT={ZXASC[pos]:pos for pos in range(len(ZXASC))}

parser = argparse.ArgumentParser(description=about, formatter_class=argparse.RawDescriptionHelpFormatter,epilog=epilog)
parser.add_argument('file', metavar='file', nargs='*', default="", help='(path to) PNG file')

# parse command line
args = parser.parse_args()

# recognised colors - all others will be color 00 - black
colors = {0x00:0x00, 0x40:0x01, 0x80:0x02, 0xFF:0x03}

if len(args.file) == 0:
    error("At least one PNG file name is required. Add '-h' for help.")

tileWidth = 8
tileHeight = 8

for pngFile in args.file:
    if not os.path.exists(pngFile):
        error("File '%s' not found!" % pngFile)
    if not pngFile[-4:] in [".png", ".PNG"]:
        error("Image '%s' must have a 'png' extension!" % pngFile)

    # read PNG file
    pngObject = png.Reader(pngFile)
    pngDirect = pngObject.asDirect()
    tileMatrix = list(pngDirect[2])
    
    # open ZSM file for writing
    zsmName = "%s.h" % pngFile[:-4]
    zsmFile = open(zsmName, "w")
    zsmFile.write("#asm\n%s:\n" % pngFile[:-4])

    tilesW = len(tileMatrix[0]) // tileWidth
    tilesH = len(tileMatrix) // tileHeight
    print("Creating '%s', %dx%d tiles found ..." % (zsmName, tilesW, tilesH))

    for tileY in range(tilesH):
        for tileX in range(tilesW):
#            if (tileX == 0) and (tileY == 0): continue
            defb = []
            xBytes = tileWidth // 4
            for xx in range(xBytes):
                for y in range(tileHeight):
                    byte = 0
                    for x in range(xx*4+3, xx*4-1,-1):
                        try:
                            col = colors[tileMatrix[y+tileY*tileHeight][x+tileX*tileWidth]]
                        except:
                            col = 0
                        byte <<= 2
                        byte |= col
                    defb.append(byte)
#            if sum(defb) == 0: continue
            #print("; %s [%d,%d]" % (pngFile, tileX, tileY), end="")
            zsmFile.write("; %s [%d,%d]" % (pngFile, tileX, tileY))
            for i,b in enumerate(defb):
                if (i % 8) == 0:
                    #print("\n    DB ", end="")
                    zsmFile.write("\n    DB ")
                #print("0%02XH" % b, end="")
                zsmFile.write("0%02XH" % b)
                if ((i+1) % 8) != 0:
                    #print(",", end="")
                    zsmFile.write(",")
            #print("\n")
            zsmFile.write("\n")
    zsmFile.write("#endasm\n")
    zsmFile.close()
    print("%s created." % zsmName)

