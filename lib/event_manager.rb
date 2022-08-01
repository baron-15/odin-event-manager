require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


# lines = File.readlines('event_attendees.csv')
# row_index = 0
# lines.each_with_index do |line, index|
#    next if row_index == 0
#    columns = line.split(",")
#    name = columns[2]
#    puts name
# end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    return civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    return 'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
    'event_attendees.csv', 
    headers: true,
    header_converters: :symbol
)
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter



legislators_hash = Hash.new

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  legislators_hash[name] = {zipcode: zipcode, legislators: legislators}
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end

