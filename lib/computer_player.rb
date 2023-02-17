# frozen_string_literal: true

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