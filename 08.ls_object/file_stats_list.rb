# frozen_string_literal: true

class FileStatsList
  # 表示時の列数上限
  MAX_COLUMN = 3

  def initialize(all: nil, reverse: nil)
    file_names = Dir.glob('*')
    file_names = Dir.glob('*', File::FNM_DOTMATCH) if all
    file_names = file_names.reverse if reverse

    @file_stats = file_names.map do |file_name|
      FileStat.new(file_name)
    end
  end

  def display
    formatted_file_names.each do |file_names_per_line|
      file_names_per_line.each.with_index(1) do |file_name, i|
        print file_name.ljust(column_width)
        # 表示する列数に合わせて改行を入れる
        print "\n" if i == column_count
      end
    end
  end

  def display_details
    total_file_blocks = 0
    file_details = []

    @file_stats.each do |file_stat|
      total_file_blocks += file_stat.blocks
      file_details << file_stat.detail_text
    end
    puts "total #{total_file_blocks}"
    puts file_details
  end

  private

  def console_width
    `tput cols`.to_i
  end

  def column_count
    # ファイル名の最大文字数を算出
    max_length = @file_stats.map(&:name).max_by(&:length).length
    # 表示できる列数を算出(余裕を持たせるためプラス1して計算)
    column_count = console_width / (max_length + 1)
    column_count > MAX_COLUMN ? MAX_COLUMN : column_count
  end

  def column_width
    console_width / column_count
  end

  # 縦出力のための加工
  def formatted_file_names
    file_names = @file_stats.map(&:name)
    # 整形にあたってズレが生じないよう、空白を配列に追加
    file_names << "\s" until (file_names.count % column_count).zero?

    # 表示に必要な行数(要素数を列数で割った数)を算出
    line_count = file_names.count / column_count
    # 行数にeach_sliceし、最終出力用配列を作成
    formatted_file_names = file_names.each_slice(line_count).map { |v| v }
    # その結果をtransposeし、縦横変換
    formatted_file_names.transpose
  end
end
