#!/usr/bin/env bash

## Mac HFS image RSRC ripper
## by akasaka, 2022
## Requires: resource_dasm, perl-convert-binhex, hfsutils, grep, sed
## Usage: $0 /path/to/disk.hfv /path/to/output/dir 
## (recommend tmpfs for output)

disk="$1"
outDir="$2"

hmount $disk >/dev/null
if [ $? -ne 0 ]; then
	echo "[!] Looks like mount failed: exit code $?"
	exit 1
fi

diskName=$(hvol $disk | grep -oP 'Volume name is "\K(.+)(?=")')
root="$outDir/$diskName"

mkdir -p "$root"
cd "$root"

while read line; do
	if [ "${line:0:1}" == ":" ]; then
		# directory entry
		dirEntry=$(echo "$line" | sed 's~/~_~g' | sed 's~:~/~g')
		cd "$root"
		mkdir -p "$root/$dirEntry"
		cd "$root/$dirEntry"
		hcd "$diskName$line"
	else
		while read fname; do
			if [[ -n "${fname// /}" ]]; then
				uqname=$(echo $fname | tr -d \")
				hqxname="./_$uqname.hqz"
				hcopy -b "$uqname" "$hqxname"
				if [ $? -eq 0 ]; then
					outf=$(debinhex.pl "$hqxname" | grep -oP 'Writing:     \K(.+)')
					outf=$(basename "$outf")
					echo $outf
					mv "$outf.rsrc" "_$outf.rsrc"
					resource_dasm --data-fork --target=actb --target=acur --target=cctb --target=cicn --target=clut --target=crsr --target=CTBL --target=CURS --target=dctb --target=fctb --target=icl4 --target=icl4 --target=icl8 --target=icm# --target=icm4 --target=icm8 --target=ICN# --target=icns --target=ICON --target=ics# --target=ics4 --target=ics8 --target=kcs# --target=kcs4 --target=kcs8 --target=PICT  --target=pltt  --target=SICN  --target=wctb  --target=csnd  --target=esnd  --target=ESnd  --target=snd  --target=SOUN  --target=Ysnd "_$outf.rsrc"
					
					rm "$hqxname" "$outf" "_$outf.rsrc"
					
					if [ "$(ls -A "_$outf.rsrc.out")" ]; then
						mv "_$outf.rsrc.out" "_$outf.rsrc"
					else
						rmdir "_$outf.rsrc.out"
					fi
				fi
			fi
		done <<< $(echo "$line" | tr ',' '\n')
	fi
done <<< $(hls -amRQ)

humount "$disk"
