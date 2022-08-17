#!/usr/bin/env bash

# requires sqlite3, extracts domains from reconned process (nettis)
# must be run from repository root
#
# author: halis duraki (0xduraki) <duraki@linuxmail.org>


# full scripts dir no matter where it is being called from
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

mode="column"
db="szone/storage.sqlite3"
output="szone/cctld-ba_nett.txt"
table="domains"
query="select url from $table"

cli="$(cat <<-EOF
sqlite3 "$SCRIPT_DIR/../$db" ".headers off" ".output $SCRIPT_DIR/../$output" ".mode $mode" "$query" ""
EOF
)"

echo "executed cli:"
echo "$cli"

eval $cli

echo "ba-domains_extract.sh successfully extracted"
echo "output is (bytes+lines): $output"; wc -c "$SCRIPT_DIR/../$output"; wc -l "$SCRIPT_DIR/../$output"

#echo "evaulating toplevel and secondlevel domains only"
#sed  's/.*\.\([^.]\+\.[^.]\+\)$/\1/' "$SCRIPT_DIR/../$output" > "$SCRIPT_DIR/../szone/top_second-cctld-ba_nett.txt"
