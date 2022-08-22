#!/usr/bin/env ruby
require 'pg'

class String # => extend String#rsplit
  def rsplit(pattern=nil, limit=nil)
    array = self.split(pattern)
    left = array[0...-limit].join(pattern)
    right_spits = array[-limit..]
    return [left] + right_spits
  end
end

module PG # => extend PG::Connection#* 
  class Connection
    # => counts a query size
    def count(certgrabber) 
      # => certgrabber : CertGrabber # A CertGrabber object of self

      certgrabber.queries+=1
      puts "[dbg]  pg count (ensured) ... [#{certgrabber.queries}]" 
    end
  end
end

class CertGrabber
  # szone/clean_cctld-ba_nett.txt     io      pg_obj
  attr_accessor :filename, :io, :psql

  # session
  attr_accessor :conn

  # debug flag
  attr_accessor :debug

  # counter (inc)
  attr_accessor :queries

  attr_accessor :collection_hosts         # => hosts collected via reconphase
  attr_accessor :collection_subdomains    # => subdomains collected via reconphase

  # storage (array)
  attr_accessor :outfile

  def initialize(filename, io, psql, debug = false)
    self.debug = debug
    self.queries = 0
    self.collection_subdomains = []
    self.collection_hosts = []
    self.outfile = []

    # => io : Array # Loaded provided lines in IO
    # => psql : PostgreSQL # An object containing psql session
    puts ("   ... certgrabber DEBUG(#{self.debug.to_s})")
    puts ("   ... libpg version: " + PG.library_version.to_s)
    puts ("   ... io (YES) with #{filename}; psql_sess@pg (#{psql.inspect}) - created new sess. certgrabber (status: 0)")
    connect()

    # test / spec
    # do_work("olx.ba")

    io.each_with_index do |line, ix|
      line.gsub!(/[\r\n]/, '')
      line.gsub!(" ", '')
      begin
        do_work(line, ix)
      rescue
        puts "[fail] do_work failed at hostname #{line}, index #{ix} at [CertGrabber].new()"
        puts "[fail] do_work io.each_with_index at [CertGrabber].new()"
        next
      end
    end
  end

  def connect()
    puts "Initiating a new pgsql connection to remote host ..."
    # uri = URI("postgresql://guest@crt.sh:5432/certwatch")
    uri = URI("postgresql://guest@crt.sh:5432/certwatch") # hot_standby_feedback
    self.conn = nil

    puts "Using URI conn. string: #{uri.to_s}"
    begin
      self.conn = PG::Connection.new(uri.to_s)
      puts "Connection to remote host initiated: #{self.conn.inspect}"
      puts "    ... server pg version: " + self.conn.server_version.inspect
      puts "    ... pg last status: #{self.conn.status} (expected 4)"
      puts "    ... testing connection exec(): " + self.conn.exec('SELECT VERSION()').getvalue(0, 0)
    rescue PG::Error => e
      puts "[fail] " + e.message
      puts "  (maybe)? missing correct connection uri [fail]"
      puts ""
      puts "[fail] executing self.finalize() in rescue, recreating session"
      puts "[fail] self.conn = nil in object CertGrabber.rescue*"
      self.finalize # xxx: check me
      self.conn = nil
      connect()
    ensure
      self.queries+=1
    end
    puts "    ... queries (#{self.queries})"
  end

  def finalize
    in_out = Hash[
      "SZONE_SUBDOMAINS_CERTEXT" => "all-crtsh_subdomains_ext.txt",
      "SZONE_HOSTS_SUBS_CERTEXT" => "all-crtsh_hosts+subdomains_ext.txt"
    ]

    self.outfile = [
      __dir__ + "/../szone/" + in_out["SZONE_SUBDOMAINS_CERTEXT"],
      __dir__ + "/../szone/" + in_out["SZONE_HOSTS_SUBS_CERTEXT"]
    ]

    self.collection_hosts.sort!.uniq!
    self.collection_subdomains.sort!.uniq!

    # write subdomains only to file
    IO.write(__dir__ + "/../szone/" + in_out["SZONE_SUBDOMAINS_CERTEXT"], 
             self.collection_subdomains.join("\n"),
             mode = File::APPEND)

    # write hosts to file 
    IO.write(__dir__ + "/../szone/" + in_out["SZONE_HOSTS_SUBS_CERTEXT"], 
             self.collection_hosts.join("\n"),
             mode = File::APPEND)

    #puts " # Extracted Files"
    #puts "    cat #{__dir__}" + "/../szone/" + in_out["SZONE_SUBDOMAINS_CERTEXT"]
    #puts "    cat #{__dir__}" + "/../szone/" + in_out["SZONE_HOSTS_SUBS_CERTEXT"]
    #puts ""
    #puts "    [finalized] psql_crtsh exiting"
  end

  def do_query(domain_hostname, repeat = false, early_exit = false)
    # => qry : String # psql database query statement
    puts "    ... building query (plainto_tsquery)+(identities) - %LIKE%.#{domain_hostname}"
    qry = "SELECT distinct(lower(name_value)) FROM certificate_and_identities cai WHERE plainto_tsquery('$1') @@ identities(cai.CERTIFICATE) AND lower(cai.NAME_VALUE) LIKE ('%.$1');" 
    puts "    ... doing query (#{domain_hostname})" 
    puts "[dbg]   #{ARGV[1] == "--debug" ? qry : qry.strip(100) + ' ... <stripped+100>'} "
    puts "[dbg]   #{ARGV[1] != "--debug" ? 'use --debug cli argument to print whole query' : 'dbg set'}"

    if ARGV[1] == "--debug"
      qry.gsub!("$1", "#{domain_hostname}")

      puts "*" * qry.size
      puts qry # => use .sub for single match 
      puts "*" * qry.size
    end

    begin
      res = self.conn.exec(qry)
      puts "    ... pg_res created: #{res.inspect}"
      puts "    ... pg_res obj: #{res}" # => PG::Result::<> : query result tuples (rows)
      extract_subdomains(res, domain_hostname)
      puts "    ... enumerated approx. ~#{res.cmd_tuples}"
    rescue PG::Error => e
      puts "[fail] == PG::Error (start) ==" # + "*" * 50
      puts "[fail] " + e.message
      puts "[fail] == PG::Error (end) ==" # + "*" * 50

      if e.message.include?("PQconsumeInput")
        puts "[fail] PQconsumeInput with message: #{e.message}"
      end

      # 2nd-iteration with identified PQsocket
      if (repeat) && e.message.include?("PQsocket") 
        connect()
        puts "[fail] PQsocket failure on DNS:       #{domain_hostname}"
        puts "[fail] " + e.message + " (PQsocket dead) PG::ConnectionBad"
        puts "[fail] seems like it PQsocket failed, will repeat: #{repeat.to_s}"
        puts "[dbg]  " + " repeat " + " (#{repeat.to_s})"
        puts "[dbg]  " + " next-run (repeated), repeat now false, early_exit true"
        puts "[dbg]  " + " PQSocket manual exception detected"
        puts "[dbg]  " + "        due to the PQsocket error, this is repeated request"
        sleep(1)
        return do_query(domain_hostname, repeat = false, early_exit = true)
      else 
        puts "[dbg]  " + " first-run (default) " + "[not-fail] non repeat"

        if e.message.include?("PQsocket") # => non-repeat + error
          return if early_exit
          connect()
          puts "[fail]  " + " first-run (non-repeat + error), setting repeat to true " + "[dbg]"
          do_query(domain_hostname, repeat = true, early_exit = false)
        else
          return if early_exit
          do_query(domain_hostname, repeat = false, early_exit = false)
        end
      end
    ensure
      self.queries+=1
    end
  end

  def extract_subdomains(pg_res, domain_hostname)
    # => pg_res : PGResult # psql rows in query results
    # => domain_hostname : String # Domain ccTLD hostname or DNS

    host_and_subdomains = [] # => all extracted hostnames and subdomains
    only_subdomains = [] # => all subdomains extracted from hostname

    puts "    ... total subdomains: #{pg_res.count} -- in #{domain_hostname}"
    pg_res.each do |subdomain_row|
      # ... total subdomains: 12 -- in olx.ba
      #   {"lower"=>"blog.olx.ba"}
      #   {"lower"=>"cert.olx.ba"}
      host_subdomain = subdomain_row["lower"] # => `host_subdomain` will be blog.example.ba
      system("echo '#{host_subdomain}' >> ./_host_subdomain.txt")
      
      if self.debug && ARGV[2] == "--print-active"
        puts "    ... Found subdomain: " #+ host_subdomain
      end

      host_and_subdomains << host_subdomain

      begin
        uri = URI.parse("http://#{host_subdomain}")
        if _subdomain = uri.host.split('.').first
          system("echo '#{_subdomain}' >> ./_subdomain.txt")
          only_subdomains << _subdomain
        end
      rescue
        puts "[fail] could nto split from uri(#{host_subdomain}) skip ..."
        next
      ensure 
        store_in_coll(host_and_subdomains, only_subdomains)
        self.finalize
      end
    end
  end

  def store_in_coll(hosts, subdomains)
    self.collection_hosts += hosts
    self.collection_subdomains += subdomains
    puts "    ... now total(subdomains) #{self.collection_subdomains.count} NOT_UNIQ"
  end

  def prompt(*args)
    print(*args)
    gets
  end

  def do_work(line, ix)
    puts "domain (#{line})@#{ix} in progress ... psql_crtsh extraction qry"

    do_query("#{line}")
    Signal.trap('INT') do |trap|
      # Ctrl+C reached here
      puts "    .... SIGINT Ctrl+C [Interrupted by user]" 
      puts "         writing indexed line to current directory"
      puts "         cat #{__dir__}/crtsh.ix"
      File.write(__dir__ + "/" + "crtsh.ix", ix)
      self.finalize
      abort "   .... exiting"
    end

  end

