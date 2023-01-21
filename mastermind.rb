module Feedback
  def determine_feedback(guess_array)
    @feedback_helper = { code: [], guess: [], feedback: [] }
    find_right_create_helper(guess_array)
    find_detail_for_wrong unless @feedback_helper[:feedback].count == 4
    @feedback_helper[:feedback]
  end

  def find_right_create_helper(guess_array)
    p guess_array
    guess_array.each_with_index do |guess, index|
      if guess.to_i == @code[index].to_i
        @feedback_helper[:feedback] << 2
      else
        @feedback_helper[:code] << @code[index].to_i
        @feedback_helper[:guess] << guess.to_i
      end
    end
  end

  def find_detail_for_wrong
    wrong_number = array_difference(@feedback_helper[:code], @feedback_helper[:guess])
    right_number_wrong_spot = 4 - @feedback_helper[:feedback].count - wrong_number

    @feedback_helper[:feedback] += [1] * right_number_wrong_spot
    @feedback_helper[:feedback] += [0] * wrong_number
  end

  def count_guesses(array)
    array.reduce(Hash.new(0)) do |number, occur|
      number[occur] += 1
      number
    end
  end
end

class Game
  include Feedback

  def initialize(player, computer_player, code_object)
    @player = player
    @code_object = code_object
    @code = code_object.code
    @round = 1
    @guesses_by_round = {}
    @feedback_by_round = {}
    @feedback_helper = {}
    @round_limit = 3
    @code_broken = 'no'
    @human_role = 1
    @computer_player = computer_player
  end

  def play_game
    # opening_message
    @human_role = @player.choose_role.to_i
    assign_code
    p @code
    while @round <= @round_limit && @code_broken == 'no'
      if @human_role == 1
        gets_human_guess
      else
        @guesses_by_round[@round] = @computer_player.generate_computer_guess(
          @round, @guesses_by_round, @feedback_by_round
        )
      end
      @feedback_by_round[@round] = determine_feedback(@guesses_by_round[@round])
      check_for_broken_code(@feedback_by_round[@round])
      give_feedback
      @round += 1
    end
    endgame_check_for_winner
  end

  def assign_code
    @code = if @human_role == 1
              @code_object.generate_random_code
            else
              assign_human_code
            end
  end

  def assign_human_code
    puts '*********************************************'
    puts '************* Secret Code Entry *************'
    puts '*********************************************'
    human_code = []
    i = 0
    while i < 4
      puts "What is your entry for position #{i + 1}?"
      human_code[i] = @player.ask_for_entry
      i += 1
    end
    human_code
  end

  def check_for_broken_code(feedback)
    hash = count_guesses(feedback)
    @code_broken = 'yes' if hash[2] == 4
  end

  def endgame_check_for_winner
    if @code_broken == 'yes' && @human_role == 1
      puts "You cracked the code! #{@code}"
    elsif @code_broken == 'no' && @human_role == 1
      puts "You lost! The code was #{@code}."
    elsif @code_broken == 'yes' && @human_role == 2
      puts 'You lost! The computer cracked your code :('
    else
      puts "You won! The computer couldn't crack your code!"
    end
  end

  def give_feedback
    i = 1
    puts ''
    while i <= @round
      puts "Round #{i}"
      puts "Guesses: #{@guesses_by_round[i]}"
      puts "Feedback: #{@feedback_by_round[i]}."
      puts ''
      i += 1
    end
  end

  def array_difference(code, guess)
    code_hash = count_guesses(code)
    guess_hash = count_guesses(guess)
    wrong_number = 0
    i = 1
    while i <= 6
      wrong_number += code_hash[i] - guess_hash[i] if (code_hash[i] - guess_hash[i]).positive?
      i += 1
    end
    wrong_number
  end

  def gets_human_guess
    @guesses_by_round[@round] = Array.new(4)
    puts '*********************************************'
    puts "****************** Round #{@round} ******************"
    puts '*********************************************'

    i = 0
    while i < 4
      puts "What is your guess for position #{i + 1}?"
      @guesses_by_round[@round][i] = @player.ask_for_entry
      i += 1
    end
  end

  def opening_message
    puts '*************************************************************************'
    puts '*************************************************************************'
    puts '******Welcome to Mastermind! Your goal is to break the secret code.******'
    puts '*************************************************************************'
    puts '*************************************************************************'
    puts "Enter 'yes' to see game rules or 'no' to advance"
    if gets.chomp == 'yes'
      puts 'The code consists of 4 numbers between 1 and 6'
      puts 'You must enter them in the correct order.'
      puts 'Example: the code might be: [1,1,2,3]'
      puts 'You will have 12 guesses to crack the code.'
      puts 'For every guess you will recieve feedback.'
      puts 'Each 2 means one of your guesses is a correct number in the right spot.'
      puts 'Each 1 means one of your guesses is a correct number in the wrong spot.'
      puts 'Each 0 means one of your guesses is an incorrect number.'
      puts 'The order of the feedback does NOT correspond to the order of your guess.'
    end
    puts '_____________________________________________'
  end
end

# player
class Player
  def initialize; end

  def ask_for_entry
    pass = 0
    until pass == 1
      begin
        guess = Kernel.gets.chomp.match(/^[1-6]{1}$/)[0]
      rescue StandardError => _e
        puts 'Your entry must be a number between 1-6. Please try again.'
      else
        pass = 1
        return guess
      end
    end
  end

  def choose_role
    puts ''
    puts 'Enter 1 to play as the codebreaker or enter 2 to submit your own code.'
    pass = 0
    until pass == 1
      begin
        role_choice = Kernel.gets.chomp.match(/^[1-2]{1}$/)[0]
      rescue StandardError => _e
        puts 'Your must choose either 1 or 2. Please try again.'
      else
        pass = 1
        return role_choice
      end
    end
  end
end

# comp player
class ComputerPlayer
  include Feedback

  def initialize
    @set_of_possible = [1, 2, 3, 4, 5, 6].repeated_permutation(4).to_a
  end

  def generate_computer_guess(round, guesses, feedback)
    # create_set_of_possible
    # p @set_of_possible
    if round == 1
      [1, 1, 2, 2]
    else
      eliminate_impossible_arrays(round, guesses, feedback)
    end
  end

  def eliminate_impossible_arrays(round, guesses, feedback)
    # guesses
    p @set_of_possible.include?([1, 1, 2, 2])
    p guesses[round - 1]
    p @set_of_possible.find_index(guesses[round - 1])
    @set_of_possible.delete_at(@set_of_possible.find_index(guesses[round - 1]))
    p @set_of_possible.include?([1, 1, 2, 2])

    # @set_of_possible.select! do |array|
    #   array.include?(1) || array.include?(2) || array.include?(3) || array.include?(4)
    # end
    p @set_of_possible
    p @set_of_possible.count
    [rand(1..6), rand(1..6), rand(1..6), rand(1..6)]
  end
end

# SecretCode
class Code
  attr_reader :code

  def initialize
    # @code = [6, 1, 2, 2]
    @code = []
  end

  def generate_random_code
    @code = [rand(1..6), rand(1..6), rand(1..6), rand(1..6)]
  end
end

code_object = Code.new

human_player = Player.new
computer_player = ComputerPlayer.new

game = Game.new(human_player, computer_player, code_object)
game.play_game

# feedback module
