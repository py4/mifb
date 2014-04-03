require 'nokogiri'
require 'open-uri'
require 'colorize'

blacklist = ["dvdrip","xvid","maxspeed","720p","hd"]

puts "Enter the directory: "
dir_addr = gets.chomp
names = Dir.entries(dir_addr).reject { |name| name == "." or name == ".." }
names.each do |name|
    name.downcase!
    blacklist.each { |black_name| name.gsub!(black_name,'') if name.include? black_name }
    name = name.gsub(/[^A-Za-z\s]/,' ').strip.gsub(" ","+")
    doc = Nokogiri::HTML(open("http://www.imdb.com/find?q=#{name}&s=all"))
    section = doc.css("div.findSection").select { |section| section.css("h3.findSectionHeader").text == "Titles" }.first
    relative_url = section.css("table.findList").css("tr").first.css("td.result_text").css("a").attr("href").text
    doc = Nokogiri::HTML(open("http://www.imdb.com#{relative_url}"))
    puts ">>> #{doc.css("h1.header").css("span.itemprop").text} <<<".red
    print "genre: ".green
    print doc.css("div.infobar").css("span.itemprop").map { |item| item.text }
    print "\n"
    print "rating: ".green
    puts doc.css("div.star-box-giga-star").text
    print "description: ".green
    puts doc.css("td#overview-top").css("p").select { |p| p.attributes["itemprop"] and p.attributes["itemprop"].value == "description" }.first.text
end

