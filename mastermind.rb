class Game
  def initialize(player, game_code)
    @player = player
    @code = game_code.code
    @round = 1
    @guesses_by_round = {}
    @feedback_by_round = {}
    @feedback_helper = {}
  end

  def play_game
    while @round < 2 # && code is unbroken
      # opening_message
      p @code
      gets_guess
      prints_guesses_by_round
      determine_feedback
      @round += 1
    end
  end

  def determine_feedback
    @feedback_by_round[@round] = []
    @feedback_helper = {code: [], guess: [] }
    @guesses_by_round[@round].each_with_index do |guess, index|
      if guess.to_i == @code[index].to_i
        @feedback_by_round[@round] << 2
      else
        @feedback_helper[:code] << @code[index].to_i
        @feedback_helper[:guess] << guess.to_i
      end
    end
    wrong_number_wrong_spot_array = @feedback_helper[:code] - @feedback_helper[:guess]
    wrong_number_wrong_spot = wrong_number_wrong_spot_array.count
    right_number_wrong_spot = 4 - @feedback_by_round[@round].count - wrong_number_wrong_spot

    @feedback_by_round[@round] += [1] * right_number_wrong_spot
    @feedback_by_round[@round] += [0] * wrong_number_wrong_spot 
  end

  def gets_guess
    @guesses_by_round[@round] = Array.new(4)
    puts '*********************************************'
    puts "****************** Round #{@round} ******************"
    puts '*********************************************'

    i = 0
    while i < 4
      puts "What is your guess for position #{i + 1}?"
      @guesses_by_round[@round][i] = @player.get_guess
      i += 1
    end
  end

  def prints_guesses_by_round
    puts "Your guesses for Round #{@round} are #{@guesses_by_round[@round]}"
  end

  def opening_message
    puts 'Welcome to Mastermind! Your goal is to break the secret code.'
    puts ''
    puts "Enter 'yes' to see game rules or 'no' to advance"
    if gets.chomp == 'yes'
      puts 'The code consists of 4 numbers between 1 and 6'
      puts 'You must enter them in the correct order.'
      puts 'Example: the code might be: [1,2,3,4]'
      puts 'You will have 12 guesses to crack the code'
      puts 'For every guess you will recieve feedback.'
      puts '_____________________________________________'
    else
      puts '_____________________________________________'
    end
  end
end

class Player
  def initialize; end

  def get_guess
    pass = 0
    until pass == 1
      begin
        guess = Kernel.gets.chomp.match(/^[1-6]{1}$/)[0]
      rescue StandardError => _e
        puts 'Your guess must be a number between 1-6. Please try again.'
      else
        pass = 1
        return guess
      end
    end
  end

end

#SecretCode
class Code
  attr_reader :code

  def initialize
    @code = [rand(1..6), rand(1..6), rand(1..6), rand(1..6)]
  end
end

game_code = Code.new
# p game_code.code

human_player = Player.new

game = Game.new(human_player, game_code)
game.play_game