end

args = ARGV

if args[0] == "--build"
  puts "... # building clean final subdomain list from the `psql_crtsh` flow"
  puts "    ... sorting subdomain(s) to szone/"
  system("cat #{__dir__}/../_subdomain.txt| sort > szone/_subdomain_sorted.txt")
  puts "    ... sorting by uniqness of the literal string"
  system("cat #{__dir__}/../szone/_subdomain_sorted.txt| uniq > szone/clean_subdomains.crtsh.txt")
  puts "    ... removing unreferenced `_/` files"
  system("rm -rf #{__dir__}/../szone/_subdomain_sorted.txt")

  puts "[dbg] build completed. all done"
  system("wc -l #{__dir__}/../szone/clean_subdomains.crtsh.txt")
  
  exit(1)
end

if args[0] == "--build-hostnames"
  puts "... # building clean final hostname list from the `psql_crtsh` flow"
  puts "    ... sorting hostname(s) to szone/"
  system("cat #{__dir__}/../_host_subdomain.txt| sort > szone/_host_subdomain_sorted.txt")
  puts "    ... sorting by uniqness of the literal string"
  system("cat #{__dir__}/../szone/_host_subdomain_sorted.txt| uniq > szone/clean_hostname-w_subdomains.crtsh.txt")
  puts "    ... removing unreferenced `_/` files"
  system("rm -rf #{__dir__}/../szone/_host_subdomain_sorted.txt")

  puts "[dbg] hostname+subdomain build completed. all done"
  system("wc -l #{__dir__}/../szone/clean_hostname-w_subdomains.crtsh.txt")
  exit(1)
