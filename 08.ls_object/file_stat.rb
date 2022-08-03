# frozen_string_literal: true

require 'etc'

class FileStat
  attr_reader :name, :ftype, :mode, :hard_link_count, :owner_name, :group_name, :byte_size, :time_stamp, :blocks

  PERMISSION_MODES = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

  def initialize(file_name)
    stat = File.stat(file_name)
    @name = file_name
    @ftype = formatted_ftype(stat.ftype)
    @mode = convert_into_character(stat.mode)
    @hard_link_count = stat.nlink
    @owner_name = Etc.getpwuid(stat.uid).name
    @group_name = Etc.getgrgid(stat.gid).name
    @byte_size = stat.size
    @time_stamp = stat.ctime.strftime("%-m\s\s%-d\s%H:%M")
    @blocks = stat.blocks
  end

  def detail_text
    file_info = ftype
    file_info += mode
    file_info += "  #{hard_link_count}"
    file_info += " #{owner_name}"
    file_info += "  #{group_name}"
    file_info += "  #{byte_size}"
    file_info += " #{time_stamp}"
    file_info + " #{name}"
  end

  private

  # lsコマンドでのファイルタイプ表示を実現
  def formatted_ftype(ftype)
    case ftype
    when 'file'
      '-'
    when 'fif'
      'p'
    else
      # 通常ファイルとfifo以外は1文字目を表示すれば良い
      ftype[0]
    end
  end

  def convert_into_character(numbers)
    numbers = format('%o', numbers).slice!(-3, 3).split('')
    mode = numbers.map do |num|
      PERMISSION_MODES[num.to_i]
    end
    mode.join
  end
end
