# frozen_string_literal: true

require 'optparse'
require 'etc'

# オプション設定処理
option = {}

OptionParser.new do |opt|
  opt.on('-a') { |v| option[:a] = v }
  opt.on('-r') { |v| option[:r] = v }
  opt.on('-l') { |v| option[:l] = v }

  opt.parse!(ARGV)
end

# 出力内容加工処理
# オプションに応じて処理
file_names = Dir.glob('*').sort
file_names = Dir.entries('.').sort if option[:a]
file_names = file_names.reverse if option[:r]

# -lオプションがある場合の処理
# 8進数のアクセス権を文字に直す処理
def convert_into_character(num_of_permission)
  case num_of_permission.to_i
  # 各8進数の数字と対応する権限を代入
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

file_details = [] # 各ファイルの詳細情報格納配列
nums_of_file_blocks = [] # 各ファイルの割り当てブロック数格納配列
if option[:l]
  # 対象のファイルが入った配列をeachで処理
  file_names.each do |file|
    file_info = [] # 各ファイルの情報結合用配列
    stat = File.stat(file)
    # ファイルタイプを取得
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

    # モードを8進数で取得、権限部分（下3桁）を
    file_mode = format('%o', stat.mode).slice!(-3, 3).split('')
    # 下3桁を解析
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
    # 各情報を一つの文字列に結合
    file_details << file_info.join
  end
  puts "total #{nums_of_file_blocks.sum}"
  puts file_details
  return # lオプションがある時は整形出力しないため、ここで終了
end

# 出力整形処理パート
MAX_COLUMN = 3 # 今回は上限3列が要件
console_width = `tput cols`.to_i # ターミナルの幅を取得
max_length = file_names.max_by(&:length).length # ファイル名の最大文字数を算出
num_of_column = console_width / (max_length + 1) # 表示できる列数を算出(余裕を持たせるためプラス1して計算)
num_of_column = MAX_COLUMN if num_of_column > MAX_COLUMN # 列数が上限を超えないようにする
column_width = console_width / num_of_column # 一列あたりの幅を算出

# 縦出力のための加工
file_names << "\s" until (file_names.count % num_of_column).zero? # 整形にあたってズレが生じないよう、空白を配列に加える

formated_file_names = [] # 最終出力用配列を用意

num_of_lines = file_names.count / num_of_column # 表示する行数(要素数を列数で割った数)を算出
file_names.each_slice(num_of_lines) { |v| formated_file_names << v } # 行数にeach_sliceし、最終出力用配列に格納
formated_file_names = formated_file_names.transpose # その結果をtransposeし、出力前の配列が完成

# 出力処理
formated_file_names.each do |formated_file_name|
  formated_file_name.each.with_index(1) do |file_name, i|
    print file_name.ljust(column_width)
    print "\n" if i == num_of_column # 表示する列数に合わせて改行を入れる
  end
end
