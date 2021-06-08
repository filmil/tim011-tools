#!/bin/bash

#    Script for copying files from/to TIM-011 images
#    Copyright (C) 2019  Zarko Zivanov

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# constants
CPMTYPE="tim011"
DISKDEFS="diskdefs"
INPIMG=1
INPDIR=2
INPLST=3
# empty image name
EMPTY="empty.img"

#save keyboard stdin in descriptor 10
exec 10<&0

# script help
function usage {
    colecho "[g]Script for copying files from/to TIM-011 images"
    colecho "[b](C) 2019 Zarko Zivanov, www.onceuponabyte.org"
    colecho "For licnece, see [m]https://www.gnu.org/licenses/"
    colecho "\nUsage:"
    colecho "[g]$0[n] [c]-e <image>[n] [m][directory]"
    colecho "   Extracts files from TIM-011 image into directory."
    colecho "   If directory isn't specified, image name will be used."
    colecho "   User area [c]0[n] is extracted directly into directory, while"
    colecho "   other user areas are extracted into their subdirectories."
    colecho "[g]$0[n] [c]-c <directory>[n] [m][image]"
    colecho "   Creates new TIM-011 image from files in directory."
    colecho "   If image isn't specified, directory name with [m].img"
    colecho "   extension will be used."
    colecho "   User area [c]0[n] is copied directly from directory, while"
    colecho "   other user areas are copied from their subdirectories."
    colecho "[g]$0[n] [c]-l <image> [m][pattern]"
    colecho "   Displays contents of the image. Pattern can be"
    colecho "       [m][user:][name][.ext]"
    colecho "   where [m]user[n] is [c]0-15[n], and [m]name[n] and [m]ext[n] can use wildcards"
    colecho "   [c]*[n] and [c]?[n], with usual meaning"
    colecho "   [r]Warning[n]: [g]cpmls[n] doesn't always display user information"
    colecho "            for first listed group, script assumes that it"
    colecho "            is [c]0[n], but that can be wrong"
    colecho "   For more detailed listing, use [g]cpmls[n] directly:"
    colecho "       [g]cpmls -f tim011 [m][opt] [c]<image> [m][pattern]"
    colecho "   See [g]man cpmls[n] for details (recommended opt: [m]-D[n] or [m]-l[n])."
    colecho "[g]$0[n] [c]-t <img type> <command>"
    colecho "   Change IMG type (default is tim011, others are in diskdefs file)."
    colecho "[g]$0[n] [c]-h"
    colecho "   This help."
    colecho "\n[r]Requirements[n]: [g]cpmtools[n], [g]bash[n]\n"
    exit 0
}

# display error and exit script
function error {
    colecho "[r]Error: $1" >&2
    exit 1
}

