require 'rubygems'
require 'nokogiri'
require 'json'
require 'net/http'
require 'open-uri'
require 'csv'

# No trailing slash for site
def scrape(site)
  base_url = "#{site}/page/"

  url_list = Array.new
  post_links = Array.new

  # Grabbing all the pages
  (1..14).each do |i|
    url_list << base_url + i.to_s
    puts "Getting page " + i.to_s
  end

  # Going through individual pages
  url_list.each do |page|
    doc = Nokogiri::HTML(open(page))

    # Getting post links, make sure to check the HTML <==================== CHANGE THIS ===========================
    doc2 = doc.css('h2.entry-title a')

    doc2.each do |link|
      puts 'Collecting link ' + post_links.count.to_s
      post_links << link['href']
    end
  end

  puts "Finished with getting all the links"

  CSV.open("derek-halpern-wp.csv", "wb") do |csv|
    csv << ["Title", "Link", "Date", "Comments", "Likes", "Tweets", "LinkedIn", "Pins", "+ 1's"]
    
    post_links.each_with_index do |post, index|

      share_counts = "http://api.sharedcount.com/?url=#{post}"
      resp = (Net::HTTP.get_response(URI.parse(share_counts))).body
      result = JSON.parse(resp, :symbolize_names => true)

      fb = result[:Facebook][:total_count]
      tw = result[:Twitter]
      ln = result[:LinkedIn]
      pin = result[:Pinterest]
      gp = result[:GooglePlusOne]

      post_page = Nokogiri::HTML(open(post))

      # Make sure the post headline follows this structure <==================== CHANGE THIS ===========================
      post_title = post_page.css('h1.entry-title').text
      
      # Make sure the comments follow this structure <==================== CHANGE THIS ===========================
      post_comments = post_page.css('#comments_intro').text.to_i

      #post_date = post_page.css('.meta .signature').text
      #find_comments = post_page.xpath('//*[@id="comments"]/comment()').text
      #convert_to_ng = Nokogiri::HTML.parse(find_comments)
      #post_comments = convert_to_ng.css('h2').text.to_i

      puts "Scraping post " + index.to_s + "/" + post_links.length.to_s

      csv << ["#{post_title}", "#{post}", "#{post_date}","#{post_comments}", "#{fb}", "#{tw}", "#{ln}", "#{pin}", "#{gp}"]
    end
  end
end