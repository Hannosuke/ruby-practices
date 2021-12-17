# frozen_string_literal: true

require_relative 'game'

game = Game.new(ARGV.first)
puts game.result
