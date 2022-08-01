require 'csv'
require 'time'
require 'date'

def clean_hour(reg)
  return Time.strptime(reg, "%m/%d/%y %k:%M").hour
end

def clean_weekday(reg)
  return Date.strptime(reg, "%m/%d/%y %k:%M").wday
end

def hoursAnalysis(array)
  tally = array.tally.sort_by{|hour, value| value}.reverse
  puts
  puts "Time Targeting"
  puts "Result:"
  tally.each_with_index do |(hour, value), index|
    puts "\##{index+1} - Hour #{hour}: #{value}"
  end
end

def weekdayAnalysis(array)
  tally = array.tally.sort_by{|day, value| value}.reverse
  puts
  puts "Weekday Targeting"
  puts "Result:"
  tally.each_with_index do |(day, value), index|
    puts "\##{index+1} - #{dayLookup(day)}: #{value}"
  end
end

def dayLookup(num)
  days ={0 => "Sunday",
    1 => "Monday", 
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6 => "Saturday"}
  return days[num]
end

def clean_phone(phoneNumber)
  number = phoneNumber.tr('^0-9', '')
  if (number.size == 10)
    return number
  elsif (number.size == 11)
    if number[0]="1"
      return number[1..-1]
    end
  else
    return "Invalid"
  end
end

contents = CSV.open(
    'event_attendees_full.csv', 
    headers: true,
    header_converters: :symbol
)

hours_array = []
weekday_array = []

contents.each do |row|
  hours_array.push(clean_hour(row[:regdate]))
  weekday_array.push(clean_weekday(row[:regdate]))
  phone = clean_phone(row[:homephone])
  puts "#{row[:first_name]} - Phone number #{phone}"
end

hoursAnalysis(hours_array)
weekdayAnalysis(weekday_array)