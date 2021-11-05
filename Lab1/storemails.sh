#!/bin/bash

function show_help {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h|--help] [-d|--directory root_dir] [Maildateien]

Store mails in archive.

Available options:
-h, --help         Print this help and exit
-d, --directory    Root directory for mail archive
EOF
  exit 0
}

if [[ $# -eq 0 ]] ; then
  show_help
fi

ROOT="${PWD}"
FILES=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      show_help
      ;;
    -d|--directory)
      ROOT="$2"
      shift
      shift
      ;;
    *)
      FILES+=("$1")
      shift
      ;;
  esac
done

function extract_date {
  local file=$1
  cat "$file" | grep -Po '^Date: .*?, \K[+ :A-Za-z0-9]*'
}

function get_day {
  local date=$1
  date -d "$date" "+%d"
}

function get_month {
  local date=$1
  date -d "$date" "+%m"
}

function get_year {
  local date=$1
  date -d "$date" "+%Y"
}

function setup_target_dir {
  local day=$1
  local month=$2
  local year=$3

  local dir="${ROOT}/$year/$month/$day"
  mkdir -p "${dir}"
  echo "${dir}"
}

function archive_mail {
  local file=$1
  
  local raw_date="$(extract_date "${file}")"
  
  local day="$(get_day "${raw_date}")"
  local month="$(get_month "${raw_date}")"
  local year="$(get_year "${raw_date}")"

  local targetDir="$(setup_target_dir $day $month $year)"
  
  cp "${file}" "${targetDir}"
  local fileName="$(basename "${file}")"
  local targetFile="${targetDir}/${fileName}"
  local m_date="$(date -d "${raw_date}" +%Y%m%d%H%M.%S)"
  touch -m -t $m_date "${targetFile}"
}

echo "Found ${#FILES[@]} Files"


for ((i = 0; i < ${#FILES[@]}; i++))
do
  file="${FILES[$i]}"
  archive_mail "${file}"
done