if [ "x$1" = "x" ]; then 
  echo "Usage: $0 domain-name" 
  exit 
fi 

Q="select distinct(lower(name_value)) FROM certificate_and_identities cai WHERE plainto_tsquery('$1') @@ identities(cai.CERTIFICATE) AND lower(cai.NAME_VALUE) LIKE ('%.$1')" 

psql -P pager=off -P footer=off -U guest -d certwatch --host crt.sh -c "$Q" | sed -e '$d' -e 's/^ //' -e '1,2d'
