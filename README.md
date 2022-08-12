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

## See Also

### Contributing

See CONTRIBUTING.md

### Similar Projects

* [fuzzdb-project/fuzzdb](https://github.com/fuzzdb-project/fuzzdb)
* [giteshnxtlvl/cook](https://github.com/giteshnxtlvl/cook)
* [fuzzdb-project/fuzzdb](https://github.com/fuzzdb-project/fuzzdb)
* [assetonote wordlists](https://wordlists.assetnote.io/)

### License

This project is licensed under the private entity license. Redistribution and copy is allowed only to contributors.

