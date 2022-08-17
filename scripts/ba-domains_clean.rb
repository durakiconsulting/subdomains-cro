CCTLD_BA = [
  # => can only have one dot (.) - ie. nic.ba
  ".ba",      

  # => can only have two dots (.) - ie. .org.ba
  ".org.ba",  
  ".net.ba",
  ".gov.ba",
  ".mil.ba",
  ".edu.ba"
]

@clean_list = []

def count_dots(line) # => should return number of string occurences of "."
  count = line.count(".")
  return count
end

def do_work(line)
  puts "domain (#{line}) in progress ... no_unknw"

  if line.end_with?(CCTLD_BA[5]) # .edu.ba
    #puts "Domain is Educational => Calculate (#{line})"
    if (count = count_dots(line)) > 2
      #puts "Skipping. Supposably a subdomain of reconned cctld (count: #{count})"
    else
      @clean_list << line
      return
    end
    return
  end

  if line.end_with?(CCTLD_BA[4]) # .mil.ba
    if (count = count_dots(line)) > 2
    else
      @clean_list << line
      return
    end
    return
  end

  if line.end_with?(CCTLD_BA[3]) # .gov.ba
    if (count = count_dots(line)) > 2
    else
      @clean_list << line
      return
    end
    return
  end

  if line.end_with?(CCTLD_BA[2]) # .net.ba
    if (count = count_dots(line)) > 2
    else
      @clean_list << line
      return
    end
    return
  end

  if line.end_with?(CCTLD_BA[1]) # .org.ba
    if (count = count_dots(line)) > 2
    else
      @clean_list << line
      return
    end
    return
  end

  if line.end_with?(CCTLD_BA[0]) # .ba
    if (count = count_dots(line) > 1)
    else
      @clean_list << line
    end
    return
  end
end

puts "evaulating toplvl+secondlvl domains only"

input = __dir__ + "/../" + "szone/cctld-ba_nett.txt"
output = __dir__ + "/../" + "szone/clean_cctld-ba_nett.txt"

puts "input is (#{input}) => output is (#{output})"
puts "now doings extraction ..."

#io_input = IO.read(input)
io_input = IO.readlines(input)
puts "total lines to process ... ~(#{io_input.size})"

io_input.each do |line|
  line.gsub!(/[\r\n]/, '')
  line.gsub!(" ", '')
  do_work(line)

  # test / specs
  #do_work("test.edu.ba")
  #do_work("subdomain.test.edu.ba")
  #do_work("test.gov.ba")
  #do_work("military.mil.ba")
  #do_work("sub.military.mil.ba")
end

puts "Final Results:"
@clean_list.sort!
@clean_list.uniq!

puts @clean_list
puts "Total Results (count) #{@clean_list.count}"

puts "Writing new results to output(#{output})"
File.open("#{output}", 'w') { |f| @clean_list.each { |line| f << line + "\r\n" } }

