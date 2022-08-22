<div align="center">
  <kbd>
    <img src="./docs/banner.png" />
  </kbd>
</div>

## subdomains-cro

This is a repostiory containing subdomain enumeration wordlists used in Penetration Testing engagements, that is compiled for Bosnian/Croatian/Serbian language.

Authors:
* [0xduraki](https://github.com/duraki/) (Halis D.)  
* [captcha-n00b](https://github.com/captcha-n00b/) (Danijel V.)  
* [DarkoMilanov](https://github.com/DarkoMilanov/) (Darko M.)  

## Description

`subdomains-cro` is the security tester's companion. It's a collection of a subdomain lists used during security assessments, collected in one place, prototyped and translted to Yugoslavian langauges. List type incluides typical network, username, sensitive design patterns, fuzzing payloads and many more to easily enumerate and recon potential Yugoslavian subdomains. Can be used with: [gobuster](https://github.com/OJ/gobuster), [amass](https://github.com/OWASP/Amass), [sublist3r](https://github.com/aboul3la/Sublist3r) and many others.

This project is mainained by [durakiconsulting](https://github.com/durakiconsulting/) and friendship haxors.

### Getting started

- [ ] Gather all interesting subdomain and DNS wordlists in one place (SecList, Jihadx, etc.)
- [ ] Use Translating Engine (ie. Google Translate) to Translate words from `EN` -> `CRO` from default wordlists
- [ ] Use [crt.sh](https://crt.sh) in combination with .BA/.HR/.RS DNS Zone List (from [nettis](https://github.com/durakiconsulting/nettis))
- [ ] Store all cert/transparency discovered subdomains to a new list
- [ ] Use [gorilla](https://github.com/d4rckh/gorilla) & [cook](https://github.com/giteshnxtlvl/cook) to permutate subdomain words
- [ ] Final compilation of all unique/translated/fabricated subdomain words

### Features

- Subdomain words in Croatian/Serbian/Bosnian
- Brainstorming new potential ideas
- Technical Details on Pre-Enumeration, Generation and Compilation
- Additional Mutation Techniques
- Never-seen 🇧🇦🇷🇸🇭🇷 subdomain wordlist (who would say ExYu is coming back? :)

## Prerequisits

```
$ gem install --user-install pg  # => required for crt transparency extraction script
```

## Install

**Zip**

```
get -c https://github.com/durakiconsulting/subdomains-cro/archive/master.zip -O subdomains-cro.zip \
  && unzip subdomains-cro.zip \
  && rm -f subdomains-cro.zip
```

**Git (Small)**

```
git clone --depth 1 \
  https://github.com/durakiconsulting/subdomains-cro.git
```

### Building

You will need a zonelist of prefered choice for specific ccTLD. This is not provided in the repository. Upon gathering an sqlite3 database of zonelist, you need to execute the following commands:

```
$ ./scripts/ba-domains_extract.sh     # => this will extract `url` column from `domains` table of the sqlite database
ba-domains_extract.sh successfully extracted
output is (bytes+lines): szone/cctld-ba_nett.txt
  657060 subdomains-cro/scripts/../szone/cctld-ba_nett.txt
   10951 subdomains-cro/scripts/../szone/cctld-ba_nett.txt

$ ruby scripts/ba-domains_clean.rb    # => this uses previously extracted `url`-set to compile a newly clean cctld list
...
input is (szone/cctld-ba_nett.txt) => output is (szone/clean_cctld-ba_nett.txt)
total lines to process ... ~(10951)
domain (058.ba) in progress ... no_unknw
```

### Extracting

The extraction is combined of several factors.

**Using Google Translate**, we will provide translated default wordlists, as seen on other repositories.
**Using PostgreSQL Database session-based** connection to `crt(dot)sh` transparency logs and querying the data.

#### Translations

**Google Translate**

**todo:** ... what else?

#### Certificate Transparency

**Certificate Transparency Logs**

This repository includes a [script](/scripts/psql_crtsh.rb) called `psql_crtsh`, written in Ruby, used to somehow make sense of collected "clean" szone ccTLD list (*see above*). This list contains ~20k (yes, a thousands) `*.ba` (hostnames). The idea was to do both a quick scan and deep-scan, that stores hostname for another recon process. 

Setup a logging interface first, for an ease in greping and pattern matching. Here is the author's preference:

```
$ cd $HOME/subdomains-cro/
$ touch $HOME/subdomains-cro/docs/debug.log

# => term#1 all results
$ tail -F docs/debug.log

# => term#2 error based results
$ tail -n0 -f docs/debug.log | sed -n '/fail/p'
$ echo "[fail]" >> docs/debug.log # => smoke-test, should result in logged error

# => term#3 finally, execute the script
$ ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt --debug --print-active --show > ./docs/debug.log

# => additionally, term#4 can be used for [dbg] logs
$ tail -n0 -f docs/debug.log | sed -n '/dbg/p'
```

**todo:** explanation of the script
* Built using `ruby` with `pg` external library
* Many edge-cases are implemented to avoid resplash and rewrite
* The script contains `String`, `PG` overrides, and custom `CertGrabber` class
* The `CertGrabber` class is an instance of a worker, evaled via CLI args
* The `main()` of the script is near the bottom, it initializes worker, and jobs
* If worker instance is running, a PostgreSQL session is alive
* Same `PG::Session` is used when executing queries

Even tho the script covers most edge-cases, it's not bulletproof. Most of the script logic is executing in the `try:catch` block, and the script tries to handle all exceptions gracefully. Script is super-fast on high-end Mac machine, and if you are not impressed, just use `supervisor` or similar worker deamon.

*Common Exception Throws*

```
# => canceling statement due to conflict with recovery
[fail] ERROR:  canceling statement due to conflict with recovery
[fail]do_work failed at line acquattro.ba index 104

# => could nto split from uri
[fail]do_work failed at line advokat-sahinpasic.ba index 153
[fail]could nto split from uri()

# => PQconsumeInput
[fail] PQconsumeInput() ERROR:  client_idle_timeout
[fail]do_work failed at line coach.ba index 1737

# => PQsocket
[fail]do_work failed at line cobear.ba index 1738
[fail] PQsocket() can't get socket descriptor
```

**Command-Line Interface**

```
       psql_crtsh - Ruby Extraction Script
       durakiconsulting/subdomains-cro
       Halis Duraki <duraki@linuxmail.org>

ruby scripts/psql_crtsh.rb <domain-list>

Extract Certificate Transparency logs via crt(dot)sh and ccTLD szone domain list.

Command-Line Options
    <domain-list>   A domain list of the targeted ccTLD
    --debug         Debug Mode
    --print-active  Active Subdomain Grabber
    --show          Will display extracted subdomains and hosts
    <domain-start>  A starting point from which to continue process

Example
    ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt
    ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt --debug --print-active --show
    ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt --debug --print-active --show "nic.ba"
    ruby scripts/psql_crtsh.rb # .. cli opts ..
```

Your `stdout` should look something like this, when giving recon options:

```
$ ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt --debug --print-active --show 'nic.ba'

...
SELECT distinct(lower(name_value)) FROM certificate_and_identities cai WHERE plainto_tsquery('zzzm.ba') @@ identities(cai.CERTIFICATE) AND lower(cai.NAME_VALUE) LIKE ('%.zzzm.ba');
    ... pg_res created: #<PG::Result:0x00000001124d6328 status=PGRES_TUPLES_OK ntuples=10 nfields=1 cmd_tuples=10>
    ... pg_res obj: #<PG::Result:0x00000001124d6328>
    ... total subdomains: 10 -- in zzzm.ba
    ... Found subdomain:
    ... now total(subdomains) 7560 NOT_UNIQ
    ... [snip]
    ... enumerated approx. ~10
   ... possibly created psql session (wip)
   ... debug mode: (true)
   ... all done.
   ... QUERYS_TOTAL:     (6080)
   ... SUBDOMAIN_TOTAL:  (7559)
   ... HOST_AND*_TOTAL:  (57546)
```

Just showing-off for some reason? Build your preliminary subdomains.

```
$ ruby scripts/psql_crtsh.rb --build

# building final subdomain list from the `psql_crtsh` flow
    ... sorting subdomain(s) to szone/
    ... sorting by uniqness of the literal string
    ... removing unreferenced `_/` files
[dbg] build completed. all done
   11434 $HOME/subdomains-cro/scripts/../szone/clean_subdomains.crtsh.txt


# => meaning total uniq subdomains: **11434**. bingo!
#    szone/clean_subdomains.crtsh.txt
```

Log and result files are also present in the final build:

```
# => enable log-file in docs/debug.log :
#   $ ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt --debug --print-active --show0 > ./docs/debug.log

# => there are multiple files stored
  ./_subdomain.txt      containing all subdomains from the recon process
  ./_host_subdomain.txt containing all hostnames from the recon process

# => additionally, there are alternative modus operandi sorting unique
  ./szone/all-crtsh_subdomains_ext.txt 
  ./szone/all-crtsh_hosts+subdomains_ext.txt
```

**Combining the Preliminary Subdomain Results (auto)**

You can use built-in command `--build` to compile and build resourced subdomains:

```
$ ruby psql_crtsh.sh --build
...
```

**Combining Manually, Higher Build control (manual)**

```
# => the trick is to merge both unsorted, and programatical file writes 

  repository/ (DIR)
    --> _*.txt      _subdomain.txt _host_subdomain.txt    A file containing unsorted subdomain literals
    --> szone/all-crtsh_*_ext.txt                         Programatically sorted and unified subdomain literals

# => will sort dirty subdomains to szone/ equivalent
$ cat _subdomain.txt| sort > szone/_subdomain_sorted.txt 

# => will unify results and store to szone/ equivalent
$ cat szone/_subdomain_sorted.txt| uniq > szone/clean_subdomains.crtsh.txt
$ rm -rf szone/_subdomain_sorted.txt
```

## See Also

### Contributing

See CONTRIBUTING.md

### Similar Projects

* [fuzzdb-project/fuzzdb](https://github.com/fuzzdb-project/fuzzdb)
* [giteshnxtlvl/cook](https://github.com/giteshnxtlvl/cook)
* [fuzzdb-project/fuzzdb](https://github.com/fuzzdb-project/fuzzdb)
* [assetonote wordlists](https://wordlists.assetnote.io/)
* [archivesuburls](https://github.com/osamahamad/archivesuburls)

### License

This project is licensed under the private entity license. Redistribution and copy is allowed only to contributors.

