# frozen_string_literal: true

require_relative 'count'
require_relative 'game'
require_relative 'human_player'
require_relative 'secret_code'
require_relative 'computer_player'

game = Game.new
game.play_game