#!/bin/sh

# I mean... this sucks, I get it - but sadly we have to use Wine for this
# because no one has made an installer extractor for Wine that works on
# Linux. Sorry.

# builds a pk3 file that's alphabetically sorted
mk_pk3()
{
	tree -fi > ./build_contents.txt
	sed -i '/build_contents/d' ./build_contents.txt
	sed -i '/directories,/d' ./build_contents.txt
	zip -0 "$1".pk3 -@ < ./build_contents.txt
	rm ./build_contents.txt
	mv "$1".pk3 ../"$1".pk3
}

SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
OUTPK3DIR="pak0_retail.pk3dir"

if ! [ -x "$(command -v wine)" ]; then
	printf "Error: wine is not installed.\n" >&2
	exit 1
fi

if ! [ $# -gt 0 ]; then
	printf "Path to MOUNTED CD-ROM folder, e.g. /mnt/cdrom:\n"
	read CDROM_PATH
else
	CDROM_PATH="$1"
fi

if ! [ -f "$CDROM_PATH"/rewolf/install.EXE ]; then
	printf "Error: install.EXE not found in $CDROM_PATH.\n" >&2
	exit 1
fi

# Set up a prefix that's 32-bit inside
export WINEPREFIX="${SCRPATH}/prefix"
export WINEARCH=win32
DATA_PATH="${WINEPREFIX}/drive_c/Sierra/Gunman/"

# Check if we need to install the content, or throw a warning.
if ! [ -f "$SCRPATH/$OUTPK3DIR/liblist.gam" ]; then
	# May already have been extracted here (debug)
	if ! [ -f "$DATA_PATH"/gunman.exe ]; then
		# Because /x does NOT preserve directories.
		wine "$CDROM_PATH"/rewolf/install.EXE /s
	fi

	# Move rewolf to become OUTPK3DIR
	mv "$DATA_PATH/rewolf" "$SCRPATH/$OUTPK3DIR"
	# Logos need to be in the game-dir
	mv "$DATA_PATH/logos" "$SCRPATH/$OUTPK3DIR/logos"
else
	printf "$OUTPK3DIR already exists... everything okay?\n"
fi

# Make the pk3 archive
cd "$SCRPATH/$OUTPK3DIR"
mk_pk3 pak0_cd

# Make sure we're back in here
cd "$SCRPATH"

# imagemagick will help us get our icon
if [ -x "$(command -v convert)" ]; then
	printf "Detected ImageMagick's convert... giving you a nice icon!\n"
	# check if we need an icon.tga
	if ! [ -f "$SCRPATH/icon.tga" ]; then
		convert "$DATA_PATH/rewolf.ico" "$SCRPATH/rewolf.tga"
		rm "$SCRPATH/rewolf-0.tga"
		mv "$SCRPATH/rewolf-1.tga" "$SCRPATH/icon.tga"
	fi
fi

# Redundant - but you NEVER know where we'll execute the next two commands
cd "$SCRPATH"

# Be real careful here
rm -rfv "./$OUTPK3DIR"
rm -rfv "./prefix"
