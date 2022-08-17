# Contributing

### Folder Structure

* `./szone/` - (undisclosed) A cctld domain zone lists (`.ba/.rs/.hr`)
* `./collection/en/` - Directory containing all possible English subdomains
* `./docs/` - Documentation and API datasets
* `./scripts` - Scripts used while building this list

### Notes

During the creation of this repository and dataset, a special ccTLD zone has been used, provided by the tool [nettis](https://github.com/duraki/nettis) which contained all registered ccTLDs and domains registered at the respective country register (such is *nic.ba*).

We are unable to provide this list to non-contributors as it may disclose potential security issues in the domains presented throughout the dataset. Therefore, we didn't include `./szone/` directory in the public-viewable repository.

### Using `./szone/storage.sqlite3`

This sqlite3 database contains both enumerated and reconned domains, grabbed via tool described above. The following represents a table schema of interest:

```
$ sqlite szone/storage.sqlite3

# => ...
sqlite> .schema domains
CREATE TABLE domains (
  id INTEGER PRIMARY KEY,
  url TEXT,
  ip TEXT,
  whois_text TEXT,
  whois_image TEXT,
  domains_on_host TEXT,
  subdomains TEXT,
  forensic TEXT,
  network TEXT,
  shodan_data TEXT,
  created_at DATE,
  updated_at DATE
);
```

The extraction is executed via:

```
$ ./scripts/ba-domains_extract.sh
# => ...
```
