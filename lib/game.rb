# frozen_string_literal: true

class Game
  include Count

  def initialize
    @player = Player.new
    @code_object = Code.new
    @computer_player = ComputerPlayer.new
    @round = 1
    @guesses_by_round = {}
    @feedback_by_round = {}
    @feedback_helper = {}
    @round_limit = 12
    @code_broken = 'no'
    @human_role = 1
  end

  def play_game
    opening_message
    @human_role = @player.choose_role.to_i
    assign_secret_code
    while @round <= @round_limit && @code_broken == 'no'
      puts "****************** Round #{@round} ******************"
      if @human_role == 1
        @guesses_by_round[@round] = @player.ask_for_entry.split('')
      else
        computer_guessing_turn
      end
      determine_and_give_feedback
      @round += 1
    end
    endgame_check_for_winner
  end

  def computer_guessing_turn
    @guesses_by_round[@round] = @computer_player.generate_computer_guess(
      @round, @guesses_by_round, @feedback_by_round
    )
    sleep(2)
    puts "The Computer guessed: #{@guesses_by_round[@round].join}"
  end

  def determine_and_give_feedback
    @feedback_by_round[@round] = determine_feedback(@guesses_by_round[@round])
    check_for_broken_code(@feedback_by_round[@round])
    puts "Feedback: #{@feedback_by_round[@round]}"
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

  def assign_secret_code
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
    @player.ask_for_entry.split('')
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
    puts 'The code consists of 4 numbers between 1 and 6 (numbers can be duplicated).'
    puts 'You must enter them in the correct order.'
    puts 'Example: the code might be 1123'
    puts 'You will have 12 guesses to crack the code.'
    puts 'For every guess you will recieve feedback.'
    puts 'Each 2 means one of your guesses is a correct number in the right spot.'
    puts 'Each 1 means one of your guesses is a correct number in the wrong spot.'
    puts 'Each 0 means one of your guesses is an incorrect number.'
    puts 'The order of the feedback does NOT correspond to the order of your guess.'
    puts "Example: a guess of '3142' with feedback '[2],[1],[1],[0]' does NOT necessarily mean the 3 is in the correct position."
  end
end
