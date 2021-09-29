# frozen_string_literal: true

require 'optparse'
require './08.ls_object/file_stats_list'
require './08.ls_object/file_stat'

class Ls
  def initialize(options)
    option = parse_options(options)

    @option_l = option[:l]
    @file_stats_list = FileStatsList.new(all: option[:a], reverse: option[:r])
  end

  def call
    if @option_l
      @file_stats_list.display_details
    else
      @file_stats_list.display
    end
  end

  private

  def parse_options(raw_options)
    option = {}
    OptionParser.new do |opt|
      opt.on('-a') { |v| option[:a] = v }
      opt.on('-r') { |v| option[:r] = v }
      opt.on('-l') { |v| option[:l] = v }

      opt.parse!(raw_options)
    end
    option
  end
end

ls = Ls.new(ARGV)
ls.call
