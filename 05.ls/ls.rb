# frozen_string_literal: true

require 'optparse'
require 'etc'

option = {}

OptionParser.new do |opt|
  opt.on('-a') { |v| option[:a] = v }
  opt.on('-r') { |v| option[:r] = v }
  opt.on('-l') { |v| option[:l] = v }

  opt.parse!(ARGV)
end

file_names = Dir.glob('*')
file_names = Dir.glob('*', File::FNM_DOTMATCH) if option[:a]
file_names = file_names.reverse if option[:r]

def convert_into_character(num_of_permission)
  case num_of_permission.to_i
  when 0
    '---'
  when 1
    '--x'
  when 2
    '-w-'
  when 3
    '-wx'
  when 4
    'r--'
  when 5
    'r-x'
  when 6
    'rw-'
  when 7
    'rwx'
  end
end

file_details = []
nums_of_file_blocks = []
if option[:l]
  file_names.each do |file|
    file_info = []
    stat = File.stat(file)
    ftype = stat.ftype
    file_info <<
      case ftype
      when 'file'
        '-'
      when 'fif'
        'p'
      else
        ftype[0]
      end

    # モードを8進数で取得、権限部分（下3桁）を解析
    file_mode = format('%o', stat.mode).slice!(-3, 3).split('')
    file_mode.each do |permission|
      file_info << convert_into_character(permission)
    end

    nums_of_file_blocks << stat.blocks
    file_info << "  #{stat.nlink}"
    file_info << " #{Etc.getpwuid(stat.uid).name}"
    file_info << "  #{Etc.getgrgid(stat.gid).name}"
    file_info << "  #{stat.size}"
    file_info << " #{stat.ctime.strftime("%-m\s\s%-d\s%H:%M")}"
    file_info << " #{file}"
    file_details << file_info.join
  end
  puts "total #{nums_of_file_blocks.sum}"
  puts file_details

  # lオプションがある時は整形出力しないため、ここで終了
  return
end

# 今回は上限3列が要件
MAX_COLUMN = 3
console_width = `tput cols`.to_i
max_length = file_names.max_by(&:length).length # ファイル名の最大文字数を算出
num_of_column = console_width / (max_length + 1) # 表示できる列数を算出(余裕を持たせるため最大文字数+1で計算)
num_of_column = MAX_COLUMN if num_of_column > MAX_COLUMN
column_width = console_width / num_of_column # 一列あたりの幅を算出

# 縦出力のための加工
file_names << "\s" until (file_names.count % num_of_column).zero? # 整形にあたってズレが生じないよう、空白を配列に加える
formatted_file_names = []

num_of_lines = file_names.count / num_of_column # 表示する行数(要素数を列数で割った数)を算出
file_names.each_slice(num_of_lines) { |v| formatted_file_names << v }
formatted_file_names = formatted_file_names.transpose

formatted_file_names.each do |file_names_per_line|
  file_names_per_line.each.with_index(1) do |file_name, i|
    print file_name.ljust(column_width)
    print "\n" if i == num_of_column
  end
end
