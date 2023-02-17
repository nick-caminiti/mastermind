# frozen_string_literal: true

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