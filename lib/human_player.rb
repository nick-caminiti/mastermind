# frozen_string_literal: true

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