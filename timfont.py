#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    TimFont (c) 2021  Žarko Živanov

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
about = """TimFont %s (c) 2021  Zarko Zivanov

This program is used for manipulating font data from
TIM-011 font COM files. It can convert font data into
a PNG file that can be edited in any PNG capable editor,
and can also insert data from PNG file into COM font
file.""" % (VERSION)

epilog="""You need to provide two arguments, one of
them must be PNG file, while the other must be COM
file. Conversion goes from first to second.

Each TIM-011 character is defined with 10 bytes. Two
lowest bits of each definition byte aren't used, so
effective size is 6x10 pixels. When generating PNG,
those 2 lower bits are colored differently and should
not be used for defining the characters.

Be sure that program you use for editing PNG won't
change its format: 1 byte per pixel, greyscale, no
alpha channel, no layers or anything else. Photoshop
users should use the "Flatten Layers" option before
saving their PNG file."""

parser = argparse.ArgumentParser(description=about, formatter_class=argparse.RawDescriptionHelpFormatter,epilog=epilog)
parser.add_argument('file', metavar='file', nargs=2, default="", help='(path to) COM/PNG file')

# parse command line
args = parser.parse_args()

###############################################
#         Input files basic checking
###############################################

inputFile = args.file[0]
outputFile = args.file[1]

if not os.path.exists(inputFile):
    error("File '%s' not found!" % inputFile)
if os.path.exists(outputFile):
    prompt = "File '%s' already exist. Overwrite Y/N? " % outputFile
    if sys.version_info[0] == 2:
        answer = str(raw_input(prompt))
    else:
        answer = str(input(prompt))
    if not answer in ['y','Y','yes','YES']:
        exit(0)

conversion = ""
if inputFile[-4:] in [".com", ".COM"]:
    if not outputFile[-4:] in [".png", ".PNG"]:
        error("Output file '%s' must have a 'png' extension!" % outputFile)
    conversion = "com2png"
elif inputFile[-4:] in [".png", ".PNG"]:
    if not outputFile[-4:] in [".com", ".COM"]:
        error("Output file '%s' must have a 'com' extension!" % outputFile)
    conversion = "png2com"
else:
    error("Input file '%s' must be a 'png' or 'com'!" % inputFile)

###############################################
#         Constants used for conversion
###############################################

#                0        1         2         3         4         5         6         7         8         9         0
#                1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
TIMFONT_ENG = """ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"""
TIMFONT_CYR = """ !"#$%&'()*+,-./0123456789:;<=>?ЖАБЦДЕФГХИЈКЛМНОПЉРСТУВЊXЏЗШЂЋЧ_жабцдефгхијклмнопљрстувњxџзшђћч■█▓▒░"""

TIM_CHARS = 100             # number of font chars in TIM COM file
FONT_OFFSET = 0x114         # ofset for font data inside COM file
DEFAULT_COM = "default.com" # COM file used for exporting
timCharW = 8                # TIM character width in pixels
timCharH = 10               # TIM character height in pixels
pngCharsX = 10              # PNG char matrix width in chars
pngCharsY = 10              # PNG char matrix height in chars
charColGrid = 0x00          # color used for char matrix grid
charColBack = 0x80          # color used for char matrix background
charColUnus = 0x40          # color used for char matrix unused bits
charColPixl = 0xFF          # color used for char matrix pixels

print("Converting '%s' to '%s' ..." % (inputFile, outputFile))

# convert PNG to TIM COM file
if conversion == "png2com":
    if not os.path.exists(DEFAULT_COM):
        error("File '%s' not found!\nCopy any TIM-011 font file as %s. and try again" % (DEFAULT_COM, DEFAULT_COM))

    # read PNG file
    pngObject = png.Reader(inputFile)
    pngDirect = pngObject.asDirect()
    fontMatrix = list(pngDirect[2])

    # load default TIM font from COM file
    timFile = open(DEFAULT_COM, "rb")
    timFont = array.array('B')
    timFont.fromfile(timFile, flen(timFile))
    timFile.close()

    # copy font data
    for x in range(pngCharsX*timCharW):
        for y in range(pngCharsY*timCharH):
            row = y//timCharH
            col = x//timCharW
            line = y % timCharH
            bit = 7 - (x%timCharW)
            mask = 1 << bit
            offset = row*(pngCharsX*timCharH) + col*timCharH + line + FONT_OFFSET

            pngX = x + x//timCharW
            pngY = y + y//timCharH
            if fontMatrix[pngY][pngX] == charColPixl:
                timFont[offset] |= mask
            else:
                timFont[offset] &= ~mask

    # save TIM font as COM file
    timFile = open(outputFile, "wb")
    timFile.write(timFont)
    timFile.close()

# convert TIM COM file to PNG
elif conversion == "com2png":
    # load TIM font from COM file
    timFile = open(inputFile, "rb")
    timFile.seek(FONT_OFFSET)
    timFont = array.array('B')
    timFont.fromfile(timFile, TIM_CHARS*10)
    timFile.close()

    # convert font to array for PNG
    timCharW = 8
    timCharH = 10
    pngCharsX = 10
    pngCharsY = 10
    charColGrid = 0x00
    charColBack = 0x80
    charColUnus = 0x40
    charColPixl = 0xFF
    pngSizeW = pngCharsX * timCharW + pngCharsX - 1
    pngSizeH = pngCharsY * timCharH + pngCharsY - 1
    fontMatrix = [[charColBack for x in range(pngSizeW)] for y in range(pngSizeH)]

    # generate unused bits
    for x in range(pngCharsX):
        lineX = x*(timCharW+1)+timCharW-2
        for y in range(pngCharsY * timCharH + pngCharsY - 1):
            fontMatrix[y][lineX] = charColUnus
            fontMatrix[y][lineX+1] = charColUnus

    # generate grid
    for x in range(pngCharsX-1):
        lineX = x*(timCharW+1)+timCharW
        for y in range(pngCharsY * timCharH + pngCharsY - 1):
            fontMatrix[y][lineX] = charColGrid
    for y in range(pngCharsY-1):
        lineY = y*(timCharH+1)+timCharH
        for x in range(pngCharsX * timCharW + pngCharsX - 1):
            fontMatrix[lineY][x] = charColGrid

    # copy font data
    for x in range(pngCharsX*timCharW):
        for y in range(pngCharsY*timCharH):
            row = y//timCharH
            col = x//timCharW
            line = y % timCharH
            bit = 7 - (x%timCharW)
            mask = 1 << bit
            offset = row*(pngCharsX*timCharH) + col*timCharH + line

            pngX = x + x//timCharW
            pngY = y + y//timCharH
            if (timFont[offset] & mask) != 0:
                fontMatrix[pngY][pngX] = charColPixl

    # save PNG
    pngWriter = png.Writer(pngSizeW, pngSizeH, greyscale=True, bitdepth=8)
    png = open(outputFile,"wb")
    pngWriter.write(png, fontMatrix)
    png.close()

print("Done!")

