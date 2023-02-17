# frozen_string_literal: true

module Count
  def array_to_hash(array)
    array.reduce(Hash.new(0)) do |number, occur|
      number[occur] += 1
      number
    end
  end
end

# game
class Game
  include Count

  def initialize(player, computer_player, code_object)
    @player = player
    @code_object = code_object
    @code = code_object.code
    @round = 1
    @guesses_by_round = {}
    @feedback_by_round = {}
    @feedback_helper = {}
    @round_limit = 12
    @code_broken = 'no'
    @human_role = 1
    @computer_player = computer_player
  end

  def play_game
    opening_message
    @human_role = @player.choose_role.to_i
    assign_code
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

  def determine_feedback(guess_array)
    @feedback_helper = { code: [], guess: [], feedback: [] }
    find_right_create_helper(guess_array)
    find_detail_for_wrong unless @feedback_helper[:feedback].count == 4
    @feedback_helper[:feedback]
  end

  def find_right_create_helper(guess_array)
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
    hash = array_to_hash(feedback)
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
      puts "Feedback: #{@feedback_by_round[i]}"
      puts ''
      i += 1
    end
  end

  def array_difference(code, guess)
    code_hash = array_to_hash(code)
    guess_hash = array_to_hash(guess)
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
    instructions if gets.chomp == 'yes'
    puts '_____________________________________________'
  end

  def instructions
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
  include Count

  def initialize
    @set_of_possible = [1, 2, 3, 4, 5, 6].repeated_permutation(4).to_a
    @three_right_nums = false
  end

  def generate_computer_guess(round, guesses, feedback)
    if round == 1
      [1, 1, 2, 2]
    else
      eliminate_impossible_arrays(round, guesses, feedback)
      @set_of_possible[rand(0..(@set_of_possible.count - 1))]
    end
  end

  def eliminate_impossible_arrays(round, guesses, feedback)
    # delete last rounds guess from possibles
    @set_of_possible.delete_at(@set_of_possible.find_index(guesses[round - 1]))
    latest_guess = guesses[round - 1]
    latest_feedback = array_to_hash(feedback[round - 1])
    correct_number_count = latest_feedback[2] + latest_feedback[1]
    if correct_number_count.positive?
      correct_num_branch(latest_guess, latest_feedback, correct_number_count)
    else
      reject_all_current_nums(latest_guess)
    end
  end

  def correct_num_branch(latest_guess, latest_feedback, correct_number_count)
    if correct_number_count == 4
      remove_any_dif_nums(latest_guess)
    else
      remove_same_nums_dif_order(latest_guess)
      remove_pairs(latest_guess) if correct_number_count == 1
    end
    necessary_combos = latest_guess.combination(correct_number_count).to_a
    remove_no_nec_combos(necessary_combos)
    no_twos_remove_same_positions(latest_guess) if latest_feedback[2].zero?
  end

  def remove_pairs(guess)
    @set_of_possible.reject! do |possible_array|
      possible_hash = array_to_hash(possible_array)
      guess_hash = array_to_hash(guess)
      test_for_pairs(possible_hash, guess_hash)
    end
  end

  def test_for_pairs(possible_hash, guess_hash)
    pass = false
    in_common = 0
    i = 1
    while i <= 6
      if (possible_hash[i] - guess_hash[i]).zero?
        in_common += possible_hash[i]
      elsif (possible_hash[i] - guess_hash[i]).positive?
        in_common += guess_hash[i]
      end
      i += 1
    end
    pass = true if in_common >= 2
    pass
  end

  def remove_any_dif_nums(guess)
    @set_of_possible.select! do |possible_array|
      dif_nums(possible_array, guess)
    end
  end

  def dif_nums(possible, guess)
    pass = true
    i = 0
    while i < 4
      pass = false unless possible.include?(guess[i])
      i += 1
    end
    pass
  end

  def remove_same_nums_dif_order(guess)
    @set_of_possible.reject! do |possible_array|
      same_nums_dif_order(possible_array, guess)
    end
  end

  def same_nums_dif_order(possible, guess)
    possible_hash = array_to_hash(possible)
    guess_hash = array_to_hash(guess)
    test_for_overlap(possible_hash, guess_hash)
  end

  def reject_all_current_nums(guess)
    i = 0
    while i < 4
      @set_of_possible.reject! do |possible_array|
        possible_array.include?(guess[i])
      end
      i += 1
    end
  end

  def remove_no_nec_combos(necessary_combos)
    # get rid of anything that doesn't have all of the numbers in at least one nec combo
    necessary_hash_combos = []
    i = 0
    while i < necessary_combos.count
      necessary_hash_combos[i] = array_to_hash(necessary_combos[i])
      i += 1
    end
    @set_of_possible.select! do |possible_array|
      possible_hash = array_to_hash(possible_array)
      test_each_necessary_hash(possible_hash, necessary_hash_combos)
    end
  end

  def test_each_necessary_hash(possible_hash, necessary_combos_array_of_hashes)
    # returns true if possible fully includes necessary
    # p "necessary combos hash: #{necessary_combos_hash}"
    necessary_combos_array_of_hashes.each do |necessary_hash|
      return true if test_for_overlap(possible_hash, necessary_hash)
    end
    false
  end

  def test_for_overlap(possible_hash, necessary_hash)
    pass = true
    i = 1
    while i <= 6
      pass = false unless possible_hash[i] >= necessary_hash[i]
      i += 1
    end
    pass
  end

  def no_twos_remove_same_positions(guess)
    i = 0
    while i < 4
      @set_of_possible.reject! do |possible_array|
        possible_array[i] == guess[i]
      end
      i += 1
    end
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
