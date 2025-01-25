#!/bin/bash

###################################################################################################
#
# Back up filtered files of current folder and its subfolders into a target folder
#
# USAGE:
#  bf [-dry-run] [pathstr|/pathstr]* target_folder
# with [pathstr|/pathstr]* defined in ff script.
# Option -dry-run simulates the backup without doing anything.
#
###################################################################################################

RED_COLOR=$'\E[1m\E[4m\E[31m'
YELLOW_COLOR=$'\E[1m\E[4m\E[33m'
BOLD=$'\E[1m'
NC=$'\E[0m'

# print error message
printError() {
    error_str=$1

    echo -e -n "$RED_COLOR" >&2
    echo -n "$error_str" >&2
    echo -e "$NC" >&2
}

if [[ $# -eq 0 ]]; then
    printError "error: missing parameter(s): no target folder"
    exit 1
fi

dry_run=0
dry_run_str=""
dry_run_option=""
pathstrs_list=""
pathstrs_list_for_call=""
target_folder=""
target_folder_for_call=""
parameter_nb=0
for arg in "$@"; do
    ((parameter_nb++))
    if [[ "$arg" == "-dry-run" && $dry_run -eq 0 ]]; then
        dry_run=1
        dry_run_str=" [DRY RUN]"
        dry_run_option="--dry-run "
    elif [[ $parameter_nb -lt $# ]]; then
        if echo "$arg" | grep -q " "; then
            pathstrs_list="$pathstrs_list\"$arg\" "
        else
            pathstrs_list="$pathstrs_list$arg "
        fi
        pathstrs_list_for_call="$pathstrs_list_for_call\"$arg\" "
    else
        if echo "$arg" | grep -q " "; then
            target_folder="\"$arg\""
        else
            target_folder="$arg"
        fi
        target_folder_for_call="$arg"
    fi
done

if [[ "$target_folder_for_call" == "" ]]; then
    printError "error: missing parameter(s): no target folder"
    exit 1
fi

echo "**********************************************************************"
echo -n "back up "
if [[ "$pathstrs_list" != "" ]]; then
    echo -n "${pathstrs_list}files "
else
    echo -n "all files "
fi
echo "to $target_folder$dry_run_str"

if ! [[ -d "$target_folder_for_call" ]]; then
    printError "error: target folder $target_folder_for_call does not exist"
    exit 1
fi

if [[ $dry_run -eq 0 ]]; then
    backup_str="backed up"
    echo "Press Enter to start the backup..."
    read
else
    backup_str="to back up"
fi

display_size() {
    size=$1

    color_beg=""
    color_end=""
    if [[ $size -ge 25000000 ]]; then
        color_beg="$RED_COLOR"
        color_end="$NC"
    elif [[ $size -ge 8000000 ]]; then
        color_beg="$YELLOW_COLOR"
        color_end="$NC"
    fi

    if [[ $size -lt 1000 ]]; then
        echo "$color_beg${size} B$color_end"
    elif [[ $size -lt 1000000 ]]; then
        echo "$color_beg$((size/1000)) KB$color_end"
    else
        echo "$color_beg$((size/1000000)) MB$color_end"
    fi

}

format_output() {
    nb_files=0
    total_size=0

    # in this loop, "IFS=" avoids input lines being trimmed
    while IFS= read -r input_str; do
        if [ -f "$input_str" ]; then
            file_size=$(ls -l "$input_str" | awk '{print $5}')
            total_size=$((total_size + file_size))
            echo -n "$input_str"
            echo -e "\t$(display_size $file_size) / $(display_size $total_size)"
            nb_files=$((nb_files + 1))
        fi
    done
    if [[ $nb_files -eq 0 ]]; then
        echo -e "${BOLD}no file $backup_str$NC"
    elif [[ $nb_files -eq 1 ]]; then
        echo "${BOLD}1 file $backup_str, $(display_size $total_size)$NC"
    else
        echo "${BOLD}$nb_files files $backup_str, $(display_size $total_size)$NC"
    fi
}

SCRIPT_DIR=$(dirname "$0")
search_command="$SCRIPT_DIR/ff -print0 $pathstrs_list_for_call| xargs -0 -I {} sh -c 'rsync -auR $dry_run_option--out-format="%n" \"{}\" \"$target_folder_for_call\"' | format_output"
echo "search_command=$search_command"
eval "$search_command"

echo
echo "Do you want to compare current and backup folders? (Y/N)"
read answer

if [[ "$answer" != "N" && "$answer" != "n" ]]; then
    echo "Comparing..."
    diff -qr "." "$target_folder_for_call" | sed "s/differ/${RED_COLOR}differ$NC/" | sed "s/Only in .:/${RED_COLOR}Only in .:$NC/" | nl -w 1 -s ' '
fi

echo
echo "done"