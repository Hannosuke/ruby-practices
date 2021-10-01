require 'date'
require 'optparse'

# -y, -mオプションを受け取る
option = {}
OptionParser.new do |opt|
  begin
    opt.banner = "Usage: calender [options]"
    opt.on('-y year') {|v| option[:year] = v}
    opt.on('-m month') {|v| option[:month] = v}

    opt.parse!(ARGV)
  rescue OptionParser::InvalidOption => e
    puts "calender.rb:\s#{e.reason=('illegal option')}\s#{e.args.join(' ')}"
    puts opt.help
    exit 1
  rescue OptionParser::MissingArgument => e
    puts "option requires an argument\s#{e.args.join(' ')}"
    puts opt.help
    exit 1
  end
end

# オプション有無の処理
if option[:year] 
  year = option[:year].to_i if option[:year] =~ /^\d+$/

  unless (1..9999).include?(year)
   puts "calender.rb: year #{option[:year]} not in range 1..9999"
   exit
  end
else
  year = Date.today.year
end

if option[:month]
  month = option[:month].to_i if option[:month] =~ /^\d+$/

  unless (1..12).include?(month)
    puts "calender.rb: #{option[:month]} is neither a month number (1..12) nor a name"
    exit
  end
else
  month = Date.today.month
end

# 各変数を用意
first_day = Date.new(year, month, 1)
last_day = Date.new(year, month, -1)
days_of_week_header = %w(日 月 火 水 木 金 土)

# ヘッダー情報を出力
month_header = "#{month}月 #{year}"
puts month_header.center(20)
puts days_of_week_header.join(' ')
print "\s\s\s" * first_day.wday

# カレンダー部分出力
(first_day..last_day).each do |date|
  day_number = date.day.to_s.rjust(2)
  
  if date == Date.today
    print "\e[47;30m#{day_number}\e[0m" + "\s"
  else
    print day_number + "\s"
  end
  
  if (date.wday + 1) % 7 == 0
    print "\n"
  end
end

# 末日が土曜日でない場合の改行
if (last_day.wday + 1) % 7 != 0
  print "\n"
end
