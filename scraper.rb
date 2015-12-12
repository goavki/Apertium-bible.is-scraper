require 'nokogiri'
require 'open-uri'
require 'optparse'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-uURL", "--url=URL", "The bible.is URL for the bible. (Mandatory)") do |u|
    options[:url] = u
  end
  
  opts.on("-oOUTPUT", "--out=OUTPUT", "The out file name. (Mandatory)") do |o|
    options[:out] = o
  end
  
  opts.on("-tTIME", "--time=TIME", "The time limit in seconds. (Optional)") do |t|
    options[:time] = t
  end
  
  opts.on("-nVERSES", "--num=VERSES", "The verse limit. (Optional)") do |v|
    options[:verses] = v
  end
end

begin
  optparse.parse!
  raise OptionParser::MissingArgument if options[:url].nil? || options[:out].nil?
rescue OptionParser::MissingArgument, OptionParser::InvalidOption
  puts optparse
  exit
end

bible_url = options[:url]  || "http://www.bible.is/ENGESV/2Pet/3"
page_exists = true
verses_finished = 0
start_time = Time.now

open(options[:out] || "out.txt", "w:UTF-8") do |f|
  while page_exists && (options[:time].nil? || Time.now - start_time < options[:time].to_i) && (options[:verses].nil? || verses_finished < options[:verses].to_i)
    page = Nokogiri::HTML(open(bible_url).read, nil, 'UTF-8')
    a = page.css(".verse-container")
  
    ch_title = page.xpath('.//*[@class="chapter-title"]').text
    
    f.puts ch_title << "\n"
    puts(ch_title)
    
    a.each do |v|
      f.puts v.xpath('.//*[@class="verse-marker"]').text << " " << v.xpath('.//*[@class="verse-text"]').text << "\n"
    end
  
    bible_url = page.at_css(".chapter-nav-right")["href"]
  
    page_exists = false if bible_url.nil? || bible_url.empty?
    verses_finished = verses_finished + 1
  end
end