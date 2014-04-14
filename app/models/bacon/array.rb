# Special array class for quick insertion of sorted elements
# specifically for sorting BaconNodes by their depth.
# This way we can #shift the first one off the array and be
# confident we're searching from the best position
class Bacon::Array < Array

  def self.[](*array)
    self.new(array)
  end

  def initialize(array = nil)
    super(array.sort_by(&:depth)) if array
  end

  def <<(value)
    insert(index_for_value(value.depth), value)
  end

  private
  def index_for_value(value)
    index = 0
    max   = length - 1
    while index <= max
      lookup = (max + index) / 2

      if value < self[lookup].depth
        max = lookup - 1
      else
        index = lookup + 1
      end
    end
    index
  end
end