# color echo
# $1    - string with color codes [r],[g],[b],[m],[c],[n]
# -c NN - center the text on NN characters
# -n    - no nweline after text
function colecho {
    nonewl=0
    width=0
    if [ "$1" == "-c" ]; then
        width=$2
        shift 2
    fi
    if [ "$1" == "-n" ]; then
        nonewl=1
        shift
    fi
    output="$1"
    chars=${output//\[[a-z]\]/}
    if [ "$2" == "" ]; then output="${output}\e[00m"; fi
    output=${output//\[r\]/\\e\[01;31m}
    output=${output//\[g\]/\\e\[01;32m}
    output=${output//\[b\]/\\e\[01;34m}
    output=${output//\[m\]/\\e\[01;35m}
    output=${output//\[c\]/\\e\[01;36m}
    output=${output//\[n\]/\\e\[00m}
    if [ "$width" != "0" ]; then
        textsize=${#chars}
        if [ $width -gt $textsize ]; then
            span=$((($width - $textsize) / 2))
            printf "%${span}s" ""
        fi
    fi
    if [ $nonewl -eq 0 ]; then
        echo -e "$output"
    else
        echo -n -e "$output"
    fi
}

# show help if no parameters
if [ "$1" == "" ]; then
    usage
fi

## check if "diskdefs" file is present, and create one if it isn't
#if ! [ -f "$DISKDEFS" ]; then
#    echo -e "# TIM011/Micromint SB180 - DSDD 3.5\" - 1024 x 5
#diskdef tim011
#  seclen 1024
#  tracks 160
#  sectrk 5
#  secbase 17
#  blocksize 2048
#  maxdir 256
#  skew 1
#  boottrk 2
#  os 2.2
#end
#" > "$DISKDEFS"
#fi

# check command line options
while getopts ":he:c:l:t:" opt; do
  case $opt in
    h)
        # show help
        usage
        ;;
    t)
        # set another CP/M image type
        CPMTYPE=$OPTARG
        ;;
    e)
        # find user areas in image
        IMG=$OPTARG
        if [ -f "$IMG" ]; then
            USERS=$(cpmls -f $CPMTYPE "$IMG" | grep -E "^[0-9]{1,2}:$" | grep -oE "[0-9]{1,2}")
            colecho "[c]Found user areas: [g]$(echo $USERS)"
        else
            error "Image [g]$IMG[r] not found!"
        fi
        INPUT=$INPIMG
        # determine image name
        filename=$(basename -- "$IMG")
        extension="${filename##*.}"
        filename="${filename%.*}"
        if [ "$extension" != "img" ]; then
            colecho "[m]Warning: Image extension should be [g].img[m]!"
        fi
        # output directory name
        DIR="$filename"
        ;;
    c)
        # find user areas in directory
        DIR=$OPTARG
        if [ -d "$DIR" ]; then
            USERS=$(find "$DIR" ! -path "$DIR" -type d -printf "%f\n" | sort)
            USERS="0 $USERS"
            colecho "[c]Found user areas: [g]$(echo $USERS)"
            for user in $USERS; do
                if ! [[ "$user" =~ ^[0-9]{1,2}$ ]]; then
                    error "Bad user area [g]$user"
                else
                    if [ $user -lt 0 ] || [ $user -gt 15 ]; then
                        error "Bad user area [g]$user"
                    fi
                fi
            done
        else
            error "Directory [g]$DIR[r] not found!"
        fi
        INPUT=$INPDIR
        # new image name
        IMG="$(basename $DIR).img"
        ;;
    l)
        IMG=$OPTARG
        if ! [ -f "$IMG" ]; then
            error "Image [g]$IMG[r] not found!"
        fi
        INPUT=$INPLST
        ;;
    \?)
        error "Invalid option: -$OPTARG"
        ;;
    :)
        error "Option -$OPTARG requires an argument."
        ;;
  esac
done
shift $((OPTIND-1))

if [ $OPTIND -le 2 ]; then
    error "No command was given"
fi

# do commands
case $INPUT in
    $INPIMG)
        # get directory name if it exists
        if [ "$1" != "" ]; then
            DIR="$1"
        fi
        # check if output directory exists
        if [ -e "$DIR" ]; then
            if [ -d "$DIR" ]; then
                colecho "Directory [g]$DIR[n] alredy exists. Delete its files [[c]y/n[n]]?"
                read -u 10 -n 1 ans
                echo -e -n "\r"
                if [ "$ans" != "y" ]; then
                    exit 1
                fi
                rm -rf "$DIR/*"
            else
                error "[g]$DIR[r] is a file, it must be a directory!"
            fi
        fi
        # copy files from all user areas
        for user in $USERS; do
            colecho "Extracting files for user area [g]$user"
            if [ $user != 0 ]; then
                mkdir -p "$DIR/$user"
                cpmcp -f $CPMTYPE "$IMG" $user:* "$DIR/$user/"
            else
                mkdir -p "$DIR"
                cpmcp -f $CPMTYPE "$IMG" $user:* "$DIR/"
            fi
        done
        ;;
    $INPDIR)
        # get image name if it exists
        if [ "$1" != "" ]; then
            IMG="$1"
        fi
        # check if output image exists
        if [ -e "$IMG" ]; then
            if [ -f "$IMG" ]; then
                colecho "File [g]$IMG[n] alredy exists. Delete it [[c]y/n[n]]?"
                read -u 10 -n 1 ans
                echo -e -n "\r"
                if [ "$ans" != "y" ]; then
                    exit 1
                fi
                rm -f "$IMG"
            else
                error "[g]$IMG[r] is a directory, it must be a file!"
            fi
        fi
        # copy files from all user areas
        cp "$EMPTY" "$IMG"
        for user in $USERS; do
            colecho "Copying files for user area [g]$user"
            if [ $user != 0 ]; then
                cpmcp -f $CPMTYPE "$IMG" "$DIR/$user/"* $user:
            else
                 find "$DIR" -maxdepth 1 -type f -exec cpmcp -f $CPMTYPE "$IMG" '{}' $user: \;
            fi
        done
        ;;
    $INPLST)
        # get pattern if it rxists
        if [ "$1" != "" ]; then
            OUT=$(cpmls -f $CPMTYPE -d "$IMG" "$1")
        else
            OUT=$(cpmls -f $CPMTYPE -d "$IMG")
        fi
        USER0=""
        # check if "User 0" should be added
        # TODO: base file listing on -l option, it always displays user area
        if [[ "$OUT" =~ .*User\ [0-9].* ]]; then
            if ! [[ "$OUT" =~ ^User\ [0-9].* ]]; then
                USER0="User 0\n"
            fi
        fi
        # color User area information
        OUT=$(sed -E "s/(User [0-9]{1,2})/\n[g]\1[n]/g" <<< "$USER0$OUT")
        # color executable files
        OUT=$(sed -E "s/([A-Z0-9][A-Z0-9 ]{8}(COM|CMD))/[b]\1[n]/g" <<< "$OUT")
        # color system files
        OUT=$(sed -E "s/([A-Z0-9][A-Z0-9 ]{8}(SYS|MDL|RCP|Z3T|FCP|IOP))/[m]\1[n]/g" <<< "$OUT")
        colecho "$OUT"
        # display occupied and free space
        cpmls -f $CPMTYPE -D "$IMG" | tail -n 1
        ;;
esac

