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

# No pak0 present
if ! [ -f "$SCRPATH/pak0_cd.pk3" ]; then
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
fi

# Make sure we're back in here
cd "$SCRPATH"

# check if we need an icon.tga
if ! [ -f "$SCRPATH/icon.tga" ]; then
	# imagemagick will help us get our icon
	if [ -x "$(command -v convert)" ]; then
		printf "Detected ImageMagick's convert... giving you a nice icon!\n"
		convert "$DATA_PATH/rewolf.ico" "$SCRPATH/rewolf.tga"
		rm "$SCRPATH/rewolf-0.tga"
		mv "$SCRPATH/rewolf-1.tga" "$SCRPATH/icon.tga"
	else
		printf "No ImageMagick found... can't give you a window icon then.\n"
	fi
fi

# Make sure we're back in here
cd "$SCRPATH"

printf "All done. Would you like to rip the the Compact Disc Digital Audio for music?\ny/n: "
read CHOICE

if [[ "$CHOICE" == [Yy]* ]]; then
	# check if we require rippin tunes
	if ! [ -f "$SCRPATH/music/track02.wav" ] && ! [ -f "$SCRPATH/music/track02.ogg" ]; then
		if [ -x "$(command -v cdparanoia)" ]; then
			mkdir -p "./music"
			cd "./music"
			cdparanoia -B
			rename ".cdda." "." *.wav

			# Maybe the user does not have the physical disc and cdp fails.
			if [ -f "$SCRPATH/music/track02.wav" ]; then
			# I'd offer FLAC, but that also requires the ffmpeg plugin
			if [ -x "$(command -v oggenc)" ]; then
				printf "All done. Would you like to convert them to OGG for playback compatibility\nas well as space preservation (frees up ~150 MB)?\ny/n: "
				read CHOICE
				if [[ "$CHOICE" == [Yy]* ]]; then
					oggenc *.wav
					rm *.wav
				fi
			fi
			fi
		else
			printf "cdparanoia is missing. Cannot rip music.\nPlease run the installer again once you've got it installed.\n"
		fi
	else
		printf "Music was already present.\n"
	fi
fi

cd "$SCRPATH"

# Be real careful here
rm -rfv "./$OUTPK3DIR"
rm -rfv "./prefix"
