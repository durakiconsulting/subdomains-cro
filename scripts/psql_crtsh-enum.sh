#!/usr/bin/env bash 
set -e 
set -u

# require psql, extracts cert transparency subdomains from dns list
# must be run from repository root
# 
# author: halis duraki (0xduraki) <duraki@linuxmail.org>

### cli-exmpl:
# psql -P pager=off -P footer=off -U guest -d certwatch --host crt.sh
# select distinct(lower(name_value)) from certificate_and_identities cai where plainto_tsquery ('olx.ba') @@ identities (cai.CERTIFICATE) AND lower(cai.NAME_VALUE) LIKE ('%.olx.ba');
#       lower
#-------------------
# -- snip --
#otvorishop.olx.ba
#payment.olx.ba
#pomoc.olx.ba
#promo.olx.ba

# script accepts a dns zonelist (ie. clean_cctld-ba_nett.txt)
if [ "x$1" = "x" ]; then 
  echo "Usage: $0 domain_list.txt" 
  exit 
fi 

# now, paging crtsh for each of the dns in the list is troublesome. there are ~10000 ccTLDs only for .ba
# instead of bashing/ddosing our dear crtsh with db. reconnection, and constant requeryies on the spawn shell;
# we can apply some unix-fu to establish a db. connection once, spawn a pipe, make it world-readable,
# and use the psql -f /the/pipe to stash a session or requery a certlog of our target
rm -rf /tmp/crtpipe # force delete pipe
mkfifo /tmp/crtpipe
chmod a+r /tmp/crtpipe
cat > /tmp/crtpipe & # this will hold session open
bash -c "psql -P pager=off -P footer=off -U guest -d certwatch --host crt.sh -f /tmp/crtpipe"  # | sed -e '$d' -e 's/^ //' -e '1,2d'

LINES=$(cat $1)
for LINE in $LINES
do
  echo "Building DNS Query: $LINE"
  DNS="$LINE"

#QRY_P_I=$(cat <<EOF
#SELECT distinct(lower(name_value)) FROM certificate_and_identities cai WHERE plainto_tsquery('$LINE') @@ identities(cai.CERTIFICATE) AND lower(cai.NAME_VALUE) LIKE ('%.$LINE');
#EOF
#)

  # q equals query on cert db
  Q="select distinct(lower(name_value)) "
  Q+="from certificate_and_identities cai where plainto_tsquery "
  #Q+="('olx.ba') "
  Q+="(:'tsquery') "

  #Q+="'\''$DNS'\''"
  Q+="@@ identities (cai.CERTIFICATE) "
  Q+="AND lower(cai.NAME_VALUE) LIKE "
  Q+="(:'likequery');"
  


  #Q="select distinct(lower(name_value)) FROM certificate_and_identities cai WHERE plainto_tsquery('$LINE') @@ identities(cai.CERTIFICATE) AND lower(cai.NAME_VALUE) LIKE ('%.$LINE');" 

  echo "Built Query:"
  echo \""$Q"\"
  #echo "$QRY_P_I"
  exit

  #echo "$Q" > /tmp/crtpipe
  #echo "\q" > /tmp/crtpipe

  # dbconn
  # psql -P pager=off -P footer=off -U guest -d certwatch --host crt.sh -c "$Q" | sed -e '$d' -e 's/^ //' -e '1,2d'
done

rm -rf /tmp/crtpipe