end

if args.count < 1
  puts ""
  puts "       psql_crtsh - Ruby Extraction Script"
  puts "       durakiconsulting/subdomains-cro"
  puts "       Halis Duraki <duraki@linuxmail.org>"
  puts ""
  puts "ruby scripts/psql_crtsh.rb <domain-list>"
  puts ""
  puts "Extract Certificate Transparency logs via crt(dot)sh and ccTLD szone domain list."
  puts ""
  puts "Command-Line Options"
  puts "    --build         Build the final 'szone/clean_subdomains.crtsh.txt'"
  puts "    <domain-list>   A domain list of the targeted ccTLD"
  puts "    --debug         Debug Mode"
  puts "    --print-active  Active Subdomain Grabber" # => displays more verbosly
  puts "    --show          Will display extracted subdomains and hosts" 
  puts "    <domain-start>  A starting point from which to continue process"
  puts ""
  puts "Examples"
  puts "    ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt"
  puts "    ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt --debug --print-active --show"
  puts "    ruby scripts/psql_crtsh.rb szone/clean_cctld-ba_nett.txt --debug --print-active --show 'nic.ba'"
  puts "    ruby scripts/psql_crtsh.rb # .. cli opts .."
  puts ""
  puts "Building"
  puts "    ruby scripts/psql_crtsh.rb --build        # will build the 'final', 'clean' dataset"
else
  @domainlist = args[0]
  @io_input = []

  input = __dir__ + "/../" + @domainlist

  # => argv4 is used as position index, 
  #    ie. start_from = "nic.ba", will start worker from the offset of the literal string
  if !args[4].nil? 
    start_from = args[4] ? args[4] : ""
    puts "   ... starting from #{start_from} at indexed szone"
    puts "   ... io_input #{@io_input}"
    cont = false
    IO.readlines(input).each do |x|
      x.gsub!(/[\r\n]/, '')
      x.gsub!(" ", '')
      start_from = start_from.gsub(/[\r\n]/, '')
      start_from = start_from.gsub(" ", '')

      if (x == start_from) && (cont == false) then
        @io_input << x
        cont = true
      elsif (cont == true) && (x != start_from) then 
        @io_input << x
      end
    end

    puts "   ... custom starting point, from #{start_from}, total next count: #{@io_input.size}"
  else 
    @io_input = IO.readlines(input)
  end

  puts "Loaded <#{@domainlist}> for extraction purposes ..."
  puts "   ... possibly all uniq (wip)"
  puts "   ... possibly ~#{@io_input.size} total"
  @pg = nil
  debug = false
  if ARGV[1] == "--debug"
    debug = true # => is --debug set
  end
  pg_crt = CertGrabber.new(input, @io_input, @pg, debug) 
  puts "   ... possibly created psql session (wip)"
  puts "   ... debug mode: (#{debug})"
  puts "   ... all done."
  puts "   ... QUERYS_TOTAL:     (#{pg_crt.queries})"
  puts "   ... SUBDOMAIN_TOTAL:  (#{pg_crt.collection_subdomains.count})"
  puts "   ... HOST_AND*_TOTAL:  (#{pg_crt.collection_hosts.count})"
  puts ""

  pg_crt.finalize # ? required xxx: check me

  # => --show cli argument will print out final *txts
  if ARGV[3] == "--show" then
    pg_crt.outfile.each do |out|
      puts ""
      puts "*" * 100
      system("cat #{out}")
    end
  end


  # pkill -f ruby
  # pkill -9 ruby

end
