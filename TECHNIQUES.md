# Techniques

Generally, we used two type of subdomain enumeration as well as generation. These are:

* Passive subdomain enumeration
* Active subdomains enumeration

**Passive subdomain enumeration** could be performed by querying public information that is available in database. It is completely silent towards the target, since no DNS request are sent at all.

**Active subdomain enumeration** queries the nameserver of the target, in order to construct a list of valid subdomains. These includes queries such is AXFR, bruteforce, 'A' Resource Record queries, 'CNAME' and so on.

Since the goal of this excersise is to provide a compiled list of subdomains for regional limits of Ex-Yu, we will not provide scripts for requesting and responsing all of the techniques. Instead, a partials will be provided with a completed subdomain list for an end-user's use. Additionally, no recursive ENT (Empty Non-Terminal) will be handled; instead, use of wordlist permutation tools will be used to generate larger wordlists.

## List of Techniques

These are techniques utilised in one part or another in this project. From few, we will list the following:

* Extraction of ccTLD Zone via extract/enum/parse
* Extraction of subdomains via [machine learning](/ML-TECHNIQUES.md) (RNN)
* Extraction of subdomains via Google Search operator (ie.: `site:*.DOMAIN.cctld`)
* Extraction of subdomains via Bing Search operator (ie.: `site:*.DOMAIN.cctld`) 
* Extraction of subdomains via VirusTotal passive DNS replication (ie: `Search => DOMAIN.cctld`)
* Extraction of subdomains via DNSdumpster
* Extraction of subdomains via Archiving Services, such is Wayback Machine
  - note: `archivesuburls` can be used to ease the process
* Extraction of subdomains via Certificate Transparency (CT) Logs
  - note: *downside of CT for subdomain enumeration is that the domain names found in the CT logs may not exist anymore*
  - note: *conjuct `massdns` with CT Logs to quickly identify resolvable domain names 
  - note: `./ct.py DOMAIN.cctld | ./bin/massdns -r RESOLVERS.txt -t A -q -a -o -w DOMAIN_RESOLVABLE.txt -`
* Extraction of subdomains via Dictionary-based techniques (ie.: `seclists`) 
  - note: *this is used indirectly with Translation services, such is translating English-based wordlists to Regional
* Extraction of subdomains via Permutation scanning , such is altering and mutating known subdomains
  - note: *`altdns` is a tool that conforms to domain generation patterns*
  - note: *[`cook`](https://github.com/giteshnxtlvl/cook) is a tool to manage wordlists via generator/splitter/merger/creator/combinator and so on* 
* Extraction of subdomains via Autonomus System (AS) Numbers, identifying netblocks of a belonging organization
  - note: `dig/host DOMAIN.cctld`, `find ASN for given IPv4 addr`, then `nmap --script targets-asn --targets-asn.asn=XXXX`
* Extraction of subdomains via Zone Transfer on a DNS
  - note: `dig +multi AXFR @ns1.INSECURE_DOMAIN.cctld INSECURE_DOMAIN.cctld`
* Extraction of subdomains via DNSSEC zone enumeration 
  - note: `ldns-walk @ns1.INSECURE_DOMAIN.cctld INSECURE_DOMAIN.cctld`
  - note: *some DNSSEC zone use NSEC3, that uses hashed domain names to prevent this attack. we can still use hashes and crack them offline*
  - note: *tools like `nsec3walker`, `nsec3map` can be used to collect and crack the hashses* 
  - *using nsec3:* `collect DOMAIN.cctld > DOMAIN.cctld.collect`
  - *using nsec3:* `unhash < DOMAIN.cctld.collect > DOMAIN.cctld.unhash`
  - *using nsec3:* `cat DOMAIN.cctld.unhash | grep "DOMAIN" | awk '{print $2;}'`
* Extraction of subdomains via Forward DNS dataset ([Project Sonar](https://opendata.rapid7.com/sonar.fdns_v2/))
  - `curl -silent https://scans.io/data/rapid7/sonar.fdns_v2/20170417-fdns.json.gz | pigz -dc | grep ".DOMAIN.cctld" | jq`
* Extraction of `Content-Security-Policy` HTTP Header
  - `curl -s -I -L "https://www.DOMAIN.cctld/" | grep -Ei ‘^Content-Security-Policy:’ | sed “s/;/;\\n/g”`
* Passive extraction of subdomains via external scanners (ie.: `amass`)

### References

[A penetration tester’s guide to subdomain enumeration](https://blog.appsecco.com/a-penetration-testers-guide-to-sub-domain-enumeration-7d842d5570f6), [Open Source Intelligence Gathering 101](https://blog.appsecco.com/open-source-intelligence-gathering-101-d2861d4429e3), [Esoteric Subdomain Enum (slides)](https://github.com/appsecco/bugcrowd-levelup-subdomain-enumeration/blob/master/esoteric_subdomain_enumeration_techniques.pdf), [Enhancing Subdomain Enumeration - ENTs and NOERROR](https://www.securesystems.de/blog/enhancing-subdomain-enumeration-ents-and-noerror/)

### Related Projects 

[GSAN - Get Subject Alternative Names](https://franccesco.github.io/getaltname/), [DomainRecon](https://github.com/realsanjay/DomainRecon)
