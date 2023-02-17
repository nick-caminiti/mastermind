# frozen_string_literal: true

module Count
  def array_to_hash(array)
    array.reduce(Hash.new(0)) do |number, occur|
      number[occur] += 1
      number
    end
  end
end