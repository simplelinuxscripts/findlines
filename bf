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

export LC_ALL=en_US.UTF-8

RED_COLOR=$'\E[1m\E[4m\E[31m'
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

SCRIPT_DIR=$(dirname "$0")
find_files_command="$SCRIPT_DIR/ff -noformatting $pathstrs_list_for_call"
tabs=$'\x09\x09'
eval "$find_files_command" | sed 's|^\./||' | rsync -auR $dry_run_option--out-format="%n${tabs}%l bytes" --stats --files-from=- . "$target_folder_for_call" | grep -Ev '/\s*[0-9]+ bytes$' | sed "/Number of deleted files:/s/.*/${BOLD}&${NC}/" | sed "/Number of regular files transferred:/s/.*/${BOLD}&${NC}/" | sed "/Total transferred file size:/s/.*/${BOLD}&${NC}/"

echo
echo "Do you want to compare current and backup folders? (Y/N)"
read answer

if [[ "$answer" != "N" && "$answer" != "n" ]]; then
    echo "Comparing..."
    diff -qr "." "$target_folder_for_call" | sed "s/differ/${RED_COLOR}differ$NC/" | sed "s/Only in .:/${RED_COLOR}Only in .:$NC/" | nl -w 1 -s ' '
fi

echo
echo "done"