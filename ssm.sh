#!/bin/bash

usage() {
    echo "  -f|--filename <input filename>"
    echo "  -o|--output-path [output path]"
	echo "  -c|--chromosome [chromosome,eg chrX] default (all)"
    echo "  -n|--number [default=10]"
    echo "  -a|--ascending default(descending)"
    echo "  -h|--help"
}
function analyzer {
local chromosome="$1"
/hgsc_software/bcftools/bcftools-1.15.1/bin/bcftools view --no-header --regions "$chromosome" $filename | grep -i ps  | cut -f 1,2,10 | tr ':' '\t' | cut -f 1,8 | uniq -c | sort -k 1 -n ${sort} | head -n "$number">"$output_path/$chromosome.txt"
tmp_chr=$(mktemp)
echo -e "No.haplotypes    chromosome    position    length">"$tmp_chr"
while read -r line
do 
hp=$(awk '{print $1}'<<<"$line")
chr=$(awk '{print $2}'<<<"$line")
position=$(awk '{print $3}'<<<"$line")
result=($(/hgsc_software/bcftools/bcftools-1.15.1/bin/bcftools view --no-header --regions $chromosome $filename --regions $chromosome --include " PS = $position" | awk 'NR==1 {print $2}; END{print $2}' | xargs))
length=$((result[1]-result[0]))
printf '%-17s%-14s%-12s%s\n' $hp $chr $position $length >>"$tmp_chr"
done<"$output_path/$chromosome.txt"
mv $tmp_chr "$output_path/$chromosome.txt"
}

sort="-r"
number=10
output_path="summary_statistic_VCF"


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
        -[cC]|--chromosome)
            chromosome="$2"
            shift
          ;; 
		-[hH]|--[hH]elp)
			usage
			exit
			;;
        -[nN]|--number)
            number=$2
            shift
        ;;
        -[aA]|--ascending)
            sort=""
        ;;	esac
	shift
done
if ! [ -d "$output_path" ]; then
    mkdir -p "$output_path"  
fi
if [ -v chromosome ]
then
   analyzer "$chromosome"
else 
    for index in $(seq 1 22) X Y
    do
        analyzer "chr$index"
    done
fi
















