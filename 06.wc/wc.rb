# frozen_string_literal: true

require 'optparse'

option = {}
OptionParser.new do |opt|
  opt.on('-l') { |v| option[:l] = v }

  opt.parse!(ARGV)
end

def multi_args?
  ARGV.count >= 2
end

if ARGV.count.positive?
  # 引数が複数の場合は合計出力用配列を用意
  total_info = [] if multi_args?

  ARGV.each do |file_name|
    if !Dir.entries('.').include?(file_name)
      puts "wc: #{file_name}: open: No such file or directory"
      next
    elsif File.stat(file_name).ftype == 'directory'
      puts "wc: #{file_name}: read: Is a directory"
      next
    end

    info = []
    str = File.read(file_name)
    info << str.count("\n")

    if option[:l]
      info << file_name

      puts info.join(' ')
      total_info << info.slice(0) if multi_args?
    else
      info << str.split(/\n+|\t+\s+|[[:space:]]+/).size
      info << File.size(file_name)
      info << file_name

      puts info.join(' ')
      total_info << info.slice(0..-2) if multi_args?
    end
  end

  # 引数が複数ある場合は最後にトータルを出力
  if multi_args?
    if option[:l]
      puts "#{total_info.sum} total"
      return
    end

    total_info = total_info.transpose.map(&:sum) << 'total'
    puts total_info.join(' ')
  end
  return
end

# 引数がない場合に、コマンドの実行結果を受け取って処理する
str = readlines
info = []
if option[:l]
  puts str.count
else
  info << str.count
  amounts_of_words = str.map { |line| line.split(/\n+|\t+\s+|[[:space:]]+/).size }
  info << amounts_of_words.sum
  info << str.join.bytesize

  puts info.join(' ')
end
