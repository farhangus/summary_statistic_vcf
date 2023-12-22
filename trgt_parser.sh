#!/bin/bash

usage() {
    echo "  -f|--filename <input filename>"
    echo "  -o|--output-path [output path]"
	echo "  -p|--position <region>"
    echo "  -h|--help"
}
output_path="trgt_results"


if [ $# -eq 0 ]; then
	usage
	exit
fi

while [ $# -gt 0 ]; do
	case $1 in
		-[fF]|--filename)
			filename="$2"
		    if ! [ -f "$filename" ]; then
				echo "file not found!"
				exit
			fi
            shift
            ;;
        -[oO]|--output-path)
            output_path="$2"
            shift
            ;; 
        -[pP]|--position)
            position="$2"
            shift
          ;; 
		-[hH]|--[hH]elp)
			usage
			exit
			;;
   esac
	shift
done
if ! [ -d "$output_path" ]; then
    mkdir -p "$output_path"  
fi
text="$(zgrep -P "\t$position\t" trgt_output.vcf.gz)"
motif_value=$(echo "$text" | grep -oP 'MOTIFS=\K[^;]+')
ref=$(echo "$text" | awk 'NR==1 {print $4}')
motif_ref=$(bc <<<"scale=1;${#ref} / ${#motif_value}")
alt=$(echo "$text" | awk 'NR==1 {print $5}')
IFS=',' read -ra parts <<< "$alt"
alt1="${parts[0]}"
alt2="${parts[1]}"
match_alt1=$(grep -o "$motif_value" <<< "$alt1" | wc -l)
match_alt2=$(grep -o "$motif_value" <<< "$alt2" | wc -l)

echo "position=${position}"
echo "motif=${motif_value}"
echo "ref=${ref}"
echo "No of motifs n reference=${motif_ref}"
echo "alt1=${alt1}, alt2=${alt2}"
echo "motifs_alt1=${match_alt1},motifs_alt2=${match_alt2} "
