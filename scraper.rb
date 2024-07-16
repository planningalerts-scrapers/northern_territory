require 'scraperwiki'
require 'rubygems'
require 'mechanize'
require 'date'
require 'json'

agent = Mechanize.new do |a|
  a.verify_mode = OpenSSL::SSL::VERIFY_NONE
end

url = 'https://www.ntlis.nt.gov.au/planning-notices-online/notices/json'

data = JSON.parse(agent.get(url).content)['currentNotices']
data.each do |row|
  begin
	  address = "#{row['parcelDetails'][0]['streetNumber']} #{row['parcelDetails'][0]['streetName']} #{row['parcelDetails'][0]['suburb']}, NT"
  rescue
	  next
	  # No addresses on this DA
  end
  council_reference = row['applicationNumber']
  description = row['purpose']
  on_notice_to = row['exhibition']['formattedFinishDate']
  
  record = {
    'address' => address,
    'description' => description,
    'on_notice_to' => on_notice_to,
    'council_reference' => council_reference,
    'info_url' => "https://www.ntlis.nt.gov.au/planningPopup/lta.dar.view/#{council_reference}",
    'date_scraped' => Date.today.to_s
  }
  ScraperWiki.save_sqlite(['council_reference'], record)
end
